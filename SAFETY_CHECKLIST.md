# 🛡️ SAFETY CHECKLIST - Keyball39 Dongle Configuration

## ✅ Critical Fixes Applied

### 1. **FIXED: Dongle Overlay**
- ❌ **DANGEROUS (old)**: Empty kscan with `input-gpios = <>`
- ✅ **SAFE (new)**: No kscan defined at all (dongle has no physical keys)

### 2. **FIXED: Central/Peripheral Roles**
- ❌ **WRONG (old)**: Left half was configured as central
- ✅ **CORRECT (new)**: Only dongle is central, both halves are peripherals

### 3. **FIXED: USB VID/PID**
- ❌ **RISKY (old)**: Using Seeed Studio VID (0x2886)
- ✅ **SAFE (new)**: Using generic test VID/PID (0x1209/0x0001)

## 🔍 Pre-Flash Verification Steps

### Step 1: Verify Configuration Files
Check that these files exist and have the correct content:

1. **`keyball39_dongle.overlay`** - Should be nearly empty:
   ```dtsi
   / {
       /* Dongle has no physical keys - no kscan needed */
       /* It only acts as a wireless receiver */
   };
   ```

2. **`keyball39_dongle.conf`** - Must have:
   - `CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y` (dongle is central)
   - `CONFIG_ZMK_USB=y` (USB output enabled)
   - `CONFIG_BUILD_OUTPUT_UF2=y` (bootloader protection)

3. **`keyball39_left.conf`** - Must have:
   - `CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n` (left is peripheral)

4. **`keyball39_right.conf`** - Must have:
   - `CONFIG_ZMK_SPLIT_ROLE_CENTRAL=n` (right is peripheral)

### Step 2: Build Verification
```bash
# Check the build output for any warnings about:
# - GPIO conflicts
# - Missing device tree nodes
# - Undefined kscans
# - USB configuration errors
```

### Step 3: Firmware Size Check
- ✅ **SAFE**: UF2 files should be between 200KB - 800KB
- ❌ **SUSPICIOUS**: Files under 100KB or over 1MB

## 🚨 Red Flags - DO NOT FLASH IF YOU SEE:

1. **Build Warnings About:**
   - "undefined reference to kscan"
   - "GPIO pin conflict"
   - "invalid device tree"
   - "bootloader region overlap"

2. **Configuration Issues:**
   - Multiple devices set as `ROLE_CENTRAL`
   - Empty or invalid GPIO configurations
   - Missing USB configuration for dongle

3. **File Issues:**
   - Dongle overlay with kscan definitions
   - Matrix transform in dongle overlay
   - Physical key mappings for dongle

## 🔧 Emergency Recovery Plan

If something goes wrong:

1. **Bootloader Recovery Mode:**
   - Power off the nice!nano
   - Hold the RST button while plugging in USB
   - Double-tap RST quickly (should see drive appear)

2. **If Bootloader Won't Start:**
   - Use the SWD recovery method in your recovery folder
   - Connect via SWD pins using your recovery scripts

3. **Safe Recovery Firmware:**
   - Always keep a copy of `settings_reset.uf2`
   - Have a known-good firmware backup

## 📋 Final Pre-Flight Checklist

Before flashing ANY firmware:

- [ ] Backed up current working firmware
- [ ] Verified dongle.overlay has NO kscan
- [ ] Confirmed only dongle is ROLE_CENTRAL
- [ ] Build completed without GPIO warnings
- [ ] UF2 files are reasonable size (200-800KB)
- [ ] Have settings_reset.uf2 ready
- [ ] Recovery tools accessible if needed
- [ ] Battery charged on keyboard halves

## 🎯 Safe Flashing Order

1. **TEST FIRST**: Flash dongle to a spare nice!nano if available
2. Flash dongle (least risk - no existing config)
3. Flash right half
4. Flash left half (has mouse sensor - flash last)

## ⚡ Quick Verification Script

Run this to check your configuration:

```bash
#!/bin/bash
echo "Checking dongle configuration safety..."

# Check overlay doesn't have kscan
if grep -q "kscan" config/boards/shields/keyball_nano/keyball39_dongle.overlay; then
    echo "❌ DANGER: Dongle overlay contains kscan!"
    exit 1
fi

# Check role configuration
if grep -q "CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y" config/boards/shields/keyball_nano/keyball39_dongle.conf; then
    echo "✅ Dongle is central"
else
    echo "❌ ERROR: Dongle is not set as central!"
    exit 1
fi

if grep -q "CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y" config/boards/shields/keyball_nano/keyball39_left.conf; then
    echo "❌ ERROR: Left is incorrectly set as central!"
    exit 1
fi

if grep -q "CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y" config/boards/shields/keyball_nano/keyball39_right.conf; then
    echo "❌ ERROR: Right is incorrectly set as central!"
    exit 1
fi

echo "✅ Configuration appears SAFE to build"
```

## 📝 Notes

- The dongle nice!nano will ONLY act as a USB receiver
- It has NO physical keys or matrix scanning
- Both keyboard halves connect to it wirelessly
- The dongle must always be powered via USB

**Remember**: When in doubt, DON'T flash. Ask for help first!