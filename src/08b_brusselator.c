#include "../lib/mt19937ar.h"
#include "ctmp/brusselator.h"
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

    init_genrand((unsigned long)time(NULL));

    // read parameters from command line
    double a = atof(argv[1]);
    double b = atof(argv[2]);
    double o = atof(argv[3]);
    int init_x = atoi(argv[4]);
    int init_y = atoi(argv[5]);
    double max_time = atof(argv[6]);

    // compose file name
    char fname[100];
    snprintf(fname, sizeof(fname), "out/08b_a%g_b%g_O%g_X%d_Y%d_T%g.txt",
             a, b, o, init_x, init_y, max_time);
    FILE *file = fopen(fname, "w");
    if (file == NULL) {
        perror("E: fopen() failed");
        return 1;
    }

    // parameters arrays
    int init_pops[2] = {init_x, init_y};
    double rate_con[3] = {a, b, o};
    // reaction rate functions array
    rate_ptr rate_fns[4] = {&x_creat_r, &x_destr_r, &y_to_x_r, &x_to_y_r};
    // reaction update functions array
    reac_ptr reac_fns[4] = {&x_creat_u, &x_destr_u, &y_to_x_u, &x_to_y_u};

    struct state *init = malloc(sizeof(struct state));
    init_state_list(init, init_pops, 2);

    gillespie(&init, rate_fns, rate_con, reac_fns, 4, max_time);

    write_state_list(init, file);

    fclose(file);
    free_state_list(init);

    return 0;
}
