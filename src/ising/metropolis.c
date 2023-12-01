#include "metropolis.h"
#include "../../lib/mt19937ar.h"
#include <math.h>

void metropolis(struct lattice *lat, int n_steps, double beta,
                double *energy, double *magnet)
{
    int n_spins = lat->side * lat->side;
    int e = 0, m = 0;
    int t, i, j, nn_sum;

    // compute energy and magnetization at initialization
    for (i = 0; i < n_spins; ++i) {
        // sum the up and right nearest neighbours
        j = 4 * i;
        nn_sum = lat->spins[lat->nbrs[j]] + lat->spins[lat->nbrs[j + 1]];
        e -= lat->spins[i] * nn_sum;
        m += lat->spins[i];
    }

    // divide by N = L^2 to get average per spin
    energy[0] = (double)e / n_spins;
    magnet[0] = (double)m / n_spins;

    double delta_e;        // for the metropolis test
    double diff_e, diff_m; // to keep track of e and m between samplings
    for (t = 1; t < n_steps; ++t) {
        diff_e = 0.0;
        diff_m = 0.0;
        // visit all spins sequentially
        for (i = 0; i < n_spins; ++i) {
            // compute the delta in energy from the spin flip
            nn_sum = 0;
            for (j = 4 * i; j < 4 * (i + 1); ++j)
                nn_sum += lat->spins[lat->nbrs[j]];
            delta_e = 2.0 * lat->spins[i] * nn_sum;
            
            // metropolis acceptance condition
            if (delta_e < 0 || genrand_real1() < exp(-beta * delta_e)) {
                lat->spins[i] *= -1;
                diff_e += delta_e;
                diff_m += 2.0 * lat->spins[i];
            }
        }

        energy[t] = energy[t - 1] + diff_e / n_spins;
        magnet[t] = magnet[t - 1] + diff_m / n_spins;
    }
}
