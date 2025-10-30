#!/bin/bash
# Complete recovery process for nice!nano

echo "========================================="
echo "nice!nano Complete Recovery Process"
echo "========================================="
echo
echo "This script will:"
echo "1. Unlock the device (if AP protected)"
echo "2. Mass erase the flash"
echo "3. Flash the bootloader"
echo

# Check for bootloader file
BOOTLOADER_FILE="${1:-nice_nano_bootloader-0.6.0_s140_6.1.1.hex}"

if [ ! -f "$BOOTLOADER_FILE" ]; then
    echo "ERROR: Bootloader file not found: $BOOTLOADER_FILE"
    echo
    echo "Usage: $0 [bootloader_file.hex]"
    echo
    echo "Download the bootloader from:"
    echo "https://github.com/nice-nano/nice-nano-bootloader/releases"
    exit 1
fi

echo "Using bootloader: $BOOTLOADER_FILE"
echo
echo "WARNING: This will COMPLETELY ERASE your nice!nano!"
echo "Press Enter to continue or Ctrl+C to cancel..."
read

CONFIG_DIR="$(dirname "$0")/../configs"

# Step 1: Try to unlock (will fail gracefully if already unlocked)
echo
echo "Step 1: Checking AP protection..."
sudo openocd -f "$CONFIG_DIR/pi4b-swd.cfg" \
    -c "init" \
    -c "nrf52_recover" \
    -c "exit" 2>&1 | grep -q "AP lock engaged" && echo "Device was locked, now unlocked"

# Step 2: Mass erase
echo
echo "Step 2: Mass erasing flash..."
sudo openocd -f "$CONFIG_DIR/pi4b-swd.cfg" \
    -c "init" \
    -c "halt" \
    -c "nrf5 mass_erase" \
    -c "exit"

if [ $? -ne 0 ]; then
    echo "✗ Mass erase failed!"
    exit 1
fi
echo "✓ Mass erase complete"

# Step 3: Flash bootloader with slower config
echo
echo "Step 3: Flashing bootloader..."

cat > /tmp/flash-bootloader.cfg << EOF
source $CONFIG_DIR/flash-config.cfg
program $BOOTLOADER_FILE verify reset
exit
EOF

sudo openocd -f /tmp/flash-bootloader.cfg

if [ $? -eq 0 ]; then
    echo
    echo "========================================="
    echo "✓ RECOVERY COMPLETE!"
    echo "========================================="
    echo
    echo "Next steps:"
    echo "1. Disconnect all SWD wires from the nice!nano"
    echo "2. Unplug the USB cable from the nice!nano"
    echo "3. Reconnect ONLY the USB cable"
    echo "4. The device should appear as 'NICENANO' USB drive"
    echo "5. Drag and drop your .uf2 firmware file to update"
    echo
    echo "If the USB drive doesn't appear:"
    echo "- Try double-tapping the reset button"
    echo "- Check dmesg for USB device detection"
else
    echo "✗ Bootloader flash failed!"
    exit 1
fi

rm -f /tmp/flash-bootloader.cfg