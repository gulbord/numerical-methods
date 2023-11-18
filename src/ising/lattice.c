#include "lattice.h"
#include "lib/mt19937ar.h"
#include <stdlib.h>

void init_lattice(Lattice* lat, int l_siz)
{
    lat->side = l_siz;
    int n_spins = l_siz * l_siz;
    lat->spins = malloc(n_spins * sizeof(int));
    lat->nbrs = malloc(4 * n_spins * sizeof(int));

    int i, j, n, k = 0;
    for (i = 0; i < l_siz; ++i) {
        for (j = 0; j < l_siz; ++j) {
            // random +1/-1 initialization
            lat->spins[k] = (genrand_int32() % 2) * 2 - 1;

            // find the four nearest neighbours with pbc
            n = 4 * k;
            lat->nbrs[n] = (k + l_siz) % n_spins;                   // up
            lat->nbrs[n + 1] = l_siz * i + (k + 1) % l_siz;         // right
            lat->nbrs[n + 2] = l_siz * i + (l_siz + j - 1) % l_siz; // left
            lat->nbrs[n + 3] = (n_spins + k - l_siz) % n_spins;     // down
            ++k;
        }
    }
}

void free_lattice(Lattice* lat)
{
    free(lat->spins);
    free(lat->nbrs);
    free(lat);
}
