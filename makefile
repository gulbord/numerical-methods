CC := gcc
CFLAGS := -O3 -Wall -Wextra

SRC := src
EXE := exe

RNG := $(SRC)/utils/random.c

all: 1 2 7 8

clean:
	rm -f $(EXE)/*

1: 11 12 13 14

11: 11a 11b

11a: $(SRC)/011a_rect_hit_miss.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/011a_rect_hit_miss

11b: $(SRC)/011b_disk_hit_miss.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/011b_disk_hit_miss

12: $(SRC)/012_inversion_power34.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/012_inversion_power34

13: $(SRC)/013_inversion_power2.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/013_inversion_power2

14: 14a 14b 14c

14a: $(SRC)/014a_inversion_exp.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/014a_inversion_exp

14b: $(SRC)/014b_inversion_exp2.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/014b_inversion_exp2

14c: $(SRC)/014c_inversion_powerlaw.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/014c_inversion_powerlaw

2: 21 22 23

21: $(SRC)/021_disk_sampling.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/021_disk_sampling

22: $(SRC)/022_box_muller.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/022_box_muller

23: 23a 23b

23a: $(SRC)/023a_rejection_sampling.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/023a_rejection_sampling

23b: $(SRC)/023b_rejection_accratio.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/023b_rejection_accratio

7: 71 72

71: $(SRC)/071_lotka_volterra.c $(SRC)/ctmp/gillespie.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/071_lotka_volterra

72: $(SRC)/072_brusselator.c $(SRC)/ctmp/gillespie.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/072_brusselator

8: 82 83

82: $(SRC)/082_off_lattice_mc.c $(SRC)/off-lattice/monte_carlo.c \
	$(SRC)/off-lattice/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/082_off_lattice_mc

83: $(SRC)/083_hard_spheres.c $(SRC)/off-lattice/monte_carlo.c \
	$(SRC)/off-lattice/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/083_hard_spheres

.PHONY: all clean
