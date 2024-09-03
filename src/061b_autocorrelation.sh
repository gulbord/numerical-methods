#!/bin/bash

lat_sides=(10 14 20 28 40 50)

num_steps=50000
Tc=$(echo "2 / l(1 + sqrt(2))" | bc -l)

for L in "${lat_sides[@]}"; do
  echo "Running Metropolis for L = $L"
  metropolis_steps=$(echo "$num_steps * $L * $L" | bc)
  min_steps=$(echo "10000000 < $metropolis_steps" | bc)
  if [ $min_steps -eq 1 ]; then
    metropolis_steps=10000000
  fi
  exe/051_metropolis "acor_L$L" $L $L $Tc $metropolis_steps
  
  echo "Running Wolff for L = $L"
  exe/061_wolff "acor_L$L" $L $L $Tc $num_steps
done
