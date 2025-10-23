#!/bin/bash

# Simple EV Configuration Setup
# This script adds a working EV configuration section directly to the HTML

set -e

echo "🔧 Setting up Simple EV Configuration Section..."

# Find the templates directory
TEMPLATES_DIR=""
if [ -d "/app/src/emhass/templates" ]; then
    TEMPLATES_DIR="/app/src/emhass/templates"
else
    echo "❌ Could not find templates directory"
    exit 1
fi

CONFIG_HTML="$TEMPLATES_DIR/configuration.html"
if [ -f "$CONFIG_HTML" ]; then
    echo "📁 Found configuration template: $CONFIG_HTML"

    # Create backup if it doesn't exist
    if [ ! -f "$CONFIG_HTML.original" ]; then
        cp "$CONFIG_HTML" "$CONFIG_HTML.original"
        echo "💾 Created backup of original configuration.html"
    fi

    # Check if EV section already exists
    if ! grep -q "EV Configuration" "$CONFIG_HTML"; then
        echo "🔧 Adding EV configuration section..."

        # Create the EV configuration section HTML
        cat > /tmp/ev_config_section.html << 'EOF'

<!-- EV Configuration Section -->
<div class="form-group" style="margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; background: #f9f9f9;">
    <h3 style="color: #333; margin-bottom: 15px;">🚗 Electric Vehicle Configuration</h3>

    <!-- EV Enable Toggle -->
    <div style="margin-bottom: 20px;">
        <label class="switch" style="display: inline-block;">
            <input type="checkbox" id="set_use_ev" name="set_use_ev">
            <span class="slider" style="position: relative; display: inline-block; width: 60px; height: 34px; background-color: #ccc; border-radius: 34px; transition: .4s;">
                <span style="position: absolute; content: ''; height: 26px; width: 26px; left: 4px; bottom: 4px; background-color: white; border-radius: 50%; transition: .4s;"></span>
            </span>
        </label>
        <label for="set_use_ev" style="margin-left: 10px; font-weight: bold;">Enable Electric Vehicle Optimization</label>
    </div>

    <!-- EV Parameters (initially hidden) -->
    <div id="ev-parameters" style="display: none;">
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
            <div>
                <label for="number_of_ev_loads" style="display: block; font-weight: bold; margin-bottom: 5px;">Number of EV Loads:</label>
                <input type="number" id="number_of_ev_loads" name="number_of_ev_loads" min="0" max="5" value="1" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                <small style="color: #666;">Number of electric vehicles (0 to disable)</small>
            </div>

            <div>
                <label for="ev_battery_capacity" style="display: block; font-weight: bold; margin-bottom: 5px;">Battery Capacity (Wh):</label>
                <input type="text" id="ev_battery_capacity" name="ev_battery_capacity" value="[75000]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                <small style="color: #666;">Battery capacity in Wh (e.g., [75000] for 75 kWh)</small>
            </div>

            <div>
                <label for="ev_charging_efficiency" style="display: block; font-weight: bold; margin-bottom: 5px;">Charging Efficiency:</label>
                <input type="text" id="ev_charging_efficiency" name="ev_charging_efficiency" value="[0.9]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                <small style="color: #666;">Charging efficiency (e.g., [0.9] for 90%)</small>
            </div>

            <div>
                <label for="ev_nominal_charging_power" style="display: block; font-weight: bold; margin-bottom: 5px;">Nominal Charging Power (W):</label>
                <input type="text" id="ev_nominal_charging_power" name="ev_nominal_charging_power" value="[11000]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                <small style="color: #666;">Maximum charging power (e.g., [11000] for 11 kW)</small>
            </div>

            <div>
                <label for="ev_minimum_charging_power" style="display: block; font-weight: bold; margin-bottom: 5px;">Minimum Charging Power (W):</label>
                <input type="text" id="ev_minimum_charging_power" name="ev_minimum_charging_power" value="[1380]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                <small style="color: #666;">Minimum charging power in W</small>
            </div>

            <div>
                <label for="ev_consumption_efficiency" style="display: block; font-weight: bold; margin-bottom: 5px;">Consumption (kWh/100km):</label>
                <input type="text" id="ev_consumption_efficiency" name="ev_consumption_efficiency" value="[20.0]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                <small style="color: #666;">Energy consumption per 100km</small>
            </div>
        </div>

        <div style="background: #e8f4f8; border: 1px solid #bee5eb; border-radius: 6px; padding: 15px; margin-top: 20px;">
            <h4 style="margin-top: 0; color: #0c5460;">💡 Configuration Tips:</h4>
            <ul style="margin-bottom: 0; padding-left: 20px;">
                <li><strong>Battery Capacity:</strong> Use Wh units (e.g., 75 kWh = 75000 Wh)</li>
                <li><strong>Charging Power:</strong> Check your charger specs (3.7kW, 7.4kW, 11kW, 22kW)</li>
                <li><strong>Consumption:</strong> Typical values: 15-25 kWh/100km depending on EV model</li>
                <li><strong>Multiple EVs:</strong> Use arrays like [75000, 60000] for two different EVs</li>
            </ul>
        </div>
    </div>
</div>

<script>
// EV Configuration JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const evToggle = document.getElementById('set_use_ev');
    const evParameters = document.getElementById('ev-parameters');

    // Toggle EV parameters visibility
    if (evToggle && evParameters) {
        evToggle.addEventListener('change', function() {
            evParameters.style.display = this.checked ? 'block' : 'none';
        });
    }

    // Load existing configuration if available
    function loadEVConfig() {
        try {
            // Try to load from existing config
            if (window.configData && window.configData.params && window.configData.params.ev_conf) {
                const evConf = window.configData.params.ev_conf;

                if (document.getElementById('number_of_ev_loads')) {
                    document.getElementById('number_of_ev_loads').value = evConf.number_of_ev_loads || 1;
                }
                if (document.getElementById('ev_battery_capacity')) {
                    document.getElementById('ev_battery_capacity').value = JSON.stringify(evConf.ev_battery_capacity || [75000]);
                }
                if (document.getElementById('ev_charging_efficiency')) {
                    document.getElementById('ev_charging_efficiency').value = JSON.stringify(evConf.ev_charging_efficiency || [0.9]);
                }
                if (document.getElementById('ev_nominal_charging_power')) {
                    document.getElementById('ev_nominal_charging_power').value = JSON.stringify(evConf.ev_nominal_charging_power || [11000]);
                }
                if (document.getElementById('ev_minimum_charging_power')) {
                    document.getElementById('ev_minimum_charging_power').value = JSON.stringify(evConf.ev_minimum_charging_power || [1380]);
                }
                if (document.getElementById('ev_consumption_efficiency')) {
                    document.getElementById('ev_consumption_efficiency').value = JSON.stringify(evConf.ev_consumption_efficiency || [20.0]);
                }

                // Show parameters if EV is enabled
                const numEVs = parseInt(document.getElementById('number_of_ev_loads').value);
                if (numEVs > 0) {
                    evToggle.checked = true;
                    evParameters.style.display = 'block';
                }
            }
        } catch (e) {
            console.log('Could not load existing EV configuration:', e);
        }
    }

    // Load config after a short delay to ensure other scripts are loaded
    setTimeout(loadEVConfig, 1000);

    // Hook into form submission to include EV data
    const forms = document.querySelectorAll('form');
    forms.forEach(function(form) {
        form.addEventListener('submit', function() {
            try {
                const evConfig = {
                    number_of_ev_loads: parseInt(document.getElementById('number_of_ev_loads')?.value || '0'),
                    ev_battery_capacity: JSON.parse(document.getElementById('ev_battery_capacity')?.value || '[75000]'),
                    ev_charging_efficiency: JSON.parse(document.getElementById('ev_charging_efficiency')?.value || '[0.9]'),
                    ev_nominal_charging_power: JSON.parse(document.getElementById('ev_nominal_charging_power')?.value || '[11000]'),
                    ev_minimum_charging_power: JSON.parse(document.getElementById('ev_minimum_charging_power')?.value || '[1380]'),
                    ev_consumption_efficiency: JSON.parse(document.getElementById('ev_consumption_efficiency')?.value || '[20.0]')
                };

                // Add to global config data
                if (window.configData && window.configData.params) {
                    window.configData.params.ev_conf = evConfig;
                }

                console.log('EV Configuration submitted:', evConfig);
            } catch(e) {
                console.error('Error submitting EV configuration:', e);
            }
        });
    });
});
</script>

EOF

        # Insert the EV section before the closing body tag
        sed -i '/<\/body>/i\
<!-- Insert EV Configuration Section -->' "$CONFIG_HTML"

        # Insert the actual EV configuration content
        sed -i '/<!-- Insert EV Configuration Section -->/r /tmp/ev_config_section.html' "$CONFIG_HTML"

        # Remove the marker comment
        sed -i '/<!-- Insert EV Configuration Section -->/d' "$CONFIG_HTML"

        echo "✅ EV configuration section added to HTML template"
    else
        echo "ℹ️ EV configuration section already exists in template"
    fi
else
    echo "❌ configuration.html not found in $TEMPLATES_DIR"
    exit 1
fi

echo "🎉 Simple EV Configuration Setup complete!"
echo "📋 The EV configuration section is now available on the configuration page"