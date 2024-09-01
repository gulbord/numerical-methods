#include "integration.h"
#include "../utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void initialize(double *particles, const struct parameters *params)
{
    if (strcmp(params->init_conf, "random") == 0) {
        for (int i = 0; i < 3 * params->num_particles; ++i)
            particles[i] = rng_real() * params->box_size;
    } else if (strcmp(params->init_conf, "lattice") == 0) {
        // Number of particles in each direction
        int n = ceil(cbrt(params->num_particles));
        int spacing = params->box_size / n;
        int assigned = 0;
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                for (int k = 0; k < n; ++k) {
                    if (assigned < params->num_particles) {
                        particles[3 * assigned] = (i + 0.5) * spacing;
                        particles[3 * assigned + 1] = (j + 0.5) * spacing;
                        particles[3 * assigned + 2] = (k + 0.5) * spacing;
                        ++assigned;
                    } else
                        break;
                }
            }
        }
    } else
        fprintf(stderr, "Unknown initialization string: %s\n",
                params->init_conf);
}

void sweep(double *particles, struct observables *obs,
           const struct parameters *params,
           double compute_energy_delta(int, const double *, const double *,
                                       const struct parameters *))
{
    int accepted = 0;
    double trial[3];
    for (int i = 0; i < params->num_particles; ++i) {
        // Displace a particle picked at random
        int pick = 3 * rng_int_n(params->num_particles);
        for (int j = 0; j < 3; ++j) {
            trial[j] = particles[pick + j];
            trial[j] += (2.0 * rng_real() - 1.0) * params->max_disp;
            // Periodic boundary conditions
            trial[j] -= params->box_size * floor(trial[j] / params->box_size);
        }

        double delta = compute_energy_delta(pick, trial, particles, params);

        if (delta < 0.0 || rng_real() < exp(-delta / params->temperature)) {
            ++accepted;
            obs->energy += delta;
            for (int j = 0; j < 3; ++j)
                particles[pick + j] = trial[j];
        }
    }

    obs->acc_ratio = (double)accepted / params->num_particles;
}
