#!/bin/bash

# 19.01.2017 - Paul Czechowski - paul.czechowski@gmail.com 
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
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
fi

# define input and output locations
# --------------------------------
wdir="Zenodo/Classifier"
qdir="Zenodo/Qiime"

# input files
# ------------
clssf="120_18S_classifier.qza"
repset="060_18S_represe_seqs.qza"

# output files
# ------------
tax="130_18S_taxonomy.qza"
taxv="130_18S_taxonomy.qzv"

# Run scripts
# ------------
qiime feature-classifier classify-sklearn \
  --i-classifier "$trpth"/"$wdir"/"$clssf.qza" \
  --i-reads "$trpth"/"$qdir"/"$repset" \
  --o-classification "$trpth"/"$qdir"/"$tax"

qiime metadata tabulate \
  --m-input-file "$trpth"/"$qdir"/"$tax" \
  --o-visualization "$trpth"/"$qdir"/"$taxv"

