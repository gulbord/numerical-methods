#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, const char* argv[])
{
    if (argc != 2) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = (long int)time(NULL);
    srand48(seed);

    FILE* file = fopen("out/A02b.txt", "w");

    // rho(x) = (3/8) * x^2 --> sample with F^(-1)(p) = 2 * p^(1/3)
    int n_smp = atoi(argv[1]);
    double* x = malloc(n_smp * sizeof(*x));
    for (int i = 0; i < n_smp; ++i)
        x[i] = 2 * pow(drand48(), 1.0 / 3);

    // write the entire array to out (in binary)
    fwrite(x, sizeof(*x), n_smp, file);

    fclose(file);
    free(x);

    return 0;
}
