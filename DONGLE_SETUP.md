# Keyball39 Dongle Setup Guide

## Overview
The dongle acts as a USB receiver that wirelessly connects to both halves of your Keyball39 split keyboard, eliminating the need for cables between the keyboard and computer.

## Architecture
- **Dongle**: Central device (USB receiver) - connects to computer
- **Left Half**: Peripheral device - connects wirelessly to dongle
- **Right Half**: Peripheral device - connects wirelessly to dongle

## Files Created
1. `config/boards/shields/keyball_nano/keyball39_dongle.overlay` - Device tree overlay
2. `config/boards/shields/keyball_nano/keyball39_dongle.conf` - Dongle configuration
3. Updated `build.yaml` to include dongle build target
4. Updated left/right `.conf` files for peripheral mode

## Building the Firmware

### Using GitHub Actions
Push your changes and the workflow will automatically build all targets including:
- `keyball39_left` - Left half firmware
- `keyball39_right` - Right half firmware
- `keyball39_dongle` - Dongle firmware
- `settings_reset` - Settings reset firmware (if needed)

### Local Build (if configured)
```bash
# Build dongle firmware
west build -p -b nice_nano_v2 -- -DSHIELD=keyball39_dongle

# Build left half
west build -p -b nice_nano_v2 -- -DSHIELD="keyball39_left nice_view_adapter nice_view"

# Build right half
west build -p -b nice_nano_v2 -- -DSHIELD="keyball39_right nice_view_adapter nice_view"
```

## Flashing Instructions

### Required Hardware
- 3x nice!nano v2 boards (one for dongle, one for each keyboard half)
- USB cable for flashing

### Flashing Process

1. **Flash the Dongle First**
   - Connect the nice!nano designated for the dongle via USB
   - Double-tap RST to enter bootloader mode (should appear as storage device)
   - Copy `keyball39_dongle.uf2` to the device
   - Device will reboot automatically

2. **Flash Left Half**
   - Connect left nice!nano via USB
   - Double-tap RST to enter bootloader mode
   - Copy `keyball39_left.uf2` to the device
   - Device will reboot

3. **Flash Right Half**
   - Connect right nice!nano via USB
   - Double-tap RST to enter bootloader mode
   - Copy `keyball39_right.uf2` to the device
   - Device will reboot

## Pairing Process

After flashing, the devices should automatically pair:

1. **Power on all devices**
   - Dongle: Connect to computer via USB (will be powered)
   - Left/Right halves: Turn on using power switch

2. **Automatic Pairing**
   - Devices should connect automatically within 10-30 seconds
   - Left display should show connection status if nice!view is installed

3. **If Pairing Fails**
   - Flash `settings_reset.uf2` to all three devices to clear bonds
   - Re-flash the firmware to each device
   - Try pairing again

## Troubleshooting

### Devices Not Connecting
- Ensure all devices have fresh firmware
- Check battery charge on keyboard halves
- Use settings_reset to clear existing bonds
- Verify CONFIG_ZMK_SPLIT settings in .conf files

### Connection Drops
- Move dongle away from USB 3.0 ports (interference)
- Use a USB extension cable to position dongle better
- Check battery levels
- Reduce wireless interference sources

### Keys Not Working
- Verify the keymap is properly loaded
- Check that the matrix transform matches your layout
- Ensure both halves are connected (check display/LEDs)

## LED Status Indicators (if configured)
- **Solid Blue**: Connected and working
- **Blinking Blue**: Searching for connection
- **Red**: Low battery (keyboard halves only)

## Power Management
- Dongle: Always powered via USB, sleep disabled
- Keyboard halves: Will use battery, sleep can be configured
- Current config has sleep disabled for better responsiveness

## Next Steps
1. Build the firmware using GitHub Actions or local build
2. Flash all three nice!nano boards
3. Test the connection and key functionality
4. Adjust configuration as needed in the `.conf` files

## Configuration Tweaks

### For Better Range
Edit `keyball39_dongle.conf`:
```conf
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y  # Maximum transmission power
```

### For Lower Latency
Already configured with optimized connection intervals

### For Debugging
Uncomment in `keyball39_dongle.conf`:
```conf
CONFIG_ZMK_USB_LOGGING=y  # Enable USB logging
```