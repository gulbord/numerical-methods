#ifndef PARAMETERS_H
#define PARAMETERS_H

#define LINE_BUFSIZ 256
#define TOKEN_BUFSIZ 32

struct parameters {
    int num_particles;
    double box_size;
    double disp_max;
    double temperature;
    int mc_steps;
    char init_type[TOKEN_BUFSIZ];
};

int parse_config(const char *filename, struct parameters *params);

#endif
