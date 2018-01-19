#!/bin/bash

# 19.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime biodiversity core analyses
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_Pearl_Harbour"
    useConfirm=false
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    useConfirm=true
fi

# Define input and output locations
# ---------------------------------
mptpth='Zenodo/Qiime/100_18S_tree_mdp_root.qza'
ftable='Zenodo/Qiime/060_18S_feature_table.qza'
mdata='/Zenodo/Manifest/05_metadata.tsv'
crdir='/Zenodo/Qiime/110_18S_core_metrics'
depth='249872' 

# Run scripts
# ------------
qiime2cli diversity core-metrics-phylogenetic \
  --i-phylogeny "$trpth"/"$mptpth" \
  --i-table "$trpth"/"$ftable" \
  --m-metadata-file "$trpth"/"$mdata" \
  --output-dir "$trpth"/"$crdir" \
  --p-sampling-depth "$depth"
