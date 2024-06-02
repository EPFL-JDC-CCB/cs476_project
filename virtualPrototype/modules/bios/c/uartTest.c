void icache_handler() {}

void dcache_handler() {}

void irq_handler() {}

void invalid_handler() {}

void system_handler() {}

int bios() {
    init_rs232();
    while(1) {
        sendRs232Char('a');
    }
    return 0;
}