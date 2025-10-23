# EMHASS EV Extension Changelog

## [v1.3.2] - 2025-10-24

### Fixed
- **Python Path Issue**: Resolved `/run.sh: line 45: python3: command not found` error
  - Added shell script version of DST fix (`fix_dst_issues.sh`) as primary method
  - Improved execution path detection for Python in EMHASS container
  - Added fallback mechanisms: shell script → venv python → uv run → system python
  - Better error reporting and troubleshooting information

### Added
- **Shell Script DST Fix**: Pure bash implementation that doesn't require Python
- **Multiple Execution Paths**: Robust handling of different container Python setups
- **Enhanced Logging**: Clear feedback about which DST fix method is being used

### Technical Details
- Shell script uses `sed` for reliable text replacement without Python dependencies
- Handles EMHASS container's `uv` virtual environment setup
- Maintains compatibility with all Python environment configurations
- Includes verification and backup creation in both Python and shell versions

---

## [v1.3.1] - 2025-10-24

### Fixed
- **DST Timezone Handling**: Added comprehensive daylight saving time transition fixes
  - Resolves `AmbiguousTimeError: Cannot infer dst time from 2025-10-26 02:00:00`
  - Applies PR601 equivalent fixes automatically at container startup
  - Adds `ambiguous="infer"` and `nonexistent="shift_forward"` to all `tz_localize()` calls
  - Replaces problematic `pd.Timestamp(datetime.now(), tz=...)` with `pd.Timestamp.now(tz=...)`
  - Compatible with all timezone configurations (Australia/Sydney, US/Eastern, Europe, etc.)
  - Includes verification and backup creation during patching

### Added
- **Automatic DST Fix Script**: `fix_dst_issues.py` patches forecast.py at runtime
- **Documentation**: DST_FIX_README.md and QUICK_DST_FIX.md for troubleshooting
- **Verification System**: Confirms DST fixes are applied correctly

### Technical Details
- Handles both "spring forward" (nonexistent times) and "fall back" (ambiguous times) DST transitions
- Creates backup of original forecast.py before patching
- Applied automatically on every container startup
- No configuration changes required from users

---

## [v1.3.0] - 2025-10-23

### Added
- **Complete EMHASS EV Implementation**: Full mathematical optimization model for electric vehicle charging
- **EV-Specific Variables**: `P_ev`, `SOC_ev`, `P_ev_bin` optimization variables
- **Semi-Continuous Charging**: Advanced constraint handling for realistic EV charging behavior
- **Multi-EV Support**: Framework for optimizing multiple electric vehicles
- **Native EMHASS Integration**: Seamless integration with existing EMHASS infrastructure

### Features
- **Intelligent Scheduling**: Optimizes EV charging based on energy prices and availability
- **SOC Management**: Maintains battery level requirements for driving schedules
- **Distance Forecasting**: Considers daily commute and weekend driving patterns
- **Efficiency Modeling**: Accounts for charging and consumption efficiency
- **Home Assistant Integration**: Complete automation and dashboard support

### Configuration
- **Installation Guide**: Comprehensive EMHASS_EV_INSTALLATION_GUIDE.md
- **Automation Template**: emhass_ev_automation.yaml for single EV setups
- **HA Helpers**: ha_ev_configuration.yaml with input helpers and sensors
- **Multi-Platform Support**: Tesla, BMW, Volkswagen, and generic EV integrations

### Documentation
- **Complete Implementation**: EV_EXTENSION_README.md technical documentation
- **User Guides**: Step-by-step installation and configuration instructions
- **Examples**: Sample configurations for various EV platforms