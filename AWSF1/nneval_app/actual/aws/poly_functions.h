void knuth_yao(long long int e[]);

int FV_mul(long long int c10[][4096], long long int c11[][4096], long long int c20[][4096], long long int c21[][4096], long long int c0[][4096], long long int c1[][4096]);
int FV_add(long long int c10[][4096], long long int c11[][4096], long long int c20[][4096], long long int c21[][4096], long long int c0[][4096], long long int c1[][4096]);
int FV_sub(long long int c10[][4096], long long int c11[][4096], long long int c20[][4096], long long int c21[][4096], long long int c0[][4096], long long int c1[][4096]);
int FV_relin(long long int c0_shares[][4096], long long int c1_shares[][4096], mpz_t c2_full[]);

void coefficient_mul_q(long long int a[], long long int b[], long long int c[], int prime_index);
void coefficient_add_q(long long int a[], long long int b[], long long int c[], int prime_index);

void FV_enc_q(int m[], long long int c0[][4096], long long int c1[][4096]);
void FV_dec_q(int m[], long long int c0[][4096], long long int c1[][4096]);

int word_decomp(mpz_t c[], mpz_t cwd0[], mpz_t cwd1[], mpz_t cwd2[], mpz_t cwd3[], mpz_t cwd4[]);
void compute_shares(mpz_t a[], long long int a_shares[][4096]);
void compute_mod(mpz_t a[],long long int b[], int prime_index);
int centerlift(mpz_t a[]);
int round2x_mod(mpz_t a[]);
int centerlift_QL(mpz_t a[]);
int map_to_QL(mpz_t a[], long long int b[][4096]);
void coefficient_mul_q(long long int a[], long long int b[], long long int c[], int prime_index);

void inverse_crt_length7(long long int c0[][4096], mpz_t c0_full[]);
void inverse_crt_length15(long long int c0[][4096], mpz_t c0_full[]);

void poly_copy(long long int a[], long long int b[]);
void message_gen(int m[]);


