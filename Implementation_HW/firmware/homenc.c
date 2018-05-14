
#include <stdio.h>
#include "xil_printf.h"
#include "xpseudo_asm.h"

#include "configuration.h"
#include "homenc.h"
#include "data.h"
#include "code.h"
#include "hardware.h"
#include "server.h"

// defined by each RAW mode application
void tcp_fasttmr(void);
void tcp_slowtmr(void);

extern struct netif *echo_netif;
extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;
extern uint32_t eth_input_counter;
extern uint32_t eth_processor_counter;
extern uint32_t eth_chunk_counter;

extern INSTRUCTION code[];
extern INSTRUCTION code0;

extern IN_CIPHERTEXT  constants;

extern uint8_t* eth_buffer;

void Receive_Inputs_from_PC (IN_CIPHERTEXT*  ct, int count)
{
    int counter = 0;

    while(counter < count)
    {
        eth_input_counter     = 0;
        eth_processor_counter = 0;
        eth_chunk_counter     = 0;           

        while (eth_input_counter < 4)
        {
            if		(eth_input_counter == 0) eth_buffer = (uint8_t*)(ct[counter].c00[eth_processor_counter]);
            else if	(eth_input_counter == 1) eth_buffer = (uint8_t*)(ct[counter].c01[eth_processor_counter]);
            else if	(eth_input_counter == 2) eth_buffer = (uint8_t*)(ct[counter].c10[eth_processor_counter]);
            else                             eth_buffer = (uint8_t*)(ct[counter].c11[eth_processor_counter]);

            if (TcpFastTmrFlag)
            {
                tcp_fasttmr();
                TcpFastTmrFlag = 0;
            }
            if (TcpSlowTmrFlag)
            {
                tcp_slowtmr();
                TcpSlowTmrFlag = 0;
            }
            xemacif_input(echo_netif);
        }
     
        counter++;
    }
}

void Write_Inputs_to_FPGA (IN_CIPHERTEXT* ct)
{
    uint8_t   input;
    int       iter;
    int 	  proc;
    uint8_t  *buffer;
    uint16_t  bram_address = 0;
    
    for(input=0; input<4; input++)
    {
        // Write the input polynomials to mem4 at each loop

        for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
        {
            if      (input == 0) buffer = (uint8_t*)(ct->c00[proc]);
            else if (input == 1) buffer = (uint8_t*)(ct->c01[proc]);
            else if (input == 2) buffer = (uint8_t*)(ct->c10[proc]);
            else                 buffer = (uint8_t*)(ct->c11[proc]);
        
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

        // Copy the input polynomials to memory 1->4 at each loop

        send_inst_raw  (20,
                        0,
                        4,
                        0,
                        input+1,
                        0
                        );
        
        wait_inst_done();

        send_inst(code0);
    }
}

void ExecuteCode(void)
{
    int       line = 0;
    uint8_t  *buffer;
    uint16_t  bram_address = 0;
    int       iter;

    // uINSTRUCTION uinst;

    send_inst(code0);
            
    while(code[line].ins != 255)
    {
        // uinst.instruction = code[line];

        // xil_printf("Code[%d]: 0x%08X \n\r", line, uinst.whole32);
        
        if(code[line].ins != 4)
        {
            send_inst(code[line]);

            if(code[line].ins != 0 && code[line].ins != 255)
                wait_inst_done();
            
            send_inst(code0);
        }
        else
        {
            if      (code[line].addr1 <  6) 	buffer = (uint8_t*)(constants.c00[code[line].proc]);
            else if (code[line].addr1 < 12) 	buffer = (uint8_t*)(constants.c01[code[line].proc]);
            else if (code[line].addr1 < 18) 	buffer = (uint8_t*)(constants.c10[code[line].proc]);
            else					            buffer = (uint8_t*)(constants.c11[code[line].proc]);

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

            send_inst(code0);
        }
        

        line++;
    }

    send_inst(code0);
}

void Read_Outputs_from_FPGA (OUT_CIPHERTEXT* ct)
{
    uint8_t  *buffer;
    uint16_t  bram_address;
    int       proc;
    int       iter;
    uint8_t   output;

    for(output=0; output<2; output++)
    {
        // Copy outputs from memory 1->2 to mem4 at each loop

        send_inst_raw  (20,
                        0,
                        output+1,0,
                        4,0
                        );
        
        wait_inst_done();

        send_inst(code0);

        // Read mem4 to output polynomials

        for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
        {
            if(output==0) buffer = (uint8_t*)(ct->c0[proc]);
            else          buffer = (uint8_t*)(ct->c1[proc]);

            bram_address    =  0;

            for(iter=0; iter<TX_ITER_COUNT; iter++)
            {
                recv_eth_data(	bram_address,
                                proc,
                                buffer+iter*DATA_LEN,
                                DATA_LEN);

                bram_address += 128;
            }
        }
    }
}

void Send_Outputs_to_PC (OUT_CIPHERTEXT* ct, int count)
{
    int counter = 0;

    while(counter < count)
    {
        eth_input_counter     = 0;
        eth_processor_counter = 0;
        eth_chunk_counter     = 0;

        while (eth_input_counter < 2)
        {
            if		(eth_input_counter == 0) eth_buffer = (uint8_t*)(ct[counter].c0[eth_processor_counter]);
            else if	(eth_input_counter == 1) eth_buffer = (uint8_t*)(ct[counter].c1[eth_processor_counter]);

            if (TcpFastTmrFlag)
            {
                tcp_fasttmr();
                TcpFastTmrFlag = 0;
            }
            if (TcpSlowTmrFlag)
            {
                tcp_slowtmr();
                TcpSlowTmrFlag = 0;
            }
            xemacif_input(echo_netif);
        }

        counter++;
    }
}
