#ifndef XOSHIRO256PLUSPLUS_H
#define XOSHIRO256PLUSPLUS_H

#include <stdint.h>

void set_seed(uint64_t* seed);
uint64_t next(void);
void jump(void);
void long_jump(void);

// calls next() and convert the resulting uint64_t to [0, 1) double
static inline double u01(void) { return (next() >> 11) * 0x1.0p-53; }

#endif
