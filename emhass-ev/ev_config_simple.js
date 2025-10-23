// Simplified EV Configuration Interface
// This script creates a configuration interface that works with the EMHASS configuration system

(function() {
    'use strict';
    
    // EV Configuration Panel HTML
    const evConfigPanelHTML = `
        <div id="ev-config-panel" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 10000;">
            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 30px; border-radius: 12px; max-width: 600px; max-height: 80vh; overflow-y: auto; box-shadow: 0 8px 32px rgba(0,0,0,0.2);">
                <h2 style="margin-top: 0; color: #2c5aa0; border-bottom: 2px solid #4a90e2; padding-bottom: 10px;">🚗 EV Configuration</h2>
                
                <div style="margin-bottom: 20px; padding: 12px; background: #e8f5e8; border-radius: 6px; border-left: 4px solid #4a90e2;">
                    <strong>Configure your Electric Vehicle parameters for optimal charging schedule optimization.</strong>
                </div>
                
                <form id="ev-config-form">
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Number of EV Loads:</label>
                        <input type="number" id="number_of_ev_loads" min="0" max="5" value="1" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <small style="color: #666;">Number of electric vehicles to optimize (0 = disabled)</small>
                    </div>
                    
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Battery Capacity (Wh):</label>
                        <input type="text" id="ev_battery_capacity" value="[75000]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <small style="color: #666;">Battery capacity in Wh for each EV (e.g., [75000] for 75 kWh)</small>
                    </div>
                    
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Charging Efficiency:</label>
                        <input type="text" id="ev_charging_efficiency" value="[0.9]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <small style="color: #666;">Charging efficiency (0-1) for each EV (e.g., [0.9] for 90%)</small>
                    </div>
                    
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Nominal Charging Power (W):</label>
                        <input type="text" id="ev_nominal_charging_power" value="[11000]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <small style="color: #666;">Maximum charging power in W for each EV (e.g., [11000] for 11 kW)</small>
                    </div>
                    
                    <div style="margin-bottom: 15px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Minimum Charging Power (W):</label>
                        <input type="text" id="ev_minimum_charging_power" value="[1380]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <small style="color: #666;">Minimum charging power in W for each EV (e.g., [1380])</small>
                    </div>
                    
                    <div style="margin-bottom: 20px;">
                        <label style="display: block; font-weight: bold; margin-bottom: 5px;">Consumption Efficiency (kWh/km):</label>
                        <input type="text" id="ev_consumption_efficiency" value="[0.2]" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                        <small style="color: #666;">Energy consumption in kWh per km (e.g., [0.2] for 0.2 kWh/km)</small>
                    </div>
                    
                    <div style="background: #f8f9fa; padding: 15px; border-radius: 6px; margin-bottom: 20px;">
                        <h4 style="margin-top: 0;">💡 Configuration Tips:</h4>
                        <ul style="margin-bottom: 0; padding-left: 20px;">
                            <li><strong>Battery Capacity:</strong> Use Wh units (e.g., 75 kWh = 75000 Wh)</li>
                            <li><strong>Charging Power:</strong> Check your charger specifications (3.7kW, 7.4kW, 11kW, 22kW)</li>
                            <li><strong>Consumption:</strong> Typical values: 0.15-0.25 kWh/km depending on EV model</li>
                            <li><strong>Multiple EVs:</strong> Use arrays like [75000, 60000] for two different EVs</li>
                        </ul>
                    </div>
                    
                    <div style="display: flex; gap: 10px; justify-content: flex-end;">
                        <button type="button" id="cancel-ev-config" style="padding: 10px 20px; border: 1px solid #ddd; background: #f8f9fa; border-radius: 4px; cursor: pointer;">Cancel</button>
                        <button type="submit" style="padding: 10px 20px; border: none; background: #4a90e2; color: white; border-radius: 4px; cursor: pointer;">Save EV Configuration</button>
                    </div>
                </form>
            </div>
        </div>
    `;
    
    // Add EV Configuration button to the page
    function addEVConfigButton() {
        // Find a suitable place to add the button
        const targetElements = [
            document.querySelector('.navbar'),
            document.querySelector('.header'),
            document.querySelector('body > div:first-child'),
            document.querySelector('main'),
            document.body
        ];
        
        for (const target of targetElements) {
            if (target) {
                const evButton = document.createElement('button');
                evButton.innerHTML = '🚗 EV Configuration';
                evButton.style.cssText = `
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    background: linear-gradient(135deg, #4a90e2, #6bb6ff);
                    color: white;
                    border: none;
                    padding: 12px 20px;
                    border-radius: 25px;
                    cursor: pointer;
                    font-weight: bold;
                    box-shadow: 0 4px 12px rgba(74, 144, 226, 0.3);
                    z-index: 1000;
                    transition: transform 0.2s;
                `;
                
                evButton.onmouseover = function() {
                    this.style.transform = 'scale(1.05)';
                };
                evButton.onmouseout = function() {
                    this.style.transform = 'scale(1)';
                };
                
                evButton.onclick = function() {
                    showEVConfigPanel();
                };
                
                target.appendChild(evButton);
                break;
            }
        }
    }
    
    // Show EV configuration panel
    function showEVConfigPanel() {
        // Add panel to page if not already present
        if (!document.getElementById('ev-config-panel')) {
            document.body.insertAdjacentHTML('beforeend', evConfigPanelHTML);
            
            // Add event listeners
            document.getElementById('cancel-ev-config').onclick = function() {
                document.getElementById('ev-config-panel').style.display = 'none';
            };
            
            document.getElementById('ev-config-form').onsubmit = function(e) {
                e.preventDefault();
                saveEVConfiguration();
            };
            
            // Load current configuration
            loadCurrentEVConfig();
        }
        
        document.getElementById('ev-config-panel').style.display = 'block';
    }
    
    // Load current EV configuration
    function loadCurrentEVConfig() {
        fetch('/config')
            .then(response => response.json())
            .then(data => {
                if (data.params && data.params.ev_conf) {
                    const evConf = data.params.ev_conf;
                    document.getElementById('number_of_ev_loads').value = evConf.number_of_ev_loads || 1;
                    document.getElementById('ev_battery_capacity').value = JSON.stringify(evConf.ev_battery_capacity || [75000]);
                    document.getElementById('ev_charging_efficiency').value = JSON.stringify(evConf.ev_charging_efficiency || [0.9]);
                    document.getElementById('ev_nominal_charging_power').value = JSON.stringify(evConf.ev_nominal_charging_power || [11000]);
                    document.getElementById('ev_minimum_charging_power').value = JSON.stringify(evConf.ev_minimum_charging_power || [1380]);
                    document.getElementById('ev_consumption_efficiency').value = JSON.stringify(evConf.ev_consumption_efficiency || [0.2]);
                }
            })
            .catch(error => {
                console.log('Could not load current config, using defaults:', error);
            });
    }
    
    // Save EV configuration
    function saveEVConfiguration() {
        try {
            const evConfig = {
                number_of_ev_loads: parseInt(document.getElementById('number_of_ev_loads').value),
                ev_battery_capacity: JSON.parse(document.getElementById('ev_battery_capacity').value),
                ev_charging_efficiency: JSON.parse(document.getElementById('ev_charging_efficiency').value),
                ev_nominal_charging_power: JSON.parse(document.getElementById('ev_nominal_charging_power').value),
                ev_minimum_charging_power: JSON.parse(document.getElementById('ev_minimum_charging_power').value),
                ev_consumption_efficiency: JSON.parse(document.getElementById('ev_consumption_efficiency').value)
            };
            
            // Get current config and update with EV parameters
            fetch('/config')
                .then(response => response.json())
                .then(currentConfig => {
                    // Update the config with EV parameters
                    if (!currentConfig.params) currentConfig.params = {};
                    currentConfig.params.ev_conf = evConfig;
                    
                    // Save the updated configuration
                    return fetch('/save-config', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(currentConfig)
                    });
                })
                .then(response => {
                    if (response.ok) {
                        alert('EV Configuration saved successfully!');
                        document.getElementById('ev-config-panel').style.display = 'none';
                    } else {
                        throw new Error('Failed to save configuration');
                    }
                })
                .catch(error => {
                    console.error('Error saving EV configuration:', error);
                    alert('Failed to save EV configuration. Please try again.');
                });
                
        } catch (error) {
            console.error('Error parsing EV configuration:', error);
            alert('Please check your configuration values. Arrays should be in JSON format like [75000].');
        }
    }
    
    // Initialize the EV configuration interface
    function initEVConfigInterface() {
        // Wait for page to load
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', function() {
                setTimeout(addEVConfigButton, 1000);
            });
        } else {
            setTimeout(addEVConfigButton, 1000);
        }
    }
    
    // Start initialization
    initEVConfigInterface();
    
    console.log('EMHASS EV Configuration Interface loaded');
})();