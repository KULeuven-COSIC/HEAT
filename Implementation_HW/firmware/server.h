#ifndef SERVER_H
#define SERVER_H

#include "xparameters.h"

#include "netif/xadapter.h"

#include "platform.h"
#include "platform_config.h"

#include "lwip/tcp.h"
#include "lwip/dhcp.h"

int init_server();
int start_server();

#endif
