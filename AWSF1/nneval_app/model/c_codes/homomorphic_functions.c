static long long int sk[NUM_PRIME][4096];
static long long int pk0[NUM_PRIME][4096], pk1[NUM_PRIME][4096];
static long long int rlk00[NUM_PRIME][4096], rlk01[NUM_PRIME][4096], rlk10[NUM_PRIME][4096], rlk11[NUM_PRIME][4096];
//static long long int rlk20[NUM_PRIME][4096], rlk21[NUM_PRIME][4096], rlk30[NUM_PRIME][4096], rlk31[NUM_PRIME][4096], rlk40[NUM_PRIME][4096], rlk41[NUM_PRIME][4096];

//mpz_t quotient[THREADS], rem[THREADS];
//mpz_t temp_array64[THREADS]; 
//mpz_t chunk[THREADS]; 
//mpz_t temp_array512[THREADS]; 

// #include "lift_c_accurate.c"

void read_keys()
{
	FILE *fp;
	int i, j;
	static mpz_t big_array[4096];
	mpz_t big, temp;
	
	mpz_array_init(big_array[0], 4096, 256);
	mpz_init(big); mpz_init(temp);

///////////////////////////////////////////////////////////////////////////
///////////////////////  Public key reading   /////////////////////////////

	

	fp = fopen("sage_generated_key/pk0", "r");
	for(i=0; i<4096; i++)
	{
		gmp_fscanf(fp, "%Zd", big_array[i]);
	}
	fclose(fp);
	
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, pk0[i], i);
	}
	
	fp = fopen("sage_generated_key/pk1", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, pk1[i], i);
	}
	fp = fopen("sage_generated_key/sk", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, sk[i], i);
	}




/*
	fp = fopen("keys/pk0_0to4095_q0", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk0[0][i]);
	fclose(fp);
	fp = fopen("keys/pk0_0to4095_q1", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk0[1][i]);
	fclose(fp);
	fp = fopen("keys/pk0_0to4095_q2", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk0[2][i]);
	fclose(fp);
	fp = fopen("keys/pk0_0to4095_q3", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk0[3][i]);
	fclose(fp);
	fp = fopen("keys/pk0_0to4095_q4", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk0[4][i]);
	fclose(fp);
	fp = fopen("keys/pk0_0to4095_q5", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk0[5][i]);
	fclose(fp);
	fp = fopen("keys/pk0_0to4095_q6", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk0[6][i]);
	fclose(fp);




	fp = fopen("keys/pk1_0to4095_q0", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk1[0][i]);
	fclose(fp);
	fp = fopen("keys/pk1_0to4095_q1", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk1[1][i]);
	fclose(fp);
	fp = fopen("keys/pk1_0to4095_q2", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk1[2][i]);
	fclose(fp);
	fp = fopen("keys/pk1_0to4095_q3", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk1[3][i]);
	fclose(fp);
	fp = fopen("keys/pk1_0to4095_q4", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk1[4][i]);
	fclose(fp);
	fp = fopen("keys/pk1_0to4095_q5", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk1[5][i]);
	fclose(fp);
	fp = fopen("keys/pk1_0to4095_q6", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &pk1[6][i]);
	fclose(fp);


	fp = fopen("keys/sk_0to4095_q0", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &sk[0][i]);
	fclose(fp);
	fp = fopen("keys/sk_0to4095_q1", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &sk[1][i]);
	fclose(fp);
	fp = fopen("keys/sk_0to4095_q2", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &sk[2][i]);
	fclose(fp);
	fp = fopen("keys/sk_0to4095_q3", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &sk[3][i]);
	fclose(fp);
	fp = fopen("keys/sk_0to4095_q4", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &sk[4][i]);
	fclose(fp);
	fp = fopen("keys/sk_0to4095_q5", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &sk[5][i]);
	fclose(fp);
	fp = fopen("keys/sk_0to4095_q6", "r");
	for(i=0; i<4096; i++)
	fscanf(fp, "%lu", &sk[6][i]);
	fclose(fp);
*/

///////////////////////////////////////////////////////////////////////////
////////////////  Relinearisation key reading /////////////////////////////

	fp = fopen("sage_generated_key/rlk0_0", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk00[i], i);
	}
	fp = fopen("sage_generated_key/rlk0_1", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk01[i], i);
	}
	fp = fopen("sage_generated_key/rlk1_0", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk10[i], i);
	}
	fp = fopen("sage_generated_key/rlk1_1", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk11[i], i);
	}


/*
	fp = fopen("keys/rlk00_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk00[i], i);
	}
	fp = fopen("keys/rlk01_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk01[i], i);
	}
	fp = fopen("keys/rlk10_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk10[i], i);
	}
	fp = fopen("keys/rlk11_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<7; i++)
	{
		compute_mod(big_array, rlk11[i], i);
	}
	fp = fopen("keys/rlk20_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk20[i], i);
	}
	fp = fopen("keys/rlk21_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk21[i], i);
	}
	fp = fopen("keys/rlk30_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk30[i], i);
	}
	fp = fopen("keys/rlk31_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk31[i], i);
	}
	fp = fopen("keys/rlk40_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk40[i], i);
	}
	fp = fopen("keys/rlk41_0to4095", "r");
	for(i=0; i<4096; i++)
	gmp_fscanf(fp, "%Zd", big_array[i]);
	fclose(fp);
	for(i=0; i<NUM_PRIME; i++)
	{
		compute_mod(big_array, rlk41[i], i);
	}
*/

///////////////////////////////////////////////////////////////////////////
//////////////////  Compute FFT of the keys   /////////////////////////////


	for(i=0; i<NUM_PRIME; i++)
	{	
		fwd_ntt_q(pk0[i], i);
		fwd_ntt_q(pk1[i], i);
		fwd_ntt_q(sk[i], i);

		fwd_ntt_q(rlk00[i], i);
		fwd_ntt_q(rlk01[i], i);
		fwd_ntt_q(rlk10[i], i);
		fwd_ntt_q(rlk11[i], i);
		//fwd_ntt_q(rlk20[i], i);
		//fwd_ntt_q(rlk21[i], i);
		//fwd_ntt_q(rlk30[i], i);
		//fwd_ntt_q(rlk31[i], i);
		//fwd_ntt_q(rlk40[i], i);
		//fwd_ntt_q(rlk41[i], i);
	}
}


void FV_recrypt(long long int c0[][4096], long long int c1[][4096])
{
	int m[4096];

	FV_dec_q(m, c0, c1);
	FV_enc_q(m, c0, c1);
}

void FV_enc_q(int m[], long long int c0[][4096], long long int c1[][4096])
{
	int i, j, r;
	long long int primrt;
	
	long long int m_encoded[4096], e1[4096], e2[4096], u[4096], u_copy[4096], pk0_mul_u[4096], pk1_mul_u[4096], e1_plus_m_encoded[4096];	

	knuth_yao(e1);	
	knuth_yao(e2);	

	for(i=0; i<4096; i++)
	{
		r = rand() % 2;
		if(rand()%2==1)
			r = -r;
		u[i] = r;
	}

	
	for(i=0; i<NUM_PRIME; i++)
	{	
		for(j=0; j<4096; j++)
		m_encoded[j] = m[j] * pby_t[i];
		
		poly_copy(u, u_copy);	
		fwd_ntt_q(u_copy, i);

		//fwd_ntt_q(pk0[i], i);
		//fwd_ntt_q(pk1[i], i);
		coefficient_mul_q(pk0[i], u_copy, pk0_mul_u, i);	
		coefficient_mul_q(pk1[i], u_copy, pk1_mul_u, i);	// e1_plus_m_encoded <-- m_encoded + e1 
		inv_ntt_q(pk0_mul_u, i);				// pk0_mul_u <-- pk0*u
		inv_ntt_q(pk1_mul_u, i);				// pk1_mul_u <-- pk1*u


		coefficient_add_q(e1, m_encoded, e1_plus_m_encoded, i);		// e1_plus_m_encoded <-- m_encoded + e1 
		coefficient_add_q(pk0_mul_u, e1_plus_m_encoded, c0[i], i);	// c0[i] <-- pk0*u + e1 + m_encoded 
		coefficient_add_q(pk1_mul_u, e2, c1[i], i);			// c1[i] <-- pk1*u + e2  
	}
}

/*
void create_crt_rom(mpz_t q[], int length)
{
	int i, j;
	mpz_t q_full, Ni, Ni_inv, temp;
	mpz_init(q_full);
	mpz_init(Ni);
	mpz_init(Ni_inv);
	mpz_init(temp);

	mpz_t mask;
	mpz_init(mask);

	mpz_set_str(q_full, "1", 10);
	mpz_set_str(mask, "262143", 10);	
	
	for(i=0; i<length; i++)
	mpz_mul(q_full, q_full, q[i]);


		for(j=0; j<length; j++)		
		{
			mpz_fdiv_q(Ni, q_full, q[j]);
			mpz_invert(Ni_inv, Ni, q[j]);

			gmp_printf("mux8_18bits	rom(18'd%Zd, ", Ni_inv);
			
			for(i=0; i<length-1; i++)
			{
				mpz_and(temp, Ni, mask);

				if(i<length-2)
				gmp_printf("18'd%Zd, ", temp);
				else
				gmp_printf("18'd%Zd, 18'd0, 18'd0, address, dataout);\n\n", temp);
	
				mpz_sub(Ni, Ni, temp);
				mpz_fdiv_q_2exp(Ni, Ni, 18);
			}
		}
}
*/



void inverse_crt_length7(long long int c0[][4096], mpz_t c0_full[])
{
	int i, j;

	int thread_num;
	mpz_t temp;
	mpz_init(temp);
		//#pragma omp parallel for private(thread_num, j)
		for(i=0; i<4096; i++)
		{	
			//thread_num = omp_get_thread_num();	
			for(j=0; j<NUM_PRIME; j++)		
			{
				mpz_mul_ui(temp, Ni_length7[j], c0[j][i]);
				mpz_mul(temp, temp, Ni_inv_length7[j]);
				mpz_mod(temp, temp, p_full_length7);	// temp = c0[i][j]*Ni*Ni_inv mod q_full
		
				if(j==0)
				mpz_set(c0_full[i], temp);
				else
				mpz_add(c0_full[i], c0_full[i], temp);
			}
			mpz_mod(c0_full[i], c0_full[i], p_full_length7);	
		}
}


void inverse_crt_length15(long long int c0[][4096], mpz_t c0_full[])
{
	int i, j;
	int thread_num;
	mpz_t temp;
	mpz_init(temp);
	
		//#pragma omp parallel for private(thread_num, j)
		for(i=0; i<4096; i++)
		{	
			for(j=0; j<NUM_PRIME_EXT; j++)		
			{
				mpz_mul_ui(temp, Ni_length15[j], c0[j][i]);
				mpz_mul(temp, temp, Ni_inv_length15[j]);
				mpz_mod(temp, temp, p_full_length15);	// temp = c0[i][j]*Ni*Ni_inv mod q_full
		
				if(j==0)
				mpz_set(c0_full[i], temp);
				else
				mpz_add(c0_full[i], c0_full[i], temp);
			}
			mpz_mod(c0_full[i], c0_full[i], p_full_length15);	
		}
}


int round_tx(mpz_t a[])	// computes round(t*c/q)
{
	int i;
	int thread_num;
	
	mpz_t quotient, rem;
	mpz_init(quotient);
	mpz_init(rem);


	//#pragma omp parallel for private(thread_num)
	for(i=4095; i>=0; i--)
	{
		//thread_num = omp_get_thread_num();

		mpz_mul_ui(a[i], a[i], t);	// a[i] <-- a[i]*t
		if(mpz_cmp_ui(a[i], 0)<0)	// a[i] is -ve
		{
			mpz_ui_sub(a[i], 0, a[i]);
			mpz_fdiv_qr(quotient, rem, a[i], p_full_length7);
			if(mpz_cmp(rem, p_full_length7_by2)>0)
			mpz_add_ui(quotient, quotient, 1);
			mpz_ui_sub(a[i], 0, quotient);
		}
		else
		{
			mpz_fdiv_qr(quotient, rem, a[i], p_full_length7);
			if(mpz_cmp(rem, p_full_length7_by2)>0)
			mpz_add_ui(quotient, quotient, 1);
			//gmp_printf("quo rem p_full_length7_by2 %Zd  %Zd %Zd\n", quotient, rem, p_full_length7_by2);
			mpz_set(a[i], quotient);
		}
	}
}

int round_tx_mod(mpz_t a[])	// computes mod( round(t*c/q), q )
{
	int i;
	int thread_num;
	
	mpz_t quotient, rem;
	mpz_init(quotient);
	mpz_init(rem);


	//#pragma omp parallel for private(thread_num)
	for(i=0; i<4096; i++)
	{
		//thread_num = omp_get_thread_num();

		mpz_mul_ui(a[i], a[i], t);

		if(mpz_cmp_ui(a[i], 0)<0)	// a[i] is -ve
		{
			mpz_ui_sub(a[i], 0, a[i]);
			mpz_fdiv_qr(quotient, rem, a[i], p_full_length7);
			if(mpz_cmp(rem, p_full_length7_by2))
			mpz_add_ui(quotient, quotient, 1);
			mpz_ui_sub(a[i], 0, quotient);
			mpz_mod(a[i], a[i], p_full_length7);
		}
		else
		{
			mpz_fdiv_qr(quotient, rem, a[i], p_full_length7);
			if(mpz_cmp(rem, p_full_length7_by2))
			mpz_add_ui(quotient, quotient, 1);
			mpz_set(a[i], quotient);
			mpz_mod(a[i], a[i], p_full_length7);
		}
	}
}

void FV_dec_q(int m[], long long int c0[][4096], long long int c1[][4096])
{
	int i;

	long long int sk_mul_c1[NUM_PRIME][4096];
	mpz_t c1_full[4096];	
	mpz_t temp;

	mpz_array_init(c1_full[0], 4096, 512);
	mpz_init(temp);

	for(i=0; i<NUM_PRIME; i++)
	{
		fwd_ntt_q(c1[i], i);
		coefficient_mul_q(sk[i], c1[i], sk_mul_c1[i], i);
		inv_ntt_q(sk_mul_c1[i], i);

		coefficient_add_q(c0[i], sk_mul_c1[i], sk_mul_c1[i], i);	// sk_mul_c1 <-- c0 + sk_mul_c1 
	}
	
	inverse_crt_length7(sk_mul_c1, c1_full);

	centerlift(c1_full);
	round_tx(c1_full);	// round t*c/q

	for(i=4095; i>=0; i--)
	{
		//if(mpz_cmp(c1_full[i], p_full_length7_by4)>=0 && mpz_cmp(c1_full[i], p_full_length7_by4_mul3)<0)
		//m[i]=1;
		//else 
		//m[i]=0;

		mpz_mod_ui(temp, c1_full[i], t);	// temp = c1_full[i] % t
		m[i] = mpz_get_ui(temp);
		
	}

	mpz_clear(c1_full[0]);
}

int FV_add(long long int c10[][4096], long long int c11[][4096], long long int c20[][4096], long long int c21[][4096], long long int c0[][4096], long long int c1[][4096])
{
	int i;
	
	for(i=0; i<NUM_PRIME; i++)
	{
		poly_add_q(c10[i], c20[i], c0[i], i);
		poly_add_q(c11[i], c21[i], c1[i], i);
	}
}

int FV_sub(long long int c10[][4096], long long int c11[][4096], long long int c20[][4096], long long int c21[][4096], long long int c0[][4096], long long int c1[][4096])
{
	int i;
	
	for(i=0; i<NUM_PRIME; i++)
	{
		poly_sub_q(c10[i], c20[i], c0[i], i);
		poly_sub_q(c11[i], c21[i], c1[i], i);
	}
}



int FV_mul(long long int c10[][4096], long long int c11[][4096], long long int c20[][4096], long long int c21[][4096], long long int c0[][4096], long long int c1[][4096])
{
	int i, j, index;
	FILE *fp;
	long long int c10_QL[NUM_PRIME_EXT][4096], c11_QL[NUM_PRIME_EXT][4096], c20_QL[NUM_PRIME_EXT][4096], c21_QL[NUM_PRIME_EXT][4096], c2[NUM_PRIME_EXT][4096];
	long long int c10_mul_c20[NUM_PRIME_EXT][4096], c10_mul_c21[NUM_PRIME_EXT][4096], c11_mul_c20[NUM_PRIME_EXT][4096], c11_mul_c21[NUM_PRIME_EXT][4096];
	mpz_t c10_full[4096], c11_full[4096], c20_full[4096], c21_full[4096];
	mpz_t c0_full[4096], c1_full[4096], c2_full[4096];

	long long int primrt;
	int num_thread;	

	mpz_array_init(c10_full[0], 4096, 512);
	mpz_array_init(c11_full[0], 4096, 512);
	mpz_array_init(c20_full[0], 4096, 512);
	mpz_array_init(c21_full[0], 4096, 512);
	mpz_array_init(c0_full[0], 4096, 512); 
	mpz_array_init(c1_full[0], 4096, 512); 
	mpz_array_init(c2_full[0], 4096, 512); 


	inverse_crt_length7(c10, c10_full);
	inverse_crt_length7(c11, c11_full);
	inverse_crt_length7(c20, c20_full);
	inverse_crt_length7(c21, c21_full);


	centerlift(c10_full);
	centerlift(c11_full);
	centerlift(c20_full);
	centerlift(c21_full);

	map_to_QL(c10_full, c10_QL);
	map_to_QL(c11_full, c11_QL);
	map_to_QL(c20_full, c20_QL);
	map_to_QL(c21_full, c21_QL);


	//#pragma omp parallel for
	for(i=0; i<NUM_PRIME_EXT; i++)
	{
			fwd_ntt_q(c10_QL[i], i);
			fwd_ntt_q(c11_QL[i], i);
			fwd_ntt_q(c20_QL[i], i);
			fwd_ntt_q(c21_QL[i], i);

			coefficient_mul_q(c10_QL[i], c20_QL[i], c10_mul_c20[i], i);	
			coefficient_mul_q(c10_QL[i], c21_QL[i], c10_mul_c21[i], i);
			coefficient_mul_q(c11_QL[i], c20_QL[i], c11_mul_c20[i], i);		
			coefficient_mul_q(c11_QL[i], c21_QL[i], c11_mul_c21[i], i);		

			inv_ntt_q(c10_mul_c20[i], i);							// c0[i] = c10*c20 mod q[i]
			poly_copy(c10_mul_c20[i], c0[i]);

			coefficient_add_q(c10_mul_c21[i], c11_mul_c20[i], c1[i], i); 
			inv_ntt_q(c1[i], i);						// c1[i] = c10*c21 mod q[i]

			inv_ntt_q(c11_mul_c21[i], i);					// c2[i] = c11*c21 mod q[i]
			poly_copy(c11_mul_c21[i], c2[i]);
	}

	
	long long int c0_temp[13][4096];
	for(i=0; i<13; i++)
	for(j=0; j<4096; j++)
		c0_temp[i][j] = c0[i][j];

	inverse_crt_length15(c0, c0_full);
	centerlift_QL(c0_full);
	round_tx_mod(c0_full);
	compute_shares(c0_full, c0);
	/*
	uint32_t result[6];
	uint8_t sign_result;
	uint32_t kk[13];

	for(j=0; j<4096; j++)
	{
		for(i=0; i<13; i++)
		kk[i] = c0[i][j];

		crt_Q(kk, result, &sign_result);
		compute_shares_qi(result, sign_result, kk);

		for(i=0; i<6; i++)
			c0[i][j] = kk[i];
	}
	*/
	inverse_crt_length15(c1, c1_full);
	centerlift_QL(c1_full);
	round_tx_mod(c1_full);
	compute_shares(c1_full, c1);
	/*
	for(j=0; j<4096; j++)
	{
		for(i=0; i<13; i++)
		kk[i] = c1[i][j];

		crt_Q(kk, result, &sign_result);
		compute_shares_qi(result, sign_result, kk);

		for(i=0; i<6; i++)
			c1[i][j] = kk[i];
	}
	*/
	inverse_crt_length15(c2, c2_full);
	centerlift_QL(c2_full);
	round_tx_mod(c2_full);
	centerlift(c2_full);

	
	FV_relin(c0, c1, c2_full);

	mpz_clear(c10_full[0]); 
	mpz_clear(c11_full[0]); 
	mpz_clear(c20_full[0]); 
	mpz_clear(c21_full[0]); 
	mpz_clear(c0_full[0]);
	mpz_clear(c1_full[0]);
	mpz_clear(c2_full[0]);
}

int FV_relin(long long int c0_shares[][4096], long long int c1_shares[][4096], mpz_t c2_full[])
{ 

	int i;	

	mpz_t cwd0[4096], cwd1[4096], cwd2[4096], cwd3[4096], cwd4[4096];
	
	mpz_array_init(cwd0[0], 4096, 256);
	mpz_array_init(cwd1[0], 4096, 256);
	mpz_array_init(cwd2[0], 4096, 256);
	mpz_array_init(cwd3[0], 4096, 256);
	mpz_array_init(cwd4[0], 4096, 256);

	long long int rlk0_mul_cwd[NUM_PRIME][4096], rlk1_mul_cwd[NUM_PRIME][4096];
	long long int cwd0_shares[NUM_PRIME][4096], cwd1_shares[NUM_PRIME][4096], cwd2_shares[NUM_PRIME][4096], cwd3_shares[NUM_PRIME][4096], cwd4_shares[NUM_PRIME][4096];
	long long int temp[NUM_PRIME][4096];


	word_decomp(c2_full, cwd0, cwd1, cwd2, cwd3, cwd4);

	compute_shares(cwd0, cwd0_shares);
	compute_shares(cwd1, cwd1_shares);
	compute_shares(cwd2, cwd2_shares);
	compute_shares(cwd3, cwd3_shares);
	compute_shares(cwd4, cwd4_shares);

	for(i=0; i<NUM_PRIME; i++)
	{
		fwd_ntt_q(cwd0_shares[i], i);
		coefficient_mul_q(rlk00[i], cwd0_shares[i], rlk0_mul_cwd[i], i);

		fwd_ntt_q(cwd1_shares[i], i);
		coefficient_mul_q(rlk10[i], cwd1_shares[i], temp[i], i);
		coefficient_add_q(rlk0_mul_cwd[i], temp[i], rlk0_mul_cwd[i], i);	// rlk0_mul_cwd[i] = rlk00[i]*cwd0_shares[i] + rlk10[i]*cwd1_shares[i]
		/*
		fwd_ntt_q(cwd2_shares[i], i);
		coefficient_mul_q(rlk20[i], cwd2_shares[i], temp[i], i);
		coefficient_add_q(rlk0_mul_cwd[i], temp[i], rlk0_mul_cwd[i], i);	// rlk0_mul_cwd[i] = rlk00[i]*cwd0_shares[i]+rlk10[i]*cwd1_shares[i]+rlk20[i]*cwd2_shares[i]

		fwd_ntt_q(cwd3_shares[i], i);
		coefficient_mul_q(rlk30[i], cwd3_shares[i], temp[i], i);
		coefficient_add_q(rlk0_mul_cwd[i], temp[i], rlk0_mul_cwd[i], i);	

		fwd_ntt_q(cwd4_shares[i], i);
		coefficient_mul_q(rlk40[i], cwd4_shares[i], temp[i], i);
		coefficient_add_q(rlk0_mul_cwd[i], temp[i], rlk0_mul_cwd[i], i);  	// rlk0_mul_cwd[i] = sum( rlk_j0[i]*cwd_j_shares[i])
		*/

		coefficient_mul_q(rlk01[i], cwd0_shares[i], rlk1_mul_cwd[i], i);

		coefficient_mul_q(rlk11[i], cwd1_shares[i], temp[i], i);
		coefficient_add_q(rlk1_mul_cwd[i], temp[i], rlk1_mul_cwd[i], i);	

		/*
		coefficient_mul_q(rlk21[i], cwd2_shares[i], temp[i], i);
		coefficient_add_q(rlk1_mul_cwd[i], temp[i], rlk1_mul_cwd[i], i);	

		coefficient_mul_q(rlk31[i], cwd3_shares[i], temp[i], i);
		coefficient_add_q(rlk1_mul_cwd[i], temp[i], rlk1_mul_cwd[i], i);	

		coefficient_mul_q(rlk41[i], cwd4_shares[i], temp[i], i);
		coefficient_add_q(rlk1_mul_cwd[i], temp[i], rlk1_mul_cwd[i], i);  // rlk1_mul_cwd[i] = sum( rlk_j1[i]*cwd_j_shares[i])
		*/

		inv_ntt_q(rlk0_mul_cwd[i], i);		
		inv_ntt_q(rlk1_mul_cwd[i], i);		

		coefficient_add_q(c0_shares[i], rlk0_mul_cwd[i], c0_shares[i], i);		// c0_shares[i] = c0_shares[i]+ sum[rlk_i0*cwd_i] 
		coefficient_add_q(c1_shares[i], rlk1_mul_cwd[i], c1_shares[i], i);		// c1_shares[i] = c1_shares[i]+ sum[rlk_i1*cwd_i] 
	}



	mpz_clear(cwd0[0]); mpz_clear(cwd1[0]); mpz_clear(cwd2[0]); mpz_clear(cwd3[0]); mpz_clear(cwd4[0]);
}


int word_decomp(mpz_t c[], mpz_t cwd0[], mpz_t cwd1[], mpz_t cwd2[], mpz_t cwd3[], mpz_t cwd4[])
{
	int i, j;
	int sign;

	mpz_t mask; mpz_init(mask);
	mpz_set_str(mask, "2475880078570760549798248447", 10);	// mask=2^32-1

	mpz_t two_to_32; mpz_init(two_to_32);
	mpz_set_str(two_to_32, "2475880078570760549798248448", 10);

	mpz_t two_to_31; mpz_init(two_to_31);
	mpz_set_str(two_to_31, "1237940039285380274899124224", 10);

	mpz_t chunk;
	mpz_init(chunk);
	

	int thread_num;

		
	//#pragma omp parallel for private(thread_num, sign, j)
	for(i=0; i<4096; i++)
	{
		//thread_num = omp_get_thread_num();

		sign=0;
		if(mpz_cmp_ui(c[i], 0)<0)
		{
			sign = 1;
			mpz_ui_sub(c[i], 0, c[i]);
		}

		for(j=0; j<2; j++)
		{
			mpz_and(chunk, c[i], mask);	
		 	mpz_sub(c[i], c[i], chunk);
			mpz_fdiv_q_2exp(c[i], c[i], 91);	// c[i] = c[i]>>91
			
			if(mpz_cmp(chunk, two_to_31)>0)	// if chunk > 2^31
			{
				mpz_sub(chunk, chunk, two_to_32);	// chunk = chunk- 2^32
				mpz_add_ui(c[i], c[i], 1);
			}
			
			if(sign) mpz_ui_sub(chunk, 0, chunk);	// chunk = -chunk

			if(j==0) mpz_mod(cwd0[i], chunk, p_full_length7);
			if(j==1) mpz_mod(cwd1[i], chunk, p_full_length7);
			if(j==2) mpz_mod(cwd2[i], chunk, p_full_length7);
			if(j==3) mpz_mod(cwd3[i], chunk, p_full_length7);
			if(j==4) mpz_mod(cwd4[i], chunk, p_full_length7);
		}
	}
}

int word_decomp_32bit(mpz_t c[], mpz_t cwd0[], mpz_t cwd1[], mpz_t cwd2[], mpz_t cwd3[], mpz_t cwd4[])
{
	int i, j;
	int sign;

	mpz_t mask; mpz_init(mask);
	mpz_set_str(mask, "4294967295", 10);	// mask=2^32-1

	mpz_t two_to_32; mpz_init(two_to_32);
	mpz_set_str(two_to_32, "4294967296", 10);

	mpz_t two_to_31; mpz_init(two_to_31);
	mpz_set_str(two_to_31, "2147483648", 10);

	mpz_t chunk;
	mpz_init(chunk);
	

	int thread_num;

		
	//#pragma omp parallel for private(thread_num, sign, j)
	for(i=0; i<4096; i++)
	{
		//thread_num = omp_get_thread_num();

		sign=0;
		if(mpz_cmp_ui(c[i], 0)<0)
		{
			sign = 1;
			mpz_ui_sub(c[i], 0, c[i]);
		}

		for(j=0; j<5; j++)
		{
			mpz_and(chunk, c[i], mask);	
		 	mpz_sub(c[i], c[i], chunk);
			mpz_fdiv_q_2exp(c[i], c[i], 32);	// c[i] = c[i]>>32
			
			if(mpz_cmp(chunk, two_to_31)>0)	// if chunk > 2^31
			{
				mpz_sub(chunk, chunk, two_to_32);	// chunk = chunk- 2^32
				mpz_add_ui(c[i], c[i], 1);
			}
			
			if(sign) mpz_ui_sub(chunk, 0, chunk);	// chunk = -chunk

			if(j==0) mpz_mod(cwd0[i], chunk, p_full_length7);
			if(j==1) mpz_mod(cwd1[i], chunk, p_full_length7);
			if(j==2) mpz_mod(cwd2[i], chunk, p_full_length7);
			if(j==3) mpz_mod(cwd3[i], chunk, p_full_length7);
			if(j==4) mpz_mod(cwd4[i], chunk, p_full_length7);
		}
	}
}



void compute_shares(mpz_t a[], long long int a_shares[][4096])
{
	int i, j;

	int thread_num;

	mpz_t temp;
	mpz_init(temp);

	//#pragma omp parallel for private(thread_num, j)
	for(i=0; i<4096; i++)
	{
		//thread_num = omp_get_thread_num();
		for(j=0; j<NUM_PRIME; j++)
		{
			mpz_mod_ui(temp, a[i], p[j]);		
			a_shares[j][i] = mpz_get_ui(temp);
		}
	}
}	

void compute_mod(mpz_t a[],long long int b[], int prime_index)
{
	int i;
	mpz_t temp; mpz_init(temp);

	for(i=0; i<4096; i++)
	{
		mpz_mod_ui(temp, a[i], p[prime_index]);
		b[i] = mpz_get_ui(temp);
	}
}

int centerlift(mpz_t a[])
{
	int i;

	//#pragma omp parallel for
	for(i=0; i<4096; i++)
	{
		if(mpz_cmp(a[i], p_full_length7_by2)>0)
		mpz_sub(a[i], a[i], p_full_length7);		// a[i] = a[i]-q	
	}
}






int centerlift_QL(mpz_t a[])
{
	int i;

	//#pragma omp parallel for
	for(i=0; i<4096; i++)
	{
		if(mpz_cmp(a[i], p_full_length15_by2)>0)
		mpz_sub(a[i], a[i], p_full_length15);		// a[i] = a[i]-q	
	}
}

int map_to_QL(mpz_t a[], long long int b[][4096])
{
	int i, j;


	int thread_num;
	mpz_t temp; mpz_init(temp);

	//#pragma omp parallel for private(thread_num, j)	
	for(i=0; i<4096; i++)
	{
		mpz_mod(a[i], a[i], p_full_length15);	

		for(j=0; j<NUM_PRIME_EXT; j++)
		{		
			mpz_mod_ui(temp, a[i], p[j]);
			b[j][i] = mpz_get_ui(temp);
		}
	}
	
}	


void coefficient_mul_q(long long int a[], long long int b[], long long int c[], int prime_index)
{
	int j;

		for(j=0; j<4096; j++)
		{
			c[j] = mod(a[j] * b[j], prime_index);
		}
}



void coefficient_add_q(long long int a[], long long int b[], long long int c[], int prime_index)
{
	int j;

		for(j=0; j<4096; j++)
		{
			c[j] = mod(a[j] + b[j], prime_index);
		}
}



void message_gen(int m[])
{
	FILE *fm;
	int i, r1, r2;

	for(i=0;i<4096;i++)
	{
		m[i]=0;
	}
	m[0]=random()%2;
}


void poly_copy(long long int a[], long long int b[])
{
	int i;

	for(i=0; i<4096; i++)
	b[i] = a[i];
}



/*
void message_encrypt(int m, mpz_t c[])
{
	int message[4096];
	int i;

	for(i=0; i<4096; i++)
	message[i] = 0;

	message[0] = m;

	YASHE_enc(message, c);
}
*/
