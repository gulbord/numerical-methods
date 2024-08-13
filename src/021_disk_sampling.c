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

    FILE *file = fopen("out/021.csv", "w");
    fprintf(file, "r_naive,r_correct,theta\n");

    int n_smp = atoi(argv[1]);
    for (int i = 0; i < n_smp; ++i)
        fprintf(file, "%g,%g,%g\n", genrand_real1(), sqrt(genrand_real1()),
                2 * M_PI * genrand_real1());

    fclose(file);

    return 0;
}
