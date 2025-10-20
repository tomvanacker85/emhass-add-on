#!/bin/bash
# Quick setup script for testing EMHASS EV Extension locally

set -e

echo "🚗 Setting up EMHASS EV Extension Local Testing Environment"

# Create testing directories
echo "📁 Creating directories..."
mkdir -p ~/ha-test/{config,addons,share,ssl,media}
mkdir -p ~/ha-test/config/addons/emhass-ev

# Copy add-on files
echo "📋 Copying add-on files..."
cp -r /workspaces/emhass-add-on/* ~/ha-test/config/addons/emhass-ev/

# Create basic Home Assistant configuration
echo "⚙️ Creating basic HA configuration..."
cat > ~/ha-test/config/configuration.yaml << 'EOF'
# Basic Home Assistant Configuration for EMHASS EV Testing

default_config:

# Enable REST sensors for EMHASS
sensor:
  - platform: rest
    name: "EMHASS EV Forecast"
    resource: "http://localhost:5000/action/dayahead-optim"
    method: POST
    headers:
      Content-Type: application/json
    payload: >
      {
        "prediction_horizon": 24,
        "ev_availability": [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1]],
        "ev_minimum_soc_schedule": [[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]],
        "ev_initial_soc": [0.2]
      }
    value_template: "{{ value_json.status if value_json.status is defined else 'unknown' }}"
    json_attributes_path: "$.optim_status"
    json_attributes:
      - P_EV0
      - SOC_EV0
      - P_deferrable0
      - P_grid
    scan_interval: 3600
    timeout: 300

# Test automation for EV charging
automation:
  - id: 'ev_charging_update'
    alias: 'EV Charging Schedule Update'
    description: 'React to new EV charging optimization'
    trigger:
      - platform: state
        entity_id: sensor.emhass_ev_forecast
    action:
      - service: persistent_notification.create
        data:
          title: "🚗 EV Charging Update"
          message: >
            New EV charging schedule received!
            Next hour power: {{ state_attr('sensor.emhass_ev_forecast', 'P_EV0')[0] if state_attr('sensor.emhass_ev_forecast', 'P_EV0') else 'N/A' }}W
            Current SOC: {{ state_attr('sensor.emhass_ev_forecast', 'SOC_EV0')[0] if state_attr('sensor.emhass_ev_forecast', 'SOC_EV0') else 'N/A' }}

# REST commands for manual testing
rest_command:
  emhass_dayahead:
    url: "http://localhost:5000/action/dayahead-optim"
    method: POST
    headers:
      Content-Type: "application/json"
    payload: >
      {
        "ev_availability": {{ ev_availability | default('[[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1]]') }},
        "ev_minimum_soc_schedule": {{ ev_min_soc | default('[[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]]') }},
        "ev_initial_soc": {{ ev_initial_soc | default('[0.2]') }}
      }
EOF

# Create automations.yaml
cat > ~/ha-test/config/automations.yaml << 'EOF'
[]
EOF

# Create scripts.yaml for manual testing
cat > ~/ha-test/config/scripts.yaml << 'EOF'
test_ev_optimization:
  alias: "Test EV Optimization"
  sequence:
    - service: rest_command.emhass_dayahead
      data:
        ev_availability: "[[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1]]"
        ev_min_soc: "[[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]]"
        ev_initial_soc: "[0.15]"
    - service: persistent_notification.create
      data:
        title: "EV Test Triggered"
        message: "EV optimization test has been triggered. Check sensor.emhass_ev_forecast for results."

test_ev_weekend:
  alias: "Test EV Weekend Schedule"
  sequence:
    - service: rest_command.emhass_dayahead
      data:
        ev_availability: "[[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]"
        ev_min_soc: "[[0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6,0.6]]"
        ev_initial_soc: "[0.3]"
EOF

echo "🐳 Starting Home Assistant container..."
# Stop existing container if running
docker stop homeassistant-test 2>/dev/null || true
docker rm homeassistant-test 2>/dev/null || true

# Start Home Assistant
docker run -d \
  --name homeassistant-test \
  --privileged \
  --restart=unless-stopped \
  -e TZ=Europe/Brussels \
  -v ~/ha-test/config:/config \
  -v /run/dbus:/run/dbus:ro \
  -p 8123:8123 \
  ghcr.io/home-assistant/home-assistant:stable

echo "⏳ Waiting for Home Assistant to start..."
sleep 10

# Show status
echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Wait for Home Assistant to fully start (check logs below)"
echo "2. Open http://localhost:8123 in your browser"
echo "3. Complete the initial setup wizard"
echo "4. Go to Settings → Add-ons → Local Add-ons"
echo "5. Install 'EMHASS EV Extension'"
echo "6. Configure EV parameters in the add-on"
echo "7. Test with Developer Tools → Services → script.test_ev_optimization"
echo ""
echo "📊 Monitoring commands:"
echo "  Home Assistant logs: docker logs -f homeassistant-test"
echo "  EMHASS add-on logs:  docker logs -f addon_emhass-ev (after installation)"
echo "  Stop HA:             docker stop homeassistant-test"
echo ""

echo "🔍 Home Assistant startup logs:"
docker logs -f homeassistant-test