# 🚀 EMHASS EV Extension - Deployment Guide

## ✅ Yes, You Can Install This in Home Assistant!

Your EMHASS EV extension is ready for production deployment. Here's everything you need to know:

## 📦 Repository Information

### **Main Repository**: `https://github.com/tomvanacker85/emhass-add-on`

- **Add-on Location**: `emhass-ev/` folder
- **Status**: Production ready
- **Custom Core**: Yes, uses your enhanced EMHASS fork with EV extensions

### **EMHASS Core Fork**: `https://github.com/tomvanacker85/emhass`

- **Branch**: `feature/ev-charging-extension`
- **Enhanced**: Complete EV charging optimization capabilities

## 🏠 Installation in Home Assistant

### Method 1: Direct Installation (Recommended)

1. **Add Custom Repository**:

   ```
   Go to: Settings > Add-ons > Add-on Store > ⋮ (menu) > Repositories
   Add: https://github.com/tomvanacker85/emhass-add-on
   ```

2. **Install Add-on**:
   - Refresh the add-on store
   - Look for "EMHASS EV Extension"
   - Click Install
   - Configure and Start

### Method 2: Manual Installation

1. **Copy Files**:

   ```bash
   # Copy the emhass-ev folder to your Home Assistant
   scp -r /workspaces/emhass-add-on/emhass-ev/ homeassistant:/addons/local/
   ```

2. **Restart Home Assistant** and install from Local add-ons

## 🔄 Parallel Usage with Original EMHASS

### **✅ YES - Full Parallel Support!**

Both add-ons can run simultaneously without conflicts:

| **Feature**       | **Original EMHASS**         | **EMHASS EV**               |
| ----------------- | --------------------------- | --------------------------- |
| **Port**          | 5002                        | 5001                        |
| **Data Path**     | `/share/emhass`             | `/share/emhass-ev`          |
| **Web UI**        | `http://homeassistant:5002` | `http://homeassistant:5001` |
| **API Base**      | `/api/emhass/`              | `/api/emhass-ev/`           |
| **Configuration** | Separate                    | Separate                    |

### **Installation Order**:

1. Keep your existing EMHASS add-on running
2. Install EMHASS EV extension alongside it
3. Configure EV parameters independently
4. Use both for different optimization scenarios

## 💾 Data Storage Locations

### **EMHASS EV Data Path**: `/share/emhass-ev/`

```
/share/emhass-ev/
├── config_emhass.yaml          # EV-specific configuration
├── secrets_emhass.yaml         # EV add-on secrets
├── data/
│   ├── opt_res_latest.csv      # EV optimization results
│   ├── forecast_method_*.csv   # EV forecasting data
│   └── ev_charging_*.csv       # EV charging schedules
├── logs/
│   └── emhass-ev.log          # EV extension logs
└── backups/                   # Configuration backups
```

### **Isolation Benefits**:

- **No Conflicts**: EV and standard EMHASS use separate data
- **Independent**: Configure each add-on separately
- **Backup Safety**: Each has its own backup/restore
- **Migration**: Easy to move configurations

## ⚙️ Custom EMHASS Core Features

### **Enhanced Capabilities**:

Your EV extension uses a **custom EMHASS core** with:

```python
# EV-Specific Parameters (not in original EMHASS)
number_of_ev_loads: 1                    # Multiple EV support
ev_battery_capacity: [75000]             # Battery capacity (Wh)
ev_charging_efficiency: [0.9]            # Charging efficiency
ev_nominal_charging_power: [11000]       # Max charging power (W)
ev_minimum_charging_power: [1400]        # Min charging power (W)
ev_consumption_efficiency: [0.2]         # Consumption (kWh/km)

# EV Runtime Parameters
ev_soc_current: [50000]                  # Current SOC (Wh)
ev_soc_target: [75000]                   # Target SOC (Wh)
ev_availability: [1,1,1,0,0,1,...]       # Availability windows
ev_distance_forecast: [0,25,50,0,...]    # Distance forecast (km)
```

## 🎯 Configuration Examples

### **Basic EV Setup**:

```yaml
# In Home Assistant Add-on Configuration
number_of_ev_loads: 1
ev_battery_capacity:
  - 75000 # 75 kWh battery
ev_charging_efficiency:
  - 0.9 # 90% efficiency
ev_nominal_charging_power:
  - 11000 # 11kW charger (3-phase 16A)
ev_consumption_efficiency:
  - 0.2 # 0.2 kWh/km consumption
```

### **Multi-EV Setup**:

```yaml
number_of_ev_loads: 2
ev_battery_capacity:
  - 75000 # EV 1: 75 kWh
  - 50000 # EV 2: 50 kWh
ev_nominal_charging_power:
  - 11000 # EV 1: 11kW charger
  - 7400 # EV 2: 7.4kW charger
```

## 🔧 Verification Steps

### **Test Installation**:

```bash
# Run the verification script
cd /workspaces/emhass-add-on
./test_emhass_ev_final.sh
```

### **Verify Parallel Operation**:

1. **Original EMHASS**: `http://homeassistant:5002`
2. **EMHASS EV**: `http://homeassistant:5001`
3. **Check Data**: Both `/share/emhass` and `/share/emhass-ev` exist

## 🚨 Important Notes

### **Docker Image Source**:

- **Builds from**: `tomvanacker85/emhass:feature/ev-charging-extension`
- **Not using**: Original EMHASS docker image
- **Custom features**: EV optimization, km-based input, availability windows

### **Updates**:

- **EV Extension**: Updates from your repository
- **Core EMHASS**: Updates from your fork with EV features
- **Independent**: Original EMHASS updates don't affect EV extension

## 🎉 Ready for Production!

Your EMHASS EV extension is **production-ready** with:

✅ **Complete Home Assistant integration**
✅ **Parallel operation with original EMHASS**
✅ **Isolated data storage**
✅ **Custom EV optimization core**
✅ **Full configuration UI**
✅ **API compatibility**

**Next Step**: Add your repository to Home Assistant and install the add-on!

---

**Repository**: https://github.com/tomvanacker85/emhass-add-on
**Add-on**: `emhass-ev/`
**Web UI**: Port 5001
**Data**: `/share/emhass-ev/`
