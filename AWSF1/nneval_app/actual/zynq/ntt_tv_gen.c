#include<stdio.h>
main()
{
	int i, j;

	for(j=0; j<6; j++)
	for(i=0; i<2048; i++)
	printf("%d \t %d \n", 2*i+j*4096, 2*i+1+j*4096);

	for(j=2; j<13; j++)
	for(i=0; i<2048; i++)
	printf("%d \t %d \n", 0, 0);

}
