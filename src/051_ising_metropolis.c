#include "utils/progress.h"
#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 5

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [output file prefix] \\\n");
        fprintf(stderr, "  [lattice side] [temperature] [# of steps]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    char fname[100];
    snprintf(fname, sizeof(fname), "out/051_%s.csv", argv[1]);

    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }

    fprintf(file, "energy,magnet\n");

    int side = atoi(argv[2]);
    double temperature = atof(argv[3]);
    int num_steps = atoi(argv[4]);

    int num_spins = side * side;
    int *spins = malloc(num_spins * sizeof(*spins));
    // Array to hold the indices of nearest neighbours
    int(*nn)[4] = malloc(num_spins * sizeof(*nn));

    // Initialize with random spins, find nearest neighbours and compute initial
    // energy and magnetization
    int energy = 0;
    int magnet = 0;
    int k = 0;
    for (int i = 0; i < side; ++i) {
        for (int j = 0; j < side; ++j) {
            spins[k] = rng_int_n(2) * 2 - 1;

            nn[k][0] = i == side - 1 ? k + side - num_spins : k + side; // Up
            nn[k][1] = j == side - 1 ? k + 1 - side : k + 1;            // Right
            nn[k][2] = i == 0 ? k - side + num_spins : k - side;        // Down
            nn[k][3] = j == 0 ? k - 1 + side : k - 1;                   // Left

            energy -= spins[k] * (spins[nn[k][0]] + spins[nn[k][1]]);
            magnet += spins[k];

            ++k;
        }
    }

    // Start the main loop
    for (int t = 1; t <= num_steps; ++t) {
        print_progress(t, num_steps);

        // Visit all spins sequentially
        for (int i = 0; i < num_spins; ++i) {
            int nn_sum = 0;
            for (int j = 0; j < 4; ++j)
                nn_sum += spins[nn[i][j]];
            int delta = 2 * spins[i] * nn_sum;

            // Metropolis acceptance condition
            if (delta < 0 || rng_real() < exp(-(double)delta / temperature)) {
                spins[i] = -spins[i];
                energy += delta;
                magnet += 2 * spins[i];
            }
        }

        fprintf(file, "%d,%d\n", energy, magnet);
    }

    printf("\n"); // After progress bar

    fclose(file);
    free(spins);
    free(nn);

    return 0;
}
