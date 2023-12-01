#include "wolff.h"
#include "../../lib/mt19937ar.h"
#include <math.h>

void evolve(struct lattice *lat, int n_flips, double beta,
            double *energy, double *magnet, int *clus_sz)
{
    int n_spins = lat->side * lat->side;
    int e = 0, m = 0;
    int i, j, nn_sum;

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

    double p_add = 1 - exp(-2 * beta);
    int t, s, b, cs, front, rear, nbr;

    for (t = 1; t < n_flips; ++t) {
        // pick a starting spin at random
        i = (int)(genrand_real1() * n_spins);
        // flip the seed spin
        s = lat->spins[i];
        lat->spins[i] = -s;

        f = 0, r = 0; 
        int unvis[n_spins]; // save unvisited spins in a queue
        unvis[rear++] = i;

        cs = 1; // cluster size counter
        b = 0;  // number of border spins with different sign
        while (f != r) {
            // get an unvisited site from the front
            i = unvis[front++];
            // loop over neighbours 
            for (j = 4 * i; j < 4 * (i + 1); ++j) {
                ++b;
                nbr = lat->nbrs[j];
                // flip if right sign with probability p_add
                if (lat->spins[nbr] == s) {
                    --b;
                    if (genrand_real1() < p_add) {
                        lat->spins[nbr] = -s;
                        unvis[rear++] = nbr; // enqueue the site to check it later
                        ++cs;
                    }
                }
            }
        }

        clus_sz[t - 1] = cs;
        energy[t] = energy[t - 1] - 2.0 * b / n_spins;
        magnet[t] = magnet[t - 1] - 2.0 * s * cs / n_spins;
    }
}
