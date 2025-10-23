# 🚗⚡ EMHASS EV Add-on Installation Guide

**Complete Electric Vehicle charging optimization for Home Assistant**

## 📋 Prerequisites

- Home Assistant OS, Supervised, or Container
- Home Assistant Add-on Store access
- EV integration or sensors for battery SOC and charging status
- Energy price sensors (optional but recommended)

## 🚀 Installation Steps

### Step 1: Add the Repository

1. Open Home Assistant
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click the **⋮** menu (three dots) in the top right
4. Select **Repositories**
5. Add this repository URL:
   ```
   https://github.com/tomvanacker85/emhass-add-on
   ```
6. Click **Add**

### Step 2: Install EMHASS EV Add-on

1. Refresh the Add-on Store page
2. Find **"EMHASS EV"** in the list
3. Click on it and select **Install**
4. Wait for installation to complete

### Step 3: Configure the Add-on

1. Go to the **Configuration** tab
2. Configure basic settings:
   ```yaml
   # Location Settings
   lat: 51.1766
   lon: 3.8661
   time_zone: Europe/Brussels
   
   # EV Configuration
   number_of_ev_loads: 1
   ev_battery_capacity: [77000]  # Wh
   ev_nominal_charging_power: [4600]  # W
   ev_charging_efficiency: [0.9]
   ev_consumption_efficiency: [0.15]  # kWh/km
   
   # Energy Settings
   costfun: profit
   optimization_time_step: 60
   ```

### Step 4: Start the Add-on

1. Go to the **Info** tab
2. Click **Start**
3. Enable **Start on boot** (recommended)
4. Check the **Log** tab for any errors

## 🏠 Home Assistant Configuration

### Add Required Helpers

Add this to your `configuration.yaml` or include the file `ha_ev_configuration.yaml`:

```yaml
# EV Configuration Helpers
input_number:
  ev_battery_capacity:
    name: "EV Battery Capacity"
    min: 30000
    max: 200000
    step: 1000
    unit_of_measurement: "Wh"
    initial: 77000

  ev_nominal_charging_power:
    name: "EV Charging Power"
    min: 1380
    max: 22000
    step: 100
    unit_of_measurement: "W"
    initial: 4600

  ev_daily_commute_km:
    name: "Daily Commute"
    min: 0
    max: 200
    step: 5
    unit_of_measurement: "km"
    initial: 50

input_datetime:
  ev_work_departure:
    name: "Work Departure"
    has_time: true
    initial: "07:30"

  ev_work_return:
    name: "Work Return"
    has_time: true
    initial: "18:00"

# Shell Commands for EMHASS EV
shell_command:
  emhass_ev_naive_mpc: 'curl -i -H "Content-Type: application/json" -X POST -d "{{ payload }}" http://localhost:5000/action/naive-mpc-optim'
  emhass_ev_publish_data: 'curl -i -H "Content-Type: application/json" -X POST -d "{}" http://localhost:5000/action/publish-data'
```

### Add EV Sensors

Configure sensors for your specific EV integration:

#### Tesla Integration Example:
```yaml
sensor:
  - platform: template
    sensors:
      ev_battery_soc:
        value_template: "{{ states('sensor.tesla_battery_level')|float / 100 }}"

binary_sensor:
  - platform: template
    sensors:
      ev_connected:
        value_template: "{{ is_state('binary_sensor.tesla_charger_connected', 'on') }}"
```

#### BMW/MINI Integration Example:
```yaml
sensor:
  - platform: template
    sensors:
      ev_battery_soc:
        value_template: "{{ states('sensor.bmw_remaining_battery_percent')|float / 100 }}"

binary_sensor:
  - platform: template
    sensors:
      ev_connected:
        value_template: "{{ is_state('binary_sensor.bmw_charging_status', 'on') }}"
```

#### Generic/Manual Configuration:
```yaml
input_number:
  ev_manual_soc:
    name: "EV Battery Level"
    min: 0
    max: 1
    step: 0.01
    initial: 0.5

input_boolean:
  ev_manual_connected:
    name: "EV Connected"
    initial: false

sensor:
  - platform: template
    sensors:
      ev_battery_soc:
        value_template: "{{ states('input_number.ev_manual_soc')|float }}"

binary_sensor:
  - platform: template
    sensors:
      ev_connected:
        value_template: "{{ is_state('input_boolean.ev_manual_connected', 'on') }}"
```

### Add the Automation

Copy the content from `emhass_ev_automation.yaml` to your Home Assistant automations:

1. Go to **Settings** → **Automations & Scenes**
2. Click **Create Automation**
3. Switch to **YAML mode**
4. Paste the automation content
5. Save as "EMHASS EV MPC Optimization"

## 🔧 Energy Price Integration

### Nordpool/ENTSO-E Integration:
```yaml
# Add to configuration.yaml
sensor:
  - platform: nordpool
    region: "BE"  # Your region
    currency: "EUR"

# Use in automation variables:
load_cost_forecast: >
  {{ state_attr('sensor.nordpool_kwh_be_eur_3_10_021', 'today') + 
     state_attr('sensor.nordpool_kwh_be_eur_3_10_021', 'tomorrow') }}
```

### Fixed Tariff Example:
```yaml
# Simple fixed pricing
load_cost_forecast: >
  {% set peak_price = 0.2907 %}
  {% set offpeak_price = 0.1419 %}
  {% set current_hour = now().hour %}
  {% set prices = [] %}
  {% for i in range(48) %}
    {% set hour = (current_hour + i) % 24 %}
    {% if hour >= 7 and hour <= 22 %}
      {% set _ = prices.append(peak_price) %}
    {% else %}
      {% set _ = prices.append(offpeak_price) %}
    {% endif %}
  {% endfor %}
  {{ prices }}
```

## 📊 Dashboard Configuration

### Add EV Control Card:
```yaml
type: entities
title: EV Charging Control
entities:
  - entity: input_number.ev_battery_capacity
  - entity: input_number.ev_nominal_charging_power
  - entity: input_number.ev_daily_commute_km
  - entity: input_datetime.ev_work_departure
  - entity: input_datetime.ev_work_return
  - entity: sensor.ev_battery_soc
  - entity: binary_sensor.ev_connected
  - entity: automation.emhass_ev_mpc_optimization
```

### Add Charging Schedule Graph:
```yaml
type: history-graph
title: EV Charging Schedule
entities:
  - entity: sensor.p_ev0
    name: "EV Charging Power (W)"
  - entity: sensor.soc_ev0
    name: "EV Battery SOC"
hours_to_show: 48
refresh_interval: 300
```

### Add Energy Cost Monitoring:
```yaml
type: energy-usage-graph
title: EV Charging Costs
entities:
  - entity: sensor.total_cost_fun_value
  - entity: sensor.unit_load_cost
  - entity: sensor.unit_prod_price
```

## 🔍 Verification

### Check Add-on Status:
1. Go to **Settings** → **Add-ons** → **EMHASS EV**
2. Check the **Log** tab for any errors
3. Verify the add-on is running

### Test Optimization:
1. Trigger the automation manually
2. Check **Developer Tools** → **States** for new sensors:
   - `sensor.p_ev0` (EV charging power schedule)
   - `sensor.soc_ev0` (EV SOC forecast)
   - `sensor.total_cost_fun_value` (optimization cost)

### Debug Issues:
```bash
# Check add-on logs
ha addon logs emhass-ev

# Test API endpoint
curl -X GET http://localhost:5000/get-conf

# Test optimization
curl -X POST http://localhost:5000/action/naive-mpc-optim \
  -H "Content-Type: application/json" \
  -d '{"prediction_horizon": 24}'
```

## ⚙️ Advanced Configuration

### Multiple EVs:
```yaml
# Add-on configuration
number_of_ev_loads: 2
ev_battery_capacity: [77000, 60000]
ev_nominal_charging_power: [4600, 11000]

# Automation variables
ev_availability: >
  {{ [ev1_schedule, ev2_schedule] }}
```

### Smart Charging Rules:
```yaml
# Only charge during off-peak hours
ev_availability: >
  {% set current_hour = now().hour %}
  {% set schedule = [] %}
  {% for i in range(48) %}
    {% set hour = (current_hour + i) % 24 %}
    {% if hour >= 23 or hour <= 6 %}
      {% set _ = schedule.append(1) %}
    {% else %}
      {% set _ = schedule.append(0) %}
    {% endif %}
  {% endfor %}
  {{ [schedule] }}
```

### Solar-First Charging:
```yaml
# Prioritize solar charging
variables:
  alpha: 0.1  # Low cost weight
  beta: 0.9   # High solar utilization weight
```

## 🆘 Troubleshooting

### Common Issues:

**Add-on won't start:**
- Check Home Assistant logs
- Verify configuration syntax
- Ensure port 5000 is available

**No EV optimization:**
- Verify `set_use_ev: true` in configuration
- Check EV sensor states
- Validate automation payload

**Sensors not updating:**
- Check automation triggers
- Verify shell commands work
- Test API endpoints manually

**Optimization fails:**
- Check prediction horizon (max 48)
- Verify all required sensors exist
- Check EV parameter arrays match number_of_ev_loads

### Support:
- GitHub Issues: [tomvanacker85/emhass-add-on](https://github.com/tomvanacker85/emhass-add-on/issues)
- Home Assistant Community: [EMHASS Discussion](https://community.home-assistant.io/)

## 🎯 Next Steps

1. **Monitor Performance:** Track charging costs and solar utilization
2. **Optimize Schedule:** Adjust work times and driving patterns
3. **Add Automations:** Create rules for holidays, weekends, etc.
4. **Integrate Weather:** Add weather-based PV forecasting
5. **Scale Up:** Add multiple EVs or battery storage optimization

## 📝 Configuration Examples

Complete working examples available in:
- `emhass_ev_automation.yaml` - Full automation
- `ha_ev_configuration.yaml` - Home Assistant helpers
- `test-share/emhass-ev/config.json` - Add-on configuration

🎉 **Congratulations!** Your EMHASS EV system is now ready for intelligent charging optimization!