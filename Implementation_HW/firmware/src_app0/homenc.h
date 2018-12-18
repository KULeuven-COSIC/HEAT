#ifndef HOMENC_H
#define HOMENC_H

#include "data.h"

void Receive_Inputs_from_PC     (IN_CIPHERTEXT*  ct, int count);
void Write_Inputs_to_FPGA       (IN_CIPHERTEXT*  ct);
void ExecuteCode                (void);
void Read_Outputs_from_FPGA     (OUT_CIPHERTEXT* ct);
void Send_Outputs_to_PC         (OUT_CIPHERTEXT* ct, int count);


#endif
