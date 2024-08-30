#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [# samples]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    FILE *file = fopen("out/014b.csv", "w");

    // rho(x) = 2 * x * e^(-x^2) --> sample with F^(-1)(p) = sqrt(-log(p))
    int n_smp = atoi(argv[1]);
    for (int i = 0; i < n_smp; ++i)
        fprintf(file, "%f\n", sqrt(-log(1.0 - rng_real())));

    fclose(file);

    return 0;
}
