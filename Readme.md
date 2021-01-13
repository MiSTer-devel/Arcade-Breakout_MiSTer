# Arcade Breakout for MiSTer

+ FPGA implementation of arcade Atari Breakout(1976) for MiSTer.

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

## Important notice
+ **The video signal is far from standard.**
+ It is adjusted for stable image output over HDMI.
+ VGA (on IO board) and DirectVideo are **not guaranteed**.

## Note
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