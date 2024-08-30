#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 3

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [μ] [# samples]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    double mu = atof(argv[1]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/014a_mu%g.csv", mu);
    FILE *file = fopen(fname, "w");

    // rho(x) = μ * e^(-μ * x) --> sample with F^(-1)(p) = -log(p) / μ
    int n_smp = atoi(argv[2]);
    for (int i = 0; i < n_smp; ++i)
        fprintf(file, "%f\n", -log(1.0 - rng_real()) / mu);

    fclose(file);

    return 0;
}
