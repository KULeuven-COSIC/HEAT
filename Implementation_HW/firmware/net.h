#ifndef NET_H
#define NET_H

#include <stdio.h>

#include "lwip/tcp.h"

 err_t message_receive(struct tcp_pcb *tpcb, uint8_t *msg, int msg_length);
 err_t message_send   (struct tcp_pcb *tpcb, uint8_t *msg, int msg_length);

#endif
