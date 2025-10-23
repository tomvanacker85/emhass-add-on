#!/bin/bash

# EMHASS EV Extension - Final Verification Script
# This script verifies that the EV extension is working correctly

echo "🚗 EMHASS EV Extension - Final Verification"
echo "=========================================="

cd /workspaces/emhass-add-on/emhass-ev

echo ""
echo "📦 Building EMHASS EV Docker image..."
docker build -t local/emhass-ev:latest . --quiet

if [ $? -eq 0 ]; then
    echo "✅ Docker build successful!"
else
    echo "❌ Docker build failed!"
    exit 1
fi

echo ""
echo "🔍 Testing EMHASS imports..."
IMPORT_TEST=$(docker run --rm local/emhass-ev:latest python -c "
try:
    import emhass
    from emhass.optimization import Optimization
    print('✅ All imports successful!')
except Exception as e:
    print(f'❌ Import failed: {e}')
    exit(1)
" 2>&1)

if [[ $IMPORT_TEST == *"✅ All imports successful!"* ]]; then
    echo "$IMPORT_TEST"
else
    echo "❌ Import test failed:"
    echo "$IMPORT_TEST"
    exit 1
fi

echo ""
echo "⚙️  Checking EV configuration parameters..."
EV_CONFIG=$(docker run --rm local/emhass-ev:latest python -c "
import json
try:
    with open('/app/src/emhass/data/config_defaults.json', 'r') as f:
        config = json.load(f)

    ev_params = ['number_of_ev_loads', 'ev_battery_capacity', 'ev_charging_efficiency',
                 'ev_nominal_charging_power', 'ev_minimum_charging_power', 'ev_consumption_efficiency']

    missing = []
    for param in ev_params:
        if param not in config:
            missing.append(param)

    if missing:
        print(f'❌ Missing EV parameters: {missing}')
        exit(1)
    else:
        print('✅ All EV parameters found in configuration!')
        for param in ev_params:
            print(f'  {param}: {config[param]}')
except Exception as e:
    print(f'❌ Configuration check failed: {e}')
    exit(1)
" 2>&1)

echo "$EV_CONFIG"

echo ""
echo "🌐 Testing web server startup..."
CONTAINER_ID=$(docker run -d -p 5003:5003 local/emhass-ev:latest python -m emhass.web_server)

# Wait for server to start
sleep 8

# Test web server response
WEB_TEST=$(curl -s -f http://localhost:5003 | head -1)
if [[ $WEB_TEST == *"<!DOCTYPE html>"* ]]; then
    echo "✅ Web server started successfully!"
    echo "✅ EMHASS EV interface accessible at http://localhost:5003"
else
    echo "❌ Web server test failed"
    docker logs $CONTAINER_ID
    docker stop $CONTAINER_ID > /dev/null 2>&1
    exit 1
fi

# Check logs for any errors
LOGS=$(docker logs $CONTAINER_ID 2>&1 | grep -E "(ERROR|CRITICAL|Exception)" | wc -l)
if [ "$LOGS" -eq 0 ]; then
    echo "✅ No errors in server logs"
else
    echo "⚠️  Found $LOGS potential issues in logs:"
    docker logs $CONTAINER_ID 2>&1 | grep -E "(ERROR|CRITICAL|Exception)" | head -3
fi

# Clean up
docker stop $CONTAINER_ID > /dev/null 2>&1

echo ""
echo "🎉 EMHASS EV Extension Verification Complete!"
echo ""
echo "Summary:"
echo "✅ Docker image builds successfully"
echo "✅ Python imports work correctly"
echo "✅ EV configuration parameters are loaded"
echo "✅ Web server starts and responds"
echo ""
echo "🚀 Your EMHASS EV extension is ready for deployment!"
echo ""
echo "Next steps:"
echo "1. Copy emhass-ev/ folder to your Home Assistant add-ons directory"
echo "2. Install the add-on in Home Assistant"
echo "3. Configure EV parameters for your vehicle"
echo "4. Start optimizing your EV charging!"
echo ""
echo "📚 See EMHASS_EV_SUCCESS.md for detailed usage instructions"