#include "monte_carlo.h"
#include "../utils/random.h"
#include "particles.h"
#include <math.h>

double monte_carlo_sweep(double *particles, const struct parameters *params)
{
    int i, j, pick;
    double old_position[3];
    double old_energy, new_energy, delta;
    for (i = 0; i < params->num_particles; ++i) {
        old_energy = calc_energy(particles, params);

        // Displace a particle picked at random
        pick = 3 * rng_int_n(params->num_particles);
        for (j = 0; j < 3; ++j) {
            old_position[j] = particles[pick + j];
            particles[pick + j]
                += (2.0 * rng_uniform_01() - 1.0) * params->disp_max;
            // Periodic boundary conditions
            particles[pick + j]
                -= params->box_size
                   * floor(particles[pick + j] / params->box_size);
        }

        new_energy = calc_energy(particles, params);
        delta = new_energy - old_energy;

        if (delta > 0 && rng_uniform_01() < exp(-delta / params->temperature)) {
            for (j = 0; j < 3; ++j)
                particles[pick + j] = old_position[j];
            new_energy = old_energy;
        }
    }

    return new_energy;
}
