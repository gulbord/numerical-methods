#include "random.h"
#include <float.h>
#include <math.h>

#define NN 312
#define MM 156
#define MATRIX_A 0xB5026F5AA96619E9ULL
#define UM 0xFFFFFFFF80000000ULL // Most significant 33 bits
#define LM 0x7FFFFFFFULL         // Least significant 31 bits
#define S 6364136223846793005ULL

// Array for the state vector
static uint64_t mt[NN];
// mti == NN + 1 means mt[NN] is not initialized
static int mti = NN + 1;

void rng_set_seed(uint64_t seed)
{
    mt[0] = seed;
    for (mti = 1; mti < NN; ++mti)
        mt[mti] = S * (mt[mti - 1] ^ (mt[mti - 1] >> 62)) + mti;
}

// Generate a random 64 bit unsigned int
uint64_t rng(void)
{
    int i;
    uint64_t x;
    static uint64_t mag01[2] = {0ULL, MATRIX_A};

    if (mti >= NN) { // Generate NN words at one time
        // if rng_set_seed() has not been called,
        // a default initial seed is used
        if (mti == NN + 1)
            rng_set_seed(5489ULL);

        for (i = 0; i < NN - MM; ++i) {
            x = (mt[i] & UM) | (mt[i + 1] & LM);
            mt[i] = mt[i + MM] ^ (x >> 1) ^ mag01[(int)(x & 1ULL)];
        }
        for (; i < NN - 1; ++i) {
            x = (mt[i] & UM) | (mt[i + 1] & LM);
            mt[i] = mt[i + MM - NN] ^ (x >> 1) ^ mag01[(int)(x & 1ULL)];
        }

        x = (mt[NN - 1] & UM) | (mt[0] & LM);
        mt[NN - 1] = mt[MM - 1] ^ (x >> 1) ^ mag01[(int)(x & 1ULL)];

        mti = 0;
    }

    x = mt[mti++];

    x ^= (x >> 29) & 0x5555555555555555ULL;
    x ^= (x << 17) & 0x71D67FFFEDA60000ULL;
    x ^= (x << 37) & 0xFFF7EEE000000000ULL;
    x ^= (x >> 43);

    return x;
}

// Generate a random int (32 bit unsigned) on [0, n - 1]
//
// M.E. O'Neill. 2018. Efficiently generating a number in a range. PCG, a Better
// Random Number Generator. Retrieved August 2024 from
// https://www.pcg-random.org/posts/bounded-rands.html.
uint32_t rng_int_n(uint32_t n)
{
    uint32_t mask = -1;
    --n;
    // Restrict mask to the closest [0, 2^k) range fitting [0, --n]
    mask >>= __builtin_clz(n | 1);
    uint32_t x;
    do {
        x = (rng() >> 32) & mask;
    } while (x > n);

    return x;
}

// Generate an integer (32 bit signed) on [min, max]
int32_t rng_int_range(int32_t min, int32_t max)
{
    uint32_t range = (uint32_t)(max - min) + 1U;
    return min + rng_int_n(range);
}

// Generate a random double on [0, 1)
double rng_real(void) { return (rng() >> 11) * 0x1.0p-53; }

// Generate a random double with a (0, 1) Gaussian distribution
double rng_gauss(void)
{
    static double cached = DBL_MAX;
    double result;

    if (cached == DBL_MAX) {
        double r = sqrt(-2.0 * log(1.0 - rng_real()));
        double t = 2.0 * M_PI * rng_real();
        cached = r * sin(t);
        result = r * cos(t);
    } else {
        result = cached;
        cached = DBL_MAX;
    }

    return result;
}
