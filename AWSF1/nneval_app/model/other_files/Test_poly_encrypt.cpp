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
#include <chrono>
#include <iostream>
#include "/home/sujoy/nfllib/include/nfl.hpp"
#include <thread>
#include <vector>

/// include the FV homomorphic encryption library
namespace FV {
namespace params {
using poly_t = nfl::poly_from_modulus<uint64_t, 8, 310>;
template <typename T>
struct plaintextModulus;
template <>
struct plaintextModulus<mpz_class> {
  static mpz_class value() {
    return mpz_class("987654345678987654345678987654323456953");
  }
};
using gauss_struct = nfl::gaussian<uint16_t, uint64_t, 2>;
using gauss_t = nfl::FastGaussianNoise<uint16_t, uint64_t, 2>;
gauss_t fg_prng_sk(8.0, 128, 1 << 14);
gauss_t fg_prng_evk(8.0, 128, 1 << 14);
gauss_t fg_prng_pk(8.0, 128, 1 << 14);
gauss_t fg_prng_enc(8.0, 128, 1 << 14);
}
}  // namespace FV::params
#include "FV.hpp"

int main() {
  // Seed (for deterministic values)
  srand(0);

  // Keygen
  FV::sk_t secret_key;
  FV::evk_t evaluation_key(secret_key, 32);
  FV::pk_t public_key(secret_key, evaluation_key);

  // Polynomials
  FV::params::poly_p m[2];
  m[0] = {1, 2, 3, 4, 5, 6, 7, 8};
  m[1] = {8, 7, 6, 5, 4, 3, 2, 1};

  // Encrypt
  std::array<FV::ciphertext_t, 2> c;
  FV::encrypt_poly(c[0], public_key, m[0]);
  FV::encrypt_poly(c[1], public_key, m[1]);

  // Initialize polym
  std::array<mpz_t, 8> polym0, polym1;
  for (size_t i = 0; i < 8; i++) {
    mpz_inits(polym0[i], polym1[i], nullptr);
  }

  // decrypt to the polym
  FV::decrypt_poly(polym0, secret_key, public_key, c[0]);
  FV::decrypt_poly(polym1, secret_key, public_key, c[1]);

  // Script sage
  std::cout << "# Sage script for the verification" << std::endl;
  std::cout << "p=" << FV::params::plaintextModulus<mpz_class>::value().get_str() << std::endl;
  std::cout << "K.<X> = QuotientRing(GF(p)[x], GF(p)[x].ideal(x^8 + 1));"
            << std::endl;

  std::cout << "m0 = ";
  for (size_t i = 0; i < 8; i++) {
    std::cout << mpz_class(polym0[i]).get_str() << "*X^" << i
              << (i == 7 ? ";\n" : "+");
  }
  std::cout << "m1 = ";
  for (size_t i = 0; i < 8; i++) {
    std::cout << mpz_class(polym1[i]).get_str() << "*X^" << i
              << (i == 7 ? ";\n" : "+");
  }

  // Multiplication and decryption
  FV::ciphertext_t prod = c[0] * c[1];
  FV::decrypt_poly(polym0, secret_key, public_key, prod);

  std::cout << "m = ";
  for (size_t i = 0; i < 8; i++) {
    std::cout << mpz_class(polym0[i]).get_str() << "*X^" << i
              << (i == 7 ? ";\n" : "+");
  }

  std::cout << "m == m0*m1" << std::endl;

  // Clean
  for (size_t i = 0; i < 8; i++) {
    mpz_clears(polym0[i], polym1[i], nullptr);
  }

  return 0;
}
