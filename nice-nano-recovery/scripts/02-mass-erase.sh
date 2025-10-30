#!/bin/bash
# Step 2: Mass erase the flash memory

echo "========================================="
echo "Step 2: Mass Erase Flash Memory"
echo "========================================="
echo
echo "This will completely erase all flash memory."
echo "Required before flashing new bootloader."
echo
echo "Press Enter to continue or Ctrl+C to cancel..."
read

CONFIG_DIR="$(dirname "$0")/../configs"

echo "Performing mass erase..."
sudo openocd -f "$CONFIG_DIR/pi4b-swd.cfg" \
    -c "init" \
    -c "halt" \
    -c "nrf5 mass_erase" \
    -c "exit"

if [ $? -eq 0 ]; then
    echo "✓ Mass erase completed successfully!"
else
    echo "✗ Mass erase failed. Check device connection."
    exit 1
fi