/*
 * Ball motion counters
 */
module ball_motion_counters(
  input  logic CLK_DRV, CLOCK,
  input  logic CX0, CX1, X2,
  input  logic Y0, Y1, Y2,
  output logic BALL,
  output logic BRICK_SOUND, VB_HIT_SOUND, P_HIT_SOUND
);
  logic D7c, D8c, D7b;
  logic C7_QB, C7_QC, C7_QD, C7_RCO, C8_RCO;
  logic B7_QC, B7_QD, B7_RCO, B8_QA, B8_RCO;

  assign D7c = C7_QC & C7_QB & B7_QD;
  assign D8c = ~(B8_RCO & B7_RCO);
  assign D7b = D7c & B7_QC & B8_RCO;

  assign BRICK_SOUND  = B8_QA;
  assign VB_HIT_SOUND = B7_QD;
  assign P_HIT_SOUND  = B7_QC;
  assign BALL = D7b;

  DM9316 DM9316_C7(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(D8c), .ENP(1'b1), .ENT(1'b1),
    .A(CX0), .B(CX1), .C(X2), .D(1'b0),
    .QA(), .QB(C7_QB), .QC(C7_QC), .QD(C7_QD),
    .RCO(C7_RCO)
  );

  DM9316 DM9316_C8(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(1'b1), .ENP(C7_RCO), .ENT(C7_QD),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(), .QB(), .QC(), .QD(),
    .RCO(C8_RCO)
  );

  DM9316 DM9316_B7(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(D8c), .ENP(C8_RCO), .ENT(C7_RCO),
    .A(Y0), .B(Y1), .C(Y2), .D(1'b0),
    .QA(), .QB(), .QC(B7_QC), .QD(B7_QD),
    .RCO(B7_RCO)
  );

  DM9316 DM9316_B8(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(1'b1), .ENP(B7_RCO), .ENT(C8_RCO),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(B8_QA), .QB(), .QC(), .QD(),
    .RCO(B8_RCO)
  );

endmodule
