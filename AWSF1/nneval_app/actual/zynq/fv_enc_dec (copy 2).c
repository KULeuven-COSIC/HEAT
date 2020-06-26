/*
#include<stdio.h>
#include<gmp.h>
#include "primitive_root.c"
#include "lut1_s11.32.c"
#include "lut2_s11.32.c"
#include "probability_s11.32.c"
*/


long long int sk_0[2][512], sk_1[2][512], pk0_0[2][512], pk0_1[2][512], pk1_0[2][512], pk1_1[2][512];

void knuth_yao1(long long int e_0[], long long int e_1[])
{

int r;
int random_bit;
long long int distance;
long long int ROW, COLUMN;
long long int SAMPLE_COUNTER;
//long long int q = 147457;

	int state1[16], state2[16], state3[16], state4[16], state5[16], state6[16], state7[16], state8[16], state9[16];
	int seed;
	int bit, input, i;
	int flag, index, sample, sample_msb, random;
		
	int integer_equivalent;
	int flag1;
	int ran;
//////////////////////////////////////////////////////////////////////
	
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0xbd4a;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state1[i] = bit;
		seed = seed>>1;
	}

	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0xf1ce;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state2[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0xef52;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state3[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0x5760;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state4[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0xbbd4;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state5[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0xc8ab;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state6[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0x6e8e;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state7[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0xab38;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state8[i] = bit;
		seed = seed>>1;
	}
	ran = rand();
	ran = ran & 65535;
	seed = ran;
	seed = 0x5bbd;
	for(i=15;i>=0;i--)
	{
		bit = seed%2;
		state9[i] = bit;
		seed = seed>>1;
	}

//	printf("Knuth-Yao\n");
for(SAMPLE_COUNTER=0; SAMPLE_COUNTER<1024; )
{
//	printf("SAMPLE_COUNTER=%ld  ",SAMPLE_COUNTER);
	flag1=1;
//	printf("random = %ld%ld%ld%ld%ld%ld%ld%ld%ld ", state9[15],state8[15],state7[15],state6[15],state5[15],state4[15],state3[15],state2[15],state1[15]); 
	index = state1[15] + 2*state2[15] + 4*state3[15] + 8*state4[15] + 16*state5[15] + 32*state6[15] + 64*state7[15] + 128*state8[15];
//	printf("random = %ld\n" , index+256*state9[15]);
	sample = lut1[index];
	sample_msb = sample & 16;
	if(sample_msb==0)	// lookup was successful
	{
		flag = 1; // set to 1 so that no-retern from 'goto' occurs.	
		sample = sample & 0xf;
//		if(sample>24) sample = sample - 24;
		if(state9[15]) sample = (0 - sample);
		if(SAMPLE_COUNTER%2==1) e_1[SAMPLE_COUNTER/2] = sample;	// mpz_set_ui(e_1[SAMPLE_COUNTER/2], sample);
		if(SAMPLE_COUNTER%2==0) e_0[SAMPLE_COUNTER/2] = sample; //mpz_set_ui(e_0[SAMPLE_COUNTER/2], sample);
//		printf("sample = %ld  lut1 \n", sample);
		goto L1;
	}
//	printf("z\n");
//	printf("lut1 = %ld\n", sample);


	flag1=0;
	goto L2;
	L4: flag1=1;
	distance = sample & 7;
	index = state1[15] + 2*state2[15] + 4*state3[15] + 8*state4[15] + 16*state5[15] + 32*distance;
//	printf("random1 = %ld\n" , index);
	sample = lut2[index];
//	printf("lut2 = %ld\n", sample);
	sample_msb = sample & 32;
	if(sample_msb==0)	// lookup was successful
	{
		flag = 1; // set to 1 so that no-retern from 'goto' occurs.	
		sample = sample & 31;
//		if(sample>24) sample = sample - 24;
		if(state9[15]) sample = (0 - sample);
		if(SAMPLE_COUNTER%2==1) e_1[SAMPLE_COUNTER/2] = sample;	//mpz_set_ui(e_1[SAMPLE_COUNTER/2], sample);
		if(SAMPLE_COUNTER%2==0) e_0[SAMPLE_COUNTER/2] = sample; //mpz_set_ui(e_0[SAMPLE_COUNTER/2], sample);
//		printf("sample = %ld lut2 \n", sample);
//		printf("x\n");
		goto L1;
	}


	if(sample_msb!=0)
	{
//	printf("random = %ld" , index+256*state9[15]);
		distance = sample & 15;
 		for(COLUMN=13; COLUMN<109; )
		{
			flag = 0;	// set to 0 so that retern from 'goto' occurs.
			 	
				if(COLUMN==13) distance = distance*2 + state9[15];
				else distance = distance*2 + state1[15];	
			//	printf("random %ld dist at jump %ld \n", random, distance);
			//	printf("random %ld \n", random);
				goto L2;
				L3: ROW=54;
			// Read probability-column 0 and count the number of non-zeros
			for(ROW=54; ROW>=0; ROW--)
			{
				distance = distance - pmat[ROW][COLUMN];
//				printf("inter dist %ld \n", distance);
				if(distance<0)
				{
					flag = 1;
					sample = ROW;
//					if(sample>24) sample = sample - 24;
					if(state9[15]) sample = (0 - ROW);
					if(SAMPLE_COUNTER%2==1) e_1[SAMPLE_COUNTER/2] = sample;	//mpz_set_ui(e_1[SAMPLE_COUNTER/2], sample);
					if(SAMPLE_COUNTER%2==0) e_0[SAMPLE_COUNTER/2] = sample;	//mpz_set_ui(e_0[SAMPLE_COUNTER/2], sample);

//					printf("sample = %ld  bitscan\n", sample);
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





bitreverse1(long long int a_0[], long long int a_1[])
{
	int i;
	int bit1, bit2, bit3, bit4, bit5, bit6, bit7, bit8, bit9, bit10, bit11, swp_index;
	long long int q1, r1, q2, r2;
	long long int temp;

	for(i=0; i<1024; i++)
	{
		bit1 = i%2;
		bit2 = (i>>1)%2;
		bit3 = (i>>2)%2;
		bit4 = (i>>3)%2;
        	bit5 = (i>>4)%2;
        	bit6 = (i>>5)%2;
        	bit7 = (i>>6)%2;
        	bit8 = (i>>7)%2;
        	bit9 = (i>>8)%2;
        	bit10 = (i>>9)%2;

		q1=i/2;
		r1=i%2;
		swp_index = bit1*512 + bit2*256 + bit3*128 + bit4*64 + bit5*32 + bit6*16 + bit7*8 + bit8*4 + bit9*2 + bit10;
		q2 = swp_index/2;
		r2 = swp_index%2;

		if(swp_index>i)
		{
			if(r2==0) temp = a_0[q2];
			if(r2==1) temp = a_1[q2];
			if(r2==0 && r1==0) a_0[q2] = a_0[q1];
			if(r2==0 && r1==1) a_0[q2] = a_1[q1];
			if(r2==1 && r1==0) a_1[q2] = a_0[q1];
			if(r2==1 && r1==1) a_1[q2] = a_1[q1];
			if(r1==0) a_0[q1] = temp;
			if(r1==1) a_1[q1] = temp;
		}
	}
}


void fwd_ntt1(long long int a_0[], long long int a_1[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;
	long long int primrt, omega;

	for(m=2; m<=512; m=2*m)
	{
		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}
		primrt = primrt_array[prime_index][i-1];
		omega = primrt_array[prime_index][i];
		//printf("m=%d %d %d\n", m, primrt, omega);
		for(j=0; j<m/2; j++)
		{
			for(k=0; k<512; k=k+m)
			{
				t1 = omega * a_1[k+j];
				t1 = mod(t1, prime_index);
				t2 = omega * a_1[k+j+m/2];
				t2 = mod(t2, prime_index);

				u1 = a_0[k+j];
				u2 = a_0[k+j+m/2];	

				a_0[k+j] = u1 + t1;
				a_0[k+j] = mod(a_0[k+j], prime_index);
				a_1[k+j] = u2 + t2;
				a_1[k+j] = mod(a_1[k+j], prime_index);
				a_0[k+j+m/2] = u1 - t1;
				a_0[k+j+m/2] = mod(a_0[k+j+m/2], prime_index);
				a_1[k+j+m/2] = u2 - t2;
				a_1[k+j+m/2] = mod(a_1[k+j+m/2], prime_index);

			}
			omega = omega * primrt;
			omega = mod(omega, prime_index);	
		}
	}

	m = 1024;

		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}
		primrt = primrt_array[prime_index][i-1];
		omega = primrt_array[prime_index][i];
		//printf("%ld\n", omega);


		for(j=0; j<m/2; j++)
		{
			//printf("j=%ld omega=%ld a_1[j]=%ld\n", j, omega, a_1[j]);
			t1 = omega * a_1[j];
			t1 = mod(t1, prime_index);
			u1 = a_0[j];
			a_0[j] = u1 + t1;
			a_0[j] = mod(a_0[j], prime_index);
			a_1[j] = u1 - t1;
			a_1[j] = mod(a_1[j], prime_index);

			omega = omega * primrt;
			omega = mod(omega, prime_index);
		}

		/*
		if(m==2048)
		{
			for(i=0; i<1024; i++)
			printf("i=%ld %ld %ld\n", i, a_0[i], a_1[i]);
		}	
		*/
}



void rearrange1(long long int a_0[], long long int a_1[])
{
	int i;
	int bit1, bit2, bit3, bit4, bit5, bit6, bit7, bit8, bit9, bit10;
	int swp_index;

	long long int u1, t1, u2, t2;
	
	for(i=0; i<512; i++)
	{
		bit1 = i%2;
		bit2 = (i>>1)%2;
		bit3 = (i>>2)%2;
		bit4 = (i>>3)%2;
		bit5 = (i>>4)%2;
		bit6 = (i>>5)%2;
		bit7 = (i>>6)%2;
		bit8 = (i>>7)%2;
		bit9 = (i>>8)%2;

		swp_index = bit1*256 + bit2*128 + bit3*64 + bit4*32 + bit5*16 + bit6*8 + bit7*4 + bit8*2 + bit9;
		
		if(swp_index>i)
		{
			u1 = a_0[i];
			u2 = a_1[i];
			
			a_0[i] = a_0[swp_index];
			a_1[i] = a_1[swp_index];

			a_0[swp_index] = u1;
			a_1[swp_index] = u2;
		}
//		gmp_printf("index = %ld   a_1 = %Zd    a_0 = %Zd \n", i, a_1[i], a_0[i]);
//		gmp_printf("swp_index = %ld   a_1 = %Zd    a_0 = %Zd \n", swp_index, a_1[swp_index], a_0[swp_index]);

	}
}

void inv_ntt1(long long int a_0[], long long int a_1[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;
	long long int primrt, omega;		

	for(m=2; m<=512; m=2*m)
	{
		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}
		primrt = inv_primrt_array[prime_index][i-1];
		omega = 1;
		//printf("m = %d primrt=%ld   \n", m, primrt);

		for(j=0; j<m/2; j++)
		{
			for(k=0; k<512; k=k+m)
			{
				t1 = omega * a_1[k+j];
				t1 = mod(t1, prime_index);
				u1 = a_0[k+j];	
				t2 = omega * a_1[k+j+m/2];
				t2 = mod(t2, prime_index);		
				u2 = a_0[k+j+m/2];	
				
				a_0[k+j] = u1 + t1;
				a_0[k+j] = mod(a_0[k+j], prime_index);
				a_1[k+j] = u2 + t2;
				a_1[k+j] = mod(a_1[k+j], prime_index);
				a_0[k+j+m/2] = u1 - t1;
				a_0[k+j+m/2] = mod(a_0[k+j+m/2], prime_index);
				a_1[k+j+m/2] = u2 - t2;
				a_1[k+j+m/2] = mod(a_1[k+j+m/2], prime_index);
			}
			omega = omega * primrt;
			omega = mod(omega, prime_index);	
		}
	}

	m = 1024;
		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}
		primrt = inv_primrt_array[prime_index][i-1];
		omega = 1;
		//printf("m = %d primrt=%ld   \n", m, primrt);

		for(j=0; j<m/2; j++)
		{
			t1 = omega * a_1[j];
			t1 = mod(t1, prime_index);
			u1 = a_0[j];
			a_0[j] = u1 + t1;
			a_0[j] = mod(a_0[j], prime_index);
			a_1[j] = u1 - t1;
			a_1[j] = mod(a_1[j], prime_index);

			omega = omega * primrt;
			omega = mod(omega, prime_index);
		}
		if(m==1024)
		{
			//for(i=0; i<1024; i++)
			//printf("i=%ld %ld %ld\n", i, a_0[i], a_1[i]);
		}




	m = 1024;
	long long int omega2;
		primrt = inv_primrt_array[prime_index][log_n-1];
		omega = 1;

		omega2=primrt;
		for(i=2; i<1024; i=i*2)
		omega2 = mod(omega2*omega2, prime_index);


		omega = mod(omega*n_inv[prime_index], prime_index);
		omega2 = mod(omega2*n_inv[prime_index], prime_index);
		for(j=0; j<m/2; j++)
		{
			a_0[j] = omega * a_0[j];
			a_0[j] = mod(a_0[j], prime_index);
			a_1[j] = omega2 * a_1[j];
			a_1[j] = mod(a_1[j], prime_index);

			//printf("j=%ld omega=%ld omega2=%ld %ld %ld\n", j, omega, omega2, a_0[j], a_1[j]);

			omega = omega * primrt;
			omega = mod(omega, prime_index);
			omega2 = omega2 * primrt;
			omega2 = mod(omega2, prime_index);

		}
}


void coefficient_mul1(long long int a_0[], long long int a_1[], long long int b_0[], long long int b_1[], long long int c_0[], long long int c_1[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;

	m = 1024;
		for(j=0; j<m/2; j++)
		{
			c_0[j] = a_0[j] * b_0[j];
			c_0[j] = mod(c_0[j], prime_index);
			c_1[j] = a_1[j] * b_1[j];
			c_1[j] = mod(c_1[j], prime_index);
		}
}

void coefficient_add1(long long int a_0[], long long int a_1[], long long int b_0[], long long int b_1[], long long int c_0[], long long int c_1[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;

	m = 1024;
		for(j=0; j<m/2; j++)
		{
			c_0[j] = a_0[j] + b_0[j];
			c_0[j] = mod(c_0[j], prime_index);
			c_1[j] = a_1[j] + b_1[j];
			c_1[j] = mod(c_1[j], prime_index);
//			gmp_printf("index=%ld a_0=%Zd, a_1=%Zd\n", j, a_0[j], a_1[j]);
		}
}


void coefficient_sub1(long long int a_0[], long long int a_1[], long long int b_0[], long long int b_1[], long long int c_0[], long long int c_1[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;

	m = 1024;
		for(j=0; j<m/2; j++)
		{
			c_0[j] = a_0[j] - b_0[j];
			c_0[j] = mod(c_0[j], prime_index);
			c_1[j] = a_1[j] - b_1[j];
			c_1[j] = mod(c_1[j], prime_index);
		}
}



void message_gen1(long long int m_0[], long long int m_1[])
{
	FILE *fm;
	int i, r1, r2;

	fm = fopen("input_message.txt", "w");
	for(i=0;i<512;i++)
	{
		r1 = rand();
		m_0[i] = r1%2;
		r2 = rand();
		m_1[i] = r2%2;
		fprintf(fm, "%lld %lld\n", m_0[i], m_1[i]);
	}
	fclose(fm);
}

void poly_copy1(long long int u_0[], long long int u_1[], long long int u_temp_0[], long long int u_temp_1[])
{
	int i;
	for(i=0; i<512; i++)
	{
		u_temp_0[i] = u_0[i];
		u_temp_1[i] = u_1[i];
	}
}

void FV_enc1(long long int m_0[], long long int m_1[], long long int c1_0[][512], long long int c1_1[][512], long long int c2_0[][512], long long int c2_1[][512],
	    long long int pk0_0[][512], long long int pk0_1[][512], long long int pk1_0[][512], long long int pk1_1[][512])
{
	int i, r;
	FILE *fp;	
	long long int e1_0[512], e1_1[512], e2_0[512], e2_1[512], u_0[512], u_1[512];	
	long long int u_temp_0[512], u_temp_1[512], e1_temp_0[512], e1_temp_1[512];
	long long int temp_0[512], temp_1[512];
	long long int m_encoded_0[512], m_encoded_1[512];
	long long int share_counter;

	knuth_yao1(e1_1, e1_0);	
	knuth_yao1(e2_1, e2_0);	

	for(i=0; i<512; i++)
	{
		r = random() % 2;
		if(random()%2==1)
			r = -r;
		u_0[i] = r;

		r = random() % 2;
		if(random()%2==1)
			r = -r;
		u_1[i] = r;
	}

	for(share_counter=0; share_counter<2; share_counter++)
	{
		for(i=0; i<512; i++)		
		{
			m_encoded_0[i] = m_0[i] * pby2[share_counter];		// encoding of message
			m_encoded_1[i] = m_1[i] * pby2[share_counter];
		}

		poly_copy1(u_0, u_1, u_temp_0, u_temp_1);

		fwd_ntt1(u_temp_0, u_temp_1, share_counter);

		/*
		/// debug
		fp = fopen("dump/fft_u", "r");
		for(i=0; i<512; i++)
		fscanf(fp, "%ld %ld %ld %ld", &u_0[i], &u_1[i], &u_temp_0[i], &u_temp_1[i]); 
		fclose(fp);
		*/

		for(i=0; i<512; i++)		
		{
			temp_0[i] = mod(pk0_0[share_counter][i] * u_temp_0[i], share_counter);		// temp <-- ntt(pk0*u)
			temp_1[i] = mod(pk0_1[share_counter][i] * u_temp_1[i], share_counter);
		}

		rearrange1(temp_0, temp_1);
		inv_ntt1(temp_0, temp_1, share_counter);							// temp <-- pk0*u

		/*
		if(share_counter==1)
		{	
			printf("pk0*u\n");	
			for(i=0; i<512; i++)
			printf("%ld %ld\n", temp_0[i], temp_1[i]);
		}
		*/

		for(i=0; i<512; i++)		
		{
			e1_temp_0[i] = mod(e1_0[i] + m_encoded_0[i], share_counter);	
			e1_temp_1[i] = mod(e1_1[i] + m_encoded_1[i], share_counter);	
		}
		
		/*
		/// debug
		fp = fopen("dump/masked_message", "r");
		for(i=0; i<512; i++)
		fscanf(fp, "%ld %ld %ld %ld", &u_0[i], &u_1[i], &e1_temp_0[i], &e1_temp_1[i]); 
		fclose(fp);
		*/

		for(i=0; i<512; i++)		
		{
			c1_0[share_counter][i] = mod(temp_0[i] + e1_temp_0[i], share_counter);		// c1 <-- pk0*u + e1 + delta*m
			c1_1[share_counter][i] = mod(temp_1[i] + e1_temp_1[i], share_counter);
		}

		/*
		if(share_counter==1)
		{	
			printf("c0\n");	
			for(i=0; i<512; i++)
			printf("%ld %ld\n", c1_0[1][i], c1_1[1][i]);
		}
		*/	

		for(i=0; i<512; i++)		
		{
			temp_0[i] = mod(pk1_0[share_counter][i] * u_temp_0[i], share_counter);		// temp <-- ntt(pk1*u)
			temp_1[i] = mod(pk1_1[share_counter][i] * u_temp_1[i], share_counter);
		}
		rearrange1(temp_0, temp_1);
		inv_ntt1(temp_0, temp_1, share_counter);							// temp <-- pk0*u

		for(i=0; i<512; i++)		
		{
			c2_0[share_counter][i] = mod(temp_0[i] + e2_0[i], share_counter);			// c2 <-- pk1*u + e2
			c2_1[share_counter][i] = mod(temp_1[i] + e2_1[i], share_counter);
		}

	}
}	

void decoding1(mpz_t c1_0_full[], mpz_t c1_1_full[], long long int m_decrypted_0[], long long int m_decrypted_1[])
{
	int i;

	for(i=0; i<512; i++)
	{
		if(mpz_cmp(c1_0_full[i],  p_full_length2_by4)>0  && mpz_cmp(c1_0_full[i], p_full_length2_by4_mul3)<0) m_decrypted_0[i] = 1; else m_decrypted_0[i] = 0;	
		if(mpz_cmp(c1_1_full[i],  p_full_length2_by4)>0  && mpz_cmp(c1_1_full[i], p_full_length2_by4_mul3)<0) m_decrypted_1[i] = 1; else m_decrypted_1[i] = 0;	
	}

}

void inverse_crt1(long long int c_0[][512], long long int c_1[][512], mpz_t c_full_0[], mpz_t c_full_1[])
{
	int i, j;

	int thread_num;
	mpz_t temp;
	mpz_init(temp);

		for(i=0; i<512; i++)
		{	
			for(j=0; j<2; j++)		
			{
				mpz_mul_ui(temp, Ni_length2[j], c_0[j][i]);
				mpz_mul(temp, temp, Ni_inv_length2[j]);
				mpz_mod(temp, temp, p_full_length2);	// temp = c0[i][j]*Ni*Ni_inv mod q_full
		
				if(j==0)
				mpz_set(c_full_0[i], temp);
				else
				mpz_add(c_full_0[i], c_full_0[i], temp);
			}
			mpz_mod(c_full_0[i], c_full_0[i], p_full_length2);	
		}

		for(i=0; i<512; i++)
		{	
			for(j=0; j<2; j++)		
			{
				mpz_mul_ui(temp, Ni_length2[j], c_1[j][i]);
				mpz_mul(temp, temp, Ni_inv_length2[j]);
				mpz_mod(temp, temp, p_full_length2);	// temp = c0[i][j]*Ni*Ni_inv mod q_full
		
				if(j==0)
				mpz_set(c_full_1[i], temp);
				else
				mpz_add(c_full_1[i], c_full_1[i], temp);
			}
			mpz_mod(c_full_1[i], c_full_1[i], p_full_length2);	
		}
}


void FV_dec1(long long int m_decrypted_0[], long long int m_decrypted_1[], 
	    long long int c1_0[][512], long long int c1_1[][512], long long int c2_0[][512], long long int c2_1[][512],
	    long long int sk_0[][512], long long int sk_1[][512])
{
	int i;
	FILE *fp;	

	long long int temp_0[512], temp_1[512];
	long long int share_counter;
	mpz_t c1_0_full[512], c1_1_full[512];

	mpz_array_init(c1_0_full[0], 512, 256);
	mpz_array_init(c1_1_full[0], 512, 256);
	
	for(share_counter=0; share_counter<2; share_counter++)
	{


		rearrange1(c2_0[share_counter], c2_1[share_counter]);

		fwd_ntt1(c2_0[share_counter], c2_1[share_counter], share_counter);
		


		for(i=0; i<512; i++)		
		{
			c2_0[share_counter][i] = mod(sk_0[share_counter][i] * c2_0[share_counter][i], share_counter);		// c2 <-- ntt(c2*sk)
			c2_1[share_counter][i] = mod(sk_1[share_counter][i] * c2_1[share_counter][i], share_counter);
		}


		rearrange1(c2_0[share_counter], c2_1[share_counter]);
		inv_ntt1(c2_0[share_counter], c2_1[share_counter], share_counter);							// c2 <-- c2*sk


		for(i=0; i<512; i++)		
		{
			c1_0[share_counter][i] = mod(c2_0[share_counter][i] + c1_0[share_counter][i], share_counter);		// c1 <-- c1 + c2*sk
			c1_1[share_counter][i] = mod(c2_1[share_counter][i] + c1_1[share_counter][i], share_counter);
		}

		/*
		for(i=0; i<512; i++)
		{
			printf("i=%d %lu %lu\n", i, c1_0[share_counter][i], c1_1[share_counter][i]);
		}
		*/
	}

	inverse_crt1(c1_0, c1_1, c1_0_full, c1_1_full);
	//gmp_printf("c1_0_full = %Zd\n", c1_0_full[0]);
	decoding1(c1_0_full, c1_1_full, m_decrypted_0, m_decrypted_1);	

}




/*
main()
{
	int i, I;
	FILE *fm;
	srand (time(NULL));
	
	long long int m_0[1024], m_1[1024], m_decrypted_0[1024], m_decrypted_1[1024], c1_0[1024], c1_1[1024], c2_0[1024], c2_1[1024];
	long long int hamming_m, hamming_mdec;

	for(I=0; I<1; I++)
	{
		key_gen();

		hamming_m = hamming_mdec = 0;
	
		message_gen(m_0, m_1);
	
		for(i=0; i<1024; i++)
		hamming_m = hamming_m + m_0[i] + m_1[i];

		bitreverse(m_0, m_1);

	////////////////////////////////////////////////////
	// 	Encryption -- Decryption

		RLWE_enc(m_0, m_1, c1_0, c1_1, c2_0, c2_1);


		rearrange(c1_0, c1_1);
		rearrange(c2_0, c2_1);

		fm = fopen("ciphertext.txt", "w");
		for(i=0; i<1024; i++)
		fprintf(fm, "%ld %ld %ld %ld\n", c1_0[i], c1_1[i], c2_0[i], c2_1[i]);		
		fclose(fm);


		RLWE_dec(m_decrypted_0, m_decrypted_1, c1_0, c1_1, c2_0, c2_1);

	////////////////////////////////////////////////////

		rearrange(m_decrypted_0, m_decrypted_1);
		RLWE_enc(m_decrypted_0, m_decrypted_1, c1_0, c1_1, c2_0, c2_1);

		rearrange(c1_0, c1_1);
		rearrange(c2_0, c2_1);

		RLWE_dec(m_decrypted_0, m_decrypted_1, c1_0, c1_1, c2_0, c2_1);

	
		for(i=0; i<1024; i++)
		hamming_mdec = hamming_mdec + m_decrypted_0[i] + m_decrypted_1[i];
	

		// Print the output message in a file
		fm = fopen("output_message.txt", "w");
		for(i=0; i<512; i++)
		fprintf(fm, "%ld %ld\n", m_decrypted_0[2*i], m_decrypted_0[2*i+1]);

		for(i=0; i<512; i++)
		fprintf(fm, "%ld %ld\n", m_decrypted_1[2*i], m_decrypted_1[2*i+1]);
		fclose(fm);

		system("diff input_message.txt output_message.txt");
	}

}
*/




void 	read_keys1(long long int sk_0[][512], long long int sk_1[][512], 
		  long long int pk0_0[][512], long long int pk0_1[][512], long long int pk1_0[][512], long long int pk1_1[][512])
{
	int i;
	FILE *fp;

	fp=fopen("keys/pk0_0to1023_q0", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &pk0_0[0][i]);
		fscanf(fp, "%lld", &pk0_1[0][i]);	
	}
	fclose(fp);

	fp=fopen("keys/pk0_0to1023_q1", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &pk0_0[1][i]);
		fscanf(fp, "%lld", &pk0_1[1][i]);	
	}
	fclose(fp);

	fp=fopen("keys/pk1_0to1023_q0", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &pk1_0[0][i]);
		fscanf(fp, "%lld", &pk1_1[0][i]);	
	}
	fclose(fp);

	fp=fopen("keys/pk1_0to1023_q1", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &pk1_0[1][i]);
		fscanf(fp, "%lld", &pk1_1[1][i]);	
	}
	fclose(fp);


	fp=fopen("keys/sk_0to1023_q0", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &sk_0[0][i]);
		fscanf(fp, "%lld", &sk_1[0][i]);	
	}
	fclose(fp);

	fp=fopen("keys/sk_0to1023_q1", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &sk_0[1][i]);
		fscanf(fp, "%lld", &sk_1[1][i]);	
	}
	fclose(fp);

	for(i=0; i<2; i++)
	{
		bitreverse1(pk0_0[i], pk0_1[i]);
		bitreverse1(pk1_0[i], pk1_1[i]);
		bitreverse1(sk_0[i], sk_1[i]);

		fwd_ntt1(pk0_0[i], pk0_1[i], i);
		fwd_ntt1(pk1_0[i], pk1_1[i], i);
		fwd_ntt1(sk_0[i], sk_1[i], i);
	}

	fp=fopen("keys/sk_0to511ntt_q0", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld %lld\n", sk_0[0][i], sk_1[0][i]);
	}
	fclose(fp);
	fp=fopen("keys/sk_0to511ntt_q1", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld %lld\n", sk_0[1][i], sk_1[1][i]);
	}
	fclose(fp);


	fp=fopen("keys/pk0_0to511ntt_q0", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld %lld\n", pk0_0[0][i], pk0_1[0][i]);
	}
	fclose(fp);
	fp=fopen("keys/pk0_0to511ntt_q1", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld %lld\n", pk0_0[1][i], pk0_1[1][i]);
	}
	fclose(fp);



	fp=fopen("keys/pk1_0to511ntt_q0", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld %lld\n", pk1_0[0][i], pk1_1[0][i]);
	}
	fclose(fp);
	fp=fopen("keys/pk1_0to511ntt_q1", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld %lld\n", pk1_0[1][i], pk1_1[1][i]);
	}
	fclose(fp);
}

void read_ciphertext(long long int c0_0[][512], long long int c0_1[][512], long long int c1_0[][512], long long int c1_1[][512])
{
	int i;
	FILE *fp;

	fp=fopen("c00_q0", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c0_0[0][i]);
	}
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c0_1[0][i]);	
	}
	fclose(fp);
	fp=fopen("c00_q1", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c0_0[1][i]);
	}
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c0_1[1][i]);	
	}
	fclose(fp);


	fp=fopen("c01_q0", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c1_0[0][i]);
	}
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c1_1[0][i]);	
	}
	fclose(fp);
	fp=fopen("c01_q1", "r");
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c1_0[1][i]);
	}
	for(i=0; i<512; i++)
	{
		fscanf(fp, "%lld", &c1_1[1][i]);	
	}
	fclose(fp);
}


void write_ciphertext(long long int c0_0[][512], long long int c0_1[][512], long long int c1_0[][512], long long int c1_1[][512])
{
	int i;
	FILE *fp;

	fp=fopen("box/c0_q0", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c0_0[0][i]);
	}
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c0_1[0][i]);	
	}
	fclose(fp);
	fp=fopen("box/c0_q1", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c0_0[1][i]);
	}
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c0_1[1][i]);	
	}
	fclose(fp);


	fp=fopen("box/c1_q0", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c1_0[0][i]);
	}
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c1_1[0][i]);	
	}
	fclose(fp);
	fp=fopen("box/c1_q1", "w");
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c1_0[1][i]);
	}
	for(i=0; i<512; i++)
	{
		fprintf(fp, "%lld\n", c1_1[1][i]);	
	}
	fclose(fp);
}

void FV_recrypt1(long long int c0[][1024], long long int c1[][1024])
{
	long long int m_0[512], m_1[512];
	long long int c0_0[2][512], c0_1[2][512], c1_0[2][512], c1_1[2][512];
	int i, j;
	FILE *fp;

	// convert from c0 to c0_0 and c0_1 arrays
	for(i=0; i<512; i++)
	{
		c0_0[0][i] = c0[0][i];
		c0_0[1][i] = c0[1][i];
		c0_1[0][i] = c0[0][i+512];
		c0_1[1][i] = c0[1][i+512];

		c1_0[0][i] = c1[0][i];
		c1_0[1][i] = c1[1][i];
		c1_1[0][i] = c1[0][i+512];
		c1_1[1][i] = c1[1][i+512];
	}
/*
	fp= fopen("dump/c0_q0", "w");
	for(i=0; i<512; i++)
	fprintf(fp, "%ld %ld\n", c0_0[0][i], c0_1[0][i]);
	fclose(fp);
	fp= fopen("dump/c0_q1", "w");
	for(i=0; i<512; i++)
	fprintf(fp, "%ld %ld\n", c0_0[1][i], c0_1[1][i]);
	fclose(fp);
	fp= fopen("dump/c1_q0", "w");
	for(i=0; i<512; i++)
	fprintf(fp, "%ld %ld\n", c1_0[0][i], c1_1[0][i]);
	fclose(fp);
	fp= fopen("dump/c1_q1", "w");
	for(i=0; i<512; i++)
	fprintf(fp, "%ld %ld\n", c1_0[1][i], c1_1[1][i]);
	fclose(fp);
*/
/*
	fp=fopen("dump/c0_fpga", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%ld %ld %ld %ld", &c0_0[0][i], &c0_1[0][i], &c0_0[1][i], &c0_1[1][i]);
	fclose(fp);
	
	fp=fopen("dump/c1_fpga", "r");
	for(i=0; i<512; i++)
	fscanf(fp, "%ld %ld %ld %ld", &c1_0[0][i], &c1_1[0][i], &c1_0[1][i], &c1_1[1][i]);
	fclose(fp);
*/

	FV_dec1(m_0, m_1, c0_0, c0_1, c1_0, c1_1, sk_0, sk_1);
	
	//for(i=0; i<512; i++)
	//printf("%lld %lld\n", m_0[i], m_1[i]);
	

	
	FV_enc1(m_0, m_1, c0_0, c0_1, c1_0, c1_1, pk0_0, pk0_1, pk1_0, pk1_1);

	// convert from {c0_0, c0_1} arrays to c0
	for(i=0; i<512; i++)
	{
		c0[0][i] = c0_0[0][i]; 
		c0[1][i] = c0_0[1][i]; 
		c0[0][i+512] = c0_1[0][i];
		c0[1][i+512] = c0_1[1][i];
		c1[0][i] = c1_0[0][i]; 
		c1[1][i] = c1_0[1][i]; 
		c1[0][i+512] = c1_1[0][i];
		c1[1][i+512] = c1_1[1][i];
	}
	
}

void FV_recrypt1_HW(long long int c0[][1024], long long int c1[][1024])
{
}



void comm_test()
{
	int total_sync_loss;
	long long int m_0[512], m_1[512];
	long long int c0_0[32768], c0_1[32768], c1_0[2][512], c1_1[2][512];
	int i, j;
	FILE *fp;
	long long int et=0;

	// Declaration of Ethernet Frame variables 	
	unsigned char byte_array1[MSGS][6+128*10], byte_array2[4][6+128*10], byte_array3[4][6+128*10], reset_array[4][6+128*10];
	unsigned char byte_array4[4][6+128*10], byte_array5[4][6+128*10];

	long long int random_array[256];

	fp = fopen("tt", "w");
	for(i=0; i<256; i++)
	{
		random_array[i] = rand() & 1073741823llu;
		fprintf(fp, "%lld\n", random_array[i]);
	}
	fclose(fp);

	total_sync_loss = 0;

	int COUNTER;
	unsigned int temp;
	unsigned char ins = 0;
	unsigned short operand = 0;

	unsigned short processor_sel, memory_sel;
	/*		
	for(i=0; i<6; i++)
	{
		ins=1;
		random_array[0] = 0;
		processor_sel=i; memory_sel=0; 
		operand = (processor_sel<<5)+memory_sel;
		printf("operand %d sent\n", operand);
		poly2byte(byte_array1, 4096*i, operand);
		//poly2byte_zero(byte_array1, 1, operand);
		send_byte_array(byte_array1);
		usleep(10000);

		processor_sel=i; memory_sel=0; 
		operand = (processor_sel<<5)+memory_sel;
		ins = 3;  // DDR[0] <-- P0_M0 ;
		send_instruction(ins, operand);
		usleep(100000);
	}
	*/	
	
	/*
	ins=1;
	random_array[0] = 0;
	processor_sel=0; memory_sel=1; 
	operand = (processor_sel<<5)+memory_sel;
	printf("operand %d sent\n", operand);
	poly2byte(byte_array1, 4096, operand);
	send_byte_array(byte_array1);
	usleep(10000);
	
		processor_sel=0; memory_sel=1; 
		operand = (processor_sel<<5)+memory_sel;
		ins = 3;  // DDR[1] <-- P0_M1 ;
		send_instruction(ins, operand);
		usleep(100000);
	*/
	/*
	for(i=2; i<13; i++)
	{
		ins=1;
		random_array[0] = 0;
		processor_sel=0; memory_sel=i; 
		operand = (processor_sel<<5)+memory_sel;
		printf("operand %d sent\n", operand);
		poly2byte_zero(byte_array1, 0, operand);
		send_byte_array(byte_array1);
		usleep(10000);

			processor_sel=0; memory_sel=i; 
			operand = (processor_sel<<5)+memory_sel;
			ins = 3;  // DDR[i] <-- P0_M0 or P0_M1 ;
			send_instruction(ins, operand);
			usleep(100000);
	}
	*/
	
	usleep(1000000);		
	// SEND PROGRAM
	ins=64;
	random_array[0] = 0;
	processor_sel=0; memory_sel=0; 
	operand = 0;
	printf("operand %d sent\n", operand);
	poly2byte_program(byte_array1, operand);
	send_byte_array(byte_array1);
	usleep(10000);
		


	
	for(COUNTER=0; COUNTER<1; COUNTER++)
	{
		
		operand = 0;
		ins = 0;
		send_instruction(ins, operand);
		usleep(10000);
				
		operand = 0;
		ins = 65;
		send_instruction(ins, operand);
		usleep(1000000);

		/*		
		operand = 0;
		ins = 0;
		send_instruction(ins, operand);
		usleep(10000);
		*/		

		/*		
		operand = 0;
		ins = 5;
		send_instruction(ins, operand);
		usleep(1000000);
		*/
		/*		
		operand = 0;
		ins = 0;
		send_instruction(ins, operand);
		usleep(10000);
		*/
		/*	
		processor_sel=0; memory_sel=6; 
		operand = (processor_sel<<5)+memory_sel;
		ins = 4;  // DDR[] --> P0_M0 ;
		send_instruction(ins, operand);
		usleep(100000);
		*/


		/*
		processor_sel=0; memory_sel=5; 
		operand = (processor_sel<<5)+memory_sel;
		ins = 3;  // DDR[5] <-- P0_M1 ;
		send_instruction(ins, operand);
		usleep(100000);
		*/

		/*
		operand = 0;
		ins = 16;	// rearrange P0_M0
		send_instruction(ins, operand);
		usleep(10000);
		
		ins = 17;	// NTT P0_M0
		send_instruction(ins, operand);
		usleep(10000);

		ins = 16;	// rearrange P0_M0
		send_instruction(ins, operand);
		usleep(10000);
		
		ins = 18;	// INTT P0_M0
		send_instruction(ins, operand);
		usleep(10000);
		*/

		/*
		operand = 0;
		ins = 4;
		send_instruction(ins, operand);
		usleep(100000);
		*/
		/*			
		ins = 16;
		send_instruction(ins, operand);
		usleep(10000);
		
		ins = 17;
		send_instruction(ins, operand);
		usleep(10000);

		operand = 2;
		ins = 3;
		send_instruction(ins, operand);
		usleep(100000);
		*/
		/*		
		ins = 16;
		send_instruction(ins, operand);
		usleep(10000);

		ins = 18;
		send_instruction(ins, operand);
		usleep(10000);
		*/
		
		
		/*
		operand = 0;
		ins = 0;
		send_instruction(ins, operand);
		usleep(10000);
		
		processor_sel=0; memory_sel=6; 
		operand = (processor_sel<<5)+memory_sel;
		ins = 4;  // DDR[] --> P0_M0 ;
		send_instruction(ins, operand);
		usleep(100000);
		*/

		L1:		
		ins = 2;
		processor_sel=0; memory_sel=0; 
		operand = (processor_sel<<5)+memory_sel;	// Eth read P0_M0
		send_instruction(ins, operand);

		break_loop_detected = 0;
		packet_count = 0;
		if(receive_byte_array() != 0)		// when corrupt eth frame is received then nonzero is returned
		{
			printf("Sync loss\n");
			open_pcap_ethport();		// open ethernet port
			goto L1; 			// re-transmit the c to fpga
		}
		break_loop_detected = 0;
		packet_count = 0;
		byte2poly(c0_0, c0_1);

		for(i=0; i<MSGS*128; i++)
		{
			printf("i = %d\n", i);
			printf("C %lld %lld \n", c0_0[i]&1073741823llu, c0_1[i]&1073741823llu);
			/*
			if((c0_0[i]&1073741823llu) != ((2*i+random_array[operand])&1073741823llu) || (c0_1[i]&1073741823llu) != ((2*i+1+random_array[operand])&1073741823llu))
			{
				printf("ERROR\n");
				et = 1;
				goto L2;
			}
			*/
		}
		L2: if(et) { printf("C i=%d %lld %lld tt %lld\n", i, c0_0[i]&1073741823llu, c0_1[i]&1073741823llu, ((2*i+random_array[operand])&1073741823llu)); scanf("%d", &j);}






		usleep(10000);
		et = 0;
	}


/*
		send_byte_array(byte_array1);
		usleep(10000);

		operand = 0x01;
		ins = 3;
		send_instruction(ins, operand);
		usleep(10000);

		operand = 0x01;
		ins = 4;
		send_instruction(ins, operand);
		usleep(10000);

		ins = 2;
		operand = 0xffff;
		send_instruction(ins, operand);

		break_loop_detected = 0;
		packet_count = 0;
		if(receive_byte_array() != 0)		// when corrupt eth frame is received then nonzero is returned
		{
			printf("Sync loss\n");
			open_pcap_ethport();		// open ethernet port
			goto L1; 			// re-transmit the c to fpga
		}
		break_loop_detected = 0;
		packet_count = 0;
		byte2poly(c0_0, c0_1);

		for(i=0; i<32768; i++)
		{
			printf("i = %d\n", i);
			printf("C %lld %lld \n", c0_0[i]&1073741823llu, c0_1[i]&1073741823llu);
			if(i%128==127) 
			{
				printf("et = %d\n", et);
				//scanf("%d", &j);	
			}
		}
		printf("et = %d\n", et);
*/
	break_loop_detected = 0;
	packet_count = 0;
	printf("et = %d\n", et);
}







/*
main()
{
	long long int a_0[512], a_1[512], b_0[512], b_1[512];
	int i;

	compute_crt_constants();
	creat_primrt_array();
	
	for(i=0; i<512; i++)
	{
		a_0[i] = i*2;
		a_1[i] = i*2+1;
	}

	bitreverse1(a_0, a_1);
	inv_ntt1(a_0, a_1, 0);


	//rearrange1(a_0, a_1);
	//inv_ntt1(a_0, a_1, 1);
	
	for(i=0; i<512; i++)
	{
		printf("i=%d %ld %ld\n", i, a_0[i], a_1[i]);
	}

}

*/

/*
main()
{
	int i, I;
	FILE *fm;
	srand (time(NULL));
	
	long long int sk_0[2][512], sk_1[2][512], pk0_0[2][512], pk0_1[2][512], pk1_0[2][512], pk1_1[2][512];

	long long int m_0[512], m_1[512], m_decrypted_0[512], m_decrypted_1[512];
	long long int c1_0[2][512], c1_1[2][512], c2_0[2][512], c2_1[2][512];
	long long int hamming_m, hamming_mdec;

	compute_crt_constants();
	creat_primrt_array();
	
	read_keys(sk_0, sk_1, pk0_0, pk0_1, pk1_0, pk1_1);
	printf("reading done\n");

	for(I=0; I<1; I++)
	{
		hamming_m = hamming_mdec = 0;
	
		message_gen1(m_0, m_1);
		
		//for(i=0; i<512; i++)
		//{
		//	m_0[i] = 0; m_1[i] = 0;
		//}
		//m_0[0] = 1;
		
		for(i=0; i<512; i++)
		hamming_m = hamming_m + m_0[i] + m_1[i];


	////////////////////////////////////////////////////
	// 	Encryption -- Decryption

		FV_enc1(m_0, m_1, c1_0, c1_1, c2_0, c2_1, pk0_0, pk0_1, pk1_0, pk1_1);
		
		//write_ciphertext(c1_0, c1_1, c2_0, c2_1);

		FV_dec1(m_decrypted_0, m_decrypted_1, c1_0, c1_1, c2_0, c2_1, sk_0, sk_1);
	

	////////////////////////////////////////////////////
		
		FV_enc1(m_decrypted_0, m_decrypted_1, c1_0, c1_1, c2_0, c2_1, pk0_0, pk0_1, pk1_0, pk1_1);

		//write_ciphertext(c1_0, c1_1, c2_0, c2_1);
		//FV_dec(m_0, m_1, c1_0, c1_1, c2_0, c2_1, sk_0, sk_1);
		
		FV_dec1(m_0, m_1, c1_0, c1_1, c2_0, c2_1, sk_0, sk_1);
		FV_enc1(m_0, m_1, c1_0, c1_1, c2_0, c2_1, pk0_0, pk0_1, pk1_0, pk1_1);
		
		//write_ciphertext(c1_0, c1_1, c2_0, c2_1);

		FV_dec1(m_decrypted_0, m_decrypted_1, c1_0, c1_1, c2_0, c2_1, sk_0, sk_1);


	
		for(i=0; i<512; i++)
		hamming_mdec = hamming_mdec + m_decrypted_0[i] + m_decrypted_1[i];

		// Print the output message in a file
		fm = fopen("output_message.txt", "w");
		for(i=0; i<512; i++)
		fprintf(fm, "%ld %ld\n", m_decrypted_0[i], m_decrypted_1[i]);
		fclose(fm);

		system("diff input_message.txt output_message.txt");
		printf("hamming weights %ld %ld\n", hamming_m, hamming_mdec);

		
		//read_ciphertext(c1_0, c1_1, c2_0, c2_1);
		//FV_dec1(m_decrypted_0, m_decrypted_1, c1_0, c1_1, c2_0, c2_1, sk_0, sk_1);
		//for(i=0; i<512; i++)
		//printf("%ld %ld\n", m_decrypted_0[i], m_decrypted_1[i]);
		
	}

}
*/


