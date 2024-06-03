#include <stdio.h>
#include <vga.h>

int main () {
  vga_clear();
  *((volatile int*)0x60000000) = *((volatile int*)0x00001584);
  printf("Hello World!\n" );
}
