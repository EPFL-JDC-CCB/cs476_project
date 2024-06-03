# CS476 Final Project

Note: For now I have copied our source from PW6 part 3 so that we can test the grayscale app


## Random notes

automation things
- quick way to turn on/off tracing in the verilator makefile

UART/printing strategy
- keep the uart as-is, it's already reasonably fast in verilator with tracing completely off 
  (doesn't need to be the whole dpi thing though because the read doesn't work, and we're not going to have it work)
- We will use the same bios as the stock, but there will be an #ifdef SIMULATION in the code that makes it so that instead of getRS232Char(), it goes to a method which loads from a constant array that has each of the commands. something like {'*', 'p', '\n', '$', '\n', 0}. when it is over it just busy loops.
- It's too slow to load the program from uart, and we don't have a way to write to the uart peripheral readily, so we will use the flash instead

SPI flash strategy 
- Extend SimpleMemorySlave to have variable latency, size, width, etc. etc. Let's put an ifdef then that replaces the spi peripheral in the or1420singlecore with also a simpleMemorySlave. Or extract it out like the SDRAM version. This simplememoryslave will be readmemh'd to the hex the user wants to program. (Controllable by parameter)

Video strategy 
- For HDMI and camera we should extract all the way out to the top level and write a true simulation peripheral (if time permits).