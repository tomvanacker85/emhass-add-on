# EMHASS EV Extension v1.2.1 - Complete Integration Documentation

## ✅ Final Implementation Status

The EMHASS EV Extension has been **successfully integrated** into the existing EMHASS framework following proper architectural patterns. The EV configuration now appears as a **native section** on the EMHASS configuration page.

## 🎯 What Was Achieved

### 1. Proper Framework Integration
- **EV Section**: Added as a native section card in `configuration_list.html`
- **Toggle Switch**: `set_use_ev` toggle following Battery/Solar pattern
- **Parameter Definitions**: EV parameters integrated into `param_definitions.json`
- **JavaScript Support**: `configuration_script.js` updated to handle EV section dynamically
- **Default Configuration**: `config_defaults.json` includes `set_use_ev: false`

### 2. Native EMHASS Experience
- EV section appears between Solar System (PV) and Battery sections
- Toggle switch enables/disables EV parameters dynamically
- Full integration with EMHASS save/load/default functionality
- Consistent styling and user experience with existing sections

### 3. Complete Parameter Coverage
The following EV parameters are available when the toggle is enabled:
- **set_use_ev**: Enable Electric Vehicle optimization
- **number_of_ev_loads**: Number of electric vehicles (1-4)
- **ev_battery_capacity**: Battery capacity in Wh per EV
- **ev_charging_efficiency**: Charging efficiency (0-1) per EV
- **ev_nominal_charging_power**: Maximum charging power in W per EV
- **ev_minimum_charging_power**: Minimum charging power in W per EV
- **ev_consumption_efficiency**: Energy consumption in kWh/km per EV

## 🏗️ Technical Architecture

### Configuration Flow
```
1. User opens EMHASS configuration page
2. configuration_list.html template loads with EV section
3. configuration_script.js processes section headers including set_use_ev
4. When EV toggle is enabled, buildParamContainers() generates EV parameters
5. Parameters are loaded from param_definitions.json["Electric Vehicle (EV)"]
6. Configuration can be saved/loaded like any other EMHASS section
```

### File Modifications
- **`/app/src/emhass/static/configuration_list.html`**: Added EV section card
- **`/app/src/emhass/static/data/param_definitions.json`**: Added "Electric Vehicle (EV)" section
- **`/app/src/emhass/static/configuration_script.js`**: Added set_use_ev handling
- **`/app/src/emhass/data/config_defaults.json`**: Added set_use_ev default

## 🎮 User Experience

### How to Use EV Configuration
1. **Access Configuration**: Open EMHASS configuration page at `http://localhost:5000/configuration`
2. **Enable EV Section**: Locate "Electric Vehicle (EV)" section and toggle the switch
3. **Configure Parameters**: Set EV parameters for your specific vehicles
4. **Save Configuration**: Use EMHASS's standard save functionality
5. **YAML Editing**: Toggle to YAML mode to edit configuration directly

### Example EV Configuration
```json
{
  "set_use_ev": true,
  "number_of_ev_loads": 2,
  "ev_battery_capacity": [75000, 60000],
  "ev_charging_efficiency": [0.9, 0.85],
  "ev_nominal_charging_power": [11000, 7400],
  "ev_minimum_charging_power": [1380, 1380],
  "ev_consumption_efficiency": [0.2, 0.18]
}
```

## 🔧 Installation and Setup

### For Home Assistant Users
1. **Add Repository**: `https://github.com/tomvanacker85/emhass-add-on`
2. **Install Add-on**: Search for "EMHASS" in Home Assistant add-on store
3. **Configure**: Use the integrated EV configuration section
4. **Start Optimization**: EV parameters automatically included in optimization

### For Docker Users
```bash
# Pull the latest image
docker pull ghcr.io/tomvanacker85/emhass-add-on/emhass:latest

# Run with EV support
docker run -d \
  --name emhass-ev \
  -p 5000:5000 \
  -v /path/to/config:/data \
  ghcr.io/tomvanacker85/emhass-add-on/emhass:latest
```

## 🎯 Benefits of This Integration

### 1. Seamless Experience
- No separate configuration files or interfaces
- Native EMHASS look and feel
- Consistent with existing Battery/Solar sections

### 2. Proper Framework Extension
- Follows EMHASS architectural patterns
- Leverages existing configuration management
- Future-proof design for additional EV features

### 3. Multi-EV Support
- Configure up to 4 electric vehicles
- Different parameters per vehicle
- Individual charging schedules and efficiency ratings

## 🔄 Version History

### v1.2.1 (Final Release)
- ✅ Complete EMHASS framework integration
- ✅ Native configuration section with toggle
- ✅ Multi-EV parameter support
- ✅ Home Assistant add-on ready
- ✅ Docker container optimization

## 📞 Support and Troubleshooting

### Common Issues
1. **EV Section Not Visible**: Ensure container restart after integration
2. **Parameters Not Saving**: Check write permissions to /data or /share
3. **Toggle Not Working**: Verify JavaScript loading correctly

### Getting Help
- **Documentation**: See included DOCS.md files
- **Examples**: Check example_ev_*.yaml and example_ev_*.py files
- **Testing**: Use test_ev_*.sh scripts for validation

---

## 🎉 Conclusion

The EMHASS EV Extension is now **fully integrated** into the EMHASS framework, providing a native, professional experience for electric vehicle optimization. Users can configure EV parameters alongside their existing solar, battery, and load configurations in a unified interface.

The integration follows EMHASS best practices and provides a foundation for future enhancements while maintaining backward compatibility with existing EMHASS installations.