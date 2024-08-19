#include "monte_carlo.h"
#include "../utils/random.h"
#include <math.h>

double monte_carlo_sweep(double *particles, const struct parameters *params,
                         energy_delta_ptr energy_delta)
{
    int i, j, pick;
    double old_position[3];
    double delta, energy = 0.0;
    for (i = 0; i < params->num_particles; ++i) {
        // Displace a particle picked at random
        pick = 3 * rng_int_n(params->num_particles);
        for (j = 0; j < 3; ++j) {
            old_position[j] = particles[pick + j];
            particles[pick + j] += (2 * rng_real() - 1) * params->disp_max;
            // Periodic boundary conditions
            particles[pick + j]
                -= params->box_size
                   * floor(particles[pick + j] / params->box_size);
        }

        delta = energy_delta(pick, old_position, particles, params);

        if (delta > 0 && rng_real() < exp(-delta / params->temperature)) {
            for (j = 0; j < 3; ++j)
                particles[pick + j] = old_position[j];
        } else
            energy += delta;
    }

    return energy;
}
