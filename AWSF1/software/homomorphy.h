#ifndef HOMOMORPHY_H
#define HOMOMORPHY_H

#include <stdint.h>

// In fact there are 7 blocks. Also the first 6 of them are CPU accessible.
// Pretend as if there are 8 blocks, to have an 512-bit aligment of data words.
#define MEM_BLK_CNT  8

// 2048 times 60-bit (8-byte) words
// 4096 times 30-bit (4-byte) words
#define MEM_DEPTH     2048

// Polynomial size = POLY_LEN x NUM_MEM_BLK x 64 bit
//                       2048 x           8 x  8 bytes
//                                           128 KiB
//                                            32 pages
#define POLYNOMIAL_SIZE 0x20000 // 0x1FFFF // in bytes
#define CIPHERTEXT_SIZE 0x40000 // 0x3FFFE // in bytes

typedef struct POLYNOMIAL {
  uint64_t coeff_pair[MEM_DEPTH][MEM_BLK_CNT];
} POLYNOMIAL;

typedef struct CIPHERTEXT {
  POLYNOMIAL A;
  POLYNOMIAL B;
} CIPHERTEXT;

typedef struct RLK_CONSTANTS {
  POLYNOMIAL P[12];
} RLK_CONSTANTS;

////////////////////////////////////////////////////////////////////////////////

void multiply (CIPHERTEXT ct_C, CIPHERTEXT ct_A, CIPHERTEXT ct_B);
void add      (CIPHERTEXT ct_C, CIPHERTEXT ct_A, CIPHERTEXT ct_B);

////////////////////////////////////////////////////////////////////////////////

void printPolynomial(uint64_t* address, int length);

#endif