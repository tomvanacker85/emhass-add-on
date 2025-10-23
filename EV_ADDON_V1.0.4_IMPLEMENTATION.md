# EMHASS EV Add-on v1.0.4 Implementation Complete

## 🎯 **Implementation Summary**

Successfully updated the EMHASS EV Extension add-on with the same km-based improvements that were applied to the enhanced add-on. The EV add-on now includes all the latest features and proper configuration separation.

## 🔧 **Changes Applied**

### 1. **Version Update**

- Updated from `v0.14.0-ev` to `v1.0.4`
- Aligned with enhanced add-on versioning scheme

### 2. **New EV Parameter - Km-based Consumption**

- Added `ev_consumption_efficiency` parameter to both options and schema
- Enables intuitive distance-based energy forecasting (e.g., "20 kWh/100km")
- Users can now specify driving distance in km instead of complex energy calculations

### 3. **Port Configuration Fix**

- **Fixed port conflicts**: Changed from 5001 to 5003
- **Port allocation now**:
  - 5000: Original EMHASS
  - 5001: Enhanced EMHASS
  - 5003: EV EMHASS ✅
- Updated port in `config.yml`, `Dockerfile`, and `run.sh`

### 4. **Updated Documentation**

#### config.yml

- Added `ev_consumption_efficiency` to options and schema
- Updated version to v1.0.4
- Fixed port configuration to 5003

#### CHANGELOG.md

- Added v1.0.4 release notes
- Documented km-based functionality
- Noted port conflict resolution

#### README.md

- Added section on km-based energy planning
- Updated all port references from 5001 → 5003
- Enhanced feature documentation
- Updated differences from standard EMHASS

#### Dockerfile & run.sh

- Updated EMHASS_PORT environment variable to 5003
- Ensured consistent port configuration

## 🚀 **New Functionality**

### Distance-based EV Planning

Users can now provide EV consumption forecasts using intuitive distance data:

```json
{
  "ev_distance_forecast": [
    [
      0, 0, 0, 0, 0, 0, 25, 40, 60, 75, 50, 40, 25, 15, 10, 5, 0, 0, 0, 0, 0, 0,
      0, 0
    ]
  ]
}
```

Combined with efficiency setting:

```yaml
ev_consumption_efficiency: "[20.0]" # 20 kWh/100km
```

The system automatically converts km → kWh for optimization calculations.

## 📊 **Configuration Summary**

| Parameter | Value                           | Purpose                              |
| --------- | ------------------------------- | ------------------------------------ |
| Version   | v1.0.4                          | Latest with km-based features        |
| Port      | 5003                            | Avoids conflicts with other versions |
| Data Path | /share/emhass-ev                | Isolated from other EMHASS instances |
| Image     | ghcr.io/tomvanacker85/emhass-ev | EV-specific Docker image             |
| New Param | ev_consumption_efficiency       | Km-based energy calculation          |

## 🔄 **Three-Way Separation Achieved**

All three EMHASS versions can now run simultaneously:

1. **Original EMHASS** (port 5000, /share/emhass)
2. **Enhanced EMHASS** (port 5001, /share/emhass-enhanced)
3. **EV EMHASS** (port 5003, /share/emhass-ev) ✅

## ✅ **Implementation Status**

- [x] Version bumped to v1.0.4
- [x] Km-based consumption parameter added
- [x] Port conflicts resolved (5001 → 5003)
- [x] All documentation updated
- [x] Dockerfile and run scripts updated
- [x] Changes committed to git
- [x] Consistent with enhanced add-on improvements

## 🎉 **Result**

The EMHASS EV Extension add-on now has the same advanced km-based functionality as the enhanced add-on, with proper port separation enabling all three versions to run simultaneously without conflicts.

**Ready for deployment and testing!**
