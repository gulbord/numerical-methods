#include "ctmp/brusselator.h"
#include "utils/random.h"
#include <stdlib.h>
#include <time.h>

#define N_ARGS 8

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [output file prefix] [a] [b] [Ω] \\\n");
        fprintf(stderr, "  [init. X] [init. Y] [max. time]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    double a = atof(argv[2]);
    double b = atof(argv[3]);
    double omega = atof(argv[4]);
    int init_x = atoi(argv[5]);
    int init_y = atoi(argv[6]);
    double max_time = atof(argv[7]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/072_%s.csv", argv[1]);
    FILE *file = fopen(fname, "w");
    fprintf(file, "time,X,Y\n");

    // Parameters arrays
    int pops[2] = {init_x, init_y};
    double k[3] = {a, b, omega};
    // Reaction rate functions array
    rate_ptr rates[4] = {&x_creat_r, &x_destr_r, &y_to_x_r, &x_to_y_r};
    // Reaction update functions array
    reac_ptr reactions[4] = {&x_creat_u, &x_destr_u, &y_to_x_u, &x_to_y_u};

    gillespie(pops, 2, reactions, 4, rates, k, max_time, file);

    fclose(file);

    return 0;
}
