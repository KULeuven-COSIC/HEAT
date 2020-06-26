#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <sleep.h>

#include "platform.h"
#include "xil_printf.h"
#include "xil_cache.h"

#include "configuration.h"
#include "performance.h"
#include "data.h"

#define READ(STR, VAL)       \
    printf("%s: ", STR);     \
    scanf ("%d", &VAL);      \
    if(VAL == -1)			 \
        break; 				 \
    printf("%d\n\r",  VAL);

long long int mod_add(long long int a, int prime_index);
int poly_add_q(long long int a[], long long int b[], long long int c[], int prime_index);

void print_polynomial(uint64_t* polynomial)
{
    int i;

    uint32_t low, high;

    printf("Polynomial is:\n");
    for(i=0; i<POLY_LEN; i++)
    {
//    	printf("%ld\n\r", polynomial[i]);

    	low  = (polynomial[i] & 0x3FFFFFFF);
    	high = (polynomial[i] & 0x0FFFFFFFC0000000) >> 30;
    	printf("%d %d\n\r", high, low);
    }
}

volatile uint32_t * SHAREDMEM;

// These are the variables allocated here, and shared with application processors

POLYNOMIAL poly;
extern IN_CIPHERTEXT  in_ct0 [2];
extern IN_CIPHERTEXT  in_ct1 [2];
extern OUT_CIPHERTEXT out_ct0[2];
extern OUT_CIPHERTEXT out_ct1[2];
extern RLK_CONSTANTS  rlkconstants;

void init_SharedMemory(void)
{
	SHAREDMEM 		  = (uint32_t *) 0xFFFC0000;

    SHAREDMEM[0]  = 0;
    SHAREDMEM[1]  = 0;
    SHAREDMEM[2]  = 0;
    SHAREDMEM[3]  = 0;

    SHAREDMEM[4]  = (uint32_t) ((uint64_t)poly.p0[0]             & 0xFFFFFFFF);
    SHAREDMEM[5]  = (uint32_t) ((uint64_t)poly.p0[0]             >> 32       );

    SHAREDMEM[6]  = (uint32_t) ((uint64_t)in_ct0                & 0xFFFFFFFF);
	SHAREDMEM[7]  = (uint32_t) ((uint64_t)in_ct0[0].c00[0]      >> 32       );

	SHAREDMEM[8]  = (uint32_t) ((uint64_t)out_ct0[0].c0[0]      & 0xFFFFFFFF);
	SHAREDMEM[9]  = (uint32_t) ((uint64_t)out_ct0[0].c0[0]      >> 32       );

    SHAREDMEM[10] = (uint32_t) ((uint64_t)in_ct1[0].c00[0]      & 0xFFFFFFFF);
	SHAREDMEM[11] = (uint32_t) ((uint64_t)in_ct1[0].c00[0]      >> 32       );

	SHAREDMEM[12] = (uint32_t) ((uint64_t)out_ct1[0].c0[0]      & 0xFFFFFFFF);
	SHAREDMEM[13] = (uint32_t) ((uint64_t)out_ct1[0].c0[0]      >> 32       );

	SHAREDMEM[14] = (uint32_t) ((uint64_t)rlkconstants.rlk00[0] & 0xFFFFFFFF);
	SHAREDMEM[15] = (uint32_t) ((uint64_t)rlkconstants.rlk00[0] >> 32       );

	// printf("SHAREDMEM        : %p\n\r", (void *)  SHAREDMEM         );
    // printf("SHAREDMEM[4]     : %08X\n\r", SHAREDMEM[4]      );
    // printf("SHAREDMEM[5]     : %08X\n\r", SHAREDMEM[5]      );

	// printf("poly.p[0]       : %p\n\r", (void *)  poly.p[0]      );
	// printf("poly.p[0][0]    : %p\n\r", (void *) &poly.p[0][0]   );
	// printf("poly.p[1]       : %p\n\r", (void *)  poly.p[1]      );
	// printf("poly.p[1][0]    : %p\n\r", (void *) &poly.p[1][0]   );
	// printf("poly.p[1][1]    : %p\n\r", (void *) &poly.p[1][1]   );
	// printf("poly.p[1][2047] : %p\n\r", (void *) &poly.p[1][2047]);
	// printf("poly.p[2]       : %p\n\r", (void *)  poly.p[2]      );

	// printf("polynomial  : %p\n\r", (void *)  polynomial   );
	// printf("polynomial0 : %p\n\r", (void *)  polynomial[0]);
	// printf("polynomial1 : %p\n\r", (void *)  polynomial[1]);
	// printf("polynomial10: %p\n\r", (void *)&(polynomial[1][   0]));
	// printf("polynomial11: %p\n\r", (void *)&(polynomial[1][   1]));
	// printf("polynomial1x: %p\n\r", (void *)&(polynomial[1][2047]));
	// printf("polynomial2 : %p\n\r", (void *)  polynomial[2]);

	// printf("in_ct[0]            : %p\n\r", (void *) &in_ct[0]          );
	// printf("in_ct[0].c00        : %p\n\r", (void *) &in_ct[0].c00      );
	// printf("in_ct[1]            : %p\n\r", (void *) &in_ct[1]          );
	// printf("in_ct[1].c01[1][1]  : %p\n\r", (void *) &in_ct[1].c01[1][1]);

}

int main()
{
	char key = '0';

	int core = 0;

    init_platform();

	Xil_DCacheFlush();
	Xil_DCacheDisable();

	init_SharedMemory();

//    arm_v8_timing_init();

    sleep(1);

	SHAREDMEM[APP_SEL_0] = 1;
	SHAREDMEM[APP_SEL_1] = 0;

    printf("Interfacing Core is ready\n\r");

    while(1)
    {
    	xil_printf(" \n\r"
    		"                                  C: %d \n\r"
    		" --------------------------------------\n\r"
			" 0 - select core                       \n\r"
			" 1 - initialize polynomial             \n\r"
			" 2 - clear polynomial                  \n\r"
			" 3 - print polynomial                  \n\r"
			" 4 - send polynomial to FPGA           \n\r"
			" 5 - read polynomial from FPGA         \n\r"
			" 6 - send instruction to FPGA          \n\r"
			" 7 - execute code - once      		    \n\r"
		    " \n\r", core);

		scanf("%s", &key);
		xil_printf("Pressed %c\n\r", key);

		if (key == '0')
		{
			READ("Select Core", core);

			if     (core == 0) { SHAREDMEM[APP_SEL_0] = 1;	SHAREDMEM[APP_SEL_1] = 0; }
			else if(core == 1) { SHAREDMEM[APP_SEL_0] = 0;	SHAREDMEM[APP_SEL_1] = 1; }
			else 			   { SHAREDMEM[APP_SEL_0] = 1;	SHAREDMEM[APP_SEL_1] = 1; }

		}
		else

		if (key == '1')
		{
			uint64_t low, high;
			int proc, elem;
			for(proc=0; proc<NUM_OF_PROCESSORS+1; proc++)
			{
				for(elem=0; elem<POLY_LEN; elem++)
				{
					low  = (elem + 2*POLY_LEN * proc);
					high = (elem + 2*POLY_LEN * proc) + POLY_LEN;

					if (core==0) {
						poly.p0[proc][elem] = low;
						poly.p0[proc][elem] |= (high << 30);
					}
					else if (core==1) {
						poly.p1[proc][elem] = low;
						poly.p1[proc][elem] |= (high << 30);
					}
					else {
						poly.p0[proc][elem] = low;
						poly.p0[proc][elem] |= (high << 30);

						poly.p1[proc][elem] = low;
						poly.p1[proc][elem] |= (high << 30);
					}
				}
			}
		}
		else

		if (key == '2')
		{
			int proc, elem;
			for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
				for(elem=0; elem<POLY_LEN; elem++)
					if   	(core==0) 	poly.p0[proc][elem] = 0;
					else if (core==1) 	poly.p1[proc][elem] = 0;
					else {
										poly.p0[proc][elem] = 0;
										poly.p1[proc][elem] = 0;
					}
		}
		else

		if (key == '3')
		{
			if (core >= 2)
				printf("Select a single core, cannot print them both\r\n");
			else {
				int processor     =  0;

				while(processor != -1) {
					READ("Select a processor", processor);

					if   	(core==0) 	print_polynomial(poly.p0[processor]);
					else 				print_polynomial(poly.p1[processor]);
				}
			}
		}
		else

//		if (key == '8')
//		{
//			long long int a[NUM_PRIME][4096], b[NUM_PRIME][4096], c[NUM_PRIME][4096];
//			int i, j, k;
//
//			uint64_t time1;
//			uint64_t time2;
//
//
//			for(i=0; i<NUM_PRIME; i++) {
//				for(j=0; j<4096; j++) {
//					a[i][j] = j*j+i*4096;
//					b[i][j] = j*(j-1) +i*4096 + 123456;
//				}
//			}
//
//			for(k=0; k<10; k++)
//			{
//				time1 = arm_v8_get_timing();
//
//				// Addition of two ciphertexts (addition of 12 30-bit polynomials)
//				for(i=0; i<NUM_PRIME; i++) {
//					poly_add_q(a[i], b[i], c[i], i);
//					poly_add_q(b[i], c[i], a[i], i);
//				}
//
//				time2 = arm_v8_get_timing();
//
//				printf("TD: %ld\r\n", time2-time1);
//			}
//
//		}
//		else

		if (key == '4' || key == '5' || key == '6' || key == '7')
		{
//START_TIMING
			SHAREDMEM[APP_KEY] = key;

			while(SHAREDMEM[APP_KEY] != 0);
//STOP_TIMING
		}
    }

    cleanup_platform();
    return 0;
}


////////////////////////////////////////////////////////////

#define NUM_PRIME 6

long long int p[] = {1068564481,
					 1069219841,
					 1070727169,
					 1071513601,
					 1072496641,
					 1073479681,
					 1068433409,
					 1068236801,
					 1065811969,
					 1065484289,
					 1064697857,
					 1063452673,
					 1063321601};


long long int mod_add(long long int a, int prime_index)
{
	if(a>=p[prime_index])
		a = a - p[prime_index];

	return(a);
}


int poly_add_q(long long int a[], long long int b[], long long int c[], int prime_index)
{
	int i;

	for(i=0; i<4096; i++)
		c[i] = mod_add(a[i] + b[i], prime_index);

	return 0;
}
