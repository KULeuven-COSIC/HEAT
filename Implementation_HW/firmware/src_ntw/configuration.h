#ifndef CONFIG_H
#define CONFIG_H

// 2048 times 60-bit (8-byte) words
// 4096 times 30-bit (4-byte) words
#define POLY_LEN 2048

// One transfer is 1024-bytes
#define DATA_LEN 1024

// All transfers will take 2048 * 8 / 1024 = 16 iterations
//                         4096 * 4 / 1024 = 16
#define TX_ITER_COUNT (POLY_LEN * 8 / DATA_LEN)

#define NUM_OF_PROCESSORS   6

#define APP_SEL_0    		0
#define APP_SEL_1    		1
#define APP_KEY      		2
#define POLYNOMIAL_OFFSET   8
#define POLYNOMIAL_LENGTH   2048

#endif
