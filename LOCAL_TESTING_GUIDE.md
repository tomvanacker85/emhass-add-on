# Local Home Assistant Testing Guide for EMHASS EV Extension

## 🚀 Quick Start - Home Assistant Container Method

### Step 1: Prepare Your Modified EMHASS

```bash
# In your current workspace
cd /workspaces/emhass

# Build a Docker image with your EV extension
docker build -t emhass-ev:latest .
```

### Step 2: Set Up Home Assistant Container

```bash
# Create directories for Home Assistant
mkdir -p ~/ha-test/{config,addons,share,ssl,media}

# Run Home Assistant in container
docker run -d \
  --name homeassistant-test \
  --privileged \
  --restart=unless-stopped \
  -e TZ=Europe/Brussels \
  -v ~/ha-test/config:/config \
  -v /run/dbus:/run/dbus:ro \
  --network=host \
  ghcr.io/home-assistant/home-assistant:stable
```

### Step 3: Install EMHASS Add-on with EV Extension

```bash
# Clone your add-on repository
cd ~/ha-test/config
mkdir -p addons/emhass-ev
cd addons/emhass-ev

# Copy your modified add-on files
cp -r /workspaces/emhass-add-on/* .

# Modify the add-on to use your custom EMHASS image
```

## 📝 Configuration Files You'll Need

Create these files in `~/ha-test/config/`:

### `configuration.yaml`

```yaml
# Enable the frontend
default_config:

# Enable add-ons
hassio:

# EMHASS integration
sensor:
  - platform: rest
    name: "EMHASS Forecast"
    resource: "http://localhost:5000/action/dayahead-optim"
    method: POST
    headers:
      Content-Type: application/json
    payload: >
      {
        "ev_availability": [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1]],
        "ev_minimum_soc_schedule": [[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]],
        "ev_initial_soc": [0.2]
      }
    value_template: "{{ value_json.status }}"
    json_attributes:
      - P_EV0
      - SOC_EV0
      - P_deferrable0
    scan_interval: 3600
```

### `automations.yaml`

```yaml
- id: "1234567890"
  alias: EV Charging Schedule
  description: "Update EV charging based on EMHASS optimization"
  trigger:
    - platform: state
      entity_id: sensor.emhass_forecast
  action:
    - service: notify.persistent_notification
      data:
        title: "EV Charging Update"
        message: "New EV charging schedule received: {{ state_attr('sensor.emhass_forecast', 'P_EV0') }}"
```

## 🔧 Modify Your Add-on for Testing

### Update `emhass/Dockerfile`

```dockerfile
FROM your-registry/emhass-ev:latest

# Copy your modified EMHASS source
COPY --from=emhass-source /workspaces/emhass/src /usr/local/lib/python3.11/site-packages/

# Rest of your existing Dockerfile...
```

### Update `emhass/config.yml`

```yaml
name: "EMHASS EV Extension"
description: "Energy Management for Home Assistant with EV Charging"
version: "0.14.0-ev"
slug: "emhass-ev"
init: false
arch:
  - armhf
  - armv7
  - aarch64
  - amd64
  - i386
startup: services
# ... rest of your existing config with EV parameters
```

## 🧪 Testing Steps

### 1. Start Home Assistant

```bash
# Check if HA is running
docker logs homeassistant-test -f

# Access HA at http://localhost:8123
```

### 2. Install Your EV Add-on

- Go to Supervisor → Add-on Store → Local Add-ons
- Install "EMHASS EV Extension"
- Configure EV parameters in the add-on configuration

### 3. Test EV Configuration

```yaml
# In add-on configuration UI
number_of_ev_loads: 1
ev_battery_capacity: "[60000]"
ev_charging_efficiency: "[0.9]"
ev_nominal_charging_power: "[7400]"
ev_minimum_charging_power: "[1380]"
```

### 4. Test API Calls

```bash
# Test basic health
curl http://localhost:5000/

# Test EV optimization
curl -X POST http://localhost:5000/action/dayahead-optim \
  -H "Content-Type: application/json" \
  -d '{
    "ev_availability": [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1]],
    "ev_minimum_soc_schedule": [[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]],
    "ev_initial_soc": [0.2]
  }'
```

## 🎯 What to Look For

### Success Indicators:

✅ Add-on starts without errors
✅ API responds with EV power schedule (`P_EV0`)
✅ API responds with EV SOC profile (`SOC_EV0`)
✅ Optimization completes in reasonable time
✅ EV constraints are respected (availability, min SOC)

### Debugging:

```bash
# Check add-on logs
docker logs addon_emhass-ev

# Check Home Assistant logs
docker logs homeassistant-test

# Test EMHASS directly
docker exec -it addon_emhass-ev python3 -c "
from emhass.optimization import Optimization
print('EV extension loaded successfully!')
"
```

## 🚀 Next Steps After Local Testing

### 1. Production Deployment

- Push your changes to GitHub
- Update your production Home Assistant instance
- Monitor performance and optimization results

### 2. Integration with Real EV Charger

```yaml
# Example: Integrate with Wallbox charger
switch:
  - platform: rest
    name: "EV Charger Control"
    resource: "http://your-charger-ip/api/control"
    body_on: '{"power": "{{ states.sensor.emhass_forecast.attributes.P_EV0[now().hour] }}"}'
    body_off: '{"power": 0}'
```

### 3. Advanced Automation

```yaml
# Dynamic EV availability based on presence
automation:
  - alias: "Update EV Availability"
    trigger:
      - platform: state
        entity_id: device_tracker.ev_location
    action:
      - service: rest_command.update_emhass_ev
        data:
          ev_availability: >
            {% if states('device_tracker.ev_location') == 'home' %}
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
            {% else %}
            [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            {% endif %}
```

Would you like me to help you set up any specific part of this testing environment?
