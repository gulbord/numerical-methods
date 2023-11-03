#ifndef XOSHIRO256PLUSPLUS_H
#define XOSHIRO256PLUSPLUS_H

#include <stdint.h>

void set_seed(uint64_t seed);
uint64_t next(void);
void jump(void);
void long_jump(void);

#endif
