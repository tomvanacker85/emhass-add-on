// EV Configuration Extension for EMHASS
// This script adds EV parameters as a separate section in the configuration tab

(function() {
    'use strict';

    // EV Configuration section HTML
    const evConfigHTML = `
        <div class="config-section" id="ev-config-section">
            <h3>🚗 Electric Vehicle Configuration</h3>
            <div class="config-description">
                Configure EV charging parameters and consumption patterns. These settings define how EMHASS optimizes EV charging schedules.
            </div>
            
            <div class="form-group">
                <label for="number_of_ev_loads">
                    Number of EV Loads:
                    <span class="help-text">Number of electric vehicles to optimize (0 = disabled)</span>
                </label>
                <input type="number" id="number_of_ev_loads" name="number_of_ev_loads" 
                       min="0" max="5" value="1" class="form-control">
            </div>

            <div class="form-group">
                <label for="ev_battery_capacity">
                    Battery Capacity (Wh):
                    <span class="help-text">Battery capacity in Wh for each EV (e.g., [75000] for 75 kWh)</span>
                </label>
                <input type="text" id="ev_battery_capacity" name="ev_battery_capacity" 
                       value="[75000]" class="form-control" placeholder="[75000]">
            </div>

            <div class="form-group">
                <label for="ev_charging_efficiency">
                    Charging Efficiency:
                    <span class="help-text">Charging efficiency (0-1) for each EV (e.g., [0.9] for 90%)</span>
                </label>
                <input type="text" id="ev_charging_efficiency" name="ev_charging_efficiency" 
                       value="[0.9]" class="form-control" placeholder="[0.9]">
            </div>

            <div class="form-group">
                <label for="ev_nominal_charging_power">
                    Nominal Charging Power (W):
                    <span class="help-text">Maximum charging power in W for each EV (e.g., [11000] for 11 kW)</span>
                </label>
                <input type="text" id="ev_nominal_charging_power" name="ev_nominal_charging_power" 
                       value="[11000]" class="form-control" placeholder="[11000]">
            </div>

            <div class="form-group">
                <label for="ev_minimum_charging_power">
                    Minimum Charging Power (W):
                    <span class="help-text">Minimum charging power in W for each EV (e.g., [1380])</span>
                </label>
                <input type="text" id="ev_minimum_charging_power" name="ev_minimum_charging_power" 
                       value="[1380]" class="form-control" placeholder="[1380]">
            </div>

            <div class="form-group">
                <label for="ev_consumption_efficiency">
                    Consumption Efficiency (kWh/km):
                    <span class="help-text">Energy consumption in kWh per km (e.g., [0.2] for 0.2 kWh/km)</span>
                </label>
                <input type="text" id="ev_consumption_efficiency" name="ev_consumption_efficiency" 
                       value="[0.2]" class="form-control" placeholder="[0.2]">
            </div>

            <div class="ev-info">
                <h4>💡 EV Configuration Tips</h4>
                <ul>
                    <li><strong>Battery Capacity:</strong> Use Wh units (e.g., 75 kWh = 75000 Wh)</li>
                    <li><strong>Charging Power:</strong> Check your charger specifications (3.7kW, 7.4kW, 11kW, 22kW)</li>
                    <li><strong>Consumption:</strong> Typical values: 0.15-0.25 kWh/km depending on EV model</li>
                    <li><strong>Multiple EVs:</strong> Use arrays like [75000, 60000] for two different EVs</li>
                </ul>
            </div>
        </div>
    `;

    // CSS styles for EV configuration section
    const evConfigCSS = `
        <style>
            #ev-config-section {
                background: linear-gradient(135deg, #e8f5e8 0%, #f0f8ff 100%);
                border: 2px solid #4a90e2;
                border-radius: 12px;
                padding: 20px;
                margin: 20px 0;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }

            #ev-config-section h3 {
                color: #2c5aa0;
                border-bottom: 2px solid #4a90e2;
                padding-bottom: 10px;
                margin-bottom: 15px;
            }

            .config-description {
                background: rgba(74, 144, 226, 0.1);
                padding: 12px;
                border-radius: 6px;
                margin-bottom: 20px;
                font-style: italic;
                color: #2c5aa0;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-group label {
                display: block;
                font-weight: bold;
                margin-bottom: 5px;
                color: #333;
            }

            .help-text {
                display: block;
                font-size: 0.9em;
                color: #666;
                font-weight: normal;
                margin-top: 2px;
            }

            .form-control {
                width: 100%;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 4px;
                box-sizing: border-box;
                font-size: 14px;
            }

            .form-control:focus {
                border-color: #4a90e2;
                outline: none;
                box-shadow: 0 0 5px rgba(74, 144, 226, 0.3);
            }

            .ev-info {
                background: #f8f9fa;
                border: 1px solid #e9ecef;
                border-radius: 6px;
                padding: 15px;
                margin-top: 20px;
            }

            .ev-info h4 {
                margin-top: 0;
                color: #495057;
            }

            .ev-info ul {
                margin-bottom: 0;
            }

            .ev-info li {
                margin-bottom: 8px;
            }
        </style>
    `;

    // Function to inject EV configuration section
    function injectEVConfig() {
        // Add CSS styles
        document.head.insertAdjacentHTML('beforeend', evConfigCSS);

        // Find the configuration form or container
        const configContainer = document.querySelector('.configuration-container, .config-form, form, main');
        
        if (configContainer) {
            // Insert EV configuration section
            configContainer.insertAdjacentHTML('beforeend', evConfigHTML);
            
            // Load existing EV configuration if available
            loadEVConfiguration();
            
            console.log('EV Configuration section added successfully');
        } else {
            console.warn('Configuration container not found, retrying in 1 second...');
            setTimeout(injectEVConfig, 1000);
        }
    }

    // Function to load existing EV configuration
    function loadEVConfiguration() {
        // Try to load from existing config
        if (window.configData && window.configData.params && window.configData.params.ev_conf) {
            const evConf = window.configData.params.ev_conf;
            
            // Populate form fields
            document.getElementById('number_of_ev_loads').value = evConf.number_of_ev_loads || 1;
            document.getElementById('ev_battery_capacity').value = JSON.stringify(evConf.ev_battery_capacity || [75000]);
            document.getElementById('ev_charging_efficiency').value = JSON.stringify(evConf.ev_charging_efficiency || [0.9]);
            document.getElementById('ev_nominal_charging_power').value = JSON.stringify(evConf.ev_nominal_charging_power || [11000]);
            document.getElementById('ev_minimum_charging_power').value = JSON.stringify(evConf.ev_minimum_charging_power || [1380]);
            document.getElementById('ev_consumption_efficiency').value = JSON.stringify(evConf.ev_consumption_efficiency || [0.2]);
        }
    }

    // Function to collect EV configuration data
    function collectEVConfiguration() {
        const evConfig = {
            number_of_ev_loads: parseInt(document.getElementById('number_of_ev_loads').value),
            ev_battery_capacity: JSON.parse(document.getElementById('ev_battery_capacity').value || '[75000]'),
            ev_charging_efficiency: JSON.parse(document.getElementById('ev_charging_efficiency').value || '[0.9]'),
            ev_nominal_charging_power: JSON.parse(document.getElementById('ev_nominal_charging_power').value || '[11000]'),
            ev_minimum_charging_power: JSON.parse(document.getElementById('ev_minimum_charging_power').value || '[1380]'),
            ev_consumption_efficiency: JSON.parse(document.getElementById('ev_consumption_efficiency').value || '[0.2]')
        };
        
        return evConfig;
    }

    // Hook into the configuration save process
    function hookConfigurationSave() {
        // Find save buttons and hook into their click events
        const saveButtons = document.querySelectorAll('button[type="submit"], .save-button, .btn-save');
        
        saveButtons.forEach(button => {
            button.addEventListener('click', function(e) {
                try {
                    const evConfig = collectEVConfiguration();
                    
                    // Add EV configuration to the main config object
                    if (window.configData && window.configData.params) {
                        window.configData.params.ev_conf = evConfig;
                    }
                    
                    console.log('EV Configuration collected:', evConfig);
                } catch (error) {
                    console.error('Error collecting EV configuration:', error);
                }
            });
        });
    }

    // Initialize EV configuration extension
    function initEVConfig() {
        // Wait for DOM to be ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                setTimeout(injectEVConfig, 500);
                setTimeout(hookConfigurationSave, 1000);
            });
        } else {
            setTimeout(injectEVConfig, 500);
            setTimeout(hookConfigurationSave, 1000);
        }
    }

    // Start the initialization
    initEVConfig();

    console.log('EMHASS EV Configuration Extension loaded');
})();