#!/bin/bash

# 18.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.

# for debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    thrds='14'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define relative input and output locations
# ---------------------------------
inpth_tab='Zenodo/Qiime/080_18S_merged_tab.qza'
inpth_rep='Zenodo/Qiime/080_18S_merged_seq.qza'

otpth_tab='Zenodo/Qiime/085_18S_sum_feat_tab.qzv'
otpth_rep='Zenodo/Qiime/085_18S_sum_repr_seq.qzv'

inpth_map='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# run script
# ----------
  
qiime2cli feature-table summarize \
 --i-table "$trpth"/"$inpth_tab" \
 --o-visualization "$trpth"/"$otpth_tab" 
 --m-sample-metadata-file "$trpth"/"$inpth_map"

qiime2cli feature-table tabulate-seqs \
  --i-data "$trpth"/"$inpth_rep" \
  --o-visualization "$trpth"/"$otpth_rep"
