#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2

int main(int argc, const char *argv[])
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [# samples]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    FILE *file = fopen("out/021.csv", "w");
    fprintf(file, "r_naive,r_correct,theta\n");

    int n_smp = atoi(argv[1]);
    for (int i = 0; i < n_smp; ++i)
        fprintf(file, "%g,%g,%g\n", rng_real(), sqrt(rng_real()),
                2 * M_PI * rng_real());

    fclose(file);

    return 0;
}
