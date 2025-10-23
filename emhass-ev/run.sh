#!/bin/bash
set -e

# EMHASS EV Extension Run Script

echo "🚗 Starting EMHASS EV Extension v1.0.4..."

# Set up configuration paths for EV extension
CONFIG_PATH="/share/emhass-ev"
echo "📁 Creating EV data directory: ${CONFIG_PATH}"
mkdir -p "${CONFIG_PATH}"

# Read Home Assistant add-on options
if [ -f "/data/options.json" ]; then
    echo "📝 Reading EV add-on configuration..."

    # Extract configuration values
    CONFIG_ENTRIES=$(jq -r 'to_entries[] | "\(.key)=\(.value)"' /data/options.json)

    # Export as environment variables for EMHASS
    while IFS='=' read -r key value; do
        export "EMHASS_${key^^}"="${value}"
    done <<< "$CONFIG_ENTRIES"
fi

# Set EV extension specific defaults
export EMHASS_PORT="${EMHASS_PORT:-5003}"
export EMHASS_CONFIG_PATH="${CONFIG_PATH}"
export EMHASS_DATA_PATH="${CONFIG_PATH}"

echo "🔧 EV Extension configuration loaded"
echo "📡 Port: ${EMHASS_PORT}"
echo "📁 Config path: ${CONFIG_PATH}"

# Start EMHASS with EV extension
echo "🚀 Starting EMHASS EV web server..."
exec python3 -m emhass.web_server --port "${EMHASS_PORT}"