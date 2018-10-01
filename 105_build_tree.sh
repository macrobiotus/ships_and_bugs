#!/bin/bash

# 01.10.2018 - Paul Czechowski - paul.czechowski@gmail.com 
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
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Define input and output locations
# ---------------------------------
inseq='Zenodo/Qiime/100_18S_097_cl_seq_algn.qza'
urtpth='Zenodo/Qiime/105_18S_097_cl_tree_rad.qza'

intab='Zenodo/Qiime/085_18S_097_cl_tab.qza'
mptpth='Zenodo/Qiime/105_18S_097_cl_tree_mid.qza'

ottab='Zenodo/Qiime/105_18S_097_cl_tab.qza'
inpth='Zenodo/Qiime/085_18S_097_cl_seq.qza'

otseq='Zenodo/Qiime/105_18S_097_cl_seq.qza'

# Run scripts
# ------------
# printf "Calculating tree...\n"
#   qiime phylogeny fasttree \
#   --i-alignment "$trpth"/"$inseq" \
#   --o-tree "$trpth"/"$urtpth" \
#   --p-n-threads 3 \
#   --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/105_18S_097_cl_tree_log.txt"
# 
# # qiime phylogeny raxml-rapid-bootstrap \
# #   --p-seed 1723 --p-rapid-bootstrap-seed 9384 \
# #   --p-bootstrap-replicates 200 \
# #   --p-substitution-model GTRGAMMAI \
# #   --p-n-threads 3 \
# #   --i-alignment "$trpth"/"$inseq" \
# #   --o-tree "$trpth"/"$urtpth" \
# #   --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/105_18S_097_cl_tree_log.txt"
# 
# printf "Rooting at midpoint...\n"  
# qiime phylogeny midpoint-root \
#  --i-tree "$trpth"/"$urtpth" \
#  --o-rooted-tree "$trpth"/"$mptpth"

printf "Retaining features with tree-tips...\n"
qiime phylogeny filter-table \
  --i-table "$trpth"/"$intab" \
  --i-tree "$trpth"/"$mptpth" \
  --o-filtered-table "$trpth"/"$ottab" \
  --verbose

printf "Filtering sequences to match features with tree-tips...\n"
qiime feature-table filter-seqs \
  --i-data "$trpth"/"$inpth" \
  --i-table "$trpth"/"$ottab" \
  --o-filtered-data "$trpth"/"$otseq" \
  --verbose
