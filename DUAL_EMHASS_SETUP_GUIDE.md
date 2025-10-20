# Dual EMHASS Setup Guide: Production + EV Extension

## 🎯 Goal: Run Two EMHASS Add-ons Safely

This guide helps you set up:
- **EMHASS (Original)**: Your current production system - **UNCHANGED**
- **EMHASS EV Extension**: New add-on for EV optimization - **NEW**

## 📋 Pre-Installation Checklist

✅ **Backup Current Setup**
```bash
# Backup your current EMHASS configuration
cp -r /config/share/emhass /config/backups/emhass-backup-$(date +%Y%m%d)
```

✅ **Verify Current EMHASS is Working**
- Check that your current EMHASS add-on is running
- Note down current configuration settings
- Test that optimization still works

## 🚀 Installation Steps

### Step 1: Prepare Your Fork (One-time Setup)

```bash
# 1. Push your EV extension to GitHub
cd /workspaces/emhass
git push origin feature/ev-charging-extension

# 2. Create a release or tag (optional but recommended)
git tag v0.14.0-ev
git push origin v0.14.0-ev
```

### Step 2: Add EV Add-on to Home Assistant

#### Option A: Local Development
1. Copy the `emhass-ev` folder to your Home Assistant:
   ```bash
   # From your dev environment
   scp -r /workspaces/emhass-add-on/emhass-ev/ user@your-ha:/config/addons/
   ```

2. In Home Assistant:
   - Go to **Supervisor** → **Add-on Store**
   - Click **⋮** (three dots) → **Reload**
   - Look for **"EMHASS EV Extension"** under **Local Add-ons**

#### Option B: GitHub Repository (Recommended)
1. Create a new repository: `tomvanacker85/emhass-addon-ev`
2. Push your `emhass-ev` folder to it
3. In Home Assistant:
   - **Supervisor** → **Add-on Store** → **⋮** → **Repositories**
   - Add: `https://github.com/tomvanacker85/emhass-addon-ev`

### Step 3: Configure EV Add-on

1. **Install** "EMHASS EV Extension"
2. **Configure** before starting:

```yaml
# Basic configuration - start simple
number_of_ev_loads: 1
ev_battery_capacity: '[60000]'
ev_charging_efficiency: '[0.9]'  
ev_nominal_charging_power: '[7400]'
ev_minimum_charging_power: '[1380]'

# Standard settings (copy from your existing EMHASS)
battery_nominal_energy_capacity: 5000  # Use your current values
battery_minimum_state_of_charge: 0.3
battery_maximum_state_of_charge: 0.9
# ... other battery settings
```

3. **Start** the add-on
4. **Check logs** for any errors

## 🔍 Verification: Both Add-ons Running

### Check Services
```bash
# Original EMHASS - port 5000
curl http://your-ha:5000/

# EV Extension - port 5001  
curl http://your-ha:5001/
```

### Web Interfaces
- **Original EMHASS**: http://your-ha:8123/hassio/ingress/emhass
- **EV Extension**: http://your-ha:8123/hassio/ingress/emhass-ev

### Home Assistant Services
```yaml
# In Developer Tools → Services, you should see both:
service: rest_command.emhass_original        # Your existing
service: rest_command.emhass_ev_extension    # New EV version
```

## 📊 Usage Strategy

### Phase 1: Parallel Testing (Recommended)
Keep both running, use original for house, test EV with new one:

```yaml
# Automation: Keep using original EMHASS for house
- alias: "House Energy Management"
  trigger:
    - platform: time
      at: "05:30:00"
  action:
    - service: rest_command.emhass_original  # Existing
      
# Automation: Test EV with new add-on  
- alias: "EV Charging Test"
  trigger:
    - platform: time  
      at: "23:00:00"
  action:
    - service: rest_command.emhass_ev_extension  # New EV
      data:
        ev_availability: "[[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1]]"
        ev_minimum_soc_schedule: "[[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]]"
        ev_initial_soc: "[0.2]"
```

### Phase 2: Integrated Usage (After Testing)
Once confident, you can:
1. **Option A**: Use EV add-on for everything (house + EV)
2. **Option B**: Keep both - original for house, EV for cars
3. **Option C**: Migrate completely and remove original

## 🛡️ Safety Measures

### Configuration Isolation
- **Different ports**: 5000 vs 5001
- **Different config paths**: `/share/emhass` vs `/share/emhass-ev`
- **Different slugs**: `emhass` vs `emhass-ev`

### Rollback Plan
If something goes wrong:
```bash
# Stop EV add-on
# Remove EV add-on  
# Your original EMHASS continues unchanged

# Restore backup if needed
cp -r /config/backups/emhass-backup-* /config/share/emhass
```

### Monitoring
```yaml
# Monitor both services
sensor:
  - platform: rest
    name: "EMHASS Original Status"
    resource: "http://localhost:5000/"
    
  - platform: rest  
    name: "EMHASS EV Status"
    resource: "http://localhost:5001/"
```

## 🎯 Expected Results

### Success Indicators
✅ Both add-ons show "Running" status  
✅ Both web interfaces accessible  
✅ Original EMHASS continues optimizing house  
✅ EV add-on returns optimization with EV data  
✅ No port conflicts or resource issues  

### API Response Comparison
```json
// Original EMHASS response (unchanged)
{
  "P_deferrable0": [...],
  "P_grid": [...],
  "P_batt": [...]
}

// EV Extension response (enhanced)  
{
  "P_deferrable0": [...],
  "P_EV0": [...],           // NEW: EV power schedule
  "SOC_EV0": [...],         // NEW: EV SOC profile  
  "P_grid": [...],
  "P_batt": [...]
}
```

## 🔧 Troubleshooting

### Port Conflicts
If port 5001 is busy:
```yaml
# In emhass-ev config.yml, change to different port
ports:
  5002/tcp: 5002
```

### Build Issues
Check add-on logs:
```bash
ha addons logs emhass-ev
```

Common issues:
- GitHub access to your fork
- Missing dependencies
- Configuration syntax errors

### Performance Impact
Monitor system resources:
- CPU usage should be similar to running one EMHASS
- Memory usage roughly doubles
- Network: minimal additional load

---

**This approach gives you a safe path to test EV functionality while keeping your production energy management system fully operational!** 🏠🚗⚡