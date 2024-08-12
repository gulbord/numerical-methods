#include "../lib/mt19937ar.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 3

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        printf("Wrong number of arguments! (Should be %d)\n", N_ARGS);
        printf("[executable] [μ] [# samples]\n");
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    double mu = atof(argv[1]);

    char fname[100];
    snprintf(fname, 100, "out/014a_mu%g.csv", mu);
    FILE *file = fopen(fname, "w");

    // rho(x) = μ * e^(-μ * x) --> sample with F^(-1)(p) = -log(p) / μ
    int n_smp = atoi(argv[2]);
    for (int i = 0; i < n_smp; ++i)
        // genrand_real2() generates on [0, 1), so log(1 - p) is safe
        fprintf(file, "%g\n", -log(1 - genrand_real2()) / mu);

    fclose(file);

    return 0;
}
