#!/usr/bin/env bash

# 28.03.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Checking reads after denoising, merging, and clustering.

# for debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi

# define relative input and output locations
# ---------------------------------
inpth_tab='Zenodo/Qiime/085_18S_097_cl_tab.qza'
inpth_rep='Zenodo/Qiime/085_18S_097_cl_seq.qza'

otpth_tab='Zenodo/Qiime/090_18S_097_cl_tab.qzv'
otpth_rep='Zenodo/Qiime/085_18S_097_cl_seq.qzv'

inpth_map='Zenodo/Manifest/05_18S_merged_metadata_checked.tsv'

# run script
# ----------
  
qiime feature-table summarize \
 --i-table "$trpth"/"$inpth_tab" \
 --o-visualization "$trpth"/"$otpth_tab" 
 --m-sample-metadata-file "$trpth"/"$inpth_map"

qiime feature-table tabulate-seqs \
  --i-data "$trpth"/"$inpth_rep" \
  --o-visualization "$trpth"/"$otpth_rep"
