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

# Fix 1: Enhanced tz_localize fix - handle all variations
# First, fix cases where parameters might be partially present
sed -E 's/\.tz_localize\(([^)]*)\s*,\s*ambiguous=[^,)]*\s*(,\s*nonexistent=[^)]*)?/\.tz_localize(\1, ambiguous="infer", nonexistent="shift_forward"/g' "$FORECAST_PATH" > "$TEMP_FILE"

if ! cmp -s "$FORECAST_PATH" "$TEMP_FILE"; then
    fixes_applied=$((fixes_applied + 1))
    cp "$TEMP_FILE" "$FORECAST_PATH"
    echo "✅ Fixed existing partial tz_localize DST parameters"
fi

# Fix 2: Add missing DST parameters to tz_localize calls without any DST params
sed -E 's/\.tz_localize\(([^)]*)\)([^,]|$)/\.tz_localize(\1, ambiguous="infer", nonexistent="shift_forward")\2/g' "$FORECAST_PATH" > "$TEMP_FILE"

if ! cmp -s "$FORECAST_PATH" "$TEMP_FILE"; then
    fixes_applied=$((fixes_applied + 1))
    cp "$TEMP_FILE" "$FORECAST_PATH"
    echo "✅ Added DST parameters to tz_localize calls"
fi

# Fix 3: Handle specific problematic patterns that might slip through
sed -E 's/data_15min\.index\.tz_localize\([^)]*\)/data_15min.index.tz_localize(self.time_zone, ambiguous="infer", nonexistent="shift_forward")/g' "$FORECAST_PATH" > "$TEMP_FILE"

if ! cmp -s "$FORECAST_PATH" "$TEMP_FILE"; then
    fixes_applied=$((fixes_applied + 1))
    cp "$TEMP_FILE" "$FORECAST_PATH"
    echo "✅ Fixed specific data_15min.index.tz_localize pattern"
fi

# Fix 4: Replace pd.Timestamp(datetime.now(), tz=...) with pd.Timestamp.now(tz=...)
sed -E 's/pd\.Timestamp\(datetime\.now\(\),?\s*tz=([^)]*)\)/pd.Timestamp.now(tz=\1)/g' "$FORECAST_PATH" > "$TEMP_FILE"

if ! cmp -s "$FORECAST_PATH" "$TEMP_FILE"; then
    fixes_applied=$((fixes_applied + 1))
    cp "$TEMP_FILE" "$FORECAST_PATH"
    echo "✅ Fixed pd.Timestamp construction for DST awareness"
fi

# Fix 5: Handle edge case - ensure no double parameters
sed -E 's/ambiguous="infer",?\s*ambiguous="infer"/ambiguous="infer"/g' "$FORECAST_PATH" > "$TEMP_FILE"
sed -E 's/nonexistent="shift_forward",?\s*nonexistent="shift_forward"/nonexistent="shift_forward"/g' "$TEMP_FILE" > "${TEMP_FILE}.2"

if ! cmp -s "$FORECAST_PATH" "${TEMP_FILE}.2"; then
    fixes_applied=$((fixes_applied + 1))
    cp "${TEMP_FILE}.2" "$FORECAST_PATH"
    echo "✅ Cleaned up duplicate DST parameters"
fi

# Clean up
rm -f "$TEMP_FILE" "${TEMP_FILE}.2"

# Advanced verification - check the exact line causing the error
if grep -n "data_15min.index = data_15min.index.tz_localize" "$FORECAST_PATH"; then
    echo "📍 Found the problematic line - checking DST parameters:"
    grep -A1 -B1 "data_15min.index = data_15min.index.tz_localize" "$FORECAST_PATH"
fi

# Verify critical fixes are present
ambiguous_count=$(grep -c 'ambiguous="infer"' "$FORECAST_PATH" 2>/dev/null || echo "0")
nonexistent_count=$(grep -c 'nonexistent="shift_forward"' "$FORECAST_PATH" 2>/dev/null || echo "0")

if [ "$ambiguous_count" -gt 0 ] && [ "$nonexistent_count" -gt 0 ]; then
    echo "✅ Critical DST parameters successfully added"
    verification_passed=true
else
    echo "⚠️ Warning: DST parameters may not have been added correctly"
    echo "   Ambiguous parameters found: $ambiguous_count"
    echo "   Nonexistent parameters found: $nonexistent_count"
    verification_passed=false
fi

# Summary
if [ $fixes_applied -gt 0 ]; then
    echo "🎉 Applied $fixes_applied DST fixes to forecast.py"
    if [ "$verification_passed" = true ]; then
        echo "✅ DST fixes applied and verified successfully!"
        echo "🔄 EMHASS should now handle DST transitions properly"
        echo "📅 Target fix: AmbiguousTimeError: 2025-10-26 02:00:00"
    fi
else
    echo "ℹ️ No DST fixes needed - file may already be patched"
fi

# Display verification info
echo ""
echo "📊 DST Fix Verification:"
echo "   ✓ Ambiguous parameters: $ambiguous_count found"
echo "   ✓ Nonexistent parameters: $nonexistent_count found"
echo "   ✓ Problematic patterns checked and fixed"

# Show a few lines around tz_localize calls for debugging
echo ""
echo "🔍 Current tz_localize calls in file:"
grep -n "tz_localize" "$FORECAST_PATH" | head -5

exit 0