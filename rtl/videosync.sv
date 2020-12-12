/*
 * Video sync
 */
module videosync(
  input   logic CLK_DRV, CLOCK,
  input   logic PAD_N, BALL_DISPLAY,
  input   logic PLAYER2_CONDITIONAL,
  output  logic _1H, _2H, _4H, _8H, _16H, _32H, _64H, _128H,
  output  logic _2V, _4V, _8V, _16V, _32V, _64V, _128V,
  output  logic _8H_N, _16H_N, _32H_N, _16V_N, _64V_N, _64V1,
  output  logic _8H__, _4V__, _8V__, _16V__, _32V__, _64V__, _128V__,
  output  logic HSYNC, HSYNC_N,
  output  logic VSYNC, VSYNC_N,
  output  logic CSYNC,
  output  logic PSYNC, PSYNC_N,
  output  logic BSYNC, BSYNC_N,
  output  logic PAD,
  output  logic SCLOCK,
  output  logic [7:0] HCNT,
  output  logic [7:0] VCNT
);
  //
  // Raw count value
  //
  logic _1H_, _2H_, _4H_, _8H_, _16H_, _32H_, _64H_, _128H_;
  logic _1V_, _2V_, _4V_, _8V_, _16V_, _32V_, _64V_, _128V_;

  assign HCNT = {_128H_, _64H_, _32H_, _16H_, _8H_, _4H_, _2H_, _1H_};
  assign VCNT = {_128V_, _64V_, _32V_, _16V_, _8V_, _4V_, _2V_, _1V_};

  assign _8H__ = _8H_;
  assign _4V__ = _4V_;
  assign _8V__ = _8V_;
  assign _16V__ = _16V_;
  assign _32V__ = _32V_;
  assign _64V__ = _64V_;
  assign _128V__ = _128V_;

  //
  // Horizontal + Vertical counter
  //
  logic L1_RCO, K1_RCO, M1_RCO;
  assign SCLOCK = K1_RCO;

  logic H2b, N4b, H1c;
  assign H2b = L1_RCO & M1_RCO;
  assign N4b = _32V_ & _64V_ & _128V_;
  assign H1c = ~(N4b & VSYNC_N);

  DM9316 DM9316_L1(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(H1c), .ENP(1'b1), .ENT(1'b1),
    .A(1'b1), .B(1'b0), .C(1'b1), .D(1'b0),
    .QA(_1H_), .QB(_2H_), .QC(_4H_), .QD(_8H_),
    .RCO(L1_RCO)
  );

  DM9316 DM9316_K1(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(1'b1), .ENP(L1_RCO), .ENT(1'b1),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(_16H_), .QB(_32H_), .QC(_64H_), .QD(_128H_),
    .RCO(K1_RCO)
  );

  DM9316 DM9316_M1(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(H1c), .ENP(L1_RCO), .ENT(K1_RCO),
    .A(1'b0), .B(1'b0), .C(1'b1), .D(1'b0),
    .QA(_1V_), .QB(_2V_), .QC(_4V_), .QD(_8V_),
    .RCO(M1_RCO)
  );

  DM9316 DM9316_N1(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1), .LOAD_N(1'b1), .ENP(H2b), .ENT(1'b1),
    .A(1'b1), .B(1'b1), .C(1'b1), .D(1'b1),
    .QA(_16V_), .QB(_32V_), .QC(_64V_), .QD(_128V_),
    .RCO()
  );

  //
  // Synchronize
  //
  SN74175 SN74175_J1(
    .CLK_DRV,
    .CLK(CLOCK), .CLR_N(1'b1),

    .DA(K1_RCO),
    .DB(N4b),
    .DC(PAD_N),
    .DD(BALL_DISPLAY),

    .QA(HSYNC),   .QA_N(HSYNC_N),
    .QB(VSYNC),   .QB_N(VSYNC_N),
    .QC(PSYNC_N), .QC_N(PSYNC),
    .QD(BSYNC),   .QD_N(BSYNC_N)
  );

  logic D2b, E3c, E2d;
  assign D2b = _16V_ | _8V_;
  assign E3c = ~(VSYNC_N | D2b);
  assign E2d = HSYNC_N ^ E3c;
  assign CSYNC = E2d;

  //
  // Pad gating
  //
  logic B9a;
  assign B9a = PSYNC & VSYNC_N;
  assign PAD = B9a;

  //
  // Scren rotation logic for cocktail table 2P
  //
  logic M2_S2, M2_S3, M2_S4, M2_C4;
  SN7483 SN7483_M2(
    .A1(_1V_), .A2(_2V_), .A3(_4V_), .A4(_8V_),
    .B1(1'b0), .B2(PLAYER2_CONDITIONAL), .B3(1'b0), .B4(1'b0),
    .C0(1'b0),
    .S1(), .S2(M2_S2), .S3(M2_S3), .S4(M2_S4),
    .C4(M2_C4)
  );

  logic N2_S1, N2_S2, N2_S3, N2_S4;
  SN7483 SN7483_N2(
    .A1(_16V_), .A2(_32V_), .A3(_64V_), .A4(_128V_),
    .B1(1'b0), .B2(PLAYER2_CONDITIONAL), .B3(1'b0), .B4(1'b0),
    .C0(M2_C4),
    .S1(N2_S1), .S2(N2_S2), .S3(N2_S3), .S4(N2_S4),
    .C4()
  );

  logic M3a, M3b, M3d, N3c, N3a, N3b, N3d, H7d;

  assign M3a = M2_S2 ^ PLAYER2_CONDITIONAL;
  assign M3b = M2_S3 ^ PLAYER2_CONDITIONAL;
  assign M3d = M2_S4 ^ PLAYER2_CONDITIONAL;
  assign N3c = N2_S1 ^ PLAYER2_CONDITIONAL;
  assign N3a = N2_S2 ^ PLAYER2_CONDITIONAL;
  assign N3b = N2_S3 ^ PLAYER2_CONDITIONAL;
  assign N3d = N2_S4 ^ PLAYER2_CONDITIONAL;
  assign H7d = N3d & N3d;

  assign _2V = M3a;
  assign _4V = M3b;
  assign _8V = M3d;
  assign _16V = N3c;
  assign _32V = N3a;
  assign _64V = N3b;
  assign _128V = N3d;
  assign _64V1 = H7d;

  logic L2c, L2d, L2a, L2b, K2c, K2d, K2a, K2b;

  assign L2c = _1H_   ^ PLAYER2_CONDITIONAL;
  assign L2d = _2H_   ^ PLAYER2_CONDITIONAL;
  assign L2a = _4H_   ^ PLAYER2_CONDITIONAL;
  assign L2b = _8H_   ^ PLAYER2_CONDITIONAL;
  assign K2c = _16H_  ^ PLAYER2_CONDITIONAL;
  assign K2d = _32H_  ^ PLAYER2_CONDITIONAL;
  assign K2a = _64H_  ^ PLAYER2_CONDITIONAL;
  assign K2b = _128H_ ^ PLAYER2_CONDITIONAL;

  assign _1H   = L2c;
  assign _2H   = L2d;
  assign _4H   = L2a;
  assign _8H   = L2b;
  assign _16H  = K2c;
  assign _32H  = K2d;
  assign _64H  = K2a;
  assign _128H = K2b;

  //
  // Inverted signal
  //
  logic M9e, J2c, J2b, J2e, J2a;
  assign M9e = ~_64V;
  assign J2c = ~_16H;
  assign J2b = ~_32H;
  assign J2e = ~_16V;
  assign J2a = ~_8H;

  assign _64V_N = M9e;
  assign _16H_N = J2c;
  assign _32H_N = J2b;
  assign _16V_N = J2e;
  assign _8H_N  = J2a;

endmodule

