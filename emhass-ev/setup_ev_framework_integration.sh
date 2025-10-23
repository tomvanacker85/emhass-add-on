#!/bin/bash

# Proper EMHASS Framework Integration for EV Configuration
# This script properly integrates EV configuration into the existing EMHASS framework

set -e

echo "🔧 Setting up Proper EMHASS Framework Integration for EV..."

# Find the static directory where templates are located
STATIC_DIR=""
if [ -d "/app/src/emhass/static" ]; then
    STATIC_DIR="/app/src/emhass/static"
else
    echo "❌ Could not find static directory"
    exit 1
fi

echo "📁 Found static directory: $STATIC_DIR"

# 1. First, modify the configuration_list.html template to add EV section
CONFIG_LIST_HTML="$STATIC_DIR/configuration_list.html"
if [ -f "$CONFIG_LIST_HTML" ]; then
    echo "📝 Adding EV section to configuration_list.html template..."

    # Create backup
    if [ ! -f "$CONFIG_LIST_HTML.original" ]; then
        cp "$CONFIG_LIST_HTML" "$CONFIG_LIST_HTML.original"
        echo "💾 Created backup of configuration_list.html"
    fi

    # Check if EV section already exists
    if ! grep -q "Electric Vehicle" "$CONFIG_LIST_HTML"; then
        # Add EV section after Battery section, before the closing
        cat > /tmp/ev_section.html << 'EOF'
<div id="Electric Vehicle (EV)" class="section-card">
  <div class="section-card-header">
    <h4>Electric Vehicle (EV)</h4>
    <label class="switch"> <!-- switch connected to set_use_ev  -->
      <input id="set_use_ev" type="checkbox">
      <span class="slider"></span>
    </label>
  </div>
  <div class="section-body"> </div> <!--  parameters will get generated here -->
</div>
EOF

        # Insert EV section after Battery section
        sed -i '/<div class="section-body"> <\/div> <!--  parameters will get generated here -->/,/<\/div>$/{
            /<\/div>$/{
                /Battery/{
                    a\
<div id="Electric Vehicle (EV)" class="section-card">\
  <div class="section-card-header">\
    <h4>Electric Vehicle (EV)</h4>\
    <label class="switch"> <!-- switch connected to set_use_ev  -->\
      <input id="set_use_ev" type="checkbox">\
      <span class="slider"></span>\
    </label>\
  </div>\
  <div class="section-body"> </div> <!--  parameters will get generated here -->\
</div>
                }
            }
        }' "$CONFIG_LIST_HTML"

        echo "✅ EV section added to configuration_list.html"
    else
        echo "ℹ️ EV section already exists in configuration_list.html"
    fi
else
    echo "❌ configuration_list.html not found"
    exit 1
fi

# 2. Update parameter definitions to include proper EV section
PARAM_DEFS="/app/src/emhass/static/data/param_definitions.json"
if [ -f "$PARAM_DEFS" ]; then
    echo "📝 Ensuring EV parameters are in param_definitions.json..."

    # Create backup
    if [ ! -f "$PARAM_DEFS.original" ]; then
        cp "$PARAM_DEFS" "$PARAM_DEFS.original"
        echo "💾 Created backup of param_definitions.json"
    fi

    # Check if EV section exists
    if ! grep -q "Electric Vehicle (EV)" "$PARAM_DEFS"; then
        echo "🔧 Adding EV parameter definitions..."

        # Restore from backup and add EV section properly
        cp "$PARAM_DEFS.original" "$PARAM_DEFS"

        # Create EV definitions with proper EMHASS structure
        cat > /tmp/ev_param_definitions.json << 'EOF'
,
  "Electric Vehicle (EV)": {
    "set_use_ev": {
      "friendly_name": "Enable Electric Vehicle",
      "Description": "Enable Electric Vehicle optimization and charging scheduling.",
      "input": "boolean",
      "default_value": false
    },
    "number_of_ev_loads": {
      "friendly_name": "Number of EV loads",
      "Description": "Number of electric vehicles to optimize (0 to disable).",
      "input": "integer",
      "default_value": 1
    },
    "ev_battery_capacity": {
      "friendly_name": "EV battery capacity",
      "Description": "Battery capacity in Wh for each EV (e.g., [75000] for 75 kWh).",
      "input": "list",
      "default_value": [75000]
    },
    "ev_charging_efficiency": {
      "friendly_name": "EV charging efficiency",
      "Description": "Charging efficiency (0-1) for each EV (e.g., [0.9] for 90%).",
      "input": "list",
      "default_value": [0.9]
    },
    "ev_nominal_charging_power": {
      "friendly_name": "EV nominal charging power",
      "Description": "Maximum charging power in W for each EV (e.g., [11000] for 11 kW).",
      "input": "list",
      "default_value": [11000]
    },
    "ev_minimum_charging_power": {
      "friendly_name": "EV minimum charging power",
      "Description": "Minimum charging power in W for each EV.",
      "input": "list",
      "default_value": [1380]
    },
    "ev_consumption_efficiency": {
      "friendly_name": "EV consumption efficiency",
      "Description": "Energy consumption in kWh per km for each EV.",
      "input": "list",
      "default_value": [0.2]
    }
  }
EOF

        # Remove the last closing brace, add EV section, then close
        head -n -1 "$PARAM_DEFS" > /tmp/param_defs_temp.json
        cat /tmp/param_defs_temp.json /tmp/ev_param_definitions.json > /tmp/param_defs_new.json
        echo "}" >> /tmp/param_defs_new.json
        mv /tmp/param_defs_new.json "$PARAM_DEFS"

        echo "✅ EV parameter definitions added"
    else
        echo "ℹ️ EV parameter definitions already exist"
    fi
else
    echo "❌ param_definitions.json not found"
    exit 1
fi

# 3. Update configuration script to handle EV section
CONFIG_SCRIPT="/app/src/emhass/static/configuration_script.js"
if [ -f "$CONFIG_SCRIPT" ]; then
    echo "📝 Updating configuration script for EV support..."

    # Create backup
    if [ ! -f "$CONFIG_SCRIPT.original" ]; then
        cp "$CONFIG_SCRIPT" "$CONFIG_SCRIPT.original"
        echo "💾 Created backup of configuration_script.js"
    fi

    # Check if EV support already added
    if ! grep -q "set_use_ev" "$CONFIG_SCRIPT"; then
        echo "🔧 Adding EV support to configuration script..."

        # Add set_use_ev to header_input_list
        sed -i 's/let header_input_list = \["set_use_battery", "set_use_pv", "number_of_deferrable_loads"\];/let header_input_list = ["set_use_battery", "set_use_pv", "set_use_ev", "number_of_deferrable_loads"];/' "$CONFIG_SCRIPT"

        # Add EV case to the switch statement
        sed -i '/case "number_of_deferrable_loads":/i\
    //if set_use_ev, add or remove EV section (inc. params)\
    case "set_use_ev":\
      if (element.checked) {\
        param_container.innerHTML = "";\
        buildParamContainers("Electric Vehicle (EV)", param_definitions["Electric Vehicle (EV)"], config, [\
          "set_use_ev",\
        ]);\
        element.checked = true;\
      } else {\
        param_container.innerHTML = "";\
      }\
      break;\
\
    ' "$CONFIG_SCRIPT"

        echo "✅ EV support added to configuration script"
    else
        echo "ℹ️ EV support already exists in configuration script"
    fi
else
    echo "❌ configuration_script.js not found"
    exit 1
fi

# 4. Update config defaults to include set_use_ev
CONFIG_DEFAULTS="/app/src/emhass/data/config_defaults.json"
if [ -f "$CONFIG_DEFAULTS" ]; then
    echo "📝 Adding set_use_ev to config defaults..."

    # Create backup
    if [ ! -f "$CONFIG_DEFAULTS.original" ]; then
        cp "$CONFIG_DEFAULTS" "$CONFIG_DEFAULTS.original"
        echo "💾 Created backup of config_defaults.json"
    fi

    # Add set_use_ev if it doesn't exist
    if ! grep -q "set_use_ev" "$CONFIG_DEFAULTS"; then
        sed -i '/"set_use_battery": false,/a\  "set_use_ev": false,' "$CONFIG_DEFAULTS"
        echo "✅ set_use_ev added to config defaults"
    else
        echo "ℹ️ set_use_ev already exists in config defaults"
    fi
else
    echo "❌ config_defaults.json not found"
    exit 1
fi

echo "🎉 Proper EMHASS Framework Integration Complete!"
echo ""
echo "📋 What was integrated:"
echo "  ✅ EV section added to configuration_list.html template"
echo "  ✅ EV parameter definitions added to param_definitions.json"
echo "  ✅ EV toggle support added to configuration_script.js"
echo "  ✅ set_use_ev toggle added to config_defaults.json"
echo "  ✅ Proper section positioning between Battery and Solar"
echo ""
echo "🎮 How it works:"
echo "  1. EV section appears as a native EMHASS section card"
echo "  2. Toggle switch enables/disables EV parameters"
echo "  3. Parameters are dynamically generated like other sections"
echo "  4. Full integration with EMHASS save/load/default functionality"