#!/bin/bash

# 02.04.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Converting clustering results to biom files for Qiime 1 and
# network graphics. (Trees are neglected here, they can be incorporated
# later if this is deemed desirable for clusters)

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

# Define input files
# ------------------
map_file='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# Run scripts
# ------------
shopt -s nullglob
for tab_file in $trpth/Zenodo/Qiime/210_18S_???_cl_*_tab.qza ; do
  # check if input file exists
  [ -f "$tab_file" ] || continue
    
  # get matching taxonomy filename (dependent input file, which needs to be available)
  filename=$(basename "$tab_file")
  prefix="${filename%.*}"
  prefix="220${prefix:3}"
  ### if `/Users/paul/Documents/CU_combined/Github/220_classify_clusters.sh`
  ### was run uncomment the following line and comment the line below that
  tax_file="Zenodo/Qiime/${prefix::${#prefix}-4}_tax.qza" # Bash 4: ${foo::-4}
  tax_file="Zenodo/Qiime/130_18S_taxonomy.qza"
  
  
  # check if dependent input file exists
  [ -f "$trpth"/"$tax_file" ] || continue
  
  # get matching sequence filename (dependent input file, which needs to be available)
  filename=$(basename "$tab_file")
  prefix="${filename%.*}"
  prefix="210${prefix:3}"
  seq_file="Zenodo/Qiime/${prefix::${#prefix}-4}_seq.qza" # Bash 4: ${foo::-4}
  # check if dependent input file exists
  [ -f "$trpth"/"$seq_file" ] || continue
  
  # create output directory path
  filename=$(basename "$tab_file")
  prefix="${filename%.*}"
  prefix="250${prefix:3}"
  biom_dir="Zenodo/Qiime/${prefix::${#prefix}-4}_biom_export" # Bash 4: ${foo::-4}
  
  # for debugging only: 
  
  # list being looped over
  # printf "$tab_file\n"
  
  # dependent input files
  # printf "$trpth"/"$tax_file\n"
  
  # dependent input files
  # printf "$trpth"/"$seq_file\n"

  # dependent input files
  # printf "$trpth"/"$biom_dir\n"
  
  printf "Exporting Qiime 2 files at $(date +"%T")...\n"
  qiime tools export "$tab_file" --output-dir "$trpth"/"$biom_dir" && \
  qiime tools export "$trpth"/"$seq_file" --output-dir "$trpth"/"$biom_dir" && \
  qiime tools export "$trpth"/"$tax_file" --output-dir "$trpth"/"$biom_dir" || \
  { echo 'Export failed' ; exit 1; }
 
  # Tree unzipping is not implemented
  # unzip -p "$trpth"/"$mptpth" > "$trpth"/"${clust_exp[$i]}"/"$ottre"
 
  printf "Modifying taxonomy file to match exported feature table at $(date +"%T") ...\n" && \
  new_header='#OTUID  taxonomy    confidence' && \
  sed -i.bak "1 s/^.*$/$new_header/" "$trpth"/"$biom_dir"/taxonomy.tsv || { echo 'Edit failed' ; exit 1; }
  
  printf "Adding taxonomy information to .biom file at $(date +"%T") ...\n"
  biom add-metadata \
    -i "$trpth"/"$biom_dir"/feature-table.biom \
    -o "$trpth"/"$biom_dir"/features-tax.biom \
    --observation-metadata-fp "$trpth"/"$biom_dir"/taxonomy.tsv \
    --observation-header OTUID,taxonomy,confidence \
    --sc-separated taxonomy || { echo 'taxonomy addition failed' ; exit 1; }
  
  printf "Adding metadata information to .biom file at $(date +"%T")...\n"
  biom add-metadata \
    -i "$trpth"/"$biom_dir"/features-tax.biom \
    -o "$trpth"/"$biom_dir"/features-tax-meta.biom \
    --sample-metadata-fp "$trpth"/"$map_file" \
    --observation-header OTUID,taxonomy,confidence || { echo 'metadata addition failed' ; exit 1; }

done
