#include "lib/mt19937ar.h"
#include "metropolis.h"
#include <math.h>

static double comp_energy(Lattice* lat)
{
    int e = 0;
    int nn_sum;
    int i, j, n, k = 0;
    for (i = 0; i < lat->side; ++i) {
        for (j = 0; j < lat->side; ++j) {
            // sum the up and right nearest neighbours
            n = 4 * k;
            nn_sum = lat->spins[lat->nbrs[n]] + lat->spins[lat->nbrs[n + 1]];
            e += lat->spins[k++] * nn_sum;
        }
    }

    // divide by N = L^2 to get average per spin
    return -(double)e / (lat->side * lat->side);
}

static double comp_magnet(Lattice* lat)
{
    int m = 0;
    int i, j, k = 0;
    for (i = 0; i < lat->side; ++i) {
        for (j = 0; j < lat->side; ++j) {
            m += lat->spins[k++];
        }
    }

    // divide by N = L^2 to get average per spin
    return (double)m / (lat->side * lat->side);
}

void evolve(Lattice* lat, int n_steps, double beta,
            double* energy, double* magnet)
{
    // compute energy and magnetization at initialization
    energy[0] = comp_energy(lat);
    magnet[0] = comp_magnet(lat);

    int n_spins = lat->side * lat->side;
    int pick, nn_sum, delta_e;
    int t, i;
    for (t = 1; t < n_steps; ++t) {
        // pick a spin at random
        pick = (int)(genrand_real2() * n_spins);

        // compute the delta in energy from the spin flip
        nn_sum = 0;
        for (i = 0; i < 4; ++i)
            nn_sum += lat->spins[lat->nbrs[4 * pick + i]];
        delta_e = 2 * lat->spins[pick] * nn_sum;

        // metropolis acceptance condition
        if (delta_e < 0 || genrand_real1() < exp(-beta * delta_e)) {
            lat->spins[pick] = -lat->spins[pick]; // flip spin
            energy[t] = energy[t - 1] + (double)delta_e / n_spins;
            magnet[t] = magnet[t - 1] + 2.0 * lat->spins[pick] / n_spins;
        } else {
            energy[t] = energy[t - 1];
            magnet[t] = magnet[t - 1];
        }
    }
}
