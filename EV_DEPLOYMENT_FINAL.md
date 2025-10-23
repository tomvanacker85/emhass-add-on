# 🎉 EMHASS EV Setup Complete - Deployment Instructions

## ✅ What We've Created

You now have a **completely separate EV add-on repository** that works alongside the original EMHASS:

### 📁 Repository Structure

```
Original EMHASS (unchanged):
├── Repository: https://github.com/davidusb-geek/emhass-add-on
├── Add-on: "EMHASS"
├── Port: 5002
└── Data: /share/emhass

NEW EV Optimizer (your enhanced version):
├── Repository: https://github.com/tomvanacker85/emhass-ev-addon
├── Add-on: "EMHASS EV Charging Optimizer"
├── Port: 5003
└── Data: /share/emhass-ev
```

## 🚀 Next Steps to Deploy

### 1. Create GitHub Repository

```bash
# Push your EV addon to GitHub
cd /home/vscode/emhass-ev-addon
git remote add origin https://github.com/tomvanacker85/emhass-ev-addon.git
git push -u origin main
```

### 2. Install in Home Assistant

#### Option A: Via Repository URL

```
Settings → Add-ons → Add-on Store → ⋮ → Repositories
Add: https://github.com/tomvanacker85/emhass-ev-addon
```

#### Option B: Manual Installation

```bash
# Copy to Home Assistant
scp -r /home/vscode/emhass-ev-addon/emhass-ev/ homeassistant:/addons/local/
```

### 3. Configure Both Add-ons

#### Original EMHASS (keep existing)

- **Repository**: `davidusb-geek/emhass-add-on`
- **Port**: 5002
- **Use for**: Standard home energy optimization

#### EV Optimizer (new)

- **Repository**: `tomvanacker85/emhass-ev-addon`
- **Port**: 5003
- **Use for**: Electric vehicle charging optimization

## ⚙️ Configuration Example

### EV Optimizer Settings

```yaml
# In Home Assistant Add-on Configuration
number_of_ev_loads: 1
ev_battery_capacity:
  - 75000 # 75 kWh battery
ev_charging_efficiency:
  - 0.9 # 90% efficiency
ev_nominal_charging_power:
  - 11000 # 11kW charger
ev_consumption_efficiency:
  - 0.2 # 0.2 kWh/km
```

## 🎯 Benefits of This Approach

### ✅ Complete Separation

- **No conflicts** with original EMHASS installation
- **Independent updates** - original EMHASS updates don't affect EV optimizer
- **Separate data** - `/share/emhass` vs `/share/emhass-ev`
- **Different purposes** - use each for its strengths

### ✅ Clear Distinction

- **Different repository names**: `emhass-add-on` vs `emhass-ev-addon`
- **Different add-on names**: "EMHASS" vs "EMHASS EV Charging Optimizer"
- **Different slugs**: `emhass` vs `emhass-ev-optimizer`
- **Different ports**: 5002 vs 5003

### ✅ Enhanced EV Features

- **Availability windows** (0/1 arrays)
- **SOC management** (current/target battery levels)
- **Distance-based input** (km forecasting)
- **Multi-EV support** (multiple vehicles)
- **Custom optimization** (EV-specific algorithms)

## 📊 Usage Scenarios

### Scenario 1: Standard Home Only

- Use **original EMHASS** from `davidusb-geek/emhass-add-on`
- Optimize solar, battery, house loads

### Scenario 2: EV Owner Only

- Use **EV optimizer** from `tomvanacker85/emhass-ev-addon`
- Optimize EV charging with availability and SOC constraints

### Scenario 3: Both (Recommended)

- **Original EMHASS**: Optimize house energy (solar, battery, loads)
- **EV Optimizer**: Optimize EV charging independently
- **Best results**: Separate optimization for different needs

## 🔧 File Locations

### Your Development Environment

```
/home/vscode/emhass-ev-addon/          # New EV-specific repository
├── emhass-ev/                         # The actual add-on
├── README.md                          # Repository documentation
├── INSTALLATION.md                    # Installation guide
└── repository.yaml                    # Repository config
```

### Home Assistant (after installation)

```
/addons/local/emhass-ev/              # If manually installed
/share/emhass-ev/                     # EV add-on data directory
/share/emhass/                        # Original EMHASS data (unchanged)
```

## 🎉 Ready for Production!

Your EV optimizer is now:

✅ **Completely separate** from original EMHASS
✅ **Production ready** with full EV optimization
✅ **Easy to install** via custom repository
✅ **Conflict-free** parallel operation
✅ **Feature-complete** with all requested EV capabilities

**Next step**: Create the GitHub repository and start optimizing your EV charging! 🚗⚡
