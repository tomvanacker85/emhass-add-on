# EV Charging Extension Design for EMHASS

## Overview

This document describes the proposed extension to EMHASS to add sophisticated Electric Vehicle (EV) charging optimization capabilities. The extension maintains compatibility with existing deferrable loads while adding EV-specific constraints and variables.

## Current State Analysis

### Existing Deferrable Load System

EMHASS currently supports generic deferrable loads with:

- `P_deferrable[k][i]` - Power consumption variables
- Binary variables for semi-continuous operation
- Operating hours/timestep constraints
- Time window constraints (start/end timesteps)
- Minimum power constraints
- Runtime parameter support

### Limitations for EV Charging

1. No battery state tracking
2. No availability scheduling (when EV is plugged in)
3. No minimum charge level requirements over time
4. No charging efficiency modeling

## Proposed EV Extension Architecture

### 1. Configuration Parameters

#### Add to EMHASS config.yml schema:

```yaml
number_of_ev_loads: "int?" #optional
ev_battery_capacity: "str?" #optional - JSON array of EV battery capacities in Wh
ev_charging_efficiency: "str?" #optional - JSON array of EV charging efficiencies (0-1)
ev_nominal_charging_power: "str?" #optional - JSON array of max EV charging power in W
ev_minimum_charging_power: "str?" #optional - JSON array of min EV charging power in W
```

#### Add to Home Assistant Add-on Configuration:

- **number_of_ev_loads**: Number of EVs to optimize (default: 0)
- **ev_battery_capacity**: JSON array `[60000, 75000]` (Wh)
- **ev_charging_efficiency**: JSON array `[0.9, 0.85]` (0-1)
- **ev_nominal_charging_power**: JSON array `[7400, 11000]` (W)
- **ev_minimum_charging_power**: JSON array `[1380, 2000]` (W)

### 2. Runtime Parameters

These arrays are passed at runtime via API calls:

```python
# EV availability (0/1 for each timestep in prediction horizon)
ev_availability: [[1, 1, 1, 0, 0, 0, 1, 1, ...]]  # Length = prediction_horizon

# Minimum desired SOC at each timestep (0-1)
ev_minimum_soc_schedule: [[0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.6, ...]]  # Length = prediction_horizon

# Initial SOC for each EV (0-1)
ev_initial_soc: [0.2, 0.4]  # Current charge level
```

### 3. Optimization Variables

#### New Decision Variables:

```python
# EV charging power (W) at each timestep
P_ev = {}  # P_ev[k][i] = EV k charging power at timestep i

# EV battery state of charge (0-1) at each timestep
SOC_ev = {}  # SOC_ev[k][i] = EV k SOC at timestep i

# Binary variables for EV charging state
P_ev_bin = {}  # P_ev_bin[k][i] = 1 if EV k is charging at timestep i
```

#### Variable Bounds:

```python
# For each EV k and timestep i:
P_ev[k][i]: 0 <= P_ev[k][i] <= ev_nominal_charging_power[k]
SOC_ev[k][i]: 0 <= SOC_ev[k][i] <= 1
P_ev_bin[k][i]: binary {0, 1}
```

### 4. Optimization Constraints

#### A. Availability Constraints

EV can only charge when connected (plugged in):

```python
# For each EV k and timestep i:
P_ev[k][i] <= ev_availability[k][i] * ev_nominal_charging_power[k]
```

#### B. SOC Evolution Equations

Track battery charge level over time:

```python
# For each EV k and timestep i > 0:
SOC_ev[k][i] = SOC_ev[k][i-1] + (
    P_ev[k][i-1] * ev_charging_efficiency[k] * timeStep
) / ev_battery_capacity[k]

# Initial condition:
SOC_ev[k][0] = ev_initial_soc[k]
```

#### C. Minimum SOC Requirements

Ensure EV meets minimum charge requirements:

```python
# For each EV k and timestep i:
SOC_ev[k][i] >= ev_minimum_soc_schedule[k][i]
```

#### D. Charging Power Constraints

Semi-continuous charging (either off or above minimum power):

```python
# For each EV k and timestep i:
# If charging, must be above minimum power:
P_ev[k][i] >= ev_minimum_charging_power[k] * P_ev_bin[k][i]

# Binary relationship:
P_ev[k][i] <= ev_nominal_charging_power[k] * P_ev_bin[k][i]
```

#### E. Grid Integration

Add EV loads to main power balance:

```python
# Modified power balance constraint:
P_grid_pos[i] - P_grid_neg[i] + P_PV[i] = (
    P_load[i] +
    sum(P_deferrable[k][i] for k in deferrable_loads) +
    sum(P_ev[k][i] for k in ev_loads) +
    P_sto_pos[i] + P_sto_neg[i]
)
```

### 5. Objective Function Integration

Add EV charging costs to existing objective:

```python
# Add to cost minimization objective:
ev_charging_cost = sum(
    P_ev[k][i] * unit_load_cost[i] * timeStep
    for k in ev_loads for i in timesteps
)

objective += ev_charging_cost
```

### 6. Implementation in EMHASS Core

#### File: `src/emhass/optimization.py`

Key modifications needed:

1. **Add EV configuration parsing**:

```python
# In perform_optimization method
if self.optim_conf.get("number_of_ev_loads", 0) > 0:
    num_ev_loads = self.optim_conf["number_of_ev_loads"]
    ev_battery_capacity = self.optim_conf["ev_battery_capacity"]
    ev_charging_efficiency = self.optim_conf["ev_charging_efficiency"]
    # ... other EV parameters
```

2. **Create EV variables**:

```python
# EV charging power variables
P_ev = []
SOC_ev = []
P_ev_bin = []

for k in range(num_ev_loads):
    P_ev.append({
        i: plp.LpVariable(
            cat="Continuous",
            lowBound=0,
            upBound=ev_nominal_charging_power[k],
            name=f"P_ev{k}_{i}"
        ) for i in set_I
    })

    SOC_ev.append({
        i: plp.LpVariable(
            cat="Continuous",
            lowBound=0,
            upBound=1,
            name=f"SOC_ev{k}_{i}"
        ) for i in set_I
    })

    P_ev_bin.append({
        i: plp.LpVariable(
            cat="Binary",
            name=f"P_ev_bin{k}_{i}"
        ) for i in set_I
    })
```

3. **Add EV constraints**:

```python
# Availability constraints
for k in range(num_ev_loads):
    for i in set_I:
        constraints[f"ev_availability_{k}_{i}"] = plp.LpConstraint(
            e=P_ev[k][i] - ev_availability[k][i] * ev_nominal_charging_power[k],
            sense=plp.LpConstraintLE,
            rhs=0
        )

# SOC evolution constraints
for k in range(num_ev_loads):
    # Initial SOC
    constraints[f"ev_soc_initial_{k}"] = plp.LpConstraint(
        e=SOC_ev[k][0],
        sense=plp.LpConstraintEQ,
        rhs=ev_initial_soc[k]
    )

    # SOC evolution over time
    for i in range(1, len(set_I)):
        constraints[f"ev_soc_evolution_{k}_{i}"] = plp.LpConstraint(
            e=SOC_ev[k][i] - SOC_ev[k][i-1] - (
                P_ev[k][i-1] * ev_charging_efficiency[k] * self.timeStep
                / ev_battery_capacity[k]
            ),
            sense=plp.LpConstraintEQ,
            rhs=0
        )

# Minimum SOC constraints
for k in range(num_ev_loads):
    for i in set_I:
        constraints[f"ev_min_soc_{k}_{i}"] = plp.LpConstraint(
            e=SOC_ev[k][i],
            sense=plp.LpConstraintGE,
            rhs=ev_minimum_soc_schedule[k][i]
        )

# Semi-continuous charging constraints
for k in range(num_ev_loads):
    for i in set_I:
        # Minimum power when charging
        constraints[f"ev_min_power_{k}_{i}"] = plp.LpConstraint(
            e=P_ev[k][i] - ev_minimum_charging_power[k] * P_ev_bin[k][i],
            sense=plp.LpConstraintGE,
            rhs=0
        )

        # Maximum power constraint with binary
        constraints[f"ev_max_power_{k}_{i}"] = plp.LpConstraint(
            e=P_ev[k][i] - ev_nominal_charging_power[k] * P_ev_bin[k][i],
            sense=plp.LpConstraintLE,
            rhs=0
        )
```

4. **Update power balance constraint**:

```python
# Modified power balance including EV loads
for i in set_I:
    ev_power_sum = plp.lpSum(P_ev[k][i] for k in range(num_ev_loads))

    constraints[f"constraint_power_balance_{i}"] = plp.LpConstraint(
        e=P_grid_pos[i] - P_grid_neg[i] + P_PV[i] - P_load[i] -
          plp.lpSum(P_deferrable[k][i] for k in range(num_deferrable_loads)) -
          ev_power_sum - P_sto_pos[i] - P_sto_neg[i],
        sense=plp.LpConstraintEQ,
        rhs=0
    )
```

5. **Update results output**:

```python
# Add EV results to optimization output
for k in range(num_ev_loads):
    opt_tp[f"P_ev{k}"] = [P_ev[k][i].varValue for i in set_I]
    opt_tp[f"SOC_ev{k}"] = [SOC_ev[k][i].varValue for i in set_I]
```

### 7. Runtime Parameter Support

#### File: `src/emhass/utils.py`

Add EV parameters to runtime handling:

```python
# In treat_runtimeparams function
if "ev_availability" in runtimeparams.keys():
    params["passed_data"]["ev_availability"] = runtimeparams["ev_availability"]

if "ev_minimum_soc_schedule" in runtimeparams.keys():
    params["passed_data"]["ev_minimum_soc_schedule"] = runtimeparams["ev_minimum_soc_schedule"]

if "ev_initial_soc" in runtimeparams.keys():
    params["passed_data"]["ev_initial_soc"] = runtimeparams["ev_initial_soc"]
```

### 8. API Usage Examples

#### Day-ahead Optimization with EV:

```python
POST /action/dayahead-optim
{
    "ev_availability": [[1, 1, 1, 0, 0, 0, 1, 1, 1, ...]],  # EV0 availability
    "ev_minimum_soc_schedule": [[0.3, 0.3, 0.4, 0.5, 0.8, 0.8, 0.6, ...]],  # EV0 desired SOC
    "ev_initial_soc": [0.2],  # EV0 starting at 20% charge
    "prediction_horizon": 24
}
```

#### MPC Optimization with Multiple EVs:

```python
POST /action/naive-mpc-optim
{
    "ev_availability": [
        [1, 1, 1, 0, 0, 0, 1, 1, ...],  # EV0 schedule
        [0, 0, 1, 1, 1, 1, 0, 0, ...]   # EV1 schedule
    ],
    "ev_minimum_soc_schedule": [
        [0.2, 0.2, 0.3, 0.5, 0.8, 0.8, 0.6, ...],  # EV0 SOC requirements
        [0.4, 0.4, 0.4, 0.6, 0.9, 0.9, 0.7, ...]   # EV1 SOC requirements
    ],
    "ev_initial_soc": [0.15, 0.35],  # Both EVs current charge
    "prediction_horizon": 48
}
```

### 9. Benefits of This Design

1. **Maintains Compatibility**: Existing deferrable loads work unchanged
2. **Flexible Configuration**: Support multiple EVs with different characteristics
3. **Runtime Flexibility**: Availability and SOC schedules can be updated dynamically
4. **Realistic Modeling**: Accounts for charging efficiency, battery capacity, availability
5. **Integration**: Works with existing PV, battery, and grid optimization
6. **Extensible**: Can easily add features like V2G (vehicle-to-grid) later

### 10. Use Case Examples

#### Scenario 1: Daily Commuter

- EV available: 18:00-08:00 (evening to morning)
- Minimum SOC: 80% by 07:00 (for daily commute)
- Optimize charging during low electricity rates

#### Scenario 2: Unpredictable Schedule

- EV availability varies daily (passed at runtime)
- Different SOC requirements (weekend vs weekday)
- Optimize around actual usage patterns

#### Scenario 3: Multi-EV Household

- Two EVs with different schedules and requirements
- Load balancing to avoid exceeding grid connection limits
- Coordinate with home battery and PV system

## Implementation Steps

1. **Phase 1**: Add configuration schema to add-on (✅ Done)
2. **Phase 2**: Extend EMHASS core optimization model
3. **Phase 3**: Add runtime parameter support
4. **Phase 4**: Update web configuration interface
5. **Phase 5**: Testing and validation with real scenarios

## Future Enhancements

- **Vehicle-to-Grid (V2G)**: Allow EV to discharge back to home/grid
- **Charging curves**: Non-linear charging power based on SOC
- **Temperature effects**: Adjust capacity/efficiency based on ambient temperature
- **Smart charging protocols**: Integration with OCPP/ISO 15118 standards
- **Multi-location charging**: Handle charging at work, public stations, etc.
