/*
 * References
 * ----------
 *
 * [1]J. D. Chodera, W. C. Swope, J. W. Pitera, C. Seok, and K. A. Dill, “Use of
 * the Weighted Histogram Analysis Method for the Analysis of Simulated and
 * Parallel Tempering Simulations,” Journal of Chemical Theory and Computation,
 * vol. 3, no. 1, pp. 26–41, 2007, doi: 10.1021/ct0502864. 
 *
 * [2] J. D. Chodera, “A Simple Method for Automated Equilibration Detection in
 * Molecular Simulations,” Journal of Chemical Theory and Computation, vol. 12,
 * no. 4, pp. 1799–1805, 2016, doi: 10.1021/acs.jctc.5b00784.
 *
 */

#include <stdlib.h>

#define C_THR 0.005

double stat_ineff(double* a, int len_a, int t0, int min_lag)
{
    // length of shortened data
    int len_a0 = len_a - t0;

    // compute the mean of the shortened version of a, a0 = a[t0:len_a]
    double mean_a0 = 0.0;
    int i;
    for (i = t0; i < len_a; ++i)
        mean_a0 += a[i];
    mean_a0 /= len_a0;

    // compute variance and shifted data
    double* da0 = malloc(len_a0 * sizeof(double));
    double var0 = 0.0;
    for (i = 0; i < len_a0; ++i) {
        da0[i] = a[i + t0] - mean_a0;
        var0 += da0[i] * da0[i];
    }
    if (var0 == 0.0)
        return -1.0; // perfectly stationary time series
    var0 /= len_a0;

    double tau = 0.0;
    double c;
    int t = 1;
    while (t < len_a0 - 1) {
        // compute normalized fluctuation correlation function at lag t
        c = 0.0;
        for (i = 0; i < len_a0 - t; ++i)
            c += da0[i] * da0[i + t];
        c /= (len_a0 - t) * var0;

        // terminate if c has crossed the threshold C_THR
        // and we've computed it at least out to lag = min_lag
        if (c < C_THR && t > min_lag)
            break;

        // accumulate contribution to the correlation time
        tau += (1 - (double)t / len_a0) * c;
        ++t;
    }

    free(da0);

    return 1 + 2 * tau;
}

int eq_time(double* a, int len_a, int n_skip)
{
    double g, n_eff, max_n_eff = 0.0;
    int t0, best_t0 = 0;
    for (t0 = 0; t0 < len_a - 1; t0 += n_skip) {
        // compute stat. ineff. and # of uncorrelated samples
        g = stat_ineff(a, len_a, t0, 3);
        n_eff = (len_a - t0 + 1) / g;

        // search for t0 such that n_eff is maximized
        if (n_eff > max_n_eff) {
            max_n_eff = n_eff;
            best_t0 = t0;
        } else if (n_eff < 0) {
            // stat_ineff() returns -1 when it encounters a stationary time
            // series. In that case, there's no reason to continue sampling
            // since all subsequent subsets a[t0:] will be stationary too
            break;
        }
    }

    return best_t0;
}
