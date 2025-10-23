# 🚗 EMHASS EV Extension - Home Assistant Installation Guide

## ⚡ **Quick Installation**

### Step 1: Add Repository to Home Assistant

1. Open Home Assistant
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click the **⋮** (three dots) in the top right corner
4. Select **"Repositories"**
5. Add this URL:
   ```
   https://github.com/tomvanacker85/emhass-add-on
   ```
6. Click **"ADD"**

### Step 2: Install EMHASS EV Extension

1. Refresh the add-on store
2. Find **"EMHASS EV Extension"** in the **Local Add-ons** section
3. Click on it
4. Click **"INSTALL"** (this may take a few minutes)

### Step 3: Configure Your EV

1. Click **"Configuration"** tab
2. Configure your EV parameters:

```yaml
# Example configuration for a Tesla Model 3
number_of_ev_loads: 1
ev_battery_capacity: "[75000]" # 75 kWh battery (in Wh)
ev_charging_efficiency: "[0.9]" # 90% charging efficiency
ev_nominal_charging_power: "[11000]" # 11 kW home charger
ev_minimum_charging_power: "[1380]" # 1.38 kW minimum power
ev_consumption_efficiency: "[18.5]" # 18.5 kWh/100km consumption
```

### Step 4: Start the Add-on

1. Click **"Info"** tab
2. Toggle **"Start on boot"** ON
3. Click **"START"**
4. Wait for it to show **"RUNNING"**

### Step 5: Access the Interface

- **Web Interface**: `http://homeassistant.local:5003`
- **Configuration Page**: `http://homeassistant.local:5003/configuration`

## 🔧 **EV Configuration Parameters**

| Parameter                   | Description                  | Example              |
| --------------------------- | ---------------------------- | -------------------- |
| `number_of_ev_loads`        | Number of EVs (0 to disable) | `1`                  |
| `ev_battery_capacity`       | Battery size in Wh           | `"[75000]"` (75 kWh) |
| `ev_charging_efficiency`    | Charging efficiency (0-1)    | `"[0.9]"` (90%)      |
| `ev_nominal_charging_power` | Max charging power in W      | `"[11000]"` (11 kW)  |
| `ev_minimum_charging_power` | Min charging power in W      | `"[1380]"` (1.38 kW) |
| `ev_consumption_efficiency` | Energy use in kWh/100km      | `"[18.5]"`           |

## 🚗 **Multi-EV Configuration**

For multiple EVs, use arrays:

```yaml
number_of_ev_loads: 2
ev_battery_capacity: "[75000, 60000]" # Tesla + Nissan Leaf
ev_charging_efficiency: "[0.9, 0.88]" # Different efficiencies
ev_nominal_charging_power: "[11000, 7400]" # 11kW + 7.4kW chargers
ev_minimum_charging_power: "[1380, 1380]" # Same minimum
ev_consumption_efficiency: "[18.5, 16.2]" # Different consumption
```

## 📊 **Usage Examples**

### Daily Commuter

- Connect EV: 6 PM - 8 AM
- Need 80% charge by 7 AM
- Optimize for lowest electricity rates

### Weekend Trip

- Need 90% charge by Friday evening
- Flexible timing over multiple days
- Balance with solar production

## 🔍 **Verification**

After installation, you should see:

1. **Add-on Status**: Running (green)
2. **Web Interface**: Accessible at port 5003
3. **Configuration Page**: Shows EV section with toggle switch
4. **Logs**: No errors in add-on logs

## 📞 **Support**

- **Issues**: [GitHub Issues](https://github.com/tomvanacker85/emhass-add-on/issues)
- **Original EMHASS**: [davidusb-geek/emhass](https://github.com/davidusb-geek/emhass)
- **Community**: [Home Assistant Community](https://community.home-assistant.io/)

## 🚀 **What's Next?**

1. Configure your EV parameters
2. Set up Home Assistant sensors for your EV
3. Create automations for EV charging
4. Monitor optimization results
5. Fine-tune parameters for your usage patterns

Happy EV optimization! ⚡🏠
