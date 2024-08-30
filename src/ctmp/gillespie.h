#ifndef GILLESPIE_H
#define GILLESPIE_H

#include <stdio.h>

typedef void (*reac_ptr)(int *);
typedef double (*rate_ptr)(double *, int *);

void gillespie(int *pops, int n_pops, reac_ptr *reactions, int n_reac,
               rate_ptr *rates, double *k, double max_time, FILE *file);

#endif
