# EMHASS EV Extension Add-on

![EMHASS EV Logo](logo.png)

## About

This add-on provides **EMHASS (Energy Management for Home Assistant) with EV Charging Extension** - an advanced energy management system that optimizes your home energy usage including smart EV charging.

## Key Features

### 🏠 **Home Energy Management**

- Solar PV optimization
- Home battery management
- Grid interaction optimization
- Deferrable load scheduling

### 🚗 **EV Charging Optimization** (NEW!)

- **Smart Scheduling**: Charge during optimal times (low cost, high solar)
- **SOC Management**: Ensure minimum charge levels when needed
- **Multi-EV Support**: Handle multiple vehicles with different patterns
- **Availability Control**: Use 0/1 arrays to define when EVs are connected
- **Dynamic Requirements**: Set different SOC targets throughout the day

## Configuration

### Basic Setup

1. Install the add-on
2. Configure your EV parameters
3. Start the add-on
4. Access the web interface at port 5001

### EV Configuration Example

```yaml
number_of_ev_loads: 1
ev_battery_capacity: "[60000]" # 60 kWh = 60,000 Wh
ev_charging_efficiency: "[0.9]" # 90% charging efficiency
ev_nominal_charging_power: "[7400]" # 7.4 kW charger
ev_minimum_charging_power: "[1380]" # 1.38 kW minimum power
```

### Runtime Usage

Pass EV schedules via API calls:

```json
{
  "ev_availability": [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1]
  ],
  "ev_minimum_soc_schedule": [
    [
      0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8,
      0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8
    ]
  ],
  "ev_initial_soc": [0.2]
}
```

## API Endpoints

- **Web Interface**: `http://your-ha:5001`
- **Day-ahead Optimization**: `POST /action/dayahead-optim`
- **Perfect Forecast**: `POST /action/perfect-optim`

## Differences from Standard EMHASS

This EV extension adds:

- 5 new configuration parameters for EV setup
- 3 new runtime parameters for dynamic EV control
- EV power variables in optimization (P_EV0, P_EV1, etc.)
- EV SOC tracking (SOC_EV0, SOC_EV1, etc.)
- Advanced constraints for availability and minimum SOC

## Use Cases

### Daily Commuter

- Connect EV 6PM-8AM
- Need 80% charge by 7AM
- Optimize for lowest electricity rates

### Multi-EV Household

- Different vehicles, different patterns
- Coordinate charging to avoid peak demand
- Balance with home battery and solar

### Weekend Trip Planning

- Charge to 90% for long trips
- Flexible timing over multiple days
- Smart scheduling around other loads

## Support

- **Original EMHASS**: [davidusb-geek/emhass](https://github.com/davidusb-geek/emhass)
- **EV Extension**: [tomvanacker85/emhass](https://github.com/tomvanacker85/emhass)
- **Add-on Repository**: [tomvanacker85/emhass-add-on](https://github.com/tomvanacker85/emhass-add-on)

## Installation

1. Add this repository to your Home Assistant add-on store
2. Find "EMHASS EV Extension" in Local Add-ons
3. Install and configure
4. Start the add-on

**Note**: This runs on port 5001 to avoid conflicts with standard EMHASS (port 5000).
