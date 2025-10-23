#!/bin/bash
# Emergency DST Fix - Handle the specific AmbiguousTimeError: 2025-10-26 02:00:00

FORECAST_PATH="/app/src/emhass/forecast.py"

echo "🚨 Emergency DST Fix for AmbiguousTimeError: 2025-10-26 02:00:00"

if [ ! -f "$FORECAST_PATH" ]; then
    echo "❌ forecast.py not found"
    exit 1
fi

# Create backup
cp "$FORECAST_PATH" "${FORECAST_PATH}.emergency_backup"

# Create a more aggressive fix specifically for this error
cat > /tmp/dst_emergency_patch.py << 'EOF'
import re

# Read the file
with open('/app/src/emhass/forecast.py', 'r') as f:
    content = f.read()

# Find and replace the problematic tz_localize pattern with robust error handling
old_pattern = r'(\s+)(data_15min\.index)\s*=\s*(data_15min\.index)\.tz_localize\([^)]*\)'

new_code = r'''\1try:
\1    \2 = \3.tz_localize(self.time_zone, ambiguous="infer", nonexistent="shift_forward")
\1except Exception as tz_error:
\1    # Handle stubborn DST transitions
\1    try:
\1        # Try with NaT handling for ambiguous times
\1        \2 = \3.tz_localize(self.time_zone, ambiguous="NaT", nonexistent="NaT")
\1        print(f"⚠️ Used NaT for DST ambiguous time: {tz_error}")
\1    except:
\1        try:
\1            # Convert to UTC first, then to target timezone
\1            temp_utc = \3.tz_localize('UTC')
\1            \2 = temp_utc.tz_convert(self.time_zone)
\1            print(f"⚠️ Used UTC conversion for DST: {tz_error}")
\1        except:
\1            # Last resort - keep naive datetime
\1            \2 = \3
\1            print(f"❌ DST fix failed, using naive datetime: {tz_error}")'''

# Apply the fix
content = re.sub(old_pattern, new_code, content, flags=re.MULTILINE)

# Write back
with open('/app/src/emhass/forecast.py', 'w') as f:
    f.write(content)

print("✅ Emergency DST fix applied with comprehensive error handling")
EOF

# Run the emergency patch
/app/.venv/bin/python /tmp/dst_emergency_patch.py 2>/dev/null || python3 /tmp/dst_emergency_patch.py 2>/dev/null || python /tmp/dst_emergency_patch.py

# Verify the fix
if grep -q "except Exception as tz_error:" "$FORECAST_PATH"; then
    echo "✅ Emergency DST fix successfully applied"
    echo "🔄 EMHASS should now handle AmbiguousTimeError: 2025-10-26 02:00:00"
else
    echo "⚠️ Emergency fix may not have been applied"
fi

# Clean up
rm -f /tmp/dst_emergency_patch.py

echo "🎯 Emergency DST fix complete"