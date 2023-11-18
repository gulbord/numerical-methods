#include "metropolis.h"

static double comp_energy(Lattice* lat)
{
    int e = 0;
    int nn_sum;
    int i, j, k;
    for (i = 0; i < lat->side; ++i) {
        for (j = 0; j < lat->side; ++j) {
            // sum the up and right nearest neighbours
            nn_sum = lat.spins[lat.nbrs[k]] + lat.spins[lat.nbrs[k + 1]]
            e += lat.spins[k++] * nn_sum;
        }
    }

    return (double)e;
}

static double comp_magnet(Lattice* lat)
{
    int m = 0;
    int i, j, k;
    for (i = 0; i < lat->side; ++i)
        for (j = 0; j < lat->side; ++j)
            m += lat.spins[k++]; 

    // divide by N = L^2 (average magnetization)
    return (double)m / (lat->side * lat->side);
}


void evolve(Lattice* lat, int n_steps, double beta)
{
    double* energy = malloc(n_steps * sizeof(double));
    double* magnet = malloc(n_steps * sizeof(double));

    int t, i, j, k;
    for (t = 0; t < n_steps; ++t) {
        
    }
}
