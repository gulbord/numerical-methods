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
    params->box_size = -1;
    params->density = -1;
    params->temperature = -1;
    params->max_disp = -1;
    params->num_steps = 1000;
    params->num_realizations = 1;
    strcpy(params->init_conf, "random");

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
        else if (strcmp(key, "max_disp") == 0)
            params->max_disp = atof(value);
        else if (strcmp(key, "num_steps") == 0)
            params->num_steps = atoi(value);
        else if (strcmp(key, "num_realizations") == 0)
            params->num_realizations = atoi(value);
        else if (strcmp(key, "init_conf") == 0)
            strcpy(params->init_conf, value); // Same buffer size
    }

    if (params->temperature < 0) {
        fprintf(stderr, "Provide a valid temperature value.\n");
        fclose(file);
        return 1;
    }

    if (params->max_disp < 0) {
        fprintf(stderr, "Provide a valid max_disp value.\n");
        fclose(file);
        return 1;
    }

    // Complete num_particles, box_size and density
    double volume;
    int provided = (params->num_particles > 0) + (params->box_size > 0.0) +
                   (params->density > 0.0);
    if (provided < 2) {
        fprintf(stderr, "Two values between num_particles, box_size, and "
                        "density need to be provided!\n");
        fclose(file);
        return 1;
    }

    if (params->num_particles < 0) { // Calculate num_particles
        volume = pow(params->box_size, 3);
        params->num_particles = round(params->density * volume);
    } else if (params->box_size < 0.0) { // Calculate box_size
        volume = params->num_particles / params->density;
        params->box_size = cbrt(volume);
    } else { // Calculate density
        volume = pow(params->box_size, 3);
        params->density = params->num_particles / volume;
    }

    fclose(file);

    return 0;
}
