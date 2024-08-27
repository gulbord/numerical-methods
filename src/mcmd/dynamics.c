#include "dynamics.h"
#include "../utils/random.h"
#include <math.h>
#include <stdio.h>
#include <string.h>

void initialize(struct particle *particles, const struct parameters *params)
{
    if (strcmp(params->init_conf, "random") == 0) {
        for (int i = 0; i < params->num_particles; ++i)
            for (int j = 0; j < 3; ++j)
                particles[i].x[j] = rng_real() * params->box_size;
    } else if (strcmp(params->init_conf, "cubic") == 0) {
        // Number of particles in each direction
        int n = ceil(cbrt(params->num_particles));
        int spacing = params->box_size / n;
        int assigned = 0;
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < n; ++j) {
                for (int k = 0; k < n; ++k) {
                    if (assigned < params->num_particles) {
                        particles[assigned].x[0] = (i + 0.5) * spacing;
                        particles[assigned].x[1] = (j + 0.5) * spacing;
                        particles[assigned].x[2] = (k + 0.5) * spacing;
                        ++assigned;
                    } else
                        break;
                }
            }
        }
    }
}

void equilibrate(struct particle *particles, const struct parameters *params,
                 double compute_energy_delta(int, const double *,
                                             const struct particle *,
                                             const struct parameters *),
                 void compute_forces(struct particle *,
                                     const struct parameters *))
{
    if (strcmp(params->eq_type, "mc")) {
        double trial[3];
        for (int t = 0; t < params->num_particles * params->num_eq_steps; ++t) {
            int pick = rng_int_n(params->num_particles);
            for (int i = 0; i < 3; ++i) {
                trial[i] = particles[pick].x[i];
                trial[i] += (2.0 * rng_real() - 1.0) * params->max_disp;
                trial[i] -=
                    params->box_size * floor(trial[i] / params->box_size);
            }

            double delta = compute_energy_delta(pick, trial, particles, params);
            if (delta < 0.0 || rng_real() < exp(-delta / params->temperature))
                memcpy(particles[pick].x, trial, 3 * sizeof(double));
        }
    } else if (strcmp(params->eq_type, "md")) {
        for (int t = 0; t < params->num_eq_steps; ++t)
            step(particles, params, compute_forces);
    }

    // Initialize velocities with Maxwell-Boltzmann
    double v_tot[3] = {0.0, 0.0, 0.0};
    double sigma_mb = sqrt(params->temperature);
    for (int i = 0; i < params->num_particles; ++i) {
        for (int j = 0; j < 3; ++j) {
            double v = sigma_mb * rng_gauss();
            particles[i].v[j] = v;
            v_tot[j] += v;
        }
    }

    // Normalize total momentum and subtract it from each velocity
    for (int i = 0; i < 3; ++i)
        v_tot[i] /= params->num_particles;

    for (int i = 0; i < params->num_particles; ++i)
        for (int j = 0; j < 3; ++j)
            particles[i].v[j] -= v_tot[j];
}

void step(struct particle *particles, const struct parameters *params,
          void compute_forces(struct particle *, const struct parameters *))
{
    for (int i = 0; i < params->num_particles; ++i) {
        for (int j = 0; j < 3; ++j) {
            particles[i].v[j] += 0.5 * particles[i].f[j] * params->step_size;
            particles[i].x[j] += particles[i].v[j] * params->step_size;
        }
    }

    compute_forces(particles, params);

    for (int i = 0; i < params->num_particles; ++i)
        for (int j = 0; j < 3; ++j)
            particles[i].v[j] += 0.5 * particles[i].f[j] * params->step_size;
}
