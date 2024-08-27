#ifndef DYNAMICS_H
#define DYNAMICS_H

#include "parameters.h"

typedef double (*energy_delta_ptr)(int, const double *, const double *,
                                   const struct parameters *);

struct observables {
    double acc_ratio;
    double energy;
};

void initialize(double *particles, const struct parameters *params);
// Perform N (number of particles) Monte Carlo moves and return the difference
// between the final and initial total energy
void sweep(double *particles, struct observables *obs,
           const struct parameters *params,
           const energy_delta_ptr energy_delta);

#endif
