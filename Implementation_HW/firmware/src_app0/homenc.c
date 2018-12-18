
#include <stdio.h>
#include "xil_printf.h"
#include "xpseudo_asm.h"

#include "configuration.h"
#include "homenc.h"
#include "data.h"
#include "code.h"
#include "hardware.h"
#include "performance.h"


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
//extern INSTRUCTION code0;

extern RLK_CONSTANTS * rlkconstants;

// Use local polynomial as c2, when the code is executed
extern POLYNOMIAL    *	poly;

extern uint8_t* eth_buffer;

void Receive_Inputs_from_PC (IN_CIPHERTEXT*  ct, int count)
{
//    int counter = 0;
//
//    while(counter < count)
//    {
//        eth_input_counter     = 0;
//        eth_processor_counter = 0;
//        eth_chunk_counter     = 0;
//
//        while (eth_input_counter < 4)
//        {
//            if		(eth_input_counter == 0) eth_buffer = (uint8_t*)(ct[counter].c00[eth_processor_counter]);
//            else if	(eth_input_counter == 1) eth_buffer = (uint8_t*)(ct[counter].c01[eth_processor_counter]);
//            else if	(eth_input_counter == 2) eth_buffer = (uint8_t*)(ct[counter].c10[eth_processor_counter]);
//            else                             eth_buffer = (uint8_t*)(ct[counter].c11[eth_processor_counter]);
//
//            if (TcpFastTmrFlag)
//            {
//                tcp_fasttmr();
//                TcpFastTmrFlag = 0;
//            }
//            if (TcpSlowTmrFlag)
//            {
//                tcp_slowtmr();
//                TcpSlowTmrFlag = 0;
//            }
//            xemacif_input(echo_netif);
//        }
//
//        counter++;
//    }
}

void Write_Inputs_to_FPGA (IN_CIPHERTEXT* ct)
{
    uint8_t   input;
    uint8_t  *buffer;
    
    for(input=0; input<4; input++)
    {
        // Write the input polynomials to mem4 at each loop

    	if      (input == 0) buffer = (uint8_t*)(ct->c00[0]);
		else if (input == 1) buffer = (uint8_t*)(ct->c01[0]);
		else if (input == 2) buffer = (uint8_t*)(ct->c10[0]);
		else                 buffer = (uint8_t*)(ct->c11[0]);

		send_eth_data_all(buffer);

        // Copy the input polynomials to memory 1->4 at each loop
		send_inst_raw  (20,
                        0,
                        4,
                        0,
                        input+1,
                        0
                        );
        
        wait_inst_done();
    }
}

void ExecuteCode(void)
{
	int       line = 0;
    uint8_t  *buffer;

//    uINSTRUCTION uinst;
            
    while(code[line].ins != 255)
    {
//         uinst.instruction = code[line];

//         xil_printf("Code[%d]: 0x%08X \n\r", line, uinst.whole32);

xil_printf("Instruction: %d\r\n", code[line].ins);

START_TIMING

         if (code[line].ins == 4)
		 {


			if      (code[line].addr1 ==  0)	buffer = (uint8_t*)(rlkconstants->rlk00[0]);
			else if (code[line].addr1 ==  1)	buffer = (uint8_t*)(rlkconstants->rlk01[0]);
			else if (code[line].addr1 ==  2)	buffer = (uint8_t*)(rlkconstants->rlk10[0]);
			else if (code[line].addr1 ==  3)	buffer = (uint8_t*)(rlkconstants->rlk11[0]);
			else if (code[line].addr1 ==  4)	buffer = (uint8_t*)(rlkconstants->rlk20[0]);
			else if (code[line].addr1 ==  5)	buffer = (uint8_t*)(rlkconstants->rlk21[0]);
			else if (code[line].addr1 ==  6)	buffer = (uint8_t*)(rlkconstants->rlk30[0]);
			else if (code[line].addr1 ==  7)	buffer = (uint8_t*)(rlkconstants->rlk31[0]);
			else if (code[line].addr1 ==  8)	buffer = (uint8_t*)(rlkconstants->rlk40[0]);
			else if (code[line].addr1 ==  9)	buffer = (uint8_t*)(rlkconstants->rlk41[0]);
			else if (code[line].addr1 == 10)	buffer = (uint8_t*)(rlkconstants->rlk50[0]);
			else if (code[line].addr1 == 11)	buffer = (uint8_t*)(rlkconstants->rlk51[0]);

			send_eth_data_all(buffer);
		 }

		 // Load memory 4 to c2 in DDR
         else if (code[line].ins == 10)
         {
#if APP == 0
        	 recv_eth_data_all((uint8_t*)(&poly->p0[0][0]));
#else
        	 recv_eth_data_all((uint8_t*)(&poly->p1[0][0]));
#endif
		 }

         // Load c2[addr1] to processor[any] of memory 4
		 else if (code[line].ins == 11)
		 {

 			send_eth_data(   0,
 							 0,
#if APP == 0
							 (uint8_t*)(&poly->p0[code[line].addr1][0]),
#else
							 (uint8_t*)(&poly->p1[code[line].addr1][0]),
#endif
							 DATA_LEN*TX_ITER_COUNT,
 							 1);
		 }
         else
         {
//        	 xil_printf("Instruction: %d\r\n", code[line].ins);

//START_TIMING
			 send_inst(code[line]);

			 if(code[line].ins != 0 && code[line].ins != 255)
		         wait_inst_done();
//STOP_TIMING

		}

STOP_TIMING

        line++;
    }
}

void Read_Outputs_from_FPGA (OUT_CIPHERTEXT* ct)
{
	uint8_t  *buffer;
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

		// Read mem4 to output polynomials

		if      (output == 0) buffer = (uint8_t*)(ct->c0[0]);
		else                  buffer = (uint8_t*)(ct->c1[0]);

		recv_eth_data_all(buffer);
	}


//    uint8_t  *buffer;
//    uint16_t  bram_address;
//    int       proc;
//    int       iter;
//    uint8_t   output;
//
//    for(output=0; output<2; output++)
//    {
//        // Copy outputs from memory 1->2 to mem4 at each loop
//
//        send_inst_raw  (20,
//                        0,
//                        output+1,0,
//                        4,0
//                        );
//
//        wait_inst_done();
//
////        send_inst(code0);
//
//        // Read mem4 to output polynomials
//
//        for(proc=0; proc<NUM_OF_PROCESSORS; proc++)
//        {
//            if(output==0) buffer = (uint8_t*)(ct->c0[proc]);
//            else          buffer = (uint8_t*)(ct->c1[proc]);
//
//            bram_address    =  0;
//
//            for(iter=0; iter<TX_ITER_COUNT; iter++)
//            {
//                recv_eth_data(	bram_address,
//                                proc,
//                                buffer+iter*DATA_LEN,
//                                DATA_LEN);
//
//                bram_address += 128;
//            }
//        }
//    }
}

void Send_Outputs_to_PC (OUT_CIPHERTEXT* ct, int count)
{
//    int counter = 0;
//
//    while(counter < count)
//    {
//        eth_input_counter     = 0;
//        eth_processor_counter = 0;
//        eth_chunk_counter     = 0;
//
//        while (eth_input_counter < 2)
//        {
//            if		(eth_input_counter == 0) eth_buffer = (uint8_t*)(ct[counter].c0[eth_processor_counter]);
//            else if	(eth_input_counter == 1) eth_buffer = (uint8_t*)(ct[counter].c1[eth_processor_counter]);
//
//            if (TcpFastTmrFlag)
//            {
//                tcp_fasttmr();
//                TcpFastTmrFlag = 0;
//            }
//            if (TcpSlowTmrFlag)
//            {
//                tcp_slowtmr();
//                TcpSlowTmrFlag = 0;
//            }
//            xemacif_input(echo_netif);
//        }
//
//        counter++;
//    }
}
