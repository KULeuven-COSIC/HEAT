#include<stdio.h>
#include<stdint.h>
#include <cstdlib>
#include<time.h>
#include<gmp.h>
//#include<omp.h>
#include<string.h>
#include<stdint.h>

#define THREADS 40		// for parallel processing. this is not important
#define NUM_PRIME 6		// Numper of plaintext modulus for q=q0*q1*..*q5
#define NUM_PRIME_EXT 13	// Numper of plaintext modulus for Q=q0*q1*...*q12; Q>4096*q^2
#define t 33			// plaintext modulus

#include "poly_functions.h"
#include "primitive_root.c"
#include "Gaussian_sampler.c"
#include "basic_ntt_large.c"
#include "homomorphic_functions.c"

//#include "main_hw.c"


void demonstrate_multiplication()
{
	int TEST_COUNTER;
	int i, j, r;

	int message[16][4096];	// 16 messages; each message is a polynomial of 4096 coefficients.
	int m_decrypted[4096];	// Result of homomorphic multiplication is a single message.


	long long int c0[16][NUM_PRIME][4096], c1[16][NUM_PRIME][4096];	// {c0[i],c1[i]} <-- ENC(message[i]); Ciphertext in (mod q_i) space. 

	////// HE Multiplication Results ///////
	long long int cmult0_level0[8][NUM_PRIME_EXT][4096], cmult1_level0[8][NUM_PRIME_EXT][4096];	// Level0: pairewise multiplication gives 8 ciphertexts;
	long long int cmult0_level1[4][NUM_PRIME_EXT][4096], cmult1_level1[4][NUM_PRIME_EXT][4096];	// Level1: pairewise multiplication gives 4 ciphertexts;
	long long int cmult0_level2[2][NUM_PRIME_EXT][4096], cmult1_level2[2][NUM_PRIME_EXT][4096];	// Level2: pairewise multiplication gives 2 ciphertexts;
	long long int cmult0_level3[NUM_PRIME_EXT][4096], cmult1_level3[NUM_PRIME_EXT][4096];		// Level3: pairewise multiplication gives 1 ciphertext;

	
	long long int plaintext_mul_result;

	srand(1234);

	// Now 100 Level 4 HE_MULT tests are done
	for(TEST_COUNTER=0; TEST_COUNTER<100; TEST_COUNTER++)
	{

		/////////////////////////////// Initialize input messages ////////////////////////////////////////
		do{
			for(i=0; i<16; i++)
			{
				do{
				r = rand();
				r = mod33(r);
				message[i][0] = r;		// The message is the x^0 coefficient of the polynomial;
				}while(r==0);			// does not allow 0 to appear in the plaintext; because then result will be 0;
			}
				
			r = 1;
			for(i=0; i<16; i++)
			r = mod33(r*message[i][0]);
		}while(r==0);
		// The above process ensures that the multiplication of the 16 messages do not result in 0 in (mod 33).
	

		for(i=0; i<16; i++)
		{
			for(j=1; j<4096; j++)
			{
				message[i][j] = 0;	// Other coefficients are 0;
			}
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////



		//printf("Enc starts\n");
		for(i=0; i<16; i++)
		FV_enc_q(message[i], c0[i], c1[i]);
		//printf("Enc done\n");
	
		//////////////////////////////////////////////////////////////////////////////////////////////////
		//printf("HE Multiplication starts\n");
		// Level 0 produces 8 ciphertexts
		for(i=0; i<8; i++)						
		{
			FV_mul(c0[2*i], c1[2*i], c0[2*i+1], c1[2*i+1], cmult0_level0[i], cmult1_level0[i]);
			//HE_MUL_HW(c0[2*i], c1[2*i], c0[2*i+1], c1[2*i+1], cmult0_level0[i], cmult1_level0[i]);
		}
		//printf("Level 0 done\n");
		// Level 1 produces 4 ciphertexts
		for(i=0; i<4; i++)						
		{
			//FV_mul(cmult0_level0[2*i], cmult1_level0[2*i], cmult0_level0[2*i+1], cmult1_level0[2*i+1], cmult0_level1[i], cmult1_level1[i]);
			HE_MUL_HW(cmult0_level0[2*i], cmult1_level0[2*i], cmult0_level0[2*i+1], cmult1_level0[2*i+1], cmult0_level1[i], cmult1_level1[i]);
		}
		//printf("Level 1 done\n");
		// Level 2 produces 2 ciphertexts
		for(i=0; i<2; i++)
		{
			//FV_mul(cmult0_level1[2*i], cmult1_level1[2*i], cmult0_level1[2*i+1], cmult1_level1[2*i+1], cmult0_level2[i], cmult1_level2[i]);
			HE_MUL_HW(cmult0_level1[2*i], cmult1_level1[2*i], cmult0_level1[2*i+1], cmult1_level1[2*i+1], cmult0_level2[i], cmult1_level2[i]);
		}
		//printf("Level 2 done\n");

		// Level3 produces 1 ciphertext
		//FV_mul(cmult0_level2[0], cmult1_level2[0], cmult0_level2[1], cmult1_level2[1], cmult0_level3, cmult1_level3);
		HE_MUL_HW(cmult0_level2[0], cmult1_level2[0], cmult0_level2[1], cmult1_level2[1], cmult0_level3, cmult1_level3);
		//printf("Level 3 done\n");

		/////////////////////////////////////////////////////////////////////////////////////////////////
		// Decrypt homomorphic multiplication result
		FV_dec_q(m_decrypted, cmult0_level3, cmult1_level3);	// Result in the coefficient of x^0;


		// Verify correctness: multiplication in the plaintext domain 
		plaintext_mul_result = 1;
		for(i=0; i<16; i++)
		{
			plaintext_mul_result = mod33(plaintext_mul_result * message[i][0]);
		}

		printf("TEST_COUNTER=%d : ", TEST_COUNTER);		
		if(m_decrypted[0] == plaintext_mul_result) printf("Success\n");
		else printf("Failure\n");
		printf("plaintext_mul_result=%ld homomorphic_result=%ld\n", plaintext_mul_result, m_decrypted[0]);
	}			
}

/*
void print_ciphertext(long long int c[][4096], char filename[])
{
	int i, j;
	FILE *fp;

	fp = fopen(filename, "w");
	for(i=0; i<NUM_PRIME; i++)
	{	
		for(j=0; j<1024; j++)
		{
			fprintf(fp, "%lu %lu\n", c[i][j], c[i][j+2048]);
		}
		for(j=0; j<1024; j++)
		{
			fprintf(fp, "%lu %lu\n", c[i][j+1024], c[i][j+1024+2048]);
		}		
	}
	fclose(fp);
}
*/

void print_ciphertext(long long int c[][4096], char filename[])
{
	int i, j;
	FILE *fp;

	fp = fopen(filename, "w");
	for(i=0; i<NUM_PRIME; i++)
	{	
		for(j=0; j<4096; j++)
		{
			//printf("%lu %lu\n", c[i][2*j], c[i][2*j+1]);
			//fprintf(fp, "i = %d\n", j);	
			fprintf(fp, "%lu\n", c[i][j]);
		}
	}
	fclose(fp);
}


void demonstrate_1L_multiplication()
{
	int TEST_COUNTER;
	int i, j, r;

	char fname[100];	// file name to write ciphertext
	int message[16][4096];	// 16 messages; each message is a polynomial of 4096 coefficients.
	int m_decrypted[4096];	// Result of homomorphic multiplication is a single message.


	long long int c0[16][NUM_PRIME][4096], c1[16][NUM_PRIME][4096];	// {c0[i],c1[i]} <-- ENC(message[i]); Ciphertext in (mod q_i) space. 

	////// HE Multiplication Results ///////
	long long int cmult0_level0[8][NUM_PRIME_EXT][4096], cmult1_level0[8][NUM_PRIME_EXT][4096];	// Level0: pairewise multiplication gives 8 ciphertexts;
	long long int cmult0_level1[4][NUM_PRIME_EXT][4096], cmult1_level1[4][NUM_PRIME_EXT][4096];	// Level1: pairewise multiplication gives 4 ciphertexts;
	long long int cmult0_level2[2][NUM_PRIME_EXT][4096], cmult1_level2[2][NUM_PRIME_EXT][4096];	// Level2: pairewise multiplication gives 2 ciphertexts;
	long long int cmult0_level3[NUM_PRIME_EXT][4096], cmult1_level3[NUM_PRIME_EXT][4096];		// Level3: pairewise multiplication gives 1 ciphertext;

	
	long long int plaintext_mul_result;

	srand(1234);

	// Now 100 Level 1 HE_MULT tests are done
	for(TEST_COUNTER=0; TEST_COUNTER<1; TEST_COUNTER++)
	{

		/////////////////////////////// Initialize input messages ////////////////////////////////////////
		do{
			for(i=0; i<2; i++)
			{
				do{
				r = rand();
				r = mod33(r);
				message[i][0] = r;		// The message is the x^0 coefficient of the polynomial;
				}while(r==0);			// does not allow 0 to appear in the plaintext; because then result will be 0;
			}
				
			r = 1;
			for(i=0; i<2; i++)
			r = mod33(r*message[i][0]);
		}while(r==0);
		// The above process ensures that the multiplication of the 2 messages do not result in 0 in (mod 33).
	

		for(i=0; i<2; i++)
		{
			for(j=1; j<4096; j++)
			{
				message[i][j] = 0;	// Other coefficients are 0;
			}
		}
		///////////////////////////////////////////////////////////////////////////////////////////////////



		//printf("Enc starts\n");
		for(i=0; i<2; i++)
		FV_enc_q(message[i], c0[i], c1[i]);
		//printf("Enc done\n");
	
		strcpy(fname, "c0_0");
		print_ciphertext(c0[0], fname);
		strcpy(fname, "c0_1");
		print_ciphertext(c1[0], fname);
		strcpy(fname, "c1_0");
		print_ciphertext(c0[1], fname);
		strcpy(fname, "c1_1");
		print_ciphertext(c1[1], fname);

		//send_byte_array(reset_array);
		//////////////////////////////////////////////////////////////////////////////////////////////////
		//printf("HE Multiplication starts\n");
		// Level 0 produces 1 ciphertexts
		for(i=0; i<1; i++)
		{
			FV_mul(c0[2*i], c1[2*i], c0[2*i+1], c1[2*i+1], cmult0_level0[i], cmult1_level0[i]);
			//HE_MUL_HW(c0[2*i], c1[2*i], c0[2*i+1], c1[2*i+1], cmult0_level0[i], cmult1_level0[i]);
		}
		FV_dec_q(m_decrypted, cmult0_level0[0], cmult1_level0[0]);	// Result in the coefficient of x^0;


		/////////////////////////////////////////////////////////////////////////////////////////////////
		// Decrypt homomorphic multiplication result


		// Verify correctness: multiplication in the plaintext domain 
		plaintext_mul_result = 1;
		for(i=0; i<2; i++)
		{
			plaintext_mul_result = mod33(plaintext_mul_result * message[i][0]);
		}

		printf("TEST_COUNTER=%d : ", TEST_COUNTER);		
		if(m_decrypted[0] == plaintext_mul_result) printf("Success\n");
		else {printf("Failure\n"); break;}
		printf("plaintext_mul_result=%ld homomorphic_result=%ld\n", plaintext_mul_result, m_decrypted[0]);
	}			
}




void demonstrate_addition()
{
	int TEST_COUNTER;
	int i, j, r;

	int message[16][4096];	// 16 messages; each message is a polynomial of 4096 coefficients.
	int m_decrypted[4096];	// Result of homomorphic multiplication is a single message.


	long long int c0[16][NUM_PRIME][4096], c1[16][NUM_PRIME][4096];	// {c0[i],c1[i]} <-- ENC(message[i]); Ciphertext in (mod q_i) space. 

	////// HE addition result ///////
	long long int cadd0[NUM_PRIME_EXT][4096], cadd1[NUM_PRIME_EXT][4096];		// Level3: pairewise multiplication gives 1 ciphertext;


	
	long long int plaintext_add_result;



	// Now 100 Level 4 HE_MULT tests are done
	for(TEST_COUNTER=0; TEST_COUNTER<200; TEST_COUNTER++)
	{

		/////////////////////////////// Initialize input messages ////////////////////////////////////////
		
		for(i=0; i<16; i++)
		{
			r = rand();
			r = mod33(r);
			message[i][0] = r;		// The message is the x^0 coefficient of the polynomial;
			for(j=1; j<4096; j++)
			{
				message[i][j] = 0;	// Other coefficients are 0;
			}
		}
				
		///////////////////////////////////////////////////////////////////////////////////////////////////



		//printf("Enc starts\n");
		for(i=0; i<16; i++)
		FV_enc_q(message[i], c0[i], c1[i]);
		//printf("Enc done\n");
	
		//////////////////////////////////////////////////////////////////////////////////////////////////
		//printf("HE cumulative addition starts\n");
		FV_add(c0[0], c1[0], c0[1], c1[1], cadd0, cadd1);
		for(i=2; i<16; i++)
		FV_add(cadd0, cadd1, c0[i], c1[i], cadd0, cadd1);

		/////////////////////////////////////////////////////////////////////////////////////////////////
		// Decrypt homomorphic addition result
		FV_dec_q(m_decrypted, cadd0, cadd1);
		/*
		for(i=4095; i>=0; i--)
		{
			printf("i=%lu %lu \n", i, m_decrypted[i]);
		}
		*/

		// Verify correctness: addition in the plaintext domain 
		plaintext_add_result = 0;
		for(i=0; i<16; i++)
		{
			plaintext_add_result = mod33(plaintext_add_result + message[i][0]);
		}

		printf("TEST_COUNTER=%d : ", TEST_COUNTER);		
		if(m_decrypted[0] == plaintext_add_result) printf("Success\n");
		else printf("Failure\n");
		printf("plaintext_add_result=%ld homomorphic_result=%ld\n", plaintext_add_result, m_decrypted[0]);
	}			
}


main()
{
	
	//main_hw();

	///////////////////////////////// Initialize the System //////////////////////////////////////////
	srand (time(NULL));
	compute_barrett_constants();
	compute_crt_constants();
	creat_primrt_array( );
	compute_pby_t();
	read_keys();
	printf("System initialized\n");
	//////////////////////////////////////////////////////////////////////////////////////////////////

	demonstrate_1L_multiplication();
	//demonstrate_multiplication();
	//demonstrate_addition();

	//close(fd);
	//pcap_close(handle);

}

