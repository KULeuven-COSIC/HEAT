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
	FILE *fp;

	bitreverse(a);

	int print_prime=6;
	if(prime_index==print_prime)
	fp = fopen("w_values_fwd_q", "w");

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
			if(prime_index==print_prime)
			fprintf(fp, "%lld\n", omega);
			
			for(k=0; k<4096; k=k+m)
			{
				if((prime_index==print_prime)&& m==2048 && j==1023 && k==2048)
				fprintf(fp, "omega=%lld\n", omega); 	
				t1 = mod1(omega * a[k+j+m/2], prime_index);
				u1 = a[k+j];
				a[k+j] = mod_add(u1+t1, prime_index);
				a[k+j+m/2] = mod_sub(u1-t1, prime_index);
			}		
			omega = mod1(omega * primrt, prime_index);

		}
		if(prime_index==print_prime && m==2048) 
		fprintf(fp,"m=2048\n");
	}
	if(prime_index==print_prime)
	fclose(fp);

}


int inv_ntt_q(long long int a[], int prime_index)
{
	int i, j, k, m;
	long long int u1, t1, u2, t2;
	long long int primrt, omega;
	FILE *fp;

	bitreverse(a);


	int print_prime=6;
	if(prime_index==print_prime)
	fp = fopen("w_values_inv_q", "w");

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
			if(prime_index==print_prime)
			fprintf(fp, "%lld\n", omega);

			for(k=0; k<4096; k=k+m)
			{
				//if((prime_index==print_prime)&& m==2048 && j==1023 && k==2048)
				//fprintf(fp, "omega=%lld\n", omega); 	

				t1 = mod1(omega * a[k+j+m/2], prime_index);
				u1 = a[k+j];
				a[k+j] = mod_add(u1+t1, prime_index);
				a[k+j+m/2] = mod_sub(u1-t1, prime_index);
			}		
			omega = mod1(omega * primrt, prime_index);
		}
		//if(prime_index==print_prime && m==2048) 
		//fprintf(fp,"m=2048\n");

	}
	
	
	m = 4096;
		j=1;
		for(i=0; j<m; i++)
		{
			j=j*2;
		}

		primrt = inv_primrt_array[prime_index][i];
		//omega = 1;
		omega = n_inv[prime_index];		

		for(j=0; j<m; j++)
		{
			if(prime_index==print_prime)
			fprintf(fp, "%lld\n", omega);

			a[j] = mod1(omega * a[j], prime_index);
			omega = mod1(omega * primrt, prime_index);
		}	

		/*	
		omega = n_inv[prime_index];		
		for(j=0; j<m; j++)
		{
			a[j] = mod1(a[j]*omega, prime_index); 
		}	
		*/
	if(prime_index==print_prime)
	fclose(fp);

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
