#include "../lib/mt19937ar.h"
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
    } else if (atof(argv[1]) < 1) {
        fprintf(stderr, "Set the maximum p at least 1!\n");
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    FILE *file = fopen("out/023b.csv", "w");
    fprintf(file, "p,acc\n");

    double max_p = atof(argv[1]);
    int n_p = atoi(argv[2]);
    int n_darts = atoi(argv[3]);

    double dp = (max_p - MIN_P) / n_p;
    double p, p2, A, log_2pA;
    double u, x;

    int i, j, acc;
    for (i = 0; i < n_p; ++i) {
        // Update quantities based on p
        p = MIN_P + i * dp;
        p2 = p * p;
        A = 2 * p / (1 + 2 * p2);
        log_2pA = log(1 + 2 * p2);

        acc = 0;
        for (j = 0; j < n_darts; ++j) {
            u = genrand_real1();
            if (u < A * p) {
                // Sample from uniform g(x) = A
                x = u / A;
                if (genrand_real1() < exp(-x * x))
                    ++acc;
            } else {
                // Sample from exp g(x) = (A / p) * x * e^(p^2 - x^2)
                x = sqrt(p2 - log_2pA - log(1 - u));
                if (genrand_real1() * x < p * exp(-p2))
                    ++acc;
            }
        }

        fprintf(file, "%g,%g\n", p, (double)acc / n_darts);
    }

    fclose(file);

    return 0;
}
