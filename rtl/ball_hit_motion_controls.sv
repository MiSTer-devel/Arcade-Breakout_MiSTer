/*
 * Ball hit and motion control
 */
module ball_hit_motion_controls(
  input  logic CLK_DRV,
  input  logic BALL_DISPLAY, TOP_BOUND, BRICK_HIT, SBD_N,
  input  logic PC, PD, _16H_N, _16V__, SERVE_WAIT, SERVE_WAIT_N,
  input  logic VSYNC, BSYNC, PSYNC,
  input  logic PLAYER2_CONDITIONAL,
  output logic CX0, CX1, X2, Y0, Y1, Y2,
  output logic BP_HIT_N, BTB_HIT_N, VB_HIT_N
);
  // Internal net
  logic DN, X0, X1, V_SLOW, SU_N;

  //
  // Paddle hit, Top bound hit
  //
  logic A5c, C3a, E5a, D5a_Q, D5a_Q_N, C6a, C4a;

  assign A5c = ~(BALL_DISPLAY & PSYNC);
  assign C3a = ~(BSYNC & TOP_BOUND);
  assign E5a = ~(~C3a | ~SBD_N);
  assign C6a = PLAYER2_CONDITIONAL ^ D5a_Q;
  assign C4a = PLAYER2_CONDITIONAL ^ D5a_Q_N;

  SN7474 SN7474_D5a(
    .CLK_DRV,
    .CLK(BRICK_HIT),
    .PRE_N(A5c),
    .CLR_N(E5a),
    .D(D5a_Q_N),
    .Q(D5a_Q), .Q_N(D5a_Q_N)
  );

  assign BP_HIT_N = A5c;
  assign BTB_HIT_N = C3a;
  assign X2 = C6a;
  assign DN = C4a;

  //
  // Volleys counter (speed)
  //
  logic D6c, B6c, B6a, B5_QC, B5_QD, C5e, C5d;

  assign D6c = C6a & B6c;
  assign B6c = ~(B5_QC & B5_QD);
  assign B6a = ~(X0 & C6a);
  assign C5e = ~B5_QC;
  assign C5d = ~B5_QD;

  // break combinational loop
  logic D6cq;
  always_ff @(posedge CLK_DRV) D6cq <= D6c;

  SN74193 SN74193_B5(
    .CLK_DRV,
    .UP(D6cq), .DOWN(1'b1),
    .CLR(SERVE_WAIT),
    .LOAD_N(SU_N),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(), .QB(), .QC(B5_QC), .QD(B5_QD),
    .BO_N(), .CO_N()
  );

  assign X1 = B6a;
  assign X0 = C5e;
  assign V_SLOW = C5d;

  //
  // Detects 5pt or 7pt brick hit
  //
  logic H2c, D5b_Q, D5b_Q_N, D6d, C6d, C6b;

  assign H2c = BRICK_HIT & _16H_N;
  assign D6d = D5b_Q & DN;
  assign C6d = X0 ^ D5b_Q;
  assign C6b = D6d ^ X1;

  SN7474 SN7474_D5b(
    .CLK_DRV,
    .CLK(H2c),
    .PRE_N(1'b1),
    .CLR_N(SERVE_WAIT_N),
    .D(1'b1),
    .Q(D5b_Q), .Q_N(D5b_Q_N)
  );

  assign CX0 = C6d;
  assign CX1 = C6b;
  assign SU_N = D5b_Q_N;

  //
  // Paddle hit angle, Side wall hit
  //
  logic C4b, C5f, A5a, A5b, A5d, A6b_Q_N, A6a_Q, A6a_Q_N, B6d, C6c, B6b;

  assign C4b = PC ^ PD;
  assign C5f = ~A5c;
  assign A5a = ~(C5f & PD);
  assign A5b = ~(BSYNC & VSYNC);
  assign A5d = ~(C5f & A5a);
  assign B6d = ~(V_SLOW & A6b_Q_N);
  assign C6c = V_SLOW ^ A6a_Q;
  assign B6b = ~(B6d & C6c);

  SN7474 SN7474_A6b(
    .CLK_DRV,
    .CLK(BP_HIT_N),
    .PRE_N(1'b1),
    .CLR_N(1'b1),
    .D(C4b),
    .Q(), .Q_N(A6b_Q_N)
  );

  SN7474 SN7474_A6a(
    .CLK_DRV,
    .CLK(A5b),
    .PRE_N(A5a),
    .CLR_N(A5d),
    .D(_16V__),
    .Q(A6a_Q), .Q_N(A6a_Q_N)
  );

  assign VB_HIT_N = A5b;
  assign Y0 = B6d;
  assign Y1 = B6b;
  assign Y2 = A6a_Q_N;

endmodule
