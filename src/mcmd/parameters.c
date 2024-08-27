#include "parameters.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int parse_config(const char *filename, struct parameters *params)
{
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("fopen() failed");
        return 1;
    }

    // Provide default values
    params->num_particles = -1;
    params->box_size = -1.0;
    params->density = -1.0;
    params->temperature = -1.0;
    params->rdf_max_radius = -1.0;
    params->rdf_num_bins = -1;
    params->rdf_binwidth = -1.0;
    params->r_cut = -1.0;
    params->max_disp = -1.0;
    params->step_size = 0.01;
    params->num_steps = 1000;
    params->num_eq_steps = 1000;
    params->thinning = 10;
    params->num_realizations = 1;
    strcpy(params->init_conf, "random");
    strcpy(params->eq_type, "md");

    // Read line by line and split key-value pairs by whitespace
    char line[LINE_BUFSIZ];
    while (fgets(line, sizeof(line), file)) {
        char key[TOKEN_BUFSIZ], value[TOKEN_BUFSIZ];

        if (sscanf(line, "%s %s", key, value) != 2)
            continue;

        if (strcmp(key, "num_particles") == 0)
            params->num_particles = atoi(value);
        else if (strcmp(key, "box_size") == 0)
            params->box_size = atof(value);
        else if (strcmp(key, "density") == 0)
            params->density = atof(value);
        else if (strcmp(key, "temperature") == 0)
            params->temperature = atof(value);
        else if (strcmp(key, "rdf_max_radius") == 0)
            params->rdf_max_radius = atof(value);
        else if (strcmp(key, "rdf_num_bins") == 0)
            params->rdf_num_bins = atoi(value);
        else if (strcmp(key, "rdf_binwidth") == 0)
            params->rdf_binwidth = atof(value);
        else if (strcmp(key, "r_cut") == 0)
            params->r_cut = atof(value);
        else if (strcmp(key, "max_disp") == 0)
            params->max_disp = atof(value);
        else if (strcmp(key, "step_size") == 0)
            params->step_size = atof(value);
        else if (strcmp(key, "num_steps") == 0)
            params->num_steps = atoi(value);
        else if (strcmp(key, "num_eq_steps") == 0)
            params->num_eq_steps = atoi(value);
        else if (strcmp(key, "thinning") == 0)
            params->thinning = atoi(value);
        else if (strcmp(key, "num_realizations") == 0)
            params->num_realizations = atoi(value);
        else if (strcmp(key, "init_conf") == 0)
            strcpy(params->init_conf, value);
        else if (strcmp(key, "eq_type") == 0)
            strcpy(params->eq_type, value);
    }

    if (params->temperature < 0.0) {
        fprintf(stderr, "Provide a valid temperature value.\n");
        fclose(file);
        return 1;
    }

    if (params->num_eq_steps > 0 && params->max_disp < 0.0) {
        fprintf(stderr, "Provide a valid max_disp value.\n");
        fclose(file);
        return 1;
    }

    if (strcmp(params->init_conf, "random") != 0 &&
        strcmp(params->init_conf, "cubic") != 0) {
        fprintf(stderr, "Invalid init_conf value. It must be either 'random' "
                        "or 'cubic'.\n");
        fclose(file);
        return 1;
    }

    if (strcmp(params->eq_type, "md") != 0 &&
        strcmp(params->eq_type, "mc") != 0) {
        fprintf(stderr,
                "Invalid eq_type value. It must be either 'md' or 'mc'.\n");
        fclose(file);
        return 1;
    }

    // Complete num_particles, box_size and density
    int provided = (params->num_particles > 0) + (params->box_size > 0.0) +
                   (params->density > 0.0);
    if (provided < 2) {
        fprintf(stderr, "Two values between num_particles, box_size, and "
                        "density need to be provided!\n");
        fclose(file);
        return 1;
    }

    if (params->num_particles < 0) { // Calculate num_particles
        double volume = pow(params->box_size, 3);
        params->num_particles = round(params->density * volume);
    } else if (params->box_size < 0.0) { // Calculate box_size
        double volume = params->num_particles / params->density;
        params->box_size = cbrt(volume);
    } else { // Calculate density
        double volume = pow(params->box_size, 3);
        params->density = params->num_particles / volume;
    }

    // Complete rdf_num_bins, rdf_max_radius, and rdf_binwidth
    provided = (params->rdf_num_bins > 0) + (params->rdf_max_radius > 0.0) +
               (params->rdf_binwidth > 0.0);
    if (provided < 2) {
        fprintf(stderr, "Two values between rdf_num_bins, rdf_max_radius, and "
                        "rdf_binwidth need to be provided!\n");
        fclose(file);
        return 1;
    }

    if (params->rdf_num_bins < 0) // Calculate rdf_num_bins
        params->rdf_num_bins =
            (int)(params->rdf_max_radius / params->rdf_binwidth);
    else if (params->rdf_max_radius < 0.0) // Calculate rdf_max_radius
        params->rdf_max_radius = params->rdf_num_bins * params->rdf_binwidth;
    else // Calculate rdf_binwidth
        params->rdf_binwidth = params->rdf_max_radius / params->rdf_num_bins;

    fclose(file);

    return 0;
}
