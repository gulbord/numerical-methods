#include "../lib/mt19937ar.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 4

int main(int argc, const char *argv[])
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [mean] [st. dev.] [# samples]\n");
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    double mu = atof(argv[1]);
    double sigma = atof(argv[2]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/022_mu%g_sigma%g.csv", mu, sigma);
    FILE *file = fopen(fname, "w");
    fprintf(file, "x,y\n");

    double r, t;
    int n_smp = atoi(argv[3]);
    for (int i = 0; i < n_smp; ++i) {
        r = sigma * sqrt(-2 * log(1 - genrand_real2()));
        t = 2 * M_PI * genrand_real1();
        fprintf(file, "%g,%g\n", mu + r * cos(t), mu + r * sin(t));
    }

    fclose(file);

    return 0;
}
