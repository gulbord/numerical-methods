#include "off-lattice/monte_carlo.h"
#include "utils/progress.h"
#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2

double energy_delta(int pick, const double *trial, const double *particles,
                    const struct parameters *params)
{
    int i, j;
    double old_dr, new_dr, old_r2, new_r2, delta = 0.0;
    for (i = 0; i < 3 * params->num_particles; i += 3) {
        if (i == pick)
            continue;

        old_r2 = 0.0, new_r2 = 0.0;
        for (j = 0; j < 3; ++j) {
            old_dr = particles[pick + j] - particles[i + j];
            old_dr -= params->box_size * round(old_dr / params->box_size);
            old_r2 += old_dr * old_dr;

            new_dr = trial[j] - particles[i + j];
            new_dr -= params->box_size * round(new_dr / params->box_size);
            new_r2 += new_dr * new_dr;
        }

        delta += 1.0 / new_r2 - 1.0 / old_r2;
    }

    return delta;
}

double energy_total(const double *particles, const struct parameters *params)
{
    int i, j, k;
    double dr, r2, energy = 0.0;
    for (i = 0; i < 3 * params->num_particles - 3; i += 3) {
        for (j = i + 3; j < 3 * params->num_particles; j += 3) {
            r2 = 0.0;
            for (k = 0; k < 3; ++k) {
                dr = particles[i + k] - particles[j + k];
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

    // Initialize the particle array
    double *particles;
    init_particles(&particles, &params);

    // Perform mc_steps Monte Carlo sweeps
    double energy = energy_total(particles, &params);
    fprintf(file, "%g\n", energy);
    for (int i = 0; i < params.mc_steps; ++i) {
        print_progress((double)(i + 1) / params.mc_steps);
        energy += monte_carlo_sweep(particles, &params, &energy_delta);
        fprintf(file, "%g\n", energy);
    }

    printf("\n"); // After progress bar

    fclose(file);
    free(particles);

    return 0;
}
