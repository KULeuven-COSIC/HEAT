#include "homomorphy.h"
#include "coprocessor.c"
#include "homomorphy_code.h"

#include <unistd.h>
#include <malloc.h>
#include <time.h>

POLYNOMIAL* Ptmp;

// #define TIMING

void multiply (CIPHERTEXT ct_C, CIPHERTEXT ct_A, CIPHERTEXT ct_B) {

#ifdef TIMING
  struct timespec tstart={0,0}, tend={0,0};    
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  //                                               mb_strobe, mb_all, memory
  data_send((uint64_t*)(&ct_A.A->coeff_pair[0][0]), 0x7F,      0,      1);
  data_send((uint64_t*)(&ct_A.B->coeff_pair[0][0]), 0x7F,      0,      2);
  data_send((uint64_t*)(&ct_B.A->coeff_pair[0][0]), 0x7F,      0,      3);
  data_send((uint64_t*)(&ct_B.B->coeff_pair[0][0]), 0x7F,      0,      4);

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Sending inputs took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

////////////////////////////////////////////////////////////////////////////////

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  Ptmp = (POLYNOMIAL*) memalign(
    getpagesize(),
    (POLYNOMIAL_SIZE)*sizeof(uint8_t));

  int i=0;
  for (i=0; i<MULTIPLY_CODE_LEN; i++) {

    instruction_send(multiply_code[i]);

    // Wait for instruction's completion
    if (multiply_code[i].opcode != 0 &&
        multiply_code[i].opcode != SEND_RLK &&
        multiply_code[i].opcode != RECV_TMP &&
        multiply_code[i].opcode != SEND_TMP ) 
    {
      uint32_t state;
      do {
        instruction_check(&state);
      } while (state != 1);
    }

    instruction_send(zero);
  }

  free(Ptmp);

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Computation took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

////////////////////////////////////////////////////////////////////////////////

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  data_read((uint64_t*)(&ct_C.A->coeff_pair[0][0]), 1);
  data_read((uint64_t*)(&ct_C.B->coeff_pair[0][0]), 5);

#ifdef TIMING      
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Receiving outputs took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

}



void add (CIPHERTEXT ct_C, CIPHERTEXT ct_A, CIPHERTEXT ct_B) {

#ifdef TIMING
  struct timespec tstart={0,0}, tend={0,0};    
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  //                                                mb_strobe, mb_all, memory
  data_send((uint64_t*)(&ct_A.A->coeff_pair[0][0]), 0x7F,      0,      1);
  data_send((uint64_t*)(&ct_A.B->coeff_pair[0][0]), 0x7F,      0,      2);
  data_send((uint64_t*)(&ct_B.A->coeff_pair[0][0]), 0x7F,      0,      3);
  data_send((uint64_t*)(&ct_B.B->coeff_pair[0][0]), 0x7F,      0,      4);

#ifdef TIMING  
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Sending inputs took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

////////////////////////////////////////////////////////////////////////////////

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  INSTRUCTION inst_Add_A, inst_Add_B;

  inst_Add_A = (INSTRUCTION) {.opcode    = ADD  ,
                              .mod       = 0    ,
                              .readMem0  = 1    ,
                              .readMem1  = 3    ,
                              .writeMem0 = 1    ,
                              .writeMem1 = 0    };

  inst_Add_B = (INSTRUCTION) {.opcode    = ADD  ,
                              .mod       = 0    ,
                              .readMem0  = 2    ,
                              .readMem1  = 4    ,
                              .writeMem0 = 2    ,
                              .writeMem1 = 0    };

  instruction_send(inst_Add_A);
  instruction_send(inst_Add_B);

#ifdef TIMING      
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Computation took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

////////////////////////////////////////////////////////////////////////////////

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  data_read((uint64_t*)(&ct_C.A->coeff_pair[0][0]), 1);
  data_read((uint64_t*)(&ct_C.B->coeff_pair[0][0]), 5);

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Receiving outputs took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

}

////////////////////////////////////////////////////////////////////////////////

void convert_array_to_polynomial(POLYNOMIAL* P, long long int array[][4096]) {
  
  int index, memblock;

  for(memblock=0; memblock<NUM_PRIME; memblock++) {
		for(index=0; index<2048; index++) {
			P->coeff_pair[index][memblock]  =  array[memblock][index];
			P->coeff_pair[index][memblock] |= (array[memblock][index+2048] << 30);
		}
	}

  for(memblock=NUM_PRIME; memblock<MEM_BLK_CNT; memblock++) {
    for(index=0; index<2048; index++) {
      P->coeff_pair[index][memblock] = 0;
    }
  }


}

void convert_polynomial_to_array(POLYNOMIAL* P, long long int array[][4096]) {
  
  int index, memblock;

  for(memblock=0; memblock<NUM_PRIME; memblock++) {
		for(index=0; index<2048; index++) {
			array[memblock][index     ] =  P->coeff_pair[index][memblock]      & 0x3FFFFFFF;
      array[memblock][index+2048] = (P->coeff_pair[index][memblock]>>30) & 0x3FFFFFFF;
		}
	}
}

void zero_polynomial(POLYNOMIAL* P) {  
  int index, memblock;

  for(memblock=0; memblock<MEM_BLK_CNT; memblock++) {
		for(index=0; index<2048; index++) {
			P->coeff_pair[index][memblock] = 0;
		}
	}
}

////////////////////////////////////////////////////////////////////////////////

#define BLACK   "\033[0;30m"     
#define DGRAY   "\033[1;30m"
#define LGRAY   "\033[0;37m"     
#define WHITE   "\033[1;37m"
#define RED     "\033[0;31m"     
#define LRED    "\033[1;31m"
#define GREEN   "\033[0;32m"     
#define LGREEN  "\033[1;32m"
#define ORANGE 	"\033[0;33m"     
#define YELLOW  "\033[1;33m"
#define BLUE    "\033[0;34m"     
#define LBLUE   "\033[1;34m"
#define PURPLE  "\033[0;35m"     
#define LPURPLE "\033[1;35m"
#define CYAN    "\033[0;36m"     
#define LCYAN   "\033[1;36m"
#define NC      "\033[0m"

#define COL         YELLOW 
#define COL_INDEX   RED 
#define ROW_INDEX   PURPLE 

void printPolynomial(uint64_t* address, int length) {
  int i;

  uint32_t* addr_32 = (uint32_t*)address;

  printf("\n     " ); printf(COL"|"         COL_INDEX);
  printf("512     "); printf(COL"|        |"COL_INDEX);
  printf("448     "); printf(COL"|        |"COL_INDEX);
  printf("384     "); printf(COL"|        |"COL_INDEX);
  printf("320     "); printf(COL"|        |"COL_INDEX);
  printf("256     "); printf(COL"|        |"COL_INDEX);
  printf("192     "); printf(COL"|        |"COL_INDEX);
  printf("128     "); printf(COL"|        |"COL_INDEX);
  printf("64      "); printf(COL"|       "  COL_INDEX);
                      printf("0");
                      printf(COL"|\n"NC);

  for (i=0; i<length; i++) {    
    printf(ROW_INDEX"%04d "NC, i);
                                                            printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+15],addr_32[i*16+14]); printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+13],addr_32[i*16+12]); printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+11],addr_32[i*16+10]); printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+ 9],addr_32[i*16+ 8]); printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+ 7],addr_32[i*16+ 6]); printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+ 5],addr_32[i*16+ 4]); printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+ 3],addr_32[i*16+ 2]); printf(COL"|"NC);
    printf("%.8X %.8X", addr_32[i*16+ 1],addr_32[i*16+ 0]); printf(COL"|\n"NC);
  }
  
  printf("     "   ); printf(COL"|"         COL_INDEX);
  printf("512     "); printf(COL"|        |"COL_INDEX);
  printf("448     "); printf(COL"|        |"COL_INDEX);
  printf("384     "); printf(COL"|        |"COL_INDEX);
  printf("320     "); printf(COL"|        |"COL_INDEX);
  printf("256     "); printf(COL"|        |"COL_INDEX);
  printf("192     "); printf(COL"|        |"COL_INDEX);
  printf("128     "); printf(COL"|        |"COL_INDEX);
  printf("64      "); printf(COL"|       "  COL_INDEX);
                      printf("0");
                      printf(COL"|\n"NC);

  printf(NC); 

}
