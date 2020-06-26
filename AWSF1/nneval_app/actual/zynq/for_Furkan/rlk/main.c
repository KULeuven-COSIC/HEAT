#include<stdio.h>
#include<stdint.h>

main()
{
	FILE *fp;
	fp = fopen("rlk11_shares", "r");

	uint64_t a0, a1;
	uint64_t a;
        int i, j;

	for(j=0; j<6; j++)
	{
		for(i=0; i<2048; i++)
		{
			fscanf(fp, "%lu %lu", &a0, &a1);
			a = a0 + a1*1073741824;

			if(i==0)		
			printf("{%lu,\n", a);
			else if(i!=2047)		
			printf("%lu,\n", a);
			else
			printf("%lu},\n", a);	
		}
		printf("\n");
	}

	fclose(fp);
}
