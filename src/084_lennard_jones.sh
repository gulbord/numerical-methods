#!/bin/bash

cat <<EOL > src/084.cfg
num_particles 100
density 0.1
max_disp 0.3
temperature 1
num_steps 50000
num_realizations 10
init_conf lattice
EOL

temperatures=(0.9 2.0)
densities=(0.05 0.135 0.22 0.305 0.39 0.475 0.56 0.645 0.73 0.815 0.9)

for T in "${temperatures[@]}"; do
  for rho in "${densities[@]}"; do
    echo "Processing temperature = $T, density = $rho"

    sed -i "s/temperature .*/temperature $T/" src/084.cfg
    sed -i "s/density .*/density $rho/" src/084.cfg

    exe/084_lennard_jones src/084.cfg T${T}_r${rho}
  done
done
