#include "../lib/xoshiro256plusplus.h"
#include <stdio.h>
#include <time.h>

#define L 10

void init_lattice(int* lattice, int lsiz)
{
    int i, j;
    for (i = 0; i < lsiz; ++i) {
        for (j = 0; j < lsiz; ++j) {
            lattice[lsiz * i + j] = (next() % 2) * 2 - 1;
        }
    }
}

int main()
{
    set_seed((uint64_t)time(NULL));

    int lattice[L * L];
    init_lattice(lattice, L);

    for (int i = 0; i < L; ++i)
        printf("%d ", lattice[i]);
    printf("\n");

    return 0;
}
