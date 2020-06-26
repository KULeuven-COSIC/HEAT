void instruction_compile(unsigned long long long_instruction[], int prog_code)
{
	FILE *fp;
	int i;

	char header0[10], header1[10], header2[10], header3[10], header4[10], header5[10];
	unsigned long long instruction, address1, address2, porc_select, mem_select, mod_select;

	if(prog_code==5)
	fp = fopen("HE_programs/test/copy_RLK00.txt", "r");
	if(prog_code==6)
	fp = fopen("HE_programs/test/copy_RLK01.txt", "r");
	if(prog_code==7)
	fp = fopen("HE_programs/test/copy_RLK10.txt", "r");
	if(prog_code==8)
	fp = fopen("HE_programs/test/copy_RLK11.txt", "r");
	if(prog_code==9)
	fp = fopen("HE_programs/test/copy_cmul1.txt", "r");


	if(prog_code==0)
	fp = fopen("HE_programs/test/copy_c00.txt", "r");
	if(prog_code==1)
	fp = fopen("HE_programs/test/copy_c01.txt", "r");
	if(prog_code==2)
	fp = fopen("HE_programs/test/copy_c10.txt", "r");
	if(prog_code==3)
	fp = fopen("HE_programs/test/copy_c11.txt", "r");
	if(prog_code==4)
	fp = fopen("HE_programs/test/HE.txt", "r");

	//fp = fopen("HE_programs/mem_init.txt", "r");
	//fp = fopen("HE_programs/small_lift.txt", "r");
	//fp = fopen("HE_programs/big_lift_relin.txt", "r");
	//fp = fopen("HE_programs/big_lift.txt", "r");
	//fp = fopen("HE_programs/data_copy.txt", "r");
	//fp = fopen("HE_programs/data_copy1.txt", "r");

	//fp = fopen("HE_programs/HE_mem_copy.txt", "r");
	//fp = fopen("HE_programs/HE_program.txt", "r");
	//fp = fopen("HE_programs/test/ntt.txt", "r");
	//fp = fopen("HE_programs/test/data_copy_small_crt.txt", "r");
	//fp = fopen("HE_programs/test/data_copy_large_crt.txt", "r");
	//fp = fopen("HE_programs/test/HE.txt", "r");

		// read the header
		fscanf(fp, "%s", header0);	
		fscanf(fp, "%s", header1);	
		fscanf(fp, "%s", header2);	
		fscanf(fp, "%s", header3);	
		fscanf(fp, "%s", header4);	
		fscanf(fp, "%s", header5);	

	// read the instructions
	i = 0;
	do{
		fscanf(fp, "%llu", &instruction);	
		fscanf(fp, "%llu", &address1);		
		fscanf(fp, "%llu", &address2);	
		fscanf(fp, "%llu", &porc_select);	
		fscanf(fp, "%llu", &mem_select);	
		fscanf(fp, "%llu", &mod_select);			
		
		long_instruction[i]=instruction+address1*256llu+address2*65536llu;
		long_instruction[i]=long_instruction[i]+porc_select*16777216llu+mem_select*134217728llu+mod_select*2147483648llu;
		//printf("i=%d long_instruction=%llu\n", i, long_instruction[i]);
		i++;
	}while(instruction!=255);
	fclose(fp);
}
