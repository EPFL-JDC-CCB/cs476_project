#include <stdio.h>
#include <stddef.h>
#include <cache.h>
#include <perf.h>
#include <vga.h>
#include <swap.h>
#include <defs.h>
#include "fractal_fxpt.h"

rgb565 frameBuffer[SCREEN_HEIGHT*SCREEN_WIDTH];

int main()
{
    volatile unsigned int *vga = (unsigned int *)0X50000020;
    volatile unsigned int *dma = (unsigned int *)0X50000040;

    printf("Starting drawing a fractal but before vga\n");
    vga_clear();
    printf("Starting drawing a fractal\n");
    fxpt_4_28 delta = FRAC_WIDTH / SCREEN_WIDTH;
    printf("Starting drawing a fractal\n");

    /* Enable the vga-controller's graphic mode */
    vga[0] = swap_u32(SCREEN_WIDTH);
    vga[1] = swap_u32(SCREEN_HEIGHT);
    vga[3] = swap_u32((unsigned int)&frameBuffer[0]);

    /* Clear screen */
//     for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++)
//         frameBuffer[i] = 0;

    printf("I AM ALIVE!!!\n");

    draw_fractal(frameBuffer, SCREEN_WIDTH, SCREEN_HEIGHT, &calc_mandelbrot_point_soft, &iter_to_colour, CX_0, CY_0, delta, N_MAX);
   
    printf("Done\n");
}
