# 🚢 Port Configuration Verification - Three EMHASS Versions

## ✅ **Port Conflicts Resolved!**

All three EMHASS versions now use **unique ports** and can run simultaneously on your production Home Assistant:

## 📊 **Port Assignment Summary**

| **Repository**                     | **Add-on Name**                | **Port** | **Web UI**                  | **Status**              |
| ---------------------------------- | ------------------------------ | -------- | --------------------------- | ----------------------- |
| **davidusb-geek/emhass-add-on**    | "EMHASS"                       | **5000** | `http://homeassistant:5000` | ✅ Original             |
| **tomvanacker85/emhass-add-on**    | "EMHASS"                       | **5001** | `http://homeassistant:5001` | ✅ Enhanced with PR 601 |
| **tomvanacker85/emhass-ev-add-on** | "EMHASS EV Charging Optimizer" | **5003** | `http://homeassistant:5003` | ✅ EV functionality     |

## 🔧 **Configuration Details**

### **Original EMHASS (davidusb-geek)**

```yaml
# davidusb-geek/emhass-add-on/emhass/config.yml
ports:
  5000/tcp: 5000
ports_description:
  5000/tcp: Web interface and API
webui: http://[HOST]:[PORT:5000]
ingress_port: 5000
```

### **Enhanced EMHASS (tomvanacker85)**

```yaml
# tomvanacker85/emhass-add-on/emhass/config.yml
ports:
  5001/tcp: 5001
ports_description:
  5001/tcp: Web interface and API
webui: http://[HOST]:[PORT:5001]
ingress_port: 5001
```

### **EV EMHASS (tomvanacker85)**

```yaml
# tomvanacker85/emhass-ev-add-on/emhass-ev/config.yml
ports:
  5003/tcp: 5003
ports_description:
  5003/tcp: EMHASS EV Web interface and API
webui: http://[HOST]:[PORT:5003]
```

## 🚀 **Production Deployment**

### **Install All Three Versions**

#### **1. Original EMHASS**

```
Repository: https://github.com/davidusb-geek/emhass-add-on
Add-on: "EMHASS"
Port: 5000
Purpose: Original EMHASS functionality
```

#### **2. Enhanced EMHASS**

```
Repository: https://github.com/tomvanacker85/emhass-add-on
Add-on: "EMHASS"
Port: 5001
Purpose: EMHASS with PR 601 (DST fixes) + your enhancements
```

#### **3. EV EMHASS**

```
Repository: https://github.com/tomvanacker85/emhass-ev-add-on
Add-on: "EMHASS EV Charging Optimizer"
Port: 5003
Purpose: Complete EV charging optimization
```

## 📱 **Access Points**

### **Home Assistant Add-on Store**

Each add-on will appear with its own configuration page and can be started/stopped independently.

### **Web Interfaces**

- **Original**: `http://your-ha-ip:5000`
- **Enhanced**: `http://your-ha-ip:5001`
- **EV Version**: `http://your-ha-ip:5003`

### **API Endpoints**

- **Original**: `http://your-ha-ip:5000/action/dayahead-optim`
- **Enhanced**: `http://your-ha-ip:5001/action/dayahead-optim`
- **EV Version**: `http://your-ha-ip:5003/action/dayahead-optim`

## 🎯 **Usage Scenarios**

### **Parallel Operation Benefits**

#### **Testing & Comparison**

- **Compare results** between original and enhanced versions
- **Test EV optimization** while keeping standard optimization running
- **Gradual migration** from one version to another

#### **Different Use Cases**

- **Original (5000)**: Baseline functionality
- **Enhanced (5001)**: Standard optimization with DST fixes
- **EV (5003)**: Dedicated EV charging optimization

#### **Data Isolation**

```
/share/emhass/          # Original EMHASS data
/share/emhass/          # Enhanced EMHASS data (shared with original)
/share/emhass-ev/       # EV EMHASS data (completely separate)
```

## ⚠️ **Important Notes**

### **Resource Usage**

- **CPU**: Three optimization processes will use more CPU
- **Memory**: Each add-on requires separate memory allocation
- **Storage**: Separate data directories for logs and configurations

### **Home Assistant API**

- Each add-on will make **separate API calls** to Home Assistant
- Consider **API rate limits** if running intensive optimizations
- **Stagger optimization times** to avoid conflicts

### **Configuration Management**

- **Separate configurations** for each version
- **Different secrets** files if needed
- **Independent backup/restore** for each add-on

## 🔄 **Migration Strategy**

### **Recommended Approach**

1. **Keep original** EMHASS running (port 5000)
2. **Install enhanced** version (port 5001) and configure
3. **Test both** versions in parallel
4. **Install EV version** (port 5003) for EV optimization
5. **Gradually migrate** automations to preferred version
6. **Remove unused** versions when confident

## ✅ **Verification Complete**

### **Port Conflicts**: ❌ **RESOLVED**

- ✅ **No port conflicts** between the three versions
- ✅ **Unique ports** assigned: 5000, 5001, 5003
- ✅ **All configurations** updated correctly
- ✅ **Ready for production** deployment

### **Next Steps**

1. **Push updated repositories** to GitHub
2. **Install all three add-ons** in Home Assistant
3. **Configure each** according to your needs
4. **Start optimizing** with multiple EMHASS versions!

---

**🎉 Three EMHASS versions ready for parallel production deployment!** 🚀
