#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define P M_SQRT1_2

int main(int argc, const char* argv[])
{
    if (argc != 2) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = 123456;
    srand48(seed);

    FILE* file = fopen("out/0203ca.txt", "w");

    // read # of darts from cl
    int n_smp = atoi(argv[1]);
    double* smp = malloc(n_smp * sizeof(double));
    // quantities for calculations [last is log(2p/A)]
    double p2 = P * P;
    double A = 2 * P / (1 + 2 * p2);
    double log_2pA = log(1 + 2 * p2);
    // random numbers
    double u, x;

    int acc = 0;
    while (acc < n_smp) {
        u = drand48();
        if (u < A * P) {
            // sample from unif g(x) = A
            x = u / A;
            if (drand48() < exp(-x * x))
                smp[acc++] = x;
        } else {
            // sample from exp g(x) = (A/p) x e^(p^2 - x^2)
            x = sqrt(p2 - log_2pA - log(1 - u));
            if (drand48() * x < P * exp(-p2))
                smp[acc++] = x;
        }
    }

    fwrite(smp, sizeof(double), n_smp, file);

    fclose(file);
    free(smp);

    return 0;
}
