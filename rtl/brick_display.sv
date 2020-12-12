module brick_display(
  input  logic CLK_DRV, CKBH,
  input  logic _1H, _2H, _4H, _8H, _16H, _32H, _64H, _128H,
  input  logic _2V, _4V, _8V, _16V, _32V, _64V, _128V,
  input  logic VSYNC_N,
  input  logic FPD1, FPD2, FPD1_N, FPD2_N,
  input  logic RAM_PLAYER1,
  input  logic BALL_DISPLAY,
  input  logic BP_HIT_N, BTB_HIT_N,
  input  logic ATTRACT_N,
  input  logic START_GAME,
  input  logic SERVE_N,
  output logic SET_BRICKS, SET_BRICKS_N,
  output logic BRICK_HIT, BRICK_HIT_N,
  output logic BRICK_DISPLAY
);
  //
  // DIN
  //
  logic C2d, H3c, E1b;
  assign C2d = ~ATTRACT_N | ~SET_BRICKS_N;
  assign H3c = ~(FPD1 | C2d | FPD2);
  assign E1b = ~H3c;

  //
  // CE3_N
  //
  logic M4b, K4a, H4c;
  assign M4b = ~(_2V & _4V & _8V);
  assign K4a = VSYNC_N & _64H;
  assign H4c = ~(M4b & K4a);

  //
  // WR_N
  //
  logic F2a;
  assign F2a = ~(~FPD1_N | ~BRICK_HIT_N | ~FPD2_N);

  //
  // MEMORY
  //
  logic L3_DO_N;
  S82S16 S82S16_L3(
    .CLK_DRV,
    .A0(_4H), .A1(_8H), .A2(_16H), .A3(_32V),
    .A4(_64V), .A5(_128V), .A6(_16V), .A7(RAM_PLAYER1),
    .DIN(E1b),
    .CE1_N(_32H), .CE2_N(_128H), .CE3_N(H4c),
    .WE_N(F2a),
    .DOUT_N(L3_DO_N)
  );

  //
  // BRICK_DISPLAY
  //
  logic K4c, E3a;
  assign K4c = _1H & _2H;
  assign E3a = ~(K4c | L3_DO_N);
  assign BRICK_DISPLAY = E3a;

  //
  // SET_BRICKS
  //
  SN7474 SN7474_D3b(
    .CLK_DRV,
    .CLK(START_GAME),
    .PRE_N(1'b1),
    .CLR_N(SERVE_N),
    .D(1'b1),
    .Q(SET_BRICKS), .Q_N(SET_BRICKS_N)
  );

  //
  // BRICK_HIT
  //
  logic E5b, F7c_Q, C2a, E3d, D2a;
  assign E5b = ~(~BP_HIT_N | ~BTB_HIT_N);
  assign C2a = ~(BALL_DISPLAY & F7c_Q);
  assign E3d = ~L3_DO_N & ~C2a;
  assign D2a = ~(~E3dq & ~SET_BRICKS);

  SN74279 SN74279_F7c(
    .CLK_DRV,
    .S_N(E5b), .R_N(BRICK_HIT_N),
    .Q(F7c_Q)
  );

  // break combinational loop
  logic E3dq;
  always_ff @(posedge CLK_DRV) E3dq <= E3d;

  SN7474 SN7474_E6a(
    .CLK_DRV,
    .CLK(CKBH),
    .PRE_N(SET_BRICKS_N),
    .CLR_N(D2a),
    .D(E3dq),
    .Q(BRICK_HIT), .Q_N(BRICK_HIT_N)
  );


endmodule
