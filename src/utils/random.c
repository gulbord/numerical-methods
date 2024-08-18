#include "random.h"

// The rng_set_seed() and rng_int() functions form the xoshiro128++ PRNG by
// David Blackman and Sebastiano Vigna [1]. It is very fast and statistically
// robust, and it or others of its family are currently the default PRNGs of
// Javascript, .NET, GNU FORTRAN, Julia and Lua [2].
//
// [1] David Blackman and Sebastiano Vigna. Scrambled linear pseudorandom number
// generators. ACM Trans. Math. Softw., 47:1−32, 2021.
// [2] Sebastiano Vigna. xoshiro / xoroshiro generators and the PRNG shootout.
// Retrieved August 2024 from https://prng.di.unimi.it/.

// Rotate left operation
#define ROTL(x, k) (((x) << (k)) | ((x) >> (32 - (k))))

static uint32_t s[4];

void rng_set_seed(uint32_t seed)
{
    s[0] = seed;
    s[1] = seed ^ 0x9E3779B9;
    s[2] = seed + 0x6A09E667;
    s[3] = seed + 0xBB67AE85;
    for (int i = 0; i < 10; ++i)
        rng_int();
}

uint32_t rng_int(void)
{
    const uint32_t x = ROTL(s[0] + s[3], 7) + s[0];
    const uint32_t t = s[1] << 9;

    s[2] ^= s[0];
    s[3] ^= s[1];
    s[1] ^= s[2];
    s[0] ^= s[3];

    s[2] ^= t;
    s[3] = ROTL(s[3], 11);

    return x;
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
