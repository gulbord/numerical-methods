#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// sample for N_PTS different values of N
// ranging from DN to N_PTS * DN, with steps of DN
// N_SMP samplings for each N in [DN, N_PTS * DN]
#define N_PTS 100
#define DN 2
#define N_SMP 10

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

    FILE* file = fopen("out/0204b.txt", "w");

    int n;
    double n_tow; // just the n to write to file
    double int_n[N_SMP];
    int i, j;
    for (i = 0; i < N_PTS; ++i) {
        // calculate the current N
        n = (i + 1) * DN;
        // estimate the integral N_SMP times
        for (j = 0; j < N_SMP; ++j)
            int_n[j] = integral_cos(n);

        // write to file --> N int_n[1], ..., int_n[N_SMP]
        n_tow = (double)n;
        fwrite(&n_tow, sizeof(double), 1, file);
        fwrite(int_n, sizeof(double), N_SMP, file);
    }

    fclose(file);

    return 0;
}
