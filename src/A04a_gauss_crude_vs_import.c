#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// sample for different values of N
// ranging from MIN_N to MAX_N, with steps of DN
// N_SMP samplings for each N in [MIN_N, MAX_N]
#define MIN_N 500
#define MAX_N 5000
#define DN 10
#define N_SMP 100
#define MAX_X 5
#define TRUE_INT 0.25

inline double g(double x) { return x * cos(x * x); }

inline double f(double x)
{
    double x2 = x * x;
    return x * cos(x2) * exp(-x2);
}

double integ_crude(int N)
{
    double f_sum = 0.0;
    for (int i = 0; i < N; ++i)
        f_sum += f(MAX_X * drand48());

    return MAX_X * f_sum / N;
}

double integ_impor(int N)
{
    double r, t;
    double g_sum = 0.0;
    int n = 0;
    while (n < N) {
        // sample x, y with modified Box-Muller
        r = sqrt(-log(drand48()));
        t = -M_PI_2 + M_PI * drand48();
        g_sum += g(r * cos(t)) + g(r * fabs(sin(t)));
        n += 2;
    }

    return g_sum / (M_2_SQRTPI * N);
}

int main()
{
    // set seed for rng drand48()
    long int seed = (long int)time(NULL);
    srand48(seed);

    FILE* file = fopen("out/A04a.txt", "w");

    int n, i;
    double n_tow; // just the n to write to file
    double crude[N_SMP], impor[N_SMP];
    for (n = MIN_N; n < MAX_N; n += DN) {
        // estimate the integrals N_SMP times
        for (i = 0; i < N_SMP; ++i) {
            crude[i] = integ_crude(n);
            impor[i] = integ_impor(n);
        }

        // write to file
        // --> N, crude[1], ..., crude[N_SMP], impor[1], ...
        n_tow = (double)n;
        fwrite(&n_tow, sizeof(double), 1, file);
        fwrite(crude, sizeof(double), N_SMP, file);
        fwrite(impor, sizeof(double), N_SMP, file);
    }

    fclose(file);

    return 0;
}
