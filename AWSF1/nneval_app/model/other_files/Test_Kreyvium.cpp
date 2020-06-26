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
#include <algorithm>
#include <chrono>
#include <nfl.hpp>
#include "utils.h"

/// include the FV homomorphic encryption library
namespace FV {
namespace params {
using poly_t = nfl::poly_from_modulus<uint64_t, 1 << 12, 248>;
template <typename T>
struct plaintextModulus;
template <>
struct plaintextModulus<mpz_class> {
  static mpz_class value() { return mpz_class(2); }
};
template <>
struct plaintextModulus<unsigned long> {
  static unsigned long value() { return 2; }
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

template <typename K, typename IV, typename S, typename O, size_t N>
void Kreyvium(std::array<K, 128> const &key, std::array<IV, 128> const &iv,
              std::array<S, 288> &state, std::array<O, N> &output) {
  // std::cout << "state" << std::endl;
  // state
  for (size_t i = 1; i < 94; i++) state[i - 1] = key[i - 1];
  for (size_t i = 94; i < 178; i++) state[i - 1] = iv[i - 94];
  for (size_t i = 84; i < 128; i++) state[i + 94 - 1] = iv[i];
  for (size_t i = 222; i < 288; i++) state[i - 1] = 1;
  state[288 - 1] = 0;

  // copy the key and the iv
  // std::cout << "copy" << std::endl;
  std::array<K, 128> keyp = key;
  std::array<IV, 128> ivp = iv;
  // std::copy(key.begin(), key.end(), keyp.begin());
  // std::copy(iv.begin(), iv.end(), ivp.begin());
  std::reverse(keyp.begin(), keyp.end());
  std::reverse(ivp.begin(), ivp.end());

  // std::cout << "loop" << std::endl;
  for (size_t i = 1; i <= 1152 + N; i++) {
    // std::cout << "loop " << i << std::endl;
    auto t1 = state[66 - 1] + state[93 - 1];
    // std::cout << "loop " << i << std::endl;
    auto t2 = state[162 - 1] + state[177 - 1];
    // std::cout << "loop " << i << std::endl;
    auto t3 = state[243 - 1] + state[288 - 1] + keyp[0];
    if (i > 1152) output[i - 1152 - 1] = t1 + t2 + t3;
    // std::cout << "loop " << i << std::endl;
    t1 += state[91 - 1] * state[92 - 1] + state[171 - 1] + ivp[0];
    t2 += state[175 - 1] * state[176 - 1] + state[264 - 1];
    t3 += state[286 - 1] + state[287 - 1] + state[69 - 1];
    auto t4 = keyp[0];
    auto t5 = ivp[0];
    // std::cout << "loop " << i << std::endl;
    for (size_t j = 93; j > 1; j--) state[j - 1] = state[j - 2];
    state[1 - 1] = t3;
    for (size_t j = 177; j > 94; j--) state[j - 1] = state[j - 2];
    state[94 - 1] = t1;
    for (size_t j = 288; j > 178; j--) state[j - 1] = state[j - 2];
    state[178 - 1] = t2;
    for (size_t j = 0; j < 127; j++) keyp[j] = keyp[j + 1];
    keyp[127] = t4;
    for (size_t j = 0; j < 127; j++) ivp[j] = ivp[j + 1];
    ivp[127] = t5;
    // std::cout << "loop " << i << std::endl;
  }
}

int main() {
  size_t const N = 30;
  FV::sk_t sk;
  FV::evk_t evk(sk, 32);
  FV::pk_t pk(sk, evk);

  // Timer
  auto start = std::chrono::steady_clock::now();
  auto end = std::chrono::steady_clock::now();

  // Seed (for deterministic values)
  srand(0);

  // Key & IV
  std::array<unsigned long, 128> key, iv;
  std::generate(key.begin(), key.end(), [] { return rand() & 1; });
  std::generate(iv.begin(), iv.end(), [] { return rand() & 1; });

  // State and output
  std::array<FV::message_t<unsigned long>, 288> state;
  std::array<FV::message_t<unsigned long>, N> output;

  // Plaintext krevium
  start = std::chrono::steady_clock::now();
  Kreyvium(key, iv, state, output);
  end = std::chrono::steady_clock::now();
  std::cout << "\tPlaintext Kreyvium: \t\t"
            << get_time_us(start, end, 2) << " s" << std::endl;

  // Print output
  for (auto const &v : output) {
    std::cout << v;
  }
  std::cout << std::endl;

  // Encrypted Key
  std::array<FV::ciphertext_t, 128> e_key;
  start = std::chrono::steady_clock::now();
  for (size_t i = 0; i < 128; i++) encrypt_integer(e_key[i], pk, key[i]);
  end = std::chrono::steady_clock::now();
  std::cout << "\tEncrypt Key: \t\t" << get_time_us(start, end, 2)
            << " us" << std::endl;

  // Encrypted state & output
  std::array<FV::ciphertext_t, 288> e_state;
  std::generate(e_state.begin(), e_state.end(), [&pk] {
    return FV::ciphertext_t(pk, 0);
  });  // set the public key in all the state ciphertexts
  std::array<FV::ciphertext_t, N> e_output;

  // Kreyvium
  start = std::chrono::steady_clock::now();
  Kreyvium(e_key, iv, e_state, e_output);
  end = std::chrono::steady_clock::now();
  std::cout << "\tHomomorphic Kreyvium: \t\t"
            << get_time_us(start, end, 2) / 1000000 << " s"
            << std::endl;

  return 0;
}