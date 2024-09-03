#include "utils/progress.h"
#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
    snprintf(fname, sizeof(fname), "out/061_%s.csv", argv[1]);

    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }

    fprintf(file, "energy,magnet,clus_size\n");

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

    double p_add = 1.0 - exp(-2.0 / temperature);
    // Save unvisited spins in a queue
    int *unvisited = malloc(num_spins * sizeof(*unvisited));
    // Array of bools for cluster membership
    int *is_cluster = malloc(num_spins * sizeof(*is_cluster));

    // Start the main loop
    for (int t = 1; t <= num_steps; ++t) {
        print_progress(t, num_steps);

        memset(is_cluster, 0, num_spins * sizeof(int));

        // Pick a starting spin at random and flip it
        int seed = rng_int_n(num_spins);
        is_cluster[seed] = 1;
        int s0 = spins[seed];
        spins[seed] = -s0;

        int front = 0;
        int rear = 0;
        unvisited[rear++] = seed;

        int cluster_size = 1;
        while (front != rear) {
            // Get an unvisited site from the front of the queue
            int pick = unvisited[front++];
            for (int i = 0; i < 4; ++i) {
                int nbr = nn[pick][i];
                // Flip if nbr has the right sign, with probability p_add
                if (spins[nbr] == s0 && rng_real() < p_add) {
                    is_cluster[nbr] = 1;
                    spins[nbr] = -s0;
                    // Enqueue the site to check it later
                    unvisited[rear++] = nbr;
                    ++cluster_size;
                }
            }
        }

        // Check if we are flipping the whole cluster
        if (cluster_size == num_spins) {
            magnet = -magnet; // While the energy stays the same
            fprintf(file, "%d,%d,%d\n", energy, magnet, cluster_size);
            continue;
        }

        // Compute the energy difference
        int delta = 0;
        front = 0;
        rear = 0;
        unvisited[rear++] = seed;
        is_cluster[seed] = 2;
        while (front != rear) {
            // Get an unvisited cluster site from the front
            int pick = unvisited[front++];
            for (int i = 0; i < 4; ++i) {
                int nbr = nn[pick][i];

                // With s0 = - (i.e. the cluster is + after flipping)
                // c | b       c | b    [c = cluster, b = border]
                // - | -  -->  + | -    then delta > 0
                // - | +  -->  + | +    then delta < 0
                switch (is_cluster[nbr]) {
                case 0: // Border spin
                    delta += s0 * spins[nbr];
                    break;
                case 1: // Cluster spin
                    is_cluster[nbr] = 2;
                    unvisited[rear++] = nbr;
                    break;
                default: // Cluster spin, but already visited
                    break;
                }
            }
        }

        energy += 2 * delta;
        magnet -= 2 * s0 * cluster_size;
        fprintf(file, "%d,%d,%d\n", energy, magnet, cluster_size);
    }

    printf("\n"); // After progress bar

    fclose(file);
    free(spins);
    free(nn);

    return 0;
}
