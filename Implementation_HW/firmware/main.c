#include <stdio.h>

#include "xil_printf.h"

#include "code.h"

// defined by each RAW mode application
void tcp_fasttmr(void);
void tcp_slowtmr(void);

extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;
extern struct netif *echo_netif;

extern volatile uint32_t * core_config;

// 2048 times 60-bit (8-byte) words
// 4096 times 30-bit (4-byte) words
#define POLY_LEN 2048

// One transfer is 1024-bytes
#define DATA_LEN 1024

// All transfers will take 2048 * 8 / 1024 = 16 iterations
//                         4096 * 4 / 1024 = 16
#define TX_ITER_COUNT (POLY_LEN * 8 / DATA_LEN)

#define NUM_OF_PROCESSORS 6

uint64_t  polynomial  [NUM_OF_PROCESSORS+1][POLY_LEN];

#include "constants.h"
#include "input.h"

extern INSTRUCTION code[];
extern INSTRUCTION code0;

#define READ(STR, VAL)       \
    printf("%s: ", STR);     \
    scanf ("%d", &VAL);      \
    if(VAL == -1)			 \
        break; 				 \
    printf("%d\n\r",  VAL);


void print_polynomial(uint64_t* polynomial)
{
    int i;

    uint32_t low, high;

    printf("Polynomial is:\n");
    for(i=0; i<POLY_LEN; i++)
    {
        low  = (polynomial[i] & 0x3FFFFFFF);
        high = (polynomial[i] & 0x0FFFFFFFC0000000) >> 30;
        printf("%d %d\n\r", high, low);
    }
}

int main()
{
    char key = '0';

    init_platform();
    init_hardware();

    printf("Address of rlk is 0x%X \n\r", rlk00);
    printf("Address of rlk is %lld \n\r", rlk00);

    while(key != 'e')
    {
        xil_printf(" \n\r"
                   " --------------------------------------\n\r"
                   " 0 - initialize polynomial             \n\r"
                   " 1 - clear the polynomial              \n\r"
                   " 2 - print the polynomial              \n\r"
                   " 3 - send the polynomial               \n\r"
                   " 4 - read back the polynomial          \n\r"
                   " 5 - send an instruction               \n\r"
                   " 6 - print status  				  	   \n\r"
                   " 7 - execute code  				  	   \n\r"
                   " \n\r");

        scanf("%s", &key);
        xil_printf("Pressed %c\n\r", key);

        if (key == '0')
        {
            uint64_t low, high;
            int proc, elem;
            for(proc=0; proc<NUM_OF_PROCESSORS+1; proc++)
            {
                for(elem=0; elem<POLY_LEN; elem++)
                {
                    //low  = 2 * (elem + POLY_LEN * proc);
                    //high = 2 * (elem + POLY_LEN * proc) + 20;
                    
                    // low  = (elem + 2*POLY_LEN * proc);
                    // high = (elem + 2*POLY_LEN * proc) + POLY_LEN;

                    if      (proc==0) {high=87381051;   low=1007649774;}
                    else if (proc==1) {high=258812005;  low=882798562; }
                    else if (proc==2) {high=292876642;  low=984429559; }
                    else if (proc==3) {high=913327902;  low=777893800; }
                    else if (proc==4) {high=203221019;  low=817372628; }
                    else if (proc==5) {high=46769069;   low=462585748; }
                    else              {high=807999276;  low=741806817; }                  
                    polynomial[proc][elem] = low;
                    polynomial[proc][elem] |= (high << 30);
                }
            }
           
            // for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
            // {
            //     for(elem=0; elem<POLY_LEN; elem++)
            //     {
            //         //low  = 2 * (elem + POLY_LEN * proc);
            //         //high = 2 * (elem + POLY_LEN * proc) + 20;
            //         low  = (elem + 2*POLY_LEN * proc);
            //         high = (elem + 2*POLY_LEN * proc) + POLY_LEN;

            //         polynomial[proc][elem] = low;
            //         polynomial[proc][elem] |= (high << 30);
            //     }
            // }
        }

        if (key == '9')
        {
            uint64_t low, high;
            int proc, elem;
            for(proc=0; proc<NUM_OF_PROCESSORS+1; proc++)
            {
                for(elem=0; elem<POLY_LEN; elem++)
                {
                    //low  = 2 * (elem + POLY_LEN * proc);
                    //high = 2 * (elem + POLY_LEN * proc) + 20;
                    
                    // low  = (elem + 2*POLY_LEN * proc);
                    // high = (elem + 2*POLY_LEN * proc) + POLY_LEN;

                    if      (proc==0) {high=1015210041; low=259092531; }
                    else if (proc==1) {high=215326808;  low=975057076; }
                    else if (proc==2) {high=996761720;  low=1035334068;}
                    else if (proc==3) {high=53551254;   low=443265843; }
                    else if (proc==4) {high=660201653;  low=925332786; }
                    else if (proc==5) {high=656974035;  low=634206127; }  
                    else              {high=0;          low=0;         }         

                    polynomial[proc][elem] = low;
                    polynomial[proc][elem] |= (high << 30);
                }
            }
           
            // for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
            // {
            //     for(elem=0; elem<POLY_LEN; elem++)
            //     {
            //         //low  = 2 * (elem + POLY_LEN * proc);
            //         //high = 2 * (elem + POLY_LEN * proc) + 20;
            //         low  = (elem + 2*POLY_LEN * proc);
            //         high = (elem + 2*POLY_LEN * proc) + POLY_LEN;

            //         polynomial[proc][elem] = low;
            //         polynomial[proc][elem] |= (high << 30);
            //     }
            // }
        }

        if (key == '1')
        {
            int proc, elem;
            for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
                for(elem=0; elem<POLY_LEN; elem++)
                    polynomial[proc][elem] = 0;
        }

        if (key == '2')
        {
            int processor     =  0;

            while(processor != -1)
            {
                READ("Select a processor", processor);

                print_polynomial(polynomial[processor]);
            }
        }

        if (key == '3')
        {
            uint8_t  *buffer;
            uint16_t  bram_address;

            int proc, iter;
            for(proc=0; proc<NUM_OF_PROCESSORS+1; proc++)
            {
                buffer = (uint8_t*)(polynomial[proc]);

                bram_address = 0;

                for(iter=0; iter<TX_ITER_COUNT; iter++)
                {
                    send_eth_data(	bram_address,
                                    proc,
                                    buffer+iter*DATA_LEN,
                                    DATA_LEN);

                    bram_address += 128;
                }
            }
        }

        if (key == '4')
        {
            uint8_t  *buffer;
            uint16_t  bram_address;
            int       processor = 0;

            while(processor != -1)
            {
                READ("Select a processor", processor);

                buffer = (uint8_t*)(polynomial[processor]);

                bram_address    =  0;

                int iter;
                for(iter=0; iter<TX_ITER_COUNT; iter++)
                {
                    recv_eth_data(	bram_address,
                                    processor,
                                    buffer+iter*DATA_LEN,
                                    DATA_LEN);

                    bram_address += 128;
                }
            }
        }

        if (key == '5')
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

                while(instruction != 0 && core_config[2] != 1)
                    xil_printf(".");

                xil_printf("Done\n\r\n\r");
            }
        }

        if (key == '6')
        {
            xil_printf("Poly Done        : 0x%08X \n\r", core_config[2]);

            xil_printf("Status           : 0x%08X \n\r", core_config[4]);
            xil_printf("Poly Done        : %d\n\r", (core_config[3]&0x00000001) >>  0);
            xil_printf("Poly Eth Intr    : %d\n\r", (core_config[3]&0x00000100) >>  8);
            xil_printf("Poly Instruction : %d\n\r", (core_config[3]&0x00FF0000) >> 16);
        }

        if (key == '7')
        {
            uint8_t   counter=0;
            int       line = 0;
            uint8_t  *buffer;
            uint16_t  bram_address = 0;
            int       iter;
        	int 	  proc;

            uINSTRUCTION uinst;

            uinst.instruction = code[line];

            send_inst(code0);

            // for (line=0; line < CODE_LEN; line++)
            while(code[line].ins != 255)
            {
                uinst.instruction = code[line];

                xil_printf("Code[%d]: 0x%08X \n\r", line, uinst.whole32);

                if(code[line].ins == 4)
                {
                    if      (code[line].addr1 <  6) 	buffer = (uint8_t*)(rlk00[code[line].proc]);
                    else if (code[line].addr1 < 12) 	buffer = (uint8_t*)(rlk01[code[line].proc]);
                    else if (code[line].addr1 < 18) 	buffer = (uint8_t*)(rlk10[code[line].proc]);
                    else					            buffer = (uint8_t*)(rlk11[code[line].proc]);
                    
                    send_inst_raw  (0, 
                                    0, 
                                    code[line].addr1 & 0x0F,
                                   (code[line].addr1 & 0xF0) >> 4,
                                    code[line].addr2 & 0x0F,
                                   (code[line].addr2 & 0xF0) >> 4
                                   );
                    
                    for(iter=0; iter<TX_ITER_COUNT; iter++)
                    {
                        send_const_data(	bram_address,
                                            code[line].proc,
                                            buffer+iter*DATA_LEN,
                                            DATA_LEN);

                        bram_address += 128;
                    }
                }
                else if(code[line].ins == 64)
                {
                    for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
                    {
                        if      ((counter & 0x03) == 0)   buffer = (uint8_t*)(c00[proc]);
                        else if ((counter & 0x03) == 1)   buffer = (uint8_t*)(c01[proc]);
                        else if ((counter & 0x03) == 2)   buffer = (uint8_t*)(c10[proc]);
                        else                              buffer = (uint8_t*)(c11[proc]);

                        xil_printf("Load in 0x%02X\n\r", counter & 0x03);

                        bram_address = 0;

                        for(iter=0; iter<TX_ITER_COUNT; iter++)
                        {
                            send_eth_data(	bram_address,
                                            proc,
                                            buffer+iter*DATA_LEN,
                                            DATA_LEN);

                            bram_address += 128;
                        }
                    }

                    counter++;
                }
                else
                {
                   send_inst(code[line]);

                   while((code[line].ins != 0 && code[line].ins != 255) && core_config[2] != 1);

                   send_inst(code0);
                }

                line++;
            }

            xil_printf("Done\n\r\n\r");
        }
    }

    return 0;
}




//	xil_printf("\n\n START TEST\n\r");
//
//	init_server();
//
//	start_server();
//
//	init_hardware();
//
//	while (1)
//	{
//		if (TcpFastTmrFlag)
//		{
//			tcp_fasttmr();
//			TcpFastTmrFlag = 0;
//		}
//
//		if (TcpSlowTmrFlag)
//		{
//			tcp_slowtmr();
//			TcpSlowTmrFlag = 0;
//		}
//
//		xemacif_input(echo_netif);
//	}
//
//	cleanup_platform();
