#include "utils/random.h"
#include "off-lattice/monte_carlo.h"
#include "off-lattice/particles.h"
#include "utils/progress.h"
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

    rng_set_seed(time(NULL));

    struct parameters params;
    if (parse_config(argv[1], &params))
        return 1;

    char fname[255];
    snprintf(fname, sizeof(fname), "out/082_N%d_L%g_d%g_T%g_s%d.csv",
             params.num_particles, params.box_size, params.disp_max,
             params.temperature, params.mc_steps);
    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }

    double *particles = malloc(3 * params.num_particles * sizeof(*particles));

    init_particles(particles, &params);

    for (int i = 0; i < params.mc_steps; ++i) {
        print_progress((double)(i + 1) / params.mc_steps);
        double energy = monte_carlo_sweep(particles, &params);
        fprintf(file, "%g\n", energy);
    }

    printf("\n"); // After progress bar

    fclose(file);
    free(particles);

    return 0;
}
