#include "random.h"
#include <float.h>
#include <math.h>

// 63-bits Random number generator U(0, 1): MRG63k3a
// Author: Pierre L’Ecuyer
// Source: P. L’Ecuyer, “Good Parameter Sets for Combined Multiple Recursive
//         Random Number Generators,” Operations Research, vol. 47, no. 1, pp.
//         159-164, Jan. 1999.

#define NORM 1.0842021724855052e-19
#define M1 9223372036854769163
#define M2 9223372036854754679
#define A12 1754669720
#define Q12 5256471877
#define R12 251304723
#define A13N 3182104042
#define Q13 2898513661
#define R13 394451401
#define A21 31387477935
#define Q21 293855150
#define R21 143639429
#define A23N 6199136374
#define Q23 1487847900
#define R23 985240079

static int64_t s[6];

// Adapted from the SplitMix64 implementation by Sebastiano Vigna
// Source: https://prng.di.unimi.it/splitmix64.c (2015)
static uint64_t rng_next_seed(uint64_t seed)
{
    uint64_t x = (seed += 0x9e3779b97f4a7c15);
    x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9;
    x = (x ^ (x >> 27)) * 0x94d049bb133111eb;
    return x ^ (x >> 31);
}

void rng_set_seed(uint64_t seed)
{
    s[0] = seed % M1;
    s[1] = rng_next_seed(s[0]) % M1;
    s[2] = rng_next_seed(s[1]) % M1;
    s[3] = rng_next_seed(s[2]) % M2;
    s[4] = rng_next_seed(s[3]) % M2;
    s[5] = rng_next_seed(s[4]) % M2;
}

// Generate a random double on [0, 1)
double rng_real(void)
{
    int64_t h, p12, p13, p21, p23;

    // Component 1
    h = s[0] / Q13;
    p13 = A13N * (s[0] - h * Q13) - h * R13;
    h = s[1] / Q12;
    p12 = A12 * (s[1] - h * Q12) - h * R12;
 
    if (p13 < 0)
        p13 += M1;
    if (p12 < 0)
        p12 += M1 - p13;
    else
        p12 -= p13;
    if (p12 < 0)
        p12 += M1;

    s[0] = s[1];
    s[1] = s[2];
    s[2] = p12;

    // Component 2
    h = s[3] / Q23;
    p23 = A23N * (s[3] - h * Q23) - h * R23;
    h = s[5] / Q21;
    p21 = A21 * (s[5] - h * Q21) - h * R21;

    if (p23 < 0)
        p23 += M2;
    if (p21 < 0)
        p21 += M2 - p23;
    else
        p21 -= p23;
    if (p21 < 0)
        p21 += M2;

    s[3] = s[4];
    s[4] = s[5];
    s[5] = p21;

    // Combination
    if (p12 > p21)
        return (p12 - p21) * NORM;
    else
        return (p12 - p21 + M1) * NORM;
}

// Generate an integer (32 bit signed) on [min, max]
int32_t rng_int_range(int32_t min, int32_t max)
{
    return min + (int32_t)((max - min + 1.0) * rng_real());
}

// Generate a random int (32 bit unsigned) on [0, n - 1]
uint32_t rng_int_n(uint32_t n) { return (int32_t)(n * rng_real()); }

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
