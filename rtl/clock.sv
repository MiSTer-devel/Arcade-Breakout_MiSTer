/*
 * Clock
 */
module clock(
  input  logic CLK_DRV, CLK_SRC,
  output logic CLOCK, CKBH
);
  logic E1c, H1d, F1_QA, F1_QB, F1_RCO;

  assign E1c = ~F1_RCO;
  assign H1d = ~(F1_QA & F1_QB);

  DM9316 DM9316_F1(
    .CLK_DRV,
    .CLK(CLK_SRC), .CLR_N(1'b1), .LOAD_N(E1c), .ENP(1'b1), .ENT(1'b1),
    .A(1'b0), .B(1'b1), .C(1'b0), .D(1'b0),
    .QA(F1_QA), .QB(F1_QB), .QC(), .QD(),
    .RCO(F1_RCO)
  );

  assign CLOCK = H1d;
  assign CKBH  = F1_QB;

endmodule
