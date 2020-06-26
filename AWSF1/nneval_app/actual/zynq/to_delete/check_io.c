/* Example compiler command-line for GCC:
 * gcc -w check_io.c -lpcap -lgmp
 */ 

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include<arpa/inet.h>
#include <sys/socket.h>
#include <pcap.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <unistd.h>
#include <netinet/in.h>
#include <time.h>
#include<gmp.h>
#include "global_variables.c"


#include "poly_functions.h"
/*
#include "Gaussian_sampler.c"
#include "basic_ntt_large.c"
#include "basic_ntt_QL.c"
#include "homomorphic_functions.c"
#include "evaluation_functions.c"
*/
#include "other_functions.c"



	
int main(void)
{


	
	long int COM_COUNTER;
	int total_sync_loss;
	int i;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	srand( time(NULL) );

	// Declaration of Ethernet Frame variables 	
	unsigned char byte_array1[4][6+128*10], byte_array2[4][6+128*10], byte_array3[4][6+128*10], reset_array[4][6+128*10];
	unsigned char byte_array4[4][6+128*10], byte_array5[4][6+128*10];
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	open_pcap_ethport();		// open ethernet port
	open_udp_ethport();		// open udp port
	
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	unsigned long long pk0_0[2][512], pk0_1[2][512], pk1_0[2][512], pk1_1[2][512], sk_0[2][512], sk_1[2][512];
	unsigned long long c0_0[2][512], c0_1[2][512], c1_0[2][512], c1_1[2][512];
	FILE *fp;

	fp = fopen("keys/pk0_0to511ntt_q0", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &pk0_0[0][i], &pk0_1[0][i]);	
	fclose(fp);
	fp = fopen("keys/pk0_0to511ntt_q1", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &pk0_0[1][i], &pk0_1[1][i]);	
	fclose(fp);
	fp = fopen("keys/pk1_0to511ntt_q0", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &pk1_0[0][i], &pk1_1[0][i]);	
	fclose(fp);
	fp = fopen("keys/pk1_0to511ntt_q1", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &pk1_0[1][i], &pk1_1[1][i]);	
	fclose(fp);
	fp = fopen("keys/sk_0to511ntt_q0", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &sk_0[0][i], &sk_1[0][i]);	
	fclose(fp);
	fp = fopen("keys/sk_0to511ntt_q1", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &sk_0[1][i], &sk_1[1][i]);	
	fclose(fp);


	fp = fopen("dump/c0_q0", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &c0_0[0][i], &c0_1[0][i]);	
	fclose(fp);
	fp = fopen("dump/c0_q1", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &c0_0[1][i], &c0_1[1][i]);	
	fclose(fp);
	fp = fopen("dump/c1_q0", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &c1_0[0][i], &c1_1[0][i]);	
	fclose(fp);
	fp = fopen("dump/c1_q1", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%llu %llu", &c1_0[1][i], &c1_1[1][i]);	
	fclose(fp);
//                                                 Computations Start                                                          //

 
	unsigned long long pol0_0[512], pol0_1[512], pol1_0[512], pol1_1[512];
	unsigned long long pol2_0[512], pol2_1[512], pol3_0[512], pol3_1[512];




	poly2byte_reset(reset_array);

// send reset frame
	send_byte_array(reset_array);


COM_COUNTER=1;
while(COM_COUNTER>0)
{
	COM_COUNTER--;	

	poly2byte(sk_0[0], sk_1[0], sk_0[1], sk_1[1], byte_array1);
	poly2byte(pk0_0[0], pk0_1[0], pk0_0[1], pk0_1[1], byte_array2);
	poly2byte(pk1_0[0], pk1_1[0], pk1_0[1], pk1_1[1], byte_array3);
	poly2byte(c0_0[0], c0_1[0], c0_0[1], c0_1[1], byte_array4);
	poly2byte(c1_0[0], c1_1[0], c1_0[1], c1_1[1], byte_array5);

	for(i=0; i<512; i++)
	{
		//printf("ff i=%d %lld %lld %lld %lld \n", i, pol0_0[i], pol0_1[i], pol1_0[i], pol1_1[i]);	
	}

	total_sync_loss = 0;


	unsigned int temp;

// Send the secret key
L1:
	// send sk for M0
	send_byte_array(byte_array1);
	// send pk0 for M1
	send_byte_array(byte_array2);
	// send pk1 for M2
	send_byte_array(byte_array3);
	// send c0 for M3
	send_byte_array(byte_array4);
	// send c1 for M4
	send_byte_array(byte_array5);



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
	byte2poly(pol0_0, pol0_1, pol1_0, pol1_1);

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
	byte2poly(pol2_0, pol2_1, pol3_0, pol3_1);

	for(i=0; i<512; i++)
	{
		printf("%lld %lld %lld %lld \n", pol0_0[i], pol0_1[i], pol1_0[i], pol1_1[i]);	
	}

	for(i=0; i<512; i++)
	{
		printf("%lld %lld %lld %lld \n", pol2_0[i], pol2_1[i], pol3_0[i], pol3_1[i]);	
	}
	break_loop_detected = 0;
	packet_count = 0;
	//printf("total_sync_loss in communication= %d \n", total_sync_loss);
/*
	for(i=0; i<512; i++)
	{
		if(pol2_0[i] != pol0_0[i]) printf("i=%d ERR\n", i);
		if(pol2_1[i] != pol0_1[i]) printf("i=%d ERR\n", i);
		if(pol3_0[i] != pol1_0[i]) printf("i=%d ERR\n", i);
		if(pol3_1[i] != pol1_1[i]) printf("i=%d ERR\n", i);
	}	*/
}
	close(fd);
	pcap_close(handle);

	return 0;
}

