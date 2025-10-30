#!/bin/bash
# Download the latest nice!nano bootloader

echo "Downloading nice!nano bootloader v0.6.0..."
wget https://github.com/nice-nano/nice-nano-bootloader/releases/download/V0.6.0/nice_nano_bootloader-0.6.0_s140_6.1.1.hex

if [ $? -eq 0 ]; then
    echo "✓ Bootloader downloaded successfully!"
    echo "File: nice_nano_bootloader-0.6.0_s140_6.1.1.hex"
else
    echo "✗ Failed to download bootloader"
    echo "Please download manually from:"
    echo "https://github.com/nice-nano/nice-nano-bootloader/releases"
fi