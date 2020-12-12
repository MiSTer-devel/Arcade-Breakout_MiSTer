/*
 * Coin
 */
module coin(
  input  logic CLK_DRV,
  input  logic CSW1, CSW2,
  input  logic S3, // 0: 1CREDIT/1COIN, 1: 2CREDITS/1COIN
  input  logic _4V__, _8V, _64V1, _64V_N, _16V__,
  input  logic BONUS_COIN,
  input  logic Q, _1_CR_START_N, _2_CR_START,
  output logic COIN1_N, COIN2_N,
  output logic _1_OR_2_CREDIT, _1_OR_2_CREDIT_N,
  output logic _2_CREDIT, _2_CREDIT_N,
  output logic [3:0] CREDITS
);
  logic S3O;
  assign S3O = S3 ? _4V__ : 1'b1;

  //
  // Coin 1P
  //
  logic CSW1_N;
  logic F8b_Q, F8a_Q, F8a_Q_N, H8b_Q, J8d_Q, J9c;

  assign CSW1_N = ~CSW1;
  assign J9c = ~(S3O & H8b_Q & J8d_Q);

  SN7474 SN7474_F8b(
    .CLK_DRV, .CLK(_64V1),
    .PRE_N(CSW1), .CLR_N(1'b1),
    .D(CSW1_N),
    .Q(F8b_Q), .Q_N()
  );

  SN7474 SN7474_F8a(
    .CLK_DRV, .CLK(_64V1),
    .PRE_N(CSW1), .CLR_N(1'b1),
    .D(F8b_Q),
    .Q(F8a_Q), .Q_N(F8a_Q_N)
  );

  SN7474 SN7474_H8b(
    .CLK_DRV, .CLK(_16V__),
    .PRE_N(1'b1), .CLR_N(1'b1),
    .D(F8a_Q_N),
    .Q(H8b_Q), .Q_N()
  );

  SN74279 SN74279_J8d(
    .CLK_DRV,
    .S_N(H8b_Q), .R_N(_16V__),
    .Q(J8d_Q)
  );

  assign COIN1_N = F8a_Q;

  //
  // Coin 2P
  //
  logic CSW2_N;
  logic H9b_Q, H9a_Q, H9a_Q_N, H8a_Q, J8b_Q, J9b;

  assign CSW2_N = ~CSW2;
  assign J9b = ~(S3O & H8a_Q & J8b_Q);

  SN7474 SN7474_H9b(
    .CLK_DRV, .CLK(_64V_N),
    .PRE_N(CSW2), .CLR_N(1'b1),
    .D(CSW2_N),
    .Q(H9b_Q), .Q_N()
  );

  SN7474 SN7474_H9a(
    .CLK_DRV, .CLK(_64V_N),
    .PRE_N(CSW2), .CLR_N(1'b1),
    .D(H9b_Q),
    .Q(H9a_Q), .Q_N(H9a_Q_N)
  );

  SN7474 SN7474_H8a(
    .CLK_DRV, .CLK(_16V__),
    .PRE_N(1'b1), .CLR_N(1'b1),
    .D(H9a_Q_N),
    .Q(H8a_Q), .Q_N()
  );

  SN74279 SN74279_J8b(
    .CLK_DRV,
    .S_N(H8a_Q), .R_N(_16V__),
    .Q(J8b_Q)
  );

  assign COIN2_N = H9a_Q;

  //
  // Coin 1P + 2P
  //
  logic L9b, COIN;
  assign L9b = ~J9c | ~J9b;
  assign COIN = L9b;

  //
  // Coin accumlator
  //
  logic E7c, D8a, H7a, L9c, H8c, M9f, F9c, L9a, F9d;
  logic L8_QA, L8_QB, L8_QC, L8_QD, L8_BO_N, L8_CO_N;

  assign E7c = ~(BONUS_COIN | COIN);
  assign D8a = ~(_8V & _2_CR_START);
  assign H7a = ~(~_1_CR_START_N | ~D8a);
  assign L9c = ~Q | ~L8_BO_N;
  assign H8c = ~(L8_QB | L8_QC | L8_QD);
  assign M9f = ~L8_QA;
  assign F9c = ~H8c;
  assign L9a = ~H8c | ~M9f;
  assign F9d = ~L9a;

  // break combinational loop
  logic H7aq, L9cq, L8_CO_Nq;
  always_ff @(posedge CLK_DRV) H7aq <= H7a;
  always_ff @(posedge CLK_DRV) L9cq <= L9c;
  always_ff @(posedge CLK_DRV) L8_CO_Nq <= L8_CO_N;

  SN74193 SN74193_L8(
    .CLK_DRV,
    .UP(E7c), .DOWN(H7aq),
    .CLR(L9cq), .LOAD_N(L8_CO_Nq),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(L8_QA), .QB(L8_QB), .QC(L8_QC), .QD(L8_QD),
    .BO_N(L8_BO_N), .CO_N(L8_CO_N)
  );

  assign _1_OR_2_CREDIT   = L9a;
  assign _1_OR_2_CREDIT_N = F9d;
  assign _2_CREDIT   = F9c;
  assign _2_CREDIT_N = H8c;

  assign CREDITS = {L8_QD, L8_QC, L8_QB, L8_QA};

endmodule
