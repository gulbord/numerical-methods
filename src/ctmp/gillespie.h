#ifndef GILLESPIE_H
#define GILLESPIE_H

#include <stddef.h>
#include <stdio.h>

typedef double (*rate_ptr)(int *);
typedef void (*reac_ptr)(int *, int *);

struct state_array {
    int **states;
    double *times;
    size_t o_size; // outer size = number of stored states/times
    size_t i_size; // inner size = number of species/populations in states[i]
    size_t used;   // number of stored elements
};

// set the sizes and allocate the states and times arrays
void init_state_array(struct state_array *s, size_t n_spec, size_t init_size);
// insert a new state and time in the corresponding arrays
// and expand o_size if needed
void update_state_array(struct state_array *s, int *new_state, double new_time);
// write times and states to file in one go
void write_state_array(struct state_array *s, FILE *file);
// deallocate everything
void free_state_array(struct state_array *s);

void gillespie(struct state_array *s, rate_ptr *rate_fns, reac_ptr *reac_fns,
               int n_react, double max_time);

#endif
