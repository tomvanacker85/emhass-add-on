#!/usr/bin/env python3
"""
Example: EV Charging optimization extension for EMHASS
This demonstrates how to integrate EV charging optimization with EMHASS
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import json
import requests

class EVChargingOptimizer:
    """
    Example class showing how EV charging optimization would be implemented
    as an extension to EMHASS deferrable loads
    """

    def __init__(self, emhass_url="http://localhost:5000"):
        self.emhass_url = emhass_url

    def create_ev_schedule(self,
                          ev_connected_hours=None,
                          target_soc_by_time=None,
                          initial_soc=0.2,
                          prediction_horizon=24):
        """
        Create EV availability schedule and minimum SOC requirements

        Args:
            ev_connected_hours: List of hours when EV is plugged in (0-23)
            target_soc_by_time: Dict {hour: min_soc} for minimum SOC requirements
            initial_soc: Starting SOC (0-1)
            prediction_horizon: Optimization horizon in hours

        Returns:
            Dict with EV scheduling arrays
        """

        # Default: EV connected evenings and nights (18:00-08:00)
        if ev_connected_hours is None:
            ev_connected_hours = list(range(18, 24)) + list(range(0, 8))

        # Default: Need 80% charge by 7 AM for daily commute
        if target_soc_by_time is None:
            target_soc_by_time = {7: 0.8}

        # Create availability array (1=connected, 0=disconnected)
        availability = []
        min_soc_schedule = []

        current_time = datetime.now()
        current_soc = initial_soc

        for hour in range(prediction_horizon):
            time_hour = (current_time + timedelta(hours=hour)).hour

            # EV is available if current hour is in connected hours
            is_connected = 1 if time_hour in ev_connected_hours else 0
            availability.append(is_connected)

            # Determine minimum required SOC at this time
            min_required_soc = current_soc  # Start with current SOC

            # Check if we have a target SOC requirement at this time
            for target_hour, target_soc in target_soc_by_time.items():
                if time_hour >= target_hour:
                    min_required_soc = max(min_required_soc, target_soc)

            min_soc_schedule.append(min_required_soc)

        return {
            "ev_availability": [availability],  # Nested for multiple EVs
            "ev_minimum_soc_schedule": [min_soc_schedule],
            "ev_initial_soc": [initial_soc],
            "prediction_horizon": prediction_horizon
        }

    def optimize_ev_charging(self, ev_schedule, optimization_type="dayahead"):
        """
        Send EV optimization request to EMHASS

        Args:
            ev_schedule: Dict from create_ev_schedule()
            optimization_type: "dayahead" or "mpc"

        Returns:
            EMHASS optimization results
        """

        endpoint_map = {
            "dayahead": "/action/dayahead-optim",
            "mpc": "/action/naive-mpc-optim"
        }

        url = self.emhass_url + endpoint_map[optimization_type]

        # Prepare request payload
        payload = ev_schedule.copy()

        # Add any additional optimization parameters
        payload.update({
            "costfun": "cost",  # Minimize cost
            "debug": True
        })

        try:
            response = requests.post(url, json=payload)
            response.raise_for_status()
            return response.json()

        except requests.exceptions.RequestException as e:
            print(f"Error calling EMHASS API: {e}")
            return None

    def analyze_results(self, results):
        """
        Analyze and display EV optimization results
        """
        if not results:
            print("No results to analyze")
            return

        # Extract key results
        df = pd.DataFrame(results)

        print("=== EV Charging Optimization Results ===")

        if 'P_ev0' in df.columns:
            total_energy = df['P_ev0'].sum() * 0.5  # Assuming 30min timesteps
            print(f"Total EV Energy Charged: {total_energy/1000:.1f} kWh")

            charging_periods = (df['P_ev0'] > 0).sum()
            print(f"Number of Charging Periods: {charging_periods}")

            if 'SOC_ev0' in df.columns:
                final_soc = df['SOC_ev0'].iloc[-1]
                print(f"Final EV SOC: {final_soc:.1%}")

        if 'cost_function_value' in results:
            print(f"Total Cost: {results['cost_function_value']:.2f}")

        # Show charging schedule
        if 'P_ev0' in df.columns:
            print("\nCharging Schedule:")
            charging_times = df[df['P_ev0'] > 0].index
            for idx in charging_times:
                power = df.loc[idx, 'P_ev0'] / 1000  # Convert to kW
                time = idx * 0.5  # Assuming 30min timesteps
                print(f"  Hour {time:4.1f}: {power:5.1f} kW")

def example_daily_commuter():
    """
    Example: Optimize charging for daily commuter
    - EV plugged in from 6 PM to 8 AM
    - Need 80% charge by 7 AM
    - Start with 20% charge
    """

    optimizer = EVChargingOptimizer()

    # Create EV schedule for daily commuter
    ev_schedule = optimizer.create_ev_schedule(
        ev_connected_hours=list(range(18, 24)) + list(range(0, 8)),  # 6PM-8AM
        target_soc_by_time={7: 0.8},  # 80% by 7 AM
        initial_soc=0.2,  # Starting at 20%
        prediction_horizon=24
    )

    print("EV Schedule created:")
    print(f"Availability: {ev_schedule['ev_availability'][0][:12]}... (first 12 hours)")
    print(f"Min SOC Requirements: {ev_schedule['ev_minimum_soc_schedule'][0][:12]}...")
    print(f"Initial SOC: {ev_schedule['ev_initial_soc'][0]:.1%}")

    # Run optimization (would call EMHASS API in real implementation)
    print("\n=== Running Day-ahead Optimization ===")
    print("API Call would be:")
    print(f"POST /action/dayahead-optim")
    print(json.dumps(ev_schedule, indent=2))

    # Simulate results for demonstration
    simulate_results(ev_schedule)

def example_weekend_vs_weekday():
    """
    Example: Different charging patterns for weekday vs weekend
    """

    optimizer = EVChargingOptimizer()

    scenarios = {
        "Weekday": {
            "connected_hours": list(range(18, 24)) + list(range(0, 8)),
            "target_soc": {7: 0.8},  # Need 80% by 7 AM for commute
            "initial_soc": 0.15
        },
        "Weekend": {
            "connected_hours": list(range(20, 24)) + list(range(0, 12)),  # Later plugin, longer stay
            "target_soc": {10: 0.6},  # Only need 60% by 10 AM for errands
            "initial_soc": 0.4
        }
    }

    for scenario_name, config in scenarios.items():
        print(f"\n=== {scenario_name} Scenario ===")

        ev_schedule = optimizer.create_ev_schedule(
            ev_connected_hours=config["connected_hours"],
            target_soc_by_time=config["target_soc"],
            initial_soc=config["initial_soc"],
            prediction_horizon=24
        )

        print(f"Connected hours: {config['connected_hours']}")
        print(f"Target SOC requirements: {config['target_soc']}")
        print(f"Starting SOC: {config['initial_soc']:.1%}")

def example_multi_ev_household():
    """
    Example: Two EVs with different schedules
    """

    print("\n=== Multi-EV Household Example ===")

    # EV 1: Daily commuter car
    ev1_availability = [0]*6 + [0]*12 + [1]*6  # Available 6PM-midnight
    ev1_min_soc = [0.2]*7 + [0.8]*17  # Need 80% by 7 AM

    # EV 2: Weekend/leisure car
    ev2_availability = [1]*8 + [0]*8 + [1]*8  # Available nights
    ev2_min_soc = [0.4]*24  # Just maintain 40% minimum

    multi_ev_schedule = {
        "ev_availability": [ev1_availability, ev2_availability],
        "ev_minimum_soc_schedule": [ev1_min_soc, ev2_min_soc],
        "ev_initial_soc": [0.15, 0.3],  # EV1 at 15%, EV2 at 30%
        "prediction_horizon": 24
    }

    print("Multi-EV Configuration:")
    print(f"EV1 Initial SOC: {multi_ev_schedule['ev_initial_soc'][0]:.1%}")
    print(f"EV2 Initial SOC: {multi_ev_schedule['ev_initial_soc'][1]:.1%}")
    print(f"EV1 Available periods: {sum(ev1_availability)} hours")
    print(f"EV2 Available periods: {sum(ev2_availability)} hours")

    print("\nAPI payload for multi-EV optimization:")
    print(json.dumps(multi_ev_schedule, indent=2))

def simulate_results(ev_schedule):
    """
    Simulate what the optimization results might look like
    """

    print("\n=== Simulated Optimization Results ===")

    # Create mock results
    timesteps = ev_schedule["prediction_horizon"]
    availability = ev_schedule["ev_availability"][0]
    min_soc = ev_schedule["ev_minimum_soc_schedule"][0]
    initial_soc = ev_schedule["ev_initial_soc"][0]

    # Simulate smart charging strategy
    ev_power = []  # kW
    soc_values = []
    current_soc = initial_soc

    # Simple strategy: charge when available and SOC below target
    for i in range(timesteps):
        # Determine if we should charge
        target_soc = min_soc[i]
        is_available = availability[i]

        if is_available and current_soc < target_soc:
            # Charge at 7.4kW (typical Level 2 charger)
            charge_power = 7.4  # kW
            # Update SOC (assuming 60kWh battery, 90% efficiency)
            energy_added = charge_power * 0.5 * 0.9  # 30min timestep, 90% efficiency
            current_soc += energy_added / 60  # 60kWh battery
            current_soc = min(current_soc, 1.0)  # Cap at 100%
        else:
            charge_power = 0.0

        ev_power.append(charge_power)
        soc_values.append(current_soc)

    # Display results
    total_energy = sum(p * 0.5 for p in ev_power)  # 30min timesteps
    charging_hours = sum(1 for p in ev_power if p > 0) * 0.5

    print(f"Total Energy Charged: {total_energy:.1f} kWh")
    print(f"Total Charging Time: {charging_hours:.1f} hours")
    print(f"Final SOC: {soc_values[-1]:.1%}")
    print(f"Peak Charging Power: {max(ev_power):.1f} kW")

    # Show charging periods
    print("\nCharging Schedule:")
    for i, power in enumerate(ev_power):
        if power > 0:
            hour = i * 0.5
            soc = soc_values[i]
            print(f"  Hour {hour:4.1f}: {power:5.1f} kW (SOC: {soc:.1%})")

if __name__ == "__main__":
    print("EMHASS EV Charging Extension Examples")
    print("=" * 50)

    # Run examples
    example_daily_commuter()
    example_weekend_vs_weekday()
    example_multi_ev_household()

    print(f"\n{'='*50}")
    print("Implementation Notes:")
    print("- These examples show the API interface design")
    print("- Actual implementation requires extending EMHASS core")
    print("- See EV_CHARGING_EXTENSION_DESIGN.md for full technical details")
    print("- Configure your EVs in the Home Assistant add-on configuration")
    print("- Pass availability and SOC schedules as runtime parameters")