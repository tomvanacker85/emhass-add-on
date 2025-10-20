#!/bin/bash
set -e

# EMHASS EV Extension Run Script

echo "🚗 Starting EMHASS EV Extension..."

# Set up configuration paths
CONFIG_PATH="/share/emhass-ev"
mkdir -p "${CONFIG_PATH}"

# Read Home Assistant add-on options
if [ -f "/data/options.json" ]; then
    echo "📝 Reading add-on configuration..."

    # Extract configuration values
    CONFIG_ENTRIES=$(jq -r 'to_entries[] | "\(.key)=\(.value)"' /data/options.json)

    # Export as environment variables for EMHASS
    while IFS='=' read -r key value; do
        export "EMHASS_${key^^}"="${value}"
    done <<< "$CONFIG_ENTRIES"
fi

# Set default port if not specified
export EMHASS_PORT="${EMHASS_PORT:-5001}"

echo "🔧 Configuration loaded"
echo "📡 Port: ${EMHASS_PORT}"
echo "📁 Config path: ${CONFIG_PATH}"

# Change to EMHASS source directory
cd /app/emhass-source

# Start EMHASS web server
echo "🚀 Starting EMHASS EV web server..."
exec python3 -m emhass.web_server