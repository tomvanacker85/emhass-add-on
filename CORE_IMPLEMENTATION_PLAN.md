# EMHASS EV Extension Implementation Plan

## 🎯 Current Status

You have successfully:

- ✅ Forked `davidusb-geek/emhass` to `tomvanacker85/emhass`
- ✅ Extended EMHASS add-on configuration with EV parameters
- ✅ Created comprehensive technical design document
- ✅ Built working Python examples demonstrating the API interface

## 🚀 Next Steps: Core EMHASS Implementation

### Phase 1: Clone and Setup Your Fork

```bash
# Clone your forked EMHASS repository
cd /workspaces
git clone https://github.com/tomvanacker85/emhass.git
cd emhass

# Create a feature branch for EV extension
git checkout -b feature/ev-charging-extension

# Install development dependencies
pip install -e .
```

### Phase 2: Core File Modifications

#### 1. **src/emhass/optimization.py** - Main Implementation

**Location**: Primary optimization engine
**Changes**: Add EV variables, constraints, and SOC tracking

Key modifications needed:

- Add EV power variables: `P_ev[ev_idx][time_step]`
- Add EV SOC variables: `SOC_ev[ev_idx][time_step]`
- Add EV binary variables: `P_ev_bin[ev_idx][time_step]`
- Implement availability constraints
- Implement SOC tracking and minimum requirements
- Update power balance equations

#### 2. **src/emhass/retrieve_hass.py** - Runtime Parameters

**Location**: Handles runtime parameter parsing
**Changes**: Add EV runtime parameter support

Add parsing for:

- `ev_availability`: 2D array of 0s/1s
- `ev_minimum_soc_schedule`: 2D array of minimum SOC requirements
- `ev_initial_soc`: Array of starting SOC values

#### 3. **src/emhass/web_server.py** - API Endpoints

**Location**: REST API server
**Changes**: Update API to accept EV parameters

Modify endpoints:

- `/action/dayahead-optim`
- `/action/naive-mpc-optim`
- `/action/perfect-optim-optim`

#### 4. **src/emhass/command_line.py** - Configuration Loading

**Location**: Configuration management
**Changes**: Load EV configuration parameters

Add support for:

- `number_of_ev_loads`
- `ev_battery_capacity`
- `ev_charging_efficiency`
- `ev_nominal_charging_power`
- `ev_minimum_charging_power`

### Phase 3: Implementation Priority Order

#### 🥇 **Priority 1: Basic EV Variables (Start Here)**

1. **File**: `src/emhass/optimization.py`
2. **Function**: `perform_optimization()` or similar
3. **Add**: Basic EV power variables and simple constraints

```python
# Add EV power variables
for ev_idx in range(self.optim_conf['number_of_ev_loads']):
    for i in range(self.optim_conf['prediction_horizon']):
        P_ev[ev_idx].append(self.optim.continuous_var(
            lb=0,
            ub=self.optim_conf['ev_nominal_charging_power'][ev_idx],
            name="P_ev_{}_{}"format(ev_idx, i)
        ))
```

#### 🥈 **Priority 2: SOC Tracking**

Add state-of-charge variables and tracking constraints:

```python
# SOC tracking constraint
for t in range(1, prediction_horizon):
    constraint = SOC_ev[ev_idx][t] == (
        SOC_ev[ev_idx][t-1] +
        (P_ev[ev_idx][t-1] * self.optim_conf['ev_charging_efficiency'][ev_idx] *
         self.optim_conf['time_step'] / self.optim_conf['ev_battery_capacity'][ev_idx])
    )
    self.optim.add_constraint(constraint)
```

#### 🥉 **Priority 3: Availability & SOC Constraints**

Add availability and minimum SOC constraints using runtime parameters.

### Phase 4: Testing Strategy

#### 1. **Unit Tests**

```bash
cd /workspaces/emhass
python -m pytest tests/ -v
```

#### 2. **Integration Tests**

```bash
# Test with your add-on configuration
python -m emhass.command_line --action dayahead-optim --config /path/to/config
```

#### 3. **Validation Tests**

Use the examples from your add-on to validate results match expected behavior.

## 🔧 Detailed Implementation Steps

### Step 1: Start with optimization.py

1. **Navigate to your EMHASS fork**:

   ```bash
   cd /workspaces
   git clone https://github.com/tomvanacker85/emhass.git
   ```

2. **Find the optimization file**:

   ```bash
   find . -name "optimization.py" -type f
   ```

3. **Locate the main optimization function** (usually `perform_optimization` or similar)

4. **Add EV variables after existing deferrable load variables**

### Step 2: Test Basic Integration

1. **Create a minimal test case** using your add-on configuration
2. **Run optimization** with 1 EV, simple availability schedule
3. **Verify variables are created** and constraints don't conflict

### Step 3: Incremental Feature Addition

1. **Basic EV power variables** ✅
2. **SOC tracking** ✅
3. **Availability constraints** ✅
4. **Minimum SOC requirements** ✅
5. **Multi-EV support** ✅
6. **Integration with power balance** ✅

## 📁 File Structure Reference

```
tomvanacker85/emhass/
├── src/emhass/
│   ├── optimization.py      ← **PRIMARY TARGET**
│   ├── retrieve_hass.py     ← Runtime parameters
│   ├── web_server.py        ← API endpoints
│   ├── command_line.py      ← Configuration loading
│   └── utils.py             ← Helper functions
├── tests/                   ← Add EV tests here
└── config/                  ← Test configurations
```

## 🚨 Important Notes

### Coordinate with Add-on Repository

Your add-on in `/workspaces/emhass-add-on` contains:

- Configuration schema extensions ✅
- Technical design document ✅
- Working examples ✅

Your fork `tomvanacker85/emhass` will contain:

- Core optimization engine modifications 🚧
- Runtime parameter handling 🚧
- API endpoint updates 🚧

### Maintain Compatibility

- Keep all existing EMHASS functionality working
- EV features should be optional (disabled when `number_of_ev_loads: 0`)
- Existing deferrable loads should work alongside EV loads

### Development Workflow

1. Make changes in `tomvanacker85/emhass`
2. Test with configuration from your add-on
3. Update add-on to use your EMHASS fork instead of official version
4. Eventually contribute back to main EMHASS repository

## 🔄 Integration with Add-on

Once core implementation is complete, update your add-on to use your fork:

```dockerfile
# In your add-on Dockerfile
RUN pip install git+https://github.com/tomvanacker85/emhass.git@feature/ev-charging-extension
```

## 🎉 Success Criteria

You'll know the implementation is working when:

1. ✅ EMHASS accepts EV configuration parameters
2. ✅ Optimization creates EV variables and constraints
3. ✅ API accepts EV runtime parameters from your examples
4. ✅ Optimization results show realistic EV charging schedules
5. ✅ SOC requirements are satisfied
6. ✅ Availability windows are respected
7. ✅ Multi-EV scenarios work correctly

---

Ready to start with **Step 1: Clone and examine the optimization.py file**? Let me know when you're ready to dive into the core implementation!
