#ifndef GILLESPIE_H
#define GILLESPIE_H

#include <stddef.h>
#include <stdio.h>

typedef double (*rate_ptr)(double *, int *);
typedef void (*reac_ptr)(int *, int *);

struct state {
    size_t p_size; // Size of `pops`
    int *pops;     // Occupation numbers or populations
    double time;
    struct state *next; // Next element in the list
};

// Initialize the linked list by filling the head node
void init_state_list(struct state *head, int *pops, size_t p_size);
// Insert a state at the beginning of the linked list
void update_state_list(struct state **head, int *pops, double time);
// Print the whole list (in reverse order) to file
void write_state_list(struct state *head, FILE *file);
// Deallocate correctly
void free_state_list(struct state *head);

void gillespie(struct state **head, rate_ptr *rate_fns, double *rate_con,
               reac_ptr *reac_fns, int n_react, double max_time);

#endif
