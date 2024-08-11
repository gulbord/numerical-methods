#include "../lib/mt19937ar.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2

int main(int argc, const char *argv[])
{
    if (argc != N_ARGS) {
        printf("Wrong number of arguments! (Should be %d)\n", N_ARGS);
        printf("[executable] [# samples]\n");
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    FILE *file = fopen("out/013.csv", "w");

    // rho(x) = (3/8) * x^2 --> sample with F^(-1)(p) = 2 * p^(1/3)
    int n_smp = atoi(argv[1]);
    for (int i = 0; i < n_smp; ++i)
        fprintf(file, "%g\n", 2 * pow(genrand_real1(), 1.0 / 3));

    fclose(file);

    return 0;
}
