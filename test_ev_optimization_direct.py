#!/usr/bin/env python3
"""
Direct test of EV optimization without Home Assistant connectivity
"""
import numpy as np
import pandas as pd
import requests
import json
from datetime import datetime, timedelta

def test_direct_optimization():
    """Test EV optimization by directly calling the optimization endpoint"""

    print("🚗 Direct EV Optimization Test")
    print("=" * 50)

    # Prepare EV configuration data (48 timesteps = 30-minute intervals for 24 hours)
    ev_config = {
        "prediction_horizon": 48,  # 24 hours in 30-minute steps
        "costfun": "cost",
        "set_use_battery": False,  # Disable battery to simplify
        "set_total_pv_sell": False,
        "delta_forecast": 1,

        # Bypass Home Assistant
        "hass_url": "empty",
        "hass_token": "empty",

        # EV Configuration
        "number_of_ev_loads": 1,
        "ev_battery_capacity": [60000],  # 60 kWh in Wh
        "ev_charging_efficiency": [0.9],
        "ev_nominal_charging_power": [7400],  # 7.4 kW
        "ev_minimum_charging_power": [1380],  # 1.38 kW

        # EV runtime parameters - the arrays you requested! (48 values for 30-min intervals)
        "ev_availability": [
            # Connected 20/24 hours (00:00-14:00 and 18:00-24:00)
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1]
        ],
        "ev_minimum_soc_schedule": [
            # 20% until 7AM, then 80% required
            [0.2]*14 + [0.8]*34  # 14 intervals until 7AM, then 80%
        ],
        "ev_initial_soc": [0.2],  # Start at 20%
        "ev_distance_forecast": [  # Kilometers driven each 30-min interval
            [0]*14 + [7.5,5,2.5,0,0,0,0,0]*4 + [5,5,0,0] + [0]*4  # Driving during day, 48 values total
        ],

        # Simplified forecasts (48 timesteps for 30-minute intervals)
        "pv_power_forecast": [0]*12 + [100,200,500,800,1500,2000,3000,4000,4500,4500,4000,3000,2000,1500,1000,500,200,100] + [0]*18,
        "load_power_forecast": [1500] * 48,  # Constant 1.5 kW load
        "load_cost_forecast": [0.15]*16 + [0.25]*24 + [0.15]*8,  # Peak hours 8AM-8PM
        "prod_price_forecast": [0.10] * 48,  # Constant feed-in price
    }

    print(f"📊 Test Configuration:")
    print(f"   🔋 EV Battery: {ev_config['ev_battery_capacity'][0]/1000:.1f} kWh")
    print(f"   ⚡ Max Power: {ev_config['ev_nominal_charging_power'][0]/1000:.1f} kW")
    print(f"   🔌 Connected: {sum(ev_config['ev_availability'][0])}/48 intervals")
    print(f"   📈 SOC: {ev_config['ev_initial_soc'][0]:.1%} → {max(ev_config['ev_minimum_soc_schedule'][0]):.1%}")
    print(f"   🗺️  Distance: {sum(ev_config['ev_distance_forecast'][0]):.1f} km total")

    # Test both containers
    for container_name, port in [("emhass-ev-enhanced", 5003), ("emhass-ev-test", 5004)]:
        print(f"\n🧪 Testing {container_name} on port {port}")

        url = f"http://localhost:{port}/action/dayahead-optim"

        try:
            response = requests.post(url, json=ev_config, timeout=30)
            print(f"   Status: {response.status_code}")

            if response.status_code == 200:
                result = response.json()
                print(f"   ✅ Optimization succeeded!")

                # Check for EV results
                if 'P_ev0' in result:
                    ev_power = result['P_ev0']
                    print(f"   🔋 EV Power Schedule Found: {len(ev_power)} values")
                    print(f"   ⚡ Max charging: {max(ev_power):.0f}W")
                    print(f"   🔌 Charging periods: {sum(1 for p in ev_power if p > 0)}")
                else:
                    print(f"   ⚠️  No P_ev0 in result. Keys: {list(result.keys())[:10]}")

                if 'SOC_ev0' in result:
                    soc_schedule = result['SOC_ev0']
                    print(f"   📊 SOC Schedule: {soc_schedule[0]:.1%} → {soc_schedule[-1]:.1%}")
                else:
                    print(f"   ⚠️  No SOC_ev0 in result")

            else:
                print(f"   ❌ Failed: {response.status_code}")
                try:
                    error_detail = response.json()
                    print(f"   Error: {error_detail}")
                except:
                    print(f"   Error text: {response.text[:200]}")

        except Exception as e:
            print(f"   ❌ Exception: {e}")

if __name__ == "__main__":
    test_direct_optimization()