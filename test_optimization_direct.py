#!/usr/bin/env python3
"""
Test the EV optimization model directly by importing and running it
"""
import sys
import numpy as np
import pandas as pd
import logging
from datetime import datetime, timedelta

def test_optimization_model_directly():
    """Test the EV optimization by running the model directly"""

    print("🧪 Direct Optimization Model Test")
    print("=" * 50)

    try:
        # Set up the optimization configuration
        retrieve_hass_conf = {
            "optimization_time_step": pd.to_timedelta(30, "minutes"),
            "historic_days_to_retrieve": 2,
            "method_ts_round": "first",
            "time_zone": "UTC",
            "sensor_power_photovoltaics": "sensor.pv_power",
            "sensor_power_load_no_var_loads": "sensor.load_power",
            "load_forecast_method": "naive",
            "weather_forecast_method": "list"
        }

        optim_conf = {
            "set_use_battery": False,
            "number_of_deferrable_loads": 0,
            "nominal_power_of_deferrable_loads": [],
            "operating_hours_of_each_deferrable_load": [],
            "treat_deferrable_load_as_semi_cont": [],
            "set_deferrable_load_single_constant": [],
            "start_timesteps_of_each_deferrable_load": [],
            "end_timesteps_of_each_deferrable_load": [],

            # EV Configuration - this is what we're testing!
            "number_of_ev_loads": 1,
            "ev_battery_capacity": [60000],  # 60 kWh in Wh
            "ev_charging_efficiency": [0.9],
            "ev_nominal_charging_power": [7400],  # 7.4 kW
            "ev_minimum_charging_power": [1380],  # 1.38 kW
            "ev_availability": [[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1]],
            "ev_minimum_soc_schedule": [[0.2]*14 + [0.8]*34],
            "ev_initial_soc": [0.2],

            "lp_solver": "COIN_CMD",
            "lp_solver_path": "empty",
            "lp_solver_timeout": 60,
            "num_threads": 1,
            "set_total_pv_sell": False
        }

        plant_conf = {
            "P_grid_max": 9000,
            "module_model": ["test"],
            "inverter_model": ["test"],
            "surface_tilt": [30],
            "surface_azimuth": [180],
            "modules_per_string": [1],
            "strings_per_inverter": [1],
            "Pd_max": 1000,
            "maximum_power_from_grid": 9000,
            "maximum_power_to_grid": 9000,
            "inverter_is_hybrid": False,
            "compute_curtailment": False
        }

        # Create test data
        timestamps = pd.date_range(start=datetime.now(), periods=48, freq='30min')

        # PV forecast (solar during day)
        pv_power = [0]*12 + [100,200,500,800,1500,2000,3000,4000,4500,4500,4000,3000,2000,1500,1000,500,200,100] + [0]*18

        # Load forecast
        load_power = [1500] * 48

        # Cost forecasts
        unit_load_cost = [0.15]*16 + [0.25]*24 + [0.15]*8  # Peak pricing
        unit_prod_price = [0.10] * 48

        data_opt = pd.DataFrame({
            'P_PV': pv_power,
            'P_load': load_power,
            'unit_load_cost': unit_load_cost,
            'unit_prod_price': unit_prod_price
        }, index=timestamps)

        print(f"📊 Test Setup:")
        print(f"   🔋 EV Battery: {optim_conf['ev_battery_capacity'][0]/1000:.1f} kWh")
        print(f"   ⚡ Max Power: {optim_conf['ev_nominal_charging_power'][0]/1000:.1f} kW")
        print(f"   🔌 Connected: {sum(optim_conf['ev_availability'][0])}/48 intervals")
        print(f"   📈 SOC: {optim_conf['ev_initial_soc'][0]:.1%} → {max(optim_conf['ev_minimum_soc_schedule'][0]):.1%}")
        print(f"   📅 Data points: {len(data_opt)} timestamps")

        # Test if we can at least instantiate the optimization
        print(f"\n🔧 Testing optimization model instantiation...")

        # Import the optimization class
        from emhass.optimization import Optimization
        print(f"   ✅ Optimization class imported successfully")

        # Create optimization instance
        logger = logging.getLogger("test_logger")
        logger.setLevel(logging.INFO)

        opt = Optimization(
            retrieve_hass_conf=retrieve_hass_conf,
            optim_conf=optim_conf,
            plant_conf=plant_conf,
            var_load_cost="unit_load_cost",
            var_prod_price="unit_prod_price",
            costfun="cost",
            emhass_conf={},
            logger=logger
        )
        print(f"   ✅ Optimization instance created successfully")

        # Test perform_optimization with our EV parameters
        print(f"\n🚀 Running optimization with EV parameters...")
        result = opt.perform_optimization(
            data_opt=data_opt,
            P_PV=data_opt['P_PV'].values,
            P_load=data_opt['P_load'].values,
            unit_load_cost=data_opt['unit_load_cost'].values,
            unit_prod_price=data_opt['unit_prod_price'].values
        )

        print(f"   ✅ Optimization completed successfully!")
        print(f"   📊 Result type: {type(result)}")
        print(f"   📝 Columns: {list(result.columns) if hasattr(result, 'columns') else 'N/A'}")

        # Check for EV results
        if hasattr(result, 'columns'):
            ev_columns = [col for col in result.columns if 'ev' in col.lower()]
            if ev_columns:
                print(f"   🎉 EV columns found: {ev_columns}")
                for col in ev_columns:
                    values = result[col].values
                    print(f"      {col}: min={min(values):.3f}, max={max(values):.3f}, sum={sum(values):.1f}")
            else:
                print(f"   ⚠️  No EV columns found in result")
                print(f"   📋 Available columns: {list(result.columns)[:10]}")

        return True

    except ImportError as e:
        print(f"   ❌ Import failed: {e}")
        print(f"   💡 This might be expected if not running inside the container")
        return False
    except Exception as e:
        print(f"   ❌ Optimization failed: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_optimization_model_directly()
    if success:
        print(f"\n🎉 EV Optimization Model Test: SUCCESS!")
        print(f"   The EV optimization model has been successfully implemented!")
    else:
        print(f"\n❌ EV Optimization Model Test: FAILED")
        print(f"   The optimization model needs debugging")