#ifndef RANDOM_H
#define RANDOM_H

#include <stdint.h>

void rng_set_seed(uint64_t seed);
// Generate a random 64 bit unsigned int
uint64_t rng(void);
// Generate a random int (32 bit unsigned) on [0, n - 1]
uint32_t rng_int_n(uint32_t n);
// Generate a random int (32 bit signed) on [min, max]
int32_t rng_int_range(int32_t min, int32_t max);
// Generate a random double on [0, 1)
double rng_real(void);
// Generate a random double with a (0, 1) Gaussian distribution
double rng_gauss(void);

#endif
