#include "lut1_s11.32.c"
#include "lut2_s11.32.c"
#include "probability_s11.32.c"

void knuth_yao(long long int e[])
{

	int r;
	int random_bit;
	int distance;
	int ROW, COLUMN;
	int SAMPLE_COUNTER;

	int state1[16], state2[16], state3[16], state4[16], state5[16], state6[16], state7[16], state8[16], state9[16];
	int seed;
	int bit, input, i;
	int flag, index, sample_msb, random;
	long long int sample;
	
	int integer_equivalent;
	int flag1;
	int ran;
//////////////////////////////////////////////////////////////////////
	
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state1[i] = bit;
		seed = seed>>1;
	}

	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state2[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state3[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state4[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state5[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state6[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state7[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state8[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state9[i] = bit;
		seed = seed>>1;
	}

//	printf("Knuth-Yao\n");
for(SAMPLE_COUNTER=0; SAMPLE_COUNTER<4096; )
{
	flag1=1;
	index = state1[15] + 2*state2[15] + 4*state3[15] + 8*state4[15] + 16*state5[15] + 32*state6[15] + 64*state7[15] + 128*state8[15];
	sample = lut1[index];
	sample_msb = sample & 16;
	if(sample_msb==0)	// lookup was successful
	{
		flag = 1; // set to 1 so that no-retern from 'goto' occurs.	
		sample = sample & 0xf;
		if(state9[15] && sample>0) sample = -sample;
		e[SAMPLE_COUNTER] = sample;
		goto L1;
	}

	flag1=0;
	goto L2;
	L4: flag1=1;
	distance = sample & 7;
	index = state1[15] + 2*state2[15] + 4*state3[15] + 8*state4[15] + 16*state5[15] + 32*distance;
	sample = lut2[index];
	sample_msb = sample & 32;
	if(sample_msb==0)	// lookup was successful
	{
		flag = 1; // set to 1 so that no-retern from 'goto' occurs.	
		sample = sample & 31;
		if(state9[15] && sample>0) sample = -sample;
		e[SAMPLE_COUNTER] = sample;

		goto L1;
	}


	if(sample_msb!=0)
	{
		distance = sample & 15;
 		for(COLUMN=13; COLUMN<109; )
		{
			flag = 0;	// set to 0 so that retern from 'goto' occurs.
			 	
				if(COLUMN==13) distance = distance*2 + state9[15];
				else distance = distance*2 + state1[15];	
				goto L2;
				L3: ROW=54;
			// Read probability-column 0 and count the number of non-zeros
			for(ROW=54; ROW>=0; ROW--)
			{
				distance = distance - pmat[ROW][COLUMN];
				if(distance<0)
				{
					flag = 1;
					sample = ROW;
					if(state9[15] && sample>0) sample = -sample;

					e[SAMPLE_COUNTER] = sample;

					goto L1;				
				}
			}
			COLUMN++;	
//			goto L2;	// first generate random number for next jump;
		}
	}

		L1: 	SAMPLE_COUNTER++;
		
		L2:	input = state1[15] ^ state1[13] ^ state1[12] ^ state1[10];
			for(i=15; i>0; i--)
			state1[i] = state1[i-1];
			state1[0] = input;

			input = state2[15] ^ state2[13] ^ state2[12] ^ state2[10];
			for(i=15; i>0; i--)
			state2[i] = state2[i-1];
			state2[0] = input;

			input = state3[15] ^ state3[13] ^ state3[12] ^ state3[10];
			for(i=15; i>0; i--)
			state3[i] = state3[i-1];
			state3[0] = input;

			input = state4[15] ^ state4[13] ^ state4[12] ^ state4[10];
			for(i=15; i>0; i--)
			state4[i] = state4[i-1];
			state4[0] = input;

			input = state5[15] ^ state5[13] ^ state5[12] ^ state5[10];
			for(i=15; i>0; i--)
			state5[i] = state5[i-1];
			state5[0] = input;

			input = state6[15] ^ state6[13] ^ state6[12] ^ state6[10];
			for(i=15; i>0; i--)
			state6[i] = state6[i-1];
			state6[0] = input;

			input = state7[15] ^ state7[13] ^ state7[12] ^ state7[10];
			for(i=15; i>0; i--)
			state7[i] = state7[i-1];
			state7[0] = input;

			input = state8[15] ^ state8[13] ^ state8[12] ^ state8[10];
			for(i=15; i>0; i--)
			state8[i] = state8[i-1];
			state8[0] = input;

			input = state9[15] ^ state9[13] ^ state9[12] ^ state9[10];
			for(i=15; i>0; i--)
			state9[i] = state9[i-1];
			state9[0] = input;
			
			random = state1[15] + 2*state2[15] + 4*state3[15] + 8*state4[15] + 16*state5[15] + 32*state6[15] + 64*state7[15] + 128*state8[15] + 256*state9[15];
			if(flag1==0) goto L4;	// return during lut2
			if(flag==0) goto L3;	// return during an running Knuth-Yao walk
}
		
}

