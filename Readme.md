# Arcade Breakout for MiSTer

+ FPGA implementation of arcade Atari Breakout(1976) for MiSTer.

## Inputs
+ Keyboard
```
   Coin 1        : 5
   Coin 2        : 6
   Start 1P      : 1, F1
   Start 2P      : 2, F2
   1P Left/Right : Left/Right
   2P Left/Right : A/D
   1P Serve      : LCtrl
   2P Serve      : G
```
+ Joystick, Paddle supported

## ROMs
+ No ROMs needed.
+ Arcade Breakout is made up of discrete logic circuits, that is, there is no CPU and ROM.

## Important notice
+ **The video signal is far from standard.**
+ It is adjusted for stable image output over HDMI.
+ VGA (on IO board) and DirectVideo are not guaranteed.