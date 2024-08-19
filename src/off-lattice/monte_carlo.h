#ifndef MONTE_CARLO_H
#define MONTE_CARLO_H

#include "parameters.h"

typedef double (*energy_delta_ptr)(int, const double *, const double *,
                                   const struct parameters *);

// Perform N (number of particles) Monte Carlo moves and return the difference
// between the final and initial total energy
double monte_carlo_sweep(double *particles, const struct parameters *params,
                         const energy_delta_ptr energy_delta);

#endif
