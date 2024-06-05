# Requirements

* or1k-toolchain (download on moodle)
* make

# Build

Targets are listed one-by-one in the Makefile, as the name of the primary C file with the bios() function without the extension. For example, `make biosOR1420` builds `c/biosOR1420.c`. A number of default sources are specified in `generic.mk` to link with this main module, but it can be overriden and others specified (see `memTest`.)  The file is first compiled to an ELF in the `build/` directory then converted to a verilog module (using biosgen8k).