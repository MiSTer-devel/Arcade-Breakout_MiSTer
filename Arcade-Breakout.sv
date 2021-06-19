//============================================================================
//  Arcade "Breakout" (Arari, 1976) for MiSTer.
//  Based on Rev.F schematics
//
//  Copyright (c) 2020-2021 bellwood420
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
  //Master input clock
  input         CLK_50M,

  //Async reset from top-level module.
  //Can be used as initial reset.
  input         RESET,

  //Must be passed to hps_io module
  inout  [45:0] HPS_BUS,

  //Base video clock. Usually equals to CLK_SYS.
  output        CLK_VIDEO,

  //Multiple resolutions are supported using different CE_PIXEL rates.
  //Must be based on CLK_VIDEO
  output        CE_PIXEL,

  //Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
  //if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
  output [12:0] VIDEO_ARX,
  output [12:0] VIDEO_ARY,

  output  [7:0] VGA_R,
  output  [7:0] VGA_G,
  output  [7:0] VGA_B,
  output        VGA_HS,
  output        VGA_VS,
  output        VGA_DE,    // = ~(VBlank | HBlank)
  output        VGA_F1,
  output [1:0]  VGA_SL,
  output        VGA_SCALER, // Force VGA scaler

  input  [11:0] HDMI_WIDTH,
  input  [11:0] HDMI_HEIGHT,

`ifdef USE_FB
  // Use framebuffer in DDRAM (USE_FB=1 in qsf)
  // FB_FORMAT:
  //    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
  //    [3]   : 0=16bits 565 1=16bits 1555
  //    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
  //
  // FB_STRIDE either 0 (rounded to 256 bytes) or multiple of 16 bytes.
  output        FB_EN,
  output  [4:0] FB_FORMAT,
  output [11:0] FB_WIDTH,
  output [11:0] FB_HEIGHT,
  output [31:0] FB_BASE,
  output [13:0] FB_STRIDE,
  input         FB_VBL,
  input         FB_LL,
  output        FB_FORCE_BLANK,

  // Palette control for 8bit modes.
  // Ignored for other video modes.
  output        FB_PAL_CLK,
  output  [7:0] FB_PAL_ADDR,
  output [23:0] FB_PAL_DOUT,
  input  [23:0] FB_PAL_DIN,
  output        FB_PAL_WR,
`endif

  output        LED_USER,  // 1 - ON, 0 - OFF.

  // b[1]: 0 - LED status is system status OR'd with b[0]
  //       1 - LED status is controled solely by b[0]
  // hint: supply 2'b00 to let the system control the LED.
  output  [1:0] LED_POWER,
  output  [1:0] LED_DISK,

  // I/O board button press simulation (active high)
  // b[1]: user button
  // b[0]: osd button
  output  [1:0] BUTTONS,

  input         CLK_AUDIO, // 24.576 MHz
  output [15:0] AUDIO_L,
  output [15:0] AUDIO_R,
  output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
  output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

  //ADC
  inout   [3:0] ADC_BUS,

  //SD-SPI
  output        SD_SCK,
  output        SD_MOSI,
  input         SD_MISO,
  output        SD_CS,
  input         SD_CD,

`ifdef USE_DDRAM
  //High latency DDR3 RAM interface
  //Use for non-critical time purposes
  output        DDRAM_CLK,
  input         DDRAM_BUSY,
  output  [7:0] DDRAM_BURSTCNT,
  output [28:0] DDRAM_ADDR,
  input  [63:0] DDRAM_DOUT,
  input         DDRAM_DOUT_READY,
  output        DDRAM_RD,
  output [63:0] DDRAM_DIN,
  output  [7:0] DDRAM_BE,
  output        DDRAM_WE,
`endif

`ifdef USE_SDRAM
  //SDRAM interface with lower latency
  output        SDRAM_CLK,
  output        SDRAM_CKE,
  output [12:0] SDRAM_A,
  output  [1:0] SDRAM_BA,
  inout  [15:0] SDRAM_DQ,
  output        SDRAM_DQML,
  output        SDRAM_DQMH,
  output        SDRAM_nCS,
  output        SDRAM_nCAS,
  output        SDRAM_nRAS,
  output        SDRAM_nWE,
`endif

`ifdef DUAL_SDRAM
  //Secondary SDRAM
  input         SDRAM2_EN,
  output        SDRAM2_CLK,
  output [12:0] SDRAM2_A,
  output  [1:0] SDRAM2_BA,
  inout  [15:0] SDRAM2_DQ,
  output        SDRAM2_nCS,
  output        SDRAM2_nCAS,
  output        SDRAM2_nRAS,
  output        SDRAM2_nWE,
`endif

  input         UART_CTS,
  output        UART_RTS,
  input         UART_RXD,
  output        UART_TXD,
  output        UART_DTR,
  input         UART_DSR,

  // Open-drain User port.
  // 0 - D+/RX
  // 1 - D-/TX
  // 2..6 - USR2..USR6
  // Set USER_OUT to 1 to read from USER_IN.
  input   [6:0] USER_IN,
  output  [6:0] USER_OUT,

  input         OSD_STATUS
);

///////////////////////////////////////////////////////////////////////////////////////////
//    Default values for ports not used in this core
///////////////////////////////////////////////////////////////////////////////////////////
assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
//assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
//assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign LED_USER = 0;
assign BUTTONS = 0;

assign {FB_PAL_CLK, FB_FORCE_BLANK, FB_PAL_ADDR, FB_PAL_DOUT, FB_PAL_WR} = '0;

assign VGA_F1 = 0;
assign VGA_SCALER = 0;

///////////////////////////////////////////////////////////////////////////////////////////
//    CONF STR
///////////////////////////////////////////////////////////////////////////////////////////
`include "build_id.v"
localparam CONF_STR = {
  "A.BREAKOUT;;",
  "-;",
  "H0O23,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
  "O46,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
  "O7,Orientation,Vert,Horiz;",
  "OR,VSYNC,TV Compatible,Original;",
  "-;",
  "DIP;",
  "-;",
  "OFH,Control P1,Digital,X,Y,Paddle,Spinner;",
  "O8,Control P1 Invert,No,Yes;",
  "OIK,Control P2,Digital,X,Y,Paddle,Spinner;",
  "O9,Control P2 Invert,No,Yes;",
  "-;",
  "ON,Digital Paddle Speed,Slow,Fast;",
  "OPQ,Spinner Paddle Speed,Slow,Medium,Fast;",
  "-;",
  //"OO,TEST PADDLE,Off,On;",
  "R0,Reset;",
  "J1,Coin,Start1P,Start2P,Serve;",
  "jn,R,Start,Select,A|P;",
  "V,v",`BUILD_DATE
};

/////////////////////////////////////////////////////////////////////////
//      CLOCKS
/////////////////////////////////////////////////////////////////////////
wire clk_sys;
pll pll
(
  .refclk(CLK_50M),
  .rst(0),
  .outclk_0(clk_sys) // System clock - 57.272 MHz
);

// Source clock - 14.318 MHz for source of main clock
reg CLK_SRC;
always @(posedge clk_sys) begin
  reg [1:0]  div;
  div <= div + 2'd1;
  CLK_SRC <= div[1];
end

// Reset signal
wire reset = RESET | status[0] | buttons[1];

/////////////////////////////////////////////////////////////////////////
//      HPS IO
/////////////////////////////////////////////////////////////////////////
wire [31:0] joystick_0, joystick_1;
wire [15:0] joystick_analog_0, joystick_analog_1;
wire  [7:0] paddle_0, paddle_1;
wire  [8:0] spinner_0, spinner_1;
wire  [1:0] buttons;
wire [63:0] status;
wire [21:0] gamma_bus;
wire        ioctl_wr;
wire [26:0] ioctl_addr;
wire  [7:0] ioctl_dout;
wire [15:0] ioctl_index;
wire        direct_video;
wire        forced_scandoubler;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
  .clk_sys,
  .HPS_BUS(HPS_BUS),
  .EXT_BUS(),
  .gamma_bus,

  .conf_str(CONF_STR),

  .forced_scandoubler,
  .direct_video,
  .status_menumask(direct_video),

  .ioctl_wr,
  .ioctl_addr,
  .ioctl_dout,
  .ioctl_index,

  .joystick_0,
  .joystick_1,
  .joystick_analog_0,
  .joystick_analog_1,
  .paddle_0,
  .paddle_1,
  .spinner_0,
  .spinner_1,

  .buttons,
  .status
);

// Load DIP-SW
reg [7:0] dipsw[8];
always @(posedge clk_sys) begin
  if (ioctl_wr && (ioctl_index==254) && !ioctl_addr[24:3])
    dipsw[ioctl_addr[2:0]] <= ioctl_dout;
end
wire [7:0] sw = dipsw[0];

/////////////////////////////////////////////////////////////////////////
//      VIDEO
/////////////////////////////////////////////////////////////////////////

// Aspect ratio
wire [1:0] ar = status[3:2];
assign VIDEO_ARX = (!ar) ? (status[7] ? 12'd4 : 12'd3) : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? (status[7] ? 12'd3 : 12'd4) : 12'd0;

// Monochrome video signal
wire video;

// Color overlay
wire red_row_p1    = HCNT >= 8'd64 && HCNT <= 8'd71;
wire amber_row_p1  = HCNT >= 8'd72 && HCNT <= 8'd79;
wire green_row_p1  = HCNT >= 8'd80 && HCNT <= 8'd87;
wire yellow_row_p1 = HCNT >= 8'd88 && HCNT <= 8'd95;

wire red_row_p2    = HCNT >= 8'd184 && HCNT <= 8'd191;
wire amber_row_p2  = HCNT >= 8'd176 && HCNT <= 8'd183;
wire green_row_p2  = HCNT >= 8'd168 && HCNT <= 8'd175;
wire yellow_row_p2 = HCNT >= 8'd160 && HCNT <= 8'd167;

wire red_row    = red_row_p1    || (S2 & red_row_p2);
wire amber_row  = amber_row_p1  || (S2 & amber_row_p2);
wire green_row  = green_row_p1  || (S2 & green_row_p2);
wire yellow_row = yellow_row_p1 || (S2 & yellow_row_p2);

wire blue_row =  HCNT >= 8'd211 && HCNT <= 8'd219 && !S2;

wire [11:0] rgb;
always_comb begin
  if (video && red_row)
    rgb = {4'hA, 4'h2, 4'h1};
  else if (video && amber_row)
    rgb = {4'hC, 4'h8, 4'h1};
  else if (video && green_row)
    rgb = {4'h1, 4'h7, 4'h3};
  else if (video && yellow_row)
    rgb = {4'hC, 4'hC, 4'h3};
  else if (video && blue_row)
    rgb = {4'h1, 4'h7, 4'hC};
  else if (video)
    rgb = {4'hF, 4'hF, 4'hF};
  else
    rgb = {4'h0, 4'h0, 4'h0};
end

// ce_pix signal is 1/8 of clk_sys
reg ce_pix;
always_ff @(posedge clk_sys) begin
  reg [2:0] div;
  ce_pix <= !div;
  div <= div + 1'd1;
end

// Horizontal/Vertical conter values in breakout instance
wire [7:0] HCNT;
wire [7:0] VCNT;

// Blanking signals are not supplied from breatkout instance,
// so defining here
wire hblank_p1 = (HCNT >= 8'd224) || (HCNT <= 8'd24);
wire hblank_p2 = (HCNT >= 8'd232) || (HCNT <= 8'd32);
wire hblank = (S2 & PLAYER2) ? hblank_p2 : hblank_p1;
// When scandoubler enabled, widen VBlank to prevent flickering.
// However, this removes 1px from each side of the wall.
wire vblank_raw = (VCNT >= 8'd228) && (VCNT <= 8'd251);
wire vblank_fx  = (VCNT >= 8'd223) && (VCNT <= 8'd252);
wire vblank = scandoubler ? vblank_fx : vblank_raw;

// HSYNC is coming from breakout instance, using as-is
wire HSYNC;
// VSYNC is coming from breakout instance, but it is far from NTSC standard
// Here, defining optional TV compatible vsync for analog video output
wire VSYNC;
wire vsync_opt = (VCNT >= 8'd232) && (VCNT <= 8'd234);

// Sync edge signal for detecting line/frame in handling control
reg  hsync_old, vsync_old;
wire hsync_posedge = HSYNC & ~hsync_old;
wire vsync_posedge = VSYNC & ~vsync_old;

always_ff @(posedge clk_sys) begin
  hsync_old <= HSYNC;
  vsync_old <= VSYNC;
end

// Instansiate MiSTer system module
wire [2:0] fx = status[6:4];
wire scandoubler = fx || forced_scandoubler;

arcade_video #(.WIDTH(512), .DW(12)) arcade_video
(
  .*,

  .clk_video(clk_sys),
  .ce_pix(ce_pix),

  .RGB_in(rgb),
  .HBlank(hblank),
  .VBlank(vblank),
  .HSync(HSYNC),
  .VSync(status[27] ? VSYNC : vsync_opt),

  .fx,
  .forced_scandoubler,
  .gamma_bus
);
screen_rotate screen_rotate
(
  .*,

  .rotate_ccw(1'b0),
  .no_rotate(status[7])
);

/////////////////////////////////////////////////////////////////////////
//      SOUND
/////////////////////////////////////////////////////////////////////////
wire SOUND;
assign AUDIO_L = {3'b0, ~SOUND, 12'b0};
assign AUDIO_R = AUDIO_L;
assign AUDIO_S = 0;
assign AUDIO_MIX = 'd3;

/////////////////////////////////////////////////////////////////////////
//      CONTROL
/////////////////////////////////////////////////////////////////////////
wire       p1invert = status[8];
wire       p2invert = status[9];
wire       dspeed   = status[23];
wire [1:0] sspeed   = status[26:25];

//
// Paddle positioning for digital input
//
wire [3:0] delta = dspeed ? 4'd8 : 4'd4;

reg  [8:0] pos_d = 8'd128;

wire p1right = joystick_0[0] & ~PLAYER2;
wire p1left  = joystick_0[1] & ~PLAYER2;
wire p2right = joystick_1[0] & PLAYER2;
wire p2left  = joystick_1[1] & PLAYER2;

wire right = p1right | p2right;
wire left  = p1left  | p2left;

always_ff @(posedge clk_sys) begin
  if (vsync_posedge) begin
    if (right) pos_d <= ((pos_d - delta) > 255) ? 9'd0   : (pos_d - delta);
    if (left)  pos_d <= ((pos_d + delta) > 255) ? 9'd255 : (pos_d + delta);
  end
end

//
// Paddle positioning for analog input
//
wire [7:0] p1joy_sx = joystick_analog_0[7:0];
wire [7:0] p1joy_sy = joystick_analog_0[15:8];
wire [7:0] p2joy_sx = joystick_analog_1[7:0];
wire [7:0] p2joy_sy = joystick_analog_1[15:8];

wire [7:0] p1pos_ax = {~p1joy_sx[7], p1joy_sx[6:0]};
wire [7:0] p1pos_ay = {~p1joy_sy[7], p1joy_sy[6:0]};
wire [7:0] p2pos_ax = {~p2joy_sx[7], p2joy_sx[6:0]};
wire [7:0] p2pos_ay = {~p2joy_sy[7], p2joy_sy[6:0]};

//
// Paddle positioning for spinner input
//
reg old_sp1r, old_sp2r;
always_ff @(posedge clk_sys) begin
  old_sp1r <= spinner_0[8];
  old_sp2r <= spinner_1[8];
end
wire sp1_upd = old_sp1r ^ spinner_0[8];
wire sp2_upd = old_sp2r ^ spinner_1[8];

wire sp1_cw  = sp1_upd & (~spinner_0[7] ^ p1invert) & ~PLAYER2;
wire sp1_ccw = sp1_upd & ( spinner_0[7] ^ p1invert) & ~PLAYER2;
wire sp2_cw  = sp2_upd & (~spinner_1[7] ^ p2invert) &  PLAYER2;
wire sp2_ccw = sp2_upd & ( spinner_1[7] ^ p2invert) &  PLAYER2;

wire [6:0] sp1_uval = spinner_0[7] ? (~spinner_0[6:0] + 6'b1) : spinner_0[6:0];
wire [6:0] sp2_uval = spinner_1[7] ? (~spinner_1[6:0] + 6'b1) : spinner_1[6:0];
wire [6:0] sp_uval  = PLAYER2 ? sp2_uval : sp1_uval;
wire [7:0] sp_uvals;
always_comb begin
  case (sspeed)
    2'd0: sp_uvals = sp_uval << 1;
    2'd1: sp_uvals = sp_uval << 2;
    2'd2: sp_uvals = sp_uval << 3;
    default: sp_uvals = sp_uval;
  endcase
end

wire cw  = sp1_cw  | sp2_cw;
wire ccw = sp1_ccw | sp2_ccw;

reg  [8:0] pos_sp = 8'd128;

always_ff @(posedge clk_sys) begin
  if (cw)  pos_sp <= ((pos_sp - sp_uvals) > 255) ? 9'd0   : (pos_sp - sp_uvals);
  if (ccw) pos_sp <= ((pos_sp + sp_uvals) > 255) ? 9'd255 : (pos_sp + sp_uvals);
end

//
// Count horizontol line for positioning pad
//
wire PAD_EN_N;

reg [7:0] p1cnt = 8'd0;
reg [7:0] p2cnt = 8'd0;

always_ff @(posedge clk_sys) begin
  if (!PAD_EN_N) begin
    p1cnt <= 8'd0;
    p2cnt <= 8'd0;
  end else if (hsync_posedge) begin
    p1cnt <= p1cnt + 1'd1;
    p2cnt <= p2cnt + 1'd1;
  end
end

//
// Mix Inputs
//
wire [3:0] p1cntl   = status[17:15];
wire [3:0] p2cntl   = status[20:18];

wire [7:0] p1pos;
wire [7:0] p2pos;

always_comb begin
  case (p1cntl)
    3'd0:    p1pos = pos_d[7:0];                      // Digital
    3'd1:    p1pos = p1invert ? p1pos_ax : ~p1pos_ax; // X / X-Inv
    3'd2:    p1pos = p1invert ? p1pos_ay : ~p1pos_ay; // Y / Y-Inv
    3'd3:    p1pos = p1invert ? paddle_0 : ~paddle_0; // Paddle / Paddle-Inv
    3'd4:    p1pos = pos_sp[7:0];                     // Spinner / Spinner-Inv
    default: p1pos = 8'd128;
  endcase
  case (p2cntl)
    3'd0:    p2pos = pos_d[7:0];                      // Digital
    3'd1:    p2pos = p2invert ? p2pos_ax : ~p2pos_ax; // X / X-Inv
    3'd2:    p2pos = p2invert ? p2pos_ay : ~p2pos_ay; // Y / Y-Inv
    3'd3:    p2pos = p2invert ? paddle_1 : ~paddle_1; // Paddle / Paddle-Inv
    3'd4:    p2pos = pos_sp[7:0];                     // Spinner / Spinner-Inv
    default: p2pos = 8'd128;
  endcase
end

wire pad1_out = p1cnt < p1pos;
wire pad2_out = p2cnt < p2pos;
wire PAD_OUT  = PLAYER2 ? pad2_out : pad1_out;

wire CSW1 = joystick_0[4];
wire CSW2 = joystick_1[4];
wire P1_START_N = ~(joystick_0[5] | joystick_1[5]);
wire P2_START_N = ~(joystick_0[6] | joystick_1[6]);
wire P1_SERVE_N = ~(joystick_0[7]) | PLAYER2;
wire P2_SERVE_N = ~(joystick_1[7]) | ~PLAYER2;

///////////////////////////////////////////////////////////////////////////////////////////
//      BREAKOUT INSTANCE
///////////////////////////////////////////////////////////////////////////////////////////

// Switch settings (S1, S2, S3, S4)
// See breakout_top for details
wire [3:0] S1 = {sw[0], sw[1], sw[2], sw[3]};
wire       S2 = sw[4];
wire       S3 = sw[5];
wire       S4 = sw[6];

// Instansiate Breakout instance
wire PLAYFIELD, BALL, SCORE, PAD;
wire PLAYER2;

breakout_top breakout_top(
  .CLK_DRV(clk_sys), .CLK_SRC,
  .RESET(reset),
  .S1, .S2, .S3, .S4,
  .P1_SERVE_N, .P2_SERVE_N,
  .P1_START_N, .P2_START_N,
  .CSW1, .CSW2,
  .PAD_OUT,
  .HSYNC, .VSYNC,
  .PLAYFIELD, .BSYNC(BALL), .SCORE, .PAD,
  .PAD_EN_N,
  .SOUND,
  .PLAYER2,
  .P1_SERVE_BTN_LED(),  .P2_SERVE_BTN_LED(),
  .P1_START_BTN_LAMP(), .P2_START_BTN_LAMP(),
  .HCNT, .VCNT,
  .CREDITS(),
  .TEST_PAD(1'b0 /*status[24]*/)
);

assign video = PLAYFIELD | BALL | SCORE | PAD;

endmodule
