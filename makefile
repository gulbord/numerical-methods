CC := gcc
CFLAGS := -O3 -Wall -Wextra

SRC := src
EXE := exe
LIB := lib

PRNG := $(LIB)/mt19937ar.c

all: 1 6a 7a 8a 8b

clean:
	rm -f $(EXE)/*

1: 11 12 13 14

11: 11a 11b

11a: $(SRC)/011a_rect_hit_miss.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/011a_rect_hit_miss

11b: $(SRC)/011b_disk_hit_miss.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/011b_disk_hit_miss

12: $(SRC)/012_inversion_power34.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/012_inversion_power34

13: $(SRC)/013_inversion_power2.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/013_inversion_power2

14: 14a 14b 14c

14a: $(SRC)/014a_inversion_exp.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/014a_inversion_exp

14b: $(SRC)/014b_inversion_exp2.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/014b_inversion_exp2

14c: $(SRC)/014c_inversion_powerinv.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/014c_inversion_powerinv

6a: $(SRC)/06a_metropolis.c $(SRC)/ising/lattice.c $(SRC)/ising/metropolis.c \
		$(SRC)/utils/correlations.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/06a_metropolis

7a: $(SRC)/07a_wolff.c $(SRC)/ising/lattice.c $(SRC)/ising/wolff.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/07a_wolff

8a: $(SRC)/08a_lotka_volterra.c $(SRC)/ctmp/gillespie.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/08a_lotka_volterra

8b: $(SRC)/08b_brusselator.c $(SRC)/ctmp/gillespie.c
	$(CC) $(CFLAGS) $^ $(PRNG) -lm -o $(EXE)/08b_brusselator
		
.PHONY: all clean
