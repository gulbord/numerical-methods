#include "utils/random.h"
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

    rng_set_seed(time(NULL));

    double mu = atof(argv[1]);
    double sigma = atof(argv[2]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/022_mu%g_sigma%g.csv", mu, sigma);
    FILE *file = fopen(fname, "w");
    fprintf(file, "x,y\n");

    int n_smp = atoi(argv[3]);
    for (int i = 0; i < n_smp; ++i) {
        double r = sigma * sqrt(-2.0 * log(1.0 - rng_real()));
        double t = 2.0 * M_PI * rng_real();
        fprintf(file, "%f,%f\n", mu + r * cos(t), mu + r * sin(t));
    }

    fclose(file);

    return 0;
}
