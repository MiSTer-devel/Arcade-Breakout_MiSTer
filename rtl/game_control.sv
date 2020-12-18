/*
 * Game control
 */
module game_control(
  input  logic CLK_DRV, RESET,
  input  logic P1_START_N, P2_START_N,
  input  logic COIN1_N, COIN2_N,
  input  logic _1_OR_2_CREDIT_N, _2_CREDIT_N, EGL,
  input  logic _32V, _64V1, _64V__, _128V__,
  output logic Q,
  output logic START_GAME, START_GAME_N, START_GAME1_N,
  output logic _1_CR_START_N, _2_CR_START,
  output logic ATTRACT, ATTRACT_N,
  output logic _2PLGM_N
);
  //
  // Q Latch
  //
  always_ff @(posedge CLK_DRV) begin
    if (RESET)
      Q <= 1'b0; // Reset state 
    else if (!COIN1_N || !COIN2_N)
      Q <= 1'b1; // Play state
    else if (EGL && _1_OR_2_CREDIT_N)
      Q <= 1'b0; // Reset state
  end

  //
  // Start 1 player
  //
  logic E9b, E7a, E8a_Q_N;
  assign E9b = ~P1_START_N;
  assign E7a = ~(_1_OR_2_CREDIT_N | ATTRACT_N);

  // break combinational loop
  logic E7aq;
  always_ff @(posedge CLK_DRV) E7aq <= E7a;

  SN7474 SN7474_E8a(
    .CLK_DRV, .CLK(_64V__),
    .PRE_N(1'b1), .CLR_N(E7aq),
    .D(E9b),
    .Q(), .Q_N(E8a_Q_N)
  );

  assign _1_CR_START_N = E8a_Q_N;

  //
  // Start 2 player
  //
  logic E9e, E7d, F7a_Q, E8b_Q, E8b_Q_N;
  logic _2_CR_START_N;
  assign E9e = ~P2_START_N;
  assign E7d = ~(ATTRACT_N | F7a_Q);

  SN74279 SN74279_F7a(
    .CLK_DRV,
    .S_N(_128V__), .R_N(_2_CREDIT_N),
    .Q(F7a_Q)
  );

  // break combinational loop
  logic E7dq;
  always_ff @(posedge CLK_DRV) E7dq <= E7d;

  SN7474 SN7474_E8b(
    .CLK_DRV, .CLK(_64V1),
    .PRE_N(1'b1), .CLR_N(E7dq),
    .D(E9e),
    .Q(E8b_Q), .Q_N(E8b_Q_N)
  );

  assign _2_CR_START   = E8b_Q;
  assign _2_CR_START_N = E8b_Q_N;

  //
  // Attract signal gen
  //
  logic D8b, D6b, C5a, D6a, M9b, M9c, C6b_Q, C6b_Q_N;
  assign D8b = ~_1_CR_START_N | ~_2_CR_START_N;
  assign D6b = _32V & C6b_Q_N;
  assign C5a = ~EGL;
  assign D6a = ~(~Q | ~C5a);
  assign M9b = ~D8b;
  assign M9c = ~D8b;

  // break combinational loop
  logic D8bq, D6bq;
  always_ff @(posedge CLK_DRV) D8bq <= D8b;
  always_ff @(posedge CLK_DRV) D6bq <= D6b;

  SN7474 SN7474_C6b(
    .CLK_DRV, .CLK(D6bq),
    .PRE_N(1'b1), .CLR_N(D6a),
    .D(D8bq),
    .Q(C6b_Q), .Q_N(C6b_Q_N)
  );

  assign START_GAME    = D8b;
  assign START_GAME1_N = M9b;
  assign START_GAME_N  = M9c;

  assign ATTRACT_N = C6b_Q;
  assign ATTRACT   = C6b_Q_N;

  //
  // 2 player mode latch
  //
  logic F7b_Q;

  SN74279 SN74279_F7b(
    .CLK_DRV,
    .S_N(_1_CR_START_N), .R_N(_2_CR_START_N),
    .Q(F7b_Q)
  );

  assign _2PLGM_N = F7b_Q;

endmodule
