/*
 * References
 * ----------
 *
 * [1] J. D. Chodera, W. C. Swope, J. W. Pitera, C. Seok, and K. A. Dill, “Use
 * of the Weighted Histogram Analysis Method for the Analysis of Simulated and
 * Parallel Tempering Simulations,” Journal of Chemical Theory and Computation,
 * vol. 3, no. 1, pp. 26–41, 2007, doi: 10.1021/ct0502864.
 *
 * [2] J. D. Chodera, “A Simple Method for Automated Equilibration Detection in
 * Molecular Simulations,” Journal of Chemical Theory and Computation, vol. 12,
 * no. 4, pp. 1799–1805, 2016, doi: 10.1021/acs.jctc.5b00784.
 *
 */

#include <math.h>
#include <stdlib.h>

#define C_THR 0.005

double stat_ineff(double *a, int n, int t0)
{
    // compute mean and standard deviation of shortened data
    // [using Welford's algorithm]
    double mean_s = 0.0;
    double delta, delta2, m2 = 0.0;
    int i, ns = 1;
    for (i = t0; i < n; ++i) {
        delta = a[i] - mean_s;
        mean_s += delta / ns++;
        delta2 = a[i] - mean_s;
        m2 += delta * delta2;
    }

    if (ns < 2)
        return NAN; // shouldn't happen anyway
    else if (m2 == 0.0)
        return -1.0; // perfectly stationary time series

    // finalize variance
    double var_s = m2 / ns;

    double c, tau = 0.0;
    int t = 1, dt = 1;
    while (t < ns - 1) {
        // compute normalized fluctuation correlation function at lag t
        c = 0.0;
        for (i = t0; i < n - t; ++i)
            c += (a[i] - mean_s) * (a[i + t] - mean_s);
        c /= (ns - t) * var_s;

        // terminate if c has crossed the threshold C_THR
        if (c < C_THR)
            break;

        // accumulate contribution to the correlation time
        tau += (1 - (double)t / ns) * c;
        t += dt++; // increment the spacing as you move towards smaller c
    }

    return 1 + 2 * tau;
}

int eq_time(double *a, int n, int n_skip)
{
    double g, n_eff, max_n_eff = 0.0;
    int t0, best_t0 = 0;
    for (t0 = 0; t0 < n - 1; t0 += n_skip) {
        // compute stat. ineff. and # of uncorrelated samples
        g = stat_ineff(a, n, t0);
        n_eff = (n - t0 + 1) / g;

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
