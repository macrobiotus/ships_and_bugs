#!/bin/bash

# 22.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Classification of reads, needs trained classifier.

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    cores='2'
fi

# Define input files (more below)
# -------------------------------
classifier='Zenodo/Classifier/120_18S_classifier.qza'
inpth_map='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# Run classification:
# -------------------

shopt -s nullglob
for tabqza in $trpth/Zenodo/Qiime/210_18S_???_*_tab.qza ; do
  [ -f "$tabqza" ] || continue
  
  # create target filenames
  filename=$(basename "$tabqza")
  prefix="${filename%.*}"
  prefix="225${prefix:3}"
  tabvis="/Zenodo/Qiime/${prefix::${#prefix}-4}_tab.qzv" # Bash 4: ${foo::-4}

  # summarize feature tables
  printf "Summarizing  \"$tabqza\" at $(date +"%T")  ... \n"
  qiime2cli feature-table summarize \
     --i-table "$tabqza" \
     --o-visualization "$trpth"/"$tabvis" \
     --m-sample-metadata-file "$trpth"/"$inpth_map"

done

shopt -s nullglob
for seqqza in $trpth/Zenodo/Qiime/210_18S_???_*_seq.qza ; do
  [ -f "$seqqza" ] || continue
  
  # create target filenames
  filename=$(basename "$seqqza")
  prefix="${filename%.*}"
  prefix="225${prefix:3}"
  seqvis="/Zenodo/Qiime/${prefix::${#prefix}-4}_seq.qzv" # Bash 4: ${foo::-4}

  # summarize feature sequences
  printf "Summarizing  \"$seqqza\" at $(date +"%T")  ... \n"
  qiime2cli feature-table tabulate-seqs \
    --i-data "$seqqza" \
    --o-visualization "$trpth"/"$seqvis"

done
