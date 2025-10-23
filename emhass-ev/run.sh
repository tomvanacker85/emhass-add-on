#!/bin/bash
set -e

# EMHASS EV Extension Run Script

echo "🚗 Starting EMHASS EV Extension v1.0.9..."

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

# Find and start EMHASS using the original approach
echo "🚀 Starting EMHASS EV web server..."

# Try to use the original EMHASS startup script if it exists
if [ -f "/usr/bin/run.sh" ]; then
    echo "Using original EMHASS run script"
    exec /usr/bin/run.sh
elif [ -f "/app/run.sh" ]; then
    echo "Using app run script"
    exec /app/run.sh
else
    # Fallback: try to start EMHASS directly
    echo "Starting EMHASS directly..."
    cd /app 2>/dev/null || cd /
    exec emhass --action web-server --port "${EMHASS_PORT}" 2>/dev/null || \
    exec /usr/local/bin/emhass --action web-server --port "${EMHASS_PORT}" 2>/dev/null || \
    echo "❌ Could not start EMHASS web server"
fi