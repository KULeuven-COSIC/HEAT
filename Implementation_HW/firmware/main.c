#include <stdio.h>
#include <inttypes.h>
#include "xpseudo_asm.h"
#include "xil_printf.h"

#include "configuration.h"
#include "code.h"
#include "data.h"
#include "performance.h"
#include "hardware.h"
#include "homenc.h"
#include "server.h"


// defined by each RAW mode application
void tcp_fasttmr(void);
void tcp_slowtmr(void);

extern volatile uint32_t * core_config;

uint64_t  polynomial  [NUM_OF_PROCESSORS+1][POLY_LEN];

extern IN_CIPHERTEXT  in_ct [64];
extern OUT_CIPHERTEXT out_ct[64];

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
    init_server();

    start_server();

    arm_v8_timing_init();

    while(key != 'e')
    {
        xil_printf(" \n\r"
                   " --------------------------------------\n\r"
                   " 0 - initialize polynomial             \n\r"
                   " 1 - clear polynomial                  \n\r"
                   " 2 - print polynomial                  \n\r"
                   " 3 - send polynomial to FPGA           \n\r"
                   " 4 - read polynomial from FPGA         \n\r"
                   " 5 - send instruction to FPGA          \n\r"
                   " 6 - execute code - once      		   \n\r"
                   " 7 - execute code - infinite           \n\r"
                   " 8 - 100 multiplications               \n\r"
                   " 9 - 1000 multiplications              \n\r"                   
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
        }

        if (key == 'A')
        {
            uint64_t low, high;
            int proc, elem;
            for(proc=0; proc<NUM_OF_PROCESSORS+1; proc++)
            {
                for(elem=0; elem<POLY_LEN; elem++)
                {
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

                if(instruction == 7) START_TIMING

                send_inst_raw(
                    (uint8_t) instruction,
                    (uint8_t) mod_sel,
                    (uint8_t) rdM0,
                    (uint8_t) rdM1,
                    (uint8_t) wtM0,
                    (uint8_t) wtM1);

                while(instruction != 0 && core_config[2] != 1);
                    // xil_printf(".");

                if(instruction == 7) STOP_TIMING

                send_inst(code0);

                xil_printf("Done\n\r\n\r");
            }
        }

        // if (key == '6')
        // {
        //     xil_printf("Poly Done        : 0x%08X \n\r", core_config[2]);

        //     xil_printf("Status           : 0x%08X \n\r", core_config[4]);
        //     xil_printf("Poly Done        : %d\n\r", (core_config[3]&0x00000001) >>  0);
        //     xil_printf("Poly Eth Intr    : %d\n\r", (core_config[3]&0x00000100) >>  8);
        //     xil_printf("Poly Instruction : %d\n\r", (core_config[3]&0x00FF0000) >> 16);
        // }

        if (key == '6')
        {
            Receive_Inputs_from_PC  ( in_ct,  1);
            Write_Inputs_to_FPGA    (&in_ct[0] );
            ExecuteCode             ();
            Read_Outputs_from_FPGA  (&out_ct[0]);
            Send_Outputs_to_PC      ( out_ct, 1);
        }

        if (key == '7')
        {
            while(1)
            {
                Receive_Inputs_from_PC  ( in_ct,  1);

            platform_disable_interrupts();
			START_TIMING

                Write_Inputs_to_FPGA    (&in_ct[0] );
                ExecuteCode             ();
                Read_Outputs_from_FPGA  (&out_ct[0]);
			
            STOP_TIMING
            platform_enable_interrupts();

                Send_Outputs_to_PC      ( out_ct, 1);
            }
        }

        if (key == '8')
        {
            int i;

            START_TIMING
            for(i=0; i<100; i++)
            {
                Write_Inputs_to_FPGA    (&in_ct[0] );
                ExecuteCode             ();
                Read_Outputs_from_FPGA  (&out_ct[0]);
            }
            STOP_TIMING

        }

        if (key == '9')
        {
            int i;

            START_TIMING
            for(i=0; i<1000; i++)
            {
                Write_Inputs_to_FPGA    (&in_ct[0] );
                ExecuteCode             ();
                Read_Outputs_from_FPGA  (&out_ct[0]);

                if((i%10)==0) xil_printf("%d\n\r", i);
            }
            STOP_TIMING

        }
    }

    return 0;
}
