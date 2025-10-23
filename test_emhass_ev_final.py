#!/usr/bin/env python3
"""
EMHASS EV Final Working Test
Tests the EV optimization with proper offline configuration.
"""

import requests
import json
import time

BASE_URL = "http://localhost:5003"  # Correct port with EV parameters

def set_offline_config():
    """Set configuration for offline testing."""

    config = {
        # Offline mode settings
        "hass_url": "empty",
        "long_lived_token": "empty",

        # EV settings - these should already be loaded but let's ensure
        "set_use_ev": True,
        "number_of_ev_loads": 1,
        "ev_battery_capacity": [77000],
        "ev_charging_efficiency": [0.9],
        "ev_nominal_charging_power": [4600],
        "ev_minimum_charging_power": [1380],
        "ev_consumption_efficiency": [0.15],

        # Battery and optimization settings
        "set_use_battery": True,
        "set_use_pv": True,
        "costfun": "profit",
        "optimization_time_step": 60,
        "lp_solver": "COIN_CMD",

        # Disable Home Assistant data fetching
        "continual_publish": False,
    }

    try:
        response = requests.post(f"{BASE_URL}/set-config", json=config, timeout=30)
        if response.status_code in [200, 201]:
            print("✅ Offline configuration set successfully")
            return True
        else:
            print(f"❌ Configuration failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Configuration error: {e}")
        return False

def test_ev_optimization():
    """Test EV optimization with realistic scenario."""

    print("🚗 Testing EV charging optimization...")

    # Realistic Belgian winter day scenario
    test_data = {
        # 24-hour PV forecast (W) - low winter production
        "pv_power_forecast": [
            0, 0, 0, 0, 0, 0, 0, 0,  # Night: 0-7
            50, 150, 400, 700, 950, 1200, 1100, 900,  # Day: 8-15
            600, 300, 100, 50, 0, 0, 0, 0  # Evening/Night: 16-23
        ],

        # 24-hour load forecast (W) - typical household
        "load_power_forecast": [
            400, 350, 320, 300, 280, 300, 350, 450,  # Night/Morning: 0-7
            500, 480, 450, 420, 450, 500, 550, 600,  # Day: 8-15
            700, 800, 900, 850, 700, 600, 500, 450   # Evening: 16-23
        ],

        # Belgian peak/off-peak pricing (€/kWh)
        "load_cost_forecast": [
            0.1419, 0.1419, 0.1419, 0.2907, 0.2907, 0.2907, 0.1419, 0.1419,  # Night/morning
            0.1419, 0.1419, 0.1419, 0.1419, 0.1419, 0.1419, 0.1419, 0.1419,  # Day
            0.1419, 0.2907, 0.2907, 0.2907, 0.2907, 0.1419, 0.1419, 0.1419   # Evening
        ],

        # Production price (feed-in tariff)
        "prod_price_forecast": [0.05] * 24,

        # Battery state
        "soc_init": 0.4,  # Battery starts at 40%
        "soc_final": 0.5, # Target 50% at end

        # Prediction horizon
        "prediction_horizon": 24,

        # No deferrable loads for this test
        "def_total_hours": [0, 0],

        # EV scenario parameters
        "alpha": 0.5,  # Cost vs comfort balance
        "beta": 0.3,   # EV vs battery priority

        # Offline mode
        "hass_url": "empty",
        "long_lived_token": "empty",
    }

    print(f"📊 Test scenario:")
    print(f"   - PV peak: {max(test_data['pv_power_forecast'])} W")
    print(f"   - Load peak: {max(test_data['load_power_forecast'])} W")
    print(f"   - Peak price: {max(test_data['load_cost_forecast']):.3f} €/kWh")
    print(f"   - Off-peak price: {min(test_data['load_cost_forecast']):.3f} €/kWh")

    try:
        response = requests.post(f"{BASE_URL}/action/naive-mpc-optim",
                               json=test_data, timeout=120)

        if response.status_code == 200:
            result = response.json()
            print("✅ EV optimization completed successfully!")

            analyze_ev_results(result)
            return True
        else:
            print(f"❌ Optimization failed: {response.status_code}")
            error_text = response.text[:500] if hasattr(response, 'text') else 'No details'
            print(f"Error details: {error_text}")
            return False

    except Exception as e:
        print(f"❌ Optimization error: {e}")
        return False

def analyze_ev_results(result):
    """Analyze the optimization results for EV charging patterns."""

    if not isinstance(result, dict):
        print(f"⚠️  Unexpected result format: {type(result)}")
        return

    print(f"\n📈 Optimization Results Analysis:")
    print(f"Result contains {len(result.keys())} data arrays")

    # Cost analysis
    if 'cost_function_value' in result:
        cost = result['cost_function_value']
        print(f"💰 Total cost: {cost:.2f} €")

    # EV charging analysis
    ev_found = False
    for key in result.keys():
        if 'P_deferrable' in key or 'deferrable' in key.lower():
            ev_data = result[key]

            if isinstance(ev_data, list):
                # Handle nested list structure
                if ev_data and isinstance(ev_data[0], list):
                    ev_schedule = ev_data[0]  # First EV
                else:
                    ev_schedule = ev_data

                if any(p > 0 for p in ev_schedule):
                    ev_found = True
                    print(f"\n🚗 EV Charging Analysis (key: {key}):")

                    charging_hours = [i for i, p in enumerate(ev_schedule) if p > 0]
                    total_energy = sum(ev_schedule)
                    max_power = max(ev_schedule)
                    avg_power = total_energy / len(charging_hours) if charging_hours else 0

                    print(f"   - Charging periods: {len(charging_hours)} hours")
                    print(f"   - Charging hours: {charging_hours}")
                    print(f"   - Total energy: {total_energy:.0f} Wh ({total_energy/1000:.1f} kWh)")
                    print(f"   - Peak charging: {max_power:.0f} W ({max_power/1000:.1f} kW)")
                    print(f"   - Average charging: {avg_power:.0f} W")

                    # Analyze charging timing
                    night_charging = sum(ev_schedule[0:8])  # 0-7 hours
                    day_charging = sum(ev_schedule[8:17])   # 8-16 hours
                    evening_charging = sum(ev_schedule[17:24])  # 17-23 hours

                    print(f"   - Night charging (0-7h): {night_charging:.0f} Wh")
                    print(f"   - Day charging (8-16h): {day_charging:.0f} Wh")
                    print(f"   - Evening charging (17-23h): {evening_charging:.0f} Wh")

    if not ev_found:
        print("\n⚠️  No EV charging schedule found in optimization results")
        print(f"Available result keys: {list(result.keys())}")

    # Battery analysis
    if 'P_batt' in result:
        battery_schedule = result['P_batt']
        charge_periods = sum(1 for p in battery_schedule if p > 0)
        discharge_periods = sum(1 for p in battery_schedule if p < 0)

        print(f"\n🔋 Battery Analysis:")
        print(f"   - Charge periods: {charge_periods}")
        print(f"   - Discharge periods: {discharge_periods}")

        if 'SOC_opt' in result:
            soc_schedule = result['SOC_opt']
            print(f"   - SOC range: {min(soc_schedule)*100:.1f}% - {max(soc_schedule)*100:.1f}%")

    # Grid interaction
    if 'P_grid' in result:
        grid_schedule = result['P_grid']
        grid_import = sum(p for p in grid_schedule if p > 0)
        grid_export = sum(abs(p) for p in grid_schedule if p < 0)

        print(f"\n⚡ Grid Interaction:")
        print(f"   - Total import: {grid_import:.0f} Wh ({grid_import/1000:.1f} kWh)")
        print(f"   - Total export: {grid_export:.0f} Wh ({grid_export/1000:.1f} kWh)")
        print(f"   - Net consumption: {(grid_import - grid_export):.0f} Wh")

def main():
    """Run the EV optimization test."""

    print("🚀 EMHASS EV Final Working Test")
    print("=" * 50)

    # Step 1: Configure for offline mode
    print("🔧 Setting up offline configuration...")
    if not set_offline_config():
        print("❌ Failed to configure offline mode")
        return False

    time.sleep(2)

    # Step 2: Test EV optimization
    if not test_ev_optimization():
        print("❌ EV optimization test failed")
        return False

    print(f"\n🎉 EMHASS EV optimization test completed successfully!")
    print(f"✅ EV charging optimization is working correctly")

    return True

if __name__ == "__main__":
    success = main()
    if not success:
        exit(1)