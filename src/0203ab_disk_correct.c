#include "../lib/RngStream.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char* argv[]) {
    if (argc != 2) {
        printf("Wrong number of arguments!\n");
        return 1;
    }

    // set the seed
    unsigned long vseed[6] = {1234, 4321, 5678, 8765, 9898, 8989};
    RngStream_SetPackageSeed(vseed);
    // start the rng and let it run for some steps
    RngStream rngs = RngStream_CreateStream("0203aa");
    int i;
    for (i = 0; i < 1000; ++i)
        RngStream_RandU01(rngs);

    FILE* file = fopen("out/0203ab.txt", "w");

    int n_smp = atoi(argv[1]);
    // allocate radius and theta arrays
    double* r = malloc(n_smp * sizeof(*r));
    double* t = malloc(n_smp * sizeof(*t));
    for (i = 0; i < n_smp; ++i) {
        // sample uniformly (wrong way!)
        r[i] = sqrt(RngStream_RandU01(rngs));
        t[i] = 2 * M_PI * RngStream_RandU01(rngs);
    }

    // write the two arrays to out (in binary)
    fwrite(r, sizeof(*r), n_smp, file);
    fwrite(t, sizeof(*t), n_smp, file);

    fclose(file);
    free(r);
    free(t);

    return 0;
}
