#include "random.h"

// Period parameters
#define N 624
#define M 397
#define MATRIX_A 0x9908b0dfU   // Constant vector a
#define UPPER_MASK 0x80000000U // most significant w-r bits
#define LOWER_MASK 0x7fffffffU // least significant r bits

#define TEMPERING_MASK_B 0x9d2c5680U
#define TEMPERING_MASK_C 0xefc60000U

static uint32_t mt[N];  // Array for the state vector
static int mti = N + 1; // mti == N + 1 means mt[N] is not initialized

void rng_set_seed(uint32_t s)
{
    mt[0] = s;
    for (mti = 1; mti < N; mti++)
        mt[mti] = (1812433253U * (mt[mti - 1] ^ (mt[mti - 1] >> 30)) + mti);
}

// Generate a random 32 bit unsigned int on [0, 0xffffffff]
// Source: MT19937 by Takuji Nishimura and Makoto Matsumoto
// Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
// All rights reserved.
// Copyright (C) 2005, Mutsuo Saito, All rights reserved.
uint32_t rng_int(void)
{
    uint32_t y;
    static uint32_t mag01[2] = {0x0U, MATRIX_A};

    // Generate N words at one time
    if (mti >= N) {
        int kk;

        if (mti == N + 1)
            rng_set_seed(5489U); // Default initial seed

        for (kk = 0; kk < N - M; ++kk) {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
            mt[kk] = mt[kk + M] ^ (y >> 1) ^ mag01[y & 0x1U];
        }
        for (; kk < N - 1; ++kk) {
            y = (mt[kk] & UPPER_MASK) | (mt[kk + 1] & LOWER_MASK);
            mt[kk] = mt[kk + (M - N)] ^ (y >> 1) ^ mag01[y & 0x1U];
        }
        y = (mt[N - 1] & UPPER_MASK) | (mt[0] & LOWER_MASK);
        mt[N - 1] = mt[M - 1] ^ (y >> 1) ^ mag01[y & 0x1U];

        mti = 0;
    }

    y = mt[mti++];

    // Tempering
    y ^= (y >> 11);
    y ^= (y << 7) & TEMPERING_MASK_B;
    y ^= (y << 15) & TEMPERING_MASK_C;
    y ^= (y >> 18);

    return y;
}

// Generate a random int (32 bit unsigned) on [0, n - 1]
//
// Original source:
// D. Lemire, ‘Fast random integer generation in an interval’, ACM
// Trans. Model. Comput. Simul., vol. 29, no. 1, pp. 1–12, Jan. 2019.
//
// With modifications taken from:
// M. E. O’Neill, “Efficiently generating a number in a range,” PCG, A Better
// Random Number Generator, https://www.pcg-random.org/posts/bounded-rands.html
// (accessed Aug. 2024).
uint32_t rng_int_n(uint32_t n)
{
    uint32_t x = rng_int();
    uint64_t m = (uint64_t)x * (uint64_t)n;
    uint32_t l = (uint32_t)m;
    if (l < n) {
        uint32_t t = -n;
        if (t >= n) {
            t -= n;
            if (t >= n)
                t %= n;
        }
        while (l < t) {
            x = rng_int();
            m = (uint64_t)x * (uint64_t)n;
            l = (uint32_t)m;
        }
    }

    return m >> 32;
}

// Generate an integer (32 bit signed) on [min, max]
int32_t rng_int_range(int32_t min, int32_t max)
{
    uint32_t range = (uint32_t)(max - min) + 1U;
    return min + rng_int_n(range);
}

// Generate a random double on [0, 1]
double rng_uniform_01(void) { return rng_int() * (1.0 / 4294967295.0); }

// Generate a random double on [0, 1)
double rng_uniform_01_exc(void) { return rng_int() * (1.0 / 4294967296.0); }

// Generate a random double on (0, 1]
double rng_uniform_exc_01(void)
{
    return 1.0 - rng_int() * (1.0 / 4294967296.0);
}
