/*
 * Empty wall detector
 */
module empty_wall_detector(
  input  logic CLK_DRV,
  input  logic K1, D1, G1, K2, D2, G2,
  input  logic BP_HIT_N, START_GAME1_N,
  output logic FPD1, FPD1_N, FPD2, FPD2_N
);

  logic M4a, M4c, E4a, E4b, F4a_Q_N, F4b_Q_N;
  assign M4a = ~(K2 & G2 & D2);
  assign M4c = ~(K1 & G1 & D1);
  assign E4a = ~(~BP_HIT_N & ~M4a);
  assign E4b = ~(~BP_HIT_N & ~M4c);

  SN7474 SN7474_F4a(
    .CLK_DRV,
    .CLK(E4a), .PRE_N(1'b1), .CLR_N(START_GAME1_N),
    .D(1'b1),
    .Q(), .Q_N(F4a_Q_N)
  );

  SN7474 SN7474_F4b(
    .CLK_DRV,
    .CLK(E4b), .PRE_N(1'b1), .CLR_N(START_GAME1_N),
    .D(1'b1),
    .Q(), .Q_N(F4b_Q_N)
  );

  logic F3a_Q, F3a_Q_N, F3b_Q, F3b_Q_N;

  DM9602 #(
    .COUNTS(934679)  // 16.32 ms
  ) DM9602_F3a (
    .CLK(CLK_DRV),
    .A_N(F4a_Q_N), .B(1'b0),
    .CLR_N(1'b1),
    .Q(F3a_Q), .Q_N(F3a_Q_N)
  );

  DM9602 #(
    .COUNTS(934679)  // 16.32 ms
  ) DM9602_F3b (
    .CLK(CLK_DRV),
    .A_N(F4b_Q_N), .B(1'b0),
    .CLR_N(1'b1),
    .Q(F3b_Q), .Q_N(F3b_Q_N)
  );

  assign FPD2 = F3a_Q;
  assign FPD2_N = F3a_Q_N;
  assign FPD1 = F3b_Q;
  assign FPD1_N = F3b_Q_N;

endmodule
