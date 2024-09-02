#!/bin/bash

cat <<EOL > src/083.cfg
num_particles 100
density 0.1
max_disp 0.1
temperature 1
num_steps 100000
num_realizations 10
init_conf random
EOL

densities=(0.05 0.3 0.5 1)
max_disps=(0.01 0.1 0.3 0.6 1)

for rho in "${densities[@]}"; do
  for dmax in "${max_disps[@]}"; do
    echo "Processing density = $rho, max_disp = $dmax"

    sed -i "s/density .*/density $rho/" src/083.cfg
    sed -i "s/max_disp .*/max_disp $dmax/" src/083.cfg

    sed -i "s/init_conf .*/init_conf random/" src/083.cfg
    exe/083_hard_spheres src/083.cfg r${rho}_d${dmax}_random

    sed -i "s/init_conf .*/init_conf lattice/" src/083.cfg
    exe/083_hard_spheres src/083.cfg r${rho}_d${dmax}_lattice
  done
done
