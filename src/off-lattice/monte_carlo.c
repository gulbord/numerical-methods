#include "monte_carlo.h"
#include "../utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void init_particles(double **particles, const struct parameters *params)
{
    *particles = malloc(3 * params->num_particles * sizeof(**particles));

    if (strcmp(params->init_type, "random") == 0) {
        for (int i = 0; i < 3 * params->num_particles; ++i)
            (*particles)[i] = rng_real() * params->box_size;
    } else
        fprintf(stderr, "Unknown initialization string: %s\n",
                params->init_type);
}

double monte_carlo_sweep(double *particles, const struct parameters *params,
                         const energy_delta_ptr energy_delta)
{
    int i, j, pick;
    double trial[3];
    double delta, energy = 0.0;
    for (i = 0; i < params->num_particles; ++i) {
        // Displace a particle picked at random
        pick = 3 * rng_int_n(params->num_particles);
        for (j = 0; j < 3; ++j) {
            trial[j] = particles[pick + j];
            trial[j] += (2 * rng_real() - 1) * params->disp_max;
            // Periodic boundary conditions
            trial[j] -= params->box_size * floor(trial[j] / params->box_size);
        }

        delta = energy_delta(pick, trial, particles, params);

        if (delta < 0 || rng_real() > exp(-delta / params->temperature)) {
            energy += delta;
            for (j = 0; j < 3; ++j)
                particles[pick + j] = trial[j];
        }
    }

    return energy;
}
