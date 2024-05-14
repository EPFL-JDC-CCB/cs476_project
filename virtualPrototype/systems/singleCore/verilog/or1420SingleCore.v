`default_nettype none
`timescale 1ns/1ns

// TODO: port naming
// unsure if I want to commit to renaming all of these wires 
// according to the convention though
module or1420SingleCore ( input wire         systemClock,     // 74.25MHz
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

  wire        s_busIdle, s_snoopableBurst;
  wire        s_hdmiDone, s_swapByteDone, s_flashDone, s_cpuFreqDone;
  wire [31:0] s_hdmiResult, s_swapByteResult, s_flashResult, s_cpuFreqResult;
  wire [5:0]  s_memoryDistance = 6'd0;
  wire        s_busError, s_beginTransaction, s_endTransaction;
  wire [31:0] s_addressData;
  wire [3:0]  s_byteEnables;
  wire        s_readNotWrite, s_dataValid, s_busy;
  wire [7:0]  s_burstSize;

  /*
   * Here we instantiate the UART
   *
   */
  wire s_uartIrq, s_uartEndTransaction, s_uartDataValid, s_uartBusError;
  wire [31:0] s_uartAddressData;
  uartBus #( .baseAddress(32'h50000000) ) uart1
           ( .clock(systemClock),
             .reset(systemReset),
             .irq(s_uartIrq),
             .beginTransactionIn(s_beginTransaction),
             .endTransactionIn(s_endTransaction),
             .readNWriteIn(s_readNotWrite),
             .dataValidIn(s_dataValid),
             .busyIn(s_busy),
             .addressDataIn(s_addressData),
             .byteEnablesIn(s_byteEnables),
             .burstSizeIn(s_burstSize),
             .addressDataOut(s_uartAddressData),
             .endTransactionOut(s_uartEndTransaction),
             .dataValidOut(s_uartDataValid),
             .busErrorOut(s_uartBusError),
             .RxD(RxD),
             .TxD(TxD));

  /*
   * Here we instantiate the SDRAM controller
   *
   */
  wire        s_sdramInitBusy, s_sdramEndTransaction, s_sdramDataValid;
  wire        s_sdramBusy, s_sdramBusError;
  wire [31:0] s_sdramAddressData;
  wire        s_cpuReset = systemReset | s_sdramInitBusy;
  
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

  /*
   * Here we instantiate the CPU
   *
   */
  wire [31:0] s_cpu1CiResult, s_profileResult, s_grayResult, s_ramDmaResult;
  wire [31:0] s_cpu1CiDataA, s_cpu1CiDataB, s_camCiResult, s_delayResult;
  wire [7:0]  s_cpu1CiN;
  wire        s_cpu1CiRa, s_cpu1CiRb, s_cpu1CiRc, s_cpu1CiStart, s_cpu1CiCke, s_cpu1CiDone, s_i2cCiDone, s_delayCiDone;
  wire [4:0]  s_cpu1CiA, s_cpu1CiB, s_cpu1CiC;
  wire        s_cpu1IcacheRequestBus, s_cpu1DcacheRequestBus, s_camCiDone, s_ramDmaDone;
  wire        s_cpu1IcacheBusAccessGranted, s_cpu1DcacheBusAccessGranted;
  wire        s_cpu1BeginTransaction, s_cpu1EndTransaction, s_cpu1ReadNotWrite;
  wire [31:0] s_cpu1AddressData, s_i2cCiResult;
  wire [3:0]  s_cpu1byteEnables;
  wire        s_cpu1DataValid;
  wire [7:0]  s_cpu1BurstSize;
  wire        s_spm1Irq, s_profileDone, s_stall, s_grayDone;
  
  assign s_cpu1CiDone = s_hdmiDone | s_swapByteDone | s_flashDone | s_cpuFreqDone | s_i2cCiDone | s_delayCiDone | s_camCiDone | s_profileDone | s_grayDone | s_ramDmaDone;
  assign s_cpu1CiResult = s_hdmiResult | s_swapByteResult | s_flashResult | s_cpuFreqResult | s_i2cCiResult | s_camCiResult | s_delayResult | s_profileResult | s_grayResult |
                          s_ramDmaResult; 

  or1420Top #( .NOP_INSTRUCTION(32'h1500FFFF)) cpu1
             (.cpuClock(systemClock),
              .cpuReset(s_cpuReset),
              .irq(1'b0),
              .cpuIsStalled(s_stall),
              .iCacheReqBus(s_cpu1IcacheRequestBus),
              .dCacheReqBus(s_cpu1DcacheRequestBus),
              .iCacheBusGrant(s_cpu1IcacheBusAccessGranted),
              .dCacheBusGrant(s_cpu1DcacheBusAccessGranted),
              .busErrorIn(s_busError),
              .busyIn(s_busy),
              .beginTransActionOut(s_cpu1BeginTransaction),
              .addressDataIn(s_addressData),
              .addressDataOut(s_cpu1AddressData),
              .endTransactionIn(s_endTransaction),
              .endTransactionOut(s_cpu1EndTransaction),
              .byteEnablesOut(s_cpu1byteEnables),
              .dataValidIn(s_dataValid),
              .dataValidOut(s_cpu1DataValid),
              .readNotWriteOut(s_cpu1ReadNotWrite),
              .burstSizeOut(s_cpu1BurstSize),
              .ciStart(s_cpu1CiStart),
              .ciReadRa(s_cpu1CiRa),
              .ciReadRb(s_cpu1CiRb),
              .ciWriteRd(s_cpu1CiRc),
              .ciN(s_cpu1CiN),
              .ciA(s_cpu1CiA),
              .ciB(s_cpu1CiB),
              .ciD(s_cpu1CiC),
              .ciDataA(s_cpu1CiDataA),
              .ciDataB(s_cpu1CiDataB),
              .ciResult(s_cpu1CiResult),
              .ciDone(s_cpu1CiDone));
              
              assign s_cpu1CiCke = 1'b1;

  /*
   *
   * Here we define a custom instruction that determines the cpu-frequency
   *
   *
   */
  wire [31:0] s_cpuFreqValue;
  assign s_cpuFreqDone = (s_cpu1CiN == 8'd4) ? s_cpu1CiStart : 1'b0;
  assign s_cpuFreqResult = (s_cpu1CiN == 8'd4 && s_cpu1CiStart == 1'b1) ? s_cpuFreqValue : 32'd0;
  
  processorId #( .processorId(1),
                 .NumberOfProcessors(1),
                 .ReferenceClockFrequencyInHz(50000000) ) cpuFreq
               ( .clock(systemClock),
                 .reset(s_cpuReset),
                 .referenceClock(clock50MHz),
                 .biosBypass(biosBypass),
                 .procFreqId(s_cpuFreqValue) );

  /*
   *
   * Here we define a custom instruction that swaps bytes
   *
   */
  swapByte #(.customIntructionNr(8'd1)) ise1
            (.ciN(s_cpu1CiN),
             .ciDataA(s_cpu1CiDataA),
             .ciDataB(s_cpu1CiDataB),
             .ciStart(s_cpu1CiStart),
             .ciCke(s_cpu1CiCke),
             .ciDone(s_swapByteDone),
             .ciResult(s_swapByteResult));
  /*
   *
   * Here we define a custom instruction that implements a simple I2C interface
   *
   */
  i2cCustomInstr #(.CLOCK_FREQUENCY(74250000),
                   .I2C_FREQUENCY(400000),
                   .CUSTOM_ID(8'd5)) i2cm
                  (.clock(systemClock),
                   .reset(s_cpuReset),
                   .ciStart(s_cpu1CiStart),
                   .ciCke(s_cpu1CiCke),
                   .ciN(s_cpu1CiN),
                   .ciOppA(s_cpu1CiDataA),
                   .ciDone(s_i2cCiDone),
                   .result(s_i2cCiResult),
                   .sdaDriven(sdaDriven),
                   .sdaIn(sdaIn),
                   .SCL(SCL));

  /*
   *
   * Here we define a custom instruction that implements a blocking micro-second(s) delay element
   *
   */
  delayIse #(.referenceClockFrequencyInHz(12000000),
             .customInstructionId(8'd6) ) delayMicro
            (.clock(systemClock),
             .referenceClock(clock12MHz),
             .reset(s_cpuReset),
             .ciStart(s_cpu1CiStart),
             .ciCke(s_cpu1CiCke),
             .ciN(s_cpu1CiN),
             .ciValueA(s_cpu1CiDataA),
             .ciValueB(s_cpu1CiDataB),
             .ciDone(s_delayCiDone),
             .ciResult(s_delayResult));

  /*
   *
   * A profile ISE
   *
   */
  profileCi #(.customId(8'd12)) profiler
             (.start(s_cpu1CiStart),
              .clock(systemClock),
              .reset(s_cpuReset),
              .stall(s_stall),
              .busIdle(s_busIdle),
              .valueA(s_cpu1CiDataA),
              .valueB(s_cpu1CiDataB),
              .ciN(s_cpu1CiN),
              .done(s_profileDone),
              .result(s_profileResult) );

  /*
   *
   * An rgb to grayscale ISE
   *
   */
  rgb565GrayscaleIse #(.customInstructionId(8'd9)) converter
                      (.start(s_cpu1CiStart),
                       .valueA(s_cpu1CiDataA),
                       .valueB(s_cpu1CiDataB),
                       .iseId(s_cpu1CiN),
                       .done(s_grayDone),
                       .result(s_grayResult) );
  
  /*
   *
   * The RAM-DMA ISE
   *
   */
  wire s_ramDmaRequest, s_ramDmaGranted, s_ramDmaBeginTransaction, s_ramDmaReadNotWrite;
  wire s_ramDmaEndTransaction, s_ramDmaDataValid;
  wire [3:0] s_ramDmaByteEnables;
  wire [7:0] s_ramDmaBurstSize;
  wire [31:0] s_ramDmaAddressData;
  
  ramDmaCi #(.customId(8'd20) ) ramDma
            (.start(s_cpu1CiStart),
             .clock(systemClock),
             .reset(s_cpuReset),
             .valueA(s_cpu1CiDataA),
             .valueB(s_cpu1CiDataB),
             .ciN(s_cpu1CiN),
             .done(s_ramDmaDone),
             .result(s_ramDmaResult),
             .requestTransaction(s_ramDmaRequest),
             .transactionGranted(s_ramDmaGranted),
             .endTransactionIn(s_endTransaction),
             .dataValidIn(s_dataValid),
             .busErrorIn(s_busError),
             .busyIn(s_busy),
             .addressDataIn(s_addressData),
             .beginTransactionOut(s_ramDmaBeginTransaction),
             .readNotWriteOut(s_ramDmaReadNotWrite),
             .endTransactionOut(s_ramDmaEndTransaction),
             .dataValidOut(s_ramDmaDataValid),
             .byteEnablesOut(s_ramDmaByteEnables),
             .burstSizeOut(s_ramDmaBurstSize),
             .addressDataOut(s_ramDmaAddressData));

  /*
   *
   * Here we define the camera interface
   *
   */
  wire s_camReqBus, s_camAckBus, s_camBeginTransaction, s_camEndTransaction;
  wire s_camDataValid;
  wire [31:0] s_camAddressData;
  wire [3:0] s_camByteEnables;
  wire [7:0] s_camBurstSize;
  
  camera #(.customInstructionId(8'd7),
           .clockFrequencyInHz(74250000)) camIf
          (.clock(systemClock),
           .pclk(camPclk),
           .reset(s_cpuReset),
           .hsync(camHsync),
           .vsync(camVsync),
           .ciStart(s_cpu1CiStart),
           .ciCke(s_cpu1CiCke),
           .ciN(s_cpu1CiN),
           .camData(camData),
           .ciValueA(s_cpu1CiDataA),
           .ciValueB(s_cpu1CiDataB),
           .ciResult(s_camCiResult),
           .ciDone(s_camCiDone),
           .requestBus(s_camReqBus),
           .busGrant(s_camAckBus),
           .beginTransactionOut(s_camBeginTransaction),
           .addressDataOut(s_camAddressData),
           .endTransactionOut(s_camEndTransaction),
           .byteEnablesOut(s_camByteEnables),
           .dataValidOut(s_camDataValid),
           .burstSizeOut(s_camBurstSize),
           .busyIn(s_busy),
           .busErrorIn(s_busError));


  /*
   *
   * Here the hdmi controller is defined
   *
   */
  wire        s_hdmiRequestBus, s_hdmiBusgranted, s_hdmiBeginTransaction;
  wire        s_hdmiEndTransaction, s_hdmiDataValid, s_hdmiReadNotWrite;
  wire [3:0]  s_hdmiByteEnables;
  wire [7:0]  s_hdmiBurstSize;
  wire [31:0] s_hdmiAddressData;

  screens #(.baseAddress(32'h50000020),
            .pixelClockFrequency(27'd74250000),
            .cursorBlinkFrequency(27'd1)) hdmi 
           (.pixelClockIn(pixelClockIn),
            .clock(systemClock),
            .reset(systemReset),
            .testPicture(1'b0),
            .dualText(1'b0),
            .ci1N(s_cpu1CiN),
            .ci1DataA(s_cpu1CiDataA),
            .ci1DataB(s_cpu1CiDataB),
            .ci1Start(s_cpu1CiStart),
            .ci1Cke(s_cpu1CiCke),
            .ci1Done(s_hdmiDone),
            .ci1Result(s_hdmiResult),
            .ci2N(8'd0),
            .ci2DataA(32'd0),
            .ci2DataB(32'd0),
            .ci2Start(1'b0),
            .ci2Cke(1'b0),
            .ci2Done(),
            .ci2Result(),
            .requestTransaction(s_hdmiRequestBus),
            .transactionGranted(s_hdmiBusgranted),
            .beginTransactionIn(s_beginTransaction),
            .endTransactionIn(s_endTransaction),
            .readNotWriteIn(s_readNotWrite),
            .dataValidIn(s_dataValid),
            .busErrorIn(s_busError),
            .addressDataIn(s_addressData),
            .byteEnablesIn(s_byteEnables),
            .burstSizeIn(s_burstSize),
            .beginTransactionOut(s_hdmiBeginTransaction),
            .endTransactionOut(s_hdmiEndTransaction),
            .dataValidOut(s_hdmiDataValid),
            .readNotWriteOut(s_hdmiReadNotWrite),
            .byteEnablesOut(s_hdmiByteEnables),
            .burstSizeOut(s_hdmiBurstSize),
            .addressDataOut(s_hdmiAddressData),
            .pixelClkX2(pixelClockInX2),

`ifdef GECKO5Education
            .hdmiRed(hdmiRed),
            .hdmiGreen(hdmiGreen),
            .hdmiBlue(hdmiBlue),
`else
            .red(hdmiRed),
            .green(hdmiGreen),
            .blue(hdmiBlue),
`endif
            .pixelClock(pixelClock),
            .horizontalSync(horizontalSync),
            .verticalSync(verticalSync),
            .activePixel(activePixel)
            );

  /*
   *
   * Here the spi-flash controller is defined
   *
   */
  wire [31:0] s_flashAddressData;
  wire s_flashEndTransaction, s_flashDataValid, s_flashBusError;
  spiBus #( .baseAddress(32'h04000000),
            .customIntructionNr(8'd2)) flash
          ( .clock(systemClock),
            .reset(systemReset),
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
            .ciN(s_cpu1CiN),
            .ciDataA(s_cpu1CiDataA),
            .ciDataB(s_cpu1CiDataB),
            .ciStart(s_cpu1CiStart),
            .ciCke(s_cpu1CiCke),
            .ciDone(s_flashDone),
            .ciResult(s_flashResult),
            .beginTransactionIn(s_beginTransaction),
            .endTransactionIn(s_endTransaction),
            .readNotWriteIn(s_readNotWrite),
            .busErrorIn(s_busError),
            .addressDataIn(s_addressData),
            .burstSizeIn(s_burstSize),
            .byteEnablesIn(s_byteEnables),
            .addressDataOut(s_flashAddressData),
            .endTransactionOut(s_flashEndTransaction),
            .dataValidOut(s_flashDataValid),
            .busErrorOut(s_flashBusError) );

  /*
   *
   * Here we define the bios
   *
   */
  wire [31:0] s_biosAddressData;
  wire        s_biosBusError, s_biosDataValid, s_biosEndTransaction;
  bios start (.clock(systemClock),
              .reset(systemReset),
              .addressDataIn(s_addressData),
              .beginTransactionIn(s_beginTransaction),
              .endTransactionIn(s_endTransaction),
              .readNotWriteIn(s_readNotWrite),
              .busErrorIn(s_busError),
              .dataValidIn(s_dataValid),
              .byteEnablesIn(s_byteEnables),
              .burstSizeIn(s_burstSize),
              .addressDataOut(s_biosAddressData),
              .busErrorOut(s_biosBusError),
              .dataValidOut(s_biosDataValid),
              .endTransactionOut(s_biosEndTransaction));

  /*
   *
   * Here we define the bus arbiter
   *
   */
 wire [31:0] s_busRequests, s_busGrants;
 wire        s_arbBusError, s_arbEndTransaction;
 
 assign s_busRequests[31] = s_cpu1DcacheRequestBus;
 assign s_busRequests[30] = s_cpu1IcacheRequestBus;
 assign s_busRequests[29] = s_hdmiRequestBus;
 assign s_busRequests[28] =  s_camReqBus;
 assign s_busRequests[27] = s_ramDmaRequest;
 assign s_busRequests[26:0] = 27'd0;
 
 assign s_cpu1DcacheBusAccessGranted = s_busGrants[31];
 assign s_cpu1IcacheBusAccessGranted = s_busGrants[30];
 assign s_hdmiBusgranted             = s_busGrants[29];
 assign s_camAckBus                  = s_busGrants[28];
 assign s_ramDmaGranted              = s_busGrants[27];

 busArbiter arbiter ( .clock(systemClock),
                      .reset(systemReset),
                      .busRequests(s_busRequests),
                      .busGrants(s_busGrants),
                      .busErrorOut(s_arbBusError),
                      .endTransactionOut(s_arbEndTransaction),
                      .busIdle(s_busIdle),
                      .snoopableBurst(s_snoopableBurst),
                      .beginTransactionIn(s_beginTransaction),
                      .endTransactionIn(s_endTransaction),
                      .dataValidIn(s_dataValid),
                      .addressDataIn(s_addressData[31:30]),
                      .burstSizeIn(s_burstSize));
 
  /*
   *
   * Here we define the bus architecture
   *
   */
 assign s_busError         = s_arbBusError | s_biosBusError | s_uartBusError | s_sdramBusError | s_flashBusError;
 assign s_beginTransaction = s_cpu1BeginTransaction | s_hdmiBeginTransaction | s_camBeginTransaction| s_ramDmaBeginTransaction;
 assign s_endTransaction   = s_cpu1EndTransaction | s_arbEndTransaction | s_biosEndTransaction | s_uartEndTransaction |
                             s_sdramEndTransaction | s_hdmiEndTransaction | s_flashEndTransaction | s_camEndTransaction | s_ramDmaEndTransaction;
 assign s_addressData      = s_cpu1AddressData | s_biosAddressData | s_uartAddressData | s_sdramAddressData | s_hdmiAddressData |
                             s_flashAddressData | s_camAddressData | s_ramDmaAddressData;
 assign s_byteEnables      = s_cpu1byteEnables | s_hdmiByteEnables | s_camByteEnables | s_ramDmaByteEnables;
 assign s_readNotWrite     = s_cpu1ReadNotWrite | s_hdmiReadNotWrite | s_ramDmaReadNotWrite;
 assign s_dataValid        = s_cpu1DataValid | s_biosDataValid | s_uartDataValid | s_sdramDataValid | s_hdmiDataValid | 
                             s_flashDataValid | s_camDataValid | s_ramDmaDataValid;
 assign s_busy             = s_sdramBusy;
 assign s_burstSize        = s_cpu1BurstSize | s_hdmiBurstSize | s_camBurstSize | s_ramDmaBurstSize;
 
endmodule

`default_nettype wire