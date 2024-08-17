#include "monte_carlo.h"
#include "../../lib/mt19937ar.h"
#include "particles.h"
#include <math.h>

#define GENRAND_MAX 0xffffffff

double monte_carlo_sweep(double *particles, const struct parameters *params)
{
    if (params->num_particles < 2)
        return 0.0;

    int i, j, pick;
    double old_position[3];
    double disp, old_energy, new_energy, delta;

    for (i = 0; i < params->num_particles; ++i) {
        old_energy = calc_energy(particles, params);

        // Displace a particle picked at random
        pick = genrand_int32() / (GENRAND_MAX / params->num_particles + 1);
        for (j = 0; j < 3; ++j) {
            disp = (2.0 * genrand_real1() - 1.0) * params->disp_max;
            // Periodic boundary conditions
            disp -= params->box_size * floor(disp / params->box_size);
            old_position[j] = particles[pick + j];
            particles[pick + j] += disp;
        }

        new_energy = calc_energy(particles, params);
        delta = new_energy - old_energy;

        if (delta > 0 && genrand_real1() < exp(-delta / params->temperature)) {
            for (j = 0; j < 3; ++j)
                particles[pick + j] = old_position[j];
            // If the sweep is finished, restore also the energy to return it
            if (i == params->num_particles - 1)
                new_energy = old_energy;
        }
    }

    return new_energy;
}
