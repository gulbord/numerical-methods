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

    FILE *file = fopen("out/013.csv", "w");

    // rho(x) = (3/8) * x^2 --> sample with F^(-1)(p) = 2 * p^(1/3)
    int n_smp = atoi(argv[1]);
    for (int i = 0; i < n_smp; ++i)
        fprintf(file, "%g\n", 2.0 * pow(rng_real(), 1.0 / 3.0));

    fclose(file);

    return 0;
}
