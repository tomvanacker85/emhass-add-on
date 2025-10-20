# EMHASS EV Charging Extension

This repository contains a comprehensive extension to EMHASS (Energy Management for Home Assistant) that adds advanced EV (Electric Vehicle) charging optimization capabilities.

## 🚗 What This Extension Adds

The EV extension allows you to optimize your electric vehicle charging with:

- **Time-based availability control**: Define when your EV is connected using binary arrays (0/1)
- **Dynamic SOC requirements**: Set minimum battery charge levels for different times
- **Multi-EV support**: Optimize multiple electric vehicles simultaneously
- **Intelligent scheduling**: Balance EV charging with existing deferrable loads and home energy needs

## 📁 Files Created/Modified

### Configuration Files

- `emhass/config.yml` - Extended Home Assistant add-on configuration schema
- `emhass/translations/en.yaml` - User-friendly parameter descriptions
- `example_ev_config.yaml` - Complete configuration examples and use cases

### Documentation

- `EV_CHARGING_EXTENSION_DESIGN.md` - Complete technical specification
- `IMPLEMENTATION_GUIDE.md` - Step-by-step implementation instructions
- `EV_EXTENSION_README.md` - This overview document

### Examples

- `example_ev_optimization.py` - Working Python examples demonstrating API usage

## 🔧 How It Works

### 1. Configure Your EVs

Add EV parameters to your Home Assistant add-on configuration:

```yaml
number_of_ev_loads: 1
ev_battery_capacity: [60000] # 60kWh battery
ev_charging_efficiency: [0.9] # 90% charging efficiency
ev_nominal_charging_power: [7400] # 7.4kW charger
ev_minimum_charging_power: [1380] # 1.38kW minimum power
```

### 2. Define Availability & SOC Requirements

Pass dynamic schedules when calling the optimization:

```python
# EV connected 6PM-8AM (typical commuter pattern)
ev_availability = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1]]

# Need 80% charge by 7AM for commute
ev_minimum_soc_schedule = [[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]]

# Starting with 20% battery
ev_initial_soc = [0.2]
```

### 3. Optimize Your Charging

The extension integrates with EMHASS's linear programming optimization to:

- Schedule EV charging during optimal times (low cost, high solar production)
- Ensure minimum SOC requirements are met
- Balance multiple EVs with household energy needs
- Respect grid constraints and power limits

## 📊 Example Scenarios

### Daily Commuter

```python
# Connected: 6PM-8AM, need 80% by 7AM
ev_availability = [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1]]
min_soc_schedule = [[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,...]]
```

### Weekend Trip Planning

```python
# Connected Friday-Sunday, need 90% by Saturday 8AM
ev_availability = [[1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]]
min_soc_schedule = [[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.9,0.9,...]]
```

### Multi-EV Household

```python
# Two EVs with different patterns and requirements
ev_availability = [
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1],  # EV1: evening
    [1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]   # EV2: all day except work
]
```

## 🔍 Current Status

### ✅ Completed

- Home Assistant add-on configuration schema extension
- Complete technical design with mathematical constraints
- Working Python examples and API interface design
- Multi-EV support architecture
- SOC tracking and availability constraints
- Integration patterns with existing deferrable loads

### 🚧 Next Steps

1. **Core Implementation**: Modify EMHASS optimization engine (`src/emhass/optimization.py`)
2. **API Integration**: Add EV parameters to REST API endpoints
3. **Testing**: Validate optimization results and constraint satisfaction
4. **Documentation**: User guides and Home Assistant integration examples

## 🚀 Getting Started

1. **Try the Examples**:

   ```bash
   python3 example_ev_optimization.py
   ```

2. **Review the Design**: Read `EV_CHARGING_EXTENSION_DESIGN.md` for technical details

3. **Configure Your Setup**: Use `example_ev_config.yaml` as a template

4. **Implementation**: Follow `IMPLEMENTATION_GUIDE.md` for next steps

## 💡 Key Features

- **Backward Compatible**: Existing EMHASS functionality unchanged
- **Flexible Scheduling**: Binary availability arrays for precise control
- **SOC Management**: Dynamic minimum charge level requirements
- **Multi-EV Ready**: Supports multiple vehicles with different patterns
- **Smart Integration**: Works with solar, battery, and grid optimization
- **Home Assistant Ready**: Full add-on integration with configuration UI

## 📈 Benefits

- **Cost Savings**: Charge during low-cost periods
- **Solar Maximization**: Align charging with PV production
- **Grid Optimization**: Reduce peak demand and support grid stability
- **Convenience**: Automated charging ensures your EV is ready when needed
- **Flexibility**: Handle complex schedules and multiple vehicles

---

This extension transforms EMHASS from a home energy optimizer into a comprehensive EV-aware smart charging system, perfect for the modern electrified household.
