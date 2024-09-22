#include <stdio.h>
#include <stdlib.h>

#define N_ARGS 8

struct point {
    double x;
    double p;
};

static inline void vverlet(struct point *z, double k, double m, double dt)
{
    z->p -= k * z->x * dt / 2;
    z->x += z->p * dt / m;
    z->p -= k * z->x * dt / 2;
}

static inline void beeman(struct point *z, double *x_old, double k, double m,
                          double dt)
{
    double x_now = z->x;
    z->x += (z->p - (4 * x_now - *x_old) * k * dt / 6) * dt / m;
    z->p -= (2 * z->x + 5 * x_now - *x_old) * k * dt / 6;
    *x_old = x_now;
}

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr, "[executable] [output file prefix] [k] [m] \\\n");
        fprintf(stderr, "  [x0] [p0] [step size] [# of steps]\n");
        return 1;
    }

    double k = atof(argv[2]);
    double m = atof(argv[3]);
    double x0 = atof(argv[4]);
    double p0 = atof(argv[5]);
    double step_size = atof(argv[6]);
    int num_steps = atoi(argv[7]);

    char fname[100];
    snprintf(fname, sizeof(fname), "out/092_%s.csv", argv[1]);
    FILE *file = fopen(fname, "w");
    fprintf(file, "time,x_vverlet,p_vverlet,x_beeman,p_beeman\n");
    fprintf(file, "0,%f,%f,%f,%f\n", x0, p0, x0, p0);

    struct point z1 = {x0, p0};
    struct point z2 = {x0, p0};
    double x_old = x0;

    // Beeman needs to start from the third time step
    vverlet(&z1, k, m, step_size);
    vverlet(&z2, k, m, step_size);
    fprintf(file, "%f,%f,%f,%f,%f\n", step_size, z1.x, z1.p, z2.x, z2.p);

    for (int t = 2; t < num_steps; ++t) {
        vverlet(&z1, k, m, step_size);
        beeman(&z2, &x_old, k, m, step_size);
        double time = t * step_size;
        fprintf(file, "%f,%f,%f,%f,%f\n", time, z1.x, z1.p, z2.x, z2.p);
    }

    fclose(file);

    return 0;
}
