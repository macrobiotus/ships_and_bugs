#!/bin/bash

# 22.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Classification of reads, needs trained classifier. May not be necessary.

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
    cores="$(nproc --all)"
fi

# Define input files (more below)
# -------------------------------
classifier='Zenodo/Classifier/120_18S_classifier.qza'
inpth_map='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# Run classification:
# -------------------
shopt -s nullglob
for seqqza in $trpth/Zenodo/Qiime/210_18S_???_*_seq.qza ; do
  [ -f "$seqqza" ] || continue
  
  # create target filenames
  filename=$(basename "$seqqza")
  suffix="${filename##*.}"
  prefix="${filename%.*}"
  prefix="220${prefix:3}"
  trgttax="/Zenodo/Qiime/${prefix::${#prefix}-4}_tax.$suffix" # Bash 4: ${foo::-4}
  trgtvis="/Zenodo/Qiime/${prefix::${#prefix}-4}_tax.qzv" # Bash 4: ${foo::-4}
  
  # run classifier
  printf "Classifying \"$seqqza\" at $(date +"%T")  ... \n"
  qiime2cli feature-classifier classify-sklearn \
    --i-classifier "$trpth"/"$classifier" \
    --i-reads "$seqqza" \
    --o-classification "$trpth"/"$trgttax" \
    --p-n-jobs "$cores" \
    --verbose \
    || { echo 'Classification failed' ; exit 1; }
    
  # get visualisations
  printf "Visualizing \"$trgttax\" at $(date +"%T")  ... \n"
  qiime2cli metadata tabulate \
    --m-input-file "$trpth"/"$trgttax" \
    --o-visualization "$trpth"/"$trgtvis" \
    || { echo 'Visualisation failed' ; exit 1; }
  
done
