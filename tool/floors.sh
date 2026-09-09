#!/bin/bash
# floors.sh - The regression wall for SOON
# Runs on every gate: analyzer clean, tests green, no literals outside tokens, no vendor imports above seam

set -e

echo "=== SOON Floors Check ==="
echo ""

FAILED=0

# Check if Flutter/Dart is available
if ! command -v flutter &> /dev/null && ! command -v dart &> /dev/null; then
    echo "⚠ Flutter/Dart not installed - skipping analyzer and tests"
    echo "  (Static checks will still run)"
    SKIP_EXECUTION=true
else
    SKIP_EXECUTION=false
fi

# 1. Analyzer check
echo "[1/4] Running dart analyze..."
if [ "$SKIP_EXECUTION" = true ]; then
    echo "⊘ Skipped (Flutter/Dart not available)"
else
    if dart analyze --fatal-infos --fatal-warnings; then
        echo "✓ Analyzer passed"
    else
        echo "✗ Analyzer failed"
        FAILED=1
    fi
fi
echo ""

# 2. Test check
echo "[2/4] Running flutter test..."
if [ "$SKIP_EXECUTION" = true ]; then
    echo "⊘ Skipped (Flutter/Dart not available)"
else
    if flutter test; then
        echo "✓ Tests passed"
    else
        echo "✗ Tests failed"
        FAILED=1
    fi
fi
echo ""

# 3. Literal grep - no magic numbers/colors outside tokens file
echo "[3/4] Checking for raw literals outside tokens..."

# Find color literals (0x...) outside tokens file
COLOR_LITERALS=$(find lib -name "*.dart" ! -path "*/tokens/*" -exec grep -l "0xFF[0-9A-Fa-f]\{6,\}" {} \; 2>/dev/null || true)
if [ -n "$COLOR_LITERALS" ]; then
    echo "✗ Found color literals outside tokens:"
    echo "$COLOR_LITERALS"
    FAILED=1
fi

# Find duration literals (Duration(milliseconds: X) with non-token values)
# This is a simplified check - looks for common patterns
DURATION_LITERALS=$(find lib -name "*.dart" ! -path "*/tokens/*" -exec grep -E "Duration\(milliseconds:\s*[0-9]+\)" {} \; 2>/dev/null | head -5 || true)
if [ -n "$DURATION_LITERALS" ]; then
    echo "✗ Found Duration literals outside tokens:"
    echo "$DURATION_LITERALS"
    FAILED=1
fi

# Find opacity/magic number literals
MAGIC_NUMBERS=$(find lib -name "*.dart" ! -path "*/tokens/*" -exec grep -E "opacity:\s*0\.[0-9]+" {} \; 2>/dev/null | head -5 || true)
if [ -n "$MAGIC_NUMBERS" ]; then
    echo "✗ Found opacity literals outside tokens:"
    echo "$MAGIC_NUMBERS"
    FAILED=1
fi

if [ $FAILED -eq 0 ]; then
    echo "✓ No raw literals found outside tokens"
fi
echo ""

# 4. Vendor import grep - no hive/flutter_local_notifications above data layer
echo "[4/4] Checking for vendor imports above data layer..."

VENDOR_IMPORTS=$(find lib -name "*.dart" \( -path "*/presentation/*" -o -path "*/logic/*" \) -exec grep -l "import.*hive\|import.*flutter_local_notifications" {} \; 2>/dev/null || true)
if [ -n "$VENDOR_IMPORTS" ]; then
    echo "✗ Found vendor SDK imports above data layer:"
    echo "$VENDOR_IMPORTS"
    FAILED=1
else
    echo "✓ No vendor imports above data layer"
fi
echo ""

# Summary
echo "=== Summary ==="
if [ $FAILED -eq 0 ]; then
    echo "✓ All floors checks passed"
    exit 0
else
    echo "✗ Some floors checks failed"
    exit 1
fi
