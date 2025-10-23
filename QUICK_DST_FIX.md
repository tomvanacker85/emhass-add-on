# Quick Fix for DST Error

Your EMHASS EV add-on was encountering this error:

```
pytz.exceptions.AmbiguousTimeError: Cannot infer dst time from 2025-10-26 02:00:00, try using the 'ambiguous' argument
```

## ✅ **SOLUTION APPLIED**

I've added a DST fix that automatically patches the EMHASS forecast.py file at startup to handle timezone transitions properly.

## 🔄 **Next Steps to Apply the Fix**

### 1. Rebuild the EMHASS EV Add-on
In Home Assistant:
1. Go to **Supervisor** → **Add-on Store**
2. Find **EMHASS EV** add-on
3. Click **Rebuild** (or uninstall/reinstall if needed)
4. **Start** the add-on

### 2. Check the Logs
After starting, you should see in the add-on logs:
```
🕐 Applying DST timezone fixes...
🔧 Applying DST fixes to forecast.py
✅ Fixed index tz_localize assignment
✅ Critical DST parameters successfully added
🎉 Applied X DST fixes to forecast.py
```

### 3. Test the EV Optimization
Try running your EV optimization again:
```bash
curl -i -H "Content-Type: application/json" -X POST -d "{}" http://localhost:5003/action/naive-mpc-optim
```

## 🐛 **If You Still Get Errors**

### Check Container Logs
Look for DST fix messages in the add-on logs. If you don't see them, the fix might not be applying.

### Manual Container Testing
If needed, you can test the fix manually:
```bash
# Enter the running container
docker exec -it addon_emhass_ev /bin/bash

# Run the DST fix manually
python3 /app/fix_dst_issues.py

# Check if the fix was applied
grep -n "ambiguous=" /app/src/emhass/forecast.py
```

### Alternative Workaround
If the automatic fix doesn't work, you can temporarily avoid DST issues by:
1. Setting your timezone to UTC in the add-on configuration
2. Using timezone offsets instead of named timezones

## 📅 **Technical Details**

The fix implements the same solution as [PR601](https://github.com/davidusb-geek/emhass/pull/601):
- Adds `ambiguous="infer"` and `nonexistent="shift_forward"` to all `tz_localize()` calls
- Replaces problematic timestamp construction with DST-aware alternatives
- Handles both "spring forward" and "fall back" DST transitions

## 🎯 **Expected Result**

After applying this fix:
- ✅ No more `AmbiguousTimeError` during DST transitions
- ✅ EV optimization works during October/March timezone changes
- ✅ Compatible with all timezone configurations
- ✅ Automatic application on every container restart