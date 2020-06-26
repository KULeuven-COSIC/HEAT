#ifndef HE_COPROCESSOR_CODE_H
#define HE_COPROCESSOR_CODE_H

#include "coprocessor.h"

#define MULTIPLY_CODE_LEN 126

INSTRUCTION zero = 
  {  0, 0, 0, 0, 0, 0 };

INSTRUCTION multiply_code[] = {
//                               | bitlen | field     |
//                               |--------|-----------|
//   +-------------------------> | 8      | opcode    |
//   |         +---------------> | 1      | mod       |
//   |         |  +------------> | 4      | readMem0  |
//   |         |  |  +---------> | 4      | readMem1  |
//   |         |  |  |  +------> | 4      | writeMem0 |
//   |         |  |  |  |  +---> | 4      | writeMem1 |
//   |         |  |  |  |  |

//                                   1  2  3  4  5  6  7  8

  {ADD      ,  0, 1, 0, 5, 0 }, // | r|  |  |  | w|  |  |  |  |
  {ADD      ,  0, 2, 0, 6, 0 }, // |  | r|  |  |  | w|  |  |  |
  {ADD      ,  0, 3, 0, 7, 0 }, // |  |  | r|  |  |  | w|  |  |
  {ADD      ,  0, 4, 0, 8, 0 }, // |  |  |  | r|  |  |  | w|  |

  {REARRANGE,  0, 1, 0, 1, 0 }, // |rw|  |  |  |  |  |  |  |  |
  {NTT      ,  0, 1, 0, 1, 0 }, // |rw|  |  |  |  |  |  |  |  |
  {REARRANGE,  0, 2, 0, 2, 0 }, // |  |rw|  |  |  |  |  |  |  |
  {NTT      ,  0, 2, 0, 2, 0 }, // |  |rw|  |  |  |  |  |  |  |
  {REARRANGE,  0, 3, 0, 3, 0 }, // |  |  |rw|  |  |  |  |  |  |
  {NTT      ,  0, 3, 0, 3, 0 }, // |  |  |rw|  |  |  |  |  |  |
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  |
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  |

  {MULTIPLY ,  0, 2, 3, 3, 0 }, // |  |r |rw|  |  |  |  |  |  | 
  {MULTIPLY ,  0, 1, 4, 4, 0 }, // |r |  |  |rw|  |  |  |  |  | 
  {ADD      ,  0, 3, 4, 3, 0 }, // |  |  |rw|r |  |  |  |  |  | (2*3+1*4)
  
  {ADD      ,  0, 7, 0, 4, 0 }, // |  |  |  | w|  |  |r |  |  |
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  |
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  |
  {MULTIPLY ,  0, 1, 4, 1, 0 }, // |rw|  |  |r |  |  |  |  |  | (1*3)
  
  {ADD      ,  0, 8, 0, 4, 0 }, // |  |  |  | w|  |  |  |8 |  |
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  |
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  |
  {MULTIPLY ,  0, 2, 4, 2, 0 }, // |  |rw|  |r |  |  |  |  |  | (2*4)
  
  {REARRANGE,  0, 1, 0, 1, 0 }, // |rw|  |  |  |  |  |  |  |  |
  {INTT     ,  0, 1, 0, 1, 0 }, // |rw|  |  |  |  |  |  |  |  |
  {REARRANGE,  0, 2, 0, 2, 0 }, // |  |rw|  |  |  |  |  |  |  |
  {INTT     ,  0, 2, 0, 2, 0 }, // |  |rw|  |  |  |  |  |  |  |
  {REARRANGE,  0, 3, 0, 3, 0 }, // |  |  |rw|  |  |  |  |  |  |
  {INTT     ,  0, 3, 0, 3, 0 }, // |  |  |rw|  |  |  |  |  |  |

  {LIFT_5   ,  0, 5, 0, 5, 0 }, // |  |  |  |  |rw|  |  |  |  |
  {LIFT_5   ,  0, 6, 0, 6, 0 }, // |  |  |  |  |  |rw|  |  |  |
  {LIFT_5   ,  0, 7, 0, 7, 0 }, // |  |  |  |  |  |  |rw|  |  |
  {LIFT_5   ,  0, 8, 0, 8, 0 }, // |  |  |  |  |  |  |  |rw|  |

  {REARRANGE,  1, 5, 0, 5, 0 }, // |  |  |  |  |rw|  |  |  |  |
  {NTT      ,  1, 5, 0, 5, 0 }, // |  |  |  |  |rw|  |  |  |  |
  {REARRANGE,  1, 6, 0, 6, 0 }, // |  |  |  |  |  |rw|  |  |  |
  {NTT      ,  1, 6, 0, 6, 0 }, // |  |  |  |  |  |rw|  |  |  |
  {REARRANGE,  1, 7, 0, 7, 0 }, // |  |  |  |  |  |  |rw|  |  |
  {NTT      ,  1, 7, 0, 7, 0 }, // |  |  |  |  |  |  |rw|  |  |
  {REARRANGE,  1, 8, 0, 8, 0 }, // |  |  |  |  |  |  |  |rw|  |
  {NTT      ,  1, 8, 0, 8, 0 }, // |  |  |  |  |  |  |  |rw|  |   
  {MULTIPLY ,  1, 5, 8, 4, 0 }, // |  |  |  | w|r |  |  |r |  |
  {MULTIPLY ,  1, 5, 7, 5, 0 }, // |  |  |  |  |rw|  |r |  |  |
  {MULTIPLY ,  1, 6, 7, 7, 0 }, // |  |  |  |  |  |r |rw|  |  |
  {MULTIPLY ,  1, 6, 8, 6, 0 }, // |  |  |  |  |  |rw|  |r |  |
  {ADD      ,  1, 4, 7, 7, 0 }, // |  |  |  |r |  |  |rw|  |  |   
  {REARRANGE,  1, 5, 0, 5, 0 }, // |  |  |  |  |rw|  |  |  |  |
  {INTT     ,  1, 5, 0, 5, 0 }, // |  |  |  |  |rw|  |  |  |  |
  {REARRANGE,  1, 6, 0, 6, 0 }, // |  |  |  |  |  |rw|  |  |  |
  {INTT     ,  1, 6, 0, 6, 0 }, // |  |  |  |  |  |rw|  |  |  |
  {REARRANGE,  1, 7, 0, 7, 0 }, // |  |  |  |  |  |  |rw|  |  |
  {INTT     ,  1, 7, 0, 7, 0 }, // |  |  |  |  |  |  |rw|  |  |
 
  {LIFT_6   ,  0, 1, 5, 1, 0 }, // |rw|  |  |  |r |  |  |  |  |
  {LIFT_6   ,  0, 3, 7, 5, 0 }, // |  |  |r |  | w|  |r |  |  |
  {LIFT_6   ,  0, 2, 6, 4, 0 }, // |  |r |  | w|  |r |  |  |  |

  {RECV_TMP ,  0, 0, 0, 0, 0 }, // |  |  |  |r |  |  |  |  |  | // Read C2 and store in C program
   
  {SEND_RLK ,  0, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // Send RLK0A
  {ADD      ,  0, 4, 0, 6, 0 }, // |  |  |  |r |  | w|  |  |  | // Move RLK0A to M6
  {SEND_RLK ,  1, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // Send RLK0B
  {ADD      ,  0, 4, 0, 7, 0 }, // |  |  |  |r |  |  | w|  |  | // Move RLK0B to M7
  {SEND_TMP ,  0, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // c2[0]-->M4 
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | 
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | // M4<--NTT(c2[0]) 
  {MULTIPLY ,  0, 6, 4, 8, 0 }, // |  |  |  |r |  |r |  | w|  | // M8<--rlk00*NTT(c2[0]) 
  {MULTIPLY ,  0, 7, 4, 2, 0 }, // |  | w|  |r |  |  |r |  |  | // M2<--rlk01*NTT(c2[0]) 
 
  {SEND_RLK ,  2, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 6, 0 }, // |  |  |  |r |  | w|  |  |  | // RLK10 in M6
  {SEND_RLK ,  3, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 7, 0 }, // |  |  |  |r |  |  | w|  |  | // RLK11 in M7
  {SEND_TMP ,  1, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // c2[1]-->M4
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | 
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | // M4<--NTT(c2[1])
  {MULTIPLY ,  0, 6, 4, 3, 0 }, // |  |  | w|r |  |r |  |  |  | // M3<--rlk10*NTT(c2[1])
  {ADD      ,  0, 8, 3, 8, 0 }, // |  |  |r |  |  |  |  |rw|  | // M8<--rlk00*NTT(c2[0])+rlk10*NTT(c2[1])
  {MULTIPLY ,  0, 7, 4, 3, 0 }, // |  |  | w|r |  |  |r |  |  | // M3<--rlk11*NTT(c2[1])
  {ADD      ,  0, 2, 3, 2, 0 }, // |  |rw|r |  |  |  |  |  |  | // M2<--rlk01*NTT(c2[0])+rlk11*NTT(c2[1])
 
  {SEND_RLK ,  4, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 6, 0 }, // |  |  |  |r |  | w|  |  |  | // RLK20 in M6 
  {SEND_RLK ,  5, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 7, 0 }, // |  |  |  |r |  |  | w|  |  | // RLK21 in M7 
  {SEND_TMP ,  2, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // c2[2]-->M4, 
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | 
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | // M4<--NTT(c2[1]) 
  {MULTIPLY ,  0, 6, 4, 3, 0 }, // |  |  | w|r |  |r |  |  |  | // M3<--rlk20*NTT(c2[2]) 
  {ADD      ,  0, 8, 3, 8, 0 }, // |  |  |r |  |  |  |  |rw|  | // M8<--rlk20*NTT(c2[2])+..+rlk00*NTT(c2[0]) 
  {MULTIPLY ,  0, 7, 4, 3, 0 }, // |  |  | w|r |  |  |r |  |  | // M3<--rlk21*NTT(c2[2]) 
  {ADD      ,  0, 2, 3, 2, 0 }, // |  |rw|r |  |  |  |  |  |  | // M2<--rlk21*NTT(c2[2])+..+rlk01*NTT(c2[0]) 
 
  {SEND_RLK ,  6, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 6, 0 }, // |  |  |  |r |  | w|  |  |  | // RLK30 in M6      
  {SEND_RLK ,  7, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 7, 0 }, // |  |  |  |r |  |  | w|  |  | // RLK31 in M7      
  {SEND_TMP ,  3, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // c2[3]-->M4,      
  
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | 
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | // M4<--NTT(c2[3])      
  {MULTIPLY ,  0, 6, 4, 3, 0 }, // |  |  | w|r |  |r |  |  |  | // M3<--rlk30*NTT(c2[3])      
  {ADD      ,  0, 8, 3, 8, 0 }, // |  |  |r |  |  |  |  |rw|  | // M8<--rlk30*NTT(c2[3])+..+rlk00*NTT(c0[0])  
  {MULTIPLY ,  0, 7, 4, 3, 0 }, // |  |  | w|r |  |  |r |  |  | // M3<--rlk31*NTT(c2[3])      
  {ADD      ,  0, 2, 3, 2, 0 }, // |  |rw|r |  |  |  |  |  |  | // M2<--rlk31*NTT(c2[3])+..+rlk01*NTT(c2[0])
 
  {SEND_RLK ,  8, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 6, 0 }, // |  |  |  |r |  | w|  |  |  | // RLK40 in M6
  {SEND_RLK ,  9, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 7, 0 }, // |  |  |  |r |  |  | w|  |  | // RLK41 in M7
  {SEND_TMP ,  4, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // c2[4]-->M4,
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | 
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | // M4<--NTT(c2[4])
  {MULTIPLY ,  0, 6, 4, 3, 0 }, // |  |  | w|r |  |r |  |  |  | // M3<--rlk40*NTT(c2[4])
  {ADD      ,  0, 8, 3, 8, 0 }, // |  |  |r |  |  |  |  |rw|  | // M8<--rlk40*NTT(c2[4])+..+rlk00*NTT(c0[0])
  {MULTIPLY ,  0, 7, 4, 3, 0 }, // |  |  | w|r |  |  |r |  |  | // M3<--rlk41*NTT(c2[4])
  {ADD      ,  0, 2, 3, 2, 0 }, // |  |rw|r |  |  |  |  |  |  | // M2<--rlk41*NTT(c2[4])+..+rlk01*NTT(c2[0])

  {SEND_RLK , 10, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 6, 0 }, // |  |  |  |r |  | w|  |  |  | // RLK50 in M6 
  {SEND_RLK , 11, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | 
  {ADD      ,  0, 4, 0, 7, 0 }, // |  |  |  |r |  |  | w|  |  | // RLK51 in M7 
  {SEND_TMP ,  5, 0, 0, 0, 0 }, // |  |  |  | w|  |  |  |  |  | // c2[5]-->M4, 
  {REARRANGE,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | 
  {NTT      ,  0, 4, 0, 4, 0 }, // |  |  |  |rw|  |  |  |  |  | // M4<--NTT(c2[5])
  {MULTIPLY ,  0, 6, 4, 3, 0 }, // |  |  | w|r |  |r |  |  |  | // M3<--rlk50*NTT(c2[5])
  {ADD      ,  0, 8, 3, 8, 0 }, // |  |  |r |  |  |  |  |rw|  | // M8<--rlk50*NTT(c2[5])+..+rlk00*NTT(c0[0])
  {MULTIPLY ,  0, 7, 4, 3, 0 }, // |  |  | w|r |  |  |r |  |  | // M3<--rlk51*NTT(c2[5])
  {ADD      ,  0, 2, 3, 2, 0 }, // |  |rw|r |  |  |  |  |  |  | // M2<--rlk51*NTT(c2[5])+..+rlk01*NTT(c2[0]) -- END of RLK accumulation;  --  Result is in M8 and M9
                            
  {REARRANGE,  0, 8, 0, 8, 0 }, // |  |  |  |  |  |  |  |rw|  | // INTT (rlk0*c2)
  {INTT     ,  0, 8, 0, 8, 0 }, // |  |  |  |  |  |  |  |rw|  |  
  {REARRANGE,  0, 2, 0, 2, 0 }, // |  |rw|  |  |  |  |  |  |  | // INTT (rlk1*c2)
  {INTT     ,  0, 2, 0, 2, 0 }, // |  |rw|  |  |  |  |  |  |  |  

  {ADD      ,  0, 8, 1, 1, 0 }, // |rw|  |  |  |  |  |  |r |  | // c0 <-- c0 + INTT(rlk0*c2)
  {ADD      ,  0, 2, 5, 5, 0 }  // |  |r |  |  |rw|  |  |  |  | // c1 <-- c1 + INTT(rlk1*c2)
};

#endif // HE_COPROCESSOR_CODE_H