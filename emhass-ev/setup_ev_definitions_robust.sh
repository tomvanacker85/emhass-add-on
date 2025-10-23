#!/bin/bash

# EV Parameter Definitions Setup - Robust version
# This script adds EV parameter definitions to the EMHASS configuration system

set -e

echo "🔧 Setting up EV Parameter Definitions..."

# Find the parameter definitions file
PARAM_DEFS=$(find /app -name "param_definitions.json" | head -1)

if [ -n "$PARAM_DEFS" ]; then
    echo "📁 Found parameter definitions: $PARAM_DEFS"
    
    # Create backup
    if [ ! -f "$PARAM_DEFS.original" ]; then
        cp "$PARAM_DEFS" "$PARAM_DEFS.original"
        echo "💾 Created backup of original param_definitions.json"
    fi
    
    echo "🔧 Adding EV parameter definitions..."
    
    # Check if EV section already exists
    if ! grep -q "Electric Vehicle (EV)" "$PARAM_DEFS"; then
        # Restore from backup to ensure clean state
        cp "$PARAM_DEFS.original" "$PARAM_DEFS"
        
        # Use a more reliable approach: extract everything before the final } 
        # and append our EV section properly
        
        # Create the complete EV section with proper JSON syntax
        cat > /tmp/ev_section.json << 'EOF'
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
        
        # Remove the last closing brace from the original file
        head -n -1 "$PARAM_DEFS" > /tmp/param_defs_without_closing.json
        
        # Append our EV section
        cat /tmp/param_defs_without_closing.json /tmp/ev_section.json > /tmp/param_defs_new.json
        
        # Add the final closing brace
        echo "}" >> /tmp/param_defs_new.json
        
        # Replace the original file
        mv /tmp/param_defs_new.json "$PARAM_DEFS"
        
        echo "✅ EV parameter definitions added to param_definitions.json"
    else
        echo "ℹ️ EV definitions already exist in param_definitions.json"
    fi
    
else
    echo "❌ Could not find param_definitions.json"
    exit 1
fi

echo "🎉 EV Parameter Definitions setup complete!"