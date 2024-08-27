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

    int n_plot = atoi(argv[1]); // Number of different max_iter to analyse
    int dn = atoi(argv[2]);     // Step in max_iter
    int rep = atoi(argv[3]);    // Replicas for each value of max_iter

    for (int n = 0; n < n_plot; ++n) {
        int throws = (1 + n) * dn;

        for (int i = 0; i < rep; ++i) {
            int hits = 0; // Reset hit counter
            for (int j = 0; j < throws; ++j) {
                double x = rng_real();
                double y = rng_real();
                if (x < 0.5 && y < 0.5)
                    ++hits;
            }
            double mc_area = (double)hits / throws;

            fprintf(file, "%d,%g\n", throws, fabs(1.0 - 4.0 * mc_area));
        }
    }

    fclose(file);

    return 0;
}
