#include "../lib/mt19937ar.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        printf("Wrong number of arguments! (Should be %d)\n", N_ARGS);
        printf("[executable] [# samples]\n");
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    FILE *file = fopen("out/014b.csv", "w");

    // rho(x) = 2 * x * e^(-x^2) --> sample with F^(-1)(p) = sqrt(-log(p))
    int n_smp = atoi(argv[1]);
    for (int i = 0; i < n_smp; ++i)
        // genrand_real2() generates on [0, 1), so log(1 - p) is safe
        fprintf(file, "%g\n", sqrt(-log(1 - genrand_real2())));

    fclose(file);

    return 0;
}
