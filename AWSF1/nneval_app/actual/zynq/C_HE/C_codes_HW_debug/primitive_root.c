//#include<stdio.h>
//#include<stdlib.h>
//#include<gmp.h>
#define n 8192 
#define log_n 13



//long long int p[] = {1073153, 1097729, 1130497, 1146881, 1179649, 1196033, 1253377, 1318913, 1376257, 1417217, 1589249, 1597441, 1662977, 1712129, 1720321};
//long long int pby2[] = {536577, 548865, 565249, 573441, 589825, 598017, 626689, 659457, 688129, 708609, 794625, 798721, 831489, 856065, 860161};
//long long int n_inv[] = {1072891, 1097461, 1130221, 1146601, 1179361, 1195741, 1253071, 1318591, 1375921, 1416871, 1588861, 1597051, 1662571, 1711711, 1719901};


long long int p[] = {1068564481, 1069219841, 1070727169, 1071513601, 1072496641, 1073479681, 
                    1068433409, 1068236801, 1065811969, 1065484289, 1064697857, 1063452673, 1063321601};
//long long int pby_t[] = {1068564481/t, 1069219841/t, 1070727169/t, 1071513601/t, 1072496641/t, 1073479681/t};
//long long int pby_t[] = {534282240, 534609920, 535363584, 535756800, 536248320, 536739840};
long long int pby_t[NUM_PRIME];
long long int n_inv[] = {1068303601, 1068958801, 1070465761, 1071252001, 1072234801, 1073217601, 1068172561, 1067976001, 1065551761, 1065224161, 1064437921, 1063193041, 1063062001};



mpz_t p_full_length7, p_full_length7_by2, p_full_length7_by4, p_full_length7_by4_mul3, Ni_length7[NUM_PRIME], Ni_inv_length7[NUM_PRIME];	
mpz_t p_full_length15, p_full_length15_by2, Ni_length15[NUM_PRIME_EXT], Ni_inv_length15[NUM_PRIME_EXT];	

long long int primrt_array[NUM_PRIME_EXT][log_n], inv_primrt_array[NUM_PRIME_EXT][log_n];
unsigned long long barrett_constants[NUM_PRIME_EXT];

long long int barrett(long long int a, int prime_index)
{
	long long int quo, rem;
	//printf("prime_index, barrett_constants[prime_index], a, mod = %d %lld %lld %lld\n", prime_index, barrett_constants[prime_index], a, rem);

	quo = a * barrett_constants[prime_index];	// 42 bit input and 21 bit prime
	//printf("quo=%lld\n", quo);
	quo = quo>>42;
	rem = a - quo * p[prime_index];
	if(rem > p[prime_index])
		rem = rem - p[prime_index];

	//printf("prime_index, a, mod = %d %llu %llu\n", prime_index, a, rem);
	return(rem);
}

void compute_barrett_constants()
{
	int i;
	unsigned long long pow_of_two = 4398046511104llu;	// 2^42;
	
	for(i=0; i<NUM_PRIME_EXT; i++)
	{
		barrett_constants[i] = pow_of_two/p[i];
		printf("bc = %llu\n", barrett_constants[i]);
	}
}

long long int mod_add(long long int a, int prime_index)	// mod for addition
{
	if(a>=p[prime_index])
	a = a - p[prime_index];
	
	return(a);
}

long long int mod_sub(long long int a, int prime_index)	// mod for subtraction
{
	if(a<0)
	a = a + p[prime_index];
	
	return(a);
}

long long int mod(long long int a, int prime_index)
{
	long long int quotient, remainder;

	quotient = a/p[prime_index];

	if(a>=0)
		remainder = a - quotient*p[prime_index];
	else
		remainder = (1-quotient)*p[prime_index] + a;			
	
	return(remainder);
}

long long int mod33(long long int a)
{
	long long int quotient, remainder;

	quotient = a/33;

	if(a>=0)
		remainder = a - quotient*33;
	else
		remainder = (1-quotient)*33 + a;			
	
	return(remainder);
}

long long int pow2(int pw)
{
	long long int temp;
	int i;
	
	temp=1;
	for(i=0; i<pw; i++)
	temp = temp*2;	

	return(temp);
}
long long int primitive_root_find(int prime_index)
{
	int i, j;
	long long int temp;

	i=2;
	while(i < p[prime_index]-1)
	{
		temp = i;
		
		for(j=2; j<=n; j=2*j)
		{
			temp = mod(temp*temp, prime_index);
			if(temp==1 && j<n) goto L1;
			if(temp==1 && j==n) goto L2;
		}
		
		L1: i++;
	}
	
	L2: return(i);
}
int print_to_file(long long int ROM[][20], int prime_index)
{
	int m, i;

	for(i=0; i<16; i++)
	{
		printf("module ROM1_c%d_%d(ROM1_pt, ROM1_out);\n", i, p[prime_index]);
		printf("input [3:0] ROM1_pt;\n");
		printf("output [29:0] ROM1_out;\n");

		printf("assign ROM1_out =\n");
		for(m=0; m<15; m++)
		{
			printf("    (ROM1_pt==4'd%d) ? 30'd%d :\n", m, ROM[i][m]);
		}
		printf("    30'd%d;\n", ROM[i][m]);
		printf("endmodule\n");
	}
}

void creat_primrt_array( )
{
	int i, prime_index;
	long long int primrt, temp;

	mpz_t a, b, pmp;
	mpz_init(a);
	mpz_init(b);
	mpz_init(pmp);
	
	for(prime_index=0; prime_index<NUM_PRIME_EXT; prime_index++)
	{
	
		primrt = primitive_root_find(prime_index);
		mpz_set_ui(pmp, p[prime_index]);

		temp = primrt;
		for(i=log_n-1; i>=0; i--)
		{
			primrt_array[prime_index][i] = temp;
			temp = mod(temp*temp, prime_index);

			mpz_set_ui(a, primrt_array[prime_index][i]);
			mpz_invert(b, a, pmp);
			inv_primrt_array[prime_index][i]=mpz_get_ui(b);
		}
	}
}




void compute_crt_constants()
{
	int i;

	mpz_init(p_full_length7);
	mpz_init(p_full_length7_by4); 
	mpz_init(p_full_length7_by4_mul3); 

	
	mpz_array_init(Ni_length7[0], NUM_PRIME, 512);
	mpz_array_init(Ni_inv_length7[0], NUM_PRIME, 64);

	mpz_init(p_full_length15);
	mpz_array_init(Ni_length15[0], NUM_PRIME_EXT, 512);
	mpz_array_init(Ni_inv_length15[0], NUM_PRIME_EXT, 64);

	mpz_t temp; mpz_init(temp);
	
	// generating constants for length 7
	mpz_set_str(p_full_length7, "1", 10);
	for(i=0; i<NUM_PRIME; i++)
	mpz_mul_ui(p_full_length7, p_full_length7, p[i]);

	mpz_fdiv_q_ui(p_full_length7_by2, p_full_length7, 2);
	mpz_fdiv_q_ui(p_full_length7_by4, p_full_length7, 4);

	mpz_mul_ui(p_full_length7_by4_mul3, p_full_length7, 3);
	mpz_fdiv_q_ui(p_full_length7_by4_mul3, p_full_length7_by4_mul3, 4);

	for(i=0; i<NUM_PRIME; i++)		
	{
		mpz_set_ui(temp, p[i]);
		mpz_fdiv_q_ui(Ni_length7[i], p_full_length7, p[i]);
		mpz_invert(Ni_inv_length7[i], Ni_length7[i], temp);		
	}

	//gmp_printf("p_full_length7=%Zd\n", p_full_length7);

	// generating constants for length 15
	mpz_set_str(p_full_length15, "1", 10);
	for(i=0; i<NUM_PRIME_EXT; i++)
	mpz_mul_ui(p_full_length15, p_full_length15, p[i]);

	//gmp_printf("p_full_length15=%Zd\n", p_full_length15);
	mpz_fdiv_q_ui(p_full_length15_by2, p_full_length15, 2);
	
	for(i=0; i<NUM_PRIME_EXT; i++)		
	{
		mpz_set_ui(temp, p[i]);
		mpz_fdiv_q_ui(Ni_length15[i], p_full_length15, p[i]);
		mpz_invert(Ni_inv_length15[i], Ni_length15[i], temp);
	}
}
void compute_pby_t()
{
	int i;
	mpz_t temp, temp1, temp2;
	mpz_init(temp); mpz_init(temp1); mpz_init(temp2);

	mpz_fdiv_q_ui(temp, p_full_length7, t);

	for(i=0; i<NUM_PRIME; i++)
	{
		mpz_set_ui(temp1, p[i]);
		mpz_mod(temp2, temp, temp1);
		pby_t[i] = mpz_get_ui(temp2);
	}
}


int compute_rom(long long int primrt_array[], long long int primrt, int prime_index)
{
	long long int ROM[16][20];

	long long int number_of_roots, number_of_cores, number_of_cores_by_roots, number_of_roots_per_core;
	long long int temp, base;
	int i, m, j;
	
	number_of_cores=16;

	for(m=0; m<16; m++)
	{
		number_of_roots = pow2(m);
		
		if(number_of_roots<number_of_cores)
		{
			number_of_cores_by_roots = number_of_cores/number_of_roots;
			j=0;
			for(base=0; base+j<=number_of_cores; base=base+number_of_roots)
			{
				temp = 1;
				for(j=0; j<number_of_roots; j++)
				{
					ROM[j+base][m] = temp;
	
					temp = mod(temp*primrt_array[m],p[prime_index]);
				}			
			}
		}


		if(number_of_roots>=number_of_cores)
		{
			number_of_roots_per_core = number_of_roots/number_of_cores;
			
			temp = 1;
			for(i=0; i<number_of_roots_per_core; i++)	// write values in the first half of the cores
			{
				for(j=0; j<number_of_cores/2; j++)
				{
					if(i==0)
					ROM[j][m] = temp;

					temp = mod(temp*primrt_array[m],p[prime_index]);
				}			
			}

			for(i=0; i<number_of_roots_per_core; i++)	// write values in the second half of the cores
			{
				for(j=number_of_cores/2; j<number_of_cores; j++)
				{
					if(i==0)
					ROM[j][m] = temp;

					temp = mod(temp*primrt_array[m],p[prime_index]);
				}			
			}						
		}

	}

	
/*
	// This section is for software ROM

	for(i=0; i<number_of_cores; i++)
	{
		for(m=0; m<16; m++)
		{
		 	printf("ROM[%d][%d] = %d; ", i, m, ROM[i][m]);
		}
		printf("\n");
	}	
*/	
	print_to_file(ROM, p[prime_index]);	
									
}		

int print_software_ROM1(long long int primrt_array[])
{
	int i;

	printf("primrt array: ");
	for(i=0; i<log_n; i++)
	printf("%lu ", primrt_array[i]);

	printf("\n");
	for(i=0; i<log_n; i++)
	{
		printf("if(m==%d)  mpz_set_str(primrt,\"%lu\", 10);\n", pow2(i+1), primrt_array[i]);
	}
	//printf("%lu ", primrt_array[i]);
	printf("\n");
}
/*
int main()
{
	long long int p, primrt;
	long long int primrt_array[log_n];
	int i;
	
	p=249857;
	//printf("p=");
	//scanf("%lu", &p);

	primrt = primitive_root_find(p);

	creat_primrt_array(primrt_array, primrt, p);

	//compute_rom(primrt_array, primrt, p);

	print_software_ROM1(primrt_array);


	invert_primrt_array(primrt_array, p);

	//compute_rom(primrt_array, primrt, p);

	print_software_ROM1(primrt_array);


	//printf("primrt = %lu\n", primrt);
}	
*/	
