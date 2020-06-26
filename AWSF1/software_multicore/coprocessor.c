

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <malloc.h>
#include <unistd.h>

#include <fpga_pci.h>
#include <fpga_mgmt.h>
#include <fpga_dma.h>
#include <utils/lcd.h>

#include "coprocessor.h"
#include "homomorphy.h"
#include "homomorphy_data.h"

// pci_vendor_id and pci_device_id values below are Amazon's
// and avaliable to use for a given FPGA slot.
// Users may replace these with their own if allocated to them by PCI SIG
static uint16_t pci_vendor_id = 0x1D0F;
static uint16_t pci_device_id = 0xF000;
#define SLOT_ID 0

////////////////////////////////////////////////////////////////////////////////

// Peripheral Memory Addresses
#define GPIO_BASE   UINT64_C(0x00000000)
#define BRAM_BASE   UINT64_C(0xC0000000)

static uint64_t core_gpio_addr(uint8_t core, uint64_t offset) {
  return GPIO_BASE+UINT64_C(0x00001000)*core+offset; }

static uint64_t core_bram_addr(uint8_t core, uint64_t offset) {
  return BRAM_BASE+UINT64_C(0x02000000)*core+offset; }

pthread_mutex_t gpio_lock;
pthread_mutex_t bram_lock;

////////////////////////////////////////////////////////////////////////////////

// Pci_bar_handle_t is a handler for an address space
// exposed by one PCI BAR on one of the PCI PFs of the FPGA
pci_bar_handle_t pci_bar_handle_0    = PCI_BAR_HANDLE_INIT;
pci_bar_handle_t pci_bar_handle_pcis = PCI_BAR_HANDLE_INIT;
int write_fd; 
int read_fd;

// use the stdout logger for printing debug information
const struct logger *logger = &logger_stdout;

////////////////////////////////////////////////////////////////////////////////

extern POLYNOMIAL* Ptmp;


int initialise_fpga(void)
{
  int rc;
  int slot_id = SLOT_ID;
  int pf_id   = FPGA_APP_PF;

  // initialize the fpga_mgmt library
  rc = fpga_mgmt_init();
  fail_on(rc, out, "Unable to initialize the fpga_mgmt library");

  // initialize the fpga_pci library
  rc = fpga_pci_init();
  fail_on(rc, out, "Unable to initialize the fpga_pci library");

  rc = check_afi_ready(slot_id);
  fail_on(rc, out, "AFI not ready");

  // Attach to the fpga, with a pci_bar_handle out param
  rc = fpga_pci_attach(slot_id, pf_id, 0, 0, &pci_bar_handle_0);
  fail_on(rc, out, "Unable to attach to the AFI on slot id %d", slot_id);

  rc = fpga_pci_attach(slot_id, pf_id, 4, 0, &pci_bar_handle_pcis);
  fail_on(rc, out, "Unable to attach to the AFI on slot id %d", slot_id);

  // Initialise xdma
  write_fd = -1;
  read_fd = -1;

  write_fd = fpga_dma_open_queue(FPGA_DMA_XDMA, slot_id, 0, false);
  fail_on((rc = (write_fd < 0) ? -1 : 0), out, "Unable to open write dma");

  read_fd = fpga_dma_open_queue(FPGA_DMA_XDMA, slot_id, 0, true);
  fail_on((rc = (read_fd < 0) ? -1 : 0), out, "unable to open read dma");

  return rc;
out:
  return 1;
}

int instruction_send(uint8_t core, INSTRUCTION instruction) {

	uINSTRUCTION uinst;
	uinst.instruction = instruction;

  // printf("Instruction is 0x%08X\n", (uint32_t)(uinst.whole32));

  if (instruction.opcode == SEND_RLK) {
    // printf("Pseudo Instruction 1: Send RLK\n");

    data_send(core,   //core
              (uint64_t*)(&rlk.P[instruction.mod].coeff_pair[0][0]),
              0x7F,   // mb_strobe
              0   ,   // mb_all
              4   );  // memory
  }
  else if (instruction.opcode == RECV_TMP) {
    // printf("Pseudo Instruction 2: Read Intermediate Values\n");

    data_read(core,   //core
              (uint64_t*)(&Ptmp->coeff_pair[0][0]),
              4);
  }
  else if (instruction.opcode == SEND_TMP) {
    // printf("Pseudo Instruction 3: Send Back Intermediate Values\n");

    // Todo: This line should work, instead of the copying handlied below.
    // But DMA data alignment issue does not let.
    // Will try again with the updated AWS shell.
    // data_send((uint64_t*)(&Ptmp->coeff_pair[0][instruction.mod]),
    //           0x3F,   // mb_strobe
    //           1   ,   // mb_all
    //           4   );  // memory

    POLYNOMIAL *P = (POLYNOMIAL*) memalign(
        getpagesize(),
        (POLYNOMIAL_SIZE)*sizeof(uint8_t));

    for(int i=0; i<MEM_DEPTH; i++) {
      P->coeff_pair[i][0] = Ptmp->coeff_pair[i][instruction.mod];
      P->coeff_pair[i][1] = Ptmp->coeff_pair[i][instruction.mod];
      P->coeff_pair[i][2] = Ptmp->coeff_pair[i][instruction.mod];
      P->coeff_pair[i][3] = Ptmp->coeff_pair[i][instruction.mod];
      P->coeff_pair[i][4] = Ptmp->coeff_pair[i][instruction.mod];
      P->coeff_pair[i][5] = Ptmp->coeff_pair[i][instruction.mod];
      P->coeff_pair[i][6] = Ptmp->coeff_pair[i][instruction.mod];
      P->coeff_pair[i][7] = Ptmp->coeff_pair[i][instruction.mod];
    }

    data_send(core,   //core
              (uint64_t*)(&P->coeff_pair[0][0]),
              0x3F,   // mb_strobe
              1   ,   // mb_all
              4   );  // memory

    free(P);

  }
  else {

    int rc;
    pthread_mutex_lock(&gpio_lock);
    rc = fpga_pci_poke( pci_bar_handle_0,
                        core_gpio_addr(core,0),
                        (uint32_t)(uinst.whole32));
    pthread_mutex_unlock(&gpio_lock);

    fail_on(rc, out, "Unable to write to the fpga !");

    return rc;
  }

out:
  return 1;
}

int instruction_check(uint8_t core, uint32_t* value) {
  int rc;

  pthread_mutex_lock(&gpio_lock);
  rc = fpga_pci_peek( pci_bar_handle_0,
                      core_gpio_addr(core, 0),
                      value);
  pthread_mutex_unlock(&gpio_lock);
  fail_on(rc, out, "Unable to read from the fpga !");

  return rc;
out:
  return 1;
}

int data_send(uint8_t core, uint64_t* polynomial, uint8_t mb_strobe, uint8_t mb_all, uint8_t memory) {
  int rc;
  uCONTROL ucontrol;

  pthread_mutex_lock(&bram_lock);

  // Enable CPU memory access
  ucontrol.control = (CONTROL) {.memory        = memory            ,
                                .memory_all    = mb_all            ,
                                .memory_strobe = (mb_strobe & 0x7F),
                                .write_enable  = 1                 ,
                                .cpu_interrupt = 1                 };
  rc = fpga_pci_poke( pci_bar_handle_0,
                      core_gpio_addr(core, 8),
                      (uint32_t)(ucontrol.whole32));
  fail_on(rc, out, "Unable to write to the fpga !");

  // // Write with 64-bit write function
  // int i;
  // uint32_t row    = 2048;
  // uint32_t column = 8;
  // uint32_t* data = (uint32_t*)polynomial;
  // for (i=0; i<row*column*2; i+=2) {
  //   uint64_t value = data[i+1];
  //   value <<= 32;
  //   value |= data[i];
  //   rc = fpga_pci_poke64(pci_bar_handle_pcis, core_bram_addr(core,i*4), value);
  //   fail_on(rc, out, "Unable to read from the fpga !");
  // }

  // Write with DMA
  rc = fpga_dma_burst_write(write_fd,
    (uint8_t*)polynomial,
    POLYNOMIAL_SIZE,
    core_bram_addr(core,0));

  // Disable CPU memory access
  ucontrol.control.cpu_interrupt = 0;
  pthread_mutex_lock(&gpio_lock);
  rc = fpga_pci_poke( pci_bar_handle_0,
                      core_gpio_addr(core, 8),
                      (uint32_t)(ucontrol.whole32));
  pthread_mutex_unlock(&gpio_lock);
  fail_on(rc, out, "Unable to write to the fpga !");


  pthread_mutex_unlock(&bram_unlock);
  return rc;
out:
  return 1;
}

int data_read (uint8_t core, uint64_t* polynomial, uint8_t memory) {
  int rc;
  uCONTROL ucontrol;

  pthread_mutex_lock(&bram_lock);

  // Enable CPU memory access
  ucontrol.control = (CONTROL) {.memory        = memory  ,
                                .memory_all    = 0       ,
                                .memory_strobe = 0x7F    ,
                                .write_enable  = 0       ,
                                .cpu_interrupt = 1       };
  pthread_mutex_lock(&gpio_lock);
  rc = fpga_pci_poke( pci_bar_handle_0,
                      core_gpio_addr(core, 8),
                      (uint32_t)(ucontrol.whole32));
  pthread_mutex_unlock(&gpio_lock);
  fail_on(rc, out, "Unable to write to the fpga !");


  // Read with 64-bit read function
  // int i;
  // uint32_t row    = 2048;
  // uint32_t column = 8;
  // uint32_t* data = (uint32_t*)polynomial;
  // for (i=0; i<row*column*2; i+=2) {
  //   uint64_t value;
  //   rc = fpga_pci_peek64(pci_bar_handle_pcis, core_bram_addr(core,i*4), &value);
  //   fail_on(rc, out, "Unable to read from the fpga !");
  //   data[i] = value;
  //   value >>= 32;
  //   data[i+1] = value;
  // }

  // Read with DMA
  rc = fpga_dma_burst_read(read_fd,
    (uint8_t*)polynomial,
    POLYNOMIAL_SIZE,
    core_bram_addr(core,0));

  // Disable CPU memory access
  ucontrol.control.cpu_interrupt = 0;
  pthread_mutex_lock(&gpio_lock);
  rc = fpga_pci_poke  (pci_bar_handle_0,
                      core_gpio_addr(core, 8),
                      (uint32_t)(ucontrol.whole32));
  pthread_mutex_unlock(&gpio_lock);
  fail_on(rc, out, "Unable to write to the fpga !");

  pthread_mutex_unlock(&bram_lock);
  return rc;
out:
  return 1;
}

int data_check(uint8_t core, uint32_t* value) {
  int rc;

  pthread_mutex_lock(&gpio_lock);
  rc = fpga_pci_peek( pci_bar_handle_0,
                      core_gpio_addr(core, 8),
                      value);
  pthread_mutex_unlock(&gpio_lock);
  fail_on(rc, out, "Unable to read from the fpga !");

  return rc;
out:
  return 1;
}


// Check if the corresponding AFI for hello_world is loaded
int check_afi_ready(int slot_id) {

  struct fpga_mgmt_image_info info = {0};
  int rc;

  // Get local image description, contains status, vendor id, and device id.
  rc = fpga_mgmt_describe_local_image(slot_id, &info,0);
  fail_on(rc, out, "Unable to get AFI information from slot %d."
                   "Are you running as root?", slot_id);

  // Check to see if the slot is ready
  if (info.status != FPGA_STATUS_LOADED) {
    rc = 1;
    fail_on(rc, out, "AFI in Slot %d is not in READY state !", slot_id);
  }

  printf("AFI PCI  Vendor ID: 0x%x, Device ID 0x%x\n",
    info.spec.map[FPGA_APP_PF].vendor_id,
    info.spec.map[FPGA_APP_PF].device_id);

  // Confirm that the AFI that we expect is in fact loaded
  if (info.spec.map[FPGA_APP_PF].vendor_id != pci_vendor_id ||
    info.spec.map[FPGA_APP_PF].device_id != pci_device_id) {

    printf("AFI does not show expected PCI vendor id and device ID."
           "If the AFI was just loaded, it might need a rescan."
           "Rescanning now.\n");

    rc = fpga_pci_rescan_slot_app_pfs(slot_id);
    fail_on(rc, out, "Unable to update PF for slot %d",slot_id);

    // Get local image description, contains status, vendor id, and device id.
    rc = fpga_mgmt_describe_local_image(slot_id, &info, 0);
    fail_on(rc, out, "Unable to get AFI information from slot %d",slot_id);

    printf("AFI PCI  Vendor ID: 0x%x, Device ID 0x%x\n",
            info.spec.map[FPGA_APP_PF].vendor_id,
            info.spec.map[FPGA_APP_PF].device_id);

    // Confirm that the AFI that we expect is in fact loaded after rescan
    if (info.spec.map[FPGA_APP_PF].vendor_id != pci_vendor_id ||
        info.spec.map[FPGA_APP_PF].device_id != pci_device_id) {

      rc = 1;
      fail_on(rc, out, "The PCI vendor id and device of the loaded AFI"
                       "are not the expected values.");
    }
  }

  return rc;

out:
  return 1;
}