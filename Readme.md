# Arcade Breakout for MiSTer

+ FPGA implementation of Arcade _Breakout_(Atari, 1976) for MiSTer.
+ Based on Rev.F schematics.

## Inputs
+ Joypad (Default)
```
   Coin          : R
   Start 1P      : Start
   Start 2P      : Select
   Serve         : A
```
+ Joystick, Paddle and Spinner supported

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

## Note
### VSYNC
+ The original VSYNC is extremely too long compared to NTSC standard and it is overlaped on active video line.
+ This can cause sync problem for some consumer CRTs when you use analog video output.
+ In this core, better VSYNC is regenerated at the final output in order to avoid it.
+ If you prefer the original VSYNC, you can change it from OSD setting.


### DIP-switch
+ DIP-switch settings applied immediately after a change made unlike CPU-based cores.
+ No need to reset even OSD saying *Reset to apply*.

### Reset
+ Reset from OSD forces Q latch to reset state. This is not an original feature.
+ Transition to reset state is equivalent to the game powering-up, the game ending with no credits left or static discharge shock being applied.
+ Resetting right after the game started before serve button pressed causes illegal state, to be specific, the ball will pass through bricks in attract mode. 
This will not happen unless static discharge shock applied to the original game circuit at the same timing. And is resolved by pressing serve button. 

### Remaining coins
+ Breakout has coin accumulator up to 15.
+ But there is no indicator on screen, so we don't know how much is remaining.
+ Original cabinet has a light bulb in start button which indicates whether it is enabled.
+ 1P start button lights up when there is at least one coin left, 2P start button lights up when there are at least two coins left.
+ This feature is not included.

### Serve indicator
+ Original cabinet has a LED in serve button to show whether player can serve.
+ This feature is not included.