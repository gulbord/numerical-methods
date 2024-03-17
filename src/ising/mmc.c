void metropolis_mmc(int l_siz, int n_steps, int n_chains, double *betas,
                    double (*energy)[], double (*magnet)[])
{
    int n_spins = l_siz * l_siz;
    int nbrs = malloc(4 * n_spins * sizeof(int));
    int (*spins)[n_spins] = malloc(sizeof(int[n_chains][n_spins])); 

    int i, j, n, k = 0;
    for (i = 0; i < l_siz; ++i) {
        for (j = 0; j < l_siz; ++j) {
            // find the four nearest neighbours with pbc
            n = 4 * k;
            nbrs[n] = (k + l_siz) % n_spins;                   // up
            nbrs[n + 1] = l_siz * i + (k + 1) % l_siz;         // right
            nbrs[n + 2] = l_siz * i + (l_siz + j - 1) % l_siz; // left
            nbrs[n + 3] = (n_spins + k - l_siz) % n_spins;     // down
            ++k;
        }
    }

    int a, e, m, nn_sum;
    for (a = 0; a < n_chains; ++a) {
        // randomly initialize the lattice in every chain
        for (i = 0; i < n_spins; ++i)
            spins[a][i] = (genrand_int32() % 2) * 2 - 1;

        // compute energy and magnetization after initialization
        e = 0;
        m = 0;
        for (i = 0; i < n_spins; ++i) {
            nn_sum = spins[a][nbrs[4 * i]] + spins[a][nbrs[4 * i + 1]];
            e -= spins[a][i] * nn_sum;
            m += spins[a][i];
        }

        energy[0][a] = (double)e / n_spins;
        magnet[0][a] = (double)m / n_spins;
    }

    for (int t = 1; t < n_steps; ++t) { /* ... */ }

    free(nbrs);
    free(spins);
}
