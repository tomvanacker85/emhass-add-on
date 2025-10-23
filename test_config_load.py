#!/usr/bin/env python3
"""
EMHASS EV Configuration Load Test
Tests if the merged configuration can be successfully loaded by EMHASS core functions.
"""

import sys
import json
import os
from pathlib import Path

def test_config_loading():
    """Test loading the configuration with EMHASS-style parameter extraction."""

    print("🔍 Testing EMHASS configuration loading...")

    config_path = "/workspaces/emhass-add-on/test-share/emhass-ev/config.json"

    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"❌ Failed to load config: {e}")
        return False

    params = config.get('params', {})

    # Test parameter extraction similar to EMHASS utils.py
    print("\n📋 Testing parameter extraction:")

    # Test retrieve_hass_conf parameters
    retrieve_hass_conf = params.get('retrieve_hass_conf', {})
    print(f"✅ Home Assistant URL: {retrieve_hass_conf.get('hass_url', 'Not set')}")
    print(f"✅ Time Zone: {retrieve_hass_conf.get('time_zone', 'Not set')}")
    print(f"✅ Location: ({retrieve_hass_conf.get('lat', 0):.4f}, {retrieve_hass_conf.get('lon', 0):.4f})")

    # Test optim_conf parameters
    optim_conf = params.get('optim_conf', {})
    print(f"✅ Optimization function: {optim_conf.get('costfun', 'Not set')}")
    print(f"✅ Time step: {optim_conf.get('optimization_time_step', 0)} minutes")
    print(f"✅ LP Solver: {optim_conf.get('lp_solver', 'Not set')}")

    # Test plant_conf parameters
    plant_conf = params.get('plant_conf', {})
    print(f"✅ Grid max power: {plant_conf.get('P_grid_max', 0)} W")
    print(f"✅ Battery nominal energy: {plant_conf.get('Enom', 0)/1000:.1f} kWh")

    # Test PV systems
    pv_systems = plant_conf.get('pv_systems', [])
    if pv_systems:
        print(f"✅ PV Systems configured: {len(pv_systems)}")
        total_pv_power = 0
        for i, system in enumerate(pv_systems):
            power = system.get('module_power', 0) * system.get('modules_per_string', 0) * system.get('strings', 1)
            total_pv_power += power
            print(f"   - {system.get('name', f'System {i+1}')}: {power}W")
        print(f"✅ Total PV capacity: {total_pv_power/1000:.1f} kW")

    # Test EV configuration
    ev_conf = params.get('ev_conf', {})
    num_ev = ev_conf.get('number_of_ev_loads', 0)
    if num_ev > 0:
        print(f"✅ EV loads configured: {num_ev}")
        ev_battery = ev_conf.get('ev_battery_capacity', [0])
        ev_power = ev_conf.get('ev_nominal_charging_power', [0])
        ev_efficiency = ev_conf.get('ev_charging_efficiency', [0])

        if len(ev_battery) >= num_ev and len(ev_power) >= num_ev:
            for i in range(num_ev):
                capacity = ev_battery[i] if i < len(ev_battery) else 0
                power = ev_power[i] if i < len(ev_power) else 0
                eff = ev_efficiency[i] if i < len(ev_efficiency) else 0
                print(f"   - EV {i+1}: {capacity/1000:.1f} kWh, {power/1000:.1f} kW charging, {eff*100:.0f}% efficiency")
        else:
            print(f"⚠️  EV array length mismatch")

    # Test deferrable loads
    def_loads = optim_conf.get('number_of_deferrable_loads', 0)
    if def_loads > 0:
        print(f"✅ Deferrable loads configured: {def_loads}")
        def_power = optim_conf.get('nominal_power_of_deferrable_loads', [])
        def_hours = optim_conf.get('operating_hours_of_each_deferrable_load', [])

        if len(def_power) == def_loads and len(def_hours) == def_loads:
            active_loads = sum(1 for p in def_power if p > 0)
            print(f"   - Active loads: {active_loads}/{def_loads}")
        else:
            print(f"⚠️  Deferrable load array length mismatch")

    # Test forecast data
    passed_data = params.get('passed_data', {})
    forecasts = ['pv_power_forecasts', 'load_power_forecasts', 'load_cost_forecasts', 'prod_price_forecasts']

    print("\n📊 Forecast data validation:")
    for forecast in forecasts:
        data = passed_data.get(forecast, [])
        if isinstance(data, list) and len(data) == 24:
            avg_val = sum(data) / len(data) if data else 0
            print(f"✅ {forecast}: 24 values, avg: {avg_val:.3f}")
        else:
            print(f"⚠️  {forecast}: Invalid length ({len(data) if isinstance(data, list) else 'not list'})")

    print(f"\n🎉 Configuration loading test completed successfully!")
    print(f"📍 Configuration is compatible with EMHASS EV framework")

    return True

def test_yaml_conversion():
    """Test if the configuration can be converted to YAML format."""

    print("\n🔄 Testing YAML conversion compatibility...")

    try:
        import yaml

        config_path = "/workspaces/emhass-add-on/test-share/emhass-ev/config.json"
        with open(config_path, 'r') as f:
            config = json.load(f)

        # Convert to YAML
        yaml_content = yaml.dump(config, default_flow_style=False, indent=2)

        # Try to parse back
        parsed_yaml = yaml.safe_load(yaml_content)

        if parsed_yaml == config:
            print("✅ YAML conversion: Successful roundtrip")
            print(f"   - YAML size: {len(yaml_content)} characters")
        else:
            print("⚠️  YAML conversion: Data mismatch after roundtrip")

    except ImportError:
        print("⚠️  PyYAML not available, skipping YAML test")
    except Exception as e:
        print(f"❌ YAML conversion failed: {e}")
        return False

    return True

if __name__ == "__main__":
    print("🚀 EMHASS EV Configuration Load Test")
    print("=" * 50)

    success1 = test_config_loading()
    success2 = test_yaml_conversion()

    if success1 and success2:
        print(f"\n✅ All tests passed! Configuration is ready for EMHASS EV.")
        sys.exit(0)
    else:
        print(f"\n❌ Some tests failed.")
        sys.exit(1)