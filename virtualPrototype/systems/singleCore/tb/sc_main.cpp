// -*- SystemC -*-
// DESCRIPTION: Verilator Example: Top level main for invoking SystemC model
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// For std::unique_ptr
#include <memory>

// SystemC global header
#include <systemc>

// Include common routines
#include <verilated.h>
#if VM_TRACE
#include <verilated_vcd_sc.h>
#endif

#include <sys/stat.h>  // mkdir

// Include model header, generated from Verilating "top.v"
#include "tb_harness.h"

using namespace sc_core;

int sc_main(int argc, char* argv[]) {
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Prevent unused variable warnings
    if (false && argc && argv) {}

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    Verilated::debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    Verilated::randReset(2);

#if VM_TRACE
    // Before any evaluation, need to know to calculate those signals only used for tracing
    Verilated::traceEverOn(true);
#endif

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    Verilated::commandArgs(argc, argv);

    // General logfile
    ios::sync_with_stdio();

    // Define clocks
    sc_clock clk_7425{"clk", 1/(.07425), SC_NS, 0.5, 3, SC_NS, true};
    sc_clock clk_1485{"clk", 1/(.1485), SC_NS, 0.5, 3, SC_NS, true};
    sc_clock clk_50{"clk", 1/(.05), SC_NS, 0.5, 3, SC_NS, true};
    sc_clock clk_12{"clk", 1/(.012), SC_NS, 0.5, 3, SC_NS, true};

    // Construct the Verilated model, from inside Vtop.h
    // Using unique_ptr is similar to "Vtop* top = new Vtop" then deleting at end
    const std::unique_ptr<tb_harness> top{new tb_harness{"tb_harness"}};

    sc_signal<bool> rst;

    // Attach Vtop's signals to this upper model
    top->clk_7425(clk_7425);
    top->clk_1485(clk_1485);
    top->clk_50(clk_50);
    top->clk_12(clk_12);

    // You must do one evaluation before enabling waves, in order to allow
    // SystemC to interconnect everything for testing.
    sc_start(SC_ZERO_TIME);

#if VM_TRACE
    // If verilator was invoked with --trace argument,
    // and if at run time passed the +trace argument, turn on tracing
    VerilatedVcdSc* tfp = nullptr;
    const char* flag = Verilated::commandArgsPlusMatch("trace");
    if (flag && 0 == std::strcmp(flag, "+trace")) {
        std::cout << "Enabling waves into logs/vlt_dump.vcd...\n";
        tfp = new VerilatedVcdSc;
        top->trace(tfp, 99);  // Trace 99 levels of hierarchy
        Verilated::mkdir("logs");
        tfp->open("logs/vlt_dump.vcd");
    }
#endif

    // Simulate until $finish
    while (!Verilated::gotFinish()) {
#if VM_TRACE
        // Flush the wave files each cycle so we can immediately see the output
        // Don't do this in "real" programs, do it in an abort() handler instead
        if (tfp) tfp->flush();
#endif

        // Apply inputs
        if (sc_time_stamp() > sc_time(1, SC_NS) && sc_time_stamp() < sc_time(20, SC_NS)) {
            rst  = 1;  // Assert reset
        } else {
            rst = 0;  // Deassert reset
        }

        // Simulate 1ns
        sc_start(1, SC_NS);
    }

    // Final model cleanup
    top->final();

    // Close trace if opened
#if VM_TRACE
    if (tfp) {
        tfp->close();
        tfp = nullptr;
    }
#endif


    // Return good completion status
    return 0;
}
