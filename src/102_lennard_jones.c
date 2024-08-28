#include "moldyn/observables.h"
#include "utils/progress.h"
#include "utils/random.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N_ARGS 3

double compute_energy_delta(int pick, const double *trial,
                            const struct particle *particles,
                            const struct parameters *params)
{
    double delta = 0.0;

    for (int i = 0; i < params->num_particles; ++i) {
        if (i == pick)
            continue;

        double old_r2 = 0.0;
        double new_r2 = 0.0;
        for (int j = 0; j < 3; ++j) {
            double old_dr = particles[pick].x[j] - particles[i].x[j];
            old_dr -= params->box_size * round(old_dr / params->box_size);
            old_r2 += old_dr * old_dr;

            double new_dr = trial[j] - particles[i].x[j];
            new_dr -= params->box_size * round(new_dr / params->box_size);
            new_r2 += new_dr * new_dr;
        }

        if (old_r2 > params->r_cut && new_r2 > params->r_cut)
            continue;

        double old_energy, new_energy;
        if (old_r2 < params->r_cut) {
            double old_inv_r6 = 1.0 / (old_r2 * old_r2 * old_r2);
            old_energy = old_inv_r6 * old_inv_r6 - old_inv_r6;
        } else
            old_energy = 0.0;

        if (new_r2 < params->r_cut) {
            double new_inv_r6 = 1.0 / (new_r2 * new_r2 * new_r2);
            new_energy = new_inv_r6 * new_inv_r6 - new_inv_r6;
        } else
            new_energy = 0.0;

        delta += new_energy - old_energy;
    }

    return 4.0 * delta;
}

void compute_forces(struct particle *particles, const struct parameters *params)
{
    for (int i = 0; i < params->num_particles; ++i)
        for (int j = 0; j < 3; ++j)
            particles[i].f[j] = 0.0;

    double r[3];
    double r_cut2 = params->r_cut * params->r_cut;

    for (int i = 0; i < params->num_particles - 1; ++i) {
        for (int j = i + 1; j < params->num_particles; ++j) {
            double r2 = 0.0;
            for (int k = 0; k < 3; ++k) {
                r[k] = particles[i].x[k] - particles[j].x[k];
                r[k] -= params->box_size * round(r[k] / params->box_size);
                r2 += r[k] * r[k];
            }

            if (r2 > r_cut2)
                continue;

            double inv_r2 = 1.0 / r2;
            double inv_r6 = inv_r2 * inv_r2 * inv_r2;
            // f_r is |F| divided by |r|, so times r[k] we get the versor
            double f_r = 48.0 * inv_r2 * (inv_r6 * inv_r6 - 0.5 * inv_r6);
            for (int k = 0; k < 3; ++k) {
                particles[i].f[k] += f_r * r[k];
                particles[j].f[k] -= f_r * r[k];
            }
        }
    }
}

double compute_potential_r2(double r2, const struct parameters *params)
{
    if (r2 > params->r_cut * params->r_cut)
        return 0.0;

    double inv_r2 = 1.0 / r2;
    double inv_r6 = inv_r2 * inv_r2 * inv_r2;

    return 4.0 * (inv_r6 * inv_r6 - inv_r6);
}

int main(int argc, const char **argv)
{
    if (argc != N_ARGS) {
        fprintf(stderr, "Wrong number of arguments! (Should be %d)\n", N_ARGS);
        fprintf(stderr,
                "[executable] [configuration file] [output file prefix]\n");
        return 1;
    }

    rng_set_seed(time(NULL));

    struct parameters params;
    if (parse_config(argv[1], &params))
        return 1;

    char fname_ene[255];
    char fname_rdf[255];
    snprintf(fname_ene, sizeof(fname_ene), "out/102_%s_obs.csv", argv[2]);
    snprintf(fname_rdf, sizeof(fname_rdf), "out/102_%s_rdf.csv", argv[2]);

    FILE *file_ene = fopen(fname_ene, "w");
    FILE *file_rdf = fopen(fname_rdf, "w");
    if (file_ene == NULL || file_rdf == NULL) {
        perror("fopen() failed");
        return 1;
    }

    fprintf(file_ene, "realization,sample,temperature,kin_energy,pot_energy\n");
    fprintf(file_rdf, "realization,sample,radius,rdf\n");

    struct particle *particles =
        malloc(params.num_particles * sizeof(*particles));
    struct observables *obs = malloc(sizeof(*obs));
    obs->rdf = malloc(params.rdf_num_bins * sizeof(*obs->rdf));

    // Pre-compute the tail correction to the potential
    double utail = (8.0 * M_PI / 9.0) * params.density *
                   (1.0 / pow(params.r_cut, 9) - 3.0 / pow(params.r_cut, 3));

    for (int r = 1; r <= params.num_realizations; ++r) {
        printf("\rRealization %d/%d\n", r, params.num_realizations);

        initialize(particles, &params);
        equilibrate(particles, &params, &compute_energy_delta, &compute_forces);

        int s = 0;
        for (int t = 0; t < params.num_steps; ++t) {
            print_progress(t + 1, params.num_steps);
            step(particles, &params, &compute_forces);

            if (t % params.thinning == 0) {
                ++s;
                update_obs(obs, particles, &params, &compute_potential_r2);
                fprintf(file_ene, "%d,%d,%g,%g,%g\n", r, s, obs->temperature,
                        obs->kin_energy, obs->pot_energy + utail);
                for (int i = 0; i < params.rdf_num_bins; ++i)
                    fprintf(file_rdf, "%d,%d,%g,%g\n", r, s,
                            (i + 0.5) * params.rdf_binwidth, obs->rdf[i]);
            }
        }

        printf("\r\033[K\033[F"); // After progress bar
    }

    free(obs->rdf);
    free(obs);
    free(particles);

    fclose(file_ene);
    fclose(file_rdf);

    return 0;
}
