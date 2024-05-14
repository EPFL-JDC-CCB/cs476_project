#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>
#include <pw_dma.h>

#define BLOCK_SIZE 256
#define BURST_SIZE 15

// #define USE_ACCELERATOR

inline void ctrl_counters(uint32_t ctrl)
{
    asm volatile("l.nios_rrr r0,r0, %[in2],12" ::[in2] "r"(ctrl));
}

void camera_to_ci(volatile uint16_t *rgb565, int ci_offset)
{
    dma_block_size_write(BLOCK_SIZE);
    dma_burst_size_write(BURST_SIZE);

    dma_bus_start_write(rgb565);

    dma_mem_start_write(ci_offset);

    dma_status_write(1);
}

void ci_to_vga(volatile uint8_t *grayscale, int ci_offset)
{
    dma_block_size_write(BLOCK_SIZE/2);
    dma_burst_size_write(BURST_SIZE);

    dma_bus_start_write(grayscale);

    dma_mem_start_write(ci_offset);

    dma_status_write(2);
}

int main()
{
    volatile uint16_t rgb565[640 * 480];
    volatile uint8_t grayscale[640 * 480];
    volatile uint32_t result, cycles, stall, idle;
    volatile unsigned int *vga = (unsigned int *)0X50000020;
    camParameters camParams;
    vga_clear();

    for(int i = 0; i < 640*480; i++)
        grayscale[i] = 0;

    printf("Initialising camera (this takes up to 3 seconds)!\n");
    camParams = initOv7670(VGA);
    printf("Done!\n");
    printf("NrOfPixels : %d\n", camParams.nrOfPixelsPerLine);
    result = (camParams.nrOfPixelsPerLine <= 320) ? camParams.nrOfPixelsPerLine | 0x80000000 : camParams.nrOfPixelsPerLine;
    vga[0] = swap_u32(result);
    printf("NrOfLines  : %d\n", camParams.nrOfLinesPerImage);
    result = (camParams.nrOfLinesPerImage <= 240) ? camParams.nrOfLinesPerImage | 0x80000000 : camParams.nrOfLinesPerImage;
    vga[1] = swap_u32(result);
    printf("PCLK (kHz) : %d\n", camParams.pixelClockInkHz);
    printf("FPS        : %d\n", camParams.framesPerSecond);
    vga[2] = swap_u32(2);
    vga[3] = swap_u32((uint32_t)&grayscale[0]);
    // Disable and reset counters
    ctrl_counters(0x0F0 | 0xF00);
    while (1)
    {
        takeSingleImageBlocking((uint32_t)&rgb565[0]);
        // Enable the counters
        ctrl_counters(0x00F);

        int buf_1 = 0;
        int buf_2 = buf_1 + 256;
        camera_to_ci(&rgb565[0], buf_1);
        while (dma_status_read() != 0);

        for (int iter = 1; iter < 600; iter++)
        {
            if (__builtin_expect(iter < 599, 1))
                camera_to_ci(&rgb565[iter * 512], buf_2);
            for (int pix = 0; pix < 128; pix++)
            {
                uint32_t gray_pix;
                uint32_t rgb_pix_1 = (dma_read(buf_1 + 2*pix));
                rgb_pix_1 = swap_u16(rgb_pix_1 & 0xFFFF) | (swap_u16(rgb_pix_1 >> 16) << 16);
                uint32_t rgb_pix_2 = (dma_read(buf_1 + 2*pix+1));
                rgb_pix_2 = swap_u16(rgb_pix_2 & 0xFFFF) | (swap_u16(rgb_pix_2 >> 16) << 16);
                asm volatile("l.nios_rrr %[out1],%[in1],%[in2],9" : [out1] "=r"(gray_pix) : [in1] "r"(rgb_pix_1), [in2] "r"(rgb_pix_2));
                dma_write(buf_1 + pix, swap_u32(gray_pix));
            }
            if (__builtin_expect(iter < 599, 1))
                while (dma_status_read() != 0);
            
            ci_to_vga(&grayscale[(iter - 1) * 512], buf_1);
            while (dma_status_read() != 0);
            int tmp = buf_1;
            buf_1 = buf_2;
            buf_2 = tmp;
        }
        ci_to_vga(&grayscale[(599) * 512], buf_1);
        while (dma_status_read() != 0);
        
        // TODO: need to add busy wait here for the screen to be stable
        // doesn't seem to have to do with the performance though
        
        // Disable the counters
        ctrl_counters(0x0F0);
        uint32_t exc_result, stall_result, busidle_result, counterid = 0;
        uint32_t control = 0xF00;
        asm volatile("l.nios_rrr %[out1], %[in1], r0, 12" : [out1] "=r"(exc_result) : [in1] "r"(counterid++));
        asm volatile("l.nios_rrr %[out1], %[in1], r0, 12" : [out1] "=r"(stall_result) : [in1] "r"(counterid++));
        asm volatile("l.nios_rrr %[out1], %[in1], %[in2], 12" : [out1] "=r"(busidle_result) : [in1] "r"(counterid++), [in2] "r"(control));
        printf("CPU: %d | STALL: %d | BUS-IDLE: %d\n", exc_result, stall_result, busidle_result);
        // break;
    }
}
