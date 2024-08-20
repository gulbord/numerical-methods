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
    char line[LINE_BUFSIZ], tmp[LINE_BUFSIZ];
    while (fgets(line, sizeof(line), file)) {
        char key[50], value[50];
        if (sscanf(line, "%s", tmp) == EOF)
            continue; // Blank line
        else if (sscanf(line, "%[#]", tmp) == 1)
            continue; // Comment
        else if (sscanf(line, "%s %s", key, value) == 2) {
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
            else if (strcmp(key, "init_type") == 0)
                strcpy(params->init_type, value); // Same buffer size
        }
    }

    fclose(file);

    return 0;
}
