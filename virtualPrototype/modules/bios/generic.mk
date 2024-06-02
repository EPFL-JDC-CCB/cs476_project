# directories/files 
BUILD = build/
BIOS_BIN = bios.elf
VERILOG_MODULE = biosRom
SRCS ?= c/crt0.S c/exceptionHandlers.c c/flash.c c/or32Print.c c/uart.c c/vgaPrint.c

# tools
BIOSGEN = util/bin/biosgen8k
CC = or1k-elf-gcc

default: verilog/$(VERILOG_MODULE).v

.PHONY: $(BUILD)/$(BIOS_BIN) verilog/$(VERILOG_MODULE).v

$(BUILD)/$(BIOS_BIN): $(SRCS) c/$(BINARY_NAME).c $(BUILD)
	echo "#define compiledate \"Build version: $(shell date)\\\\n\\\\n\"" > c/date.h
	$(CC) $(CFLAGS) $(SRCS) c/$(BINARY_NAME).c -o $(BUILD)/$(BIOS_BIN)

verilog/$(VERILOG_MODULE).v: $(BUILD)/$(BIOS_BIN) 
	$(BIOSGEN) -8k $(BUILD)/$(BIOS_BIN)
	@echo "// Original top bios file: c/$(BINARY_NAME).c\n" | cat - $(BUILD)/$(BIOS_BIN)_rom.v > verilog/$(VERILOG_MODULE).v


$(BUILD):
	mkdir -p $(BUILD)