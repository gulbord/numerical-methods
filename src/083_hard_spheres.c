#include "offlat/integration.h"
#include "utils/progress.h"
#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 3
#define EPS 1e6

double compute_energy_delta(int pick, const double *trial,
                            const double *particles,
                            const struct parameters *params)
{
    double delta = 0.0;

    for (int i = 0; i < 3 * params->num_particles; i += 3) {
        if (i == pick)
            continue;

        double old_r2 = 0.0;
        double new_r2 = 0.0;
        for (int j = 0; j < 3; ++j) {
            double old_dr = particles[pick + j] - particles[i + j];
            old_dr -= params->box_size * round(old_dr / params->box_size);
            old_r2 += old_dr * old_dr;

            double new_dr = trial[j] - particles[i + j];
            new_dr -= params->box_size * round(new_dr / params->box_size);
            new_r2 += new_dr * new_dr;
        }

        if (old_r2 > 1.0 && new_r2 < 1.0)
            delta += EPS;
        else if (old_r2 < 1.0 && new_r2 > 1.0)
            delta -= EPS;
    }

    return delta;
}

double compute_potential(const double *particles,
                         const struct parameters *params)
{
    double energy = 0.0;

    for (int i = 0; i < 3 * params->num_particles - 3; i += 3) {
        for (int j = i + 3; j < 3 * params->num_particles; j += 3) {
            double r2 = 0.0;
            for (int k = 0; k < 3; ++k) {
                double dr = particles[i + k] - particles[j + k];
                dr -= params->box_size * round(dr / params->box_size);
                r2 += dr * dr;
            }

            if (r2 < 1.0)
                energy += EPS;
        }
    }

    return energy;
}

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr,
                "[executable] [configuration file] [output file prefix]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    struct parameters params;
    if (parse_config(argv[1], &params))
        return 1;

    char fname[255];
    snprintf(fname, sizeof(fname), "out/083_%s.csv", argv[2]);

    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }
    fprintf(file, "realization,acc_ratio,energy\n");

    double *particles = malloc(3 * params.num_particles * sizeof(*particles));
    struct observables obs;

    for (int r = 1; r <= params.num_realizations; ++r) {
        printf("\rRealization %d/%d\n", r, params.num_realizations);

        // Initialize particles according to config
        initialize(particles, &params);

        // Perform mc_steps Monte Carlo sweeps
        obs.energy = compute_potential(particles, &params);
        for (int t = 1; t <= params.num_steps; ++t) {
            print_progress(t, params.num_steps);
            sweep(particles, &obs, &params, &compute_energy_delta);
            fprintf(file, "%d,%f,%f\n", r, obs.acc_ratio, obs.energy);
        }

        printf("\r\033[K\033[F"); // After progress bar
    }

    free(particles);
    fclose(file);

    return 0;
}
