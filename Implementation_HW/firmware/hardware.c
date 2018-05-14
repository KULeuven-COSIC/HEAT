
#include "hardware.h"
#include "xpseudo_asm.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "xaxidma.h"
#include "platform.h"

#include "xparameters.h"
#include "platform.h"

#include "platform_config.h"


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

/*
XAxiDma myDMA;

static int init_dma(XAxiDma* p_dma_inst, int dma_device_id)
{

	// Local variables
	int             status = 0;
	XAxiDma_Config* cfg_ptr;

	// Look up hardware configuration for device
	cfg_ptr = XAxiDma_LookupConfig(dma_device_id);
	if (!cfg_ptr)
	{
		xil_printf("ERROR! No hardware configuration found for AXI DMA with device id %d.\r\n", dma_device_id);
		return 0;
	}

	// Initialize driver
	status = XAxiDma_CfgInitialize(p_dma_inst, cfg_ptr);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Initialization of AXI DMA failed with %d\r\n", status);
		return 0;
	}

	// Test for Scatter Gather
	if (XAxiDma_HasSg(p_dma_inst))
	{
		xil_printf("ERROR! Device configured as SG mode.\r\n");
		return 0;
	}

	// Disable interrupts for both channels
	XAxiDma_IntrDisable(p_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(p_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	// Reset DMA
	XAxiDma_Reset(p_dma_inst);
	while (!XAxiDma_ResetIsDone(p_dma_inst)) {}

	xil_printf("DMA Device configured.\r\n");

	return 1;
}
*/

void init_hardware()
{
	dma_config 		   = (uint32_t *) 0x00B0000000;
	core_config		   = (uint32_t *) 0x00A0000000;

	core_config[0] = 0;
	core_config[1] = 0;
	core_config[3] = 0;

	Xil_DCacheFlush();
	Xil_DCacheDisable();

	// Below these lines,
	// I perform a dummy DMA transfer that will set completion flags
	// when completed. These initial transfers are needed for the flags,
	// because, being set of which the flags will be polled in the future transfers.
	// If they are not set, for the initial transfer, it will become an infinite waiting.

	uint8_t  data_addr[1024] = {0,};
	uint32_t data_len = 1024;

	//                write                      memory
	core_config[0] = (1<<24) | (0<<20) | (4<<16) | (0 & 0x000007FF);

	// Perform the DMA transfer
    dma_config[MM2S_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[MM2S_SA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[MM2S_SA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[MM2S_LENGTH_OFFSET]  = data_len;     									//Specify number of bytes

	core_config[0] = 0;

	//                write                      memory
	core_config[0] = (2<<24) | (0<<20) | (4<<16) | (0 & 0x000007FF);

	// Perform the DMA transfer
	dma_config[S2MM_DMACR_OFFSET]   = 1;                								//Stop
	dma_config[S2MM_DA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
	dma_config[S2MM_DA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
	dma_config[S2MM_LENGTH_OFFSET]  = data_len;       				   				    //Specify number of bytes

	core_config[0] = 0;
}

void send_inst      (INSTRUCTION instruction)
{
	uINSTRUCTION uinst;

	uinst.instruction = instruction;

	core_config[1] = (uint32_t)(uinst.whole32);

	// dmb();
	dsb();
	// isb();
}

void wait_inst_done(void)
{
	while(core_config[2] != 1);
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

	// dmb();
	dsb();
	// isb();

	// platform_enable_interrupts();
}

void send_eth_data  (uint32_t bram_address, 
					 uint8_t  processor, 
					 uint8_t* data_addr, 
					 uint32_t data_len)
{
	// Flush the data cache to ensure that fresh data is stored inside DRAM
   	// Xil_DCacheFlushRange((INTPTR)data_addr,(int)data_len);
	
	//                write                      memory
	core_config[0] = (1<<24) | (processor<<20) | (4<<16) | (bram_address & 0x000007FF);

	while((dma_config[MM2S_DMASR_OFFSET] & (1<<1)) == 0);

	// Perform the DMA transfer
    dma_config[MM2S_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[MM2S_SA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[MM2S_SA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[MM2S_LENGTH_OFFSET]  = data_len;     									//Specify number of bytes

	core_config[0] = 0;

	// uint64_t acknowledgement;

	// acknowledgement  = core_config[5] << 32;
	// acknowledgement |= core_config[6];

	// xil_printf("Ack: 0x%08X - %lu \n\r", acknowledgement, acknowledgement);	 
}

void recv_eth_data	(uint32_t bram_address, 
					 uint8_t  processor, 
					 uint8_t* data_addr,
					 uint32_t data_len)
{
	// Flush the data cache to ensure that fresh data is stored inside DRAM
	// Xil_DCacheFlushRange((INTPTR)data_addr,(int)data_len);	

	//                write                      memory
	core_config[0] = (2<<24) | (processor<<20) | (4<<16) | (bram_address & 0x000007FF);

	while((dma_config[S2MM_DMASR_OFFSET] & (1<<1)) == 0);

	// Perform the DMA transfer
    dma_config[S2MM_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[S2MM_DA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[S2MM_DA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[S2MM_LENGTH_OFFSET]  = data_len;       				   				    //Specify number of bytes

	core_config[0] = 0;
}

void send_const_data(uint32_t bram_address, 
					 uint8_t  processor, 
					 uint8_t* data_addr, 
					 uint32_t data_len)
{
	// Flush the data cache to ensure that fresh data is stored inside DRAM
	// Xil_DCacheFlushRange((INTPTR)data_addr,(int)data_len);

    //                write                      memory
	core_config[0] = (1<<24) | (processor<<20) | (4<<16) | (bram_address & 0x000007FF);

	while((dma_config[S2MM_DMASR_OFFSET] & (1<<1)) == 0);

	// Perform the DMA transfer
    dma_config[MM2S_DMACR_OFFSET]   = 1;                								//Stop
    dma_config[MM2S_SA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);   //Specify read address
    dma_config[MM2S_SA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);  		//Specify read address
    dma_config[MM2S_LENGTH_OFFSET]  = data_len;     									//Specify number of bytes

	core_config[0] = 0;
}
