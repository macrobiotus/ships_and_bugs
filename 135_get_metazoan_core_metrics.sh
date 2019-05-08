#!/usr/bin/env bash

# 08.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Define input and output locations
# ---------------------------------
mptpth='Zenodo/Qiime/115_18S_097_cl_tree_mid.qza'
ftable='Zenodo/Qiime/100_18S_097_cl_metzn_tab.qza'
mdata='Zenodo/Manifest/05_18S_merged_metadata.tsv' # (after correction: `9704c8ce6cf9f8acbd08c88d124b4a5b`)

crdir='Zenodo/Qiime/120_18S_metazoan_core_metrics'
depth='2500' # see README and `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190403_rarefaction_depth.png`
             # "Retained 467,500 (7.35%) sequences in 187 (78.57%) samples at the specifed sampling depth."
            
# Run scripts
# ------------
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny "$trpth"/"$mptpth" \
  --i-table "$trpth"/"$ftable" \
  --m-metadata-file "$trpth"/"$mdata" \
  --output-dir "$trpth"/"$crdir" \
  --p-sampling-depth "$depth"
