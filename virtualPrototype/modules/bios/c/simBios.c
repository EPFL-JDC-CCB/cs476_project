unsigned char biosNextChar() {
    char startupCommands[] = { '*', 'r', '\n', 0 };
    // offset number stored in sdram cause static doesnt seem to work
    volatile int* cmdOfsP = (volatile int*)4;
    // assume it starts at 0
    char nextChar = startupCommands[(*cmdOfsP)++];
    if (nextChar) {
        return (unsigned char)nextChar;
    } else {
        // out of commands to run
        while (1) asm volatile("");
    }    
}

#include "biosOR1420_default.h"