module vsim_top();

reg clk, rst;

initial begin
    clk = 0;
    rst = 0;
    @(posedge clk);
    rst = 1;
    repeat (10) @(posedge clk);
    rst = 0;
    repeat (1000) @(posedge clk);
    $finish;
end

initial begin
    forever clk = #5 ~clk;
end

endmodule