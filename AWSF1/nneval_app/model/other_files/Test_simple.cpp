/**
 *
 * This file is part of FV-NFLlib
 *
 * Copyright (C) 2016  CryptoExperts
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

#include <cstddef>

#include <gmpxx.h>
#include <nfl.hpp>

/// include the FV homomorphic encryption library
namespace FV {
namespace params {
using poly_t = nfl::poly_from_modulus<uint64_t, 1 << 12, 248>;
template <typename T>
struct plaintextModulus;
template <>
struct plaintextModulus<mpz_class> {
  static mpz_class value() { return mpz_class("123456789"); }
};
using gauss_struct = nfl::gaussian<uint16_t, uint64_t, 2>;
using gauss_t = nfl::FastGaussianNoise<uint16_t, uint64_t, 2>;
gauss_t fg_prng_sk(8.0, 128, 1 << 14);
gauss_t fg_prng_evk(8.0, 128, 1 << 14);
gauss_t fg_prng_pk(8.0, 128, 1 << 14);
gauss_t fg_prng_enc(8.0, 128, 1 << 14);
}
}  // namespace FV::params
#include <FV.hpp>

using namespace FV;

int main() {
  sk_t sk;
  evk_t evk(sk, 32);
  pk_t pk(sk, evk);

  mpz_class value("876543");

  mess_t m(value);
  ciphertext_t c;
  encrypt(c, pk, m);
  std::cout << "initial noise: \t\t" << noise(m, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  mess_t m_dec;

  c += 1;
  value += 1;
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  c += mpz_class("3456789");
  value = (value + mpz_class("3456789")) % params::plaintextModulus<mpz_class>::value();
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  c += m;
  value = (value + m.getValue()) % params::plaintextModulus<mpz_class>::value();
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  c += c;
  value = (2 * value) % params::plaintextModulus<mpz_class>::value();
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  std::cout << "noise after adds.: \t" << noise(m_dec, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  c *= 1;
  value *= 1;
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  std::cout << "noise after mult 1: \t" << noise(m_dec, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  c *= 2;
  value *= 2;
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  std::cout << "noise after mult 2: \t" << noise(m_dec, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  c *= mpz_class("3456789");
  value = (value * mpz_class("3456789")) % params::plaintextModulus<mpz_class>::value();
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  std::cout << "noise after mult 3: \t" << noise(m_dec, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  c *= m;
  value = (value * m.getValue()) % params::plaintextModulus<mpz_class>::value();
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  std::cout << "noise after mult 4: \t" << noise(m_dec, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  c *= c;
  value = (value * value) % params::plaintextModulus<mpz_class>::value();
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  std::cout << "noise after mult 5: \t" << noise(m_dec, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  c *= c;
  value = (value * value) % params::plaintextModulus<mpz_class>::value();
  decrypt(m_dec, sk, pk, c);
  assert(m_dec == mess_t(value));

  std::cout << "noise after mult 6: \t" << noise(m_dec, sk, pk, c) << "/"
            << pk.noise_max << std::endl;

  return 0;
}