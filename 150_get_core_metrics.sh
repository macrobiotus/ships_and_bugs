#!/usr/bin/env bash

# 03.05.2018 - Paul Czechowski - paul.czechowski@gmail.com 
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
    trpth="/workdir/pc683/CU_combined"
    useConfirm=false
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    useConfirm=true
fi

# Define input and output locations
# ---------------------------------
mptpth='Zenodo/Qiime/105_18S_097_cl_tree_mid.qza'
mdata='Zenodo/Manifest/05_18S_merged_metadata.tsv'


ftable='Zenodo/Qiime/130_18S_097_cl_meta_tab.qza'
crdir='Zenodo/Qiime/150_18S_metazoan_core_metrics'
depth='10000' # using frequency of 140_18S_097_cl_euk_tab.qzv to include most samples
              # Retained 1,210,000 (21.76%) sequences in 121 (68.36%) samples at the specified sampling depth.
            
# Run scripts
# ------------
qiime2cli diversity core-metrics-phylogenetic \
  --i-phylogeny "$trpth"/"$mptpth" \
  --i-table "$trpth"/"$ftable" \
  --m-metadata-file "$trpth"/"$mdata" \
  --output-dir "$trpth"/"$crdir" \
  --p-sampling-depth "$depth"
