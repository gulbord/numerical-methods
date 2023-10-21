#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, const char* argv[]) {
    if (argc != 3) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = (long int)time(NULL);
    srand48(seed);

    // compose file name
    char fname[100];
    snprintf(fname, 100, "%s%s%s", "out/020201a_out_", argv[1], ".txt");
    FILE* file = fopen(fname, "w");

    // rho(x) = (n + 1) * x^n --> sample with F^(-1)(p) = p^(1/(n+1))
    int n = atoi(argv[1]);
    int n_smp = atoi(argv[2]);
    double* x = malloc(n_smp * sizeof(*x));
    for (int i = 0; i < n_smp; ++i)
        x[i] = pow(drand48(), 1.0 / (n + 1));

    // write the entire array to out (in binary)
    fwrite(x, sizeof(*x), n_smp, file);

    fclose(file);
    free(x);

    return 0;
}
