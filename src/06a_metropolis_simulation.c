#include "ising/lattice.h"
#include "ising/lib/mt19937ar.h"
#include "ising/metropolis.h"
#include "utils/correlations.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 4

int main(int argc, char** argv)
{
    if (argc != N_ARGS) {
        printf("Wrong number of arguments! (Should be %d)\n", N_ARGS);
        return 1;
    }

    // alternative to time() seed:
    // unsigned long seed[4] = {0x123, 0x345, 0x789, 0x583};
    // init_by_array(seed, 4);
    init_genrand((unsigned long)time(NULL));

    // read parameters from command line
    int lat_size = atoi(argv[1]);
    double temp = atof(argv[2]);
    int n_steps = atoi(argv[3]);

    // compose file name
    char fname[100];
    snprintf(fname, sizeof(fname), "out/A06a_L%s_T%.4f_Nt%s.txt",
             argv[1], temp, argv[3]);
    FILE* file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }

    double* energy = malloc(n_steps * sizeof(double));
    double* magnet = malloc(n_steps * sizeof(double));

    // build the lattice and perform metropolis for n_steps timesteps
    Lattice* system = malloc(sizeof(Lattice));
    init_lattice(system, lat_size);
    evolve(system, n_steps, 1 / temp, energy, magnet);
    free_lattice(system);

    // write results to file
    fwrite(energy, sizeof(*energy), n_steps, file);
    fwrite(magnet, sizeof(*magnet), n_steps, file);
    fclose(file);
    printf("Results written to file. Computing equilibration times... ");
    fflush(stdout);

    // detect equilibration times
    int teq_e = eq_time(energy, n_steps, 10);
    int teq_m = eq_time(magnet, n_steps, 10);

    printf("Finished!\nt0[E] = %d\nt0[M] = %d\n", teq_e, teq_m);

    free(energy);
    free(magnet);

    return 0;
}
