#include "../lib/mt19937ar.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2
#define P M_SQRT1_2

int main(int argc, const char *argv[])
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments!\n");
        fprintf(stderr, "[executable] [# samples]\n");
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    FILE *file = fopen("out/023a.csv", "w");

    int n_smp = atoi(argv[1]);

    double p2 = P * P;
    double A = 2 * P / (1 + 2 * p2);
    double log_2pA = log(1 + 2 * p2); // log(2p / A)
    double u, x;

    int acc = 0;
    while (acc < n_smp) {
        u = genrand_real1();
        if (u < A * P) {
            // Sample from unif g(x) = A
            x = u / A;
            if (genrand_real1() < exp(-x * x)) {
                ++acc;
                fprintf(file, "%g\n", x);
            }
        } else {
            // Sample from exp g(x) = (A / p) * x * e^(p^2 - x^2)
            x = sqrt(p2 - log_2pA - log(1 - u));
            if (genrand_real1() * x < P * exp(-p2)) {
                ++acc;
                fprintf(file, "%g\n", x);
            }
        }
    }

    fclose(file);

    return 0;
}
