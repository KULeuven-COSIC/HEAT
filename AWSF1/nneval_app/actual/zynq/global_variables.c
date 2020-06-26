#define MSGS 16				        // number of messages to send per ciphertext polynomial

/*
	// Declaration of the PCAP vars  
	pcap_t *handle;					 //Session handle 
	char *dev;					 //The device to sniff on 
	char errbuf[PCAP_ERRBUF_SIZE];			 //Error string 
	struct bpf_program fp;				 //The compiled filter 
	char filter_exp[] = "src host 192.168.2.1";	 //The filter expression; pcap monitors eth frames with source ip 192.168.2.1 
	bpf_u_int32 mask;				 //Our netmask 
	bpf_u_int32 net;				 //Our IP 
	struct pcap_pkthdr header;			 //The header that pcap gives us 
	const u_char *packet;				 //The actual packet 

	 Declaration of UDP vars 
	struct sockaddr_in myaddr, remaddr;
	int fd, i, j, slen=sizeof(remaddr);
	int recvlen;					//				 # bytes in acknowledgement message 
	char *server = "192.168.2.1";			//				 ip of the fpga 
*/

unsigned char packet_global[MSGS][1500];
unsigned int packet_count=0;
long int break_loop_detected=0;

