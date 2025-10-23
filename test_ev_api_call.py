#!/usr/bin/env python3
"""
Quick test to verify EV API is working with your Home Assistant add-on
"""

import requests
import json

# Update this with your Home Assistant IP and EV add-on port
EMHASS_EV_URL = "http://localhost:5003"  # Adjust to your HA IP and EV port

def test_ev_api():
    """Test if EV parameters are accepted by the API"""

    # EV test data: Daily commuter scenario
    ev_data = {
        # EV availability: connected 6PM-8AM (plugged in at home)
        "ev_availability": [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1]],

        # Minimum SOC: need 80% by 7AM for work commute
        "ev_minimum_soc_schedule": [[0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8]],

        # Initial SOC: currently at 20%
        "ev_initial_soc": [0.2]
    }

    print("🚗 Testing EMHASS EV API...")
    print(f"URL: {EMHASS_EV_URL}")

    # Test 1: Check if the service is running
    try:
        response = requests.get(f"{EMHASS_EV_URL}/", timeout=10)
        print(f"✅ EV service is running (status: {response.status_code})")
    except requests.exceptions.RequestException as e:
        print(f"❌ Cannot reach EV service: {e}")
        print("\n💡 Troubleshooting:")
        print("1. Check if EMHASS EV add-on is started in Home Assistant")
        print("2. Verify the correct IP and port")
        print("3. Try accessing the web interface first")
        return False

    # Test 2: Send day-ahead optimization with EV data
    try:
        print("\n📊 Sending EV optimization request...")

        response = requests.post(
            f"{EMHASS_EV_URL}/action/dayahead-optim",
            json=ev_data,
            timeout=30
        )

        if response.status_code == 200:
            result = response.json()
            print("✅ EV optimization successful!")

            # Look for EV-specific results
            if 'P_EV0' in str(result):
                print("✅ EV power schedule (P_EV0) found in results!")
            if 'SOC_EV0' in str(result):
                print("✅ EV SOC schedule (SOC_EV0) found in results!")

            print(f"\n📋 Result keys: {list(result.keys()) if isinstance(result, dict) else 'Not a dict'}")

        else:
            print(f"❌ Optimization failed (status: {response.status_code})")
            print(f"Response: {response.text[:200]}...")

    except requests.exceptions.RequestException as e:
        print(f"❌ API call failed: {e}")
        return False

    return True

if __name__ == "__main__":
    print("EMHASS EV API Test")
    print("=" * 50)

    success = test_ev_api()

    print("\n" + "=" * 50)
    if success:
        print("🎉 EV extension is working! You can now:")
        print("  • Create automations with EV data")
        print("  • Pass availability and SOC schedules")
        print("  • Get optimized EV charging plans")
    else:
        print("🔧 Next steps:")
        print("  • Ensure EV add-on is configured and started")
        print("  • Check the web interface for EV options")
        print("  • Verify EV parameters in add-on configuration")