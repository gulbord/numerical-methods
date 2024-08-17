#include "../../lib/mt19937ar.h"
#include "particles.h"
#include <math.h>

void init_particles(double *particles, const struct parameters *params)
{
    for (int i = 0; i < 3 * params->num_particles; ++i)
        particles[i] = genrand_real1() * params->box_size;
}

double calc_energy(double *particles, const struct parameters *params)
{
    int i, j, k;
    double dr, r2, energy = 0.0;
    for (i = 0; i < params->num_particles - 1; ++i) {
        for (j = i + 1; j < params->num_particles; ++j) {
            r2 = 0.0;
            for (k = 0; k < 3; ++k) {
                dr = particles[3 * i + k] - particles[3 * j + k];
                // Periodic boundary conditions
                dr -= params->box_size * floor(dr / params->box_size);
                r2 += dr * dr;
            }
            energy += 1.0 / sqrt(r2);
        }
    }

    return energy;
}
