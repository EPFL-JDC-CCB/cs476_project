`default_nettype none 
module top			    ( input wire         clock12MHz,
                                             clock50MHz,
                                             nReset,
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
                          inout wire [15:0]  sdramData,

                          // The spi interface
                          output wire        spiScl,
                                             spiNCs,
                          inout wire         spiSiIo0,
                                             spiSoIo1,
                                             spiIo2,
                                             spiIo3,

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
                                             camnReset,
                          inout              SDA,
                          input wire         camPclk,
                                             camHsync,
                                             camVsync,
                                             biosBypass,
                          input wire [7:0]   camData
                           );


///////////////////////////////
// Clock & reset generation //
/////////////////////////////

  reg[4:0] s_resetCountReg;
  wire     s_pllLocked;

  wire 	   s_systemClock, s_systemClockX2;	
  wire     s_pixelClock, s_pixelClockX2;
  wire     s_systemReset = ~s_resetCountReg[4];  
  
  assign camnReset = s_resetCountReg[4];

  always @(posedge s_systemClock or negedge s_pllLocked)
    if (s_pllLocked == 1'b0) s_resetCountReg <= 5'd0;
    else s_resetCountReg <= (s_resetCountReg[4] == 1'b0) ? s_resetCountReg + 5'd1 : s_resetCountReg;

`ifdef GECKO5Education
  wire s_resetPll = ~nReset;
  wire s_feedbackClock;
  // CPU @ 74.25MHz
  EHXPLLL #(
        .PLLRST_ENA("ENABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(1),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(4),
        .CLKOP_CPHASE(1),
        .CLKOP_FPHASE(0),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(8),
        .CLKOS_CPHASE(1),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(8),
        .CLKOS2_CPHASE(1),
        .CLKOS2_FPHASE(0),
        .CLKOS3_ENABLE("ENABLED"),
        .CLKOS3_DIV(4),
        .CLKOS3_CPHASE(1),
        .CLKOS3_FPHASE(0),
        .FEEDBK_PATH("INT_OP"),
        .CLKFB_DIV(2)
    ) pll_1 (
        .RST(s_resetPll),
        .STDBY(1'b0),
        .CLKI(clock12MHz),
        .CLKOP(s_pixelClockX2),
        .CLKOS(s_pixelClock),
        .CLKOS2(s_systemClock),
        .CLKOS3(s_systemClockX2),
        .CLKFB(s_feedbackClock),
        .CLKINTFB(s_feedbackClock),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(s_pllLocked)
	);
`else
  wire[4:0] s_pllClocks;
  // CPU @ 74.25MHz
  assign s_pixelClock = s_pllClocks[0];
  assign s_pixelClockX2 = s_pllClocks[1]; //
  assign s_systemClock = s_pllClocks[2]; // 74.25MHz
  assign s_systemClockX2 = s_pllClocks[3]; // 148.5MHz

  
	altpll	altpll_component (
				.areset (~nReset),
				.inclk ({1'b0,clock12MHz}),
				.clk (s_pllClocks),
				.locked (s_pllLocked),
				.activeclock (),
				.clkbad (),
				.clkena ({6{1'b1}}),
				.clkloss (),
				.clkswitch (1'b0),
				.configupdate (1'b0),
				.enable0 (),
				.enable1 (),
				.extclk (),
				.extclkena ({4{1'b1}}),
				.fbin (1'b1),
				.fbmimicbidir (),
				.fbout (),
				.fref (),
				.icdrclk (),
				.pfdena (1'b1),
				.phasecounterselect ({4{1'b1}}),
				.phasedone (),
				.phasestep (1'b1),
				.phaseupdown (1'b1),
				.pllena (1'b1),
				.scanaclr (1'b0),
				.scanclk (1'b0),
				.scanclkena (1'b1),
				.scandata (1'b0),
				.scandataout (),
				.scandone (),
				.scanread (1'b0),
				.scanwrite (1'b0),
				.sclkout0 (),
				.sclkout1 (),
				.vcooverrange (),
				.vcounderrange ());
	defparam
		altpll_component.bandwidth_type = "AUTO",
		altpll_component.clk0_divide_by = 16,
		altpll_component.clk0_duty_cycle = 50,
		altpll_component.clk0_multiply_by = 99,
		altpll_component.clk0_phase_shift = "0",
		altpll_component.clk1_divide_by = 8,
		altpll_component.clk1_duty_cycle = 50,
		altpll_component.clk1_multiply_by = 99,
		altpll_component.clk1_phase_shift = "0",
		altpll_component.clk2_divide_by = 16,
		altpll_component.clk2_duty_cycle = 50,
		altpll_component.clk2_multiply_by = 99,
		altpll_component.clk2_phase_shift = "0",
		altpll_component.clk3_divide_by = 8,
		altpll_component.clk3_duty_cycle = 50,
		altpll_component.clk3_multiply_by = 99,
		altpll_component.clk3_phase_shift = "0",
		altpll_component.compensate_clock = "CLK0",
		altpll_component.inclk0_input_frequency = 83333,
		altpll_component.intended_device_family = "Cyclone IV E",
		altpll_component.lpm_hint = "CBX_MODULE_PREFIX=test",
		altpll_component.lpm_type = "altpll",
		altpll_component.operation_mode = "NORMAL",
		altpll_component.pll_type = "AUTO",
		altpll_component.port_activeclock = "PORT_UNUSED",
		altpll_component.port_areset = "PORT_USED",
		altpll_component.port_clkbad0 = "PORT_UNUSED",
		altpll_component.port_clkbad1 = "PORT_UNUSED",
		altpll_component.port_clkloss = "PORT_UNUSED",
		altpll_component.port_clkswitch = "PORT_UNUSED",
		altpll_component.port_configupdate = "PORT_UNUSED",
		altpll_component.port_fbin = "PORT_UNUSED",
		altpll_component.port_inclk0 = "PORT_USED",
		altpll_component.port_inclk1 = "PORT_UNUSED",
		altpll_component.port_locked = "PORT_USED",
		altpll_component.port_pfdena = "PORT_UNUSED",
		altpll_component.port_phasecounterselect = "PORT_UNUSED",
		altpll_component.port_phasedone = "PORT_UNUSED",
		altpll_component.port_phasestep = "PORT_UNUSED",
		altpll_component.port_phaseupdown = "PORT_UNUSED",
		altpll_component.port_pllena = "PORT_UNUSED",
		altpll_component.port_scanaclr = "PORT_UNUSED",
		altpll_component.port_scanclk = "PORT_UNUSED",
		altpll_component.port_scanclkena = "PORT_UNUSED",
		altpll_component.port_scandata = "PORT_UNUSED",
		altpll_component.port_scandataout = "PORT_UNUSED",
		altpll_component.port_scandone = "PORT_UNUSED",
		altpll_component.port_scanread = "PORT_UNUSED",
		altpll_component.port_scanwrite = "PORT_UNUSED",
		altpll_component.port_clk0 = "PORT_USED",
		altpll_component.port_clk1 = "PORT_USED",
		altpll_component.port_clk2 = "PORT_USED",
		altpll_component.port_clk3 = "PORT_USED",
		altpll_component.port_clk4 = "PORT_UNUSED",
		altpll_component.port_clk5 = "PORT_UNUSED",
		altpll_component.port_clkena0 = "PORT_UNUSED",
		altpll_component.port_clkena1 = "PORT_UNUSED",
		altpll_component.port_clkena2 = "PORT_UNUSED",
		altpll_component.port_clkena3 = "PORT_UNUSED",
		altpll_component.port_clkena4 = "PORT_UNUSED",
		altpll_component.port_clkena5 = "PORT_UNUSED",
		altpll_component.port_extclk0 = "PORT_UNUSED",
		altpll_component.port_extclk1 = "PORT_UNUSED",
		altpll_component.port_extclk2 = "PORT_UNUSED",
		altpll_component.port_extclk3 = "PORT_UNUSED",
		altpll_component.self_reset_on_loss_lock = "OFF",
		altpll_component.width_clock = 5;

`endif

/////////////////////////
// Instantiate system //
///////////////////////
wire sdaDriven;
wire sdaIn;

wire [15:0] sdramDataOut;
wire sdramDataDriven;
wire [15:0] sdramDataIn;

wire        spiSiIo0Out,
			spiSoIo1Out,
			spiIo2Out,
			spiIo3Out;
wire        spiSiIo0Driven,
			spiSoIo1Driven,
			spiIo2Driven,
			spiIo3Driven;
wire        spiSiIo0In,
			spiSoIo1In,
			spiIo2In,
			spiIo3In;
or1420SingleCoreSDRAM iSOC (
	.systemClock(s_systemClock),
	.systemClockX2(s_systemClockX2),
	.pixelClockIn(s_pixelClock),
	.pixelClockInX2(s_pixelClockX2),
	.clock12MHz(clock12MHz),
	.clock50MHz(clock50MHz),
	.systemReset(s_systemReset),
	.RxD(RxD),
	.TxD(TxD),
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
	.sdramDataIn(sdramDataIn),
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

/////////////////////////////
// Top-level I/O handling //
///////////////////////////
assign SDA = sdaDriven ? 1'b0 : 1'bZ;
assign sdaIn = SDA;

assign sdramData = sdramDataDriven ? sdramDataOut : 16'hZ;
assign sdramDataIn = sdramData;

assign spiSiIo0 = spiSiIo0Driven ? spiSiIo0Out : 1'bZ;
assign spiSoIo1 = spiSoIo1Driven ? spiSoIo1Out : 1'bZ;
assign spiIo2 = spiIo2Driven ? spiIo2 : 1'bZ;
assign spiIo3 = spiIo3Driven ? spiIo3 : 1'bZ;

assign spiSiIo0In = spiSiIo0;
assign spiSoIo1In = spiSoIo1;
assign spiIo2In = spiIo2;
assign spiIo3In = spiIo3;
endmodule