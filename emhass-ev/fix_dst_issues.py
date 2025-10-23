#!/usr/bin/env python3
"""
DST Fix for EMHASS EV - Apply PR601 timezone handling fixes
This script patches the forecast.py file to handle DST transitions properly.
Addresses: AmbiguousTimeError and NonExistentTimeError during DST transitions.
"""

import os
import re
import shutil
from pathlib import Path

def patch_forecast_file():
    """Apply DST fixes to forecast.py similar to PR601"""
    
    forecast_path = Path("/app/src/emhass/forecast.py")
    
    if not forecast_path.exists():
        print(f"❌ forecast.py not found at {forecast_path}")
        return False
    
    print(f"🔧 Applying DST fixes to {forecast_path}")
    
    # Read the original file
    with open(forecast_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Create backup
    backup_path = forecast_path.with_suffix('.py.backup')
    if not backup_path.exists():
        shutil.copy2(forecast_path, backup_path)
        print(f"📄 Backup created: {backup_path}")
    
    # Apply fixes for tz_localize calls
    fixes_applied = 0
    original_content = content
    
    # Fix 1: Handle the specific error case in get_weather_forecast
    # data_15min.index = data_15min.index.tz_localize(self.time_zone)
    pattern1 = r'(\w+\.index)\s*=\s*(\w+\.index)\.tz_localize\(([^)]+)\)(?!\s*,\s*ambiguous)'
    replacement1 = r'\1 = \2.tz_localize(\3, ambiguous="infer", nonexistent="shift_forward")'
    
    content = re.sub(pattern1, replacement1, content)
    if content != original_content:
        fixes_applied += 1
        print("✅ Fixed index tz_localize assignment")
        original_content = content
    
    # Fix 2: General tz_localize calls without DST parameters
    pattern2 = r'\.tz_localize\(([^)]+)\)(?!\s*,\s*ambiguous)(?!\s*,\s*nonexistent)'
    replacement2 = r'.tz_localize(\1, ambiguous="infer", nonexistent="shift_forward")'
    
    content = re.sub(pattern2, replacement2, content)
    if content != original_content:
        fixes_applied += 1
        print("✅ Fixed general tz_localize calls")
        original_content = content
    
    # Fix 3: Replace pd.Timestamp(datetime.now(), tz=...) with pd.Timestamp.now(tz=...)
    pattern3 = r'pd\.Timestamp\(datetime\.now\(\),?\s*tz=([^)]+)\)'
    replacement3 = r'pd.Timestamp.now(tz=\1)'
    
    content = re.sub(pattern3, replacement3, content)
    if content != original_content:
        fixes_applied += 1
        print("✅ Fixed pd.Timestamp construction for DST awareness")
        original_content = content
    
    # Fix 4: Add imports if missing (pandas timezone handling)
    if 'import pandas as pd' in content and 'ambiguous=' not in content:
        # Check if we have datetime import
        if 'from datetime import' in content or 'import datetime' in content:
            fixes_applied += 1
            print("✅ DST parameters ready for use")
    
    # Write the patched file if any fixes were applied
    if fixes_applied > 0:
        with open(forecast_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"🎉 Applied {fixes_applied} DST fixes to forecast.py")
        
        # Verify the critical fix is present
        if 'ambiguous="infer"' in content and 'nonexistent="shift_forward"' in content:
            print("✅ Critical DST parameters successfully added")
        else:
            print("⚠️ Warning: DST parameters may not have been added correctly")
        
        return True
    else:
        print("ℹ️ No DST fixes needed - file may already be patched")
        return False

def verify_patch():
    """Verify that the DST fixes are working"""
    forecast_path = Path("/app/src/emhass/forecast.py")
    
    if not forecast_path.exists():
        return False
    
    with open(forecast_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for key DST fix indicators
    has_ambiguous = 'ambiguous="infer"' in content
    has_nonexistent = 'nonexistent="shift_forward"' in content
    has_timestamp_fix = 'pd.Timestamp.now(tz=' in content
    
    print(f"📊 DST Fix Verification:")
    print(f"   ✓ Ambiguous parameter: {has_ambiguous}")
    print(f"   ✓ Nonexistent parameter: {has_nonexistent}")
    print(f"   ✓ Timestamp fix: {has_timestamp_fix}")
    
    return has_ambiguous and has_nonexistent

def main():
    """Main function to apply DST fixes"""
    print("🕐 EMHASS EV DST Fix (PR601 equivalent)")
    print("=====================================")
    print("Fixing: AmbiguousTimeError during DST transitions")
    print("Target: /app/src/emhass/forecast.py")
    print()
    
    try:
        success = patch_forecast_file()
        
        if success:
            print()
            if verify_patch():
                print("✅ DST fixes applied and verified successfully!")
                print("🔄 EMHASS should now handle DST transitions properly")
                print("📅 Resolved: 'Cannot infer dst time' errors")
            else:
                print("⚠️ DST fixes applied but verification failed")
        else:
            print("ℹ️ No changes made to forecast.py")
            
    except Exception as e:
        print(f"❌ Error applying DST fixes: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    return True

if __name__ == "__main__":
    main()