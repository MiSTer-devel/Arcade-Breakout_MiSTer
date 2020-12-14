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
+ Joypad (Default)
```
   Coin          : R
   Start 1P      : Start
   Start 2P      : Select
   Serve         : A
```
+ Joystick, Paddle supported

## ROMs
+ No ROMs needed.
+ Arcade Breakout is made up of discrete logic circuits, that is, there is no CPU and ROM.

## Placement
+ Please put release files (mra + rbf) as follows.
+ Otherwise DIP-switch settings on OSD will not work.
```
   /_Arcade/<game name>.mra
   /_Arcade/cores/<game rbf>.rbf
```

## Important notice
+ **The video signal is far from standard.**
+ It is adjusted for stable image output over HDMI.
+ VGA (on IO board) and DirectVideo are **not guaranteed**.

## Note
### DIP-switch
+ DIP-switch settings applied immediately after a change made unlike CPU-based cores.
+ No need to reset even OSD saying *Reset to apply*.
+ Rather, it doesn't support resetting.

### Remaining coins
+ Breakout has coin accumulator up to 15.
+ But there is no indicator on screen, so we don't know how much is remaining.
+ Original cabinet has a light bulb in start button which indicates whether it is enabled.
+ 1P start button lights up when there is at least one coin left, 2P start button lights up when there are at least two coins left.
+ This feature is not included.

### Serve indicator
+ Original cabinet has a LED in serve button to show whether player can serve.
+ This feature is not included.