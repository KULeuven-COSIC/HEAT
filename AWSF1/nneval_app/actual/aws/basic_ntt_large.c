long long int mod1(long long int a, int prime_index)
{
    	long long int quotient, remainder;
    	quotient = a/p[prime_index];
    	if(a>=0)
        	remainder = a - quotient*p[prime_index];
    	else
        	remainder = (1-quotient)*p[prime_index] + a;          
   
    	return(remainder);
}

int bitreverse(long long int a[])
{
	int i;
	int bit1, bit2, bit3, bit4, bit5, bit6, bit7, bit8, bit9, bit10, bit11, bit12, swp_index;
	long long int temp; 

	for(i=0; i<4096; i++)
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
       		bit11 = (i>>10)%2;
       		bit12 = (i>>11)%2;
		swp_index = bit1*2048 + bit2*1024 + bit3*512 + bit4*256 + bit5*128 + bit6*64 + bit7*32 + bit8*16 + bit9*8 + bit10*4 + bit11*2 + bit12;		
		
		if(swp_index>i)
		{
			temp = a[i];
			a[i] = a[swp_index];
			a[swp_index] = temp;
		}		
	}	
}

int fwd_ntt_q(long long int a[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;
	long long int primrt, omega;

	bitreverse(a);

	for(m=2; m<=4096; m=2*m)
	{
		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}
		primrt = primrt_array[prime_index][i-1];
		omega = primrt_array[prime_index][i];

		for(j=0; j<m/2; j++)
		{
			for(k=0; k<4096; k=k+m)
			{
				t1 = mod1(omega * a[k+j+m/2], prime_index);
				u1 = a[k+j];
				a[k+j] = mod_add(u1+t1, prime_index);
				a[k+j+m/2] = mod_sub(u1-t1, prime_index);
			}		
			omega = mod1(omega * primrt, prime_index);
		}
	}
}


int inv_ntt_q(long long int a[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;
	long long int primrt, omega;


	bitreverse(a);

	for(m=2; m<=4096; m=2*m)
	{

		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}

		primrt = inv_primrt_array[prime_index][i-1];
		omega = 1;

		for(j=0; j<m/2; j++)
		{
			for(k=0; k<4096; k=k+m)
			{
				t1 = mod1(omega * a[k+j+m/2], prime_index);
				u1 = a[k+j];
				a[k+j] = mod_add(u1+t1, prime_index);
				a[k+j+m/2] = mod_sub(u1-t1, prime_index);
			}		
			omega = mod1(omega * primrt, prime_index);
		}
	}
	
	
	m = 4096;
		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}

		primrt = inv_primrt_array[prime_index][i];
		omega = 1;
		for(j=0; j<m; j++)
		{
			a[j] = mod1(omega * a[j], prime_index);
			omega = mod1(omega * primrt, prime_index);
		}	
	
		omega = n_inv[prime_index];		

		for(j=0; j<m; j++)
		{
			a[j] = mod1(a[j]*omega, prime_index); 
		}	
	
}


int poly_mul_q(long long int a[], long long int b[], long long int c[], int prime_index)
{
	int i;

	fwd_ntt_q(a, prime_index);
	fwd_ntt_q(b, prime_index);

	for(i=0; i<4096; i++)
	{
		c[i] = mod1(a[i] * b[i], prime_index);
	}

	inv_ntt_q(c, prime_index);
}


int poly_add_q(long long int a[], long long int b[], long long int c[], int prime_index)
{

	int i;

	for(i=0; i<4096; i++)
	{
		c[i] = mod_add(a[i] + b[i], prime_index);
	}
}

int poly_sub_q(long long int a[], long long int b[], long long int c[], int prime_index)
{

	int i;

	for(i=0; i<4096; i++)
	{
		c[i] = mod_sub(a[i] - b[i], prime_index);
	}
}


int poly_mul_complete(long long int a[][4096], long long int b[][4096], long long int c[][4096], int qarray_length)
{
	int i;

	for(i=0; i<qarray_length; i++)
	poly_mul_q(a[i], b[i], c[i], i);
}

/*
main()
{
	mpz_t a[6][2048], b[6][2048], c[6][2048];

	int i, j, qarray_length;
	long long int p, primrt;
	long long int primrt_array[log_n], inv_primrt_array[log_n];

	mpz_t q[13]; 					// q_complete = 249857*163841*176129*184321*188417*520193			
	mpz_array_init(q[0], 6, 256);
	mpz_set_str(q[0], "249857", 10);
	mpz_set_str(q[1], "163841", 10);
	mpz_set_str(q[2], "176129", 10);
	mpz_set_str(q[3], "184321", 10);
	mpz_set_str(q[4], "188417", 10);
	mpz_set_str(q[5], "520193", 10);
	mpz_set_str(q[6], "495617", 10);
	mpz_set_str(q[7], "471041", 10);
	mpz_set_str(q[8], "430081", 10);
	mpz_set_str(q[9], "417793", 10);
	mpz_set_str(q[10], "380929", 10);
	mpz_set_str(q[11], "331777", 10);
	mpz_set_str(q[12], "319489", 10);

	for(i=0; i<6; i++)
	{
		mpz_array_init(a[i][0], 2048, 256); 
		mpz_array_init(b[i][0], 2048, 256);
		mpz_array_init(c[i][0], 2048, 256);
	}
	
	for(i=0; i<2048; i++)
	{
		for(j=0; j<6; j++)
		{
			mpz_set_si(a[j][i], i);
			mpz_set_si(b[j][i], i);
		}
	}
	
	qarray_length = 6;
	poly_mul_complete(a, b, c, q, qarray_length);

	for(i=2047; i>=0; i--)
	gmp_printf("%Zd\n", c[0][i]);

}
*/

/*
void coefficient_mul_q(long long int a[], long long int b[], long long int c[], int prime_index)
{
	int j;

		for(j=0; j<4096; j++)
		{
			c[j] = mod(a[j] * b[j], prime_index);
		}
}
		
main()
{
	long long int a[4096], b[4096];	
	int i;


	creat_primrt_array( );

	for(i=0; i<4096; i++)
	a[i] = i;

	
	fwd_ntt_q(a, 14);
	//coefficient_mul_q(a, a, b, 1);
	inv_ntt_q(a, 14);
	
	for(i=4095; i>=0; i--)
	printf("%lu\n", a[i]);
}	
*/


