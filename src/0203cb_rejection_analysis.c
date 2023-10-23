#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define MIN_P M_SQRT1_2

int main(int argc, const char* argv[]) {
    if (argc != 4) {
        printf("Wrong number of arguments!\n");
        return 1;
    } else if (atof(argv[1]) < 1) {
        printf("Set max_p at least 1!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = 123456;
    srand48(seed);

    FILE* file = fopen("out/0203cb.txt", "w");

    // read max value of p, # of p's and # of darts for each p from cl
    double max_p = atof(argv[1]);
    int n_p = atoi(argv[2]);
    int n_darts = atoi(argv[3]);

    double dp = (max_p - MIN_P) / n_p;
    double* p_arr = malloc(n_p * sizeof(double));
    double* acc_arr = malloc(n_p * sizeof(double));
    // quantities for calculations (last is log(2p/A))
    double p, p2, A, log_2pA;
    // random numbers
    double u, x;
    int acc;
    for (int i = 0; i < n_p; ++i) {
        // update quantities based on p
        p = MIN_P + i * dp;
        p2 = p * p;
        A = 2 * p / (1 + 2 * p2);
        log_2pA = log(1 + 2 * p2);

        acc = 0;
        for (int j = 0; j < n_darts; ++j) {
            u = drand48();
            if (u < A * p) {
                // sample from uniform g(x) = A
                x = u / A;
                // accept if u*c*g(x) is below f(x)
                if (drand48() < exp(-x * x))
                    ++acc;
            } else {
                // sample from exp g(x) = (A/p) x e^(p^2-x^2)
                x = sqrt(p2 - log_2pA - log(1 - u));
                // accept if u*c*g(x) is below f(x)
                if (drand48() * x < p * exp(-p2))
                    ++acc;
            }
        }

        // update arrays
        p_arr[i] = p;
        acc_arr[i] = (double)acc / n_darts;
    }

    fwrite(p_arr, sizeof(double), n_p, file);
    fwrite(acc_arr, sizeof(double), n_p, file);

    fclose(file);
    free(p_arr);
    free(acc_arr);

    return 0;
}
