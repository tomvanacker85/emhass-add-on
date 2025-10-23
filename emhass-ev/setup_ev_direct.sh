#!/bin/bash

# Direct EV Configuration Injection Script
# This script directly modifies the configuration.html template

set -e

echo "🔧 Setting up Direct EV Configuration Injection..."

# Find the templates directory - prioritize src location as it's what Flask serves
TEMPLATES_DIR=""
if [ -d "/app/src/emhass/templates" ]; then
    TEMPLATES_DIR="/app/src/emhass/templates"
else
    TEMPLATES_DIR=$(find /app -path "*/emhass/templates" -type d 2>/dev/null | head -1)
    if [ -z "$TEMPLATES_DIR" ]; then
        TEMPLATES_DIR=$(find /app -name "templates" -type d | grep emhass | head -1)
    fi
fi

if [ -n "$TEMPLATES_DIR" ]; then
    echo "📁 Found templates directory: $TEMPLATES_DIR"

    CONFIG_HTML="$TEMPLATES_DIR/configuration.html"
    if [ -f "$CONFIG_HTML" ]; then
        echo "🔧 Injecting EV configuration directly into configuration.html..."

        # Create backup
        cp "$CONFIG_HTML" "$CONFIG_HTML.original"

        # Create a temporary file with the EV configuration section
        cat > /tmp/ev_config_section.html << 'EVCONFIG'

<!-- EV Configuration Section -->
<div class="form-group" id="ev-config-section" style="background: linear-gradient(135deg, #e8f5e8 0%, #f0f8ff 100%); border: 2px solid #4a90e2; border-radius: 12px; padding: 20px; margin: 20px 0;">
    <h3 style="color: #2c5aa0; border-bottom: 2px solid #4a90e2; padding-bottom: 10px; margin-bottom: 15px;">🚗 Electric Vehicle Configuration</h3>

    <div style="background: rgba(74, 144, 226, 0.1); padding: 12px; border-radius: 6px; margin-bottom: 20px; font-style: italic; color: #2c5aa0;">
        Configure EV charging parameters and consumption patterns for optimal charging schedule optimization.
    </div>

    <div style="display: grid; gap: 15px;">
        <div>
            <label for="number_of_ev_loads" style="display: block; font-weight: bold; margin-bottom: 5px;">Number of EV Loads:</label>
            <input type="number" id="number_of_ev_loads" name="number_of_ev_loads" min="0" max="5" value="1" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
            <small style="color: #666;">Number of electric vehicles to optimize (0 = disabled)</small>
        </div>

        <div>
            <label for="ev_battery_capacity" style="display: block; font-weight: bold; margin-bottom: 5px;">Battery Capacity (Wh):</label>
            <input type="text" id="ev_battery_capacity" name="ev_battery_capacity" value="[75000]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
            <small style="color: #666;">Battery capacity in Wh for each EV (e.g., [75000] for 75 kWh)</small>
        </div>

        <div>
            <label for="ev_charging_efficiency" style="display: block; font-weight: bold; margin-bottom: 5px;">Charging Efficiency:</label>
            <input type="text" id="ev_charging_efficiency" name="ev_charging_efficiency" value="[0.9]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
            <small style="color: #666;">Charging efficiency (0-1) for each EV (e.g., [0.9] for 90%)</small>
        </div>

        <div>
            <label for="ev_nominal_charging_power" style="display: block; font-weight: bold; margin-bottom: 5px;">Nominal Charging Power (W):</label>
            <input type="text" id="ev_nominal_charging_power" name="ev_nominal_charging_power" value="[11000]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
            <small style="color: #666;">Maximum charging power in W for each EV (e.g., [11000] for 11 kW)</small>
        </div>

        <div>
            <label for="ev_minimum_charging_power" style="display: block; font-weight: bold; margin-bottom: 5px;">Minimum Charging Power (W):</label>
            <input type="text" id="ev_minimum_charging_power" name="ev_minimum_charging_power" value="[1380]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
            <small style="color: #666;">Minimum charging power in W for each EV (e.g., [1380])</small>
        </div>

        <div>
            <label for="ev_consumption_efficiency" style="display: block; font-weight: bold; margin-bottom: 5px;">Consumption Efficiency (kWh/km):</label>
            <input type="text" id="ev_consumption_efficiency" name="ev_consumption_efficiency" value="[0.2]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
            <small style="color: #666;">Energy consumption in kWh per km (e.g., [0.2] for 20 kWh/100km)</small>
        </div>
    </div>

    <div style="background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 6px; padding: 15px; margin-top: 20px;">
        <h4 style="margin-top: 0; color: #495057;">💡 EV Configuration Tips:</h4>
        <ul style="margin-bottom: 0; padding-left: 20px;">
            <li><strong>Battery Capacity:</strong> Use Wh units (e.g., 75 kWh = 75000 Wh)</li>
            <li><strong>Charging Power:</strong> Check your charger specifications (3.7kW, 7.4kW, 11kW, 22kW)</li>
            <li><strong>Consumption:</strong> Typical values: 0.15-0.25 kWh/km depending on EV model</li>
            <li><strong>Multiple EVs:</strong> Use arrays like [75000, 60000] for two different EVs</li>
        </ul>
    </div>
</div>
<!-- End EV Configuration Section -->
EVCONFIG

        # Find insertion point and add EV configuration
        if grep -q "</form>" "$CONFIG_HTML"; then
            # Insert before closing form tag
            sed -i '/^[[:space:]]*<\/form>/r /tmp/ev_config_section.html' "$CONFIG_HTML"
            echo "✅ EV configuration section inserted into form"
        elif grep -q "</body>" "$CONFIG_HTML"; then
            # Fallback: insert before closing body tag
            sed -i '/^[[:space:]]*<\/body>/r /tmp/ev_config_section.html' "$CONFIG_HTML"
            echo "✅ EV configuration section inserted into body"
        else
            echo "⚠️  Could not find suitable insertion point"
        fi

        # Add JavaScript for EV configuration handling
        cat > /tmp/ev_script.html << 'EVSCRIPT'

<script>
// EV Configuration Handler
document.addEventListener("DOMContentLoaded", function() {
    console.log("EV Configuration loaded");

    // Load existing EV configuration if available
    function loadEVConfig() {
        try {
            if (window.configData && window.configData.params && window.configData.params.ev_conf) {
                const evConf = window.configData.params.ev_conf;
                if (document.getElementById("number_of_ev_loads")) {
                    document.getElementById("number_of_ev_loads").value = evConf.number_of_ev_loads || 1;
                    document.getElementById("ev_battery_capacity").value = JSON.stringify(evConf.ev_battery_capacity || [75000]);
                    document.getElementById("ev_charging_efficiency").value = JSON.stringify(evConf.ev_charging_efficiency || [0.9]);
                    document.getElementById("ev_nominal_charging_power").value = JSON.stringify(evConf.ev_nominal_charging_power || [11000]);
                    document.getElementById("ev_minimum_charging_power").value = JSON.stringify(evConf.ev_minimum_charging_power || [1380]);
                    document.getElementById("ev_consumption_efficiency").value = JSON.stringify(evConf.ev_consumption_efficiency || [0.2]);
                    console.log("EV configuration loaded from existing data");
                }
            }
        } catch(e) {
            console.log("Using default EV configuration");
        }
    }

    // Hook into form submission
    const forms = document.querySelectorAll("form");
    forms.forEach(function(form) {
        form.addEventListener("submit", function() {
            try {
                const evConfig = {
                    number_of_ev_loads: parseInt(document.getElementById("number_of_ev_loads")?.value || "1"),
                    ev_battery_capacity: JSON.parse(document.getElementById("ev_battery_capacity")?.value || "[75000]"),
                    ev_charging_efficiency: JSON.parse(document.getElementById("ev_charging_efficiency")?.value || "[0.9]"),
                    ev_nominal_charging_power: JSON.parse(document.getElementById("ev_nominal_charging_power")?.value || "[11000]"),
                    ev_minimum_charging_power: JSON.parse(document.getElementById("ev_minimum_charging_power")?.value || "[1380]"),
                    ev_consumption_efficiency: JSON.parse(document.getElementById("ev_consumption_efficiency")?.value || "[0.2]")
                };

                if (window.configData && window.configData.params) {
                    window.configData.params.ev_conf = evConfig;
                }

                console.log("EV Configuration collected:", evConfig);
            } catch(e) {
                console.error("Error collecting EV configuration:", e);
            }
        });
    });

    // Load existing configuration
    setTimeout(loadEVConfig, 1000);
});
</script>
EVSCRIPT

        # Add the script before closing body tag
        sed -i '/^[[:space:]]*<\/body>/r /tmp/ev_script.html' "$CONFIG_HTML"
        echo "✅ EV configuration JavaScript added"

        # Clean up temporary files
        rm -f /tmp/ev_config_section.html /tmp/ev_script.html

    else
        echo "❌ configuration.html not found"
        exit 1
    fi
else
    echo "❌ Templates directory not found"
    exit 1
fi

echo "🎉 Direct EV Configuration Injection complete!"