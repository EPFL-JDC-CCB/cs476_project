`default_nettype none
`timescale 1ns/1ps

module rgb565Grayscale_tb;
  reg[4:0] r;
  reg[5:0] g;
  reg[4:0] b;
  wire [15:0] rgb = {r, g, b};
  wire [15:0] grayscale;
  reg [15:0] expected_value;

  // write a function for the expected value
  function [15:0] expected;
    input [4:0] r;
    input [5:0] g;
    input [4:0] b;
    begin
      expected = (54*r + 183*g + 19*b) >> 8;
    end
  endfunction

  rgb565Grayscale dut(
      .rgb(rgb),
      .grayscale(grayscale)
  );

  integer i;
  initial begin
    for (i = 0; i < 64; i = i + 1) begin
      r = $urandom_range(0, 31);
      g = $urandom_range(0, 63);
      b = $urandom_range(0, 31);
      expected_value = expected(r, g, b);
      #10;
      if (grayscale !== expected_value) begin
        $display("Error: r=%d, g=%d, b=%d, expected=%d, got=%d", r, g, b, expected_value, grayscale);
      end
    end
    
    $finish;
  end
endmodule

`default_nettype wire