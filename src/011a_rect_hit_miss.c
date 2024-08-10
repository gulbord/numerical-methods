#include "../lib/mt19937ar.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define N_ARGS 4

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        printf("Wrong number of arguments! (Should be %d)\n", N_ARGS);
        printf("[executable] [n. of points to plot] [step] [replicas]\n");
        return 1;
    }

    // Alternative to time() seed:
    // unsigned long seed[4] = {0x123, 0x345, 0x789, 0x583};
    // init_by_array(seed, 4);
    init_genrand((unsigned long)time(NULL));

    int n, i, j;
    int n_plot = atoi(argv[1]); // Number of different max_iter to analyse
    int dn = atoi(argv[2]);     // Step in max_iter
    int rep = atoi(argv[3]);    // Replicas for each value of max_iter
    int hits, throws;
    double x, y, mc_area;
    FILE *file = fopen("out/011a.txt", "w");

    for (n = 0; n < n_plot; ++n) {
        throws = (1 + n) * dn;
        fprintf(file, "%d,", throws);
        
        for (i = 0; i < rep; ++i) {
            hits = 0; // Reset hit counter
            for (j = 0; j < throws; ++j) {
                x = genrand_real1();
                y = genrand_real1();
                if (x < 0.5 && y < 0.5)
                    ++hits;
            }
            mc_area = (double)hits / throws;

            fprintf(file, "%g%c", fabs(1 - 4 * mc_area),
                    i == rep - 1 ? '\n' : ',');
        }
    }

    fclose(file);

    return 0;
}
