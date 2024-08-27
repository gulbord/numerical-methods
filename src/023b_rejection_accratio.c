#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 4
#define MIN_P M_SQRT1_2

int main(int argc, const char *argv[])
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments!\n");
        fprintf(stderr, "[executable] [max. p] [# p] [# darts for each p]\n");
        return 1;
    } else if (atof(argv[1]) < 1.0) {
        fprintf(stderr, "Set the maximum p at least 1!\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    FILE *file = fopen("out/023b.csv", "w");
    fprintf(file, "p,acc\n");

    double max_p = atof(argv[1]);
    int n_p = atoi(argv[2]);
    int n_darts = atoi(argv[3]);

    double dp = (max_p - MIN_P) / n_p;

    for (int i = 0; i < n_p; ++i) {
        double p = MIN_P + i * dp;
        double p2 = p * p;
        double A = 2.0 * p / (1.0 + 2.0 * p2);
        double log_2pA = log(1.0 + 2.0 * p2);

        int acc = 0;
        for (int j = 0; j < n_darts; ++j) {
            double u = rng_real();
            if (u < A * p) {
                // Sample from uniform g(x) = A
                double x = u / A;
                if (rng_real() < exp(-x * x))
                    ++acc;
            } else {
                // Sample from exp g(x) = (A / p) * x * e^(p^2 - x^2)
                double x = sqrt(p2 - log_2pA - log(1.0 - u));
                if (rng_real() * x < p * exp(-p2))
                    ++acc;
            }
        }

        fprintf(file, "%g,%g\n", p, (double)acc / n_darts);
    }

    fclose(file);

    return 0;
}
