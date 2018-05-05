#ifndef HARDWARE_H
#define HARDWARE_H

#include <stdio.h>

#include "code.h"

// 128 x (64-bits) in 32-bit words = 128*64/32 = 256
#define HW_TRANSFER_NUMBER_OF_WORDS (256)


void init_hardware();

void send_inst          (INSTRUCTION instruction); 

void send_inst_raw      (uint8_t instruction, 
                         uint8_t mod_sel, 
                         uint8_t rdM0,
                         uint8_t rdM1,
                         uint8_t wtM0,
                         uint8_t wtM1);

void send_eth_data      (uint32_t bram_address, 
                         uint8_t processor, 
                         uint8_t* data_addr, 
                         uint32_t data_len);

void recv_eth_data      (uint32_t bram_address, 
                         uint8_t processor, 
                         uint8_t* data_addr, 
                         uint32_t data_len);

void send_const_data    (uint32_t bram_address, 
                         uint8_t processor, 
                         uint8_t* data_addr, 
                         uint32_t data_len);

void recv_const_data    (uint32_t bram_address, 
                         uint8_t processor, 
                         uint8_t* data_addr, 
                         uint32_t data_len);

#endif
