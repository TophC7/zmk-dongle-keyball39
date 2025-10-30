#!/bin/bash
# Step 3: Flash the nice!nano bootloader

echo "========================================="
echo "Step 3: Flash nice!nano Bootloader"
echo "========================================="
echo

# Check for bootloader file
BOOTLOADER_FILE="${1:-nice_nano_bootloader-0.6.0_s140_6.1.1.hex}"

if [ ! -f "$BOOTLOADER_FILE" ]; then
    echo "ERROR: Bootloader file not found: $BOOTLOADER_FILE"
    echo
    echo "Usage: $0 [bootloader_file.hex]"
    echo "Default: nice_nano_bootloader-0.6.0_s140_6.1.1.hex"
    echo
    echo "Download from: https://github.com/nice-nano/nice-nano-bootloader/releases"
    exit 1
fi

echo "Found bootloader: $BOOTLOADER_FILE"
echo
echo "This will flash the bootloader to your nice!nano."
echo "Make sure you have completed steps 1 and 2 first!"
echo
echo "Press Enter to continue or Ctrl+C to cancel..."
read

CONFIG_DIR="$(dirname "$0")/../configs"

# Create temporary OpenOCD script for flashing
cat > /tmp/flash-bootloader.cfg << EOF
source $CONFIG_DIR/flash-config.cfg

echo "Flashing bootloader..."
program $BOOTLOADER_FILE verify reset
exit
EOF

echo "Flashing bootloader..."
sudo openocd -f /tmp/flash-bootloader.cfg

if [ $? -eq 0 ]; then
    echo "✓ Bootloader flashed successfully!"
    echo
    echo "Next steps:"
    echo "1. Disconnect SWD wires from nice!nano"
    echo "2. Unplug and replug the nice!nano USB cable"
    echo "3. The device should appear as a USB drive named 'NICENANO'"
    echo "4. You can now drag-and-drop UF2 firmware files to update ZMK"
else
    echo "✗ Flash failed. Try running step 2 (mass erase) again."
    exit 1
fi

rm -f /tmp/flash-bootloader.cfg