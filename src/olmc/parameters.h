#ifndef PARAMETERS_H
#define PARAMETERS_H

#define LINE_BUFSIZ 256
#define TOKEN_BUFSIZ 64

struct parameters {
    int num_particles;
    double box_size;
    double density;
    double disp_max;
    double temperature;
    int mc_steps;
    int realizations;
    char init_type[TOKEN_BUFSIZ];
};

int parse_config(const char *filename, struct parameters *params);

#endif
