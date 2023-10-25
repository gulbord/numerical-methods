#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TRUE_INT 0.25

double g(double x) { return x * cos(x * x); }

int main(int argc, const char* argv[]) {
    if (argc != 2) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = (long int)time(NULL);
    srand48(seed);

    // read # of samples from cl
    int n_smp = atoi(argv[1]);

    double r, t;
    double g_sum = 0.0;
    int n = 0;
    while (n < n_smp) {
        // sample two x with modified Box-Müller
        r = sqrt(-log(drand48()));
        t = -M_PI_2 + M_PI * drand48();
        g_sum += g(r * cos(t)) + g(r * fabs(sin(t)));
        n += 2;
    }

    double res = g_sum / (M_2_SQRTPI * n);
    double err = fabs(1 - res / TRUE_INT);

    printf("I = %g\n", res);
    printf("True value = %g --> Error = %2.2f%%\n", TRUE_INT, err * 100);

    return 0;
}
