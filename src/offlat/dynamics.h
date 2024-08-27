#ifndef DYNAMICS_H
#define DYNAMICS_H

#include "parameters.h"

struct observables {
    double acc_ratio;
    double energy;
};

void initialize(double *particles, const struct parameters *params);
// Perform N (number of particles) Monte Carlo moves and return the difference
// between the final and initial total energy
void sweep(double *particles, struct observables *obs,
           const struct parameters *params,
           double compute_energy_delta(int, const double *, const double *,
                                       const struct parameters *));

#endif
