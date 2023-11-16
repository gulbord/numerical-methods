#include "../lib/xoshiro256plusplus.h"
#include <stdio.h>
#include <time.h>

void split_64(uint64_t source, uint64_t* dest)
{
    // generate a 64-bit int with the first 16 bits set to 1:
    uint64_t mask = (1ULL << 16) - 1;
    for (int i = 0; i < 4; ++i) {
        dest[i] = source & mask;
        // discard the first 16 bits of source
        source >>= 16;
    }
}

void init_lattice(int* lattice, int lsiz)
{
    int i, j;
    for (i = 0; i < lsiz; ++i)
        for (j = 0; j < lsiz; ++j)
            lattice[lsiz * i + j] = (next() % 2) * 2 - 1;
}

int main(int argc, const char** argv)
{
    uint64_t seed[4];
    // split the timestamp into 4 and feed the array to the rng
    split_64((uint64_t)time(NULL), seed);
    set_seed(seed);

    return 0;
}
