#!/usr/bin/env bash

# 28.03.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.

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

inpth_map='Zenodo/Manifest/05_18S_merged_metadata_checked.tsv' # (should be  `c1ca7209941aa96ee9ce9f843b629f98`)

inpth_tab='Zenodo/Qiime/065_18S_merged_tab.qza'
inpth_rep='Zenodo/Qiime/065_18S_merged_seq.qza'

otpth_tab='Zenodo/Qiime/075_18S_sum_feat_tab.qzv'
otpth_rep='Zenodo/Qiime/075_18S_sum_repr_seq.qzv'

# run script
# ----------
  
qiime feature-table summarize \
 --i-table "$trpth"/"$inpth_tab" \
 --o-visualization "$trpth"/"$otpth_tab" \
 --m-sample-metadata-file "$trpth"/"$inpth_map"

qiime feature-table tabulate-seqs \
  --i-data "$trpth"/"$inpth_rep" \
  --o-visualization "$trpth"/"$otpth_rep"
