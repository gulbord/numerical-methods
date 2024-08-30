#include "ctmp/lotka_volterra.h"
#include "utils/random.h"
#include <stdlib.h>
#include <time.h>

#define N_ARGS 8

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [output file prefix] \\\n");
        fprintf(
            stderr,
            "  [prey birth rate] [predation rate] [predator death rate] \\\n");
        fprintf(stderr, "  [init. prey] [init. predators] [max. time] \\\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    double prey_birth_k = atof(argv[2]);
    double predation_k = atof(argv[3]);
    double pred_death_k = atof(argv[4]);
    int init_prey = atoi(argv[5]);
    int init_pred = atoi(argv[6]);
    double max_time = atof(argv[7]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/071_%s.csv", argv[1]);
    FILE *file = fopen(fname, "w");
    fprintf(file, "time,prey,pred\n");

    // Parameters arrays
    int pops[2] = {init_prey, init_pred};
    double k[3] = {prey_birth_k, predation_k, pred_death_k};
    // Reaction rate functions array
    rate_ptr rates[3] = {&prey_birth_r, &predation_r, &pred_death_r};
    // Reaction update functions array
    reac_ptr reactions[3] = {&prey_birth_u, &predation_u, &pred_death_u};

    gillespie(pops, 2, reactions, 3, rates, k, max_time, file);

    fclose(file);

    return 0;
}
