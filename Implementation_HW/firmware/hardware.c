
#include "hardware.h"

#include "xil_printf.h"
#include "xil_cache.h"

//Divide by 4 to get the 32-bit offsets
#define MM2S_DMACR_OFFSET   (0x00/4)
#define MM2S_DMASR_OFFSET   (0x04/4)
#define MM2S_SA_OFFSET      (0x18/4)
#define MM2S_SA_MSB_OFFSET  (0x1C/4)
#define MM2S_LENGTH_OFFSET  (0x28/4)

#define S2MM_DMACR_OFFSET   (0x30/4)
#define S2MM_DMASR_OFFSET   (0x34/4)
#define S2MM_DA_OFFSET      (0x48/4)
#define S2MM_DA_MSB_OFFSET  (0x4C/4)
#define S2MM_LENGTH_OFFSET  (0x58/4)


volatile uint32_t * dma_config;
volatile uint32_t * core_config;

// Internal functions
void print_buffer(uint8_t * buffer, int bufferlen);
void clear_buffer(uint8_t * buffer, int bufferlen);

void init_hardware()
{
	dma_config 		   = (uint32_t *) 0x00B0000000;
	core_config		   = (uint32_t *) 0x00A0000000;

	core_config[0] = 0;
	core_config[1] = 0;
	core_config[3] = 0;

//	Xil_DCacheFlush();
}

void send_inst      (INSTRUCTION instruction)
{
	uINSTRUCTION uinst;
	
	uinst.instruction = instruction;

	core_config[1] = (uint32_t)(uinst.whole32);
}

void send_inst_raw  (uint8_t instruction, 
                     uint8_t mod_sel, 
                     uint8_t rdM0,
                     uint8_t rdM1,
                     uint8_t wtM0,
                     uint8_t wtM1)
{
	uINSTRUCTION uinst;

    uinst.instruction = (INSTRUCTION){	.ins    = instruction,
										.addr1  = rdM0 + (rdM1<<4),
										.addr2  = wtM0 + (wtM1<<4),
										.proc   = 0,
										.mem    = 0,
										.mod    = mod_sel};
	
	core_config[1] = (uint32_t)(uinst.whole32);
}

void send_eth_data  (uint32_t bram_address, 
					 uint8_t  processor, 
					 uint8_t* data_addr, 
					 uint32_t data_len)
{
    // Flush the data cache to ensure that fresh data is stored inside DRAM
    Xil_DCacheFlushRange((INTPTR)data_addr,(int)data_len);

	xil_printf(".\n\r");

	//                write                      memory
	core_config[0] = (1<<24) | (processor<<20) | (4<<16) | (bram_address & 0x000007FF);

	// Perform the DMA transfer
    dma_config[MM2S_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[MM2S_SA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[MM2S_SA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[MM2S_LENGTH_OFFSET]  = data_len;     									//Specify number of bytes

	core_config[0] = 0;

	// print_buffer(data_addr, data_len);
}

void recv_eth_data	(uint32_t bram_address, 
					 uint8_t processor, 
					 uint8_t* data_addr,
					 uint32_t data_len)
{
	// Flush the data cache to ensure that fresh data is stored inside DRAM
	Xil_DCacheFlushRange((INTPTR)data_addr,(int)data_len);
	
	//                write                      memory
	core_config[0] = (2<<24) | (processor<<20) | (4<<16) | (bram_address & 0x000007FF);

	// Perform the DMA transfer
    dma_config[S2MM_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[S2MM_DA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[S2MM_DA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[S2MM_LENGTH_OFFSET]  = data_len;       				   				    //Specify number of bytes

	core_config[0] = 0;
}

void send_const_data(uint32_t bram_address, 
					 uint8_t processor, 
					 uint8_t* data_addr, 
					 uint32_t data_len)
{
	// Flush the data cache to ensure that fresh data is stored inside DRAM
	Xil_DCacheFlushRange((INTPTR)data_addr,(int)data_len);

	xil_printf(".\n\r");
	
    //                write                      memory
	core_config[0] = (1<<24) | (processor<<20) | (4<<16) | (bram_address & 0x000007FF);

	// Perform the DMA transfer
    dma_config[MM2S_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[MM2S_SA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[MM2S_SA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[MM2S_LENGTH_OFFSET]  = data_len;     									//Specify number of bytes

	core_config[0] = 0;

	// print_buffer(data_addr, data_len);
}

void recv_const_data(uint32_t bram_address, 
					 uint8_t processor, 
					 uint8_t* data_addr,
					 uint32_t data_len)
{
	//                write                      memory
	core_config[0] = (2<<24) | (processor<<20) | (4<<16) | (bram_address & 0x000007FF);

	// Perform the DMA transfer
    dma_config[S2MM_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[S2MM_DA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[S2MM_DA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[S2MM_LENGTH_OFFSET]  = data_len;       				   				    //Specify number of bytes

	core_config[0] = 0;
}

void print_buffer(uint8_t * buffer, int bufferlen)
{
	xil_printf("\r\n");
	for(int i=0; i< bufferlen; i++)
	{
		xil_printf("%02X ", buffer[i]);
	}
	xil_printf("\r\n");
}

void clear_buffer(uint8_t * buffer, int bufferlen)
{
    for (int i=0; i<bufferlen; i++)
        buffer[i]=0;
}

