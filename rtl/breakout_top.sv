/*
 * Breakout top module
 */
module breakout_top(
  input   logic       CLK_DRV, CLK_SRC,
  input   logic       RESET,
  input   logic [3:0] S1, // BONUS CREDIT SCORE
                          //  0000: No bonus credit
                          //  1000: 100 pts, 0100: 200 pts, 1100: 300 pts, 0010: 400 pts
                          //  1010: 500 pts, 0110: 600 pts, 1110: 700 pts, 0001: 800 pts
  input   logic       S2, // 0: NORMAL,        1: COCKTAIL
  input   logic       S3, // 0: 1CREDIT/1COIN, 1: 2CREDITS/1COIN
  input   logic       S4, // 0: 3 BALLS,       1: 5 BALLS
  input   logic       P1_SERVE_N, P2_SERVE_N,
  input   logic       P1_START_N, P2_START_N,
  input   logic       CSW1, CSW2,
  input   logic       PAD_OUT,
  output  logic       HSYNC, VSYNC,
  output  logic       PLAYFIELD, BSYNC, SCORE, PAD,
  output  logic       PAD_EN_N,
  output  logic       SOUND,
  output  logic       PLAYER2,
  output  logic       P1_SERVE_BTN_LED,  P2_SERVE_BTN_LED,
  output  logic       P1_START_BTN_LAMP, P2_START_BTN_LAMP,
  output  logic [7:0] HCNT,
  output  logic [7:0] VCNT,
  output  logic [3:0] CREDITS,
  input   logic       TEST_PAD  // for debug porpose
);
  logic SERVE_N;
  assign SERVE_N = P1_SERVE_N & P2_SERVE_N;

  // Clocks
  logic CLOCK, CKBH, SCLOCK;

  // Video sync
  logic _1H, _2H, _4H, _8H, _16H, _32H, _64H, _128H;
  logic _1V, _2V, _4V, _8V, _16V, _32V, _64V, _128V;
  logic _8H_N, _16H_N, _32H_N, _16V_N, _64V_N, _64V1;
  logic _8H__, _4V__, _8V__, _16V__, _32V__, _64V__, _128V__;
  logic CSYNC, HSYNC_N, VSYNC_N, PSYNC, PSYNC_N, BSYNC_N;

  // Game control
  logic Q, EGL;
  logic ATTRACT, ATTRACT_N;
  logic START_GAME, START_GAME_N;
  logic START_GAME1_N, _2PLGM_N;

  // Coin
  logic _1_CR_START_N, _2_CR_START;
  logic COIN1_N, COIN2_N;
  logic _1_OR_2_CREDIT, _1_OR_2_CREDIT_N;
  logic _2_CREDIT, _2_CREDIT_N;
  logic BONUS_COIN;

  // Player
  logic RAM_PLAYER1;
  logic PLAYER2_CONDITIONAL;

  // Score
  logic A1, B1, C1, D1, E1, F1, G1, H1, I1, J1, K1, L1;
  logic A2, B2, C2, D2, E2, F2, G2, H2, I2, J2, K2, L2;

  // Playfield
  logic TOP_BOUND, RH_SIDE, LH_SIDE;

  // Bricks
  logic BRICK_DISPLAY;
  logic SET_BRICKS, SET_BRICKS_N;
  logic BRICK_HIT, BRICK_HIT_N;
  logic FPD1, FPD2, FPD1_N, FPD2_N;

  // Brick hit count
  logic COUNT;
  logic COUNT_1, COUNT_2;

  // Ball hit/motion
  logic BALL, BALL_DISPLAY;
  logic BP_HIT_N, BTB_HIT_N, VB_HIT_N;
  logic CX0, CX1, X2;
  logic Y0, Y1, Y2;

  // Paddle
  logic PAD_N;
  logic PC, PD;

  // Serve
  logic BALL_A, BALL_B, BALL_C;
  logic SERVE_WAIT, SERVE_WAIT_N;
  logic SBD_N;

  // Sound
  logic BRICK_SOUND, VB_HIT_SOUND, P_HIT_SOUND;
  logic FREE_GAME_TONE;

  // Submodules
  clock                    clock(.*);
  videosync                videosync(.*);
  playfield                playfield(.*);
  brick_display            brick_display(.*);
  ball_motion_counters     ball_motion_counters(.*);
  ball_hit_motion_controls ball_hit_motion_controls(.*);
  ball_serve               ball_serve(.*);
  paddle                   paddle(.*);
  coin                     coin(.*);
  game_control             game_control(.*);
  points_counter           points_counter(.*);
  score_registers          score_registers(.*);
  numerals_display         numerals_display(.*);
  free_game_selector       free_game_selector(.*);
  empty_wall_detector      empty_wall_detector(.*);
  sound_sum                sound_sum(.*);

  assign P1_START_BTN_LAMP = _1_OR_2_CREDIT;
  assign P2_START_BTN_LAMP = _2_CREDIT;
  assign P1_SERVE_BTN_LED = SERVE_WAIT;
  assign P2_SERVE_BTN_LED = SERVE_WAIT;

endmodule
