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

# Try to find the correct Python executable
if command -v python3 >/dev/null 2>&1; then
    echo "Using python3"
    exec python3 -m emhass.web_server --port "${EMHASS_PORT}"
elif command -v python >/dev/null 2>&1; then
    echo "Using python"
    exec python -m emhass.web_server --port "${EMHASS_PORT}"
elif command -v /usr/local/bin/python3 >/dev/null 2>&1; then
    echo "Using /usr/local/bin/python3"
    exec /usr/local/bin/python3 -m emhass.web_server --port "${EMHASS_PORT}"
else
    echo "🔍 Searching for Python executable..."
    find /usr -name "python*" -type f 2>/dev/null | head -5
    echo "Available in PATH:"
    which python python3 2>/dev/null || echo "No python found in PATH"
    echo "❌ No Python executable found!"
    exit 1
fi