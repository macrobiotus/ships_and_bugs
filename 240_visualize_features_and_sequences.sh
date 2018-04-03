#!/bin/bash

# 02.04.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Summarizing clustering output, part 2 of 2 - summarizing sequences and
# features in graphic form.
#
# Here one can likely use use taxonomy information from unclustered data, if 
#  clusters are subsets of unclustered data (which they should be), and the 
#  identifiers aren't changed or there are new identifiers in the clustered data.
#  In the present case we have re-classified all clusters. Otherwise re-define
#  input taxonomy paths.

# For debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@" ; }
    cores='2'
fi

# input files
# ------------
map_file='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# output files
# ------------
# generated from input file names in loop - see below

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
  tax_file="Zenodo/Qiime/${prefix::${#prefix}-4}_tax.qza" # Bash 4: ${foo::-4}
  
  # check if dependent input file exists
  [ -f "$trpth"/"$tax_file" ] || continue
  
  # create output directory path
  filename=$(basename "$tab_file")
  prefix="${filename%.*}"
  prefix="240${prefix:3}"
  viz_dir="Zenodo/Qiime/${prefix::${#prefix}-4}_tax_vis" # Bash 4: ${foo::-4}
  
  # for debugging only: 
  
  # list being looped over
  # printf "$tab_file\n"
  
  # dependent input files
  # printf "$trpth"/"$tax_file\n"
  
  
  # output directory
  # printf "$trpth"/"$viz_dir\n"

  qiime taxa barplot \
    --i-table "$tab_file" \
    --i-taxonomy "$trpth"/"$tax_file" \
    --m-metadata-file "$trpth"/"$map_file" \
    --output-dir "$trpth"/"$viz_dir" \
    --verbose

done
