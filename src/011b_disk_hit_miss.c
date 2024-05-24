#include "../lib/mt19937ar.h"
#include <math.h>
#include <stdio.h>
#include <time.h>

#define N_ARGS 3

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        printf("Wrong number of arguments! (Should be %d)\n", N_ARGS);
        return 1;
    }

    // Alternative to time() seed:
    // unsigned long seed[4] = {0x123, 0x345, 0x789, 0x583};
    // init_by_array(seed, 4);
    init_genrand((unsigned long)time(NULL));

    int n;
    int n_plot = atoi(argv[1]); // Number of different max_iter to analyse
    int dn = atoi(argv[2]);
    int hits, throws;
    double x, y;
    double mc_pi;
    FILE *file = fopen("out/011b.txt", "w");

    for (n = 0; n < n_plot; ++n) {
        hits = 0; // Reset hit counter
        throws = (1 + n) * dn;
        for (i = 0; i < throws; ++i) {
            x = genrand_real1();
            y = genrand_real1();
            if (x * x + y * y < 1)
                ++hits;
        }
        mc_pi = 4 * (double)hits / throws;

        // Write to file: throws + \t + relative error + \n
        fprintf(file, "%d\t", throws);
        fprintf(file, "%g\n", fabs(1 - mc_pi * M_1_PI));
    }

    fclose(file);

    return 0;
}
