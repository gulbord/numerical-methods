#include "../lib/RngStream.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main()
{
    unsigned long seed = (unsigned long)time(NULL);

    // use the above seed to generate the other 5 needed
    int i;
    unsigned long vseed[6];
    for (i = 0; i < 6; ++i)
        vseed[i] = seed + i * 2473;

    // set the seed
    RngStream_SetPackageSeed(vseed);
    // start the rng and let it run for some steps
    RngStream rngs = RngStream_CreateStream("A01b");
    for (i = 0; i < 1000; ++i)
        RngStream_RandU01(rngs);

    int n;
    int n_plot = 1000; // # of different max_iter to analyse
    int dn = 100;
    int hits, throws;
    double x, y;
    double mc_pi;
    FILE* file = fopen("out/A01b.txt", "w");

    for (n = 0; n < n_plot; ++n) {
        hits = 0; // reset hit counter
        throws = (1 + n) * dn;
        for (i = 0; i < throws; ++i) {
            x = RngStream_RandU01(rngs);
            y = RngStream_RandU01(rngs);
            if (x * x + y * y < 1)
                ++hits;
        }
        mc_pi = 4 * (double)hits / throws;

        // write to file: throws + \t + relative error + \n
        fprintf(file, "%d\t", throws);
        fprintf(file, "%g\n", fabs(1 - mc_pi * M_1_PI));
    }

    fclose(file);

    return 0;
}
