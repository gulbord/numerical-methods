#include "gillespie.h"
#include "../utils/random.h"
#include <math.h>

#define TAU_EPS 1e-9

void gillespie(int *pops, int n_pops, reac_ptr *reactions, int n_reac,
               rate_ptr *rates, double *k, double max_time, FILE *file)
{
    // Rate array to be updated at every iteration
    double w[n_reac];
    double time = 0.0;

    fprintf(file, "%f,", time);
    for (int i = 0; i < n_pops; ++i)
        fprintf(file, "%d%c", pops[i], i + 1 == n_pops ? '\n' : ',');

    int pop_left = 0, one_left = 0;
    while (time < max_time) {
        // Calculate the escape rate by looping over rate functions
        double esc_rate = 0.0;
        for (int i = 0; i < n_reac; ++i) {
            w[i] = rates[i](k, pops);
            esc_rate += w[i];
        }

        // Calculate the residence time and check if we are past the maximum
        double tau = -log(1.0 - rng_real()) / esc_rate;
        time += tau;
        if (time > max_time)
            break;

        // If there is only one population left, check if tau is not too small
        if (!one_left) {
            pop_left = 0;
            for (int i = 0; i < n_pops; ++i)
                pop_left += pops[i] > 0;
            one_left = pop_left == 1;
        } else if (tau < TAU_EPS)
            break;

        // Pick a reaction with probability ~ rate_i / esc_rate
        double thr = rng_real() * esc_rate;
        double sum = 0.0;
        int pick = n_reac - 1; // If you never reach thr, pick the last
        for (int i = 0; i < n_reac; ++i) {
            sum += w[i];
            if (sum > thr) {
                pick = i;
                break;
            }
        }

        // Update the state according to the chosen reaction
        reactions[pick](pops);
        fprintf(file, "%f,", time);
        for (int i = 0; i < n_pops; ++i)
            fprintf(file, "%d%c", pops[i], i + 1 == n_pops ? '\n' : ',');
    }
}
