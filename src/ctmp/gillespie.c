#include "gillespie.h"
#include "../../lib/mt19937ar.h"
#include <math.h>
#include <stdlib.h>

void init_state_array(struct state_array *s, size_t n_spec, size_t init_size)
{
    s->i_size = n_spec;
    s->o_size = init_size;
    s->used = 0;

    s->states = malloc(s->o_size * sizeof(int *));
    for (size_t i = 0; i < s->o_size; ++i)
        s->states[i] = malloc(s->i_size * sizeof(int));
    s->times = malloc(s->o_size * sizeof(double));
}

void update_state_array(struct state_array *s, int *new_state, double new_time)
{
    size_t i;
    // if running out of space, double the allocation
    if (s->used == s->o_size) {
        s->o_size *= 2;
        s->states = realloc(s->states, s->o_size * sizeof(int *));
        // allocate only the additional locations (i.e. start from 'used')
        for (i = s->used; i < s->o_size; ++i)
            s->states[i] = malloc(s->i_size * sizeof(int));
        s->times = realloc(s->times, s->o_size * sizeof(double));
    }

    // copy new state and time and advance 'used' counter
    for (i = 0; i < s->i_size; ++i)
        s->states[s->used][i] = new_state[i];
    s->times[s->used++] = new_time;
}

void write_state_array(struct state_array *s, FILE *file)
{
    size_t i, j;
    for (i = 0; i < s->used; ++i) {
        fprintf(file, "%.10f,", s->times[i]);
        for (j = 0; j < s->i_size - 1; ++j)
            fprintf(file, "%i,", s->states[i][j]);
        fprintf(file, "%i\n", s->states[i][s->i_size - 1]);
    }
}

void free_state_array(struct state_array *s)
{
    for (size_t i = 0; i < s->o_size; ++i)
        free(s->states[i]);
    free(s->states);
    free(s->times);
}

void gillespie(struct state_array *s, rate_ptr *rate_fns, reac_ptr *reac_fns,
               int n_react, double max_time)
{
    // initialize a rate array to be updated at every iteration
    double *rates = malloc(n_react * sizeof(double));
    // int array to momentarily hold the updated state
    int *new_state = malloc(s->i_size * sizeof(int));

    double esc_rate, tau, thr, sum, tot_time = 0.0;
    int i, pick, t = 0;

    while (tot_time < max_time) {
        // calculate the escape rate by looping over rate functions
        esc_rate = 0.0;
        for (i = 0; i < n_react; ++i) {
            rates[i] = rate_fns[i](s->states[t]);
            esc_rate += rates[i];
        }

        // calculate the residence time and check if we are past the maximum
        tau = -log(genrand_real3()) / esc_rate;
        if (tot_time + tau > max_time)
            break;

        // pick a reaction with probability ~ rate_i / esc_rate
        thr = genrand_real1() * esc_rate;
        sum = 0.0;
        pick = 0;
        for (i = 0; i < n_react; ++i) {
            sum += rates[i];
            if (sum > thr) {
                pick = i;
                break;
            }
        }

        // update the elapsed time
        tot_time += tau;

        // update the state according to the chosen reaction
        reac_fns[pick](s->states[t++], new_state);
        update_state_array(s, new_state, tot_time);
    }

    free(rates);
    free(new_state);
}
