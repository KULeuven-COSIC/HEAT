#include "genome_table.c"

void table(int table_index, unsigned char table_row[])
{
	int i;
	for(i=0; i<GENOMIC_STRING_LENGTH; i++)
	{
		table_row[i] = table_data[table_index][i];
	}
}
