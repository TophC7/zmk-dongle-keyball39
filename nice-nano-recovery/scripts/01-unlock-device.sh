#!/bin/bash
# Step 1: Unlock nice!nano with AP protection

echo "========================================="
echo "Step 1: Unlock nice!nano Device"
echo "========================================="
echo
echo "This will remove Access Port Protection from the device."
echo "WARNING: This will erase all flash memory!"
echo
echo "Press Enter to continue or Ctrl+C to cancel..."
read

CONFIG_DIR="$(dirname "$0")/../configs"

echo "Attempting to unlock device..."
sudo openocd -f "$CONFIG_DIR/pi4b-swd.cfg" \
    -c "init" \
    -c "nrf52_recover" \
    -c "exit"

if [ $? -eq 0 ]; then
    echo "✓ Device unlocked successfully!"
else
    echo "✗ Failed to unlock device. Check connections and try again."
    exit 1
fi