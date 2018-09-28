#!/bin/bash

# 03.05.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    dbugp="/data/CU_combined"
    # dbugp="/workdir/pc683/CU_combined"
    TMPDIR="/workdir/pc683/tmp/"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    dbugp="$(dirname "$PWD")"
fi

# define input and output locations
# --------------------------------
wdir="Zenodo/Classifier"
qdir="Zenodo/Qiime"

# input files
# ------------
clssf="120_18S_classifier.qza"
repset="100_18S_merged_seq.qza"

# output files
# ------------
tax="130_18S_taxonomy.qza"
taxv="130_18S_taxonomy.qzv"

# Run scripts
# ------------
qiime2cli feature-classifier classify-sklearn \
  --i-classifier "$trpth"/"$wdir"/"$clssf" \
  --i-reads "$trpth"/"$qdir"/"$repset" \
  --o-classification "$dbugp"/"$qdir"/"$tax" \
  --p-n-jobs -1 \
  --verbose

qiime2cli metadata tabulate \
  --m-input-file "$dbugp"/"$qdir"/"$tax" \
  --o-visualization "$trpth"/"$qdir"/"$taxv"
