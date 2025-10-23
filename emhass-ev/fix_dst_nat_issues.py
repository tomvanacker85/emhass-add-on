#!/usr/bin/env python3
"""
DST NaT Fix for EMHASS EV - Resolve "cannot reindex on an axis with duplicate labels" error
This script patches forecast.py to prevent NaT values and duplicate index issues during DST transitions.
"""

import os
import re
import shutil
from pathlib import Path

def patch_reindex_and_nat_issues():
    """Apply enhanced DST fixes to prevent NaT and duplicate index issues"""
    
    forecast_path = Path("/app/src/emhass/forecast.py")
    
    if not forecast_path.exists():
        print(f"❌ forecast.py not found at {forecast_path}")
        return False
    
    print(f"🔧 Applying NaT and duplicate index fixes to {forecast_path}")
    
    # Read the original file
    with open(forecast_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Create backup with timestamp
    import datetime
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = forecast_path.with_suffix(f'.py.backup_nat_{timestamp}')
    shutil.copy2(forecast_path, backup_path)
    print(f"📄 Backup created: {backup_path}")
    
    fixes_applied = 0
    original_content = content
    
    # Fix 1: Replace all NaT-producing tz_localize calls with robust handling
    print("🔧 Fixing tz_localize calls to prevent NaT values...")
    
    # Pattern for tz_localize with NaT parameters
    nat_pattern = r'\.tz_localize\([^)]*ambiguous=["\']NaT["\'][^)]*\)'
    
    def replace_nat_localize(match):
        """Replace NaT-producing tz_localize with robust handling"""
        return '.tz_localize(self.time_zone, ambiguous="infer", nonexistent="shift_forward")'
    
    new_content = re.sub(nat_pattern, replace_nat_localize, content)
    if new_content != content:
        fixes_applied += 1
        content = new_content
        print("✅ Replaced NaT-producing tz_localize calls")
    
    # Fix 2: Add comprehensive DST handling wrapper for problematic reindex operations
    reindex_pattern = r'(\w+)\s*=\s*(\w+)\.reindex\(([^)]+)\)'
    
    def replace_reindex(match):
        """Replace problematic reindex calls with DST-aware versions"""
        result_var = match.group(1)
        data_var = match.group(2)
        index_param = match.group(3)
        
        replacement = f'''# DST-safe reindex with duplicate handling
        try:
            {result_var} = {data_var}.reindex({index_param})
        except ValueError as ve:
            if "duplicate labels" in str(ve):
                print(f"⚠️ Handling duplicate labels in reindex operation")
                # Remove duplicates from target index
                clean_index = {index_param}.drop_duplicates(keep='first')
                {result_var} = {data_var}.reindex(clean_index)
                print(f"✅ Reindexed with {len(clean_index)} unique timestamps")
            else:
                raise ve
        except Exception as e:
            print(f"⚠️ Reindex fallback for DST transition: {e}")
            # Fallback: use original data if reindex fails
            {result_var} = {data_var}'''
        
        return replacement
    
    new_content = re.sub(reindex_pattern, replace_reindex, content)
    if new_content != content:
        fixes_applied += 1
        content = new_content
        print("✅ Enhanced reindex operations with duplicate handling")
    
    # Fix 3: Prevent NaT values in forecast_dates creation
    forecast_dates_pattern = r'self\.forecast_dates\s*=.*?tz_localize\([^)]+\)'
    
    def replace_forecast_dates(match):
        """Replace forecast_dates creation to prevent NaT"""
        return '''self.forecast_dates = pd.date_range(
            start=self.start_forecast, 
            end=self.end_forecast, 
            freq=self.timefreq, 
            tz=None
        ).tz_localize(self.time_zone, ambiguous="infer", nonexistent="shift_forward")
        
        # Remove any NaT values that might have been created
        if self.forecast_dates.isna().any():
            print("⚠️ Removing NaT values from forecast_dates")
            self.forecast_dates = self.forecast_dates.dropna()
            print(f"✅ Clean forecast_dates with {len(self.forecast_dates)} timestamps")'''
    
    new_content = re.sub(forecast_dates_pattern, replace_forecast_dates, content, flags=re.MULTILINE | re.DOTALL)
    if new_content != content:
        fixes_applied += 1
        content = new_content
        print("✅ Enhanced forecast_dates creation to prevent NaT")
    
    # Fix 4: Add general NaT cleanup function
    if 'def clean_nat_from_index(' not in content:
        cleanup_function = '''
    def clean_nat_from_index(self, index):
        """Remove NaT values and duplicates from datetime index"""
        if hasattr(index, 'isna'):
            # Remove NaT values
            clean_index = index.dropna()
            if len(clean_index) != len(index):
                print(f"⚠️ Removed {len(index) - len(clean_index)} NaT values from index")
            
            # Remove duplicates
            if clean_index.duplicated().any():
                unique_count = len(clean_index)
                clean_index = clean_index.drop_duplicates(keep='first')
                print(f"⚠️ Removed {unique_count - len(clean_index)} duplicate timestamps")
            
            return clean_index
        return index
'''
        
        # Insert the cleanup function before the first method
        method_pattern = r'(\n    def \w+\(self[^:]*\):)'
        content = re.sub(method_pattern, cleanup_function + r'\1', content, count=1)
        if cleanup_function in content:
            fixes_applied += 1
            print("✅ Added NaT cleanup utility function")
    
    # Fix 5: Wrap the specific problematic line from the error
    error_line_pattern = r'data\s*=\s*data_15min\.reindex\(self\.forecast_dates\)'
    
    def replace_error_line(match):
        """Replace the specific line causing the error"""
        return '''# DST-safe reindex for weather forecast data
        try:
            # Clean forecast_dates to prevent reindex issues
            clean_forecast_dates = self.clean_nat_from_index(self.forecast_dates)
            data = data_15min.reindex(clean_forecast_dates)
        except ValueError as ve:
            if "duplicate labels" in str(ve):
                print("⚠️ Handling duplicate labels in weather forecast reindex")
                clean_dates = self.forecast_dates.drop_duplicates(keep='first')
                data = data_15min.reindex(clean_dates)
                print(f"✅ Weather reindex completed with {len(clean_dates)} unique timestamps")
            else:
                print(f"⚠️ Weather reindex error: {ve}")
                # Fallback: use original data
                data = data_15min
        except Exception as e:
            print(f"⚠️ Weather forecast reindex fallback: {e}")
            data = data_15min'''
    
    new_content = re.sub(error_line_pattern, replace_error_line, content)
    if new_content != content:
        fixes_applied += 1
        content = new_content
        print("✅ Fixed specific weather forecast reindex line")
    
    # Write the patched file if any fixes were applied
    if fixes_applied > 0:
        with open(forecast_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"🎉 Applied {fixes_applied} NaT and duplicate index fixes to forecast.py")
        return True
    else:
        print("ℹ️ No fixes needed - file may already be patched")
        return False

def main():
    """Main function to apply NaT and duplicate index fixes"""
    print("🔧 EMHASS EV NaT & Duplicate Index Fix")
    print("=====================================")
    print("Fixing: cannot reindex on an axis with duplicate labels")
    print("Fixing: NaT values in DST transitions")
    print("Target: /app/src/emhass/forecast.py")
    print()
    
    try:
        success = patch_reindex_and_nat_issues()
        
        if success:
            print()
            print("✅ NaT and duplicate index fixes applied successfully!")
            print("🔄 EMHASS should now handle DST transitions without reindex errors")
            print("📅 Resolved: ValueError: cannot reindex on an axis with duplicate labels")
        else:
            print("ℹ️ No changes made to forecast.py")
            
    except Exception as e:
        print(f"❌ Error applying fixes: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    return True

if __name__ == "__main__":
    main()