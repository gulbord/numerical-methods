#include "../lib/mt19937ar.h"
#include "ising/wolff.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 4

int main(int argc, char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "E: wrong number of arguments! (Should be %d)\n",
                N_ARGS);
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    // read parameters from command line
    int lat_size = atoi(argv[1]);
    double temp = atof(argv[2]);
    int n_steps = atoi(argv[3]);

    // compose file name
    char fname[128];
    snprintf(fname, sizeof(fname), "out/07a_L%s_T%.4f_Nt%s.txt",
             argv[1], temp, argv[3]);
    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("E: fopen() failed");
        return 1;
    }

    double *energy = malloc(n_steps * sizeof(double));
    double *magnet = malloc(n_steps * sizeof(double));
    int *clus_sz = malloc((n_steps - 1) * sizeof(int)); // no cluster at t = 0

    // build the lattice and perform wolff for n_steps timesteps
    struct lattice *lat = malloc(sizeof(struct lattice));
    init_lattice(lat, lat_size);
    wolff(lat, n_steps, 1 / temp, energy, magnet, clus_sz);
    free_lattice(lat);

    // write results to file
    fwrite(energy, sizeof(*energy), n_steps, file);
    fwrite(magnet, sizeof(*magnet), n_steps, file);
    fwrite(clus_sz, sizeof(*clus_sz), n_steps - 1, file);
    fclose(file);

    free(energy);
    free(magnet);
    free(clus_sz);

    return 0;
}
