#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TRUE_INT 1.0

double integral_cos(int N)
{
    double x;
    double f_sum = 0.0;
    for (int i = 0; i < N; ++i) {
        // sample x ~ g(x) = (3/pi)(1 - (4/pi^2)x^2)
        x = M_PI * sin(asin(drand48()) / 3);
        f_sum += cos(x) / (1 - M_2_PI * M_2_PI * x * x);
    }

    return M_PI * f_sum / (3 * N);
}

int main(int argc, const char* argv[])
{
    if (argc != 2) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = (long int)time(NULL);
    srand48(seed);

    // read # of samples from cl
    int n_smp = atoi(argv[1]);

    double x;
    double f_sum = 0.0;
    for (int i = 0; i < n_smp; ++i) {
        // sample x ~ g(x) = (3/pi)(1 - (4/pi^2)x^2)
        x = M_PI * sin(asin(drand48()) / 3);
        f_sum += cos(x) / (1 - M_2_PI * M_2_PI * x * x);
    }

    double res = M_PI * f_sum / (3 * n_smp);
    double err = fabs(1 - res / TRUE_INT);

    printf("I = %g\n", res);
    printf("True value = %g --> Error = %2.2f%%\n", TRUE_INT, err * 100);

    return 0;
}
