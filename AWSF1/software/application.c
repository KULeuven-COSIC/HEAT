#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <malloc.h>

// #include "utils/lcd.h"
#include <time.h>

#include "homomorphy.h"
#include "coprocessor.h"


#define READ(STR, VAL)    \
    printf("%s: ", STR);  \
    scanf ("%d", &VAL);   \
    if(VAL == -1)			    \
        break;

extern CIPHERTEXT ct_0;
extern CIPHERTEXT ct_1;

void checks() {
  printf("PAGESIZE: %d bytes\n", getpagesize());
  printf("\n\n");
}

int main()
{
  checks();

  initialise_fpga();

  // Allocate a page aligned memory region for a temporary use polynomial
  POLYNOMIAL* PL = (POLYNOMIAL*) memalign(
    getpagesize(),
    POLYNOMIAL_SIZE*sizeof(uint8_t));

  // Start with the application menu

  int choice;
  do {

    printf(                "\n"           \
      "---------------------\n"           \
      "Menu:\n"                           \
      "1 . Zero  polynomial \n"           \
      "2 . Init  polynomial \n"           \
      "3 . Print polynomial \n"           \
      "4 . Write polynomial  - all\n"     \
      "41. Write polynomial  - strobed\n" \
      "5 . Read  polynomial  - all\n"     \
      "51. Read  polynomial  - selected\n"\
      "6 . Write instruction - single\n"  \
      "7.  Multiply\n"                    \
      "8.  Add\n"                         \
      "?. Exit\n\n"                       );
    scanf("%d", &choice);

    if (choice == 1) { // Zero  polynomial

      uint32_t mem_block, mem_address;
      for (mem_block=0; mem_block<MEM_BLK_CNT; mem_block++) {
        for (mem_address=0; mem_address<MEM_DEPTH; mem_address++) {
          PL->coeff_pair[mem_address][mem_block] = 0;
        }
      }
    }
    else

    if (choice == 2) { // Init polynomial

      uint32_t mem_block, mem_address;
      for (mem_block=0; mem_block<MEM_BLK_CNT; mem_block++) {
        for (mem_address=0; mem_address<MEM_DEPTH; mem_address++) {
          PL->coeff_pair[mem_address][mem_block] =
            ((uint64_t)mem_block)<<32 | mem_address;
        }
      }
    }
    else

    if (choice == 3) { // Print polynomial

      printPolynomial((uint64_t*)(&PL->coeff_pair[0][0]), MEM_DEPTH);
    }
    else

    if (choice == 4) { // Write polynomial - all

      uint32_t state;
      data_send((uint64_t*)(&PL->coeff_pair[0][0]), 
                0x7F,   // mb_strobe
                0   ,   // mb_all
                4   );  // memory
      data_check(&state);
      printf(" Mem State: 0x%08X\n", state);
    }
    else

    if (choice == 41) { // Write polynomial - strobed

      uint32_t state;

      int strobe = 0;
      READ("Strobe (in dec)", strobe);

      data_send((uint64_t*)(&PL->coeff_pair[0][0]), 
                strobe,   // mb_strobe
                0     ,   // mb_all
                4     );  // memory
      data_check(&state);
      printf(" Mem State: 0x%08X\n", state);
    }
    else

    if (choice == 5) { // Read polynomial - all

      uint32_t state;
      data_read((uint64_t*)(&PL->coeff_pair[0][0]), 4);
      data_check(&state);
      printf(" Mem State: 0x%08X\n", state);
    }
    else

    if (choice == 51) { // Read polynomial - selected memory

      uint32_t state;

      int memory = 0;
      READ("Strobe (in dec)", memory);

      data_read((uint64_t*)(&PL->coeff_pair[0][0]), memory);
      data_check(&state);
      printf(" Mem State: 0x%08X\n", state);
    }
    else

    if (choice == 6) { // Write instruction - single

      int opcode    =  0;
      int readMem0  =  4;
      int readMem1  =  0;
      int writeMem0 =  4;
      int writeMem1 =  0;

      do {
        READ("Enter instruction code", opcode    );
        READ("Enter read  Mem 0"     , readMem0  );
        READ("Enter read  Mem 1"     , readMem1  );
        READ("Enter write Mem 0"     , writeMem0 );
        READ("Enter write Mem 1"     , writeMem1 );
        printf("\n");

    	  INSTRUCTION inst;

        inst = (INSTRUCTION) {.opcode    = opcode    ,
										          .mod       = 0         ,
                              .readMem0  = readMem0  ,
										          .readMem1  = readMem1  ,
										          .writeMem0 = writeMem0 ,
										          .writeMem1 = writeMem1 };

        instruction_send(inst);

        uint32_t state;
        do {
            instruction_check(&state);
        } while (state != 1);
      } while(0);
    }
    else

    if (choice == 7) { // Multiply with data in "homomorphy_data.h"

      // The result is in ct_result.
      // Instead of implementing a new function to print it,
      // I use the commands 51 and 3 above to check the results.

      CIPHERTEXT ct_result;
      multiply(ct_result, ct_0, ct_1);      
    }
    else

    if (choice == 8) { // Add with data in "homomorphy_data.h"

      // The result is in ct_result.
      // Instead of implementing a new function to print it,
      // I use the commands 51 and 3 above to check the results.

      CIPHERTEXT ct_result;
      add(ct_result, ct_0, ct_1);      
    }
    else 
    
    if (choice == -1) {

      printf("Goodbye\n");
      choice = -1;
    }

  } while(choice!=-1);

  return 0;
}