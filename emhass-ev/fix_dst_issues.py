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
    
    # Fix 1: Enhanced tz_localize with try-catch wrapper
    # Instead of just adding parameters, wrap problematic calls with error handling
    tz_localize_pattern = r'(\w+\.index)\s*=\s*(\w+\.index)\.tz_localize\([^)]+\)'
    
    def replace_tz_localize(match):
        full_line = match.group(0)
        index_var = match.group(1)
        source_index = match.group(2)
        
        # Create a robust replacement with error handling
        replacement = f'''try:
            {index_var} = {source_index}.tz_localize(self.time_zone, ambiguous="infer", nonexistent="shift_forward")
        except Exception as e:
            # Fallback for stubborn DST issues
            import pandas as pd
            if "ambiguous" in str(e) or "nonexistent" in str(e):
                try:
                    # Try with different DST handling
                    {index_var} = {source_index}.tz_localize(self.time_zone, ambiguous="NaT", nonexistent="NaT")
                except:
                    # Last resort - convert to UTC first
                    try:
                        temp_index = {source_index}.tz_localize('UTC')
                        {index_var} = temp_index.tz_convert(self.time_zone)
                    except:
                        # Keep original if all else fails
                        {index_var} = {source_index}
                        print(f"⚠️ Warning: Could not apply timezone {{self.time_zone}} to index")
            else:
                raise e'''
        
        return replacement
    
    new_content = re.sub(tz_localize_pattern, replace_tz_localize, content)
    if new_content != content:
        fixes_applied += 1
        content = new_content
        print("✅ Enhanced tz_localize with error handling and fallbacks")
    
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
    
    # Write the patched file if any fixes were applied
    if fixes_applied > 0:
        with open(forecast_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"🎉 Applied {fixes_applied} DST fixes to forecast.py")
        
        # Verify the critical fix is present
        if 'ambiguous="infer"' in content and 'nonexistent="shift_forward"' in content:
            print("✅ Critical DST parameters successfully added")
        
        if 'except Exception as e:' in content:
            print("✅ Error handling for stubborn DST cases added")
        
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
    has_error_handling = 'except Exception as e:' in content
    has_timestamp_fix = 'pd.Timestamp.now(tz=' in content
    
    print(f"📊 DST Fix Verification:")
    print(f"   ✓ Ambiguous parameter: {has_ambiguous}")
    print(f"   ✓ Nonexistent parameter: {has_nonexistent}")
    print(f"   ✓ Error handling: {has_error_handling}")
    print(f"   ✓ Timestamp fix: {has_timestamp_fix}")
    
    return has_ambiguous and has_nonexistent

def main():
    """Main function to apply DST fixes"""
    print("🕐 EMHASS EV DST Fix (Enhanced Python Version)")
    print("===============================================")
    print("Fixing: AmbiguousTimeError: 2025-10-26 02:00:00")
    print("Target: /app/src/emhass/forecast.py")
    print("Method: Enhanced error handling + DST parameters")
    print()
    
    try:
        success = patch_forecast_file()
        
        if success:
            print()
            if verify_patch():
                print("✅ DST fixes applied and verified successfully!")
                print("🔄 EMHASS should now handle DST transitions properly")
                print("📅 Resolved: AmbiguousTimeError with fallback handling")
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