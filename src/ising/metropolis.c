#include "metropolis.h"
#include "../../lib/mt19937ar.h"
#include <math.h>

static void comp_em(struct lattice *lat, int t, double *energy, double *magnet)
{
    int e = 0, m = 0;
    int k, nn_sum;
    int n_spins = lat->side * lat->side;
    for (int i = 0; i < n_spins; ++i) {
        // sum the up and right nearest neighbours
        k = 4 * i;
        nn_sum = lat->spins[lat->nbrs[k]] + lat->spins[lat->nbrs[k + 1]];
        e -= lat->spins[i] * nn_sum;
        m += lat->spins[i];
    }

    // divide by N = L^2 to get average per spin
    energy[t] = e / (double)n_spins;
    magnet[t] = m / (double)n_spins;
}

void evolve(struct lattice *lat, int n_steps, double beta,
            double *energy, double *magnet)
{
    // compute energy and magnetization at initialization
    comp_em(lat, 0, energy, magnet);

    int n_spins = lat->side * lat->side;
    int nn_sum, delta_e;
    double diff_e, diff_m; // to keep track of e and m between samplings
    int t, i, j;
    for (t = 1; t < n_steps; ++t) {
        diff_e = 0.0;
        diff_m = 0.0;
        // visit all spins sequentially
        for (i = 0; i < n_spins; ++i) {
            // compute the delta in energy from the spin flip
            nn_sum = 0;
            for (j = 4 * i; j < 4 * (i + 1); ++j)
                nn_sum += lat->spins[lat->nbrs[j]];
            delta_e = 2 * lat->spins[i] * nn_sum;
            
            // metropolis acceptance condition
            if (delta_e < 0 || genrand_real1() < exp(-beta * delta_e)) {
                lat->spins[i] *= -1;
                diff_e += (double)delta_e / n_spins;
                diff_m += 2.0 * lat->spins[i] / n_spins;
            }
        }

        energy[t] = energy[t - 1] + diff_e;
        magnet[t] = magnet[t - 1] + diff_m;
    }
}
