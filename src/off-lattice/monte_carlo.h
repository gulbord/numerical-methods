#ifndef MONTE_CARLO_H
#define MONTE_CARLO_H

#include "parameters.h"

// Perform N (number of particles) Monte Carlo moves and return the final energy
double monte_carlo_sweep(double *particles, const struct parameters *params);

#endif
