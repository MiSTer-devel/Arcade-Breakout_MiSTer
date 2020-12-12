/*
 * Ball serve (Serves counter + Serve wait)
 */
module ball_serve(
  input  logic CLK_DRV,
  input  logic START_GAME1_N, _2PLGM_N, ATTRACT,
  input  logic HSYNC, _1H, _4H, _8H__, _16H, _32H, _64H, _128H,
  input  logic BALL,
  input  logic SERVE_N,
  input  logic S4, // 0: 3 BALLS, 1: 5 BALLS
  output logic PLAYER2, BALL_A, BALL_B, BALL_C,
  output logic EGL, SBD_N,
  output logic SERVE_WAIT, SERVE_WAIT_N,
  output logic BALL_DISPLAY
);
  //
  // PLAY_CP pulse generation
  //
  logic PLAY_CP;
  logic F2b, D2c, F5a_Q;

  assign F2b = _2PLGM_N & PLAYER2 & _1H;
  assign D2c = F2b | F5a_Q;

  assign PLAY_CP = D2c;

  SN7474 SN7474_F5a(
    .CLK_DRV,
    .CLK(SERVE_WAIT),
    .PRE_N(1'b1),
    .CLR_N(_128H),
    .D(1'b1),
    .Q(F5a_Q), .Q_N()
  );

  //
  // Ball serves counter
  //
  logic B4_QA, B4_QB, B4_QC, B4_QD, A4a;
  assign A4a = B4_QB & (S4 ? B4_QD : B4_QC);

  // break combinational loop
  logic PLAY_CPq;
  always_ff @(posedge CLK_DRV) PLAY_CPq <= PLAY_CP;

  DM9316 DM9316_B4(
    .CLK_DRV,
    .CLK(PLAY_CPq), .CLR_N(START_GAME1_N), .LOAD_N(1'b1), .ENP(1'b1), .ENT(1'b1),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b0),
    .QA(B4_QA), .QB(B4_QB), .QC(B4_QC), .QD(B4_QD),
    .RCO()
  );

  assign PLAYER2 = B4_QA;
  assign BALL_A  = B4_QB;
  assign BALL_B  = B4_QC;
  assign BALL_C  = B4_QD;
  assign EGL     = A4a;

  //
  // Serve wait
  //
  logic D2d, H2d, C3c, B3b, C3b, A4c, J3b, L4a;
  logic A3a_Q_N, E1f, B3c, B3d, A3b_Q, A3b_Q_N, A4b;


  assign D2d = ~(~SERVE_WAIT_N & ~SERVE_N);
  assign H2d = BALL_DISPLAY & _128H;
  assign C3c = ~(H2d & HSYNC);
  assign B3b = ~_8H__ & ~C3c;
  assign C3b = ~(_4H & B3b);
  assign A4c = START_GAME1_N & C3b;

  assign J3b = ~_64H & ~_32H;
  assign L4a = J3b & _128H & _16H;

  assign E1f = ~BALL;
  assign B3c = ~A3a_Q_N & ~E1f;
  assign B3d = ~(A3b_Q_N | B3c);
  assign A4b = A3b_Q_N & BALL;

  SN7474 SN7474_A3a(
    .CLK_DRV,
    .CLK(ATTRACT),
    .PRE_N(SERVE_N),
    .CLR_N(A3b_Q),
    .D(1'b1),
    .Q(), .Q_N(A3a_Q_N)
  );

  // break combinational loop
  logic B3dq, A4cq;
  always_ff @(posedge CLK_DRV) B3dq <= B3d;
  always_ff @(posedge CLK_DRV) A4cq <= A4c;

  SN7474 SN7474_A3b(
    .CLK_DRV,
    .CLK(L4a),
    .PRE_N(A4cq),
    .CLR_N(1'b1),
    .D(B3dq),
    .Q(A3b_Q), .Q_N(A3b_Q_N)
  );

  assign SBD_N        = D2d;
  assign SERVE_WAIT   = A3b_Q;
  assign SERVE_WAIT_N = A3b_Q_N;
  assign BALL_DISPLAY = A4b;

endmodule
