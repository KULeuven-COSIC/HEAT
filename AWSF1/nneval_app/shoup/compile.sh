sudo arp -s 192.168.2.1 00:0a:35:02:f7:79
ulimit -S -s 6400000
gcc -w -fopenmp  main.c -lpcap -lgmp -o hw