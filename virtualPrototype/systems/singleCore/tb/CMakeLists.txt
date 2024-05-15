######################################################################
#
# DESCRIPTION: Verilator CMake Example: Small CMakeLists.txt with SystemC tracing
#
# This is an example cmake script to build a verilog to SystemC project
# using CMake and Verilator.
#
# This file ONLY is placed under the Creative Commons Public Domain, for
# any use, without warranty, 2020 by Wilson Snyder.
# SPDX-License-Identifier: CC0-1.0
#
######################################################################

# This example builds the tracing_sc example using CMake
# To use it, run the following:

# cd /path/to/verilator/examples/cmake_tracing_sc
# rm -rf build && mkdir build && cd build
# cmake ..
# cmake --build .

cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0074 NEW)

project(virtualPrototype_tb CXX)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

# SystemC dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Find SystemC using SystemC's CMake integration
find_package(SystemCLanguage QUIET)
if (NOT SystemCLanguage_FOUND)
  message(FATAL_ERROR "SystemC was not found. Did you install without CMake support? Either rebuild it using CMake, or unset SYSTEMC_HOME and let the script pull the proper version.")
endif() 

# Create a new executable target that will contain all your sources
add_executable(tb sc_main.cpp)

set_property(
  TARGET tb
  PROPERTY CXX_STANDARD ${SystemC_CXX_STANDARD}
  )

# Add the Verilated circuit to the target
verilate(tb SYSTEMC TRACE
  PREFIX "tb_harness"
  VERILATOR_ARGS -f input.vc -x-assign fast -Wno-lint -Wno-style -Wno-MULTIDRIVEN -Wno-COMBDLY -Wno-TIMESCALEMOD -Wno-UNOPTFLAT uartdpi.c
  SOURCES tb_harness.v)

verilator_link_systemc(tb)
