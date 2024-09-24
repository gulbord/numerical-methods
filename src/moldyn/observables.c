#include "observables.h"
#include <math.h>
#include <string.h>

void update_obs(struct observables *obs, const struct particle *particles,
                const struct parameters *params,
                double compute_potential_r2(double, const struct parameters *))
{
    // Reset everything
    obs->kin_energy = 0.0;
    obs->pot_energy = 0.0;
    memset(obs->rdf, 0, params->rdf_num_bins * sizeof(*obs->rdf));

    for (int i = 0; i < params->num_particles - 1; ++i) {
        for (int k = 0; k < 3; ++k)
            obs->kin_energy += particles[i].v[k] * particles[i].v[k];

        for (int j = i + 1; j < params->num_particles; ++j) {
            double r2 = 0.0;
            for (int k = 0; k < 3; ++k) {
                double dr = particles[i].x[k] - particles[j].x[k];
                dr -= params->box_size * round(dr / params->box_size);
                r2 += dr * dr;
            }

            obs->pot_energy += compute_potential_r2(r2, params);

            double r = sqrt(r2);
            if (r < params->rdf_max_radius)
                obs->rdf[(int)(r / params->rdf_binwidth)] += 2.0;
        }
    }

    // Add the last particle's kinetic energy
    int last = params->num_particles - 1;
    for (int i = 0; i < 3; ++i)
        obs->kin_energy += particles[last].v[i] * particles[last].v[i];

    // Normalize the radial distribution function
    double k = 3.0 / (4.0 * M_PI * params->density * params->num_particles *
                      pow(params->rdf_binwidth, 3));
    for (int i = 0; i < params->rdf_num_bins; ++i)
        obs->rdf[i] *= k / (3 * i * i + 3 * i + 1);

    obs->temperature = obs->kin_energy / (3.0 * params->num_particles);
    obs->kin_energy /= 2.0 * params->num_particles;
    obs->pot_energy /= params->num_particles;
}
