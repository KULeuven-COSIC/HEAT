#ifndef HE_COPROCESSOR_H
#define HE_COPROCESSOR_H

#include <stdint.h>

////////////////////////////////////////

typedef struct INSTRUCTION
{
    uint8_t opcode    : 8;
    uint8_t mod       : 8;
    uint8_t readMem0  : 4;
    uint8_t readMem1  : 4;
    uint8_t writeMem0 : 4;
    uint8_t writeMem1 : 4;
} INSTRUCTION;

typedef union
{
	uint32_t	whole32;
	INSTRUCTION	instruction;
} uINSTRUCTION;

#define REARRANGE 16
#define NTT       17
#define INTT      18
#define MULTIPLY  19
#define ADD       20

#define LIFT_5    5
#define LIFT_6    6
#define LIFT_7    7

#define SEND_RLK  1
#define RECV_TMP  2
#define SEND_TMP  3

////////////////////////////////////////

typedef struct CONTROL
{
    uint8_t cpu_interrupt : 8;
    uint8_t write_enable  : 8;
    uint8_t memory_strobe : 7;
    uint8_t memory_all    : 1;
    uint8_t memory        : 8;
} CONTROL;

typedef union
{
	uint32_t	whole32;
	CONTROL	    control;
} uCONTROL;

////////////////////////////////////////

int initialise_fpga(void);

int instruction_send(INSTRUCTION instruction);
int instruction_check(uint32_t* value);

int data_send (uint64_t* polynomial, uint8_t mb_strobe, uint8_t mb_all, uint8_t memory);
int data_read (uint64_t* polynomial, uint8_t memory);
int data_check(uint32_t* value);

int check_afi_ready(int slot);

#endif // HE_COPROCESSOR_H