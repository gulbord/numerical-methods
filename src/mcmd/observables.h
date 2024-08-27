#ifndef OBSERVABLES_H
#define OBSERVABLES_H

#include "dynamics.h"

struct observables {
    double kin_energy;
    double pot_energy;
    double *rdf;
};

void alloc_obs(struct observables *obs, const struct parameters *params);
void update_obs(struct observables *obs, const struct particle *particles,
                const struct parameters *params,
                const double *compute_potential_r2(double,
                                                   const struct particle *,
                                                   const struct parameters *));
void free_obs(struct observables *obs);

#endif
