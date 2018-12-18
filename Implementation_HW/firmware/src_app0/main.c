#include <stdio.h>
#include <inttypes.h>
#include "platform.h"
#include "xpseudo_asm.h"
#include "xil_printf.h"
#include "sleep.h"

#include "app.h"
#include "configuration.h"
#include "code.h"
#include "data.h"
#include "hardware.h"
#include "homenc.h"
#include "performance.h"

extern volatile uint32_t * core_config;

#define READ(STR, VAL)       \
    printf("%s: ", STR);     \
    scanf ("%d", &VAL);      \
    if(VAL == -1)			 \
        break; 				 \
    printf("%d\n\r",  VAL);

// Shared Memory

volatile uint32_t * SHAREDMEM;

POLYNOMIAL    *	poly;
IN_CIPHERTEXT * in_ct ;
OUT_CIPHERTEXT* out_ct;
RLK_CONSTANTS * rlkconstants;

void init_SharedMemory(void)
{
	SHAREDMEM = (uint32_t *) 0xFFFC0000;

	uint64_t base;
	base   = ((uint64_t)SHAREDMEM[4]) + ((uint64_t)SHAREDMEM[5] << 32);
	poly   = (POLYNOMIAL*) base;

#if APP == 0
	base   = ((uint64_t)SHAREDMEM[6]) + ((uint64_t)SHAREDMEM[7] << 32);
	in_ct  = (IN_CIPHERTEXT*) base;

	base   = ((uint64_t)SHAREDMEM[8]) + ((uint64_t)SHAREDMEM[9] << 32);
	out_ct = (OUT_CIPHERTEXT*) base;
#else
	base   = ((uint64_t)SHAREDMEM[10]) + ((uint64_t)SHAREDMEM[11] << 32);
	in_ct  = (IN_CIPHERTEXT*) base;

	base   = ((uint64_t)SHAREDMEM[12]) + ((uint64_t)SHAREDMEM[13] << 32);
	out_ct = (OUT_CIPHERTEXT*) base;
#endif

	base   = ((uint64_t)SHAREDMEM[14]) + ((uint64_t)SHAREDMEM[15] << 32);
	rlkconstants = (RLK_CONSTANTS*) base;
}

int main()
{

	char key = '0';

    init_platform();

    sleep(2);

    init_hardware();

    arm_v8_timing_init();

    init_SharedMemory();

	sleep(2);

    printf("Application Core %d is ready\n\r", APP);

    while(key != 'e')
    {
    	if (SHAREDMEM[APP] == 1)
		{
    		key = SHAREDMEM[APP_KEY];

			if (key == '4')
			{
#if APP == 0

START_TIMING

				send_eth_data_all((uint8_t*)(&poly->p0[0][0]));
STOP_TIMING

			int 	 proc;
			uint8_t* buffer;

START_TIMING
			for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
			{
				buffer = (uint8_t*)(&poly->p0[0][0]);

				send_eth_data(  0,
								proc,
								buffer,
								DATA_LEN*TX_ITER_COUNT,
								0);
			}
STOP_TIMING



#else
				send_eth_data_all((uint8_t*)(&poly->p1[0][0]));
#endif
				SHAREDMEM[APP_KEY] = 0;
			}

			if (key == '5')
			{
#if APP == 0
				recv_eth_data_all((uint8_t*)(poly->p0[0]));
#else
				recv_eth_data_all((uint8_t*)(poly->p1[0]));
#endif



				SHAREDMEM[APP_KEY] = 0;
			}

			if (key == '6')
			{
				int instruction =  0;
				int mod_sel		=  0;
				int rdM0		=  4;
				int rdM1		=  0;
				int wtM0		=  4;
				int wtM1		=  0;

				while(instruction != -1)
				{
					READ("Enter instruction code", instruction);
					READ("Enter rdM0", rdM0);
					READ("Enter rdM1", rdM1);
					READ("Enter wtM0", wtM0);
					READ("Enter wtM1", wtM1);

					send_inst_raw(
						(uint8_t) instruction,
						(uint8_t) mod_sel,
						(uint8_t) rdM0,
						(uint8_t) rdM1,
						(uint8_t) wtM0,
						(uint8_t) wtM1);

					while(instruction != 0 && core_config[3] != 1);

					xil_printf("Done\n\r\n\r");
				}

				SHAREDMEM[APP_KEY] = 0;
			}

			if (key == '7')
			{
				// Receive_Inputs_from_PC  ( in_ct,  1);
START_TIMING
				Write_Inputs_to_FPGA    (&in_ct[0] );
STOP_TIMING

START_TIMING
				ExecuteCode             ();
STOP_TIMING

START_TIMING
				Read_Outputs_from_FPGA  (&out_ct[0]);
STOP_TIMING
				// Send_Outputs_to_PC      ( out_ct, 1);

				SHAREDMEM[APP_KEY] = 0;
			}
		}
    }

    return 0;
}
