#ifndef CORRELATIONS_H
#define CORRELATIONS_H

double stat_ineff(double* a, int len_a, int t0, int min_lag);
double detect_eq(double* a, int len_a, int n_skip);

#endif
