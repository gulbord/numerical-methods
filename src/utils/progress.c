#include "progress.h"
#include <stdio.h>

#define PBAR_STR "============================================================"
#define PBAR_WIDTH 60

void print_progress(double percentage)
{
    int val = (int)(percentage * 100);
    int lpad = (int)(percentage * PBAR_WIDTH);
    int rpad = PBAR_WIDTH - lpad - 1;
    if (percentage < 1.0)
        printf("\r%3d%% [%.*s>%*s]", val, lpad, PBAR_STR, rpad, "");
    else
        printf("\r%3d%% [%.*s]", val, lpad + 1, PBAR_STR);
    fflush(stdout);
}
