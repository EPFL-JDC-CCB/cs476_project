module simplePrintSlave #(
    parameter [31: 0] baseAddr = 32'h60000000
) (
    input clk_i,
    input rst_i,

    // Slave Input
    input [31:0] bus_addrData_i,
    input [3:0] bus_byteEnables_i,
    input [7:0] bus_burstSize_i,
    input bus_readNWrite_i,
    input bus_beginTransaction_i,
    input bus_endTransaction_i,
    input bus_dataValid_i
);

reg go_r = 0;

wire isMyTransaction = (bus_addrData_i[31:25] == baseAddr[31:25]);

always @(posedge clk_i) begin
    if (rst_i) begin
        go_r <= 0;
    end else begin 
        go_r <= go_r ? (!bus_endTransaction_i) : (bus_beginTransaction_i & isMyTransaction);
    end
end

always @* begin
    if (go_r && bus_dataValid_i) begin
        $display("(t=%t) print: %x", $time, bus_addrData_i);
    end
end
endmodule