#include<stdio.h>
#include<stdint.h>
#include<x86intrin.h>
#define SIZE 8

int mp_add64(uint32_t length, uint64_t src1[], uint64_t src2[], uint8_t c_in, long long unsigned int sum_out[], uint8_t *c_out)
{
	int i;
	
	for(i=0; i<length; i++)
	{
		c_in = _addcarryx_u64(c_in, src1[i], src2[i], &sum_out[i]);
	}
	*c_out = c_in;
} 

int mp_add32(uint32_t length, uint32_t src1[], uint32_t src2[], uint8_t c_in, unsigned int sum_out[], uint8_t *c_out)
{
	int i;
	
	for(i=0; i<length; i++)
	{
		c_in = _addcarryx_u32(c_in, src1[i], src2[i], &sum_out[i]);
		//printf("add %u %u %u\n", src1[i], src2[i], sum_out[i]);
	}
	*c_out = c_in;
} 


int mp_sub64(uint32_t length, uint64_t src1[], uint64_t src2[], uint8_t b_in, long long unsigned int diff_out[], uint8_t *b_out)
{
	int i;
	
	for(i=0; i<length; i++)
	{
	 	b_in = _subborrow_u64(b_in, src1[i], src2[i], &diff_out[i]);
	}
	*b_out = b_in;
} 

int mp_sub32(uint32_t length, uint32_t src1[], uint32_t src2[], uint8_t b_in, unsigned int diff_out[], uint8_t *b_out)
{
	int i;
	char br_in, br_out;	
	
	br_in = b_in;

	for(i=0; i<length; i++)
	{
		// diff_out = src1 - (src2+br_in)
	 	br_in = _subborrow_u32(br_in, src2[i], src1[i], &diff_out[i]);
		//printf("%u %u %u %u\n", src1[i], src2[i], br_out, diff_out[i]);
	}
	*b_out=br_in;
} 

int mp_mul32(uint32_t len_src1, uint32_t len_src2, uint32_t src1[], uint32_t src2[], uint32_t mul_out[])
{
	int i, j;

	uint32_t partial_result[len_src1+len_src2], mul_out_temp[len_src1+len_src2];
	//uint32_t acc[len_src1+len_src2];
	uint64_t mul_64out;
	uint8_t c_out;

	//printf("len_src1+len_src2=%d\n", len_src1+len_src2);

	for(j=0; j<len_src1+len_src2; j++)
	{
		partial_result[j] = 0;		
		mul_out_temp[j] = 0;
	}

	for(i=0; i<len_src2; i=i+1)
	{	
		for(j=0; j<i; j++)
			partial_result[j] = 0;

		for(j=0; j<len_src1; j=j+2)
		{
			mul_64out = (uint64_t) src1[j] * src2[i];
			partial_result[j+i] = mul_64out&4294967295;
			partial_result[j+1+i] = (mul_64out>>32);
			//printf("j, i, j+1+i = %d %d %d\n", j, i, j+1+i);			
		}
		mp_add32(len_src1+len_src2, mul_out_temp, partial_result, 0, mul_out_temp, &c_out);	

		partial_result[i] = 0; 
		for(j=1; j<len_src1; j=j+2)
		{
			mul_64out = (uint64_t) src1[j] * src2[i];
			partial_result[j+i] = mul_64out&4294967295;
			partial_result[j+1+i] = (mul_64out>>32);			
			//printf("j, i, j+1+i = %d %d %d\n", j, i, j+1+i);			
		}
		mp_add32(len_src1+len_src2, mul_out_temp, partial_result, 0, mul_out_temp, &c_out);	

	}

	for(j=0; j<len_src1+len_src2; j++)
	mul_out[j]=mul_out_temp[j];
	
	//printf("AC: \n");
	//for(j=0; j<len_src1+len_src2; j++)
	//printf("%u\t", mul_out_temp[j]);
	//printf("\n");			 
	
}

int mp_mul32_ui(uint32_t len_src1, uint32_t src1[], uint32_t src2, uint32_t mul_out[])
{
	int i, j;

	uint32_t partial_result[len_src1+1];
	uint64_t mul_64out;
	uint8_t c_out;

		for(j=0; j<len_src1+1; j++)
		{
			partial_result[j] = 0;		
			mul_out[j] = 0;
		}


		for(j=0; j<len_src1; j=j+2)
		{
			mul_64out = (uint64_t) src1[j] * src2;
			partial_result[j] = mul_64out&4294967295;
			partial_result[j+1] = (mul_64out>>32);			
		}
		mp_add32(len_src1+1, mul_out, partial_result, 0, mul_out, &c_out);	

		partial_result[0] = 0; 
		for(j=1; j<len_src1; j=j+2)
		{
			mul_64out = (uint64_t) src1[j] * src2;
			partial_result[j] = mul_64out&4294967295;
			partial_result[j+1] = (mul_64out>>32);			
		}
		mp_add32(len_src1+1, mul_out, partial_result, 0, mul_out, &c_out);	

}


/*
int main()
{
unsigned char c_out, c_in;
uint32_t src1[SIZE], src2[SIZE];
long long unsigned int sum_out[SIZE];
uint32_t mul_out[2*SIZE];

	//c_in = 0;
	//src1[0] = 18446744073709551615; src2[0]=18446744073709551615;
	//src1[1] = 18446744073709551615; src2[1]=18446744073709551615;
	//mp_add(2, src1, src2, c_in, sum_out, &c_out);	
	//mp_sub(2, src1, src2, c_in, sum_out, &c_out);	
	//printf("carry, sum %d %llu\n", c_out, sum_out[0]);
	//printf("carry, sum %d %llu\n", c_out, sum_out[1]);
	
	src1[0] = 3077274254;
	src1[1] = 569977374;
	src1[2] = 2077526888;
	src1[3] = 2330724257;
	src1[4] = 3826350261;
	src1[5] = 3011624668;
	src1[6] = 2802313679;
	src1[7] = 1136235892;
	src2[0] = 3461439533;
	src2[1] = 3358057059;
	src2[2] = 3000617285;
	src2[3] = 1036006507;
	src2[4] = 3969638673;
	src2[5] = 2262636847;
	src2[6] = 471745366;
	src2[7] = 3509103927;
	
	mp_mul32(SIZE, SIZE, src1, src2, mul_out);
}
*/

