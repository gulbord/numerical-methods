#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char* argv[])
{
    if (argc != 4) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set seed for rng drand48()
    long int seed = 123456;
    srand48(seed);

    FILE* file = fopen("out/A03b.txt", "w");

    // read from cl gaussian params and # of samples
    double mu = atof(argv[1]);
    double sigma = atof(argv[2]);
    int n_smp = atoi(argv[3]);

    // sample with box-muller, generating two n_smp-long arrays
    double r, t;
    double* x = malloc(n_smp * sizeof(*x));
    double* y = malloc(n_smp * sizeof(*y));
    for (int i = 0; i < n_smp; ++i) {
        r = sigma * sqrt(-2 * log(drand48()));
        t = 2 * M_PI * drand48();
        x[i] = mu + r * cos(t);
        y[i] = mu + r * sin(t);
    }

    // write arrays to out (in binary)
    fwrite(x, sizeof(*x), n_smp, file);
    fwrite(y, sizeof(*y), n_smp, file);

    fclose(file);
    free(x);
    free(y);

    return 0;
}
