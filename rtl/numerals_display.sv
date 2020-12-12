/*
 * Numerals display
 */
module numerals_display(
  input  logic CLK_DRV,
  input  logic ATTRACT_N,
  input  logic BALL_A, BALL_B, BALL_C,
  input  logic PLAYER2,
  input  logic A1, B1, C1, D1, E1, F1, G1, H1, I1, J1, K1, L1,
  input  logic A2, B2, C2, D2, E2, F2, G2, H2, I2, J2, K2, L2,
  input  logic _2H, _4H, _8H, _16H, _32H, _32H_N, _64H, _128H,
  input  logic _4V, _8V, _16V, _16V_N, _32V, _64V, _128V,
  output logic SCORE
);
  //
  // Mux 7-seg input
  //
  logic C5c, M9d, C4d, A4d, C4c;
  logic N5_Y, M5_Y, L5_Y, K5_Y;
  logic PLAYER2_N;

  assign C5c = ~BALL_A;
  assign M9d = ~PLAYER2;
  assign C4d = BALL_A ^ BALL_B;
  assign A4d = BALL_A & BALL_B;
  assign C4c = BALL_C ^ A4d;
  assign PLAYER2_N = M9d;

  DM9312 DM9312_N5(
    .A(_16V), .B(_64V), .C(_128V),
    .D0(A2), .D1(E2), .D2(I2), .D3(C5c), .D4(A1), .D5(E1), .D6(I1), .D7(M9d),
    .G_N(_32H_N),
    .Y(N5_Y), .Y_N()
  );

  DM9312 DM9312_M5(
    .A(_16V), .B(_64V), .C(_128V),
    .D0(B2), .D1(F2), .D2(J2), .D3(C4d), .D4(B1), .D5(F1), .D6(J1), .D7(PLAYER2),
    .G_N(_32H_N),
    .Y(M5_Y), .Y_N()
  );

  DM9312 DM9312_L5(
    .A(_16V), .B(_64V), .C(_128V),
    .D0(C2), .D1(G2), .D2(K2), .D3(C4c), .D4(C1), .D5(G1), .D6(K1), .D7(1'b0),
    .G_N(_32H_N),
    .Y(L5_Y), .Y_N()
  );

  DM9312 DM9312_K5(
    .A(_16V), .B(_64V), .C(_128V),
    .D0(D2), .D1(H2), .D2(L2), .D3(1'b0), .D4(D1), .D5(H1), .D6(L1), .D7(1'b0),
    .G_N(_32H_N),
    .Y(K5_Y), .Y_N()
  );

  //
  // 7-seg decode
  //
  logic J5_a, J5_b, J5_c, J5_d, J5_e, J5_f, J5_g;

  SN7448 #(
    .BI_RBO_N_AS_INPUT(1'b0)
  ) SN7448_J5 (
    .BI_RBO_N(), .RBI_N(_32H), .LT_N(1'b1),
    .A(N5_Y), .B(M5_Y), .C(L5_Y), .D(K5_Y),
    .a(J5_a), .b(J5_b), .c(J5_c), .d(J5_d), .e(J5_e), .f(J5_f), .g(J5_g)
  );

  //
  // Separate horiz/vert components
  //
  logic K4d, L4b, H4d, H5_Y_N, J4_Y_N;

  assign K4d = _4V & _8V;
  assign L4b = _2H & _4H & _8H;
  assign H4d = ~(H5_Y_N & J4_Y_N);

  DM9312 DM9312_H5(
    .A(_2H), .B(_4H), .C(_8H),
    .D0(J5_a), .D1(1'b0), .D2(1'b0), .D3(J5_g), .D4(1'b0), .D5(1'b0), .D6(J5_d), .D7(1'b0),
    .G_N(K4d),
    .Y(), .Y_N(H5_Y_N)
  );

  DM9312 DM9312_J4(
    .A(_8H), .B(_4V), .C(_8V),
    .D0(J5_b), .D1(J5_c), .D2(1'b0), .D3(1'b0), .D4(J5_f), .D5(J5_e), .D6(1'b0), .D7(1'b0),
    .G_N(L4b),
    .Y(), .Y_N(J4_Y_N)
  );

  //
  // Blinking signal
  //
  logic B2_OUT;

  astable_555 #(
    .HIGH_COUNTS(7147849), // 124.81 ms
    .LOW_COUNTS(7145626)   // 124.77 ms
  ) astable_555_B2 (
    .CLK(CLK_DRV),
    .RESET_N(ATTRACT_N),
    .OUT(B2_OUT)
  );

  //
  // Gating
  //
  logic E9f, M3c, J3c, E9a, M8a, M8b, E3b, E2b, E2c, F2c, H4b;
  logic PLNR, SC1_N;

  assign E9f = ~B2_OUT;
  assign M3c = PLAYER2_N ^ _128V;
  assign J3c = ~(_64H | _128H);
  assign E9a = ~J3c;
  assign M8a = ~(E9f | M3c | PLNR);
  assign M8b = ~(M8a | E9a | E9a);

  assign E3b = ~(_32V | _16V_N);
  assign E2b = _64V ^ _32V;
  assign E2c = E3b ^ _16H;
  assign F2c = H4d & E2b & E2c;
  assign PLNR = E3b;

  assign H4b = ~(M8b & F2c);
  assign SC1_N = H4b;

  logic D3a_Q;
  assign D3a_Q = ~SC1_N; // Just invert, not using 7474
  assign SCORE = D3a_Q;

endmodule
