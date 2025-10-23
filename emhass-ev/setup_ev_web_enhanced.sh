#!/bin/bash

# Enhanced EV Configuration Web Extension Setup Script
# This script directly modifies the EMHASS configuration system

set -e

echo "🔧 Setting up Enhanced EV Configuration Integration..."

# Find the EMHASS application directory
APP_DIR="/app"
if [ ! -d "$APP_DIR" ]; then
    echo "❌ EMHASS app directory not found"
    exit 1
fi

# Find the static directory and copy our EV scripts
STATIC_DIR=$(find $APP_DIR -path "*/emhass/static" -type d 2>/dev/null | head -1)
if [ -z "$STATIC_DIR" ]; then
    STATIC_DIR=$(find $APP_DIR -name "static" -type d | grep emhass | head -1)
fi
if [ -z "$STATIC_DIR" ]; then
    STATIC_DIR=$(find $APP_DIR -name "static" -type d 2>/dev/null | head -1)
fi

if [ -n "$STATIC_DIR" ]; then
    echo "📁 Found static directory: $STATIC_DIR"

    # Copy EV configuration files
    if [ -f "/app/ev_config_extension.js" ]; then
        cp /app/ev_config_extension.js "$STATIC_DIR/"
        echo "✅ EV configuration extension copied"
    fi

    if [ -f "/app/ev_config_simple.js" ]; then
        cp /app/ev_config_simple.js "$STATIC_DIR/"
        echo "✅ EV simple configuration copied"
    fi

    # Modify the existing configuration_script.js to include EV functionality
    CONFIG_SCRIPT="$STATIC_DIR/configuration_script.js"
    if [ -f "$CONFIG_SCRIPT" ]; then
        echo "🔧 Enhancing configuration_script.js with EV support..."

        # Create a backup
        cp "$CONFIG_SCRIPT" "$CONFIG_SCRIPT.backup"

        # Add EV configuration loading at the end of the script
        cat >> "$CONFIG_SCRIPT" << 'EOF'

// ======= EV CONFIGURATION EXTENSION =======
// Auto-load EV configuration interface

(function() {
    'use strict';

    console.log('Loading EMHASS EV Configuration Extension...');

    // EV Configuration Section HTML
    const evConfigHTML = `
        <div class="form-group" id="ev-config-section" style="background: linear-gradient(135deg, #e8f5e8 0%, #f0f8ff 100%); border: 2px solid #4a90e2; border-radius: 12px; padding: 20px; margin: 20px 0;">
            <h3 style="color: #2c5aa0; border-bottom: 2px solid #4a90e2; padding-bottom: 10px; margin-bottom: 15px;">🚗 Electric Vehicle Configuration</h3>

            <div style="background: rgba(74, 144, 226, 0.1); padding: 12px; border-radius: 6px; margin-bottom: 20px; font-style: italic; color: #2c5aa0;">
                Configure EV charging parameters and consumption patterns for optimal charging schedule optimization.
            </div>

            <div style="display: grid; gap: 15px;">
                <div>
                    <label for="ev_number_of_ev_loads" style="display: block; font-weight: bold; margin-bottom: 5px;">Number of EV Loads:</label>
                    <input type="number" id="ev_number_of_ev_loads" name="number_of_ev_loads" min="0" max="5" value="1" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
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
    `;

    // Function to inject EV configuration section
    function injectEVConfig() {
        // Wait for the page to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                setTimeout(injectEVConfig, 1000);
            });
            return;
        }

        // Find the form or container to add EV config
        const configForm = document.querySelector('form, .form-container, .config-container, main');

        if (configForm && !document.getElementById('ev-config-section')) {
            // Insert the EV configuration section
            configForm.insertAdjacentHTML('beforeend', evConfigHTML);

            // Load existing configuration if available
            loadEVConfiguration();

            // Hook into form submission
            hookFormSubmission();

            console.log('✅ EV Configuration section added successfully');
        } else if (document.getElementById('ev-config-section')) {
            console.log('EV Configuration section already exists');
        } else {
            console.warn('Could not find suitable container for EV configuration');
            // Retry after a delay
            setTimeout(injectEVConfig, 2000);
        }
    }

    // Function to load existing EV configuration
    function loadEVConfiguration() {
        try {
            // Try to get current configuration from the page or server
            const evConf = window.configData?.params?.ev_conf || {};

            // Populate form fields with existing values
            const fields = {
                'ev_number_of_ev_loads': evConf.number_of_ev_loads || 1,
                'ev_battery_capacity': JSON.stringify(evConf.ev_battery_capacity || [75000]),
                'ev_charging_efficiency': JSON.stringify(evConf.ev_charging_efficiency || [0.9]),
                'ev_nominal_charging_power': JSON.stringify(evConf.ev_nominal_charging_power || [11000]),
                'ev_minimum_charging_power': JSON.stringify(evConf.ev_minimum_charging_power || [1380]),
                'ev_consumption_efficiency': JSON.stringify(evConf.ev_consumption_efficiency || [0.2])
            };

            Object.entries(fields).forEach(([id, value]) => {
                const element = document.getElementById(id);
                if (element) {
                    element.value = value;
                }
            });

            console.log('EV configuration loaded:', evConf);
        } catch (error) {
            console.log('Using default EV configuration values:', error);
        }
    }

    // Function to hook into form submission
    function hookFormSubmission() {
        const forms = document.querySelectorAll('form');
        forms.forEach(form => {
            form.addEventListener('submit', function(e) {
                try {
                    // Collect EV configuration data
                    const evConfig = {
                        number_of_ev_loads: parseInt(document.getElementById('ev_number_of_ev_loads')?.value || '1'),
                        ev_battery_capacity: JSON.parse(document.getElementById('ev_battery_capacity')?.value || '[75000]'),
                        ev_charging_efficiency: JSON.parse(document.getElementById('ev_charging_efficiency')?.value || '[0.9]'),
                        ev_nominal_charging_power: JSON.parse(document.getElementById('ev_nominal_charging_power')?.value || '[11000]'),
                        ev_minimum_charging_power: JSON.parse(document.getElementById('ev_minimum_charging_power')?.value || '[1380]'),
                        ev_consumption_efficiency: JSON.parse(document.getElementById('ev_consumption_efficiency')?.value || '[0.2]')
                    };

                    // Add to global config if available
                    if (window.configData && window.configData.params) {
                        window.configData.params.ev_conf = evConfig;
                    }

                    console.log('EV Configuration will be saved:', evConfig);
                } catch (error) {
                    console.error('Error collecting EV configuration:', error);
                }
            });
        });
    }

    // Initialize EV configuration
    console.log('Initializing EV Configuration Extension...');
    injectEVConfig();

})();

// End of EV Configuration Extension
EOF

        echo "✅ Enhanced configuration_script.js with EV support"
    else
        echo "⚠️  configuration_script.js not found, creating EV loader"
        # Create a new script if the original doesn't exist
        cat > "$STATIC_DIR/ev_auto_loader.js" << 'EOF'
// EV Configuration Auto-Loader
document.addEventListener('DOMContentLoaded', function() {
    console.log('EV Auto-Loader: Page loaded');
    // Load EV configuration after a short delay
    setTimeout(function() {
        if (typeof window.loadEVConfiguration === 'function') {
            window.loadEVConfiguration();
        }
    }, 1000);
});
EOF
        echo "✅ Created EV auto-loader script"
    fi

else
    echo "❌ Could not find static directory"
    exit 1
fi

echo "🎉 Enhanced EV Configuration Integration complete!"