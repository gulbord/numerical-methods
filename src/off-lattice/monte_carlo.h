#ifndef MONTE_CARLO_H
#define MONTE_CARLO_H

#include "parameters.h"

typedef double (*energy_ptr)(double *, const struct parameters *);

// Perform N (number of particles) Monte Carlo moves and return the final energy
double monte_carlo_sweep(double *particles, const struct parameters *params,
                         energy_ptr energy);

#endif
