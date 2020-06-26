#include "coprocessor.h"
#include "homomorphy.h"
#include "homomorphy_data.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

int initialise_fpga(void) {
  return 1;
}

int instruction_send(uint8_t core, INSTRUCTION instruction) {
  
	uINSTRUCTION uinst;
	uinst.instruction = instruction;
  
  printf("Instruction is 0x%08X\n", (uint32_t)(uinst.whole32));

  return 1;
}


int instruction_check(uint8_t core, uint32_t* value) {
  return 1;
}

int data_send(uint8_t core, uint64_t* polynomial, uint8_t mb_strobe, uint8_t mb_all, uint8_t memory) {
  
  uCONTROL ucontrol;

  // Enable CPU memory access
  ucontrol.control = (CONTROL) {.memory        = memory            ,
                                .memory_all    = mb_all            ,
                                .memory_strobe = (mb_strobe & 0x7F),
                                .write_enable  = 1                 ,
                                .cpu_interrupt = 1                 };

  printf("Enable  Command is 0x%08X\n", (uint32_t)(ucontrol.whole32));

  ucontrol.control.cpu_interrupt = 0;

  printf("Disable Command is 0x%08X\n", (uint32_t)(ucontrol.whole32));

  return 1;
}

int data_read (uint8_t core, uint64_t* polynomial, uint8_t memory) {
  
  uCONTROL ucontrol;

  ucontrol.control = (CONTROL) {.memory        = memory  ,
                                .memory_all    = 0       ,
                                .memory_strobe = 0x7F    ,
                                .write_enable  = 0       ,
                                .cpu_interrupt = 1       };

  printf("Enable  Command is 0x%08X\n", (uint32_t)(ucontrol.whole32));

  ucontrol.control.cpu_interrupt = 0;

  printf("Disable Command is 0x%08X\n", (uint32_t)(ucontrol.whole32));

  return 1;
}

int data_check(uint8_t core, uint32_t* value) {
  return 1;
}

int check_afi_ready(int slot_id) {
  return 1;
}