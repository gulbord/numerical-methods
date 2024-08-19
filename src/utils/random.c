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
#define ROTL(X, K) (((X) << (K)) | ((X) >> (64 - (K))))

static uint64_t s[4];

static uint64_t rng_next_seed(uint64_t seed)
{
    uint64_t x = (seed += 0x9e3779b97f4a7c15);
    x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9;
    x = (x ^ (x >> 27)) * 0x94d049bb133111eb;
    return x ^ (x >> 31);
}

void rng_set_seed(uint64_t seed)
{
    s[0] = seed;
    s[1] = rng_next_seed(s[0]);
    s[2] = rng_next_seed(s[1]);
    s[3] = rng_next_seed(s[2]);
}

// Generate a random 64 bit unsigned int
uint64_t rng(void)
{
    const uint64_t x = ROTL(s[0] + s[3], 23) + s[0];
    const uint64_t t = s[1] << 17;

    s[2] ^= s[0];
    s[3] ^= s[1];
    s[1] ^= s[2];
    s[0] ^= s[3];

    s[2] ^= t;
    s[3] = ROTL(s[3], 45);

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
