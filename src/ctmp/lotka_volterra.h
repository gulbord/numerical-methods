#ifndef LOTKA_VOLTERRA_H
#define LOTKA_VOLTERRA_H

#include "gillespie.h"

// reaction rates constants
#define PREY_BIRTH_K 3.0
#define PREDATION_K 0.01
#define PRED_DEATH_K 5.0

static inline double prey_birth_rate(int *state)
{
    return PREY_BIRTH_K * state[0];
}
static inline double predation_rate(int *state)
{
    return PREDATION_K * state[0] * state[1];
}
static inline double pred_death_rate(int *state)
{
    return PRED_DEATH_K * state[1];
}

static inline void prey_birth_update(int *old_state, int *new_state)
{
    new_state[0] = old_state[0] + 1;
    new_state[1] = old_state[1];
}

static inline void predation_update(int *old_state, int *new_state)
{
    new_state[0] = old_state[0] - 1;
    new_state[1] = old_state[1] + 1;
}

static inline void pred_death_update(int *old_state, int *new_state)
{
    new_state[0] = old_state[0];
    new_state[1] = old_state[1] - 1;
}

#endif
