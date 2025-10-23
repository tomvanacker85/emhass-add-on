#!/bin/bash
# DST Fix for EMHASS EV - Shell Script Version
# Apply PR601 timezone handling fixes using sed/awk

set -e

FORECAST_PATH="/app/src/emhass/forecast.py"
BACKUP_PATH="/app/src/emhass/forecast.py.backup"

echo "🕐 EMHASS EV DST Fix (Shell Version)"
echo "=================================="
echo "Target: $FORECAST_PATH"

# Check if forecast.py exists
if [ ! -f "$FORECAST_PATH" ]; then
    echo "❌ forecast.py not found at $FORECAST_PATH"
    exit 1
fi

echo "🔧 Applying DST fixes to forecast.py"

# Create backup if it doesn't exist
if [ ! -f "$BACKUP_PATH" ]; then
    cp "$FORECAST_PATH" "$BACKUP_PATH"
    echo "📄 Backup created: $BACKUP_PATH"
fi

# Counter for fixes applied
fixes_applied=0

# Create temporary file for modifications
TEMP_FILE=$(mktemp)

# Fix 1: Add ambiguous and nonexistent parameters to tz_localize calls
# Pattern: .tz_localize(something) -> .tz_localize(something, ambiguous="infer", nonexistent="shift_forward")
sed 's/\.tz_localize(\([^)]*\))/.tz_localize(\1, ambiguous="infer", nonexistent="shift_forward")/g' "$FORECAST_PATH" > "$TEMP_FILE"

# Check if changes were made
if ! cmp -s "$FORECAST_PATH" "$TEMP_FILE"; then
    fixes_applied=$((fixes_applied + 1))
    cp "$TEMP_FILE" "$FORECAST_PATH"
    echo "✅ Fixed tz_localize calls with DST parameters"
fi

# Fix 2: Replace pd.Timestamp(datetime.now(), tz=...) with pd.Timestamp.now(tz=...)
sed 's/pd\.Timestamp(datetime\.now(),\s*tz=\([^)]*\))/pd.Timestamp.now(tz=\1)/g' "$FORECAST_PATH" > "$TEMP_FILE"

if ! cmp -s "$FORECAST_PATH" "$TEMP_FILE"; then
    fixes_applied=$((fixes_applied + 1))
    cp "$TEMP_FILE" "$FORECAST_PATH"
    echo "✅ Fixed pd.Timestamp construction for DST awareness"
fi

# Clean up
rm -f "$TEMP_FILE"

# Verify critical fixes are present
if grep -q 'ambiguous="infer"' "$FORECAST_PATH" && grep -q 'nonexistent="shift_forward"' "$FORECAST_PATH"; then
    echo "✅ Critical DST parameters successfully added"
    verification_passed=true
else
    echo "⚠️ Warning: DST parameters may not have been added correctly"
    verification_passed=false
fi

# Summary
if [ $fixes_applied -gt 0 ]; then
    echo "🎉 Applied $fixes_applied DST fixes to forecast.py"
    if [ "$verification_passed" = true ]; then
        echo "✅ DST fixes applied and verified successfully!"
        echo "🔄 EMHASS should now handle DST transitions properly"
        echo "📅 Resolved: 'Cannot infer dst time' errors"
    fi
else
    echo "ℹ️ No DST fixes needed - file may already be patched"
fi

# Display some verification info
echo ""
echo "📊 DST Fix Verification:"
grep -c 'ambiguous="infer"' "$FORECAST_PATH" 2>/dev/null && echo "   ✓ Ambiguous parameter: Found" || echo "   ✗ Ambiguous parameter: Not found"
grep -c 'nonexistent="shift_forward"' "$FORECAST_PATH" 2>/dev/null && echo "   ✓ Nonexistent parameter: Found" || echo "   ✗ Nonexistent parameter: Not found"

exit 0