#ifndef PARAMETERS_H
#define PARAMETERS_H

struct parameters {
    int num_particles;
    double box_size;
    double disp_max;
    double temperature;
    int mc_steps;
};

int parse_config(const char *filename, struct parameters *params);

#endif
