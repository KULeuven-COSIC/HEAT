#include<stdio.h> //printf
#include<stdlib.h> // atoi
#include<string.h>    //strlen
#include<sys/socket.h>    //socket
#include<arpa/inet.h> //inet_addr
 

// FPGA's IP Address and TCP Port
//#define FPGA_IP "192.168.1.134"
#define FPGA_IP "192.168.1.123"
#define FPGA_PORT 7

// 256 times 30-bit (4-byte) words
// 128 times 60-bit (8-byte) words
#define POLY_LEN 2048
#define DATA_LEN (POLY_LEN*8)

// 4 commands each 32-bit (4-byte)
#define CMD_LEN (4*4)

#define TRUE 1
#define FALSE 0

int sock;
struct sockaddr_in server;
    
uint64_t counter;

int eth_init()
{
    // Create socket
    sock = socket(AF_INET , SOCK_STREAM , 0);
    if (sock == -1)
    {
        printf("Error - Could not create socket\n");
        return FALSE;
    }
    printf("Socket created.\n");
     
    server.sin_addr.s_addr = inet_addr(FPGA_IP);
    server.sin_family = AF_INET;
    server.sin_port = htons(FPGA_PORT);
    
    // Connect to TCP server @ FPGA
    if (connect(sock , (struct sockaddr *)&server , sizeof(server)) < 0)
    {
        printf("Error - Connect failed\n");
        return FALSE;
    }     
    printf("Connected\n");
	
	counter = 0;
}


int eth_send(uint8_t processor, uint8_t memory, uint8_t start_address,      
             uint64_t* polynomial)
{
    int i, j;

    uint64_t word_sum;
    uint64_t recv_sum;
	uint8_t* ack_buffer = (uint8_t*)&recv_sum; 

    // Send the data
    for(i=0; i<16; i++)
    {
		if( send(sock, (uint8_t*)polynomial+(i*1024), 1024 , 0) < 0)
		{
			printf("Error - Send data failed\n");
			return FALSE;
		}
		
		/*
		word_sum=0;
		for(j=0; j<128; j++)
			word_sum += polynomial[i*128+j];
		word_sum += counter;
		//counter++;

		//printf("C=%d S=%lu\n", counter, word_sum);

		//Receive a reply from the server
		if( recv(sock, ack_buffer, 8, 0) < 0)
		{
			printf("Recv Failure\n");
			return FALSE;
		}
		else
		{
			if(recv_sum!=word_sum)
			{
				printf("Sync Failure\n");
				printf("C=%d S=%lu\n", counter, recv_sum);
				
				for(j=0; j<8; j++)
					printf("%02X ", ack_buffer[j]);
				getchar();
				return FALSE;
			}
		}
		*/
    }
    return TRUE;
}

int eth_recv(uint8_t processor, uint8_t memory, uint8_t start_address,      
             uint64_t* polynomial)
{
    int i, j;

    // Construct the commands
    uint8_t cmd_buffer[] = {0xFE, 0xFE};

    uint64_t word_sum;
    uint64_t recv_sum;
	uint8_t* ack_buffer = (uint8_t*)&recv_sum;  

    // Send the data
    for(i=0; i<16; i++)
    {
		if( send(sock, cmd_buffer, 1, 0) < 0)
    	{
        	printf("Error - Send failed\n");
        	return FALSE;
    	}	

		//Receive a reply from the server
		if( recv(sock , (uint8_t*)polynomial+(i*1024), 1024, 0) < 0)
		{
			printf("Receive fails\n");
		}
		
		
		word_sum=0;
		for(j=0; j<128; j++)
			word_sum += polynomial[i*128+j];
		//word_sum += counter;
		//counter++;
	
		//printf("C=%d R=%lu\n", counter, word_sum);
		/*
		if( recv(sock, ack_buffer, 8, 0) < 0)
		{
			printf("Recv Failure\n");
			return FALSE;
		}
		else
		{
			if(recv_sum!=word_sum)
			{
				printf("Sync Failure\n");
				printf("C=%d R=%lu\n", counter, recv_sum);
				
				for(j=0; j<8; j++)
					printf("=%02X ", ack_buffer[j]);
				getchar();
				return FALSE;
			}
		}
		*/
	}

    return TRUE;
}
