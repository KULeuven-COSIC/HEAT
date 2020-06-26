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

/**
 * Return the time difference between the end time and the start time in us
 *     divided by N
 * @param  start start time
 * @param  end   end time
 * @param  N     denominator
 * @return       time difference / N
 */
template <class T>
double get_time_us(T const &start, T const &end, uint32_t N) {
  auto diff = end - start;
  return (long double)(std::chrono::duration_cast<std::chrono::microseconds>(
                           diff)
                           .count()) /
         N;
}