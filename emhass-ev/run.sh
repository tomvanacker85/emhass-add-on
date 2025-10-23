#!/bin/bash
set -e

# EMHASS EV Extension Run Script

echo "🚗 Starting EMHASS EV Extension v1.3.3..."

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

# Set up EV configuration defaults
if [ ! -f "${CONFIG_PATH}/config.json" ]; then
    echo "📝 Creating EV configuration defaults..."

    # Copy EV-specific config defaults if available
    if [ -f "/app/config_defaults_ev.json" ]; then
        cp /app/config_defaults_ev.json "${CONFIG_PATH}/config.json"
        echo "✅ EV configuration defaults created"
    fi
fi

# Apply DST fixes (PR601 equivalent) before starting EMHASS
echo "🕐 Applying DST timezone fixes..."

# Try shell script version first (most reliable)
if [ -f "/app/fix_dst_issues.sh" ]; then
    echo "📍 Using enhanced shell script DST fix"
    /app/fix_dst_issues.sh
elif [ -f "/app/fix_dst_issues.py" ]; then
    echo "📍 Using Python script DST fix"
    # Use the virtual environment Python from EMHASS container
    if [ -f "/app/.venv/bin/python" ]; then
        echo "📍 Using venv Python: /app/.venv/bin/python"
        /app/.venv/bin/python /app/fix_dst_issues.py
    elif command -v uv >/dev/null 2>&1; then
        echo "📍 Using uv run Python"
        cd /app && uv run python fix_dst_issues.py
    elif command -v python3 >/dev/null 2>&1; then
        echo "📍 Using system Python3"
        python3 /app/fix_dst_issues.py
    else
        echo "⚠️ Python not found - skipping Python DST fixes"
    fi
else
    echo "⚠️ No DST fix scripts found"
fi

# Apply emergency DST fix for stubborn cases
if [ -f "/app/fix_dst_emergency.sh" ]; then
    echo "🚨 Applying emergency DST fix for AmbiguousTimeError"
    /app/fix_dst_emergency.sh
fi

echo "ℹ️ DST fixes complete - EMHASS should handle timezone transitions"

# Set up EV web interface with enhanced form and YAML support
echo "🌐 Setting up Enhanced EV configuration..."
if [ -f "/app/setup_ev_enhanced.sh" ]; then
    chmod +x /app/setup_ev_enhanced.sh
    /app/setup_ev_enhanced.sh
fi

echo "🔧 EV Extension configuration loaded"
echo "📡 Port: ${EMHASS_PORT}"
echo "📁 Config path: ${CONFIG_PATH}"

# Find and start EMHASS using the original approach
echo "🚀 Starting EMHASS EV web server..."

# Check if uv is available (the proper way to run EMHASS)
if command -v uv >/dev/null 2>&1; then
    echo "✅ Found uv package manager"

    # Set up the proper environment variables for EMHASS
    export EMHASS_HOST="0.0.0.0"
    export EMHASS_PORT="${EMHASS_PORT:-5003}"
    export EMHASS_CONFIG_PATH="${EMHASS_CONFIG_PATH:-/share/emhass-ev}"
    export EMHASS_DATA_PATH="${EMHASS_DATA_PATH:-/share/emhass-ev}"

    echo "🔧 Starting EMHASS EV web server on port $EMHASS_PORT..."

    # Use the same command as the original EMHASS image but with EV-specific settings
    cd /app
    exec uv run --frozen gunicorn "emhass.web_server:create_app()" --bind "0.0.0.0:${EMHASS_PORT}" --workers 1 --timeout 120
else
    echo "❌ uv package manager not found"

    # Try to use the original EMHASS startup script if it exists
    if [ -f "/usr/bin/run.sh" ]; then
        echo "Using original EMHASS run script"
        exec /usr/bin/run.sh
    elif [ -f "/app/run.sh" ]; then
        echo "Using app run script"
        exec /app/run.sh
    else
        # Fallback: try to start EMHASS directly with various methods
        echo "Starting EMHASS directly..."

        # Check what's available
        echo "🔍 Available EMHASS executables:"
        find /usr -name "*emhass*" -type f 2>/dev/null | head -3
        find /app -name "*emhass*" -type f 2>/dev/null | head -3

        # Try different startup methods
        if [ -f "/usr/local/bin/python3" ]; then
            echo "Trying Python3 module execution..."
            cd /app 2>/dev/null || cd /
            exec /usr/local/bin/python3 -m emhass.web_server --port "${EMHASS_PORT}"
        elif [ -f "/usr/bin/python3" ]; then
            echo "Trying system Python3..."
            cd /app 2>/dev/null || cd /
            exec /usr/bin/python3 -m emhass.web_server --port "${EMHASS_PORT}"
        else
            echo "❌ Could not find Python3 to start EMHASS"
            echo "Available Python executables:"
            find /usr -name "python*" -executable -type f 2>/dev/null
            exit 1
        fi
    fi
fi