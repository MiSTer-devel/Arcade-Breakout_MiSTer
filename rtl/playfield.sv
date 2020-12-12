/*
 * Playfield
 */
module playfield(
  input  logic _8H, _16H, _32H, _64H, _128H,
  input  logic _4V, _8V, _16V, _32V, _64V, _128V,
  input  logic VSYNC_N,
  input  logic BRICK_DISPLAY,
  output logic TOP_BOUND, RH_SIDE, LH_SIDE,
  output logic PLAYFIELD
);
  //
  // Top bound
  //
  logic H3b, L4c, K4b;
  assign H3b = ~(_128H | _32H | _64H);
  assign L4c = H3b & _16H & _8H;
  assign K4b = VSYNC_N & L4c;
  assign TOP_BOUND = K4b;

  //
  // RH/LH side
  //
  logic N4a, N4c, H2a, J2f, J3d;
  assign N4a = _128V & _64V & _16V;
  assign N4c = N4a & _8V & _4V;
  assign H2a = N4c & _32V;
  assign J2f = ~N4c;
  assign J3d = ~(J2f | _32V);
  assign RH_SIDE = H2a;
  assign LH_SIDE = J3d;

  //
  // Playfield
  //
  logic H3a, E1a, H4a;
  assign H3a = ~(LH_SIDE | TOP_BOUND | RH_SIDE);
  assign E1a = ~BRICK_DISPLAY;
  assign H4a = ~(H3a & E1a);
  assign PLAYFIELD = H4a;

endmodule
