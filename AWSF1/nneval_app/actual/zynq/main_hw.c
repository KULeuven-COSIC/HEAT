#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <pcap.h>
#include <ctype.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <unistd.h>
#include <netinet/in.h>
#include <time.h>
#include <gmp.h>

unsigned char reset_array[4][6+128*8+8];


#include "global_variables.c"
#include "other_functions.c"
#include "clean_interfacing.c"



// compile gcc -w -fopenmp  main.c -lpcap -lgmp -o hw
void main_hw()
{
	FILE *fp;
	int COUNTER;

	eth_init();

	/*
	printf("Starting ...\n"); 
	poly2byte_reset(reset_array);

	// activate the comm port before the computation
	open_pcap_ethport();		// open ethernet port
	open_udp_ethport();		// open udp port
	sleep(1);

	send_byte_array(reset_array);
	*/
	printf("System Init done ... \n");
	
	/*
	int continue_loop=1;
	//while(continue_loop==1)
	{	
		comm_test_init();
		//comm_test();	
		printf("\n\n[CLIENT] Continue another search [1/0]: \n");
		//scanf("%d", &continue_loop);
	}
	*/
	
}


