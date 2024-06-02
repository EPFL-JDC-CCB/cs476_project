.PHONY: clean biosOR1420 biosOld uartTest

biosOR1420:
	make -f generic.mk CFLAGS="-D OR1420 -msoft-div -Os -nostartfiles -Wl,-Ttext=0xF0000000" BINARY_NAME=$@

biosOld: 
	make -f generic.mk CFLAGS="-Os -nostartfiles -Wl,-Ttext=0xF0000000" BINARY_NAME=$@

uartTest:
	make -f generic.mk SRCS="c/crt0.S c/uart.c" CFLAGS="-D OR1420 -msoft-div -Os -nostartfiles -fno-builtin -Wl,-Ttext=0xF0000000" BINARY_NAME=$@

clean:
	rm -rf build/
#	find . -name "*.so" -type f -delete
#	find . -name "*.sched" -type f -delete
#	find . -name "*.bo" -type f -delete
#	find . -name "*.ba" -type f -delete

all: clean $(TARGETS) $(TARGETSV)