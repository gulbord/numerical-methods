#ifndef GILLESPIE_H
#define GILLESPIE_H

#include <stddef.h>
#include <stdio.h>

typedef double (*rate_ptr)(double *, int *);
typedef void (*reac_ptr)(int *, int *);

struct state {
    size_t p_size; // size of `pops`
    int *pops;     // occupation numbers or populations
    double time;
    struct state *next; // next element in the list
};

// initialize the linked list by filling the head node
void init_state_list(struct state *head, int *pops, size_t p_size);
// insert a state at the beginning of the linked list
void update_state_list(struct state **head, int *pops, double time);
// print the whole list (in reverse order) to file
void write_state_list(struct state *head, FILE *file);
// deallocate correctly
void free_state_list(struct state *head);

void gillespie(struct state **head, rate_ptr *rate_fns, double *rate_con,
               reac_ptr *reac_fns, int n_react, double max_time);

#endif
