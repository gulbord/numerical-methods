#include "metropolis.h"
#include "../../lib/mt19937ar.h"
#include <math.h>

static void comp_em(struct lattice *lat, int t, double *energy, double *magnet)
{
    int e = 0, m = 0;
    int nn_sum;
    int i, j, n, k = 0;
    for (i = 0; i < lat->side; ++i) {
        for (j = 0; j < lat->side; ++j) {
            // sum the up and right nearest neighbours
            n = 4 * k;
            nn_sum = lat->spins[lat->nbrs[n]] + lat->spins[lat->nbrs[n + 1]];
            e -= lat->spins[k] * nn_sum;
            m += lat->spins[k];
            ++k;
        }
    }

    // divide by N = L^2 to get average per spin
    double n_spins = lat->side * lat->side;
    energy[t] = e / n_spins;
    magnet[t] = m / n_spins;
}

void evolve(struct lattice *lat, int n_steps, double beta,
            double *energy, double *magnet)
{
    // compute energy and magnetization at initialization
    comp_em(lat, 0, energy, magnet);

    int n_spins = lat->side * lat->side;
    int nn_sum, delta_e;
    double diff_e, diff_m; // to keep track of e and m between samplings
    int t, i, j, k, n;
    for (t = 1; t < n_steps; ++t) {
        n = 0;
        diff_e = 0.0;
        diff_m = 0.0;
        // visit all spins sequentially
        for (i = 0; i < lat->side; ++i) {
            for (j = 0; j < lat->side; ++j) {
                // compute the delta in energy from the spin flip
                nn_sum = 0;
                for (k = 0; k < 4; ++k)
                    nn_sum += lat->spins[lat->nbrs[4 * n + k]];
                delta_e = 2 * lat->spins[n] * nn_sum;

                // metropolis acceptance condition
                if (delta_e < 0 || genrand_real1() < exp(-beta * delta_e)) {
                    lat->spins[n] *= -1;
                    diff_e += (double)delta_e / n_spins;
                    diff_m += 2.0 * lat->spins[n] / n_spins;
                }

                // update counter and move to the next spin
                ++n;
            }
        }

        energy[t] = energy[t - 1] + diff_e;
        magnet[t] = magnet[t - 1] + diff_m;
    }
}
