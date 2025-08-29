#!/bin/bash

endoFrac=(0.05 0.15 0.2 0.3 0.35 0.4 0.5 0.55 0.6 0.65)
contFrac=(0.25 0.15 0.1 0.2 0.15 0.1 0.1 0.15 0.1 0.05)
bactFrac=(0.7 0.7 0.7 0.5 0.5 0.5 0.4 0.3 0.3 0.3)

# Ensure files are in UNIX format
dos2unix modern_microbe_abundance.csv
dos2unix ancient_microbe_abundance.csv

for i in {0..9}
do
  col_num=$((i + 1))
  echo "########## SIMULATING SAMPLE $col_num WITH GARGAMMEL ##########"


  # Extract the first column and column named col_num (skip header)
  awk -F, -v col="$col_num" 'BEGIN{OFS="\t"} NR==1{for(i=1;i<=NF;i++){if($i==col"")c2=i}} NR>1{print $1,$c2}' ancient_microbe_abundance.csv > ancient/bact/list
  awk -F, -v col="$col_num" 'BEGIN{OFS="\t"} NR==1{for(i=1;i<=NF;i++){if($i==col"")c2=i}} NR>1{print $1,$c2}' modern_microbe_abundance.csv > modern/bact/list

  # Simulate with Gargammel
  gargammel -n 250000 --comp ${bactFrac[$i]},${contFrac[$i]},${endoFrac[$i]} -rl 125 --loc 3.7424069808 --scale 0.2795148843 -damage 0.03,0.4,0.01,0.3 -o ancient/simulation ancient/
  gargammel -n 250000 --comp ${bactFrac[$i]},${contFrac[$i]},${endoFrac[$i]} -rl 125 -f sizefreq.size.gz -o modern/simulation modern/

  # Combine ancient and modern into one sample
  cat ancient/simulation_s1.fq.gz modern/simulation_s1.fq.gz > data/sample$((i + 1)).fastq.gz
done

