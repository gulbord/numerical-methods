#ifndef RANDOM_H
#define RANDOM_H

#include <stdint.h>

void rng_set_seed(uint32_t s);
// Generate a random 32 bit unsigned int on [0, 0xffffffff]
uint32_t rng_int(void);
// Generate a random int (32 bit unsigned) on [0, n - 1]
uint32_t rng_int_n(uint32_t n);
// Generate a random int (32 bit signed) on [min, max]
int32_t rng_int_range(int32_t min, int32_t max);
// Generate a random double on [0, 1]
double rng_uniform_01(void);
// Generate a random double on [0, 1)
double rng_uniform_01_exc(void);
// Generate a random double on (0, 1]
double rng_uniform_exc_01(void);

#endif
