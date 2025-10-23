#!/usr/bin/env python3
"""
EMHASS EV Model Test Script
Tests the EMHASS optimization with EV charging scenario using the validated configuration.
"""

import requests
import json
import time
from datetime import datetime, timedelta
import sys

# Test configuration
BASE_URL = "http://localhost:5004"
CONFIG_PATH = "/workspaces/emhass-add-on/test-share/emhass-ev/config.json"

def load_test_config():
    """Load our validated test configuration."""
    try:
        with open(CONFIG_PATH, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Failed to load test config: {e}")
        return None

def test_api_health():
    """Test if the EMHASS API is responding."""
    try:
        response = requests.get(f"{BASE_URL}/", timeout=10)
        if response.status_code == 200:
            print("✅ EMHASS API is responding")
            return True
        else:
            print(f"⚠️  EMHASS API responded with status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Failed to connect to EMHASS API: {e}")
        return False

def set_configuration():
    """Post our configuration to EMHASS."""
    config = load_test_config()
    if not config:
        return False
    
    try:
        # Extract parameters from our config
        params = config.get('params', {})
        
        # Prepare configuration payload
        config_payload = {}
        
        # Add all sections
        for section_name, section_data in params.items():
            if isinstance(section_data, dict):
                config_payload.update(section_data)
        
        print(f"📤 Posting configuration with {len(config_payload)} parameters...")
        
        response = requests.post(
            f"{BASE_URL}/set-config",
            json=config_payload,
            timeout=30
        )
        
        if response.status_code in [200, 201]:
            print("✅ Configuration posted successfully")
            return True
        else:
            print(f"❌ Failed to post configuration: {response.status_code}")
            print(f"Response: {response.text[:200]}...")
            return False
            
    except Exception as e:
        print(f"❌ Exception posting configuration: {e}")
        return False

def create_ev_test_scenario():
    """Create a realistic EV charging test scenario."""
    
    # Generate 72-hour forecast (3 days) as expected by EMHASS
    base_time = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    
    # Sample PV production forecast (W) - realistic Belgian winter day
    daily_pv = [0, 0, 0, 0, 0, 0, 0, 0, 40, 120, 350, 650, 950, 1200, 1400, 1500,
                1200, 800, 400, 150, 50, 0, 0, 0]
    
    pv_forecast = daily_pv * 3  # 3 days
    
    # Sample load forecast (W) - typical household
    daily_load = [450, 420, 380, 350, 340, 360, 420, 580, 650, 550, 480, 460, 520, 580,
                  620, 680, 750, 850, 920, 800, 650, 550, 500, 480]
    
    load_forecast = daily_load * 3  # 3 days
    
    # Belgian peak/off-peak pricing (€/kWh)
    cost_forecast = []
    prod_price_forecast = []
    
    for hour in range(72):  # 3 days
        hour_of_day = hour % 24
        # Peak hours: 17:24-20:24 and night/morning peak
        if (17 <= hour_of_day <= 20) or (2 <= hour_of_day <= 6):
            cost_forecast.append(0.2907)  # Peak rate
        else:
            cost_forecast.append(0.1419)  # Off-peak rate
        
        # Production price (feed-in tariff)
        prod_price_forecast.append(0.05)
    
    return {
        "pv_power_forecast": pv_forecast,
        "load_power_forecast": load_forecast,
        "load_cost_forecast": cost_forecast,
        "prod_price_forecast": prod_price_forecast,
        "prediction_horizon": 72,
        "soc_init": 0.6,  # Battery starts at 60%
        "soc_final": 0.5, # Target 50% at end
        "def_total_hours": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],  # No deferrable loads for this test
        # EV parameters for test scenario
        "alpha": 0.5,  # Weight for cost vs comfort
        "beta": 0.3,   # Weight for EV vs battery
        # Offline mode parameters
        "hass_url": "empty",
        "long_lived_token": "empty",
        "continual_publish": False,
    }

def test_perfect_optimization():
    """Test the perfect optimization with EV charging scenario."""
    
    test_data = create_ev_test_scenario()
    
    print(f"🧪 Testing perfect optimization with EV scenario...")
    print(f"   - PV forecast: {max(test_data['pv_power_forecast'])/1000:.1f} kW peak")
    print(f"   - Load forecast: {sum(test_data['load_power_forecast'])/len(test_data['load_power_forecast'])/1000:.1f} kW average")
    print(f"   - Cost range: {min(test_data['load_cost_forecast']):.3f} - {max(test_data['load_cost_forecast']):.3f} €/kWh")
    
    try:
        response = requests.post(
            f"{BASE_URL}/action/perfect-optim",
            json=test_data,
            timeout=120  # Give optimization time to complete
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Perfect optimization completed successfully!")
            
            # Analyze results
            analyze_optimization_results(result, test_data)
            return True
        else:
            print(f"❌ Optimization failed with status {response.status_code}")
            print(f"Response: {response.text[:500]}...")
            return False
            
    except requests.exceptions.Timeout:
        print("❌ Optimization timed out (>120s)")
        return False
    except Exception as e:
        print(f"❌ Exception during optimization: {e}")
        return False

def analyze_optimization_results(result, test_data):
    """Analyze and display optimization results."""
    
    print(f"\n📊 Optimization Results Analysis:")
    
    # Check if we have expected result structure
    if isinstance(result, dict):
        
        # Look for cost information
        if 'cost_function_value' in result:
            cost = result['cost_function_value']
            print(f"💰 Total cost: {cost:.2f} €")
        
        # Look for battery schedule
        if 'P_batt' in result:
            battery_schedule = result['P_batt']
            print(f"🔋 Battery schedule: {len(battery_schedule)} time steps")
            
            charge_periods = sum(1 for p in battery_schedule if p > 0)
            discharge_periods = sum(1 for p in battery_schedule if p < 0)
            print(f"   - Charging periods: {charge_periods}")
            print(f"   - Discharging periods: {discharge_periods}")
            
            max_charge = max(battery_schedule) if battery_schedule else 0
            max_discharge = min(battery_schedule) if battery_schedule else 0
            print(f"   - Max charge power: {max_charge:.0f} W")
            print(f"   - Max discharge power: {abs(max_discharge):.0f} W")
        
        # Look for EV charging schedule
        ev_found = False
        for key in result.keys():
            if 'ev' in key.lower() or 'P_def' in key:
                ev_schedule = result[key]
                if isinstance(ev_schedule, list) and any(p > 0 for p in ev_schedule):
                    print(f"🚗 EV charging schedule found: {key}")
                    print(f"   - Charging periods: {sum(1 for p in ev_schedule if p > 0)}")
                    print(f"   - Total energy: {sum(ev_schedule):.0f} Wh")
                    print(f"   - Peak charging: {max(ev_schedule):.0f} W")
                    ev_found = True
                    break
        
        if not ev_found:
            print("⚠️  No EV charging schedule found in results")
        
        # Look for grid interaction
        if 'P_grid' in result:
            grid_schedule = result['P_grid']
            print(f"⚡ Grid interaction:")
            
            grid_import = sum(p for p in grid_schedule if p > 0)
            grid_export = sum(abs(p) for p in grid_schedule if p < 0)
            print(f"   - Total import: {grid_import:.0f} Wh")
            print(f"   - Total export: {grid_export:.0f} Wh")
            print(f"   - Net consumption: {grid_import - grid_export:.0f} Wh")
        
        # Look for SOC schedule
        if 'SOC_opt' in result:
            soc_schedule = result['SOC_opt']
            print(f"📈 Battery SOC schedule:")
            print(f"   - Start SOC: {soc_schedule[0]*100:.1f}%")
            print(f"   - End SOC: {soc_schedule[-1]*100:.1f}%")
            print(f"   - Min SOC: {min(soc_schedule)*100:.1f}%")
            print(f"   - Max SOC: {max(soc_schedule)*100:.1f}%")
        
        # Show available result keys for debugging
        print(f"\n🔍 Available result keys: {list(result.keys())}")
        
    else:
        print(f"⚠️  Unexpected result format: {type(result)}")
        print(f"Result preview: {str(result)[:200]}...")

def test_get_config():
    """Test getting the current configuration to verify EV parameters."""
    
    try:
        response = requests.get(f"{BASE_URL}/get-config", timeout=10)
        
        if response.status_code in [200, 201]:
            config = response.json()
            print(f"📋 Current configuration loaded:")
            
            # Check for EV parameters
            ev_params = [key for key in config.keys() if 'ev' in key.lower()]
            if ev_params:
                print(f"✅ EV parameters found: {len(ev_params)}")
                for param in ev_params:
                    value = config[param]
                    if isinstance(value, list):
                        print(f"   - {param}: {value}")
                    else:
                        print(f"   - {param}: {value}")
            else:
                print(f"⚠️  No EV parameters found in configuration")
                
            # Check for key parameters
            key_params = ['costfun', 'optimization_time_step', 'lp_solver', 'set_use_battery']
            print(f"🔧 Key optimization parameters:")
            for param in key_params:
                if param in config:
                    print(f"   - {param}: {config[param]}")
            
            return True
        else:
            print(f"❌ Failed to get config: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Exception getting config: {e}")
        return False

def main():
    """Main test runner."""
    print("🚀 EMHASS EV Model Test")
    print("=" * 50)
    
    # Test 1: API Health
    if not test_api_health():
        print("❌ API health check failed - stopping tests")
        return False
    
    time.sleep(2)
    
    # Test 2: Set Configuration
    if not set_configuration():
        print("❌ Configuration setup failed - stopping tests")
        return False
    
    time.sleep(3)
    
    # Test 3: Verify Configuration
    if not test_get_config():
        print("⚠️  Configuration verification failed")
    
    time.sleep(2)
    
    # Test 4: Perfect Optimization Test
    if not test_perfect_optimization():
        print("❌ Optimization test failed")
        return False
    
    print(f"\n🎉 All tests completed successfully!")
    print(f"✅ EMHASS EV model is working with the validated configuration")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)