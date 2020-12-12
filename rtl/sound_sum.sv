module sound_sum(
  input  logic CLK_DRV,
  input  logic BRICK_SOUND, VB_HIT_SOUND, P_HIT_SOUND, FREE_GAME_TONE,
  input  logic BP_HIT_N, VB_HIT_N, ATTRACT_N,
  input  logic COUNT, START_GAME_N, VSYNC,
  output logic SOUND
);
  //
  // Brick sound
  //
  logic M9a, J9a, B9c, F6_BO_N, F7d_Q, A7b_Q_N, A8b_Q;
  assign M9a = ~COUNT;
  assign J9a = ~(F7d_Q & VSYNC & A7b_Q_N);
  assign B9c = A8b_Q & BRICK_SOUND;

  // break combinational loop
  logic J9aq;
  always_ff @(posedge CLK_DRV) J9aq <= J9a;

  SN74193 SN74193_F6(
    .CLK_DRV,
    .UP(M9a), .DOWN(J9aq),
    .CLR(1'b0), .LOAD_N(START_GAME_N),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(), .QB(), .QC(), .QD(),
    .BO_N(F6_BO_N), .CO_N()
  );

  SN74279 SN74279_F7d(
    .CLK_DRV,
    .S_N(M9a), .R_N(F6_BO_N),
    .Q(F7d_Q)
  );

  DM9602 #(
    .COUNTS(4478670)  // 78.2 ms
  ) DM9602_A7b (
    .CLK(CLK_DRV),
    .A_N(J9a), .B(1'b0),
    .CLR_N(ATTRACT_N),
    .Q(), .Q_N(A7b_Q_N)
  );

  DM9602 #(
    .COUNTS(1343601)  // 23.46 ms
  ) DM9602_A8b (
    .CLK(CLK_DRV),
    .A_N(J9a), .B(1'b0),
    .CLR_N(ATTRACT_N),
    .Q(A8b_Q), .Q_N()
  );

  //
  // Side wall hit sound
  //
  logic B4b, A7a_Q;
  assign B4b = A7a_Q & VB_HIT_SOUND;

  DM9602 #(
    .COUNTS(1343601)  // 23.46 ms
  ) DM9602_A7a (
    .CLK(CLK_DRV),
    .A_N(VB_HIT_N), .B(1'b0),
    .CLR_N(ATTRACT_N),
    .Q(A7a_Q), .Q_N()
  );

  //
  // Paddle hit sound
  //
  logic B9d, A8a_Q;
  assign B9d = A8a_Q & P_HIT_SOUND;

  DM9602 #(
    .COUNTS(545229)  // 9.52 ms
  ) DM9602_A8a (
    .CLK(CLK_DRV),
    .A_N(BP_HIT_N), .B(1'b0),
    .CLR_N(ATTRACT_N),
    .Q(A8a_Q), .Q_N()
  );

  //
  // Sum
  //
  assign SOUND = B4b | B9d | B9c | FREE_GAME_TONE;


endmodule
