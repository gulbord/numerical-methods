CC := gcc
CFLAGS := -O3 -Wall -Wextra

SRC := src
EXE := exe
LIB := lib

PRNG := $(LIB)/mt19937ar.c

all: 1

clean:
	rm -f $(EXE)/*

1:

		
.PHONY: all clean
