`timescale 1ns/1ns
module tb_top();

reg clk;

tb_harness tb_harness (.clk(clk));

initial begin
    clk = 0;
end

initial begin
    #2;
    forever clk = #1 ~clk;
end

endmodule
