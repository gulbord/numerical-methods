#include "../lib/mt19937ar.h"
#include "ctmp/lotka_volterra.h"
#include <stdlib.h>
#include <time.h>

#define MAX_TIME 8.0
// initial populations
#define INIT_PREY 500
#define INIT_PRED 400

int main()
{
    // alternative to time() seed:
    // unsigned long seed[4] = {0x123, 0x345, 0x789, 0x583};
    // init_by_array(seed, 4);
    init_genrand((unsigned long)time(NULL));

    // compose file name
    char fname[100];
    snprintf(fname, sizeof(fname), "out/08a_Ka%g_Kb%g_Kc%g_X%d_Y%d_T%g.txt",
             PREY_BIRTH_K, PREDATION_K, PRED_DEATH_K,
             INIT_PREY, INIT_PRED, MAX_TIME);
    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("E: fopen() failed");
        return 1;
    }

    // reaction rate functions array
    rate_ptr rate_fns[3]
        = {&prey_birth_rate, &predation_rate, &pred_death_rate};
    // reaction update functions array
    reac_ptr reac_fns[3]
        = {&prey_birth_update, &predation_update, &pred_death_update};

    struct state *init = malloc(sizeof(struct state));
    // insert the initial state
    int init_state[2] = {INIT_PREY, INIT_PRED};
    init_state_list(init, init_state, 2);

    gillespie(&init, rate_fns, reac_fns, 3, MAX_TIME);

    write_state_list(init, file);

    fclose(file);
    free_state_list(init);

    return 0;
}
