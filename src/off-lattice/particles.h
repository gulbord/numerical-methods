#ifndef PARTICLES_H
#define PARTICLES_H

#include "parameters.h"

void init_particles(double *particles, const struct parameters *params);
double calc_energy(double *particles, const struct parameters *params);

#endif
