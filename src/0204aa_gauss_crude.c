#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TRUE_INT 0.25

double f(double x)
{
    double x2 = x * x;
    return x * cos(x2) * exp(-x2);
}

int main(int argc, const char* argv[])
{
    if (argc != 3) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = (long int)time(NULL);
    srand48(seed);

    // read max x and # of samples from cl
    double max_x = atof(argv[1]);
    int n_smp = atoi(argv[2]);

    double f_sum = 0.0;
    for (int i = 0; i < n_smp; ++i)
        f_sum += f(max_x * drand48());

    double res = max_x * f_sum / n_smp;
    double err = fabs(1 - res / TRUE_INT);

    printf("I = %g\n", res);
    printf("True value = %g --> Error = %2.2f%%\n", TRUE_INT, err * 100);

    return 0;
}
