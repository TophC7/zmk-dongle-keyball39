# nice!nano Recovery and Bootloader Flash Guide

This toolkit provides a complete solution for recovering and flashing bootloaders to nice!nano boards (nRF52840) using a Raspberry Pi 4B and OpenOCD.

## Background

The nice!nano is a wireless mechanical keyboard controller based on the Nordic nRF52840 chip. Sometimes these boards can become "bricked" or need their bootloader replaced. ST-Link adapters cannot perform recovery on nRF52 chips due to lack of CTRL-AP access, but a Raspberry Pi with GPIO bitbanging can.

## Prerequisites

### Hardware Required
- Raspberry Pi 4B (or similar with GPIO headers)
- nice!nano board
- Jumper wires (3 minimum)
- USB cable for nice!nano power

### Software Required
- OpenOCD compiled with bcm2835gpio support
- nice!nano bootloader hex file

### Installing OpenOCD on Raspberry Pi

```bash
# Install dependencies
sudo apt install git autoconf libtool make pkg-config \
    libusb-1.0-0 libusb-1.0-0-dev libhidapi-dev

# Clone and build OpenOCD
git clone https://github.com/openocd-org/openocd.git
cd openocd
./bootstrap
./configure --enable-sysfsgpio --enable-bcm2835gpio
make -j4
sudo make install
```

## Wiring Connections

### Raspberry Pi 4B Pin Connections

| Pi 4B Physical Pin | GPIO Number | Function | nice!nano Pad |
|-------------------|-------------|----------|---------------|
| Pin 18            | GPIO 24     | SWDIO    | SWDIO         |
| Pin 22            | GPIO 25     | SWCLK    | SWCLK         |
| Pin 6/9/14/20/25  | Ground      | GND      | GND           |

**Note:** The nice!nano must be powered via USB during the entire process.

### nice!nano SWD Pads

The SWD pads are small test points on the bottom of the nice!nano PCB. They are typically labeled:
- **SWDIO** - Serial Wire Debug Data I/O
- **SWCLK** - Serial Wire Debug Clock
- **GND** - Ground

Use thin wire (30 AWG) or pogo pins for reliable connection. Consider temporarily soldering wires if having connection issues.

## Quick Start

### Complete Recovery (Recommended)

```bash
cd nice-nano-recovery
# Download bootloader first if you haven't already
wget https://github.com/nice-nano/nice-nano-bootloader/releases/download/V0.6.0/nice_nano_bootloader-0.6.0_s140_6.1.1.hex

# Run complete recovery
./scripts/complete-recovery.sh nice_nano_bootloader-0.6.0_s140_6.1.1.hex
```

This will:
1. Unlock the device (remove AP protection)
2. Mass erase all flash memory
3. Flash the bootloader
4. Reset the device

## Step-by-Step Manual Process

If the complete recovery fails or you need more control:

### Step 1: Unlock Device (if AP Protected)
```bash
./scripts/01-unlock-device.sh
```

### Step 2: Mass Erase Flash
```bash
./scripts/02-mass-erase.sh
```

### Step 3: Flash Bootloader
```bash
./scripts/03-flash-bootloader.sh nice_nano_bootloader-0.6.0_s140_6.1.1.hex
```

## Troubleshooting

### "Cannot read IDR" or "SWD DPIDR 0x00000000"
- Check wiring connections
- Ensure nice!nano is powered via USB
- Try slower speed in configs/pi4b-swd.cfg (change `adapter speed 1` to `adapter speed 0.1`)
- Check for shorts between SWDIO and SWCLK

### "AP lock engaged"
- This is normal for protected devices
- Run the unlock script or use `nrf52_recover` command
- This will erase all flash memory

### "Failed to write memory" during flash
- Always run mass erase before flashing
- Ensure stable power supply
- Try the complete-recovery.sh script which handles timing properly

### Device doesn't appear as USB drive after flashing
- Disconnect all SWD wires
- Completely power cycle the nice!nano (unplug and replug USB)
- Try double-tapping the reset button
- Check `dmesg` for USB device detection

### ST-Link Error: "unable to connect to the target"
ST-Link adapters **cannot** recover nRF52 devices with AP protection. The error message:
```
A high level adapter (like a ST-Link) you are currently using cannot access
the CTRL-AP so 'nrf52_recover' command will not work.
```
This is why we use the Raspberry Pi GPIO method instead.

## Manual OpenOCD Commands

For debugging or manual control, you can use OpenOCD directly:

```bash
# Start OpenOCD server
sudo openocd -f configs/pi4b-swd.cfg

# In another terminal, connect via telnet
telnet localhost 4444

# Useful commands:
nrf52.dap info                    # Show device info
nrf52.dap apreg 1 0x0c            # Check AP protection status
nrf52_recover                      # Unlock device (erases everything)
nrf5 mass_erase                    # Mass erase flash
flash write_image erase file.hex  # Write hex file to flash
reset run                          # Reset and run
```

## Configuration Files

- `configs/pi4b-swd.cfg` - Basic SWD connection config (1 kHz speed)
- `configs/flash-config.cfg` - Optimized for flashing (100 kHz speed)

You can adjust the speed by changing the `adapter speed` value. Lower values are more reliable but slower.

## References

- [Original nRF52 Recovery Guide](https://gist.github.com/tstellanova/8c8509ae3dd4f58697c3b487dc3393b2)
- [nice!nano Troubleshooting Guide](https://nicekeyboards.com/docs/nice-nano/troubleshooting/)
- [OpenOCD Documentation](http://openocd.org/doc/html/index.html)
- [nice!nano Bootloader Releases](https://github.com/nice-nano/nice-nano-bootloader/releases)

## Working Configuration Summary

The successful recovery process that worked:

1. **Connection:** Pi 4B GPIO 24/25 to nice!nano SWDIO/SWCLK
2. **Speed:** Start with 1 kHz for connection, 100 kHz for flashing
3. **Process:** Mass erase FIRST, then flash with `program` command
4. **Power:** nice!nano must be powered via USB throughout

## License

This recovery toolkit is provided as-is for educational and recovery purposes.

## Support

For nice!nano specific issues, consult the [nice!nano documentation](https://nicekeyboards.com/docs/nice-nano/).

For ZMK firmware issues, see the [ZMK documentation](https://zmk.dev/).