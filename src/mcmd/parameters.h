#ifndef PARAMETERS_H
#define PARAMETERS_H

#define LINE_BUFSIZ 256
#define TOKEN_BUFSIZ 64

struct parameters {
    int num_particles;
    double box_size;
    double density;
    double temperature;
    double rdf_max_radius;
    int rdf_num_bins;
    double rdf_binwidth;
    double r_cut;
    double max_disp;
    double step_size;
    int num_steps;
    int num_eq_steps;
    int thinning;
    int num_realizations;
    char init_conf[TOKEN_BUFSIZ];
    char eq_type[TOKEN_BUFSIZ];
};

int parse_config(const char *filename, struct parameters *params);

#endif
