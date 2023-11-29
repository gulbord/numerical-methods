#include "../lib/mt19937ar.h"
#include "ctmp/lotka_volterra.h"
#include <stdlib.h>
#include <time.h>

#define N_ARGS 7

int main(int argc, char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "E: wrong number of arguments! (Should be %d)\n",
                N_ARGS);
        return 1;
    }

    // alternative to time() seed:
    // unsigned long seed[4] = {0x123, 0x345, 0x789, 0x583};
    // init_by_array(seed, 4);
    init_genrand((unsigned long)time(NULL));

    // read parameters from command line
    double prey_birth_k = atof(argv[1]);
    double predation_k = atof(argv[2]);
    double pred_death_k = atof(argv[3]);
    int init_prey = atoi(argv[4]);
    int init_pred = atoi(argv[5]);
    double max_time = atof(argv[6]);

    // compose file name
    char fname[100];
    snprintf(fname, sizeof(fname), "out/08a_Ka%g_Kb%g_Kc%g_X%d_Y%d_T%g.txt",
             prey_birth_k, predation_k, pred_death_k,
             init_prey, init_pred, max_time);
    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("E: fopen() failed");
        return 1;
    }

    // parameters arrays
    int init_pops[2] = {init_prey, init_pred};
    double rate_con[3] = {prey_birth_k, predation_k, pred_death_k};
    // reaction rate functions array
    rate_ptr rate_fns[3] = {&prey_birth_r, &predation_r, &pred_death_r};
    // reaction update functions array
    reac_ptr reac_fns[3] = {&prey_birth_u, &predation_u, &pred_death_u};

    struct state *init = malloc(sizeof(struct state));
    init_state_list(init, init_pops, 2);

    gillespie(&init, rate_fns, rate_con, reac_fns, 3, max_time);

    write_state_list(init, file);

    fclose(file);
    free_state_list(init);

    return 0;
}
