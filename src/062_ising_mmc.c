#include "utils/progress.h"
#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 8

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [output file prefix] [lattice side]\\\n");
        fprintf(stderr, "  [min. temp.] [max. temp.] [# of chains] \\\n");
        fprintf(stderr, "  [# of steps between swaps] [# of steps]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    char fname[100];
    snprintf(fname, sizeof(fname), "out/062_%s.csv", argv[1]);

    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }

    int side = atoi(argv[2]);
    double min_temp = atof(argv[3]);
    double max_temp = atof(argv[4]);
    int num_chains = atoi(argv[5]);
    if (num_chains < 2) {
        fprintf(stderr, "Put at least two chains!\n");
        return 1;
    }
    int swap_step = atoi(argv[6]);
    int num_steps = atoi(argv[7]);

    // Construct the array of inverse temperatures
    double temp_step = (max_temp - min_temp) / (num_chains - 1);
    double *betas = malloc(num_chains * sizeof(*betas));
    // Array holding the index of the corresponding configuration
    int *which_conf = malloc(num_chains * sizeof(*which_conf));
    for (int c = 0; c < num_chains; ++c) {
        betas[c] = 1.0 / (min_temp + c * temp_step);
        which_conf[c] = c;
    }

    // Prepare the output file header
    for (int c = 1; c <= num_chains; ++c)
        fprintf(file, "energy.%d,magnet.%d,", c, c);
    fprintf(file, "swap.a,swap.b\n");

    int num_spins = side * side;
    int(*spins)[num_spins] = malloc(num_chains * sizeof(*spins));
    // Array to hold the indices of nearest neighbours
    int(*nn)[4] = malloc(num_spins * sizeof(*nn));
    for (int i = 0; i < side; ++i) {
        for (int j = 0; j < side; ++j) {
            int k = i * side + j;
            nn[k][0] = i == side - 1 ? k + side - num_spins : k + side; // Up
            nn[k][1] = j == side - 1 ? k + 1 - side : k + 1;            // Right
            nn[k][2] = i == 0 ? k - side + num_spins : k - side;        // Down
            nn[k][3] = j == 0 ? k - 1 + side : k - 1;                   // Left
        }
    }

    // Initialize with random spins, find nearest neighbours and compute initial
    // energies and magnetizations
    int *energies = calloc(num_chains, sizeof(*energies));
    int *magnets = calloc(num_chains, sizeof(*magnets));
    for (int c = 0; c < num_chains; ++c) {
        for (int i = 0; i < side; ++i) {
            for (int j = 0; j < side; ++j) {
                int k = i * side + j;
                int s = rng_int_n(2) * 2 - 1;
                spins[c][k] = s;
                energies[c] -= s * (spins[c][nn[k][0]] + spins[c][nn[k][1]]);
                magnets[c] += s;
            }
        }
    }

    // Start the main loop
    for (int t = 1; t <= num_steps; ++t) {
        print_progress(t, num_steps);

        // Visit all chains and spins sequentially
        for (int c = 0; c < num_chains; ++c) {
            int k = which_conf[c];
            for (int i = 0; i < num_spins; ++i) {
                int s = spins[k][i];

                int nn_sum = 0;
                for (int j = 0; j < 4; ++j)
                    nn_sum += spins[k][nn[i][j]];
                int delta = 2 * s * nn_sum;

                // Metropolis acceptance condition
                if (delta < 0 || rng_real() < exp(-betas[c] * delta)) {
                    spins[k][i] = -s;
                    energies[k] += delta;
                    magnets[k] -= 2 * s;
                }
            }

            fprintf(file, "%d,%d,", energies[k], magnets[k]);
        }

        if (t % swap_step != 0) {
            // No swap, so swap.a/swap.b are meaningless
            fprintf(file, "NA,NA\n");
            continue;
        }

        // Sample two adjacent configurations to swap
        int c1 = rng_int_n(num_chains);
        int c2;
        if (c1 == 0)
            c2 = 1;
        else if (c1 == num_chains - 1)
            c2 = num_chains - 2;
        else
            c2 = rng_real() < 0.5 ? c1 - 1 : c1 + 1;

        int k1 = which_conf[c1];
        int k2 = which_conf[c2];
        double logp = (betas[c2] - betas[c1]) * (energies[k2] - energies[k1]);
        if (logp > 0 || rng_real() < exp(logp)) {
            // Swap the 'pointers' which_conf
            int tmp = which_conf[c1];
            which_conf[c1] = which_conf[c2];
            which_conf[c2] = tmp;

            // Save the swapped chains
            fprintf(file, "%d,%d\n", c1, c2);
        } else
            fprintf(file, "-1,-1\n"); // No swap
    }

    printf("\n"); // After progress bar

    fclose(file);
    free(betas);
    free(which_conf);
    free(spins);
    free(nn);
    free(energies);
    free(magnets);

    return 0;
}
