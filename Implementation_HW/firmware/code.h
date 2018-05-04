#ifndef CODE_H
#define CODE_H

#include <stdint.h>

#define CODE_LEN 179

// HALT instruction code is 255.

// addr1 = rdM0 + (rdM1<<4);
// addr2 = wtM0 + (wtM1<<4);

typedef struct INSTRUCTION
{
    uint8_t ins     : 8;
    uint8_t addr1   : 8;
    uint8_t addr2   : 8;
    uint8_t proc    : 3;
    uint8_t mem     : 4;
    uint8_t mod     : 1;
} INSTRUCTION;

typedef union
{
	uint32_t	whole32;
	INSTRUCTION	instruction;
} uINSTRUCTION;


#endif
