// 74.25MHz clock
module tb_harness ( input wire clk, input wire rst );

    ////////////////////////
    // wire declarations //
    //////////////////////
    wire RxD;
    wire TxD;

    // instantiate bus wires
    wire        s_busError, s_beginTransaction, s_endTransaction;
    wire [31:0] s_addressData;
    wire [3:0]  s_byteEnables;
    wire        s_readNotWrite, s_dataValid, s_busy;
    wire [7:0]  s_burstSize;


    ////////////////////////////
    // instantiate ram slave //
    //////////////////////////
    wire [31:0] mem_out_addrData;
    wire mem_out_endTransaction;
    wire mem_out_dataValid;
    wire mem_out_busy;
    wire mem_out_error;

    simpleMemSlave #(
        .baseAddr(32'h00000000),
        // 1MB just for testing
        // real system has 32MB
        .memSize(1024*256)
    ) iMEM (
    .clk_i(clk),
    .rst_i(rst),
    .bus_addrData_i(s_addressData),
    .bus_byteEnables_i(s_byteEnables),
    .bus_burstSize_i(s_burstSize),
    .bus_readNWrite_i(s_readNotWrite),
    .bus_beginTransaction_i(s_beginTransaction),
    .bus_endTransaction_i(s_endTransaction),
    .bus_dataValid_i(s_dataValid),
    .bus_addrData_o(mem_out_addrData),
    .bus_endTransaction_o(mem_out_endTransaction),
    .bus_dataValid_o(mem_out_dataValid),
    .bus_busy_o(mem_out_busy),
    .bus_error_o(mem_out_error)
    );


    /////////////////////////////
    // instantiate uart model //
    ///////////////////////////
    uartdpi #(
        .BAUD(115200),
        .FREQ(74_250_000)
    ) iUART (
        .clk_i(clk),
        .rst_ni(~rst),
        .active(1'b1),
        .tx_o(RxD),
        .rx_i(TxD)
    );

    ////////////////////////
    // instantatiate SoC //
    //////////////////////
    or1420SingleCore iSingleCore (
        .systemClock(clk),
        // none of the other clocks are running for now
        .pixelClockIn(1'b0),    
        .pixelClockInX2(1'b0),
        .clock12MHz(1'b0), 
        .clock50MHz(1'b0),
        .systemReset(rst),
        .RxD(RxD),
        .TxD(TxD),

        .busError(s_busError),
        .beginTransaction(s_beginTransaction),
        .endTransaction(s_endTransaction),
        .addressData(s_addressData),
        .byteEnables(s_byteEnables),
        .readNotWrite(s_readNotWrite),
        .dataValid(s_dataValid),
        .busy(s_busy),
        .burstSize(s_burstSize),

        .ramInitBusy(1'b0),
        .ramEndTransaction(mem_out_endTransaction),
        .ramDataValid(mem_out_dataValid),
        .ramBusy(mem_out_busy),
        .ramBusError(mem_out_error),
        .ramAddressData(mem_out_addrData),
        
        .spiScl(),
        .spiNCs(),
        .spiSiIo0Out(),
        .spiSoIo1Out(),
        .spiIo2Out(),
        .spiIo3Out(),
        .spiSiIo0In(0),
        .spiSoIo1In(0),
        .spiIo2In(0),
        .spiIo3In(0),
        .spiSiIo0Driven(),
        .spiSoIo1Driven(),
        .spiIo2Driven(),
        .spiIo3Driven(),
        .pixelClock(),
        .horizontalSync(),
        .verticalSync(),
        .activePixel(),
        .dipSwitch(0),
        .sevenSegments(),
        .hdmiRed(),
        .hdmiGreen(),
        .hdmiBlue(),
        .SCL(),
        .sdaDriven(),
        .sdaIn(),
        .camPclk(0),
        .camHsync(0),
        .camVsync(0),
        .biosBypass(0),
        .camData(0)
    );
    
initial begin
    if ($test$plusargs("trace") != 0) begin
        $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
        $dumpfile("logs/vlt_dump.vcd");
        $dumpvars();
    end
end
endmodule
