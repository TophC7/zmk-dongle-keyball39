# Raspberry Pi and nice!nano Pinout Reference

## Raspberry Pi 4B GPIO Header

```
   3V3  (1) (2)  5V
 GPIO2  (3) (4)  5V
 GPIO3  (5) (6)  GND     <-- Use for Ground
 GPIO4  (7) (8)  GPIO14
   GND  (9) (10) GPIO15
GPIO17 (11) (12) GPIO18
GPIO27 (13) (14) GND     <-- Use for Ground
GPIO22 (15) (16) GPIO23
   3V3 (17) (18) GPIO24  <-- SWDIO
GPIO10 (19) (20) GND     <-- Use for Ground
 GPIO9 (21) (22) GPIO25  <-- SWCLK
GPIO11 (23) (24) GPIO8
   GND (25) (26) GPIO7
 GPIO0 (27) (28) GPIO1
 GPIO5 (29) (30) GND
 GPIO6 (31) (32) GPIO12
GPIO13 (33) (34) GND
GPIO19 (35) (36) GPIO16
GPIO26 (37) (38) GPIO20
   GND (39) (40) GPIO21
```

### Connection Summary for SWD

| Function | Physical Pin | GPIO Number | Wire Color (suggestion) |
|----------|-------------|-------------|------------------------|
| SWDIO    | 18          | GPIO 24     | Blue                   |
| SWCLK    | 22          | GPIO 25     | Yellow                 |
| GND      | 6/9/14/20   | Ground      | Black                  |

## nice!nano v2 Pinout

### Top View (Component Side)
```
                    [USB-C Port]
            ┌─────────────────────────┐
    RST ────┤ ●                     ● ├──── RST
    GND ────┤ ●                     ● ├──── GND
    GND ────┤ ●                     ● ├──── BAT+
    P0.06 ──┤ ●                     ● ├──── BAT+
    P0.08 ──┤ ●                     ● ├──── P0.17
    P1.11 ──┤ ●                     ● ├──── P0.20
    P0.11 ──┤ ●                     ● ├──── P0.22
    P1.04 ──┤ ●                     ● ├──── P0.24
    P1.06 ──┤ ●                     ● ├──── P1.00
    P0.09 ──┤ ●                     ● ├──── P0.10
    P1.13 ──┤ ●                     ● ├──── P1.02
    VCC ────┤ ●                     ● ├──── VCC
            └─────────────────────────┘
```

### Bottom View (SWD Test Pads)
```
            ┌─────────────────────────┐
            │                         │
            │    ● SWCLK   ● SWDIO   │
            │                         │
            │         ● GND           │
            │                         │
            │      [nRF52840 Chip]   │
            │                         │
            └─────────────────────────┘
```

## SWD Connection Points

The SWD test pads are located on the **bottom** of the nice!nano PCB. They are small circular pads that may require:

1. **Pogo pins** - Spring-loaded pins for temporary connection
2. **Thin wire (30 AWG)** - Can be held in place or temporarily soldered
3. **Test clips** - Small clips designed for PCB test points

### Tips for Reliable Connection

1. **Clean the pads** - Use isopropyl alcohol to clean oxidation
2. **Steady pressure** - If using pogo pins, maintain consistent pressure
3. **Short wires** - Keep wires under 20cm for best signal integrity
4. **Avoid movement** - Secure the board and wires during programming

## Power Requirements

The nice!nano must be powered during SWD operations:

- **USB Power**: Connect USB-C cable to provide power
- **Battery**: Can use battery power but USB is more reliable
- **Current**: ~20mA during programming, spikes during erase

**IMPORTANT**: Never connect 5V directly to the nice!nano pins. Use USB or battery only.

## Common Issues and Solutions

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| All zeros in debug output | No connection | Check SWDIO/SWCLK connections |
| Intermittent connection | Poor contact | Clean pads, use better connection method |
| "Target voltage: 0.0V" | No power | Connect USB cable to nice!nano |
| Works then fails | Wire too long | Use shorter wires (<20cm) |

## Alternative Raspberry Pi Models

While this guide uses Pi 4B, other models work with the same GPIO numbers:

- **Raspberry Pi Zero/Zero W**: Same GPIO, lower current capability
- **Raspberry Pi 3B/3B+**: Identical pinout to Pi 4B
- **Raspberry Pi 5**: Same GPIO numbers, may need different OpenOCD version

## References

- [Raspberry Pi GPIO Documentation](https://www.raspberrypi.org/documentation/usage/gpio/)
- [nice!nano Documentation](https://nicekeyboards.com/docs/nice-nano/)
- [nRF52840 Product Specification](https://infocenter.nordicsemi.com/pdf/nRF52840_PS_v1.1.pdf)