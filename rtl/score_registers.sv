/*
 * Score registers
 */
module score_registers(
  input  logic CLK_DRV,
  input  logic COUNT_1, COUNT_2,
  input  logic START_GAME_N,
  input  logic PLAYER2, _2H, SET_BRICKS_N,
  output logic A1, B1, C1, D1, E1, F1, G1, H1, I1, J1, K1, L1,
  output logic A2, B2, C2, D2, E2, F2, G2, H2, I2, J2, K2, L2,
  output logic RAM_PLAYER1
);
  //
  // Player 1 select signal
  //
  logic B3a, E7b;
  assign B3a = ~(_2H | SET_BRICKS_N);
  assign E7b = ~(B3a | PLAYER2);
  assign RAM_PLAYER1 = E7b;

  //
  // Player 1 score
  //

  // Ones digit
  logic H6_QA, H6_QB, H6_QC, H6_QD, H6_RCO;
  DM9310 DM9316_H6(
    .CLK_DRV,
    .CLK(COUNT_1), .CLR_N(START_GAME_N), .LOAD_N(1'b1),
    .ENP(RAM_PLAYER1), .ENT(1'b1),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(H6_QA), .QB(H6_QB), .QC(H6_QC), .QD(H6_QD),
    .RCO(H6_RCO)
  );
  assign {A1, B1, C1, D1} = {H6_QA, H6_QB, H6_QC, H6_QD};

  // Tens digit
  logic J6_QA, J6_QB, J6_QC, J6_QD, J6_RCO;
  DM9310 DM9316_J6(
    .CLK_DRV,
    .CLK(COUNT_1), .CLR_N(START_GAME_N), .LOAD_N(1'b1),
    .ENP(RAM_PLAYER1), .ENT(H6_RCO),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(J6_QA), .QB(J6_QB), .QC(J6_QC), .QD(J6_QD),
    .RCO(J6_RCO)
  );
  assign {E1, F1, G1, H1} = {J6_QA, J6_QB, J6_QC, J6_QD};

  // Hundreds digit
  logic K6_QA, K6_QB, K6_QC, K6_QD;
  DM9310 DM9316_K6(
    .CLK_DRV,
    .CLK(COUNT_1), .CLR_N(START_GAME_N), .LOAD_N(1'b1),
    .ENP(RAM_PLAYER1), .ENT(J6_RCO),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(K6_QA), .QB(K6_QB), .QC(K6_QC), .QD(K6_QD),
    .RCO()
  );
  assign {I1, J1, K1, L1} = {K6_QA, K6_QB, K6_QC, K6_QD};

  //
  // Player 2 score
  //

  // Ones digit
  logic N6_QA, N6_QB, N6_QC, N6_QD, N6_RCO;
  DM9310 DM9316_N6(
    .CLK_DRV,
    .CLK(COUNT_2), .CLR_N(START_GAME_N), .LOAD_N(1'b1),
    .ENP(PLAYER2), .ENT(1'b1),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(N6_QA), .QB(N6_QB), .QC(N6_QC), .QD(N6_QD),
    .RCO(N6_RCO)
  );
  assign {A2, B2, C2, D2} = {N6_QA, N6_QB, N6_QC, N6_QD};

  // Tens digit
  logic M6_QA, M6_QB, M6_QC, M6_QD, M6_RCO;
  DM9310 DM9316_M6(
    .CLK_DRV,
    .CLK(COUNT_2), .CLR_N(START_GAME_N), .LOAD_N(1'b1),
    .ENP(PLAYER2), .ENT(N6_RCO),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(M6_QA), .QB(M6_QB), .QC(M6_QC), .QD(M6_QD),
    .RCO(M6_RCO)
  );
  assign {E2, F2, G2, H2} = {M6_QA, M6_QB, M6_QC, M6_QD};

  // Hundreds digit
  logic L6_QA, L6_QB, L6_QC, L6_QD;
  DM9310 DM9316_L6(
    .CLK_DRV,
    .CLK(COUNT_2), .CLR_N(START_GAME_N), .LOAD_N(1'b1),
    .ENP(PLAYER2), .ENT(M6_RCO),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(L6_QA), .QB(L6_QB), .QC(L6_QC), .QD(L6_QD),
    .RCO()
  );
  assign {I2, J2, K2, L2} = {L6_QA, L6_QB, L6_QC, L6_QD};

endmodule
