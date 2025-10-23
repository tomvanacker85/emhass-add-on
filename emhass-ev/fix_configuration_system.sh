#!/bin/bash

# Fix EMHASS Configuration System to Include EV Parameters
# This script patches the configuration system to properly include EV parameters in the YAML editor

set -e

echo "🔧 Fixing EMHASS Configuration System for EV Parameters..."

# 1. Patch the build_config function to include EV parameters
UTILS_PY="/app/src/emhass/utils.py"

if [ -f "$UTILS_PY" ]; then
    echo "📝 Patching build_config function to include EV parameters..."

    # Create backup
    if [ ! -f "$UTILS_PY.original" ]; then
        cp "$UTILS_PY" "$UTILS_PY.original"
        echo "💾 Created backup of utils.py"
    fi

    # Find the end of the build_config function and add EV parameter loading
    # We'll add the EV loading just before the return statement

    # Create the EV loading code
    cat > /tmp/ev_config_patch.py << 'EOF'
    # Load EV parameters if they exist
    ev_config_path = "/share/emhass-ev/config.json"
    if pathlib.Path(ev_config_path).is_file():
        try:
            with open(ev_config_path, "r") as ev_data:
                ev_config = json.load(ev_data)
                logger.info("Loading EV parameters from /share/emhass-ev/config.json")

                # Extract EV parameters from ev_conf section and add to main config
                if "params" in ev_config and "ev_conf" in ev_config["params"]:
                    ev_params = ev_config["params"]["ev_conf"]

                    # Map EV parameters to EMHASS config format
                    config["set_use_ev"] = bool(ev_params.get("number_of_ev_loads", 0) > 0)
                    if config["set_use_ev"]:
                        config["number_of_ev_loads"] = ev_params.get("number_of_ev_loads", 0)
                        config["ev_battery_capacity"] = ev_params.get("ev_battery_capacity", [75000])
                        config["ev_charging_efficiency"] = ev_params.get("ev_charging_efficiency", [0.9])
                        config["ev_nominal_charging_power"] = ev_params.get("ev_nominal_charging_power", [11000])
                        config["ev_minimum_charging_power"] = ev_params.get("ev_minimum_charging_power", [1380])
                        config["ev_consumption_efficiency"] = ev_params.get("ev_consumption_efficiency", [0.2])
                        logger.info(f"Loaded EV parameters: {len(config['ev_battery_capacity'])} vehicles configured")
        except Exception as e:
            logger.warning(f"Failed to load EV parameters: {e}")
    else:
        logger.debug("No EV configuration file found at /share/emhass-ev/config.json")

EOF

    # Insert the EV loading code before the return statement in build_config
    # Find the line with "return config" and insert the EV code before it
    /app/.venv/bin/python << 'PYTHON_SCRIPT'
import re

# Read the original file
with open('/app/src/emhass/utils.py', 'r') as f:
    content = f.read()

# Read the EV patch
with open('/tmp/ev_config_patch.py', 'r') as f:
    ev_patch = f.read()

# Find the build_config function and add EV loading before return
# Look for the pattern where config is returned
pattern = r'(\s+)(return config)$'
replacement = f'\\1{ev_patch}\n\\1\\2'

# Apply the patch
modified_content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

# Write the modified content
with open('/app/src/emhass/utils.py', 'w') as f:
    f.write(modified_content)

print("✅ EV configuration loading added to build_config function")
PYTHON_SCRIPT

else
    echo "❌ utils.py not found"
    exit 1
fi

# 2. Update config_defaults.json to include all EV parameters with defaults
CONFIG_DEFAULTS="/app/src/emhass/data/config_defaults.json"

if [ -f "$CONFIG_DEFAULTS" ]; then
    echo "📝 Adding EV parameters to config_defaults.json..."

    # Create backup
    if [ ! -f "$CONFIG_DEFAULTS.defaults_backup" ]; then
        cp "$CONFIG_DEFAULTS" "$CONFIG_DEFAULTS.defaults_backup"
        echo "💾 Created backup of config_defaults.json"
    fi

    # Add EV parameters to defaults if they don't exist
    /app/.venv/bin/python << 'PYTHON_SCRIPT'
import json

# Read current defaults
with open('/app/src/emhass/data/config_defaults.json', 'r') as f:
    defaults = json.load(f)

# Add EV parameters if they don't exist
ev_defaults = {
    "set_use_ev": False,
    "number_of_ev_loads": 0,
    "ev_battery_capacity": [75000],
    "ev_charging_efficiency": [0.9],
    "ev_nominal_charging_power": [11000],
    "ev_minimum_charging_power": [1380],
    "ev_consumption_efficiency": [0.2]
}

for key, value in ev_defaults.items():
    if key not in defaults:
        defaults[key] = value

# Write updated defaults
with open('/app/src/emhass/data/config_defaults.json', 'w') as f:
    json.dump(defaults, f, indent=2)

print("✅ EV parameters added to config_defaults.json")
PYTHON_SCRIPT

else
    echo "❌ config_defaults.json not found"
    exit 1
fi

echo "🎉 EMHASS Configuration System Fixed!"
echo ""
echo "📋 What was fixed:"
echo "  ✅ build_config() function now loads EV parameters from /share/emhass-ev/config.json"
echo "  ✅ EV parameters are merged into main EMHASS configuration"
echo "  ✅ config_defaults.json includes EV parameter defaults"
echo "  ✅ YAML editor will now show EV parameters when they exist"
echo ""
echo "🎮 How it works now:"
echo "  1. Configuration page loads EV parameters if /share/emhass-ev/config.json exists"
echo "  2. EV parameters appear in both form view and YAML view"
echo "  3. set_use_ev toggle shows/hides EV parameters in form view"
echo "  4. YAML editor includes all EV parameters when present"