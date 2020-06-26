#include<string.h>
#include "socket.c"
#include<stdint.h>
/*
void comm_test_init()
{
	int total_sync_loss;
	long long int m_0[512], m_1[512];
	long long int c0_0[32768], c0_1[32768], c1_0[2][512], c1_1[2][512];
	int i, j;
	FILE *fp;
	long long int et=0;

	// Declaration of Ethernet Frame variables 	
	unsigned char byte_array1[MSGS][6+128*8+8], byte_array2[4][6+128*10], byte_array3[4][6+128*10];
	unsigned char byte_array4[4][6+128*10], byte_array5[4][6+128*10];

	long long int random_array[256];
	long long int ciphertext_poly[4096*13];


	total_sync_loss = 0;

	int COUNTER;
	unsigned int temp;
	unsigned char ins = 0;
	unsigned short operand = 0;

	unsigned short processor_sel, memory_sel;
		
	char fname[100];

	//send_byte_array(reset_array);

	/////////////////////// Send RLK00  ////////////////////////

	strcpy(fname, "rlk00_shares");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 5);
	send_byte_array(byte_array1);
	usleep(100);

	// Execute program: copy to DDR		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);

	/////////////////////// Send RLK01  ////////////////////////

	strcpy(fname, "rlk01_shares");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 6);
	send_byte_array(byte_array1);
	usleep(100);
	
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);

	/////////////////////// Send RLK10  ////////////////////////

	strcpy(fname, "rlk10_shares");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 7);
	send_byte_array(byte_array1);
	usleep(100);

	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);

	/////////////////////// Send RLK11  ////////////////////////

	strcpy(fname, "rlk11_shares");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 8);
	send_byte_array(byte_array1);
	usleep(100);

	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);

}

*/


void HE_MUL_HW(long long int c00[][4096], long long int c01[][4096], long long int c10[][4096], long long int c11[][4096], long long int c0[][4096], long long int c1[][4096])
{
	int total_sync_loss;
	long long int m_0[512], m_1[512];
	long long int c0_0[32768], c0_1[32768], c1_0[2][512], c1_1[2][512];
	int i, j;
	FILE *fp;
	long long int et=0;

	// Declaration of Ethernet Frame variables 	
	unsigned char byte_array1[MSGS][6+128*8+8], byte_array2[4][6+128*10], byte_array3[4][6+128*10];
	unsigned char byte_array4[4][6+128*10], byte_array5[4][6+128*10];

	long long int random_array[256];
	long long int ciphertext_poly[4096*13];


	total_sync_loss = 0;

	int COUNTER;
	unsigned int temp;
	unsigned char ins = 0;
	unsigned short operand = 0;

	unsigned short processor_sel, memory_sel;
		
	char fname[100];


	uint8_t processor, memory;
	uint64_t poly_60bit_word[2048];
	

	/////////////////////// Send C00  ////////////////////////

	for(processor=0; processor<NUM_PRIME; processor++)
	{
	    memory = 4;			

	    initialize_poly_gap2048(c00[processor], poly_60bit_word);

	    eth_send(processor, memory, 0, poly_60bit_word);
	}


	/////////////////////// Send C01  ////////////////////////
	for(processor=0; processor<NUM_PRIME; processor++)
	{
	    memory = 4;

	    initialize_poly_gap2048(c01[processor], poly_60bit_word);

	    eth_send(processor, memory, 0, poly_60bit_word);
	}


	/////////////////////// Send C10  ////////////////////////
	for(processor=0; processor<NUM_PRIME; processor++)
	{
	    memory = 4;

	    initialize_poly_gap2048(c10[processor], poly_60bit_word);

	    eth_send(processor, memory, 0, poly_60bit_word);
	}
	/////////////////////// Send C11  ////////////////////////
	for(processor=0; processor<NUM_PRIME; processor++)
	{
	    memory = 4;

	    initialize_poly_gap2048(c11[processor], poly_60bit_word);

	    eth_send(processor, memory, 0, poly_60bit_word);
	}


	printf("reading\n");
	// read result c0;
	for(processor=0; processor<NUM_PRIME; processor++)
	{
		memory = 4;
		
		eth_recv(processor, memory, 0, poly_60bit_word);

		initialize_ciphertext_gap2048(c0[processor], poly_60bit_word);
	}

	// read result c1;
	for(processor=0; processor<NUM_PRIME; processor++)
	{
		memory = 4;
		
		eth_recv(processor, memory, 0, poly_60bit_word);

		initialize_ciphertext_gap2048(c1[processor], poly_60bit_word);
	}

}

/*
void comm_test(long long int c00[][4096], long long int c01[][4096], long long int c10[][4096], long long int c11[][4096], long long int c0[][4096], long long int c1[][4096])
{
	int total_sync_loss;
	long long int m_0[512], m_1[512];
	long long int c0_0[32768], c0_1[32768], c1_0[2][512], c1_1[2][512];
	int i, j;
	FILE *fp;
	long long int et=0;

	// Declaration of Ethernet Frame variables 	
	unsigned char byte_array1[MSGS][6+128*8+8], byte_array2[4][6+128*10], byte_array3[4][6+128*10];
	unsigned char byte_array4[4][6+128*10], byte_array5[4][6+128*10];

	long long int random_array[256];
	long long int ciphertext_poly[4096*13];


	total_sync_loss = 0;

	//send_byte_array(reset_array);
	//usleep(1000);

	int COUNTER;
	unsigned int temp;
	unsigned char ins = 0;
	unsigned short operand = 0;

	unsigned short processor_sel, memory_sel;
		
	char fname[100];


	/////////////////////// Send C00  ////////////////////////

	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte_gap2048(byte_array1, c00[i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 0);
	send_byte_array(byte_array1);
	usleep(100);
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);
	/////////////////////// Send C01  ////////////////////////

	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		//poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		poly2byte_gap2048(byte_array1, c01[i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 1);
	send_byte_array(byte_array1);
	usleep(100);
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);
	/////////////////////// Send C10  ////////////////////////

	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		//poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		poly2byte_gap2048(byte_array1, c10[i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 2);
	send_byte_array(byte_array1);
	usleep(100);

	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);



	/////////////////////// Send C11  ////////////////////////

	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		//poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		poly2byte_gap2048(byte_array1, c11[i], operand);
		send_byte_array(byte_array1);
		usleep(200);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 3);
	send_byte_array(byte_array1);
	usleep(100);

	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);

	//////////////////////////////////////////////////
	//             Execute HE Program               //
        //////////////////////////////////////////////////

	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 4);
	send_byte_array(byte_array1);
	usleep(100);


	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	//usleep(27500);	// for single core .. run28 v3
	usleep(26800);	// for dual core .. run1 v4_proc7
	
	for(COUNTER=0; COUNTER<6; COUNTER++)
	{
		
		// Read result
		L1:		
		ins = 2;
		processor_sel=COUNTER; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;	// Eth read P0_M0
		send_instruction(ins, operand);

		break_loop_detected = 0;
		packet_count = 0;
		if(receive_byte_array() != 0)		// when corrupt eth frame is received then nonzero is returned
		{
			printf("Sync loss\n");
			open_pcap_ethport();		// open ethernet port
			goto L1; 			// re-transmit the c to fpga
		}
		break_loop_detected = 0;
		packet_count = 0;
		//byte2poly(c0_0, c0_1);
		byte2poly_gap2048(c0, COUNTER);
		for(i=0; i<MSGS*128; i++)
		{
			//printf("%lld %lld\n", c0_0[i]&1073741823llu, c0_1[i]&1073741823llu);
			//printf("%lld %lld\n", c0[COUNTER][i]&1073741823llu, c0[COUNTER][i+2048]&1073741823llu);
		}

		usleep(100);
		et = 0;
	}

	break_loop_detected = 0;
	packet_count = 0;
	//printf("et = %d\n", et);




	// send program to FPGA	: Copy cmul1 --> M4
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 9);
	send_byte_array(byte_array1);
	usleep(100);

	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);


	for(COUNTER=0; COUNTER<6; COUNTER++)
	{
		
		// Read result
		L2:		
		ins = 2;
		processor_sel=COUNTER; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;	// Eth read P0_M0
		send_instruction(ins, operand);

		break_loop_detected = 0;
		packet_count = 0;
		if(receive_byte_array() != 0)		// when corrupt eth frame is received then nonzero is returned
		{
			printf("Sync loss\n");
			open_pcap_ethport();		// open ethernet port
			goto L2; 			// re-transmit the c to fpga
		}
		break_loop_detected = 0;
		packet_count = 0;
		//byte2poly(c0_0, c0_1);
		byte2poly_gap2048(c1, COUNTER);
		for(i=0; i<MSGS*128; i++)
		{
			//printf("%lld %lld\n", c0_0[i]&1073741823llu, c0_1[i]&1073741823llu);
			//printf("%lld %lld\n", c1[COUNTER][i]&1073741823llu, c1[COUNTER][i+2048]&1073741823llu);
		}

		usleep(100);
		et = 0;
	}

	break_loop_detected = 0;
	packet_count = 0;
	//printf("et = %d\n", et);

}
*/

int first_command_send = 0;


