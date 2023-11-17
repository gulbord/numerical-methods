#ifndef LATTICE_H
#define LATTICE_H

typedef struct {
    int side;
    int* spins;
    int* nbrs[4]; // nearest neighbours of each spin
} Lattice;

void init_lattice(Lattice* lat, int l_siz);
void free_lattice(Lattice* lat);

#endif
