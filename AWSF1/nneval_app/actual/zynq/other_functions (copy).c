#include "instruction_compile.c"
void die(char *s)
{
	perror(s);
	exit(1);
}

void got_packet_new(u_char *args, const struct pcap_pkthdr *header, const u_char *packet, pcap_t *handle)
{

	static int count = 1;                   // packet counter 
	int i;

	if(packet[34]==0xff && packet[35]==0xff)	// error notification from fpga
	{	
		break_loop_detected++;			// whenever computer receives an error notification frame, it sets a flag
	}
	else
	{
		// 42 + 128*8 bytes received: 8 bytes for 64 bit data	
		for(i=0; i<1066; i++)
		packet_global[packet_count][i] = packet[i];

		packet_count++;
	}

	return;
}

void read_ciphertext1(long long int poly[], char fname[])
{
	int i;
	FILE *fp;

	fp = fopen(fname, "r");
	for(i=0; i<4096*6; i++)
	{
		fscanf(fp, "%lu", &poly[i]);
		//fscanf(fp, "%lu", &poly[i]);
		//fscanf(fp, "%lu", &poly[i+2048]);
	}	
	fclose(fp);
}

void read_ciphertext2(long long int poly[], char fname[])
{
	int i;
	FILE *fp;

	fp = fopen(fname, "r");
	for(i=0; i<4096*13; i++)
	{
		fscanf(fp, "%lu", &poly[i]);
	}	
	fclose(fp);
}


void poly2byte(unsigned char byte_array[MSGS][6+128*8+8], long long int poly[], unsigned short operand)	// 6 additional bytes for eth comm
{
	int i, j, k;
	size_t size;
	unsigned long long two_coefficients; // 40 bits when each coefficient is 20 bits

	for(i=0; i<MSGS; i++)
	{
		byte_array[i][0]=0xff;	
		byte_array[i][1]=0xff;	
		byte_array[i][2]=0x01;	
		byte_array[i][3]=0xff;	
		byte_array[i][4]= operand & 0xff;
		byte_array[i][5]=0xff;

		for(j=0; j<128; j++)
		{

			two_coefficients = (poly[i*128*2+j*2]&1073741823llu) + (poly[i*128*2+j*2+1]&1073741823llu)*1073741824llu;
			for(k=0; k<8; k++)
			{
				byte_array[i][6+j*8+k] = two_coefficients & 255llu;
				two_coefficients = two_coefficients>>8;			
			}
		}

		// additional 8 bytes are sent as the last word was not getting written
		two_coefficients = 1152921504606846975llu;
		for(k=0; k<8; k++)
		{
			byte_array[i][6+128*8+k] = two_coefficients & 255llu;
			two_coefficients = two_coefficients>>8;			
		}
	}
}


void poly2byte_program(unsigned char byte_array[MSGS][6+128*8+8], unsigned short operand, int prog_code)
{
	int i, j, k;
	size_t size;
	unsigned long long two_coefficients; // 40 bits when each coefficient is 20 bits
	unsigned long long instruction, address1, address2, porc_select, mem_select, mod_select;
	unsigned long long long_instruction[2048];
 
	instruction_compile(long_instruction, prog_code);

	for(i=0; i<MSGS; i++)
	{
		byte_array[i][0]=0xff;	
		byte_array[i][1]=0xff;	
		byte_array[i][2]=0x40;	
		byte_array[i][3]=0xff;	
		byte_array[i][4]= operand & 0xff;
		byte_array[i][5]=0xff;
	
		for(j=0; j<128; j++)
		{
			/*
			if(j==0) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==1) 
			{ 
				instruction=5; address1=0; address2=6; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==3) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==4) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==5) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==6) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=1; mod_select=1; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==7) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==8) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=1; mod_select=1; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j==9) 
			{ 
				instruction=0; address1=0; address2=0; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			if(j>9) 
			{ 
				instruction=255; address1=0; address2=0; porc_select=0; mem_select=0; mod_select=0; 
 				two_coefficients=instruction+address1*256llu+address2*65536llu;
				two_coefficients=two_coefficients+porc_select*16777216llu+mem_select*134217728llu+mod_select*268435456llu;
			}
			
			for(k=0; k<8; k++)
			{
				byte_array[i][6+j*8+k] = two_coefficients & 255llu;
				two_coefficients = two_coefficients>>8;			
			}
			*/			
			
			two_coefficients = long_instruction[i*128+j];
			//printf("i=%d two_coefficients=%llu\n", i, two_coefficients);
			for(k=0; k<8; k++)
			{
				byte_array[i][6+j*8+k] = two_coefficients & 255llu;
				two_coefficients = two_coefficients>>8;			
			}
			
		}

		// additional 8 bytes are sent as the last word was not getting written
		two_coefficients = 1152921504606846975llu;
		for(k=0; k<8; k++)
		{
			byte_array[i][6+128*8+k] = two_coefficients & 255llu;
			two_coefficients = two_coefficients>>8;			
		}
	}
}


void poly2byte_zero(unsigned char byte_array[MSGS][6+128*8+8], long long int random, unsigned short operand)	// 6 additional bytes to support the eth comm
{
	int i, j, k;
	size_t size;
	unsigned long long two_coefficients; // 40 bits when each coefficient is 20 bits
	for(i=0; i<MSGS; i++)
	{
		byte_array[i][0]=0xff;	
		byte_array[i][1]=0xff;	
		byte_array[i][2]=0x01;	
		byte_array[i][3]=0xff;	
		byte_array[i][4]= operand & 0xff;
		byte_array[i][5]=0xff;
	
		for(j=0; j<128; j++)
		{
			//two_coefficients = (pol0_0[i*128+j]&1073741823llu) + (pol0_1[i*128+j]&1073741823llu)*1073741824llu;
			if(i==0 && j==0)
			two_coefficients = ((0)&1073741823llu) + ((0)&1073741823llu)*1073741824llu;
			else
			two_coefficients = ((0+random)&1073741823llu) + ((0+random)&1073741823llu)*1073741824llu;
			for(k=0; k<8; k++)
			{
				byte_array[i][6+j*8+k] = two_coefficients & 255llu;
				two_coefficients = two_coefficients>>8;			
			}
		}

		// additional 8 bytes are sent as the last word was not getting written
		two_coefficients = 1152921504606846975llu;
		for(k=0; k<8; k++)
		{
			byte_array[i][6+128*8+k] = two_coefficients & 255llu;
			two_coefficients = two_coefficients>>8;			
		}
	}
}


void poly2byte_instruction(unsigned char byte_array[4][6+128*8+8], unsigned char ins, unsigned short operand)	// 6 additional bytes to support the eth comm
{
	int i, j, k;
	size_t size;
	unsigned long long two_coefficients; // 40 bits when each coefficient is 20 bits
	for(i=0; i<4; i++)
	{
		byte_array[i][0]=0xff;	
		byte_array[i][1]=0xff;	
		byte_array[i][2]=ins;	
		byte_array[i][3]=0xff;	
		//byte_array[i][4]=0xff;	
		byte_array[i][4]= operand & 0xff;	
		byte_array[i][5]=0xff;
		//byte_array[i][5]= (operand>> 8) & 0xff;
	
		for(j=0; j<128; j++)
		{
			for(k=0; k<8; k++)
			{
				byte_array[i][6+j*8+k] = 0x00;
			}
		}
			for(k=0; k<8; k++)
			{
				byte_array[i][6+128*8+k] = 0x00;
			}
	}	
}


void poly2byte_reset(unsigned char byte_array[4][6+128*8+8])	// 6 additional bytes to support the eth comm
{
	int i, j, k;
	size_t size;
	unsigned long long two_coefficients; // 40 bits when each coefficient is 20 bits
	for(i=0; i<4; i++)
	{
		byte_array[i][0]=0xff;	
		byte_array[i][1]=0xff;	
		byte_array[i][2]=0x00;	
		byte_array[i][3]=0x00;	
		byte_array[i][4]=0x00;	
		byte_array[i][5]=0x00;
	
		for(j=0; j<128; j++)
		{
			for(k=0; k<8; k++)
			{
				byte_array[i][6+j*8+k] = 0x00;
			}
		}
			for(k=0; k<8; k++)
			{
				byte_array[i][6+128*8+k] = 0x00;
			}
	}	
}

void byte2poly(long long int pol0_0[], long long int pol0_1[])
{
	int i, j;
	size_t size;
 	long long int two_coefficients;
	for(i=0; i<MSGS; i++)
	{
		for(j=42; j<42+128*8; j=j+8)
		{
			two_coefficients = packet_global[i][j]+packet_global[i][j+1]*256llu+packet_global[i][j+2]*65536llu;
			two_coefficients = two_coefficients + packet_global[i][j+3]*16777216llu;
			pol0_0[i*128+(j-42)/8] = two_coefficients & 1073741823;

			
			two_coefficients = (two_coefficients>>30) + packet_global[i][j+4]*4llu+packet_global[i][j+5]*1024llu;
			two_coefficients = two_coefficients + packet_global[i][j+6]*262144llu + packet_global[i][j+7]*67108864llu;
			pol0_1[i*128+(j-42)/8] = two_coefficients;
		}
	}
/*
	printf("TRT\n");
	for(j=0; j<42+128*10; j=j+1)
	{
		printf("%02x", packet_global[0][j]);
		if(j>0 && j%10==9) printf("\n");
	}	
*/
	
}

int check_dec_error(int pol[])
{
	int i;
	int sum=0;
	for(i=1; i<2048; i++)
	{
		sum = sum + pol[i];
	}
	return(sum);
}

void send_byte_array(unsigned char byte_array[][6+128*8+8])
{
	int i;

	for (i=0; i < MSGS; i++) // sending c_j
	{		
		// 1030  = 6 + 128*8 + 8
		if (sendto(fd, byte_array[i], 1030+8, 0, (struct sockaddr *)&remaddr, slen)==-1) 
		{
			perror("sendto");
			exit(1);
		}
		if(i<MSGS-1)
		usleep(1000);
	}
}

void send_instruction(unsigned char ins, unsigned short operand)
{
	int i;
	unsigned char byte_array[4][6+128*8+8];

	poly2byte_instruction(byte_array, ins, operand);

	for (i=0; i<1; i++) // sending c_j
	{		
		// 1030  = 6 + 128*8 + 8
		if (sendto(fd, byte_array[i], 1030+8, 0, (struct sockaddr *)&remaddr, slen)==-1) 
		{
			perror("sendto");
			exit(1);
		}
		if(i<3)
		usleep(1000);
	}
}


int receive_byte_array()
{
	int i;
	
	//for(i=0; i<12; i++)
	for(i=0*MSGS; i<1*MSGS; i++)
	{
		pcap_loop(handle, 1, got_packet_new, NULL);
		if(break_loop_detected)
		{
			pcap_close(handle); 
			i = MSGS;
		//	goto L2;
			return(1);
		}
	}
	return(0);
}

void open_pcap_ethport()
{

	/********************************************************************************/
	//			Open the device using Pcap				//
	/********************************************************************************/

	// Define the device 
	dev = pcap_lookupdev(errbuf);
	if (dev == NULL) 
	{
		fprintf(stderr, "Couldn't find default device: %s\n", errbuf);
		return(2);
	}
	// Find the properties for the device 
	if (pcap_lookupnet(dev, &net, &mask, errbuf) == -1) 
	{
		fprintf(stderr, "Couldn't get netmask for device %s: %s\n", dev, errbuf);
		net = 0;
		mask = 0;
	}
	// Open the session in non-promiscuous mode 
	handle = pcap_open_live(dev, BUFSIZ, 1, 5, errbuf);
	if (handle == NULL) 
	{
		fprintf(stderr, "Couldn't open device %s: %s\n", dev, errbuf);
		return(2);
	}
	// Compile and apply the filter
	if (pcap_compile(handle, &fp, filter_exp, 0, net) == -1) 
	{
		fprintf(stderr, "Couldn't parse filter %s: %s\n", filter_exp, pcap_geterr(handle));
		return(2);
	}
	if (pcap_setfilter(handle, &fp) == -1) 
	{
		fprintf(stderr, "Couldn't install filter %s: %s\n", filter_exp, pcap_geterr(handle));
		return(2);
	}
}

void open_udp_ethport()
{
	/********************************************************************************/
	//			Create UDP sockets for data sending			//
	/********************************************************************************/

	// create udp socket 

	if ((fd=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDPLITE))==-1) printf("socket failed\n");


	// bind it to all local addresses and pick any port number 

	memset((char *)&myaddr, 0, sizeof(myaddr));
	myaddr.sin_family = AF_INET;
	myaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	myaddr.sin_port = htons(20000);			


	if (bind(fd, (struct sockaddr *)&myaddr, sizeof(myaddr)) < 0) {
		perror("bind failed");
		return 0;
	}       

	// now define remaddr, the address to whom we want to send messages 
	// For convenience, the host address is expressed as a numeric IP address 
	// that we will convert to a binary format via inet_aton 

	memset((char *) &remaddr, 0, sizeof(remaddr));
	remaddr.sin_family = AF_INET;
	remaddr.sin_port = htons(21234);			// port address of the FPGA
	if (inet_aton(server, &remaddr.sin_addr)==0) 
	{
		fprintf(stderr, "inet_aton() failed\n");
		exit(1);
	}

}
