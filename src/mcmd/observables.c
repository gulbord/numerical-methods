#include "observables.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>

void alloc_obs(struct observables *obs, const struct parameters *params)
{
    obs->rdf = malloc(params->rdf_num_bins * sizeof(*obs->rdf));
}

void update_obs(struct observables *obs, const struct particle *particles,
                const struct parameters *params,
                const double *compute_potential_r2(double,
                                                   const struct particle *,
                                                   const struct parameters *))
{
    // Reset everything
    obs.kin_energy = 0.0;
    obs.pot_energy = 0.0;
    memset(obs.rdf, 0, params->rdf_num_bins * sizeof(*obs->rdf));

    // Rdf normalization constant
    double k = 3.0 / (4.0 * M_PI * params->density * params->num_particles *
                      pow(params->rdf_binwidth, 3));

    for (int i = 0; i < params->num_particles - 1; ++i) {
        for (int j = i + 1; j < params->num_particles; ++j) {
            double r2 = 0.0;
            for (int k = 0; k < 3; ++k) {
                double dr = particles[i].x[k] - particles[j].x[k];
                dr -= params->box_size * round(dr / params->box_size);
                r2 += dr * dr;
            }

            obs.pot_energy = compute_potential_r2(r2, particles, params);

            // Update rdf
            double r = sqrt(r2);
            if (r < params->rdf_max_radius) {
                int bin = (int)(r / params->rdf_binwidth);
                int bin_vol = 3 * bin * bin + 3 * bin + 1;
                obs.rdf[bin] += 2.0 * k / bin_vol;
            }
        }
    }
}

void free_obs(struct observables *obs) { free(obs->rdf); }
