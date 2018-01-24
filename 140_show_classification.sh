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
    printf "This script needs at least qiime2-2017.11. Execution on remote...\n"
    trpth="/data/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "This script needs at least qiime2-2017.11. Execution on local...\n"
    trpth="$(dirname "$PWD")"
fi

# define input and output locations
# --------------------------------
qdir="Zenodo/Qiime"

# input files
# ------------
ftable="060_18S_feature_table.qza"
mdata='Zenodo/Manifest/05_metadata.tsv'
tax="130_18S_taxonomy.qza"


# output files
# ------------
plotd="140_18S_taxvis"

# Run scripts
# ------------
qiime taxa barplot \
  --i-table "$trpth"/"$qdir"/"$ftable" \
  --i-taxonomy "$trpth"/"$qdir"/"$tax" \
  --m-metadata-file "$trpth"/"$mdata" \
  --output-dir "$trpth"/"$qdir"/"$plotd" \
  --verbose 

