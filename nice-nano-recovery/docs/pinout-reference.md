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
### Connection for SWD

| Function | Physical Pin | GPIO Number
| SWDIO    | 18           | GPIO 24
| SWCLK    | 22           | GPIO 25
| GND      | 6/9/14/20    | Ground