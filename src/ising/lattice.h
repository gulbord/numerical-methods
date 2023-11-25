#ifndef LATTICE_H
#define LATTICE_H

struct lattice {
    int side;
    int *spins;
    int *nbrs; // nearest neighbours of each spin
};

void init_lattice(struct lattice *lat, int l_siz);
void free_lattice(struct lattice *lat);

#endif
