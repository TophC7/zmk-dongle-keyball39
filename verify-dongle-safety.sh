#!/bin/bash

# Safety verification script for Keyball39 dongle configuration
# Run this before building to ensure configuration won't brick your nice!nano

set -e

echo "========================================="
echo "🛡️  Dongle Configuration Safety Check"
echo "========================================="
echo ""

ERRORS=0
WARNINGS=0

# Function to check file exists
check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "❌ ERROR: Missing file: $1"
        ((ERRORS++))
        return 1
    fi
    return 0
}

# Check all required files exist
echo "📁 Checking required files..."
check_file_exists "config/boards/shields/keyball_nano/keyball39_dongle.overlay"
check_file_exists "config/boards/shields/keyball_nano/keyball39_dongle.conf"
check_file_exists "config/boards/shields/keyball_nano/keyball39_left.conf"
check_file_exists "config/boards/shields/keyball_nano/keyball39_right.conf"
check_file_exists "config/boards/shields/keyball_nano/Kconfig.shield"
check_file_exists "config/boards/shields/keyball_nano/Kconfig.defconfig"
echo ""

# Check dongle overlay for dangerous kscan
echo "🔍 Checking dongle overlay safety..."
if grep -q "kscan" config/boards/shields/keyball_nano/keyball39_dongle.overlay 2>/dev/null; then
    if grep -q "kscan.*{" config/boards/shields/keyball_nano/keyball39_dongle.overlay 2>/dev/null; then
        echo "❌ CRITICAL ERROR: Dongle overlay contains kscan definition!"
        echo "   This WILL cause boot issues! The dongle should have NO kscan."
        ((ERRORS++))
    fi
fi

if grep -q "input-gpios" config/boards/shields/keyball_nano/keyball39_dongle.overlay 2>/dev/null; then
    echo "❌ CRITICAL ERROR: Dongle overlay contains input-gpios!"
    echo "   This can brick your bootloader!"
    ((ERRORS++))
fi

if grep -q "matrix-transform" config/boards/shields/keyball_nano/keyball39_dongle.overlay 2>/dev/null; then
    echo "⚠️  WARNING: Dongle overlay contains matrix-transform (not needed for dongle)"
    ((WARNINGS++))
fi

# Check split role configuration
echo "🔍 Checking central/peripheral roles..."

# Dongle must be central
if grep -q "CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y" config/boards/shields/keyball_nano/keyball39_dongle.conf 2>/dev/null; then
    echo "✅ Dongle is correctly configured as CENTRAL"
else
    echo "❌ ERROR: Dongle is not configured as central!"
    echo "   Add CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y to keyball39_dongle.conf"
    ((ERRORS++))
fi

# Left must NOT be central
if grep -q "CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y" config/boards/shields/keyball_nano/keyball39_left.conf 2>/dev/null; then
    echo "❌ ERROR: Left half is incorrectly configured as central!"
    echo "   It should be CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n or omitted"
    ((ERRORS++))
else
    echo "✅ Left half is correctly configured as PERIPHERAL"
fi

# Right must NOT be central
if grep -q "CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y" config/boards/shields/keyball_nano/keyball39_right.conf 2>/dev/null; then
    echo "❌ ERROR: Right half is incorrectly configured as central!"
    echo "   It should be CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n or omitted"
    ((ERRORS++))
else
    echo "✅ Right half is correctly configured as PERIPHERAL"
fi

echo ""

# Check USB configuration
echo "🔍 Checking USB configuration..."
if grep -q "CONFIG_ZMK_USB=y" config/boards/shields/keyball_nano/keyball39_dongle.conf 2>/dev/null; then
    echo "✅ USB output is enabled for dongle"
else
    echo "❌ ERROR: USB output not enabled for dongle!"
    echo "   Add CONFIG_ZMK_USB=y to keyball39_dongle.conf"
    ((ERRORS++))
fi

# Check for UF2 output
if grep -q "CONFIG_BUILD_OUTPUT_UF2=y" config/boards/shields/keyball_nano/keyball39_dongle.conf 2>/dev/null; then
    echo "✅ UF2 output format enabled (bootloader safe)"
else
    echo "⚠️  WARNING: UF2 output not explicitly enabled"
    echo "   Consider adding CONFIG_BUILD_OUTPUT_UF2=y for safety"
    ((WARNINGS++))
fi

echo ""

# Check Kconfig files
echo "🔍 Checking Kconfig configuration..."
if grep -q "SHIELD_KEYBALL39_DONGLE" config/boards/shields/keyball_nano/Kconfig.shield 2>/dev/null; then
    echo "✅ Dongle shield is defined in Kconfig.shield"
else
    echo "❌ ERROR: Dongle shield not defined in Kconfig.shield"
    ((ERRORS++))
fi

# Check build.yaml
echo "🔍 Checking build configuration..."
if grep -q "keyball39_dongle" build.yaml 2>/dev/null; then
    echo "✅ Dongle is included in build.yaml"
else
    echo "⚠️  WARNING: Dongle not found in build.yaml"
    echo "   You may need to build it manually"
    ((WARNINGS++))
fi

echo ""
echo "========================================="

# Summary
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED - Configuration appears SAFE!"
    echo ""
    echo "You can proceed with building the firmware."
    echo "Remember to flash in this order:"
    echo "  1. Dongle first (keyball39_dongle.uf2)"
    echo "  2. Right half (keyball39_right.uf2)"
    echo "  3. Left half (keyball39_left.uf2)"
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  Configuration has $WARNINGS warning(s) but no critical errors."
    echo ""
    echo "Review the warnings above, but it should be safe to proceed."
else
    echo "❌ CRITICAL ERRORS FOUND: $ERRORS error(s), $WARNINGS warning(s)"
    echo ""
    echo "DO NOT BUILD OR FLASH until errors are fixed!"
    echo "This configuration could brick your nice!nano!"
    exit 1
fi

echo "========================================="