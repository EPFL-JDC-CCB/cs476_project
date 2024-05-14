#ifndef _PW_DMA_H_
#define _PW_DMA_H_

#define DMA_CI_ID 43

#include <stdint.h>

inline void dma_wr_inst(uint32_t opA, uint32_t opB)
{
    asm volatile("l.nios_rrr r0, %[in1], %[in2], 20" ::[in1] "r"(opA), [in2] "r"(opB));
}

inline uint32_t dma_rd_inst(uint32_t opA)
{
    uint32_t res;
    asm volatile("l.nios_rrr %[out1], %[in1], r0, 20" : [out1] "=r"(res) : [in1] "r"(opA));
    return res;
}

inline uint32_t dma_read(uint32_t addr)
{
    return dma_rd_inst(addr);
}

inline void dma_write(uint32_t addr, uint32_t data)
{
    dma_wr_inst((1 << 9) | addr, data);
}

inline uint32_t dma_bus_start_read()
{
    return dma_read(0b0010 << 9);
}

inline void dma_bus_start_write(uint32_t data)
{
    dma_write(0b0011 << 9, data);
}

inline uint32_t dma_mem_start_read()
{
    return dma_read(0b0100 << 9);
}

inline void dma_mem_start_write(uint32_t data)
{
    dma_write(0b0101 << 9, data);
}

inline uint32_t dma_block_size_read()
{
    return dma_read(0b0110 << 9);
}

inline void dma_block_size_write(uint32_t data)
{
    dma_write(0b0111 << 9, data);
}

inline uint32_t dma_burst_size_read()
{
    return dma_read(0b1000 << 9);
}

inline void dma_burst_size_write(uint32_t data)
{
    dma_write(0b1001 << 9, data);
}

inline uint32_t dma_status_read()
{
    return dma_read(0b1010 << 9);
}

inline void dma_status_write(uint32_t data)
{
    dma_write(0b1011 << 9, data);
}


#endif // _PW_DMA_H_