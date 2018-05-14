#ifndef DATA_H
#define DATA_H

#include <stdint.h>
#include "configuration.h"

typedef struct IN_CIPHERTEXT
{
    uint64_t c00[NUM_OF_PROCESSORS][POLY_LEN];
    uint64_t c01[NUM_OF_PROCESSORS][POLY_LEN];
    uint64_t c10[NUM_OF_PROCESSORS][POLY_LEN];
    uint64_t c11[NUM_OF_PROCESSORS][POLY_LEN];
} IN_CIPHERTEXT;

typedef struct OUT_CIPHERTEXT
{
    uint64_t c0[NUM_OF_PROCESSORS][POLY_LEN];
    uint64_t c1[NUM_OF_PROCESSORS][POLY_LEN];
} OUT_CIPHERTEXT;

#endif