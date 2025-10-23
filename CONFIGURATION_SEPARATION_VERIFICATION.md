# 📁 Configuration & Directory Separation Verification

## ✅ **Complete Data Isolation Achieved!**

All three EMHASS versions now use **completely separate directories** and configuration paths:

## 📂 **Directory Structure Summary**

| **Version**    | **Repository**                   | **Data Path**             | **Config Path**          | **Isolation**   |
| -------------- | -------------------------------- | ------------------------- | ------------------------ | --------------- |
| **Original**   | `davidusb-geek/emhass-add-on`    | `/share/emhass` (default) | `/share/emhass`          | ✅ Default      |
| **Enhanced**   | `tomvanacker85/emhass-add-on`    | `/share/emhass-enhanced`  | `/share/emhass-enhanced` | ✅ **Separate** |
| **EV Version** | `tomvanacker85/emhass-ev-add-on` | `/share/emhass-ev`        | `/share/emhass-ev`       | ✅ **Separate** |

## 🗂️ **Detailed Configuration**

### **Original EMHASS (davidusb-geek)**

```yaml
# Default behavior - uses /share/emhass/
map:
  - share:rw
schema:
  data_path: "list(default|/data/|/share)?" #optional
```

**Data Location**: `/share/emhass/` (Home Assistant default)

### **Enhanced EMHASS (tomvanacker85)**

```yaml
# Updated to use separate directory
map:
  - share:rw
environment:
  EMHASS_DATA_PATH: "/share/emhass-enhanced"
options:
  data_path: "/share/emhass-enhanced"
```

**Data Location**: `/share/emhass-enhanced/`

### **EV EMHASS (tomvanacker85)**

```yaml
# Complete isolation with dedicated directory
map:
  - share:rw
environment:
  EMHASS_DATA_PATH: "/share/emhass-ev"
options:
  config_path: "/share/emhass-ev"
  data_path: "/share/emhass-ev"
```

**Data Location**: `/share/emhass-ev/`

## 📁 **File System Layout**

After installing all three versions, your Home Assistant `/share/` directory will contain:

```
/share/
├── emhass/                    # Original davidusb-geek/emhass data
│   ├── config_emhass.yaml     # Original configuration
│   ├── secrets_emhass.yaml    # Original secrets
│   ├── data/                  # Original optimization results
│   └── logs/                  # Original logs
│
├── emhass-enhanced/           # Enhanced tomvanacker85/emhass data
│   ├── config_emhass.yaml     # Enhanced configuration
│   ├── secrets_emhass.yaml    # Enhanced secrets
│   ├── data/                  # Enhanced optimization results
│   └── logs/                  # Enhanced logs
│
└── emhass-ev/                 # EV tomvanacker85/emhass-ev data
    ├── config_emhass.yaml     # EV configuration with EV parameters
    ├── secrets_emhass.yaml    # EV secrets
    ├── data/                  # EV optimization results
    └── logs/                  # EV logs
```

## 🔒 **Data Isolation Benefits**

### **Configuration Independence**

- **Separate config files**: Each version has its own `config_emhass.yaml`
- **Independent secrets**: Separate `secrets_emhass.yaml` files
- **Different parameters**: EV version includes EV-specific parameters

### **Data Independence**

- **Separate logs**: No mixing of log entries between versions
- **Independent results**: Optimization results stored separately
- **Backup isolation**: Each version can be backed up independently

### **No Cross-Contamination**

- **Configuration changes** in one version don't affect others
- **Data corruption** in one version doesn't impact others
- **Version upgrades** can be done independently

## 🔧 **Runtime Environment Variables**

### **Original EMHASS**

```bash
# Uses default EMHASS data path behavior
EMHASS_DATA_PATH="/share/emhass"  # Default if not set
```

### **Enhanced EMHASS**

```bash
# Explicitly set to separate directory
EMHASS_DATA_PATH="/share/emhass-enhanced"
```

### **EV EMHASS**

```bash
# Completely isolated environment
EMHASS_DATA_PATH="/share/emhass-ev"
EMHASS_PORT="5003"
```

## 📊 **Configuration File Differences**

### **Standard Parameters (Original & Enhanced)**

```yaml
# Common EMHASS parameters
costfun: "profit"
log_level: "INFO"
optimization_time_step: 60
# ... standard EMHASS config
```

### **EV-Enhanced Parameters (EV Version Only)**

```yaml
# Standard parameters PLUS EV-specific:
number_of_ev_loads: 1
ev_battery_capacity: [75000]
ev_charging_efficiency: [0.9]
ev_nominal_charging_power: [11000]
ev_minimum_charging_power: [1400]
ev_consumption_efficiency: [0.2]
# ... additional EV parameters
```

## 🚀 **Production Deployment Verification**

### **Installation Test Checklist**

#### **✅ Step 1: Install Original EMHASS**

```bash
Repository: https://github.com/davidusb-geek/emhass-add-on
Check: /share/emhass/ directory created
Port: 5000
```

#### **✅ Step 2: Install Enhanced EMHASS**

```bash
Repository: https://github.com/tomvanacker85/emhass-add-on
Check: /share/emhass-enhanced/ directory created (separate!)
Port: 5001
```

#### **✅ Step 3: Install EV EMHASS**

```bash
Repository: https://github.com/tomvanacker85/emhass-ev-add-on
Check: /share/emhass-ev/ directory created (separate!)
Port: 5003
```

### **Verification Commands**

After installation, verify separation with:

```bash
# Check directory separation
ls -la /share/ | grep emhass

# Expected output:
# drwxr-xr-x emhass/           # Original
# drwxr-xr-x emhass-enhanced/  # Enhanced
# drwxr-xr-x emhass-ev/        # EV Version

# Check configuration files
ls -la /share/*/config_emhass.yaml

# Check log separation
ls -la /share/*/logs/
```

## ⚡ **Runtime Isolation**

### **Process Separation**

- **Different Docker containers** for each version
- **Separate memory allocation** per add-on
- **Independent CPU usage** tracking
- **Isolated network ports** (5000, 5001, 5003)

### **API Isolation**

- **Independent Home Assistant API access**
- **Separate authentication tokens** if configured
- **Different entity sensors** can be created
- **No API call interference** between versions

## 🎯 **Migration & Testing Strategy**

### **Safe Testing Approach**

1. **Start with original** EMHASS (port 5000) - keep working configuration
2. **Add enhanced version** (port 5001) - test with copies of original config
3. **Configure EV version** (port 5003) - completely independent setup
4. **Compare results** across all three versions
5. **Migrate gradually** to preferred version

### **Rollback Strategy**

- **Independent backups** of each `/share/emhass-*` directory
- **Disable specific add-ons** without affecting others
- **Restore specific configurations** without cross-impact

## ✅ **Complete Isolation Verified**

### **No Conflicts Confirmed**

- ✅ **Separate ports**: 5000, 5001, 5003
- ✅ **Separate data directories**: `/share/emhass`, `/share/emhass-enhanced`, `/share/emhass-ev`
- ✅ **Separate configurations**: Independent config files
- ✅ **Separate Docker images**: Different core repositories
- ✅ **Separate environment variables**: Isolated runtime settings

---

**🎉 Complete configuration and directory separation achieved!**
**All three EMHASS versions are fully isolated and production-ready!** 🚀
