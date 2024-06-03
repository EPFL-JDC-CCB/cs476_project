// 74.25MHz clock
module tb_harness #(
    parameter integer runcnt_p = 0
)(
    input wire clk,
    input wire clkX2,

    output wire pixelClock,
    output wire horizontalSync,
    output wire verticalSync,
    output wire activePixel,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);
    reg rst;
    reg started;
    integer runcnt_arg = runcnt_p;
    string mem_file = "";

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
    .hexFile(""),
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

    ////////////////////////////
    // instantiate flash slave //
    //////////////////////////
    wire [31:0] flash_out_addrData;
    wire flash_out_endTransaction;
    wire flash_out_dataValid;
    wire flash_out_busy;
    wire flash_out_error;

    simpleMemSlave #(
        .baseAddr(32'h04000000),
        // 1MB just for testing
        // real system has 32MB
        .memSize(1024*256)
    ) iFLASH (
    .clk_i(clk),
    .rst_i(rst),
    .hexFile(mem_file),
    .bus_addrData_i(s_addressData),
    .bus_byteEnables_i(s_byteEnables),
    .bus_burstSize_i(s_burstSize),
    .bus_readNWrite_i(s_readNotWrite),
    .bus_beginTransaction_i(s_beginTransaction),
    .bus_endTransaction_i(s_endTransaction),
    .bus_dataValid_i(s_dataValid),
    .bus_addrData_o(flash_out_addrData),
    .bus_endTransaction_o(flash_out_endTransaction),
    .bus_dataValid_o(flash_out_dataValid),
    .bus_busy_o(flash_out_busy),
    .bus_error_o(flash_out_error)
    );

    //////////////////////////////
    // instantiate print slave //
    ////////////////////////////

    simplePrintSlave #(
        .baseAddr(32'h60000000)
    ) iPRINTSLV (
        .clk_i(clk),
        .rst_i(rst),
        .bus_addrData_i(s_addressData),
        .bus_byteEnables_i(s_byteEnables),
        .bus_burstSize_i(s_burstSize),
        .bus_readNWrite_i(s_readNotWrite),
        .bus_beginTransaction_i(s_beginTransaction),
        .bus_endTransaction_i(s_endTransaction),
        .bus_dataValid_i(s_dataValid)
    );


    /////////////////////////////
    // instantiate uart model //
    ///////////////////////////
    uartprint #(
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
    or1420SingleCore  #( 
        .PidReferenceClockFrequencyInHz(74_250_000),
        .DelayReferenceClockFrequencyInHz(74_250_000)
    ) iSingleCore (
        .systemClock(clk),
        .pixelClockIn(clk),    
        .pixelClockInX2(clkX2),
        .pidRefClockIn(clk), 
        .delayRefClockIn(clk),
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

        .ciN(),
        .ciDataA(),
        .ciDataB(),
        .ciStart(),
        .ciCke(),

        .flashEndTransaction(flash_out_endTransaction),
        .flashDataValid(flash_out_dataValid),
        .flashBusy(flash_out_busy),
        .flashBusError(flash_out_error),
        .flashAddressData(flash_out_addrData),

        .flashDone(0),
        .flashResult(0),
        
        .pixelClock(pixelClock),
        .horizontalSync(horizontalSync),
        .verticalSync(verticalSync),
        .activePixel(activePixel),
        .dipSwitch(0),
        .sevenSegments(),
        .hdmiRed(red),
        .hdmiGreen(green),
        .hdmiBlue(blue),
        .SCL(),
        .sdaDriven(),
        .sdaIn(),
        .camPclk(0),
        .camHsync(0),
        .camVsync(0),
        .biosBypass(1'b1),
        .camData(0)
    );
    
initial begin
    rst = 0;
    started = 0;
    $value$plusargs("limit=%d", runcnt_arg);
    $value$plusargs("memfile=%s", mem_file);
    if ($test$plusargs("trace") != 0) begin
        $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
        $dumpfile("logs/vlt_dump.vcd");
        $dumpvars();
    end
end

integer runcnt = 0;
always @(negedge clk) begin
    runcnt <= runcnt + 1;
    if (runcnt <= 10) rst <= 1;
    else if (runcnt_arg != 0 && runcnt == runcnt_arg) $finish;
    else begin 
        rst <= 0; 
        started <= 1;
        // to only trace after the started, move testplusargs stuff here
    end
end

endmodule
