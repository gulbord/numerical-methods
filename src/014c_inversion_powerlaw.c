#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 5

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [a] [b] [n] [# samples]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    double a = atof(argv[1]);
    double b = atof(argv[2]);
    double n = atof(argv[3]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/014c_a%g_b%g_n%g.csv", a, b, n);
    FILE *file = fopen(fname, "w");

    // rho(x) = b * (n - 1) * a^(n - 1) / (a + b * x)^n
    // --> sample with F^(-1)(p) = a * (p^(1 / (1 - n)) - 1) / b
    int n_smp = atoi(argv[4]);
    double ab = a / b;
    double iimn = 1.0 / (1.0 - n);
    for (int i = 0; i < n_smp; ++i)
        fprintf(file, "%g\n", ab * (pow(rng_real(), iimn) - 1.0));

    fclose(file);

    return 0;
}
