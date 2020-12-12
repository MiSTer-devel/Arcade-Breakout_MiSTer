/*
 * Points counter
 */
module points_counter(
  input  logic CLK_DRV,
  input  logic _16H_N, _8H_N,
  input  logic RAM_PLAYER1, PLAYER2,
  input  logic START_GAME, SCLOCK, BRICK_HIT, ATTRACT_N,
  output logic COUNT_1, COUNT_2, COUNT
);
  logic N7d, N7b, N7c, N9_BO_N, N8b_Q_N;

  assign N7d = N9_BO_N & SCLOCK;
  assign N7b = PLAYER2 & N7d;
  assign N7c = N7d & RAM_PLAYER1;

  // break combinational loop
  logic N7dq;
  always @(posedge CLK_DRV) N7dq <= N7d;

  SN74192 SN74192_N9(
    .CLK_DRV,
    .UP(1'b1), .DOWN(N7dq),
    .CLR(START_GAME), .LOAD_N(N8b_Q_N),
    .A(1'b1), .B(_8H_N), .C(_16H_N), .D(1'b0),
    .QA(), .QB(), .QC(), .QD(),
    .BO_N(N9_BO_N), .CO_N()
  );

  DM9602 #(
    .COUNTS(6)  // 105ns
  ) DM9602_N8b (
    .CLK(CLK_DRV),
    .A_N(1'b1), .B(BRICK_HIT),
    .CLR_N(ATTRACT_N),
    .Q(), .Q_N(N8b_Q_N)
  );

  assign COUNT_1 = N7c;
  assign COUNT_2 = N7b;
  assign COUNT   = N7d;

endmodule
