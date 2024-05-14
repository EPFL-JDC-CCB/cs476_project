`default_nettype none
`timescale 1ns/1ps

`define SYNTH_MODE

// Using shift+add method = 80 LUT with 5.617ns
// Using cont mult + add method = 58 LUT with 4.580ns

module rgb565Grayscale(
    input wire [15:0] rgb,
    output wire [15:0] grayscale
);
 
    wire[7:0] r = rgb[15:11] << 3;
    wire[7:0] g = rgb[10:5] << 2;
    wire[7:0] b = rgb[4:0] << 3;

    // Use the synthesizer
    `ifdef SYNTH_MODE
      assign grayscale = (r * 54 + g * 183 + b * 19) >> 8;
    `else
      assign grayscale = ((b + (b << 1) + (b << 4)) +
                          (g + (g << 1) + (g << 2) + (g << 4) + (g << 5) + (g << 7)) +
                          (r + (r << 1) + (r << 2) + (r << 4) + (r << 5))) >> 8;
    `endif // SYNTH_MODE
endmodule

// Custom instruction module
module rgb565GrayscaleIse #(
  parameter [7:0] customInstructionId = 8'd00
)(
  input wire start,
  input wire[31: 0] valueA,
  input wire [7: 0] iseId,
  output reg done,
  output reg[31: 0] result
);
  wire[15: 0] grayscale;
  rgb565Grayscale pe(
      .rgb(valueA[15: 0]),
      .grayscale(grayscale)
  );

  always @(*) begin
    done = 0;
    result = 0;

    if (start && iseId == customInstructionId) begin
      result = grayscale;
      done = 1;
    end
  end
endmodule

`default_nettype wire
