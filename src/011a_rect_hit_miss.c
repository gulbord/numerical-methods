#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 4

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [# points to plot] ");
        fprintf(stderr, "[step] [# replicas]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    FILE *file = fopen("out/011a.csv", "w");
    fprintf(file, "throws,error\n");

    int n, i, j;
    int n_plot = atoi(argv[1]); // Number of different max_iter to analyse
    int dn = atoi(argv[2]);     // Step in max_iter
    int rep = atoi(argv[3]);    // Replicas for each value of max_iter
    int hits, throws;
    double x, y, mc_area;

    for (n = 0; n < n_plot; ++n) {
        throws = (1 + n) * dn;

        for (i = 0; i < rep; ++i) {
            hits = 0; // Reset hit counter
            for (j = 0; j < throws; ++j) {
                x = rng_uniform_01();
                y = rng_uniform_01();
                if (x < 0.5 && y < 0.5)
                    ++hits;
            }
            mc_area = (double)hits / throws;

            fprintf(file, "%d,%g\n", throws, fabs(1 - 4 * mc_area));
        }
    }

    fclose(file);

    return 0;
}
