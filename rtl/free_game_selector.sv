/*
 * Free game selector
 */
module free_game_selector(
  input  logic       CLK_DRV,
  input  logic [3:0] S1, // BONUS CREDIT SCORE
                         //  0000: No bonus credit
                         //  1000: 100 pts, 0100: 200 pts, 1100: 300 pts, 0010: 400 pts
                         //  1010: 500 pts, 0110: 600 pts, 1110: 700 pts, 0001: 800 pts
  input  logic       I1, J1, K1, L1, I2, J2, K2, L2,
  input  logic       HSYNC_N, _4V__,
  input  logic       Q, ATTRACT_N, EGL, START_GAME1_N,
  output logic       BONUS_COIN,
  output logic       FREE_GAME_TONE
);
  logic A, B, C, D;
  assign {A, B, C, D} = {~S1[3], ~S1[2], ~S1[1], ~S1[0]};

  //
  // Bonus coin signal gen
  //
  logic K7a, K7d, K7b, K7c, L7a, L7d, L7b, L7c;
  assign K7a = I1 ^ A;
  assign K7d = J1 ^ B;
  assign K7b = K1 ^ C;
  assign K7c = L1 ^ D;
  assign L7a = I2 ^ A;
  assign L7d = J2 ^ B;
  assign L7b = K2 ^ C;
  assign L7c = L2 ^ D;

  logic J7b, J7a;
  assign J7b = ~(K7a & K7d & K7b & K7c);
  assign J7a = ~(L7a & L7d & L7b & L7c);

  logic J8c_S_N, J8a_S_N, J8c_Q, J8a_Q, K8b_Q, K8a_Q, K9b_Q_N, K9a_Q_N;
  assign J8c_S_N = START_GAME1_N & K8b_Q;
  assign J8a_S_N = START_GAME1_N & K8a_Q;

  SN74279 SN74279_J8c(
    .CLK_DRV,
    .S_N(J8c_S_N), .R_N(J7b),
    .Q(J8c_Q)
  );

  SN74279 SN74279_J8a(
    .CLK_DRV,
    .S_N(J8a_S_N), .R_N(J7a),
    .Q(J8a_Q)
  );

  SN7474 SN7474_K8b(
    .CLK_DRV,
    .CLK(EGL), .PRE_N(Q), .CLR_N(1'b1),
    .D(J8c_Q),
    .Q(K8b_Q), .Q_N()
  );

  SN7474 SN7474_K8a(
    .CLK_DRV,
    .CLK(EGL), .PRE_N(Q), .CLR_N(1'b1),
    .D(J8a_Q),
    .Q(K8a_Q), .Q_N()
  );

  SN74107 SN74107_K9b(
    .CLK_DRV,
    .CLK_N(J8c_Q), .CLR_N(HSYNC_N),
    .J(1'b1), .K(1'b0),
    .Q(), .Q_N(K9b_Q_N)
  );

  SN74107 SN74107_K9a(
    .CLK_DRV,
    .CLK_N(J8a_Q), .CLR_N(HSYNC_N),
    .J(1'b1), .K(1'b0),
    .Q(), .Q_N(K9a_Q_N)
  );

  logic L9d;
  assign L9d = ~K9b_Q_N | ~K9a_Q_N;
  assign BONUS_COIN = L9d;

  //
  // Free game tone
  //
  logic N8a_Q, N7a;
  assign N7a = _4V__ & N8a_Q;

  DM9602 #(
    .COUNTS(66206432)  // 1156 ms
  ) DM9602_A7a (
    .CLK(CLK_DRV),
    .A_N(1'b1), .B(BONUS_COIN),
    .CLR_N(ATTRACT_N),
    .Q(N8a_Q), .Q_N()
  );

  assign FREE_GAME_TONE = N7a;

endmodule
