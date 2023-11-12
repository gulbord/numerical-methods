#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// sample for different values of N
// ranging from MIN_N to MAX_N, with steps of DN
// N_SMP samplings for each N in [MIN_N, MAX_N]
#define MIN_N 10
#define MAX_N 1000
#define DN 10
#define N_SMP 100

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

int main()
{
    // set seed for rng drand48()
    long int seed = (long int)time(NULL);
    srand48(seed);

    FILE* file = fopen("out/A04b.txt", "w");

    int n, i;
    double n_tow; // just the n to write to file
    double int_n[N_SMP];
    for (n = MIN_N; n <= MAX_N; n += DN) {
        // estimate the integral N_SMP times
        for (i = 0; i < N_SMP; ++i)
            int_n[i] = integral_cos(n);

        // write to file --> N int_n[1], ..., int_n[N_SMP]
        n_tow = (double)n;
        fwrite(&n_tow, sizeof(double), 1, file);
        fwrite(int_n, sizeof(double), N_SMP, file);
    }

    fclose(file);

    return 0;
}
