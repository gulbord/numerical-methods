CC := gcc
CFLAGS := -O3 -Wall -Wextra

SRC := src
EXE := exe

RNG := $(SRC)/utils/random.c

all: 01 02 03 05 06 07 08 09 10 12

clean:
	rm -f $(EXE)/*

01: 011 012 013 014

011: 011a 011b

011a: $(SRC)/011a_rect_hit_miss.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/011a_rect_hit_miss

011b: $(SRC)/011b_disk_hit_miss.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/011b_disk_hit_miss

012: $(SRC)/012_inversion_power34.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/012_inversion_power34

013: $(SRC)/013_inversion_power2.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/013_inversion_power2

014: 014a 014b 014c

014a: $(SRC)/014a_inversion_exp.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/014a_inversion_exp

014b: $(SRC)/014b_inversion_exp2.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/014b_inversion_exp2

014c: $(SRC)/014c_inversion_powerlaw.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/014c_inversion_powerlaw

02: 021 022 023

021: $(SRC)/021_disk_sampling.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/021_disk_sampling

022: $(SRC)/022_box_muller.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/022_box_muller

023: 023a 023b

023a: $(SRC)/023a_rejection_sampling.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/023a_rejection_sampling

023b: $(SRC)/023b_rejection_accratio.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/023b_rejection_accratio

03: 031 032

031: $(SRC)/031_crude_vs_importance.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/031_crude_vs_importance

032: $(SRC)/032_cosx_importance.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/032_cosx_importance

05: 051

051: $(SRC)/051_ising_metropolis.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/051_ising_metropolis

06: 061 062

061: $(SRC)/061_ising_wolff.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/061_ising_wolff

062: $(SRC)/062_ising_mmc.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/062_ising_mmc

07: 071 072

071: $(SRC)/071_lotka_volterra.c $(SRC)/ctmp/gillespie.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/071_lotka_volterra

072: $(SRC)/072_brusselator.c $(SRC)/ctmp/gillespie.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/072_brusselator

08: 082 083 084

082: $(SRC)/082_off_lattice_mc.c $(SRC)/offlat/integration.c \
	$(SRC)/offlat/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/082_off_lattice_mc

083: $(SRC)/083_hard_spheres.c $(SRC)/offlat/integration.c \
	$(SRC)/offlat/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/083_hard_spheres

084: $(SRC)/084_lennard_jones.c $(SRC)/offlat/integration.c \
	$(SRC)/offlat/parameters.c $(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/084_lennard_jones

09: 091 092

091: $(SRC)/091_first_order.c
	$(CC) $(CFLAGS) $^ -o $(EXE)/091_first_order

092: $(SRC)/092_higher_order.c
	$(CC) $(CFLAGS) $^ -o $(EXE)/092_higher_order

10: 102

102: $(SRC)/102_lennard_jones.c $(SRC)/moldyn/integration.c \
	$(SRC)/moldyn/observables.c $(SRC)/moldyn/parameters.c \
	$(SRC)/utils/progress.c $(RNG)
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/102_lennard_jones

12: 123

123: $(SRC)/123_mhm_partition.c
	$(CC) $(CFLAGS) $^ -lm -o $(EXE)/123_mhm_partition

.PHONY: all clean
