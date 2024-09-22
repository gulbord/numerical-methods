CC := gcc
CFLAGS := -O3 -Wall -Wextra

SRC := src
EXE := exe

RNG := $(SRC)/utils/random.c

all: 1 2 3 5 6 7 8 9 10

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

3: 31 32

31: $(SRC)/031_crude_vs_importance.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/031_crude_vs_importance

32: $(SRC)/032_cosx_importance.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/032_cosx_importance

5: 51

51: $(SRC)/051_ising_metropolis.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/051_ising_metropolis

6: 61 62

61: $(SRC)/061_ising_wolff.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/061_ising_wolff

62: $(SRC)/062_ising_mmc.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/062_ising_mmc

7: 71 72

71: $(SRC)/071_lotka_volterra.c $(SRC)/ctmp/gillespie.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/071_lotka_volterra

72: $(SRC)/072_brusselator.c $(SRC)/ctmp/gillespie.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/072_brusselator

8: 82 83 84

82: $(SRC)/082_off_lattice_mc.c $(SRC)/offlat/integration.c \
	$(SRC)/offlat/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/082_off_lattice_mc

83: $(SRC)/083_hard_spheres.c $(SRC)/offlat/integration.c \
	$(SRC)/offlat/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/083_hard_spheres

84: $(SRC)/084_lennard_jones.c $(SRC)/offlat/integration.c \
	$(SRC)/offlat/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/084_lennard_jones

9: 91 92

91: $(SRC)/091_first_order.c
	$(CC) $(CFLAGS) $^ -o $(EXE)/091_first_order

92: $(SRC)/092_higher_order.c
	$(CC) $(CFLAGS) $^ -o $(EXE)/092_higher_order

10: 102

102: $(SRC)/102_lennard_jones.c $(SRC)/moldyn/integration.c \
	$(SRC)/moldyn/observables.c $(SRC)/moldyn/parameters.c \
	$(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/102_lennard_jones

.PHONY: all clean
