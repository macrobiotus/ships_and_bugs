#!/usr/bin/env bash

# 01.10.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    export PATH=/programs/Anaconda2/bin:$PATH
    source activate qiime2-2018.6
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# define input and output locations
# --------------------------------
wdir="Zenodo/Classifier"
qdir="Zenodo/Qiime"

# input files
# ------------
clssf="110_18S_classifier.qza"
repset="105_18S_097_cl_seq.qza"

# output files
# ------------
tax="115_18S_taxonomy.qza"

# Run scripts
# ------------
echo "Running Classifier"
qiime feature-classifier classify-sklearn \
  --i-classifier "$trpth"/"$wdir"/"$clssf" \
  --i-reads "$trpth"/"$qdir"/"$repset" \
  --o-classification "$trpth"/"$qdir"/"$tax" \
  --p-n-jobs "$cores" \
  --verbose

