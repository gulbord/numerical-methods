#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 5
#define MAX_X 5
#define TRUE_INT 0.25

inline double g(double x) { return x * cos(x * x); }

inline double f(double x)
{
    double x2 = x * x;
    return x * cos(x2) * exp(-x2);
}

double integral_crude(int n)
{
    double f_sum = 0.0;
    for (int i = 0; i < n; ++i)
        f_sum += f(MAX_X * rng_real());

    return MAX_X * f_sum / n;
}

double integral_importance(int n)
{
    int i = 0;
    double g_sum = 0.0;
    while (i < n) {
        // Sample x, y with modified Box-Muller
        double r = sqrt(-log(1.0 - rng_real()));
        double t = -M_PI_2 + M_PI * rng_real();
        g_sum += g(r * cos(t)) + g(r * fabs(sin(t)));
        i += 2;
    }

    return g_sum / (M_2_SQRTPI * n);
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

    FILE *file = fopen("out/031.csv", "w");
    fprintf(file, "n,crude,importance\n");

    for (int n = min_n; n <= max_n; n += dn)
        for (int i = 0; i < n_smp; ++i)
            fprintf(file, "%d,%g,%g\n", n,
                    fabs(1.0 - integral_crude(n) / TRUE_INT),
                    fabs(1.0 - integral_importance(n) / TRUE_INT));

    fclose(file);

    return 0;
}
