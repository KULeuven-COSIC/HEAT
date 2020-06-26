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
#include <nfl.hpp>
#include <thread>
#include <vector>
#include "utils.h"

/// include the FV homomorphic encryption library
namespace FV {
namespace params {
using poly_t = nfl::poly_from_modulus<uint64_t, 1 << 12, 248>;
template <typename T>
struct plaintextModulus;
template <>
struct plaintextModulus<mpz_class> {
  static mpz_class value() { return mpz_class("379"); }
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

// Depth of the binary tree
static const unsigned DEPTH = 6;

int main() {
  // Timer
  auto start = std::chrono::steady_clock::now();
  auto end = std::chrono::steady_clock::now();

  // Seed (for deterministic messages values)
  srand(0);

  std::cout << "Timings:" << std::endl;

  // Keygen
  start = std::chrono::steady_clock::now();
  FV::sk_t secret_key;
  end = std::chrono::steady_clock::now();
  std::cout << "\tSecret key generation: \t\t"
            << get_time_us(start, end, 1) << " us" << std::endl;

  start = std::chrono::steady_clock::now();
  FV::evk_t evaluation_key(secret_key, 32);
  end = std::chrono::steady_clock::now();
  std::cout << "\tEvaluation key generation: \t"
            << get_time_us(start, end, 1) << " us" << std::endl;

  start = std::chrono::steady_clock::now();
  FV::pk_t public_key(secret_key, evaluation_key);
  end = std::chrono::steady_clock::now();
  std::cout << "\tPublic key generation: \t\t"
            << get_time_us(start, end, 1) << " us" << std::endl;

  // Messages
  std::array<FV::mess_t, 1 << DEPTH> m;
  start = std::chrono::steady_clock::now();
  for (size_t i = 0; i < (size_t)(1 << DEPTH); i++) {
    m[i].random();
  }
  end = std::chrono::steady_clock::now();
  std::cout << "\tMessages generation: \t\t"
            << get_time_us(start, end, (1 << (DEPTH - 1))) << " us"
            << std::endl;

  // Encrypt
  std::array<FV::ciphertext_t, 1 << DEPTH> c;
  start = std::chrono::steady_clock::now();
  for (size_t i = 0; i < (size_t)(1 << DEPTH); i++) {
    FV::encrypt(c[i], public_key, m[i]);
  }
  end = std::chrono::steady_clock::now();
  std::cout << "\tEncrypt: \t\t\t"
            << get_time_us(start, end, (1 << (DEPTH - 1))) << " us"
            << std::endl;

  // Decrypt
  std::array<FV::mess_t, 1 << DEPTH> m2;
  start = std::chrono::steady_clock::now();
  for (size_t i = 0; i < (size_t)(1 << DEPTH); i++) {
    FV::decrypt(m2[i], secret_key, public_key, c[i]);
  }
  end = std::chrono::steady_clock::now();
  std::cout << "\tDecrypt: \t\t\t"
            << get_time_us(start, end, (1 << (DEPTH - 1))) << " us"
            << std::endl;

  // Additions
  std::array<FV::ciphertext_t, 1 << (DEPTH - 1)> c_add;
  start = std::chrono::steady_clock::now();
  for (size_t i = 0; i < (size_t)(1 << (DEPTH - 1)); i++) {
    c_add[i] = c[2 * i] + c[2 * i + 1];
  }
  end = std::chrono::steady_clock::now();

  std::cout << "\tAdd: \t\t\t\t"
            << get_time_us(start, end, (1 << (DEPTH - 1))) << " us"
            << std::endl;

  // Multiplications
  for (unsigned L = 1; L <= DEPTH; L++) {
    FV::ciphertext_t *c_mul = new FV::ciphertext_t[1 << (DEPTH - L)];

    std::this_thread::sleep_for(std::chrono::seconds(1));
    start = std::chrono::steady_clock::now();
    for (size_t i = 0; i < (size_t)(1 << (DEPTH - L)); i++) {
      c_mul[i] = c[2 * i] * c[2 * i + 1];
    }
    end = std::chrono::steady_clock::now();

    std::cout << "\tMul: \t\t\t\t"
              << get_time_us(start, end, (1 << (DEPTH - L))) << " us"
              << std::endl;

    // Update the tree
    for (size_t i = 0; i < (size_t)(1 << (DEPTH - L)); i++) {
      c[i] = c_mul[i];
      m[i] = m[2 * i];
      m[i] *= m[2 * i + 1];
    }

    // If it is the last level, output result, expected result, and final noise
    if (L == DEPTH) {
      FV::decrypt(m2[0], secret_key, public_key, c_mul[0]);

      std::cout << "Final result: \t\t" << m2[0] << std::endl;
      std::cout << "Expected result: \t" << m[0] << std::endl;
      std::cout << "Final noise: \t\t"
                << noise(m2[0], secret_key, public_key, c_mul[0]) << "/"
                << public_key.noise_max << std::endl;
    }

    // Clean
    delete[] c_mul;
  }

  return 0;
}
