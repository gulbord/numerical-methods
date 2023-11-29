#ifndef LOTKA_VOLTERRA_H
#define LOTKA_VOLTERRA_H

#include "gillespie.h"

static inline double prey_birth_r(double *k, int *pops)
{
    return k[0] * pops[0];
}
static inline double predation_r(double *k, int *pops)
{
    return k[1] * pops[0] * pops[1];
}
static inline double pred_death_r(double *k, int *pops)
{
    return k[2] * pops[1];
}

static inline void prey_birth_u(int *old_pops, int *new_pops)
{
    new_pops[0] = old_pops[0] + 1;
    new_pops[1] = old_pops[1];
}
static inline void predation_u(int *old_pops, int *new_pops)
{
    new_pops[0] = old_pops[0] - 1;
    new_pops[1] = old_pops[1] + 1;
}
static inline void pred_death_u(int *old_pops, int *new_pops)
{
    new_pops[0] = old_pops[0];
    new_pops[1] = old_pops[1] - 1;
}

#endif
