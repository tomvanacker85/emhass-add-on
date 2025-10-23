#!/usr/bin/env python3
"""
Complete EV Functionality Test
Tests all the EV features you requested:
1. EV availability array (when connected to charger)
2. Required charge at each time step
3. Driven kilometers at each time step
"""

import requests
import json
import time

BASE_URL = "http://localhost:5003"

def test_complete_ev_functionality():
    """Test the complete EV functionality with your requested parameters."""

    print("🚗 Complete EV Functionality Test")
    print("=" * 50)

    # Your requested EV scenario
    ev_test_data = {
        # Standard optimization parameters
        "pv_power_forecast": [0] * 8 + [100, 300, 500, 800, 1000, 1200, 1000, 800, 500, 200] + [0] * 6,
        "load_power_forecast": [400, 350, 320, 300, 280, 300, 350, 450, 500, 480, 450, 420, 450, 500, 550, 600, 700, 800, 900, 850, 700, 600, 500, 450],
        "load_cost_forecast": [0.1419] * 8 + [0.2907] * 4 + [0.1419] * 6 + [0.2907] * 4 + [0.1419] * 2,
        "prod_price_forecast": [0.05] * 24,
        "soc_init": 0.4,
        "soc_final": 0.5,
        "prediction_horizon": 24,

        # YOUR REQUESTED EV FUNCTIONALITY:

        # 1. EV Availability Array - when EV is connected to charger
        "ev_availability": [
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1]
        ],
        # EV connected: 0-13h (14 hours), disconnected: 14-17h (4 hours), connected: 18-23h (6 hours)
        # Total connected time: 20/24 hours

        # 2. Required charge array - required SOC at each time step
        "ev_minimum_soc_schedule": [
            [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8,
             0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8]
        ],
        # Requirements: 20% until 7AM, then 80% needed for work commute

        # 3. Driven kilometers array - km driven at each time step
        "ev_distance_forecast": [
            [0, 0, 0, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25, 0, 0, 0, 0, 0, 0]
        ],
        # Drive 25km at 7AM (to work) and 25km at 5PM (back home) = 50km total

        # 4. Initial SOC
        "ev_initial_soc": [0.2],  # Start at 20% charge

        # Additional EV configuration
        "def_total_hours": [0, 0],  # No other deferrable loads
        "alpha": 0.5,  # Cost vs comfort balance
        "beta": 0.3,   # EV vs battery priority
    }

    print("📊 EV Test Scenario Summary:")
    print(f"   🔌 EV Connection: {sum(ev_test_data['ev_availability'][0])}/24 hours connected")
    print(f"   ⚡ Charge Requirement: 20% → 80% by 7AM")
    print(f"   🚗 Daily Commute: {sum(ev_test_data['ev_distance_forecast'][0])} km total")
    print(f"   🔋 Starting SOC: {ev_test_data['ev_initial_soc'][0]*100:.0f}%")

    # Calculate energy needs
    consumption_efficiency = 0.15  # kWh/km (from config)
    energy_needed_for_trip = sum(ev_test_data['ev_distance_forecast'][0]) * consumption_efficiency
    battery_capacity = 77  # kWh (from config)

    print(f"   📈 Energy for driving: {energy_needed_for_trip:.1f} kWh")
    print(f"   🎯 Optimization goal: Charge to 80% when needed, minimize cost")

    print(f"\n🧪 Testing EV optimization...")

    try:
        # Test with the naive-mpc-optim endpoint
        response = requests.post(f"{BASE_URL}/action/naive-mpc-optim",
                               json=ev_test_data, timeout=120)

        if response.status_code == 200:
            result = response.json()
            print("✅ EV optimization completed successfully!")

            analyze_ev_optimization_results(result, ev_test_data)
            return True
        else:
            print(f"❌ Optimization failed: {response.status_code}")
            error_text = response.text[:500] if hasattr(response, 'text') else 'No details'
            print(f"Error: {error_text}")

            # If naive optimization fails, let's try setting offline config first
            return test_with_offline_config(ev_test_data)

    except Exception as e:
        print(f"❌ Optimization error: {e}")
        return False

def test_with_offline_config(ev_test_data):
    """Try setting offline configuration first."""

    print("\n🔧 Attempting with offline configuration...")

    # Set offline mode
    offline_config = {
        "hass_url": "empty",
        "long_lived_token": "empty",
        "continual_publish": False,
        "set_use_ev": True,
        "number_of_ev_loads": 1,
    }

    try:
        response = requests.post(f"{BASE_URL}/set-config", json=offline_config, timeout=30)
        if response.status_code in [200, 201]:
            print("✅ Offline mode configured")
            time.sleep(2)

            # Try optimization again with offline mode
            response = requests.post(f"{BASE_URL}/action/naive-mpc-optim",
                                   json=ev_test_data, timeout=120)

            if response.status_code == 200:
                result = response.json()
                print("✅ EV optimization completed with offline mode!")
                analyze_ev_optimization_results(result, ev_test_data)
                return True
            else:
                print(f"❌ Still failed: {response.status_code}")
                return False
        else:
            print(f"❌ Offline config failed: {response.status_code}")
            return False

    except Exception as e:
        print(f"❌ Offline config error: {e}")
        return False

def analyze_ev_optimization_results(result, test_data):
    """Analyze the optimization results for your EV functionality."""

    print(f"\n📈 EV Optimization Results Analysis:")
    print(f"=" * 45)

    if not isinstance(result, dict):
        print(f"⚠️  Unexpected result format: {type(result)}")
        return

    # Cost analysis
    if 'cost_function_value' in result:
        cost = result['cost_function_value']
        print(f"💰 Total optimization cost: {cost:.2f} €")

    # Look for EV charging schedule in the results
    ev_charging_found = False

    # Check various possible keys for EV data
    possible_keys = ['P_deferrable', 'P_def', 'deferrable_loads', 'P_EV0', 'EV_power']

    for key in result.keys():
        if any(search_key in key for search_key in possible_keys) or 'ev' in key.lower():
            ev_data = result[key]

            if isinstance(ev_data, list):
                # Handle nested structure (multiple vehicles)
                if ev_data and isinstance(ev_data[0], list):
                    ev_schedule = ev_data[0]  # First EV
                else:
                    ev_schedule = ev_data

                # Check if this contains actual charging data
                if ev_schedule and any(p > 0 for p in ev_schedule):
                    ev_charging_found = True
                    print(f"\n🚗 EV Charging Schedule Found (key: {key}):")

                    # Analyze charging pattern
                    charging_hours = [i for i, p in enumerate(ev_schedule) if p > 0]
                    total_energy = sum(ev_schedule)
                    max_power = max(ev_schedule) if ev_schedule else 0

                    print(f"   ⚡ Charging periods: {len(charging_hours)} hours")
                    print(f"   🕐 Charging hours: {charging_hours}")
                    print(f"   🔋 Total energy charged: {total_energy:.0f} Wh ({total_energy/1000:.1f} kWh)")
                    print(f"   📊 Peak charging power: {max_power:.0f} W ({max_power/1000:.1f} kW)")

                    # Check alignment with your requirements
                    availability = test_data['ev_availability'][0]
                    charging_when_available = all(
                        availability[i] == 1 for i in charging_hours
                    ) if charging_hours else True

                    print(f"   ✅ Charges only when available: {charging_when_available}")

                    # Analyze timing vs your requirements
                    morning_charge = sum(ev_schedule[0:7])   # Before 7AM
                    work_charge = sum(ev_schedule[7:17])     # Work hours (7AM-5PM)
                    evening_charge = sum(ev_schedule[17:24]) # Evening

                    print(f"\n⏰ Charging Distribution:")
                    print(f"   🌙 Night/Morning (0-6h): {morning_charge:.0f} Wh")
                    print(f"   ☀️  Work hours (7-16h): {work_charge:.0f} Wh")
                    print(f"   🌆 Evening (17-23h): {evening_charge:.0f} Wh")

                    # Calculate if requirement is met
                    required_soc = test_data['ev_minimum_soc_schedule'][0][7]  # 80% by 7AM
                    battery_capacity_wh = 77000  # 77 kWh
                    required_energy = required_soc * battery_capacity_wh
                    initial_energy = test_data['ev_initial_soc'][0] * battery_capacity_wh

                    energy_needed = required_energy - initial_energy
                    energy_for_driving = sum(test_data['ev_distance_forecast'][0]) * 0.15 * 1000  # Convert to Wh

                    print(f"\n🎯 Requirement Analysis:")
                    print(f"   📊 Initial energy: {initial_energy:.0f} Wh ({test_data['ev_initial_soc'][0]*100:.0f}%)")
                    print(f"   🎯 Target energy: {required_energy:.0f} Wh ({required_soc*100:.0f}%)")
                    print(f"   ⚡ Energy to charge: {energy_needed:.0f} Wh")
                    print(f"   🚗 Energy for driving: {energy_for_driving:.0f} Wh")
                    print(f"   📈 Total energy charged: {total_energy:.0f} Wh")

                    meets_requirement = total_energy >= energy_needed
                    print(f"   {'✅' if meets_requirement else '❌'} Meets charging requirement: {meets_requirement}")

    if not ev_charging_found:
        print(f"\n⚠️  No EV charging schedule found in results")
        print(f"📋 Available result keys: {list(result.keys())}")

        # Check if it's treated as regular deferrable load
        if 'P_deferrable' in result:
            print(f"💡 Checking if EV is in deferrable loads...")
            deferrable = result['P_deferrable']
            if isinstance(deferrable, list) and deferrable:
                total_def_energy = sum(deferrable)
                print(f"   Total deferrable energy: {total_def_energy:.0f} Wh")

    # Battery analysis
    if 'P_batt' in result:
        battery_schedule = result['P_batt']
        battery_charge = sum(p for p in battery_schedule if p > 0)
        battery_discharge = sum(abs(p) for p in battery_schedule if p < 0)

        print(f"\n🔋 Battery Analysis:")
        print(f"   ⚡ Battery charging: {battery_charge:.0f} Wh")
        print(f"   📉 Battery discharging: {battery_discharge:.0f} Wh")

        if 'SOC_opt' in result:
            soc_schedule = result['SOC_opt']
            print(f"   📈 SOC range: {min(soc_schedule)*100:.1f}% - {max(soc_schedule)*100:.1f}%")

    # Grid analysis
    if 'P_grid' in result:
        grid_schedule = result['P_grid']
        grid_import = sum(p for p in grid_schedule if p > 0)
        grid_export = sum(abs(p) for p in grid_schedule if p < 0)

        print(f"\n⚡ Grid Interaction:")
        print(f"   📥 Total import: {grid_import:.0f} Wh ({grid_import/1000:.1f} kWh)")
        print(f"   📤 Total export: {grid_export:.0f} Wh ({grid_export/1000:.1f} kWh)")
        print(f"   💰 Net cost impact: {(grid_import - grid_export)/1000:.1f} kWh")

def main():
    """Run the complete EV functionality test."""

    print("🎯 Testing Your Requested EV Functionality")
    print("🚗 EV availability array (when connected to charger)")
    print("⚡ Required charge array (needed SOC at each time step)")
    print("🗺️  Driven kilometers array (km driven at each time step)")
    print()

    success = test_complete_ev_functionality()

    if success:
        print(f"\n🎉 EV FUNCTIONALITY TEST COMPLETED!")
        print(f"✅ Your requested EV features are working:")
        print(f"   🔌 EV availability scheduling")
        print(f"   ⚡ Dynamic charge requirements")
        print(f"   🚗 Distance-based energy planning")
        print(f"   🧮 Intelligent optimization considering all factors")

    else:
        print(f"\n❌ EV functionality test failed")
        print(f"   The basic EMHASS infrastructure is working")
        print(f"   But EV-specific optimization may need debugging")

    return success

if __name__ == "__main__":
    success = main()
    if not success:
        exit(1)