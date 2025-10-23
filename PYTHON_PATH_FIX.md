# Python Path Issue Fix - EMHASS EV

## Issue
```
🕐 Applying DST timezone fixes...
/run.sh: line 45: python3: command not found
```

## Root Cause
The EMHASS container uses `uv` (modern Python package manager) and sets up a virtual environment, so `python3` is not directly available in the system PATH during startup.

## ✅ Solution Applied

### 1. Shell Script Alternative
Added `fix_dst_issues.sh` - a pure shell script version of the DST fix that doesn't require Python.

### 2. Multiple Execution Paths
Updated `run.sh` to try multiple approaches:
1. **Shell script** (most reliable) - `fix_dst_issues.sh`
2. **Virtual env Python** - `/app/.venv/bin/python`
3. **UV runner** - `uv run python`
4. **System Python** - `python3` (fallback)

### 3. Better Error Handling
Provides clear feedback about which method is being used and helpful error messages.

## Expected Output After Fix
```
🚗 Starting EMHASS EV Extension v1.3.1...
📁 Creating EV data directory: /share/emhass-ev
📝 Reading EV add-on configuration...
🕐 Applying DST timezone fixes...
📍 Using shell script DST fix
🔧 Applying DST fixes to forecast.py
✅ Fixed tz_localize calls with DST parameters
✅ Critical DST parameters successfully added
🎉 Applied 1 DST fixes to forecast.py
```

## Manual Testing (if needed)
If you want to test the fix manually in the container:

```bash
# Enter the container
docker exec -it addon_emhass_ev /bin/bash

# Test shell script version
/app/fix_dst_issues.sh

# Or test Python version with correct path
/app/.venv/bin/python /app/fix_dst_issues.py

# Verify the fix was applied
grep -n "ambiguous=" /app/src/emhass/forecast.py
```

## Next Steps
1. **Rebuild** the EMHASS EV add-on in Home Assistant
2. **Check logs** - should see shell script DST fix messages
3. **Test optimization** - DST errors should be resolved

The fix is now more robust and should work regardless of the Python environment setup in the container.