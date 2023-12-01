CC := gcc
CFLAGS := -O3 -Wall -Wextra

SRC := src
EXE := exe
LIB := lib

PRNG := $(LIB)/mt19937ar.c

all: 6a 7a

clean:
	rm -f $(EXE)/*

6a: $(SRC)/06a_metropolis.c $(SRC)/ising/lattice.c $(SRC)/ising/metropolis.c \
		$(SRC)/utils/correlations.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/06a_metropolis

7a: $(SRC)/07a_wolff.c $(SRC)/ising/wolff.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/07a_wolff

8a: $(SRC)/08a_lotka_volterra.c $(SRC)/ctmp/gillespie.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/08a_lotka_volterra

8b: $(SRC)/08b_brusselator.c $(SRC)/ctmp/gillespie.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/08b_brusselator
		
.PHONY: all clean
