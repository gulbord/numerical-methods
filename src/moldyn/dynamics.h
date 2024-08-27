#ifndef DYNAMICS_H
#define DYNAMICS_H

#include "parameters.h"

struct particle {
    double x[3];
    double v[3];
    double f[3];
};

void initialize(struct particle *particles, const struct parameters *params);
void equilibrate(struct particle *particles, const struct parameters *params,
                 double compute_energy_delta(int, const double *,
                                             const struct particle *,
                                             const struct parameters *),
                 void compute_forces(struct particle *,
                                     const struct parameters *));
void step(struct particle *particles, const struct parameters *params,
          void compute_forces(struct particle *, const struct parameters *));

#endif
