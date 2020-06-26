
#include "hardware.h"

#include "platform.h"
#include "platform_config.h"

#include "app.h"
#include "configuration.h"

//#include "xparameters.h"
#include "sleep.h"
#include "xpseudo_asm.h"
#include "xil_printf.h"
#include "xil_cache.h"


#include "mutex/xmutex.h"

////////////////////////////////////

volatile uint32_t * core_config;

////////////////////////////////////

volatile uint32_t * dma_config;

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

////////////////////////////////////

volatile uint32_t * mux_in_config;
volatile uint32_t * mux_out_config;

#define MUX_CTRL  			(0x00/4)
#define MUX_MI0_MUX  		(0x40/4)
#define MUX_MI1_MUX  		(0x44/4)

////////////////////////////////////

XMutex Mutex;

#define SEND_MUTEX 0
#define RECV_MUTEX 1

////////////////////////////////////

void select_DMA_Mux()
{
#if APP == 0
	mux_in_config[MUX_MI0_MUX] = 0x00;
	mux_in_config[MUX_CTRL]    = 0x02;

	mux_out_config[MUX_MI0_MUX] = 0x00;
	mux_out_config[MUX_MI1_MUX] = 0x80000000;
	mux_out_config[MUX_CTRL]    = 0x02;
#else
	mux_in_config[MUX_MI0_MUX] = 0x01;
	mux_in_config[MUX_CTRL]    = 0x02;

	mux_out_config[MUX_MI0_MUX] = 0x80000000;
	mux_out_config[MUX_MI1_MUX] = 0x00;
	mux_out_config[MUX_CTRL]    = 0x02;
#endif
}

void init_hardware()
{
#if APP == 0
	Xil_DCacheFlush();
	Xil_DCacheDisable();

	dma_config 		   = (uint32_t *) 0x00B0000000;
	core_config		   = (uint32_t *) 0x00A0000000;
	mux_in_config	   = (uint32_t *) 0x00A0002000;
	mux_out_config     = (uint32_t *) 0x00A0003000;

	core_config[0] = 0;
	core_config[2] = 0;

	dma_config[S2MM_DMACR_OFFSET]   = 1;
	dma_config[MM2S_DMACR_OFFSET]   = 1;

	select_DMA_Mux();

	XMutex_Config Config = {
		0, 				//		u16 DeviceId;			Unique ID of device
		0x00A0004000,	//		UINTPTR BaseAddress;	Register base address
		2,				//		u32 NumMutex;	< Number of Mutexes in this device
		0				//		u8 UserReg;	< User Register, access not controlled by Mutex
	};

	XStatus Status;
	Status = XMutex_CfgInitialize(
			&Mutex,
			&Config,
			Config.BaseAddress);
	if (Status != XST_SUCCESS) {
		printf("APP %d Failed at mutex initialisation\r\n", APP);
	}
	printf("APP %d, initialised mutex\r\n", APP);

#else
	Xil_DCacheFlush();
	Xil_DCacheDisable();

	dma_config 		   = (uint32_t *) 0x00B0000000;
	core_config		   = (uint32_t *) 0x00A0001000;
	mux_in_config	   = (uint32_t *) 0x00A0002000;
	mux_out_config     = (uint32_t *) 0x00A0003000;

	core_config[0] = 0;
	core_config[2] = 0;

	XMutex_Config Config = {
		1, 				//		u16 DeviceId;			Unique ID of device
		0x00A0005000,	//		UINTPTR BaseAddress;	Register base address
		2,				//		u32 NumMutex;	< Number of Mutexes in this device
		0				//		u8 UserReg;	< User Register, access not controlled by Mutex
	};

	select_DMA_Mux();

	XStatus Status;
	Status = XMutex_CfgInitialize(
			&Mutex,
			&Config,
			Config.BaseAddress);
	if (Status != XST_SUCCESS) {
		printf("APP %d Failed at mutex initialisation\r\n", APP);
	}
	printf("APP %d, initialised mutex\r\n", APP);
#endif
}

void send_inst      (INSTRUCTION instruction)
{
	uINSTRUCTION uinst;

	uinst.instruction = instruction;

	core_config[2] = (uint32_t)(uinst.whole32);

	// dmb();
	dsb();
	// isb();
}

void wait_inst_done(void)
{
	while(core_config[3] != 1);
}

static INLINE u32 read_reg(UINTPTR Addr)
{
	return *(volatile u32 *) Addr;
}

static INLINE void set_reg(UINTPTR Addr, u32 Value)
{
	volatile u32 *LocalAddr = (volatile u32 *)Addr;
	*LocalAddr = Value;
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
    
	core_config[2] = (uint32_t)(uinst.whole32);
}

void send_eth_data  (uint32_t bram_address,
					uint8_t  processor,
					uint8_t* data_addr,
					uint32_t data_len,
					uint8_t  to_all)
{
	while ((XMutex_Trylock(&Mutex, SEND_MUTEX)) != XST_SUCCESS);

	select_DMA_Mux();

	// Perform the DMA transfer

	// Set read address
	set_reg( (UINTPTR)(dma_config + MM2S_SA_OFFSET    ), (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF));
	set_reg( (UINTPTR)(dma_config + MM2S_SA_MSB_OFFSET), (uint32_t) ( (uint64_t)data_addr >> 32       ));

	//                                     write                       all
   	set_reg( (UINTPTR)(core_config + 0) , (1<<24) | (processor<<20) | (to_all<<16) | (bram_address & 0x000007FF));

	// Set length (in number of bytes) and start the transfer
	set_reg( (UINTPTR)(dma_config + MM2S_LENGTH_OFFSET), data_len);

	while( (read_reg((UINTPTR)(core_config + 1)) & 0x00000001) == 0);

	set_reg( (UINTPTR)(core_config + 0) , 0);

	XMutex_Unlock(&Mutex, SEND_MUTEX);
}

void send_eth_data_all  (uint8_t* data_addr)
{
	while ((XMutex_Trylock(&Mutex, SEND_MUTEX)) != XST_SUCCESS);

	// printf("APP %d has the DMA\r\n", APP);

	select_DMA_Mux();

	// Perform the DMA transfer

	// Set read address
	set_reg( (UINTPTR)(dma_config + MM2S_SA_OFFSET    ), (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF));
	set_reg( (UINTPTR)(dma_config + MM2S_SA_MSB_OFFSET), (uint32_t) ( (uint64_t)data_addr >> 32       ));

    //                                     write     proc     all
    set_reg( (UINTPTR)(core_config + 0) , (3<<24) | (0<<20) | (0<<16));

	// Set length (in number of bytes) and start the transfer
    set_reg( (UINTPTR)(dma_config + MM2S_LENGTH_OFFSET), 98306);

    while( (read_reg((UINTPTR)(core_config + 1)) & 0x00000001) == 0);

    isb();

	set_reg( (UINTPTR)(core_config + 0) , 0);

	XMutex_Unlock(&Mutex, SEND_MUTEX);

	// printf("APP %d released DMA\r\n", APP);
}

void recv_eth_data	(uint32_t bram_address,
					 uint8_t  processor, 
					 uint8_t* data_addr,
					 uint32_t data_len)
{
	while ((XMutex_Trylock(&Mutex, RECV_MUTEX)) != XST_SUCCESS);

	select_DMA_Mux();

	// Perform the DMA transfer

	// Set read address
	set_reg( (UINTPTR)(dma_config + S2MM_DA_OFFSET    ), (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF));
	set_reg( (UINTPTR)(dma_config + S2MM_DA_MSB_OFFSET), (uint32_t) ( (uint64_t)data_addr >> 32       ));

    //                                     read                        all
   	set_reg( (UINTPTR)(core_config + 0) , (2<<24) | (processor<<20) | (0<<16) | (bram_address & 0x000007FF));

	// Set length (in number of bytes) and start the transfer
   	set_reg( (UINTPTR)(dma_config + S2MM_LENGTH_OFFSET), data_len);

	while( (read_reg((UINTPTR)(core_config + 1)) & 0x00010000) == 0);

	set_reg( (UINTPTR)(core_config + 0) , 0);

	XMutex_Unlock(&Mutex, RECV_MUTEX);
}

void recv_eth_data_all	(uint8_t* data_addr)
{
	while ((XMutex_Trylock(&Mutex, RECV_MUTEX)) != XST_SUCCESS);

	select_DMA_Mux();

	// Perform the DMA transfer

	// Set read address
    dma_config[S2MM_DA_OFFSET]      = (uint32_t) ( (uint64_t)data_addr & 0xFFFFFFFF);
    dma_config[S2MM_DA_MSB_OFFSET]  = (uint32_t) ( (uint64_t)data_addr >> 32);

    //                read      proc      all
	core_config[0] = (4<<24) | (0<<20) | (0<<16);

	// Set length (in number of bytes) and start the transfer
	dma_config[S2MM_LENGTH_OFFSET]  = 98306;

	while( (read_reg((UINTPTR)(core_config + 1)) & 0x00010000) == 0);

    isb();

	set_reg( (UINTPTR)(core_config + 0) , 0);

	XMutex_Unlock(&Mutex, RECV_MUTEX);

	// printf("APP %d released DMA\r\n", APP);
}
