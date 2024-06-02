`default_nettype none 
`default_nettype none
`timescale 1ns/1ns

// TODO: port naming
// unsure if I want to commit to renaming all of these wires 
// according to the convention though
module or1420SingleCoreSDRAM ( input wire    systemClock,     // 74.25MHz
                                             systemClockX2,   // 148.5MHz 
                                             pixelClockIn,    // 74.25MHz
                                             pixelClockInX2,  // 148.5MHz 
                                             clock12MHz,
                                             clock50MHz,
                                             systemReset,
                          input wire         RxD,
                          output wire        TxD,

                          output wire        sdramClk,
                          output wire        sdramCke,
                                             sdramCsN,
                                             sdramRasN,
                                             sdramCasN,
                                             sdramWeN,
                          output wire [1:0]  sdramDqmN,
                          output wire [12:0] sdramAddr,
                          output wire [1:0]  sdramBa,
                          output wire [15:0] sdramDataOut,
                          output wire        sdramDataDriven,
                          input wire [15:0]  sdramDataIn,

                          // The spi interface
                          output wire        spiScl,
                                             spiNCs,
                          output wire        spiSiIo0Out,
                                             spiSoIo1Out,
                                             spiIo2Out,
                                             spiIo3Out,
                          output wire        spiSiIo0Driven,
                                             spiSoIo1Driven,
                                             spiIo2Driven,
                                             spiIo3Driven,
                          input wire         spiSiIo0In,
                                             spiSoIo1In,
                                             spiIo2In,
                                             spiIo3In,

                          output             pixelClock,
                                             horizontalSync,
                                             verticalSync,
                                             activePixel,

                          input wire [7:0]   dipSwitch,
                          output wire [23:0] sevenSegments,
`ifdef GECKO5Education
                          output wire [4:0]  hdmiRed,
                                             hdmiBlue,
                          output wire [5:0]  hdmiGreen
`else
                          output wire [3:0]  hdmiRed,
                                             hdmiGreen,
                                             hdmiBlue,
`endif
                          output wire        SCL,
                          output             sdaDriven,
                          input              sdaIn,
                          input wire         camPclk,
                                             camHsync,
                                             camVsync,
                                             biosBypass,
                          input wire [7:0]   camData
                           );


  // instantiate bus wires
  wire        s_busError, s_beginTransaction, s_endTransaction;
  wire [31:0] s_addressData;
  wire [3:0]  s_byteEnables;
  wire        s_readNotWrite, s_dataValid, s_busy;
  wire [7:0]  s_burstSize;


  /*
   * Here we instantiate the SDRAM controller
   *
   */
  wire        s_sdramInitBusy, s_sdramEndTransaction, s_sdramDataValid;
  wire        s_sdramBusy, s_sdramBusError;
  wire [31:0] s_sdramAddressData;
  wire [5:0]  s_memoryDistance = 6'd0;
  
  sdramController #( .baseAddress(32'h00000000),
                     .systemClockInHz(`ifdef GECKO5Education 42857143 `else 42428571 `endif)) sdram
                   ( .clock(systemClock),
                     .clockX2(systemClockX2),
                     .reset(systemReset),
                     .memoryDistanceIn(s_memoryDistance),
                     .sdramInitBusy(s_sdramInitBusy),
                     .beginTransactionIn(s_beginTransaction),
                     .endTransactionIn(s_endTransaction),
                     .readNotWriteIn(s_readNotWrite),
                     .dataValidIn(s_dataValid),
                     .busErrorIn(s_busError),
                     .busyIn(s_busy),
                     .addressDataIn(s_addressData),
                     .byteEnablesIn(s_byteEnables),
                     .burstSizeIn(s_burstSize),
                     .endTransactionOut(s_sdramEndTransaction),
                     .dataValidOut(s_sdramDataValid),
                     .busyOut(s_sdramBusy),
                     .busErrorOut(s_sdramBusError),
                     .addressDataOut(s_sdramAddressData),
                     .sdramClk(sdramClk),
                     .sdramCke(sdramCke),
                     .sdramCsN(sdramCsN),
                     .sdramRasN(sdramRasN),
                     .sdramCasN(sdramCasN),
                     .sdramWeN(sdramWeN),
                     .sdramDqmN(sdramDqmN),
                     .sdramAddr(sdramAddr),
                     .sdramBa(sdramBa),
                     .sdramDataOut(sdramDataOut),
                     .sdramDataDriven(sdramDataDriven),
                     .sdramDataIn(sdramDataIn));

    /////////////////////////////////////////////
    // instantatiate SoC and hook up to SDRAM //
    ///////////////////////////////////////////
    or1420SingleCore iSingleCore (
        .systemClock(systemClock),
        .pixelClockIn(pixelClockIn),
        .pixelClockInX2(pixelClockInX2),
        .clock12MHz(clock12MHz),
        .clock50MHz(clock50MHz),
        .systemReset(systemReset),
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

        .ramInitBusy(s_sdramInitBusy),
        .ramEndTransaction(s_sdramEndTransaction),
        .ramDataValid(s_sdramDataValid),
        .ramBusy(s_sdramBusy),
        .ramBusError(s_sdramBusError),
        .ramAddressData(s_sdramAddressData),
        
        .spiScl(spiScl),
        .spiNCs(spiNCs),
        .spiSiIo0Out(spiSiIo0Out),
        .spiSoIo1Out(spiSoIo1Out),
        .spiIo2Out(spiIo2Out),
        .spiIo3Out(spiIo3Out),
        .spiSiIo0In(spiSiIo0In),
        .spiSoIo1In(spiSoIo1In),
        .spiIo2In(spiIo2In),
        .spiIo3In(spiIo3In),
        .spiSiIo0Driven(spiSiIo0Driven),
        .spiSoIo1Driven(spiSoIo1Driven),
        .spiIo2Driven(spiIo2Driven),
        .spiIo3Driven(spiIo3Driven),
        .pixelClock(pixelClock),
        .horizontalSync(horizontalSync),
        .verticalSync(verticalSync),
        .activePixel(activePixel),
        .dipSwitch(dipSwitch),
        .sevenSegments(sevenSegments),
        .hdmiRed(hdmiRed),
        .hdmiGreen(hdmiGreen),
        .hdmiBlue(hdmiBlue),
        .SCL(SCL),
        .sdaDriven(sdaDriven),
        .sdaIn(sdaIn),
        .camPclk(camPclk),
        .camHsync(camHsync),
        .camVsync(camVsync),
        .biosBypass(biosBypass),
        .camData(camData)
    );
 
endmodule

`default_nettype wire