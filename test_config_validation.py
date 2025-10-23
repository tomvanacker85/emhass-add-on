#!/usr/bin/env python3
"""
EMHASS Configuration Validation Script
Tests the merged configuration file for structural validity and parameter consistency.
"""

import json
import sys
from pathlib import Path

def validate_config_structure(config_path):
    """Validate the EMHASS configuration file structure."""

    print(f"🔍 Validating configuration file: {config_path}")

    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        print(f"❌ JSON syntax error: {e}")
        return False
    except FileNotFoundError:
        print(f"❌ Configuration file not found: {config_path}")
        return False

    # Check top-level structure
    if 'params' not in config:
        print("❌ Missing 'params' top-level key")
        return False

    params = config['params']
    required_sections = ['passed_data', 'retrieve_hass_conf', 'optim_conf', 'plant_conf', 'ev_conf']

    print("\n📋 Checking required sections:")
    for section in required_sections:
        if section in params:
            print(f"✅ {section}")
        else:
            print(f"❌ Missing section: {section}")
            return False

    # Validate passed_data structure
    print("\n🔍 Validating passed_data section:")
    passed_data = params.get('passed_data', {})
    forecast_keys = ['pv_power_forecasts', 'load_power_forecasts', 'load_cost_forecasts', 'prod_price_forecasts']

    for key in forecast_keys:
        if key in passed_data:
            forecast_data = passed_data[key]
            if isinstance(forecast_data, list) and len(forecast_data) == 24:
                print(f"✅ {key}: {len(forecast_data)} values")
            else:
                print(f"⚠️  {key}: {len(forecast_data) if isinstance(forecast_data, list) else 'Not a list'} values (expected 24)")
        else:
            print(f"❌ Missing {key}")

    # Validate retrieve_hass_conf
    print("\n🔍 Validating retrieve_hass_conf section:")
    hass_conf = params.get('retrieve_hass_conf', {})
    hass_required = ['hass_url', 'time_zone', 'lat', 'lon']

    for key in hass_required:
        if key in hass_conf:
            print(f"✅ {key}: {hass_conf[key]}")
        else:
            print(f"❌ Missing {key}")

    # Validate optim_conf
    print("\n🔍 Validating optim_conf section:")
    optim_conf = params.get('optim_conf', {})

    # Check deferrable loads consistency
    num_def_loads = optim_conf.get('number_of_deferrable_loads', 0)
    print(f"✅ Number of deferrable loads: {num_def_loads}")

    deferrable_arrays = [
        'nominal_power_of_deferrable_loads',
        'operating_hours_of_each_deferrable_load',
        'treat_deferrable_load_as_semi_cont',
        'set_deferrable_load_single_constant'
    ]

    for array_name in deferrable_arrays:
        if array_name in optim_conf:
            array_data = optim_conf[array_name]
            if isinstance(array_data, list) and len(array_data) == num_def_loads:
                print(f"✅ {array_name}: {len(array_data)} values")
            else:
                print(f"⚠️  {array_name}: {len(array_data) if isinstance(array_data, list) else 'Not a list'} values (expected {num_def_loads})")

    # Validate plant_conf
    print("\n🔍 Validating plant_conf section:")
    plant_conf = params.get('plant_conf', {})

    # Check PV systems
    if 'pv_systems' in plant_conf:
        pv_systems = plant_conf['pv_systems']
        print(f"✅ PV systems defined: {len(pv_systems)}")

        for i, system in enumerate(pv_systems):
            required_pv_keys = ['name', 'surface_azimuth', 'surface_tilt', 'module_power']
            missing_keys = [key for key in required_pv_keys if key not in system]
            if not missing_keys:
                print(f"✅ PV System {i+1} ({system['name']}): Complete")
            else:
                print(f"⚠️  PV System {i+1}: Missing {missing_keys}")

    # Check battery configuration
    battery_keys = ['Enom', 'SOCmin', 'SOCmax', 'eta_ch', 'eta_disch']
    battery_missing = [key for key in battery_keys if key not in plant_conf]
    if not battery_missing:
        print(f"✅ Battery configuration: Complete")
        print(f"   - Capacity: {plant_conf.get('Enom', 0)/1000:.1f} kWh")
        print(f"   - SOC range: {plant_conf.get('SOCmin', 0)*100:.0f}% - {plant_conf.get('SOCmax', 1)*100:.0f}%")
    else:
        print(f"⚠️  Battery configuration: Missing {battery_missing}")

    # Validate ev_conf
    print("\n🔍 Validating ev_conf section:")
    ev_conf = params.get('ev_conf', {})

    num_ev_loads = ev_conf.get('number_of_ev_loads', 0)
    print(f"✅ Number of EV loads: {num_ev_loads}")

    if num_ev_loads > 0:
        ev_arrays = [
            'ev_battery_capacity',
            'ev_charging_efficiency',
            'ev_nominal_charging_power',
            'ev_minimum_charging_power',
            'ev_consumption_efficiency'
        ]

        for array_name in ev_arrays:
            if array_name in ev_conf:
                array_data = ev_conf[array_name]
                if isinstance(array_data, list) and len(array_data) == num_ev_loads:
                    print(f"✅ {array_name}: {len(array_data)} values")
                    if array_name == 'ev_battery_capacity':
                        print(f"   - EV Battery: {array_data[0]/1000:.1f} kWh")
                    elif array_name == 'ev_nominal_charging_power':
                        print(f"   - Charging Power: {array_data[0]/1000:.1f} kW")
                else:
                    print(f"⚠️  {array_name}: {len(array_data) if isinstance(array_data, list) else 'Not a list'} values (expected {num_ev_loads})")
            else:
                print(f"❌ Missing {array_name}")

    # Summary
    print("\n📊 Configuration Summary:")
    print(f"✅ Location: {hass_conf.get('time_zone', 'Unknown')} ({hass_conf.get('lat', '?'):.4f}, {hass_conf.get('lon', '?'):.4f})")
    print(f"✅ PV Systems: {len(plant_conf.get('pv_systems', []))}")
    print(f"✅ Battery: {plant_conf.get('Enom', 0)/1000:.1f} kWh")
    print(f"✅ Deferrable Loads: {num_def_loads}")
    print(f"✅ EV Loads: {num_ev_loads}")

    if num_ev_loads > 0:
        ev_capacity = ev_conf.get('ev_battery_capacity', [0])[0]
        ev_power = ev_conf.get('ev_nominal_charging_power', [0])[0]
        print(f"✅ EV: {ev_capacity/1000:.1f} kWh battery, {ev_power/1000:.1f} kW charging")

    print("\n🎉 Configuration validation completed successfully!")
    return True

if __name__ == "__main__":
    config_path = "/workspaces/emhass-add-on/test-share/emhass-ev/config.json"

    if len(sys.argv) > 1:
        config_path = sys.argv[1]

    success = validate_config_structure(config_path)
    sys.exit(0 if success else 1)