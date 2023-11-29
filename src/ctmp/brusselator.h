#ifndef BRUSSELATOR_H
#define BRUSSELATOR_H

#include "gillespie.h"

static inline double x_creat_r(double *k, int *pops)
{
    (void)pops; // to suppress unused-variable warning
    return k[0] * k[2];
}
static inline double x_destr_r(double *k, int *pops)
{
    (void)k;
    return (double)(pops[0]);
}
static inline double y_to_x_r(double *k, int *pops)
{
    return pops[0] * (pops[0] - 1.0) * pops[1] / (k[2] * k[2]);
}
static inline double x_to_y_r(double *k, int *pops)
{
    return k[1] * pops[0];
}

static inline void x_creat_u(int *old_pops, int *new_pops)
{
    new_pops[0] = old_pops[0] + 1;
    new_pops[1] = old_pops[1];
}
static inline void x_destr_u(int *old_pops, int *new_pops)
{
    new_pops[0] = old_pops[0] - 1;
    new_pops[1] = old_pops[1];
}
static inline void y_to_x_u(int *old_pops, int *new_pops)
{
    new_pops[0] = old_pops[0] + 1;
    new_pops[1] = old_pops[1] - 1;
}
static inline void x_to_y_u(int *old_pops, int *new_pops)
{
    new_pops[0] = old_pops[0] - 1;
    new_pops[1] = old_pops[1] + 1;
}

#endif
