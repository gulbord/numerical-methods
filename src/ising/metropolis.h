#ifndef METROPOLIS_H
#define METROPOLIS_H

#include "lattice.h"

void metropolis(struct lattice *lat, int n_steps, double beta,
                double *energy, double *magnet);

#endif
