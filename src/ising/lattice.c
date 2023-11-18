#include "lib/mt19937ar.h"

void init_lattice(Lattice* lat, int l_siz)
{
    lat->side = l_siz;
    int n_spins = l_siz * l_siz;
    lat.spins = malloc(n_spins * sizeof(int));
    lat.nbrs = malloc(4 * n_spins * sizeof(int));

    int row_first; // first index in the current row
    int i, j, k;
    for (i = 0; i < l_siz; ++i) {
        for (j = 0; j < l_siz; ++j) {
            // random +1/-1 initialization
            lat.spins[k] = (genrand_int32() % 2) * 2 - 1;

            // find the four nearest neighbours with pbc
            row_first = l_siz * (k / l_siz);
            lat.nbrs[k] = (k + l_siz) % n_spins;                       // up
            lat.nbrs[k + 1] = row_first + (k - row_first + 1) % l_siz; // right
            lat.nbrs[k + 2] = row_first + (k - row_first - 1) % l_siz; // left
            lat.nbrs[k + 3] = (n_spins + k - l_siz) % n_spins;         // down
            ++k;
        }
    }
}

void free_lattice(Lattice* lat)
{
    free(lat.spins);
    free(lat.nbrs);
}
