#!/bin/bash

# 19.01.2017 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime tree building and midpoint rooting,
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_Pearl_Harbour"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
fi

# Define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/090_18S_mskd_alignment.qza'
urtpth='Zenodo/Qiime/100_18S_tree_no_root.qza'
mptpth='Zenodo/Qiime/100_18S_tree_mdp_root.qza'

# Run scripts
# ------------
printf "Calculating tree...\n"
qiime2cli phylogeny fasttree \
  --i-alignment "$trpth"/"$inpth" \
  --o-tree "$trpth"/"$urtpth"

printf "Rooting at midpoint...\n"  
qiime2cli phylogeny midpoint-root \
  --i-tree "$trpth"/"$urtpth" \
  --o-rooted-tree "$trpth"/"$mptpth"
