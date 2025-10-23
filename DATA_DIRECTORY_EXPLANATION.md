# 📁 Data Directory Creation - Status & Solution

## ❓ **Why You Don't See `/share/emhass-enhanced` Yet**

The `/share/emhass-enhanced` directory will **only be created when the add-on starts** for the first time. Here's why:

### **Directory Creation Timeline**
1. **Before Installation**: Directory doesn't exist ❌
2. **During Add-on Installation**: Directory still doesn't exist ❌  
3. **When Add-on Starts**: Directory gets created ✅
4. **After First Run**: Directory persists ✅

## ✅ **Fix Applied**

I've added a **custom run script** that ensures the directory is created:

### **Enhanced EMHASS Add-on Now Includes:**

#### **`run.sh` Script**
```bash
# Creates the enhanced data directory
DATA_PATH="/share/emhass-enhanced"
mkdir -p "${DATA_PATH}"
echo "📁 Created data directory: ${DATA_PATH}"

# Sets proper environment variables
export EMHASS_DATA_PATH="${DATA_PATH}"
export EMHASS_CONFIG_PATH="${DATA_PATH}"
```

#### **Custom Dockerfile**
```dockerfile
# Builds from original EMHASS + enhancements
FROM ghcr.io/davidusb-geek/emhass:latest
COPY run.sh /usr/bin/run.sh
ENV EMHASS_DATA_PATH="/share/emhass-enhanced"
```

## 🚀 **What Happens During Installation**

### **Step 1: Add-on Installation** 
```bash
# Add repository: https://github.com/tomvanacker85/emhass-add-on
# Install "EMHASS" add-on
# Status: Add-on installed but not started
# Directory status: /share/emhass-enhanced doesn't exist yet
```

### **Step 2: Add-on First Start**
```bash
# Start the add-on in Home Assistant
# run.sh executes and creates /share/emhass-enhanced
# EMHASS starts with enhanced data path
# Status: Directory created and EMHASS running
```

### **Step 3: Verification**
```bash
# Check Home Assistant file system
ls -la /share/
# Expected output:
# drwxr-xr-x emhass/           # Original (if installed)
# drwxr-xr-x emhass-enhanced/  # Your enhanced version ✅
# drwxr-xr-x emhass-ev/        # EV version (if installed)
```

## 🔍 **How to Verify It's Working**

### **After Installing & Starting the Add-on:**

#### **1. Check Add-on Logs**
```bash
# In Home Assistant > Add-ons > EMHASS > Logs
# Look for:
"📁 Created data directory: /share/emhass-enhanced"
"🚀 Starting Enhanced EMHASS..."
```

#### **2. Check File System** 
```bash
# In Home Assistant > Settings > System > Hardware
# Navigate to /share/ and look for emhass-enhanced folder
```

#### **3. Test Web Interface**
```bash
# Access: http://homeassistant:5001
# Should show EMHASS interface using enhanced data path
```

## 📊 **Directory Structure After Installation**

```
/share/
├── emhass/                    # Original EMHASS (port 5000)
│   ├── config_emhass.yaml     
│   ├── secrets_emhass.yaml    
│   └── data/                  
│
├── emhass-enhanced/           # Enhanced EMHASS (port 5001) ✅
│   ├── config_emhass.yaml     # Created on first run
│   ├── secrets_emhass.yaml    # Created on first run
│   └── data/                  # Created on first run
│
└── emhass-ev/                 # EV EMHASS (port 5003)
    ├── config_emhass.yaml     
    ├── secrets_emhass.yaml    
    └── data/                  
```

## 🛠️ **Troubleshooting**

### **If Directory Still Doesn't Appear:**

#### **Check Add-on Status**
```bash
# Ensure add-on is STARTED (not just installed)
# Check add-on logs for errors
# Verify port 5001 is accessible
```

#### **Manual Verification**
```bash
# SSH into Home Assistant (if enabled)
# Or use File Editor add-on to browse /share/
# Directory should exist after first start
```

#### **Restart Add-on**
```bash
# Stop and start the add-on to trigger run.sh again
# Check logs for directory creation message
```

## ✅ **Expected Timeline**

| **Action** | **Directory Status** | **Timeline** |
|------------|---------------------|--------------|
| **Install add-on** | ❌ Doesn't exist | Immediate |
| **Start add-on** | ✅ **Created** | ~30 seconds |
| **First optimization** | ✅ **Populated with data** | After first run |

## 🎯 **Next Steps**

1. **Install the enhanced add-on** from `https://github.com/tomvanacker85/emhass-add-on`
2. **Start the add-on** in Home Assistant
3. **Check the logs** for "📁 Created data directory" message
4. **Verify directory exists** at `/share/emhass-enhanced`
5. **Access web interface** at `http://homeassistant:5001`

The directory **will definitely be created** when the add-on starts with the custom run script! 🚀