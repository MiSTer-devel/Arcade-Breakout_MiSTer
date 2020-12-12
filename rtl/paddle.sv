/*
 * Paddle
 */
module paddle(
  input  logic CLK_DRV,
  input  logic S2,
  input  logic _4H, _8H, _16H, _32H, _64H, _128H,
  input  logic _8V__, _16V__, _32V__, _64V__, _128V__,
  input  logic VSYNC_N,
  input  logic BTB_HIT_N, SERVE_WAIT_N,
  input  logic ATTRACT_N,
  input  logic PAD_OUT,
  input  logic PLAYER2,
  input  logic TEST_PAD, // Debug purpose, not original
  output logic PAD_EN_N,
  output logic PAD_N,
  output logic PC, PD,
  output logic PLAYER2_CONDITIONAL
);
  //
  // Trigger signal
  //
  logic D7a, H1b, C2b, J2d, C2c;
  assign D7a = _16V__ &  _64V__ & _128V__;
  assign H1b = ~(D7a & _8V__);
  assign C2b = ~(H1b & H1b);
  assign J2d = ~_32V__;
  assign C2c = ~(J2d & C2b);

  assign PAD_EN_N = C2c;

  //
  // Counter clock pulse
  //
  logic C5b, F5b_Q, F5b_Q_N, E5d, E5c, E4d;
  assign C5b = ~BTB_HIT_N;
  assign E5d = _64H & F5b_Q;
  assign E5c = _128H & F5b_Q_N;
  assign E4d = E5d | E5c;

  SN7474 SN7474_F5b(
    .CLK_DRV,
    .CLK(C5b),
    .PRE_N(1'b1),
    .CLR_N(SERVE_WAIT_N),
    .D(1'b1),
    .Q(F5b_Q), .Q_N(F5b_Q_N)
  );

  //
  // Paddle video signal
  //
  logic H7b, E4c, C3d, J3a, K3, D4_QC, D4_QD, D4_RCO;
  assign H7b = PAD_OUT & PAD_EN_N;
  assign E4c = D4_RCO | H7b;
  assign C3d = ~((!ATTRACT_N ? 1'b0 : ~TEST_PAD) & E4c);
  assign J3a = ~_8H & ~_32H;
  assign K3 = ~(C3d & _128H & _64H & _16H & _4H & J3a & 1'b1 & 1'b1);

  DM9316 DM9316_D4(
    .CLK_DRV,
    .CLK(E4d), .CLR_N(VSYNC_N), .LOAD_N(1'b1), .ENP(C3d), .ENT(1'b1),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(), .QB(), .QC(D4_QC), .QD(D4_QD),
    .RCO(D4_RCO)
  );

  assign PAD_N = K3;
  assign PC = D4_QC;
  assign PD = D4_QD;

  //
  // Player2 conditional
  //
  logic H7c, PLAYER2_CONDITIONAL_;
  assign H7c = PLAYER2 & S2;
  assign PLAYER2_CONDITIONAL_ = H7cq;

  // break combinational logic
  logic H7cq;
  always_ff @(posedge CLK_DRV) H7cq <= H7c;

  logic E9d, H1a;
  assign E9d = ~PLAYER2_CONDITIONAL_;
  assign H1a = ~(E9d & E9d);

  assign PLAYER2_CONDITIONAL = H1a;

endmodule
