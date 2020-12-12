/*
 * DM9312 (One of Eight Line Data Selectors/Multiplexers)
 */
module DM9312(
  input  logic A, B, C,                         // Select inputs
  input  logic D0, D1, D2, D3, D4, D5, D6, D7,  // Data inputs
  input  logic G_N,                             // Strobe negative
  output logic Y, Y_N                           // Outputs
);
  logic d;

  always_comb begin
    unique case ({C, B, A})
      3'b000: d = D0;
      3'b001: d = D1;
      3'b010: d = D2;
      3'b011: d = D3;
      3'b100: d = D4;
      3'b101: d = D5;
      3'b110: d = D6;
      3'b111: d = D7;
    endcase
  end

  assign Y   = G_N ? 1'b0 : d;
  assign Y_N = ~Y;

endmodule
