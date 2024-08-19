#include "utils/random.h"
#include "off-lattice/monte_carlo.h"
#include "utils/progress.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2

double energy(double *particles, const struct parameters *params)
{
    int i, j, k;
    double dr, r2, energy = 0.0;
    for (i = 0; i < params->num_particles - 1; ++i) {
        for (j = i + 1; j < params->num_particles; ++j) {
            r2 = 0.0;
            for (k = 0; k < 3; ++k) {
                dr = particles[3 * i + k] - particles[3 * j + k];
                // Periodic boundary conditions
                dr -= params->box_size * round(dr / params->box_size);
                r2 += dr * dr;
            }
            energy += 1.0 / r2;
        }
    }

    return energy;
}

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [configuration file]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    struct parameters params;
    if (parse_config(argv[1], &params))
        return 1;

    char fname[255];
    snprintf(fname, sizeof(fname), "out/082_N%d_L%g_d%g_T%g_s%d.csv",
             params.num_particles, params.box_size, params.disp_max,
             params.temperature, params.mc_steps);
    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }

    // Initialize the particle array with random positions
    double *particles = malloc(3 * params.num_particles * sizeof(*particles));
    for (int i = 0; i < 3 * params.num_particles; ++i)
        particles[i] = rng_real() * params.box_size;

    // Perform mc_steps Monte Carlo sweeps
    for (int i = 0; i < params.mc_steps; ++i) {
        print_progress((double)(i + 1) / params.mc_steps);
        fprintf(file, "%g\n", monte_carlo_sweep(particles, &params, &energy));
    }

    printf("\n"); // After progress bar

    fclose(file);
    free(particles);

    return 0;
}
