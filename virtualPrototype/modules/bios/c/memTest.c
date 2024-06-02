void icache_handler() {}

void dcache_handler() {}

void irq_handler() {}

void invalid_handler() {}

void system_handler() {}

int bios() {
    volatile int* base = (volatile int*)4;
    volatile int* print_base = (volatile int*)0x50000000;
    *base = 0xDEADBEEF;
    *print_base = *base;
    if (*base != 0xDEADBEEF) {
        *print_base = 0;
    } else {
        *print_base = 1;
    }
    return 0;
}
