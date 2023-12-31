#ifndef WOLFF_H
#define WOLFF_H

#include "lattice.h"

void wolff(struct lattice *lat, int n_flips, double beta,
           double *energy, double *magnet, int *clus_sz);

#endif
