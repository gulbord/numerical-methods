#ifndef OBSERVABLES_H
#define OBSERVABLES_H

#include "integration.h"

struct observables {
    double temperature;
    double kin_energy;
    double pot_energy;
    double *rdf;
};

void update_obs(struct observables *obs, const struct particle *particles,
                const struct parameters *params,
                double compute_potential_r2(double, const struct parameters *));

#endif
