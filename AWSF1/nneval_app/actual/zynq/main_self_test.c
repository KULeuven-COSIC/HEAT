#define THREADS 4
#define GENOMIC_STRING_LENGTH 16
#define TABLE_CONTENT_SIZE GENOMIC_STRING_LENGTH*8

int IMPLEMENTATION_TYPE;
int TABLE_SIZE = 1024;

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
#include<omp.h>

#include "global_variables.c"
#include "other_functions.c"

#include "poly_functions.h"
#include "Gaussian_sampler.c"
#include "basic_ntt_large.c"
#include "homomorphic_functions.c"
#include "fv_enc_dec.c"
#include "homomorphic_comparison_modified.c"
#include "genomic_table/table.c"



void convert_from_one_to_two_poly(mpz_t c00[][1024], long long int c00_0[][512], long long int c00_1[][512], int length)
{
	int i, j;

	for(i=0; i<length; i++)
	{
		for(j=0; j<512; j++)
		{
			c00_0[i][j] = mpz_get_ui(c00[i][j]); 
			c00_1[i][j] = mpz_get_ui(c00[i][j+512]); 
		}
	}
}		

void convert_from_two_to_one_poly(long long int c00_0[][512], long long int c00_1[][512], mpz_t c00[][1024], int length)
{
	int i, j;

	for(i=0; i<length; i++)
	{
		for(j=0; j<512; j++)
		{
			mpz_set_ui(c00[i][j], c00_0[i][j]);
			mpz_set_ui(c00[i][j+512], c00_1[i][j]);
		}
	}
}

void print_genomic_string(unsigned char genomic_string[])
{
	int i;
	for(i=0; i<GENOMIC_STRING_LENGTH; i++)
	printf("%c", genomic_string[i]);
	printf("\n");	
}	
	
// compile gcc -w -fopenmp  main.c -lpcap -lgmp -o hw
main()
{
	FILE *fp;
	int COUNTER;
	int i, j, r, int_eqv;
	int search_keyword, search_keyword_ones_complement;

	struct plaintext_keyword ptext0;
	struct encrypted_keyword enc_keyword;
	struct encrypted_data enc_search_result;
	unsigned char genomic_string[GENOMIC_STRING_LENGTH], decoded_genomic_string[GENOMIC_STRING_LENGTH];

	IMPLEMENTATION_TYPE = 0; // 0 for HW recryption box; 1 for SW recryption box
	
	printf("Starting ...\n"); 
	compute_barrett_constants();
	compute_crt_constants();
	creat_primrt_array();
	read_keys();
	read_keys1(sk_0, sk_1, pk0_0, pk0_1, pk1_0, pk1_1);

	ptext0=init_keyword(ptext0);  
	ptext0.bits[1][0]=1; ptext0.bits[0][0]=0; 

	FV_enc_q(ptext0.bits[0], encryption_of_bit_zero.c0, encryption_of_bit_zero.c1);
	FV_enc_q(ptext0.bits[1], encryption_of_bit_one.c0, encryption_of_bit_one.c1);
	
	srand (time(NULL));


	// activate the comm port before the computation
	unsigned char reset_array[4][6+128*10];
	open_pcap_ethport();		// open ethernet port
	open_udp_ethport();		// open udp port
	poly2byte_reset(reset_array);
	// send reset frame
	send_byte_array(reset_array);

	init_keyword(ptext0);  

	printf("System Init done ... \n");


	int ERR_COUNT=0;
	int continue_loop=200;
	while(continue_loop>0)
	{	
		printf("Loop iteration = %d\n", continue_loop);
		printf("Enter plaintext search keyword (number between 0-1023):");
		//scanf("%d", &search_keyword);
		search_keyword = random()%1023;

		search_keyword_ones_complement = search_keyword ^ 1023;
		for(i=0; i<10; i++)
		{
			ptext0.bits[i][0] = (search_keyword_ones_complement>>i)%2;
		}

		enc_keyword = encrypt_keyword(ptext0, enc_keyword);

		enc_search_result = homomorphic_search(enc_keyword);	// Client sends encrypted search query to the cloud 

		decrypt_data(enc_search_result, decoded_genomic_string);	

		print_genomic_string(decoded_genomic_string);	
		
		// for correctness checking
		table(search_keyword, genomic_string);		
		print_genomic_string(genomic_string);	

		for(i=0; i<GENOMIC_STRING_LENGTH; i++)
		{
			if(genomic_string[i] != decoded_genomic_string[i]) {printf("error\n"); ERR_COUNT++;}		
		}		
			
	
		//printf("continue another search [1/0]: \n");
		//scanf("%d", &continue_loop);
		continue_loop--;
	}
	printf("ERR_COUNT=%d\n", ERR_COUNT);
	close(fd);
	pcap_close(handle);

	
}


