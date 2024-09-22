#include <stdio.h>
#include <stdlib.h>

#define N_ARGS 6

struct point {
    double x;
    double p;
};

static inline void euler(struct point *z, double dt)
{
    double x = z->x + z->p * dt;
    z->p -= z->x * dt;
    z->x = x;
}

static inline void symp(struct point *z, double dt)
{
    z->p -= z->x * dt;
    z->x += z->p * dt;
}

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [output file prefix] [x0] [p0] [step "
                        "size] [# of steps]\n");
        return 0;
    }

    double x0 = atof(argv[2]);
    double p0 = atof(argv[3]);
    double step_size = atof(argv[4]);
    int num_steps = atoi(argv[5]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/091_%s.csv", argv[1]);
    FILE *file = fopen(fname, "w");
    fprintf(file, "time,x1,p1,x2,p2\n");
    fprintf(file, "0,%f,%f,%f,%f\n", x0, p0, x0, p0);

    struct point z1 = {x0, p0}; // For the non-symplectic integrator
    struct point z2 = {x0, p0}; // For the symplectic integrator

    for (int t = 1; t < num_steps; ++t) {
        euler(&z1, step_size);
        symp(&z2, step_size);
        double time = t * step_size;
        fprintf(file, "%f,%f,%f,%f,%f\n", time, z1.x, z1.p, z2.x, z2.p);
    }

    fclose(file);

    return 0;
}
