# datasets download genome taxon "taxon name" --reference
# unzip ncbi_dataset.zip
# find ncbi_dataset/ -name "*.fna" -exec mv {} bact/taxon_name.fa \;
# rm -rf ncbi_dataset*  README.md md5sum.txt 

#!/bin/bash

# List of taxon names
taxa=(
  "Streptosporangium roseum"
  "Clostridium botulinum"
  "Salmonella enterica"
  "Parvimonas micra"
  "Sorangium cellulosum"
  "Nocardia brasiliensis"
  "Bradyrhizobium erythrophlei"
  "Mycolicibacterium aurum"
  "Yersinia pestis"
  "Neisseria meningitidis"
  "Enterococcus faecalis"
  "Rothia dentocariosa"
  "Mycobacterium avium"
  "Ralstonia solanacearum"
  "Streptococcus pyogenes"
  "Campylobacter rectus"
  "Treponema denticola"
  "Prosthecobacter vanneervenii"
)

for taxon in "${taxa[@]}"; do

  outfile=$(echo "$taxon" | sed 's/ /_/g').fa

  datasets download genome taxon "$taxon" --reference
  unzip -q ncbi_dataset.zip
  fna_file=$(find ncbi_dataset/ -name "*.fna" | head -n 1)

  if [[ -f "$fna_file" ]]; then
    mv "$fna_file" "bact/$outfile"
    echo "Saved as: bact/$outfile"
  else
    echo "Genome not found for $taxon"
  fi

  rm -rf ncbi_dataset* README.md md5sum.txt
done
