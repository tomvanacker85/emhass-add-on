# DST (Daylight Saving Time) Fix for EMHASS EV

## Problem Description

The EMHASS EV add-on was encountering DST transition errors like:

```
pytz.exceptions.AmbiguousTimeError: Cannot infer dst time from 2025-10-26 02:00:00, try using the 'ambiguous' argument
```

This occurs during daylight saving time transitions when:
- **Spring Forward**: 2:00 AM jumps to 3:00 AM (nonexistent time)
- **Fall Back**: 2:00 AM occurs twice (ambiguous time)

## Root Cause

The error originates from the upstream EMHASS forecast.py module calling:
```python
data_15min.index = data_15min.index.tz_localize(self.time_zone)
```

Without the proper DST handling parameters, pandas cannot determine how to handle these edge cases.

## Solution Applied

This fix implements the same solution as [PR601](https://github.com/davidusb-geek/emhass/pull/601) from the upstream EMHASS repository:

### 1. DST Parameter Addition
All `tz_localize()` calls are enhanced with:
```python
.tz_localize(timezone, ambiguous="infer", nonexistent="shift_forward")
```

### 2. Timestamp Construction Fix
Replace DST-problematic timestamp construction:
```python
# OLD (problematic during DST)
pd.Timestamp(datetime.now(), tz=timezone)

# NEW (DST-aware)
pd.Timestamp.now(tz=timezone)
```

## Implementation Details

### Automatic Patching
The fix is applied automatically when the EMHASS EV container starts via:
- `fix_dst_issues.py` - Python script that patches forecast.py
- Applied during container startup in `run.sh`
- Creates backup before modification

### DST Parameters Explained
- **`ambiguous="infer"`**: When time occurs twice (fall back), infer which occurrence based on context
- **`nonexistent="shift_forward"`**: When time doesn't exist (spring forward), use the next valid time

## Verification

The fix includes verification that checks for:
- ✅ Ambiguous parameter present
- ✅ Nonexistent parameter present  
- ✅ Timestamp construction updated

## Testing Scenarios

This fix handles common DST edge cases:
- Australia/Sydney DST transitions (October/April)
- US/Eastern DST transitions (March/November)  
- European DST transitions (March/October)

## Status

✅ **RESOLVED**: The EMHASS EV add-on now includes comprehensive DST handling
✅ **COMPATIBLE**: With all timezone configurations
✅ **AUTOMATIC**: Applied on every container start

## Future

When PR601 is merged upstream, this patch can be removed as the base EMHASS image will include the fixes natively.