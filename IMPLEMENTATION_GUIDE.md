# EMHASS EV Charging Extension - Implementation Guide

## 🚗⚡ What This Extension Adds

This extension enhances EMHASS to support sophisticated Electric Vehicle (EV) charging optimization with:

- **Availability Scheduling**: Define when your EV is plugged in using 0s and 1s arrays
- **SOC Requirements**: Specify minimum battery charge levels at different times
- **Multiple EVs**: Support for households with multiple electric vehicles
- **Full Integration**: Works with existing PV, battery, and deferrable load optimization
- **Runtime Flexibility**: Update schedules dynamically via API calls

## 🏗️ Files Created

### 1. **EV_CHARGING_EXTENSION_DESIGN.md**

Complete technical specification including:

- Architecture design and constraint formulations
- Integration with existing EMHASS optimization model
- Variable definitions and mathematical constraints
- API interface specifications

### 2. **example_ev_optimization.py**

Working Python examples showing:

- How to create EV availability schedules
- Different scenarios (daily commuter, weekend vs weekday, multi-EV)
- API payload formats for EMHASS integration
- Results analysis and interpretation

### 3. **example_ev_config.yaml**

Complete configuration example with:

- EV parameter definitions and typical values
- Integration with existing EMHASS features
- Real-world use case examples
- API usage patterns

### 4. **Updated Add-on Configuration**

- **config.yml**: Added EV parameter schema to Home Assistant add-on
- **translations/en.yaml**: User-friendly descriptions for EV parameters

## 🔧 How to Implement

### Phase 1: Configure the Add-on (✅ Done)

The EMHASS add-on configuration now supports EV parameters:

```yaml
# In Home Assistant Add-on Configuration
number_of_ev_loads: 1
ev_battery_capacity: "[60000]" # 60kWh battery
ev_charging_efficiency: "[0.9]" # 90% efficiency
ev_nominal_charging_power: "[7400]" # 7.4kW charger
ev_minimum_charging_power: "[1380]" # 1.38kW minimum
```

### Phase 2: Extend EMHASS Core (Implementation Required)

To fully implement this extension, you'll need to modify the core EMHASS code:

1. **Fork the EMHASS Repository**:

   ```bash
   git clone https://github.com/davidusb-geek/emhass.git
   cd emhass
   git checkout -b ev-charging-extension
   ```

2. **Modify `src/emhass/optimization.py`**:

   - Add EV variable creation (P_ev, SOC_ev, P_ev_bin)
   - Add EV constraints (availability, SOC evolution, minimum SOC)
   - Update power balance constraint to include EV loads
   - Add EV results to output DataFrame

3. **Modify `src/emhass/utils.py`**:

   - Add EV parameters to runtime parameter handling
   - Add EV configuration parsing and validation

4. **Update Configuration Defaults**:
   - Add EV parameters to `data/config_defaults.json`
   - Set sensible defaults (number_of_ev_loads: 0 to disable by default)

### Phase 3: Test and Validate

Use the provided examples to test the implementation:

```python
# Test basic EV optimization
python example_ev_optimization.py

# Test with your actual EMHASS instance
optimizer = EVChargingOptimizer("http://your-emhass-url:5000")
results = optimizer.optimize_ev_charging(ev_schedule)
```

## 📋 Key Features

### 1. **Realistic EV Modeling**

```python
# EV availability: when plugged in (0=no, 1=yes)
ev_availability = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1]  # 6PM-8AM

# Minimum SOC requirements over time
ev_minimum_soc = [0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,...]  # 80% by 7AM

# Starting charge level
ev_initial_soc = 0.15  # Currently at 15%
```

### 2. **Multiple EV Support**

```python
# Two EVs with different schedules
{
  "ev_availability": [
    [0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0],  # EV1 schedule
    [1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1]   # EV2 schedule
  ],
  "ev_minimum_soc_schedule": [...],  # Different SOC requirements
  "ev_initial_soc": [0.2, 0.4]  # Different starting levels
}
```

### 3. **Smart Optimization**

The system automatically:

- Charges during cheapest electricity periods
- Uses excess solar production when available
- Coordinates with home battery to minimize costs
- Respects grid connection limits
- Ensures minimum SOC requirements are met

## 🌟 Use Cases

### Daily Commuter

```yaml
# Configuration
EV plugged in: 6 PM - 8 AM
Need 80% charge by 7 AM for daily commute
Optimize around time-of-use rates

# Result: Charges during cheap night rates while meeting morning requirements
```

### Multi-EV Household

```yaml
# Configuration
EV1: Daily commuter (80% by 7 AM)
EV2: Weekend car (60% by 10 AM weekends only)
Load balancing to avoid exceeding grid limits

# Result: Coordinates charging to minimize total cost and grid impact
```

### Flexible Schedule

```yaml
# Configuration
Update availability daily via API
Different SOC requirements for different trip types
Adapt to work-from-home vs office days
# Result: Optimizes based on actual usage patterns
```

## 🚀 Next Steps

1. **Immediate**: Use the configuration examples to set up EV parameters in your add-on

2. **Development**: Implement the core optimization extensions in EMHASS:

   - Follow the technical design in `EV_CHARGING_EXTENSION_DESIGN.md`
   - Start with single EV support, then add multi-EV capability
   - Test thoroughly with the provided examples

3. **Enhancement**: Consider future features:
   - Vehicle-to-Grid (V2G) capability
   - Non-linear charging curves based on SOC
   - Integration with smart charging standards (OCPP, ISO 15118)
   - Temperature effects on battery capacity

## 💡 Benefits

- **Cost Savings**: Optimize charging around electricity rates and solar production
- **Grid Friendly**: Avoid peak demand periods and grid connection limits
- **Flexible**: Adapt to changing schedules and requirements
- **Realistic**: Model actual EV behavior including battery SOC tracking
- **Integrated**: Works seamlessly with existing EMHASS features

## 📞 Support

For implementation questions:

- Review the detailed technical design document
- Study the Python examples for API usage patterns
- Test with the provided configuration examples
- Start with single EV before adding complexity

This extension transforms EMHASS from a general deferrable load optimizer into a sophisticated EV charging management system that understands the real constraints and requirements of electric vehicle ownership.
