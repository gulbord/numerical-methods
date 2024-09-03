#!/bin/bash

lat_sides=(10 14 20 28 40 50)

num_steps=1000000
Tc=$(echo "2 / l(1 + sqrt(2))" | bc -l)

for L in "${lat_sides[@]}"; do
  echo "Running Metropolis for L = $L"
  exe/051_ising_metropolis acor_L${L} ${L} ${Tc} ${num_steps}
  
  echo "Running Wolff for L = $L"
  exe/061_ising_wolff acor_L${L} ${L} ${Tc} ${num_steps}
done
