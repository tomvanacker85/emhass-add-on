# 🎯 EMHASS Four-Repository Structure - Complete Overview

## 📋 Repository Architecture

Your requested four-repository structure has been successfully created:

### **1. tomvanacker85/emhass**

- **Description**: Copy of original `davidusb-geek/emhass` with PR 601 integrated
- **Location**: `/home/vscode/repo-structure/emhass/`
- **Purpose**: Enhanced EMHASS core with DST fixes
- **Key Features**:
  - ✅ Original EMHASS functionality
  - ✅ PR 601 integrated (DST timezone fixes)
  - ✅ Base for all other repositories

### **2. tomvanacker85/emhass-add-on**

- **Description**: Copy of original `davidusb-geek/emhass-add-on`, references `tomvanacker85/emhass`
- **Location**: `/home/vscode/repo-structure/emhass-add-on/`
- **Purpose**: Standard EMHASS Home Assistant add-on with your enhanced core
- **Key Changes**:
  - ✅ References `ghcr.io/tomvanacker85/emhass` instead of original
  - ✅ Uses your EMHASS core with DST fixes
  - ✅ Maintains standard EMHASS functionality

### **3. tomvanacker85/emhass-ev**

- **Description**: Copy of `tomvanacker85/emhass` with EV functionality added
- **Location**: `/home/vscode/repo-structure/emhass-ev/`
- **Purpose**: EV-enhanced EMHASS core with charging optimization
- **Key Features**:
  - ✅ All features from `tomvanacker85/emhass` (including PR 601)
  - ✅ EV charging parameters in config_defaults.json
  - ✅ EV parameter definitions for UI integration
  - ✅ Ready for EV optimization algorithms

### **4. tomvanacker85/emhass-ev-add-on**

- **Description**: Copy of `tomvanacker85/emhass-add-on` with EV functionality, references `tomvanacker85/emhass-ev`
- **Location**: `/home/vscode/repo-structure/emhass-ev-add-on/`
- **Purpose**: EV-specific Home Assistant add-on
- **Key Features**:
  - ✅ References `ghcr.io/tomvanacker85/emhass-ev`
  - ✅ Complete EV add-on configuration
  - ✅ Port 5003 (separate from standard EMHASS)
  - ✅ EV parameter schema for Home Assistant UI

## 🔄 Repository Relationships

```
davidusb-geek/emhass (original)
├── + PR 601 (DST fixes)
└── tomvanacker85/emhass
    ├── Used by → tomvanacker85/emhass-add-on
    ├── + EV functionality
    └── tomvanacker85/emhass-ev
        └── Used by → tomvanacker85/emhass-ev-add-on

davidusb-geek/emhass-add-on (original)
├── Updated references
└── tomvanacker85/emhass-add-on (uses tomvanacker85/emhass)
    ├── + EV add-on configuration
    └── tomvanacker85/emhass-ev-add-on (uses tomvanacker85/emhass-ev)
```

## 📦 Docker Image References

| **Repository**                   | **Docker Image**                  | **Purpose**                         |
| -------------------------------- | --------------------------------- | ----------------------------------- |
| `tomvanacker85/emhass`           | `ghcr.io/tomvanacker85/emhass`    | Standard EMHASS with DST fixes      |
| `tomvanacker85/emhass-add-on`    | `ghcr.io/tomvanacker85/emhass`    | Standard add-on using enhanced core |
| `tomvanacker85/emhass-ev`        | `ghcr.io/tomvanacker85/emhass-ev` | EV-enhanced EMHASS core             |
| `tomvanacker85/emhass-ev-add-on` | `ghcr.io/tomvanacker85/emhass-ev` | EV add-on using EV core             |

## 🚀 Deployment Instructions

### **Create GitHub Repositories**

```bash
# 1. Push tomvanacker85/emhass
cd /home/vscode/repo-structure/emhass
git remote add origin https://github.com/tomvanacker85/emhass.git
git push -u origin main

# 2. Push tomvanacker85/emhass-add-on
cd /home/vscode/repo-structure/emhass-add-on
git remote add origin https://github.com/tomvanacker85/emhass-add-on.git
git push -u origin main

# 3. Push tomvanacker85/emhass-ev
cd /home/vscode/repo-structure/emhass-ev
git remote add origin https://github.com/tomvanacker85/emhass-ev.git
git push -u origin main

# 4. Push tomvanacker85/emhass-ev-add-on
cd /home/vscode/repo-structure/emhass-ev-add-on
git remote add origin https://github.com/tomvanacker85/emhass-ev-add-on.git
git push -u origin main
```

### **Home Assistant Installation**

#### **Standard EMHASS (Enhanced)**

```
Add Repository: https://github.com/tomvanacker85/emhass-add-on
Install: "EMHASS" add-on
Uses: Enhanced EMHASS core with DST fixes
Port: 5002
```

#### **EV EMHASS (EV Optimization)**

```
Add Repository: https://github.com/tomvanacker85/emhass-ev-add-on
Install: "EMHASS EV Charging Optimizer" add-on
Uses: EV-enhanced EMHASS core
Port: 5003
```

## 🎯 Key Benefits

### **Clean Separation**

- **Clear purpose** for each repository
- **No confusion** between standard and EV versions
- **Independent evolution** of each component

### **Proper Dependencies**

- **Add-ons reference correct core**: Standard → standard, EV → EV
- **Inheritance maintained**: EV versions build on standard versions
- **Original compatibility**: Can still use original add-ons with original core

### **Parallel Usage**

- **Both add-ons** can run simultaneously
- **Different ports** (5002 vs 5003)
- **Separate data paths** (/share/emhass vs /share/emhass-ev)

## 📋 Repository Status

### **Ready for GitHub Creation**

All four repositories are:

- ✅ **Committed** with proper history
- ✅ **Configured** with correct references
- ✅ **Tested** configurations
- ✅ **Ready to push** to GitHub

### **EV Features Included**

- ✅ **number_of_ev_loads**: Multiple EV support
- ✅ **ev_battery_capacity**: Battery capacity (Wh)
- ✅ **ev_charging_efficiency**: Charging efficiency
- ✅ **ev_nominal_charging_power**: Max charging power (W)
- ✅ **ev_minimum_charging_power**: Min charging power (W)
- ✅ **ev_consumption_efficiency**: Consumption (kWh/km)

## 🎉 Next Steps

1. **Create the four GitHub repositories** using the push commands above
2. **Set up Docker image builds** for the two core repositories
3. **Install add-ons** in Home Assistant using the respective repository URLs
4. **Configure EV parameters** in the EV add-on
5. **Enjoy both standard and EV optimization** running in parallel!

---

**Perfect four-repository structure achieved!** 🚗⚡
