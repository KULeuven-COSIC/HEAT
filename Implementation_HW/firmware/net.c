#include "net.h"
#include "hardware.h"

#include "xil_printf.h"

// uint64_t counter = 0;

// receiving the polynomial in chunks of 1024-bytes
uint32_t eth_input_counter;
uint32_t eth_processor_counter;
uint32_t eth_chunk_counter;

uint8_t* eth_buffer;

err_t message_receive(struct tcp_pcb *tpcb, uint8_t *msg, int msg_length)
{
	int i;
	uint64_t  word_sum=0;
	uint64_t  word_xor=0;
	uint64_t* polynomial;

	uint8_t* ack = (uint8_t*)&word_sum;
	
	// A chunk of data is received
	if(msg_length==1024)
	{
		// xil_printf("In: %d Pr: %d Chunk: %d\n\r", 	
		// 			eth_input_counter,
		// 			eth_processor_counter, 
		// 			eth_chunk_counter);

		memcpy(eth_buffer + 1024 * eth_chunk_counter, msg, 1024);

		/*
		polynomial = (uint64_t*) (eth_buffer + 1024 * eth_chunk_counter);
		for(i=0; i<128; i++)
		{
			word_sum += polynomial[i];
			word_xor += polynomial[i];  
		}
		word_sum += counter;
		// counter++;

		// xil_printf("R: %lu, C: %lu X: 0x%08X \n\r", word_sum, counter, word_xor);

		if(message_send (tpcb, ack, 8) != ERR_OK)
			xil_printf("Error on send 1.\n\r");
		*/

		eth_chunk_counter++;

		if (eth_chunk_counter == 16)
		{
			eth_processor_counter++;
			eth_chunk_counter = 0;
		}

		if (eth_processor_counter == 6)
		{
			eth_processor_counter = 0;
			eth_input_counter++;
		}
	}

	// A read command is received
	else if (msg_length==1 && msg[0]== 0xFE)
	{
		// xil_printf("Out: %d Pr: %d Chunk: %d\n\r",
		// 			eth_input_counter,
		// 			eth_processor_counter,
		// 			eth_chunk_counter);

		if(message_send (tpcb, eth_buffer + 1024 * eth_chunk_counter, 1024) != ERR_OK)
			xil_printf("Error on send 2.\n\r");

		/*
		polynomial = (uint64_t*) (eth_buffer + 1024 * eth_chunk_counter);
		for(i=0; i<128; i++)
		{
			word_sum += polynomial[i];
			word_xor += polynomial[i];  
		}
		word_sum += counter;
		// counter++;

		// xil_printf("S: %lu, C: %lu X: 0x%08X \n\r", word_sum, counter, word_xor);
		
		if(message_send (tpcb, ack, 8) != ERR_OK)
			xil_printf("Error on send 3.\n\r");
		*/

		eth_chunk_counter++;

		if (eth_chunk_counter == 16)
		{
			eth_processor_counter++;
			eth_chunk_counter = 0;
		}

		if (eth_processor_counter == 6)
		{
			eth_processor_counter = 0;
			eth_input_counter++;
		}
	}
	else
	{		
		xil_printf("Unknown message\n\r");
	}

	return ERR_OK;
}

err_t message_send (struct tcp_pcb *tpcb, uint8_t *msg, int msg_length)
{
	return tcp_write(tpcb, msg, msg_length, 1);
}
