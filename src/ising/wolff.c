#include "wolff.h"
#include "../../lib/mt19937ar.h"
#include <math.h>
#include <string.h>

void wolff(struct lattice *lat, int n_steps, double beta,
           double *energy, double *magnet, int *clus_sz)
{
    int n_spins = lat->side * lat->side;
    int e = 0, m = 0;
    int i, n, nn_sum;

    // compute energy and magnetization at initialization
    for (i = 0; i < n_spins; ++i) {
        // sum the up and right nearest neighbours
        n = 4 * i;
        nn_sum = lat->spins[lat->nbrs[n]] + lat->spins[lat->nbrs[n + 1]];
        e -= lat->spins[i] * nn_sum;
        m += lat->spins[i];
    }

    // divide by N = L^2 to get average per spin
    energy[0] = (double)e / n_spins;
    magnet[0] = (double)m / n_spins;

    double p_add = 1 - exp(-2 * beta);
    int t, cs, front, rear; // counters
    int seed, s0, nbr, delta_e;
    // save unvisited spins in a queue
    int unvisited[n_spins];
    // array of bools for cluster membership
    int is_cluster[n_spins];

    for (t = 1; t < n_steps; ++t) {
        // reset cluster membership
        memset(is_cluster, 0, sizeof(is_cluster));

        // pick a starting spin at random
        seed = (int)(genrand_real2() * n_spins);
        is_cluster[seed] = 1;
        // flip the seed spin and save its value
        s0 = lat->spins[seed];
        lat->spins[seed] = -s0;

        front = 0; rear = 0;
        unvisited[rear++] = seed;

        cs = 1; // cluster size
        while (front != rear) {
            // get an unvisited site from the front
            i = unvisited[front++];
            // loop over neighbours
            for (n = 4 * i; n < 4 * (i + 1); ++n) {
                nbr = lat->nbrs[n];
                // flip if right sign, with probability p_add
                if (lat->spins[nbr] == s0 && genrand_real1() < p_add) {
                    is_cluster[nbr] = 1;
                    lat->spins[nbr] = -s0;
                    // enqueue the site to check it later
                    unvisited[rear++] = nbr;
                    ++cs;
                }
            }
        }

        clus_sz[t - 1] = cs; // clus_sz should have (n_steps - 1) elements!
        magnet[t] = magnet[t - 1] - 2.0 * s0 * cs / n_spins;

        // compute the energy difference
        delta_e = 0;
        front = 0; rear = 0;
        unvisited[rear++] = seed;
        while (front != rear) {
            // get an unvisited cluster site from the front
            i = unvisited[front++];
            // loop over neighbours
            for (n = 4 * i; n < 4 * (i + 1); ++n) {
                nbr = lat->nbrs[n];

                // c | b     c | b    [c = cluster, b = border]
                // + | - --> + | +    then delta_e < 0
                // + | + --> + | -    then delta_e > 0
                switch (is_cluster[nbr]) {
                    case 0: // border spin
                        delta_e += s0 * lat->spins[nbr];
                        break;
                    case 1: // cluster spin
                        is_cluster[nbr] += 1;
                        unvisited[rear++] = nbr;
                        break;
                    default: // cluster spin, but already considered
                        break;
                }
            }
        }

        energy[t] = energy[t - 1] + 2.0 * delta_e / n_spins;
    }
}
