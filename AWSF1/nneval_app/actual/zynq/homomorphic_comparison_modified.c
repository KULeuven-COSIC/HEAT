struct plaintext_keyword
{
	int bits[TABLE_CONTENT_SIZE][1024];
};

struct plaintext_keyword init_keyword(struct plaintext_keyword ptext)
{
	int i, j;
	
	for(j=0; j<TABLE_CONTENT_SIZE; j++)
	for(i=0; i<1024; i++)
	ptext.bits[j][i]=0;

	return(ptext);
}

struct plaintext
{
	int bits[TABLE_CONTENT_SIZE][1024];
};

struct plaintext init_plaintext(struct plaintext ptext)
{
	int i, j;
	
	for(j=0; j<TABLE_CONTENT_SIZE; j++)
	for(i=0; i<1024; i++)
	ptext.bits[j][i]=0;

	return(ptext);
}
	
struct encrypted_bit
{
	long long int c0[5][1024], c1[5][1024]; 
};			

struct encrypted_keyword
{
	struct encrypted_bit bits[TABLE_CONTENT_SIZE];
};			
	
struct encrypted_data
{
	struct encrypted_bit bits[TABLE_CONTENT_SIZE];
};			

struct encrypted_data_8bit
{
	struct encrypted_bit bits[5];
};

struct window_table_entry
{
	struct encrypted_bit bits[2];
};

struct window_table
{
	struct window_table_entry window_table_entries[32];
};

void copy_encrypted_bit(struct encrypted_bit *bit_in, struct encrypted_bit *bit_out)
{
	int i, j;

	for(i=0; i<5; i++)			// copy cout in bit_in
	{
		for(j=0; j<1024; j++)
		{
			bit_out->c0[i][j] = bit_in->c0[i][j]; 
			bit_out->c1[i][j] = bit_in->c1[i][j]; 
		} 
	}	
}

void copy_encrypted_keyword(struct encrypted_keyword *in, struct encrypted_keyword *out)
{
	int k;
	
	for(k=0; k<TABLE_CONTENT_SIZE; k++)
	copy_encrypted_bit(&in->bits[k], &out->bits[k]);

}

void copy_encrypted_data(struct encrypted_data *in, struct encrypted_data *out)
{
	int k;
	
	for(k=0; k<TABLE_CONTENT_SIZE; k++)
	copy_encrypted_bit(&in->bits[k], &out->bits[k]);

}

struct encrypted_data ed_const_one, ed_const_allone;

struct encrypted_keyword encrypt_keyword(struct plaintext_keyword ptext, struct encrypted_keyword ed)
{
	int i;
	
	for(i=0; i<TABLE_CONTENT_SIZE; i++)
	FV_enc_q(ptext.bits[i], ed.bits[i].c0, ed.bits[i].c1);
	
	return(ed);
}

struct encrypted_data encrypt_data(struct plaintext ptext, struct encrypted_data ed)
{
	int i;
	
	for(i=0; i<TABLE_CONTENT_SIZE; i++)
	FV_enc_q(ptext.bits[i], ed.bits[i].c0, ed.bits[i].c1);
	
	return(ed);
}

struct plaintext_keyword decrypt_keyword(struct plaintext_keyword ptext, struct encrypted_keyword ed)
{
	int i;
	
	for(i=0; i<10; i++)
	FV_dec_q(ptext.bits[i], ed.bits[i].c0, ed.bits[i].c1);
	
	return(ptext);
}


void decrypt_data(struct encrypted_data ed, unsigned char decoded_string[])
{
	int i;
	struct plaintext ptext;

	init_plaintext(ptext);

	unsigned char decoded_char = 0;
	
	for(i=TABLE_CONTENT_SIZE-1; i>=0; i--)
	{
		FV_dec_q(ptext.bits[0], ed.bits[i].c0, ed.bits[i].c1);
		decoded_char = 2*decoded_char + ptext.bits[0][0];
		if(i%8==0)
		{
			decoded_string[i/8] = decoded_char;
			decoded_char = 0;
		}
	}
}


struct encrypted_bit encryption_of_bit_zero, encryption_of_bit_one;
struct window_table wt;

void homomorphic_search_precomputation(struct encrypted_keyword ed, int index)
{
	int i, j, bit;
	
	struct encrypted_data_8bit window;		// 8-bit windows are formed for all possible combinations of the table_entry bits
	struct encrypted_data_8bit result;		// is the addition of (window + ed_window)

	struct encrypted_bit multiplication_result;	// is the multiplication of the bits of result

	struct encrypted_data_8bit window_ed;

	int thread_num;

	// copy of the bits of ed in window_ed.
	for(i=0; i<5; i++)
	copy_encrypted_bit(&ed.bits[5*index+i], &window_ed.bits[i]);


	//#pragma omp parallel for private(j, bit, window, result, multiplication_result)
	for(i=0; i<32; i++)
	{
		for(j=0; j<5; j++)
		{
			bit = (i>>j)%2;
			if(bit==0) copy_encrypted_bit(&encryption_of_bit_zero, &window.bits[j]);
			else copy_encrypted_bit(&encryption_of_bit_one, &window.bits[j]);
		}	
		
		for(j=0; j<5; j++)
		{
			FV_add(window_ed.bits[j].c0, window_ed.bits[j].c1, window.bits[j].c0, window.bits[j].c1, result.bits[j].c0, result.bits[j].c1);
			if(IMPLEMENTATION_TYPE==0)
				FV_recrypt1_HW(result.bits[j].c0, result.bits[j].c1);
			else
				FV_recrypt1(result.bits[j].c0, result.bits[j].c1);			
		}
							
		for(j=1; j<5; j++)
		{
			FV_mul(result.bits[j-1].c0, result.bits[j-1].c1, result.bits[j].c0, result.bits[j].c1, multiplication_result.c0, multiplication_result.c1);	
			if(IMPLEMENTATION_TYPE==0)
				FV_recrypt1_HW(multiplication_result.c0, multiplication_result.c1);
			else
				FV_recrypt1(multiplication_result.c0, multiplication_result.c1);
			if(j<4)	copy_encrypted_bit(&multiplication_result, &result.bits[j]);
		}
		
		copy_encrypted_bit(&multiplication_result, &wt.window_table_entries[i].bits[index]);
	}
}

struct encrypted_data homomorphic_search(struct encrypted_keyword keyword)
{
	int index;
	int thread_num;
	int i, j, k, window_index0, window_index1, window_index2, window_index3;
	unsigned int table_content;
	unsigned char table_row[GENOMIC_STRING_LENGTH];

	struct encrypted_bit multiplication_result0, multiplication_result1;	// is the multiplication of the bits of result

	struct encrypted_data acc[THREADS];		// this accumulates the sum of encrypted contents

	struct encrypted_data acc_sum;

	printf("\n[SERVER] Performing encrypted search ...\n");

	for(index=0; index<2; index++)
	homomorphic_search_precomputation(keyword, index);

	//printf("Precomp done\n");

	struct plaintext ptext;
	
	for(i=0; i<THREADS; i++)
	{
		//printf("i=%d\n", i);
		init_plaintext(ptext);
		acc[i] = encrypt_data(ptext, acc[i]);
	}
	ptext=init_plaintext(ptext);
	acc_sum = encrypt_data(ptext, acc_sum);

	#pragma omp parallel
	i = omp_get_num_threads();
	//printf("num of threads %d\n", i);

	// searching starts with the table entries
	#pragma omp parallel for private(window_index0, window_index1, window_index2, window_index3, multiplication_result0, multiplication_result1, table_content, j, k, thread_num, table_row)
	for(i=0; i<256*4; i++)	// assuming 40 threads, this boundary 16384 is a multiple of 4
	{
		thread_num = omp_get_thread_num();
		
		window_index0 = i & 31;
		window_index1 = (i>>5) & 31;

		// multiplication_result0 = window_index0 & window_index1	
		FV_mul(wt.window_table_entries[window_index1].bits[1].c0, wt.window_table_entries[window_index1].bits[1].c1, 
		       wt.window_table_entries[window_index0].bits[0].c0, wt.window_table_entries[window_index0].bits[0].c1, 
		       multiplication_result0.c0, multiplication_result0.c1);

		table(i, table_row);
		
		for(j=0; j<GENOMIC_STRING_LENGTH; j++)
		{
			for(k=0; k<8; k++)
			{
				if( (table_row[j]>>k)%2 == 1 )
				FV_add(	acc[thread_num].bits[j*8+k].c0, acc[thread_num].bits[j*8+k].c1, 
                               		multiplication_result0.c0, multiplication_result0.c1, 
                               		acc[thread_num].bits[j*8+k].c0, acc[thread_num].bits[j*8+k].c1);
			}	
		}
	}	

	for(i=0; i<THREADS; i++)
	{	
		for(j=0; j<TABLE_CONTENT_SIZE; j++)	
		{
			FV_add(acc[i].bits[j].c0, acc[i].bits[j].c1, acc_sum.bits[j].c0, acc_sum.bits[j].c1, acc_sum.bits[j].c0, acc_sum.bits[j].c1);
		}
	}

	printf("\n[SERVER] Encrypted Search done\n");
	
	return(acc_sum);
	
}


