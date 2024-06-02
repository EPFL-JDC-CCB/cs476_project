.PHONY: bin/biosgen8k bin/convert_or32

all: bin/biosgen8k bin/convert_or32

bin/biosgen8k:
	mkdir -p bin/
	gcc -O2 -o bin/biosgen8k biosgen8k.c read_elf.c

bin/convert_or32:
	mkdir -p bin/
	gcc -O2 -o bin/convert_or32 convert_or32.c read_elf.c