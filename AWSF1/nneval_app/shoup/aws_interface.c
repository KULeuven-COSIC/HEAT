#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <malloc.h>

#include "aws/homomorphy.c"

// #define HW_TIMING

void HW_INIT_HW() {
	initialise_fpga();
}


void HE_COMPARE(long long int c0[][4096], 
				long long int c1[][4096]) 
{
	CIPHERTEXT CR;
	CR.A = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));
	CR.B = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));

	convert_array_to_polynomial(CR.A, c0);
	convert_array_to_polynomial(CR.B, c1);
	
	printPolynomial((uint64_t*)(&CR.A), 2048);
	printf("This is the result of FV_mul\r");
	getchar();
}

void HE_MUL_HW(	long long int c00[][4096], 
				long long int c01[][4096], 
				long long int c10[][4096], 
				long long int c11[][4096], 
				long long int c0[][4096], 
				long long int c1[][4096])
{
  

	CIPHERTEXT C0; 
	CIPHERTEXT C1;
	CIPHERTEXT CR;

#ifdef HW_TIMING
struct timespec tstart={0,0}, tend={0,0};   
clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

	C0.A = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));
	C0.B = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));
	C1.A = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));
	C1.B = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));
	CR.A = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));
	CR.B = (POLYNOMIAL*)memalign(getpagesize(),(POLYNOMIAL_SIZE)*sizeof(uint8_t));
	
	convert_array_to_polynomial(C0.A, c00);
	convert_array_to_polynomial(C0.B, c01);
	convert_array_to_polynomial(C1.A, c10);
	convert_array_to_polynomial(C1.B, c11);
	zero_polynomial(CR.A);
	zero_polynomial(CR.B);

#ifdef HW_TIMING
clock_gettime(CLOCK_MONOTONIC, &tend);
printf("Input array manipulations took about %.5f seconds\n",
  ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
  ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));

clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

	multiply(CR, C0, C1);

#ifdef HW_TIMING
clock_gettime(CLOCK_MONOTONIC, &tend);
printf("The Multiplications took about %.5f seconds\n",
  ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
  ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));

clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

	convert_polynomial_to_array(CR.A, c0);
	convert_polynomial_to_array(CR.B, c1);

	free(C0.A);
	free(C0.B);
	free(C1.A);
	free(C1.B);
	free(CR.A);
	free(CR.B);

#ifdef HW_TIMING
clock_gettime(CLOCK_MONOTONIC, &tend);
printf("Result array manipulations took about %.5f seconds\n",
  ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
  ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

}
