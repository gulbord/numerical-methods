#include "../lib/mt19937ar.h"
#include "off-lattice/monte_carlo.h"
#include "off-lattice/particles.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 2

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [configuration file]\n");
        return 1;
    }

    init_genrand((unsigned long)time(NULL));

    struct parameters params;
    if (parse_config(argv[1], &params))
        return 1;

    char fname[100];
    snprintf(fname, sizeof(fname), "out/082_N%d_L%g_d%g_T%g_s%d.csv",
             params.num_particles, params.box_size, params.disp_max,
             params.temperature, params.mc_steps);
    FILE *file = fopen(fname, "w");

    double *particles = malloc(3 * params.num_particles * sizeof(*particles));

    init_particles(particles, &params);
    printf("%g\n", calc_energy(particles, &params) / params.num_particles);

    for (int i = 0; i < params.mc_steps; ++i) {
        double energy = monte_carlo_sweep(particles, &params);
        printf("%g\n", energy / params.num_particles);
        fprintf(file, "%g\n", energy / params.num_particles);
    }

    free(particles);
    fclose(file);

    return 0;
}
