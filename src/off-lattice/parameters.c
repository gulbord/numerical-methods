#include "parameters.h"
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

    // Read line by line and split key-value pairs by whitespace
    char line[255];
    while (fgets(line, sizeof(line), file)) {
        char key[50], value[50];
        if (sscanf(line, "%s %s", key, value) == 2) {
            if (strcmp(key, "num_particles") == 0)
                params->num_particles = atoi(value);
            else if (strcmp(key, "box_size") == 0)
                params->box_size = atof(value);
            else if (strcmp(key, "disp_max") == 0)
                params->disp_max = atof(value);
            else if (strcmp(key, "temperature") == 0)
                params->temperature = atof(value);
            else if (strcmp(key, "mc_steps") == 0)
                params->mc_steps = atoi(value);
        }
    }

    fclose(file);

    return 0;
}
