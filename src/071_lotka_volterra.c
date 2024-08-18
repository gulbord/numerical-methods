#include "utils/random.h"
#include "ctmp/lotka_volterra.h"
#include <stdlib.h>
#include <time.h>

#define N_ARGS 7

int main(int argc, char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [prey birth rate] \\\n");
        fprintf(stderr, "  [predation rate] [predator death rate] \\\n");
        fprintf(stderr, "  [init. preys] [init. predators] [max. time] \\\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    double prey_birth_k = atof(argv[1]);
    double predation_k = atof(argv[2]);
    double pred_death_k = atof(argv[3]);
    int init_prey = atoi(argv[4]);
    int init_pred = atoi(argv[5]);
    double max_time = atof(argv[6]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/071_Ka%g_Kb%g_Kc%g_X%d_Y%d_T%g.csv",
             prey_birth_k, predation_k, pred_death_k,
             init_prey, init_pred, max_time);
    FILE *file = fopen(fname, "w");

    // Parameters arrays
    int init_pops[2] = {init_prey, init_pred};
    double rate_con[3] = {prey_birth_k, predation_k, pred_death_k};
    // Reaction rate functions array
    rate_ptr rate_fns[3] = {&prey_birth_r, &predation_r, &pred_death_r};
    // Reaction update functions array
    reac_ptr reac_fns[3] = {&prey_birth_u, &predation_u, &pred_death_u};

    struct state *init = malloc(sizeof(struct state));
    init_state_list(init, init_pops, 2);

    gillespie(&init, rate_fns, rate_con, reac_fns, 3, max_time);

    write_state_list(init, file);

    fclose(file);
    free_state_list(init);

    return 0;
}
