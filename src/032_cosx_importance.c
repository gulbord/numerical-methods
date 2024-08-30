#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 5

double integral_cos(int n)
{
    double f_sum = 0.0;
    for (int i = 0; i < n; ++i) {
        // Sample x ~ g(x) = (3/pi)(1 - (4/pi^2)x^2)
        double x = M_PI * sin(asin(rng_real()) / 3.0);
        f_sum += cos(x) / (1.0 - M_2_PI * M_2_PI * x * x);
    }

    return M_PI * f_sum / (3 * n);
}

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments!\n");
        fprintf(stderr,
                "[executable] [min. N] [max. N] [dN] [# samples per N]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    int min_n = atoi(argv[1]);
    int max_n = atoi(argv[2]);
    int dn = atoi(argv[3]);
    int n_smp = atoi(argv[4]);

    FILE *file = fopen("out/032.csv", "w");
    fprintf(file, "n,integral\n");

    for (int n = min_n; n <= max_n; n += dn)
        for (int i = 0; i < n_smp; ++i)
            fprintf(file, "%d,%g\n", n, integral_cos(n));

    fclose(file);

    return 0;
}
