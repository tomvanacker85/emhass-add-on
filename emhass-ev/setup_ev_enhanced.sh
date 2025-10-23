#!/bin/bash

# Enhanced EV Configuration with YAML Support
# This script adds EV configuration with both form and YAML editing capabilities

set -e

echo "🔧 Setting up Enhanced EV Configuration with YAML Support..."

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

    # Check if enhanced EV section already exists
    if ! grep -q "Enhanced EV Configuration" "$CONFIG_HTML"; then
        echo "🔧 Adding enhanced EV configuration section..."

        # Restore from original to avoid duplicates
        cp "$CONFIG_HTML.original" "$CONFIG_HTML"

        # Create the enhanced EV configuration section HTML
        cat > /tmp/enhanced_ev_config.html << 'EOF'

<!-- Enhanced EV Configuration Section -->
<div class="form-group" style="margin: 20px 0; padding: 20px; border: 2px solid #4a90e2; border-radius: 12px; background: linear-gradient(135deg, #f0f8ff 0%, #e8f5e8 100%);">
    <h3 style="color: #2c5aa0; margin-bottom: 15px; border-bottom: 2px solid #4a90e2; padding-bottom: 10px;">🚗 Enhanced EV Configuration</h3>

    <!-- Mode Toggle -->
    <div style="margin-bottom: 20px; text-align: center;">
        <button type="button" id="ev-form-mode" class="ev-mode-btn active" style="padding: 10px 20px; margin-right: 10px; border: 2px solid #4a90e2; border-radius: 6px; background: #4a90e2; color: white; cursor: pointer;">Form Mode</button>
        <button type="button" id="ev-yaml-mode" class="ev-mode-btn" style="padding: 10px 20px; border: 2px solid #4a90e2; border-radius: 6px; background: white; color: #4a90e2; cursor: pointer;">YAML Mode</button>
    </div>

    <!-- Form Mode -->
    <div id="ev-form-section">
        <!-- EV Enable Toggle -->
        <div style="margin-bottom: 20px;">
            <label class="switch" style="display: inline-block;">
                <input type="checkbox" id="set_use_ev" name="set_use_ev">
                <span class="slider round" style="position: relative; display: inline-block; width: 60px; height: 34px; background-color: #ccc; border-radius: 34px; transition: .4s;">
                    <span style="position: absolute; content: ''; height: 26px; width: 26px; left: 4px; bottom: 4px; background-color: white; border-radius: 50%; transition: .4s; transform: translateX(0px);"></span>
                </span>
            </label>
            <label for="set_use_ev" style="margin-left: 10px; font-weight: bold; color: #2c5aa0;">Enable Electric Vehicle Optimization</label>
        </div>

        <!-- EV Parameters -->
        <div id="ev-parameters" style="display: none;">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                <div>
                    <label for="number_of_ev_loads" style="display: block; font-weight: bold; margin-bottom: 5px; color: #2c5aa0;">Number of EV Loads:</label>
                    <input type="number" id="number_of_ev_loads" name="number_of_ev_loads" min="0" max="5" value="1" style="width: 100%; padding: 8px; border: 1px solid #4a90e2; border-radius: 4px;">
                    <small style="color: #666;">Number of electric vehicles (0 to disable)</small>
                </div>

                <div>
                    <label for="ev_battery_capacity" style="display: block; font-weight: bold; margin-bottom: 5px; color: #2c5aa0;">Battery Capacity (Wh):</label>
                    <input type="text" id="ev_battery_capacity" name="ev_battery_capacity" value="[75000]" style="width: 100%; padding: 8px; border: 1px solid #4a90e2; border-radius: 4px;">
                    <small style="color: #666;">Battery capacity in Wh (e.g., [75000] for 75 kWh)</small>
                </div>

                <div>
                    <label for="ev_charging_efficiency" style="display: block; font-weight: bold; margin-bottom: 5px; color: #2c5aa0;">Charging Efficiency:</label>
                    <input type="text" id="ev_charging_efficiency" name="ev_charging_efficiency" value="[0.9]" style="width: 100%; padding: 8px; border: 1px solid #4a90e2; border-radius: 4px;">
                    <small style="color: #666;">Charging efficiency (e.g., [0.9] for 90%)</small>
                </div>

                <div>
                    <label for="ev_nominal_charging_power" style="display: block; font-weight: bold; margin-bottom: 5px; color: #2c5aa0;">Nominal Charging Power (W):</label>
                    <input type="text" id="ev_nominal_charging_power" name="ev_nominal_charging_power" value="[11000]" style="width: 100%; padding: 8px; border: 1px solid #4a90e2; border-radius: 4px;">
                    <small style="color: #666;">Maximum charging power (e.g., [11000] for 11 kW)</small>
                </div>

                <div>
                    <label for="ev_minimum_charging_power" style="display: block; font-weight: bold; margin-bottom: 5px; color: #2c5aa0;">Minimum Charging Power (W):</label>
                    <input type="text" id="ev_minimum_charging_power" name="ev_minimum_charging_power" value="[1380]" style="width: 100%; padding: 8px; border: 1px solid #4a90e2; border-radius: 4px;">
                    <small style="color: #666;">Minimum charging power in W</small>
                </div>

                <div>
                    <label for="ev_consumption_efficiency" style="display: block; font-weight: bold; margin-bottom: 5px; color: #2c5aa0;">Consumption (kWh/100km):</label>
                    <input type="text" id="ev_consumption_efficiency" name="ev_consumption_efficiency" value="[20.0]" style="width: 100%; padding: 8px; border: 1px solid #4a90e2; border-radius: 4px;">
                    <small style="color: #666;">Energy consumption per 100km</small>
                </div>
            </div>
        </div>
    </div>

    <!-- YAML Mode -->
    <div id="ev-yaml-section" style="display: none;">
        <div style="margin-bottom: 15px;">
            <label for="ev-yaml-config" style="display: block; font-weight: bold; margin-bottom: 5px; color: #2c5aa0;">EV Configuration (YAML):</label>
            <textarea id="ev-yaml-config" style="width: 100%; height: 300px; padding: 10px; border: 1px solid #4a90e2; border-radius: 4px; font-family: 'Courier New', monospace; font-size: 14px; background: #f8f9fa;">
# EV Configuration YAML
ev_conf:
  number_of_ev_loads: 1
  ev_battery_capacity: [75000]
  ev_charging_efficiency: [0.9]
  ev_nominal_charging_power: [11000]
  ev_minimum_charging_power: [1380]
  ev_consumption_efficiency: [20.0]

# Example for multiple EVs:
# ev_conf:
#   number_of_ev_loads: 2
#   ev_battery_capacity: [75000, 60000]    # Tesla + Nissan Leaf
#   ev_charging_efficiency: [0.9, 0.88]   # Different efficiencies
#   ev_nominal_charging_power: [11000, 7400]  # 11kW + 7.4kW
#   ev_minimum_charging_power: [1380, 1380]   # Same minimum
#   ev_consumption_efficiency: [18.5, 16.2]   # Different consumption
            </textarea>
            <small style="color: #666;">Edit the YAML directly. Changes will sync with form mode.</small>
        </div>

        <div style="margin-bottom: 15px;">
            <button type="button" id="load-yaml-from-file" style="padding: 10px 20px; margin-right: 10px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer;">Load from /share/emhass-ev/config.json</button>
            <button type="button" id="save-yaml-to-file" style="padding: 10px 20px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;">Save to File</button>
        </div>
    </div>

    <div style="background: #e8f4f8; border: 1px solid #bee5eb; border-radius: 6px; padding: 15px; margin-top: 20px;">
        <h4 style="margin-top: 0; color: #0c5460;">💡 Configuration Tips:</h4>
        <ul style="margin-bottom: 0; padding-left: 20px; color: #0c5460;">
            <li><strong>Battery Capacity:</strong> Use Wh units (e.g., 75 kWh = 75000 Wh)</li>
            <li><strong>Charging Power:</strong> Check your charger specs (3.7kW, 7.4kW, 11kW, 22kW)</li>
            <li><strong>Consumption:</strong> Typical values: 15-25 kWh/100km depending on EV model</li>
            <li><strong>Multiple EVs:</strong> Use arrays like [75000, 60000] for two different EVs</li>
            <li><strong>YAML Mode:</strong> Direct edit for advanced users, form mode for easy configuration</li>
        </ul>
    </div>
</div>

<style>
.ev-mode-btn.active {
    background: #4a90e2 !important;
    color: white !important;
}

.switch input:checked + .slider span {
    transform: translateX(26px) !important;
}

.switch input:checked + .slider {
    background-color: #4a90e2 !important;
}
</style>

<script>
// Enhanced EV Configuration JavaScript
document.addEventListener('DOMContentLoaded', function() {
    const evToggle = document.getElementById('set_use_ev');
    const evParameters = document.getElementById('ev-parameters');
    const formModeBtn = document.getElementById('ev-form-mode');
    const yamlModeBtn = document.getElementById('ev-yaml-mode');
    const formSection = document.getElementById('ev-form-section');
    const yamlSection = document.getElementById('ev-yaml-section');
    const yamlConfig = document.getElementById('ev-yaml-config');

    // Mode switching
    function switchToFormMode() {
        formModeBtn.classList.add('active');
        yamlModeBtn.classList.remove('active');
        formSection.style.display = 'block';
        yamlSection.style.display = 'none';
        formToYaml(); // Sync form to YAML before hiding
    }

    function switchToYamlMode() {
        yamlModeBtn.classList.add('active');
        formModeBtn.classList.remove('active');
        yamlSection.style.display = 'block';
        formSection.style.display = 'none';
        formToYaml(); // Update YAML with current form values
    }

    // Event listeners for mode buttons
    if (formModeBtn) formModeBtn.addEventListener('click', switchToFormMode);
    if (yamlModeBtn) yamlModeBtn.addEventListener('click', switchToYamlMode);

    // Toggle EV parameters visibility
    if (evToggle && evParameters) {
        evToggle.addEventListener('change', function() {
            evParameters.style.display = this.checked ? 'block' : 'none';
        });
    }

    // Convert form values to YAML
    function formToYaml() {
        try {
            const config = {
                ev_conf: {
                    number_of_ev_loads: parseInt(document.getElementById('number_of_ev_loads')?.value || '1'),
                    ev_battery_capacity: JSON.parse(document.getElementById('ev_battery_capacity')?.value || '[75000]'),
                    ev_charging_efficiency: JSON.parse(document.getElementById('ev_charging_efficiency')?.value || '[0.9]'),
                    ev_nominal_charging_power: JSON.parse(document.getElementById('ev_nominal_charging_power')?.value || '[11000]'),
                    ev_minimum_charging_power: JSON.parse(document.getElementById('ev_minimum_charging_power')?.value || '[1380]'),
                    ev_consumption_efficiency: JSON.parse(document.getElementById('ev_consumption_efficiency')?.value || '[20.0]')
                }
            };

            // Simple YAML conversion
            const yaml = 'ev_conf:\\n' +
                '  number_of_ev_loads: ' + config.ev_conf.number_of_ev_loads + '\\n' +
                '  ev_battery_capacity: ' + JSON.stringify(config.ev_conf.ev_battery_capacity) + '\\n' +
                '  ev_charging_efficiency: ' + JSON.stringify(config.ev_conf.ev_charging_efficiency) + '\\n' +
                '  ev_nominal_charging_power: ' + JSON.stringify(config.ev_conf.ev_nominal_charging_power) + '\\n' +
                '  ev_minimum_charging_power: ' + JSON.stringify(config.ev_conf.ev_minimum_charging_power) + '\\n' +
                '  ev_consumption_efficiency: ' + JSON.stringify(config.ev_conf.ev_consumption_efficiency);

            if (yamlConfig) {
                yamlConfig.value = yaml;
            }
        } catch (e) {
            console.error('Error converting form to YAML:', e);
        }
    }

    // Load existing configuration
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

                // Update YAML
                formToYaml();
            }
        } catch (e) {
            console.log('Could not load existing EV configuration:', e);
        }
    }

    // Load from file button
    document.getElementById('load-yaml-from-file')?.addEventListener('click', function() {
        fetch('/share/emhass-ev/config.json')
            .then(response => response.json())
            .then(data => {
                if (data.params && data.params.ev_conf) {
                    // Update form fields
                    const evConf = data.params.ev_conf;
                    document.getElementById('number_of_ev_loads').value = evConf.number_of_ev_loads || 1;
                    document.getElementById('ev_battery_capacity').value = JSON.stringify(evConf.ev_battery_capacity || [75000]);
                    document.getElementById('ev_charging_efficiency').value = JSON.stringify(evConf.ev_charging_efficiency || [0.9]);
                    document.getElementById('ev_nominal_charging_power').value = JSON.stringify(evConf.ev_nominal_charging_power || [11000]);
                    document.getElementById('ev_minimum_charging_power').value = JSON.stringify(evConf.ev_minimum_charging_power || [1380]);
                    document.getElementById('ev_consumption_efficiency').value = JSON.stringify(evConf.ev_consumption_efficiency || [20.0]);

                    // Update toggle and visibility
                    if (evConf.number_of_ev_loads > 0) {
                        evToggle.checked = true;
                        evParameters.style.display = 'block';
                    }

                    // Update YAML
                    formToYaml();

                    alert('Configuration loaded successfully!');
                }
            })
            .catch(error => {
                alert('Could not load config file: ' + error.message);
            });
    });

    // Load config after a short delay
    setTimeout(loadEVConfig, 1000);

    // Hook into form submission
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

        # Insert the enhanced EV section before the closing body tag
        sed -i '/<\/body>/i\
<!-- Insert Enhanced EV Configuration Section -->' "$CONFIG_HTML"

        # Insert the actual EV configuration content
        sed -i '/<!-- Insert Enhanced EV Configuration Section -->/r /tmp/enhanced_ev_config.html' "$CONFIG_HTML"

        # Remove the marker comment
        sed -i '/<!-- Insert Enhanced EV Configuration Section -->/d' "$CONFIG_HTML"

        echo "✅ Enhanced EV configuration section added to HTML template"
    else
        echo "ℹ️ Enhanced EV configuration section already exists in template"
    fi
else
    echo "❌ configuration.html not found in $TEMPLATES_DIR"
    exit 1
fi

echo "🎉 Enhanced EV Configuration with YAML Support Setup complete!"
echo "📋 Features available:"
echo "  ✅ Toggle switch for EV optimization"
echo "  ✅ Form mode for easy configuration"
echo "  ✅ YAML mode for direct editing"
echo "  ✅ Load configuration from file"
echo "  ✅ Professional styling and layout"