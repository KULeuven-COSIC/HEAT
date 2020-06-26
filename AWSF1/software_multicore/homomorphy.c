#include "homomorphy.h"
#include "homomorphy_code.h"

#include <unistd.h>
#include <malloc.h>
#include <time.h>
#include <pthread.h>   

#include <stdio.h>
#include <stdint.h>
#include <string.h>     // memcpy
#include <sys/mman.h>   // mmap
#include <unistd.h>     // _SC_PAGE_SIZE

POLYNOMIAL* Ptmp;

// #define TIMING

void multiply (uint8_t core, CIPHERTEXT ct_C, CIPHERTEXT ct_A, CIPHERTEXT ct_B) {

#ifdef TIMING
  struct timespec tstart={0,0}, tend={0,0};    
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  //                                                   mb_strobe, mb_all, memory
  data_send(core,(uint64_t*)(&ct_A.A.coeff_pair[0][0]), 0x7F,      0,      1);
  data_send(core,(uint64_t*)(&ct_A.B.coeff_pair[0][0]), 0x7F,      0,      2);
  data_send(core,(uint64_t*)(&ct_B.A.coeff_pair[0][0]), 0x7F,      0,      3);
  data_send(core,(uint64_t*)(&ct_B.B.coeff_pair[0][0]), 0x7F,      0,      4);

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

    instruction_send(core,multiply_code[i]);

    // Wait for instruction's completion
    if (multiply_code[i].opcode != 0 &&
        multiply_code[i].opcode != SEND_RLK &&
        multiply_code[i].opcode != RECV_TMP &&
        multiply_code[i].opcode != SEND_TMP ) 
    {
      uint32_t state;
      do {
        instruction_check(core,&state);
      } while (state != 1);
    }

    instruction_send(core,zero);
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

  data_read(core,(uint64_t*)(&ct_C.A.coeff_pair[0][0]), 1);
  data_read(core,(uint64_t*)(&ct_C.B.coeff_pair[0][0]), 5);
      
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Receiving outputs took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

}


void add (uint8_t core, CIPHERTEXT ct_C, CIPHERTEXT ct_A, CIPHERTEXT ct_B) {

#ifdef TIMING
  struct timespec tstart={0,0}, tend={0,0};    
  clock_gettime(CLOCK_MONOTONIC, &tstart);
#endif

  //                                                   mb_strobe, mb_all, memory
  data_send(core,(uint64_t*)(&ct_A.A.coeff_pair[0][0]), 0x7F,      0,      1);
  data_send(core,(uint64_t*)(&ct_A.B.coeff_pair[0][0]), 0x7F,      0,      2);
  data_send(core,(uint64_t*)(&ct_B.A.coeff_pair[0][0]), 0x7F,      0,      3);
  data_send(core,(uint64_t*)(&ct_B.B.coeff_pair[0][0]), 0x7F,      0,      4);

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

  instruction_send(core,inst_Add_A);
  instruction_send(core,inst_Add_B);

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


  data_read(core,(uint64_t*)(&ct_C.A.coeff_pair[0][0]), 1);
  data_read(core,(uint64_t*)(&ct_C.B.coeff_pair[0][0]), 2);

#ifdef TIMING
  clock_gettime(CLOCK_MONOTONIC, &tend);
  printf("Receiving outputs took about %.5f seconds\n",
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));
#endif

}


void printPolynomial(uint64_t* address, int length) {
  int i;

  uint32_t* addr_32 = (uint32_t*)address;

  printf("    |512     |        |448     |        |"\
              "384     |        |320     |        |"\
              "256     |        |192     |        |"\
              "128     |        |64      |       0|\n");
  for (i=0; i<length; i++) {
    
    printf("%03d |%.8X %.8X|%.8X %.8X|"\
                 "%.8X %.8X|%.8X %.8X|"\
                 "%.8X %.8X|%.8X %.8X|"\
                 "%.8X %.8X|%.8X %.8X|\n",
      i,
      addr_32[i*16+15],  addr_32[i*16+14],
      addr_32[i*16+13],  addr_32[i*16+12],
      addr_32[i*16+11],  addr_32[i*16+10],
      addr_32[i*16+ 9],  addr_32[i*16+ 8],      
      addr_32[i*16+ 7],  addr_32[i*16+ 6],
      addr_32[i*16+ 5],  addr_32[i*16+ 4],
      addr_32[i*16+ 3],  addr_32[i*16+ 2],
      addr_32[i*16+ 1],  addr_32[i*16+ 0]
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

void *thread_multiply(void *arg) 
{ 
  uint8_t core = *((uint8_t*) arg);
  
  struct timespec tstart={0,0}, tend={0,0};    
  // CIPHERTEXT ct_result;

  int test = 0;
  while(test<20) {
    printf("Core %d: Printing from Thread\n", core); 

    clock_gettime(CLOCK_MONOTONIC, &tstart);

    sleep(1); 
    // multiply(CORE, ct_result, ct_0, ct_1);

    clock_gettime(CLOCK_MONOTONIC, &tend);
    printf("Core %d: Multiplication took about %.5f seconds\n",
        core,
        ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - 
        ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec));

    test++;
  }
    return NULL; 
} 

void multi_core_multiplication_test(void) {
  pthread_t thread_id; 
  printf("Threads - starting\n"); 

  uint8_t core0_arg = 0;
  uint8_t core1_arg = 1;

  pthread_create(&thread_id, NULL, thread_multiply, &core0_arg);
  pthread_create(&thread_id, NULL, thread_multiply, &core1_arg);

  pthread_join(thread_id, NULL); 
  
  printf("Threads - end\n"); 
}

////////////////////////////////////////////////////////////////////////////////
