#!/bin/bash

# 09.04.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Using Qiime 1 biom files to create network graphics table for input to
#  Cytoscape.

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    qiime() { qiime2cli "$@"; }
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    cores='2'
fi

# Define input paths and parameters for Qiime script 
# ----------------------------------------------
# find all .biom files incl. their paths and put them into an array
#   see https://stackoverflow.com/questions/23356779/how-can-i-store-find-command-result-as-arrays-in-bash
biom_files=()
while IFS=  read -r -d $'\0'; do
    biom_files+=("$REPLY")
done < <(find "$trpth"/"Zenodo/Qiime" -type f \( -iname "features-tax-meta.biom" \) -print0)

# mapping file (Qiime 1 compatible) 
map_file='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# loop over array of fasta files, create result directory, call blast
# ----------------------------------------------------------------
for biom_file in "${biom_files[@]}";do
  
  # for debugging only
  # printf "$biom_file\n"
  
  # create result folders names
  filename=$(dirname "$biom_file")
  src_dir=$(basename "$filename")
  tgt_dir="260${src_dir:3}_network"
  
  # for debugging only 
  # printf "$trpth"/Zenodo/Qiime/"$tgt_dir\n"
  
  # get networks
  make_bipartite_network.py \
    -i "$biom_file" \
    -m "$trpth"/"$map_file" \
    -o "$trpth"/Zenodo/Qiime/"$tgt_dir" \
    -k taxonomy --md_fields 'k,p,c,o,f' \
    || { echo 'command failed' ; exit 1; }

done
