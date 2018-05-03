#!/bin/bash

# 03.05.2017 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime tree building and midpoint rooting,
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
set -x

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

# Define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/095_18S_mskd_alignment.qza'
urtpth='Zenodo/Qiime/100_18S_tree_no_root.qza'
mptpth='Zenodo/Qiime/100_18S_tree_mdp_root.qza'

intab='Zenodo/Qiime/080_18S_merged_tab.qza'
ottab='Zenodo/Qiime/100_18S_merged_tab.qza'

# Run scripts
# ------------
printf "Calculating tree...\n"
qiime2cli phylogeny fasttree \
 --i-alignment "$trpth"/"$inpth" \
 --o-tree "$trpth"/"$urtpth"
 --p-n-threads -1

printf "Rooting at midpoint...\n"  
qiime2cli phylogeny midpoint-root \
 --i-tree "$trpth"/"$urtpth" \
 --o-rooted-tree "$trpth"/"$mptpth"

printf "Retaining features with tree-tips...\n"
qiime phylogeny filter-table \
  --i-table "$trpth"/"$intab" \
  --i-tree "$trpth"/"$mptpth" \
  --o-filtered-table "$trpth"/"$ottab" \
  --verbose 
