/**
 *
 * This file is part of FV-NFLlib
 *
 * Copyright (C) 2015, 2016  CryptoExperts
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 */

#pragma once

#include <cstddef>

#include <algorithm>
#include <chrono>
#include <iostream>
#include <memory>
#include <nfl.hpp>


namespace FV {

// Parameters (need to be defined before inclusion)
//
// @param poly_t (nfl::poly)
// @param plaintextModulus (mpz_class)
// @param gauss_struct (nfl::gaussian)
// @param fg_prng_sk (FastGaussianNoise)
// @param fg_prng_evk (FastGaussianNoise)
// @param fg_prng_pk (FastGaussianNoise)
// @param fg_prng_enc (FastGaussianNoise)
//
namespace params {
using poly_p =
    nfl::poly_p<typename poly_t::value_type, poly_t::degree, poly_t::nmoduli>;
using polyZ_p = nfl::poly<typename poly_t::value_type, poly_t::degree,
                          poly_t::nmoduli * 2 + 1>;
}

class sk_t;
class pk_t;
class evk_t;
class ciphertext_t;
template <typename T>
class message_t;
using mess_t = message_t<mpz_class>;

}  // namespace FV

/**
 * Headers of utilitary functions implemented at the end of the document
 */
namespace FV {
namespace util {
inline void center(mpz_t &rop, mpz_t const &op1, mpz_t const &op2,
                   mpz_t const &op2Div2);
inline void div_and_round(mpz_t &rop, mpz_t const &op1, mpz_t const &op2,
                          mpz_t const &op2Div2);
template <size_t degree>
inline void reduce(std::array<mpz_t, degree> &coefficients, mpz_t multiplier,
                   mpz_t const &divisor, mpz_t const &divisorDiv2,
                   mpz_t const &mod_init, mpz_t const &mod_initDiv2);
inline void lift(std::array<mpz_t, params::polyZ_p::degree> &coefficients,
                 params::polyZ_p const &c);
void convert(params::polyZ_p &new_c, params::poly_p const &c,
             bool ntt_form = true);
template <typename T>
T message_from_mpz_t(mpz_t value);
}  // namespace util
}  // namespace FV

/**
 * Class to store the secret key
 */
namespace FV {
class sk_t {
  using P = params::poly_p;

 public:
  /// The secret key is a polynomial
  P value;//P value{params::gauss_struct(&params::fg_prng_sk)};
  P value_shoup;

  /// Constructor
  sk_t() {
    value = nfl::non_uniform(2); 
    value.ntt_pow_phi();  // store in NTT form
    value_shoup = nfl::compute_shoup(value);
  }
  sk_t(P poly) {
    value = 0;
    value = value + poly;
    value.ntt_pow_phi();
    value_shoup = nfl::compute_shoup(value);
  }
};
}  // namespace FV

/**
 * Class to store the evaluation key
 */
namespace FV {
class evk_t {
  using P = params::poly_p;

 public:
  size_t ell;  // log_2(q)+1
  size_t word_size;
  mpz_t word;
  mpz_t word_mask;
  P **values;
  P **values_shoup;
  mpz_t qDivBy2;
  mpz_t bigmodDivBy2;

  /// Constructor
  evk_t(sk_t const &sk, size_t word_size) : word_size(word_size) {
    mpz_inits(qDivBy2, bigmodDivBy2, word, word_mask, nullptr);

    ell = floor(mpz_sizeinbase(P::moduli_product(), 2) / word_size) + 1;

    mpz_fdiv_q_ui(qDivBy2, P::moduli_product(), 2);
    mpz_fdiv_q_ui(bigmodDivBy2, params::polyZ_p::moduli_product(), 2);

    // Word and word mask
    mpz_set_ui(word, 1);
    mpz_mul_2exp(word, word, word_size);
    mpz_sub_ui(word_mask, word, 1);

    // Temporary values that will contain word^i
    mpz_t tmp_word;
    mpz_init_set_ui(tmp_word, 1);
    P add;

    // Allocate values
    values = (P **)malloc(ell * sizeof(P *));
    values_shoup = (P **)malloc(ell * sizeof(P *));
    for (size_t i = 0; i < ell; ++i) {
      values[i] = new P[2];
      values[i][1] = nfl::uniform();
      values[i][0] = params::gauss_struct(&params::fg_prng_evk);
      values[i][0].ntt_pow_phi();
      values[i][0] = values[i][0] - values[i][1] * sk.value;

      add = tmp_word;
      add.ntt_pow_phi();
      add = add * sk.value * sk.value;
      values[i][0] = values[i][0] + add;

      values_shoup[i] = new P[2];
      values_shoup[i][1] = nfl::compute_shoup(values[i][1]);
      values_shoup[i][0] = nfl::compute_shoup(values[i][0]);

      // Update for next loop
      mpz_mul_2exp(tmp_word, tmp_word, word_size);
    }

    // Clean
    mpz_clear(tmp_word);
  }

  evk_t(params::poly_p polys[], size_t word_size) : word_size(word_size) {
    mpz_inits(qDivBy2, bigmodDivBy2, word, word_mask, nullptr);

    ell = floor(mpz_sizeinbase(P::moduli_product(), 2) / word_size) + 1;

    mpz_fdiv_q_ui(qDivBy2, P::moduli_product(), 2);
    mpz_fdiv_q_ui(bigmodDivBy2, params::polyZ_p::moduli_product(), 2);

    // Word and word mask
    mpz_set_ui(word, 1);
    mpz_mul_2exp(word, word, word_size);
    mpz_sub_ui(word_mask, word, 1);

    // Allocate values
    values = (P **)malloc(ell * sizeof(P *));
    values_shoup = (P **)malloc(ell * sizeof(P *));

    size_t poly_index = 0;
    for (size_t i = 0; i < ell; ++i) {
      values[i] = new P[2];
      values[i][0] = 0;
      values[i][0] = values[i][0] + polys[poly_index];
      poly_index++;
      values[i][1] = 0;
      values[i][1] = values[i][1] + polys[poly_index];
      poly_index++;

      values[i][0].ntt_pow_phi();
      values[i][1].ntt_pow_phi();

      values_shoup[i] = new P[2];
      values_shoup[i][1] = nfl::compute_shoup(values[i][1]);
      values_shoup[i][0] = nfl::compute_shoup(values[i][0]);
    }
  }

  /// Destructor
  ~evk_t() {
    mpz_clears(qDivBy2, bigmodDivBy2, word, word_mask, nullptr);
    for (size_t i = 0; i < ell; i++) {
      delete[] values[i];
      delete[] values_shoup[i];
    }
    free(values);
    free(values_shoup);
  }
};
}  // namespace FV

/**
 * Class to store the public key
 */
namespace FV {
class pk_t {
  using P = params::poly_p;

 public:
  /// Public key elements
  P a, b, delta;
  P a_shoup, b_shoup, delta_shoup;

  /// Link to evaluation key
  evk_t *evk;

  /// Interesting value
  long noise_max;

  /// Constructor
  pk_t(sk_t const &sk, evk_t const &evaluation_key) {
    // Link to the evaluation key
    evk = (evk_t *)&evaluation_key;

    // random a (already in NTT form)
    a = nfl::uniform();
    a_shoup = nfl::compute_shoup(a);

    // b = small - a*sk
    b = params::gauss_struct(&params::fg_prng_pk);
    b.ntt_pow_phi();  // transform via NTT
    b = b - a * sk.value;
    b_shoup = nfl::compute_shoup(b);

    // Set the plaintext modulus
    noise_max =
        mpz_sizeinbase(P::moduli_product(), 2) - 1 -
        mpz_sizeinbase(params::plaintextModulus<mpz_class>::value().get_mpz_t(),
                       2);

    // Define delta the polynomial of constant coeff = floor(modulus / plaintext
    // modulus)
    mpz_class Delta;
    mpz_fdiv_q(Delta.get_mpz_t(), P::moduli_product(),
               params::plaintextModulus<mpz_class>::value().get_mpz_t());
    delta = Delta;
    delta.ntt_pow_phi();
    delta_shoup = nfl::compute_shoup(delta);
  }

  pk_t(sk_t const &sk, evk_t const &evaluation_key, params::poly_p poly[2]) {
    // Link to the evaluation key
    evk = (evk_t *)&evaluation_key;

    // random a (already in NTT form)
    a = 0;
    a = a + poly[1];
    a.ntt_pow_phi();
    a_shoup = nfl::compute_shoup(a);

    // b = small - a*sk
    b = 0;
    b = b + poly[0];
    b.ntt_pow_phi();  // transform via NTT
    b_shoup = nfl::compute_shoup(b);

    // Set the plaintext modulus
    noise_max =
        mpz_sizeinbase(P::moduli_product(), 2) - 1 -
        mpz_sizeinbase(params::plaintextModulus<mpz_class>::value().get_mpz_t(),
                       2);

    // Define delta the polynomial of constant coeff = floor(modulus / plaintext
    // modulus)
    mpz_class Delta;
    mpz_fdiv_q(Delta.get_mpz_t(), P::moduli_product(),
               params::plaintextModulus<mpz_class>::value().get_mpz_t());
    delta = Delta;
    delta.ntt_pow_phi();
    delta_shoup = nfl::compute_shoup(delta);
  }
};
}  // namespace FV

/**
 * Class to store a ciphertext
 */
namespace FV {
class ciphertext_t {
  using P = params::poly_p;
  using PZ = params::polyZ_p;

 public:
  typedef P type;

  /// ciphertext_t contains two polynomials (c0, c1)
  P c0, c1;

  /// Link to public key
  pk_t *pk = nullptr;

  /// Boolean if the ciphertext is 0
  bool isnull;

  /// Constructors
  ciphertext_t() : c0(0), c1(0), pk(nullptr), isnull(true) {}
  ciphertext_t(ciphertext_t const &ct) : c0(ct.c0), c1(ct.c1) {
    if (ct.pk != nullptr) {
      pk = ct.pk;
    }
    isnull = ct.isnull;
  }
  ciphertext_t(P const &p0, P const &p1, pk_t &pk_in) {
    if (&pk_in != nullptr) 
      pk = &pk_in;
    c0 = 0;
    c0 = c0 + p0;
    c0.ntt_pow_phi();
    c1 = 0;
    c1 = c1 + p1;
    c1.ntt_pow_phi();
    isnull = false;
  }
  template <typename T>
  ciphertext_t(T const &value) : c0(0), c1(0), pk(nullptr), isnull(true) {
    assert(value == 0);
  }
  template <typename T>
  ciphertext_t(pk_t &pk_in, message_t<T> const &m) : c1(0), pk(&pk_in) {
    if (m.getValue() == 0) {
      c0 = 0;
      isnull = true;
    } else {
      c0 = m.getValue();
      c0.ntt_pow_phi();
      c0 = nfl::shoup(c0 * pk->delta, pk->delta_shoup);
      isnull = false;
    }
  }
  template <typename T>
  ciphertext_t(pk_t &pk_in, T const &m) : c1(0), pk(&pk_in) {
    if (m == 0) {
      c0 = 0;
      isnull = true;
    } else {
      c0 = m;
      c0.ntt_pow_phi();
      c0 = nfl::shoup(c0 * pk->delta, pk->delta_shoup);
      isnull = false;
    }
  }

  /// Assignment
  inline ciphertext_t &operator=(ciphertext_t const &ct) {
    c0 = ct.c0;
    c1 = ct.c1;
    if (ct.pk != nullptr) pk = ct.pk;
    isnull = ct.isnull;
    return *this;
  }
  template <typename T>
  inline ciphertext_t &operator=(message_t<T> const &value) {
    if (value != 0) {
      assert(pk != nullptr);
      P v{value.getValue()};
      v.ntt_pow_phi();
      c1 = 0;
      c0 = nfl::shoup(v * pk->delta, pk->delta_shoup);
      isnull = false;
    } else {
      c0 = 0;
      c1 = 0;
      isnull = true;
    }
    return *this;
  }
  template <typename Tp>
  inline ciphertext_t &operator=(Tp const &value) {
    if (value != 0) {
      assert(pk != nullptr);
      P v{value};
      v.ntt_pow_phi();
      isnull = false;
      c1 = 0;
      c0 = nfl::shoup(v * pk->delta, pk->delta_shoup);
    } else {
      c0 = 0;
      c1 = 0;
      isnull = true;
    }
    return *this;
  }

  /// Additions/Substractions
  inline ciphertext_t &operator+=(ciphertext_t const &ct) {
    if (ct.isnull == false) {
      c0 = c0 + ct.c0;
      c1 = c1 + ct.c1;
      isnull = false;
    }
    return *this;
  }
  inline ciphertext_t &operator-=(ciphertext_t const &ct) {
    if (ct.isnull == false) {
      c0 = c0 - ct.c0;
      c1 = c1 - ct.c1;
      isnull = false;
    }
    return *this;
  }
  friend ciphertext_t operator+(ciphertext_t const &lhs,
                                ciphertext_t const &rhs) {
    ciphertext_t ct(lhs);
    return ct += rhs;
  }
  friend ciphertext_t operator-(ciphertext_t const &lhs,
                                ciphertext_t const &rhs) {
    ciphertext_t ct(lhs);
    return ct -= rhs;
  }

  inline ciphertext_t &operator+=(mpz_class const &value) {
    if (value == 0) {
      return *this;
    }
    P v{value};
    v.ntt_pow_phi();
    return *this += v;
  }
  inline ciphertext_t &operator-=(mpz_class const &value) {
    if (value == 0) {
      return *this;
    }
    P v{value};
    v.ntt_pow_phi();
    return *this -= v;
  }
  friend ciphertext_t operator+(ciphertext_t const &lhs, mpz_class const &rhs) {
    ciphertext_t ct(lhs);
    return ct += rhs;
  }
  friend ciphertext_t operator-(ciphertext_t const &lhs, mpz_class const &rhs) {
    ciphertext_t ct(lhs);
    return ct -= rhs;
  }

  inline ciphertext_t &operator+=(P::value_type const &value) {
    if (value == 0) {
      return *this;
    }
    P v{value};
    v.ntt_pow_phi();
    return *this += v;
  }
  inline ciphertext_t &operator-=(P::value_type const &value) {
    if (value == 0) {
      return *this;
    }
    P v{value};
    v.ntt_pow_phi();
    return *this -= v;
  }
  friend ciphertext_t operator+(ciphertext_t const &lhs,
                                P::value_type const &rhs) {
    ciphertext_t ct(lhs);
    return ct += rhs;
  }
  friend ciphertext_t operator-(ciphertext_t const &lhs,
                                P::value_type const &rhs) {
    ciphertext_t ct(lhs);
    return ct -= rhs;
  }

  template <typename T>
  inline ciphertext_t &operator+=(message_t<T> const &m) {
    if (m.getValue() == 0) {
      return *this;
    }
    return *this += m.getValue();
  }
  template <typename T>
  inline ciphertext_t &operator-=(message_t<T> const &m) {
    if (m.getValue() == 0) {
      return *this;
    }
    return *this -= m.getValue();
  }
  template <typename T>
  friend ciphertext_t operator+(ciphertext_t const &lhs,
                                message_t<T> const &rhs) {
    ciphertext_t ct(lhs);
    return ct += rhs;
  }
  template <typename T>
  friend ciphertext_t operator-(ciphertext_t const &lhs,
                                message_t<T> const &rhs) {
    ciphertext_t ct(lhs);
    return ct -= rhs;
  }

  /// Addition/Substraction of a polynomial
  inline ciphertext_t &operator+=(P const &p) {
    assert(pk != nullptr);
    c0 = c0 + nfl::shoup(p * pk->delta, pk->delta_shoup);
    isnull = false;
    return *this;
  }
  inline ciphertext_t &operator-=(P const &p) {
    assert(pk != nullptr);
    c0 = c0 - nfl::shoup(p * pk->delta, pk->delta_shoup);
    isnull = false;
    return *this;
  }
  friend ciphertext_t operator+(ciphertext_t const &lhs, P const &rhs) {
    ciphertext_t ct(lhs);
    return ct += rhs;
  }
  friend ciphertext_t operator-(ciphertext_t const &lhs, P const &rhs) {
    ciphertext_t ct(lhs);
    return ct -= rhs;
  }

  /// Multiplication
  ciphertext_t &operator*=(ciphertext_t const &ct) {
    // Early abort
    if (ct.isnull || isnull) {
      c0 = 0;
      c1 = 0;
      isnull = true;
      return *this;
    }

    size_t bits_in_moduli_product = P::bits_in_moduli_product();

    // Allocations
    PZ c00, c10, c01, c11, c1b;

    // View the polynomials as PZ polynomials
    util::convert(c00, c0);
    util::convert(c01, c1);
    util::convert(c10, ct.c0);
    util::convert(c11, ct.c1);

    // Compute products "over ZZ"
    c1b = c00 * c11 + c01 * c10;
    c00 = c00 * c10;
    c11 = c01 * c11;

    // Multiply by 2/q
    std::array<mpz_t, P::degree> coefficients;
    for (size_t i = 0; i < P::degree; i++) {
      mpz_init2(coefficients[i], (bits_in_moduli_product << 2));
    }

    util::lift(coefficients, c00);
    util::reduce<PZ::degree>(
        coefficients, params::plaintextModulus<mpz_class>::value().get_mpz_t(),
        P::moduli_product(), pk->evk->qDivBy2, PZ::moduli_product(),
        pk->evk->bigmodDivBy2);
    c0.mpz2poly(coefficients);
    c0.ntt_pow_phi();

    util::lift(coefficients, c1b);
    util::reduce<PZ::degree>(
        coefficients, params::plaintextModulus<mpz_class>::value().get_mpz_t(),
        P::moduli_product(), pk->evk->qDivBy2, PZ::moduli_product(),
        pk->evk->bigmodDivBy2);
    c1.mpz2poly(coefficients);
    c1.ntt_pow_phi();

    util::lift(coefficients, c11);
    util::reduce<PZ::degree>(
        coefficients, params::plaintextModulus<mpz_class>::value().get_mpz_t(),
        P::moduli_product(), pk->evk->qDivBy2, PZ::moduli_product(),
        pk->evk->bigmodDivBy2);

    // Decompose c2i and multiply by evaluation keys
    P c2i;

    std::array<mpz_t, P::degree> decomp;
    for (size_t i = 0; i < P::degree; i++) {
      mpz_init2(decomp[i], pk->evk->word_size);
      mpz_mod(coefficients[i], coefficients[i], P::moduli_product());
    }

    for (size_t i = 0; i < pk->evk->ell; i++) {
      for (size_t k = 0; k < P::degree; k++) {
        mpz_and(decomp[k], coefficients[k], pk->evk->word_mask);
        mpz_fdiv_q_2exp(coefficients[k], coefficients[k], pk->evk->word_size);
      }
      c2i.mpz2poly(decomp);
      c2i.ntt_pow_phi();
      c0 = c0 +
           nfl::shoup(c2i * pk->evk->values[i][0], pk->evk->values_shoup[i][0]);
      c1 = c1 +
           nfl::shoup(c2i * pk->evk->values[i][1], pk->evk->values_shoup[i][1]);
    }

    // Clean
    for (size_t i = 0; i < P::degree; i++) {
      mpz_clear(decomp[i]);
      mpz_clear(coefficients[i]);
    }

    return *this;
  }
  friend ciphertext_t operator*(ciphertext_t const &lhs,
                                ciphertext_t const &rhs) {
    ciphertext_t ct(lhs);
    return ct *= rhs;
  }

  inline ciphertext_t &operator*=(mpz_class const &m) {
    if (m == 0) {
      c0 = 0;
      c1 = 0;
      isnull = true;
      return *this;
    }
    if (m == 1) {
      return *this;
    }
    ciphertext_t c(*pk, m);
    return *this *= c;
  }
  friend ciphertext_t operator*(ciphertext_t const &lhs, mpz_class const &rhs) {
    ciphertext_t ct(lhs);
    return ct *= rhs;
  }

  inline ciphertext_t &operator*=(P::value_type const &m) {
    if (m == 0) {
      c0 = 0;
      c1 = 0;
      isnull = true;
      return *this;
    }
    if (m == 1) {
      return *this;
    }
    ciphertext_t c(*pk, m);
    return *this *= c;
  }
  friend ciphertext_t operator*(ciphertext_t const &lhs,
                                P::value_type const &rhs) {
    ciphertext_t ct(lhs);
    return ct *= rhs;
  }

  template <typename T>
  inline ciphertext_t &operator*=(message_t<T> const &m) {
    if (m.getValue() == 0) {
      c0 = 0;
      c1 = 0;
      isnull = true;
      return *this;
    }
    if (m.getValue() == 1) {
      return *this;
    }
    ciphertext_t c(*pk, m);
    return *this *= c;
  }
  template <typename T>
  friend ciphertext_t operator*(ciphertext_t const &lhs,
                                message_t<T> const &rhs) {
    ciphertext_t ct(lhs);
    return ct *= rhs;
  }

  /// Multiplication by a polynomial
  inline ciphertext_t &operator*=(P const &multiplier) {
    if (isnull == false) {
      c0 = c0 * multiplier;
      c1 = c1 * multiplier;
    }
    return *this;
  }
  friend ciphertext_t operator*(ciphertext_t const &lhs, P const &rhs) {
    ciphertext_t ct(lhs);
    return ct *= rhs;
  }
};
}  // namespace FV

/**
 * Encrypt a polynomial poly_m
 * @param ct     ciphertext (passed by reference)
 * @param pk     public key
 * @param poly_m polynomial to encrypt
 */
namespace FV {
template <class PK, class C>
void encrypt_poly(C &ct, const PK &pk, params::poly_p &poly_m) {
  using P = params::poly_p;

  // Apply the NTT on poly_m
  poly_m.ntt_pow_phi();

  // Generate a small u
  P u = nfl::non_uniform(2); //u{params::gauss_struct(&params::fg_prng_enc)};
  u.ntt_pow_phi();

  // Set the ciphertext pk
  ct.pk = (PK *)&pk;

  // Generate ct = (c0, c1)
  // where c0 = b*u + Delta*m + small error
  ct.c0 = params::gauss_struct(&params::fg_prng_enc);
  ct.c0.ntt_pow_phi();
  ct.c0 = ct.c0 + nfl::shoup(u * pk.b, pk.b_shoup) +
          nfl::shoup(poly_m * pk.delta, pk.delta_shoup);

  // where c1 = a*u + small error
  ct.c1 = params::gauss_struct(&params::fg_prng_enc);
  ct.c1.ntt_pow_phi();
  ct.c1 = ct.c1 + nfl::shoup(u * pk.a, pk.a_shoup);

  ct.isnull = false;
}
}  // namespace FV

/**
 * Decryption of a ciphertext and recover the whole polynomial encrypted
 * @param poly_mpz pointer to the polynomial (already initialized)
 * @param sk       secret key
 * @param pk       public key
 * @param ct       ciphertext
 */
namespace FV {
template <class SK, class PK, class C>
void decrypt_poly(std::array<mpz_t, params::poly_p::degree> &poly_mpz,
                  const SK &sk, const PK &pk, const C &ct) {
  using P = params::poly_p;

  // Get the polynomial
  P numerator{ct.c0 + ct.c1 * sk.value};
  numerator.invntt_pow_invphi();
  numerator.poly2mpz(poly_mpz);

  // Reduce the coefficients
  util::reduce<P::degree>(
      poly_mpz, params::plaintextModulus<mpz_class>::value().get_mpz_t(),
      P::moduli_product(), pk.evk->qDivBy2, P::moduli_product(),
      pk.evk->qDivBy2);
  for (size_t i = 0; i < P::degree; i++) {
    mpz_mod(poly_mpz[i], poly_mpz[i],
            params::plaintextModulus<mpz_class>::value().get_mpz_t());
  }
}
}  // namespace FV

/**
 * Encrypt a message
 * @param ct      ciphertext (passed by reference)
 * @param pk      public key
 * @param message message to encrypt
 */
namespace FV {
template <class PK, class C, typename T>
void encrypt(C &ct, const PK &pk, const message_t<T> &message) {
  // Store the message in the constant coefficient of a polynomial poly_m
  params::poly_p poly_m{message.getValue()};

  // Encrypt poly_m
  encrypt_poly(ct, pk, poly_m);
}
template <class PK, class C, typename T>
void encrypt_integer(C &ct, const PK &pk, const T &message) {
  // Store the message in the constant coefficient of a polynomial poly_m
  params::poly_p poly_m{message};

  // Encrypt poly_m
  encrypt_poly(ct, pk, poly_m);
}
}  // namespace FV

/**
 * Decryption of a ciphertext whose message is in
 * @param message message in the ciphertext passed by reference
 * @param sk      secret key
 * @param pk      public key
 * @param ct      ciphertext
 */
namespace FV {
template <class SK, class PK, class C, class M>
void decrypt(M &message, const SK &sk, const PK &pk, const C &ct) {
  auto const degree = params::poly_p::degree;

  // Initiate the polynomial of mpz values
  std::array<mpz_t, degree> poly_mpz;
  for (size_t i = 0; i < degree; i++) {
    mpz_init(poly_mpz[i]);
  }

  // Decrypt the ciphertext
  decrypt_poly<SK, PK, C>(poly_mpz, sk, pk, ct);

  // Get the message from the constant coefficient
  message = util::message_from_mpz_t<typename M::type>(poly_mpz[0]);

  // Clear the poly of mpz values
  for (size_t i = 0; i < degree; i++) {
    mpz_clear(poly_mpz[i]);
  }
}
}  // namespace FV

/**
 * Return the log in base 2 of the noise in the ciphertext
 * @param  message message encrypted in the ciphertext
 * @param  sk      secret key
 * @param  pk      public key
 * @param  ct      ciphertext
 * @return         log_2(noise in ct)
 */
namespace FV {
template <class SK, class PK, class C, class M>
size_t noise(M const &message, SK const &sk, PK const &pk, C const &ct) {
  using P = params::poly_p;

  P poly_m{message.getValue()};
  poly_m.ntt_pow_phi();

  P numerator{ct.c0 + ct.c1 * sk.value -
              nfl::shoup(poly_m * pk.delta, pk.delta_shoup)};
  numerator.invntt_pow_invphi();
  std::array<mpz_t, P::degree> poly_mpz = numerator.poly2mpz();

  size_t logMax = 0;

  for (size_t i = 0; i < P::degree; i++) {
    util::center(poly_mpz[i], poly_mpz[i], P::moduli_product(),
                 pk.evk->qDivBy2);
    logMax = std::max(logMax, mpz_sizeinbase(poly_mpz[i], 2));
  }

  // Clean
  for (size_t i = 0; i < P::degree; i++) {
    mpz_clear(poly_mpz[i]);
  }

  return logMax;
}
}  // namespace FV

/**
 * Class to store messages
 * templated class (T = mpz_class or T = unsigned long)
 */
namespace FV {
template <typename T>
class message_t {
 private:
  /// internal value
  T _value;

 public:
  /// type of the value
  typedef T type;

  /// Constructor
  message_t() { _value = 0; }
  message_t(message_t const &m) { _value = m._value; }
  template <typename Tp>
  message_t(Tp const &value) {
    _value = T(value) % params::plaintextModulus<T>::value();
  }

  /// Get the value
  inline T getValue() const { return _value; }

  /// Set a value
  message_t &operator=(message_t const &m) {
    _value = m._value;
    return *this;
  }
  template <typename Tp>
  message_t &operator=(Tp const &value) {
    _value = T(value) % params::plaintextModulus<T>::value();
    return *this;
  }

  /// Random generator
  message_t &random() {
    gmp_randclass rng(gmp_randinit_default);
    rng.seed(rand());
    mpz_t rnd;
    mpz_init_set(rnd, mpz_class(rng.get_z_range(mpz_class(
                                    params::plaintextModulus<T>::value())))
                          .get_mpz_t());
    message_t m = util::message_from_mpz_t<T>(rnd);
    _value = m.getValue();
    mpz_clear(rnd);
    return *this;
  };

  /// Operations +, -, *
  message_t &operator+=(message_t const &m) {
    _value = (_value + m._value) % params::plaintextModulus<T>::value();
    return *this;
  }
  message_t &operator*=(message_t const &m) {
    _value = (_value * m._value) % params::plaintextModulus<T>::value();
    return *this;
  }
  message_t &operator-=(message_t const &m) {
    _value = (_value - m._value) % params::plaintextModulus<T>::value();
    return *this;
  }
  friend message_t operator+(message_t const &lhs, message_t const &rhs) {
    message_t m(lhs);
    return m += rhs;
  }
  friend message_t operator*(message_t const &lhs, message_t const &rhs) {
    message_t m(lhs);
    return m *= rhs;
  }
  friend message_t operator-(message_t const &lhs, message_t const &rhs) {
    message_t m(lhs);
    return m -= rhs;
  }

  /// Inversion
  message_t invert() {
    mpz_class inverse;
    mpz_class value(_value);
    mpz_invert(inverse.get_mpz_t(), _value.get_mpz_t(),
               mpz_class(params::plaintextModulus<T>::value()).get_mpz_t());
    return message_t(util::message_from_mpz_t<T>(inverse.get_mpz_t()));
  }
};

/// == operator
template <typename T>
inline bool operator==(message_t<T> const &lhs, message_t<T> const &rhs) {
  return lhs.getValue() == rhs.getValue();
}
template <typename T>
inline bool operator==(message_t<T> const &lhs, T const &rhs) {
  return lhs.getValue() == rhs;
}
template <typename T>
inline bool operator==(T const &lhs, message_t<T> const &rhs) {
  return lhs == rhs.getValue();
}

/// != operator
template <typename T>
inline bool operator!=(message_t<T> const &lhs, message_t<T> const &rhs) {
  return lhs.getValue() != rhs.getValue();
}
template <typename T>
inline bool operator!=(message_t<T> const &lhs, T const &rhs) {
  return lhs.getValue() != rhs;
}
template <typename T>
inline bool operator!=(T const &lhs, message_t<T> const &rhs) {
  return rhs.getValue() != lhs;
}

namespace util {
template <typename T>
std::string value_to_string(T const &value) {
  return std::to_string(value);
}
template <>
std::string value_to_string<mpz_class>(mpz_class const &value) {
  return std::string(value.get_str());
}
}

/// << operator
template <typename T>
std::ostream &operator<<(std::ostream &os, message_t<T> const &m) {
  return os << util::value_to_string(m.getValue());
}

}  // namespace FV

namespace FV {
namespace util {
/// Helper functions for messages conversion
template <>
mpz_class message_from_mpz_t(mpz_t value) {
  return mpz_class(value);
};

template <>
unsigned long message_from_mpz_t(mpz_t value) {
  return mpz_get_ui(value);
};

/**
 * Center op1 modulo op2
 * @param rop     result
 * @param op1     number op1 already reduced modulo op2, i.e. such that 0 <= op1
 * < op2-1
 * @param op2     modulus
 * @param op2Div2 floor(modulus/2)
 */
inline void center(mpz_t &rop, mpz_t const &op1, mpz_t const &op2,
                   mpz_t const &op2Div2) {
  mpz_set(rop, op1);
  if (mpz_cmp(op1, op2Div2) > 0) {
    mpz_sub(rop, rop, op2);
  }
}

/**
 * Compute the quotient of op1 divided by op2 for a centered noise
 * @param rop     result
 * @param op1     numerator
 * @param op2     denominator
 * @param op2Div2 floor(denominator/2)
 */
inline void div_and_round(mpz_t &rop, mpz_t const &op1, mpz_t const &op2,
                          mpz_t const &op2Div2) {
  mpz_t r;
  mpz_init2(r, mpz_size(op2) + 1);

  // Compute op1 = rop * op2 + r
  // where r has the same sign as op1
  mpz_tdiv_qr(rop, r, op1, op2);

  // Correct "rop" so that r is centered around 0
  long sgn = mpz_sgn(r);
  mpz_abs(r, r);
  if (mpz_cmp(r, op2Div2) >= 0) {
    if (sgn > 0) {
      mpz_add_ui(rop, rop, 1);
    } else {
      mpz_sub_ui(rop, rop, 1);
    }
  }

  // Clean
  mpz_clear(r);
}

/**
 * center the coefficients, multiply them by "multiplier" and then divide by the
 * divisor
 * @param coefficients pointer to the initialized coefficients
 * @param degree       number of coefficients to compute
 * @param multiplier   multiplier for the internal multiplication
 * @param divisor      denominator
 * @param divisorDiv2  floor(denominator/2)
 * @param mod_init     modulus of the initial coefficients
 * @param mod_initDiv2 floor(modulus/2)
 */
template <size_t degree>
inline void reduce(std::array<mpz_t, degree> &coefficients, mpz_t multiplier,
                   mpz_t const &divisor, mpz_t const &divisorDiv2,
                   mpz_t const &mod_init, mpz_t const &mod_initDiv2) {
  for (unsigned i = 0; i < degree; i++) {
    // Center with mod_init
    center(coefficients[i], coefficients[i], mod_init, mod_initDiv2);
    // Multiply by multiplier
    mpz_mul(coefficients[i], coefficients[i], multiplier);
    // Divide by divisor
    div_and_round(coefficients[i], coefficients[i], divisor, divisorDiv2);
    // reduction will be done during the mpz2poly()'s calls
    // otherwise one needs to do it
  }
}

/**
 * Lift the polynomial into an array of integer coefficients
 * @param coefficients pointer to the array of coefficients
 * @param c            polynomial P
 */
inline void lift(std::array<mpz_t, params::polyZ_p::degree> &coefficients,
                 params::polyZ_p const &c) {
  // Compute the inverse NTT
  params::polyZ_p other{c};
  other.invntt_pow_invphi();

  // transform the poly into coefficients
  other.poly2mpz(coefficients);
}

/**
 * Convert a polynomial P into a polynomial PZ
 * @param new_c    target polynomial
 * @param c        initial polynomial
 * @param ntt_form boolean to keep the NTT form if any
 */
void convert(params::polyZ_p &new_c, params::poly_p const &c, bool ntt_form) {
  using P = params::poly_p;
  using PZ = params::polyZ_p;

  size_t size_for_shoup = P::bits_in_moduli_product() +
                          sizeof(typename P::value_type) * CHAR_BIT +
                          nfl::static_log2<P::nmoduli>::value + 1;

  // Copy c
  P other{c};

  // Compute the inverse NTT if needed
  if (ntt_form) {
    other.invntt_pow_invphi();
  }

  // Initialize temporary values
  mpz_t tmp, coefficient;
  mpz_init2(tmp, nfl::static_log2<P::nmoduli>::value + size_for_shoup);
  mpz_init2(coefficient,
            P::bits_in_moduli_product() + nfl::static_log2<P::nmoduli>::value);

  // Loop on all the coefficients of c
  for (size_t i = 0; i < P::degree; i++) {
    // Construct the i-th coefficient over ZZ
    mpz_set_ui(coefficient, 0);
    for (size_t cm = 0; cm < P::nmoduli; cm++) {
      // coefficient += other(cm, i) * lifting_integers[cm]
      mpz_addmul_ui(coefficient, P::lifting_integers()[cm], other(cm, i));
    }

    // Modular reduction modulo "moduli_product" using Shoup
    mpz_mul(tmp, coefficient, P::modulus_shoup());
    mpz_tdiv_q_2exp(tmp, tmp, size_for_shoup);  // right shift
    mpz_submul(coefficient, tmp,
               P::moduli_product());  // coefficient -= tmp * moduli_product
    if (mpz_cmp(coefficient, P::moduli_product()) >= 0) {
      mpz_sub(coefficient, coefficient, P::moduli_product());
    }

    // Store the coefficients in new_c
    for (size_t cm = 0; cm < P::nmoduli; cm++) {
      // don't need to recompute for the first moduli
      new_c(cm, i) = other(cm, i);
    }
    for (size_t cm = P::nmoduli; cm < PZ::nmoduli; cm++) {
      new_c(cm, i) = mpz_fdiv_ui(coefficient, P::get_modulus(cm));
    }
  }

  if (ntt_form) {
    new_c.ntt_pow_phi();
  }

  // Clean
  mpz_clears(tmp, coefficient, nullptr);
}
}  // namespace util
}  // namespace FV
