#include<string.h>

void comm_test_init()
{
	int total_sync_loss;
	long long int m_0[512], m_1[512];
	long long int c0_0[32768], c0_1[32768], c1_0[2][512], c1_1[2][512];
	int i, j;
	FILE *fp;
	long long int et=0;

	// Declaration of Ethernet Frame variables 	
	unsigned char byte_array1[MSGS][6+128*10], byte_array2[4][6+128*10], byte_array3[4][6+128*10], reset_array[4][6+128*10];
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
		usleep(100);
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
		usleep(100);
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
		usleep(100);
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
		usleep(100);
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

void comm_test()
{
	int total_sync_loss;
	long long int m_0[512], m_1[512];
	long long int c0_0[32768], c0_1[32768], c1_0[2][512], c1_1[2][512];
	int i, j;
	FILE *fp;
	long long int et=0;

	// Declaration of Ethernet Frame variables 	
	unsigned char byte_array1[MSGS][6+128*10], byte_array2[4][6+128*10], byte_array3[4][6+128*10], reset_array[4][6+128*10];
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
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 5);
	send_byte_array(byte_array1);
	usleep(100);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(10000);
	*/
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);
	*/
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
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 6);
	send_byte_array(byte_array1);
	usleep(100);
	
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(10000);
	*/
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);

	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);
	*/
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
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 7);
	send_byte_array(byte_array1);
	usleep(100);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(10000);
	*/
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);
	*/
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
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 8);
	send_byte_array(byte_array1);
	usleep(100);

	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(10000);
	*/
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(5000);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);
	*/




	/////////////////////// Send C00  ////////////////////////

	strcpy(fname, "c0_0");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 0);
	send_byte_array(byte_array1);
	usleep(100);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100);
	*/
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);
	*/
	/////////////////////// Send C01  ////////////////////////

	strcpy(fname, "c0_1");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 1);
	send_byte_array(byte_array1);
	usleep(100);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(10000);
	*/
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);
	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);
	*/
	/////////////////////// Send C10  ////////////////////////

	strcpy(fname, "c1_0");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 2);
	send_byte_array(byte_array1);
	usleep(100);

	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100);
	
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);

	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);


	/////////////////////// Send C11  ////////////////////////

	strcpy(fname, "c1_1");	
	read_ciphertext1(ciphertext_poly, fname);
	for(i=0; i<6; i++)
	{
		ins=1;
		processor_sel=i; memory_sel=4; 
		operand = (processor_sel<<5)+memory_sel;
		poly2byte(byte_array1, &ciphertext_poly[4096*i], operand);
		send_byte_array(byte_array1);
		usleep(100);
	}
	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 3);
	send_byte_array(byte_array1);
	usleep(100);

	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100);
	
	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	usleep(1000);


	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);



	//////////////////////////////////////////////////
	//             Execute HE Program               //
        //////////////////////////////////////////////////

	// send program to FPGA	
	ins=64;
	operand = 0;
	poly2byte_program(byte_array1, operand, 4);
	send_byte_array(byte_array1);
	usleep(100);

	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(10000);
	*/

	// Execute program		
	operand = 0;
	ins = 65;
	send_instruction(ins, operand);
	//usleep(1000000);
	usleep(27500);

	/*
	operand = 0;
	ins = 0;
	send_instruction(ins, operand);
	usleep(100000);
	*/


	
	
	
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
		byte2poly(c0_0, c0_1);

		for(i=0; i<MSGS*128; i++)
		{
			printf("%lld %lld\n", c0_0[i]&1073741823llu, c0_1[i]&1073741823llu);

		}

		usleep(100);
		et = 0;
	}
	

	break_loop_detected = 0;
	packet_count = 0;
	printf("et = %d\n", et);
}


