#include "offlat/integration.h"
#include "utils/progress.h"
#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 3
#define RCUT 3.0
#define RCUT2 9.0

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

        if (old_r2 > RCUT2 && new_r2 > RCUT2)
            continue;

        double old_energy, new_energy;
        if (old_r2 < RCUT2) {
            double old_inv_r6 = 1.0 / (old_r2 * old_r2 * old_r2);
            old_energy = old_inv_r6 * old_inv_r6 - old_inv_r6;
        } else
            old_energy = 0.0;

        if (new_r2 < RCUT2) {
            double new_inv_r6 = 1.0 / (new_r2 * new_r2 * new_r2);
            new_energy = new_inv_r6 * new_inv_r6 - new_inv_r6;
        } else
            new_energy = 0.0;

        delta += new_energy - old_energy;
    }

    return 4.0 * delta;
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

            if (r2 > RCUT2)
                continue;

            double inv_r6 = 1.0 / (r2 * r2 * r2);
            energy += inv_r6 * inv_r6 - inv_r6;
        }
    }

    return 4.0 * energy;
}

double compute_virial(const double *particles, const struct parameters *params)
{
    double virial = 0.0;

    for (int i = 0; i < 3 * params->num_particles - 3; i += 3) {
        for (int j = i + 3; j < 3 * params->num_particles; j += 3) {
            double r2 = 0.0;
            for (int k = 0; k < 3; ++k) {
                double dr = particles[i + k] - particles[j + k];
                dr -= params->box_size * round(dr / params->box_size);
                r2 += dr * dr;
            }

            if (r2 > RCUT2)
                continue;

            r2 = 1.0 / r2;
            double inv_r6 = r2 * r2 * r2;
            virial += 2.0 * inv_r6 * inv_r6 - inv_r6;
        }
    }

    return 8.0 * virial;
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
    snprintf(fname, sizeof(fname), "out/084_%s.csv", argv[2]);

    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }
    fprintf(file, "realization,energy,pressure,acc_ratio\n");

    double *particles = malloc(3 * params.num_particles * sizeof(*particles));
    struct observables obs;

    double inv_vol = 1.0 / pow(params.box_size, 3);
    double rho_temp = params.density * params.temperature; // Ideal gas pressure

    // Tail corrections for energy and pressure
    double utail = (8.0 * M_PI / 9.0) * params.num_particles * params.density *
                   (1.0 / pow(RCUT, 9) - 3.0 / pow(RCUT, 3));
    double ptail = (16.0 * M_PI / 9.0) * params.density * params.density *
                   (2.0 / pow(RCUT, 9) - 3.0 / pow(RCUT, 3));

    for (int r = 1; r <= params.num_realizations; ++r) {
        printf("\rRealization %d/%d\n", r, params.num_realizations);

        // Initialize particles according to config
        initialize(particles, &params);

        // Perform num_steps Monte Carlo sweeps
        obs.energy = compute_potential(particles, &params) + utail;
        for (int t = 1; t <= params.num_steps; ++t) {
            print_progress(t, params.num_steps);
            sweep(particles, &obs, &params, &compute_energy_delta);
            fprintf(file, "%d,%f,%f,%f\n", r, obs.energy,
                    ptail + rho_temp +
                        inv_vol * compute_virial(particles, &params),
                    obs.acc_ratio);
        }

        printf("\r\033[K\033[F"); // After progress bar
    }

    free(particles);
    fclose(file);

    return 0;
}
