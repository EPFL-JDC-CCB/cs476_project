# Requirements

* Verilator, minimum version unknown but we tested with 5.025
* sdl2 including headers (`sudo apt install libsdl2-dev` on Ubuntu)
* make, python, C++ compiler, etc. (`sudo apt install build-essential`)

# Build

By default, `make` builds the Verilated model, and runs the BIOS program for unlimited time, with nothing in flash. You can adjust the following options by passing parameters to make (i.e. `make PARAMETER=VALUE`)

| Parameter | Description |
| --------  | ------- |
| LIMIT    | value is number of cycles to run for |
| MEMFILE  | path to file to initialize flash memory with. Should NOT be the cmem, it should end in mem extension. |
| TRACE     | set to anything to enable VCD tracing    |
| CPU_DEBUG | macro to enable printing what PC fetch unit is at |

For example, `make LIMIT=5000 MEMFILE=test.mem TRACE=1` runs simulation for 5000 cycles with test.mem in flash while tracing to VCD.