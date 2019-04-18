#!/usr/bin/env bash

# 18.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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
inpth_map='Zenodo/Manifest/06_18S_merged_metadata.tsv' # (should be  `b16888550ab997736253f741eaec47b`)
inpth_tax='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'


inpth_tab='Zenodo/Qiime/065_18S_denoised_tab.qza'
inpth_seq='Zenodo/Qiime/065_18S_denoised_seq.qza'

otpth_tabv='Zenodo/Qiime/080_18S_denoised_tab_vis.qzv'
otpth_seqv='Zenodo/Qiime/080_18S_denoised_seq_vis.qzv'
otpth_bplv='Zenodo/Qiime/080_18S_denoised_tax_vis.qzv'

# run script
# ----------
  
qiime feature-table summarize \
 --i-table "$trpth"/"$inpth_tab" \
 --m-sample-metadata-file "$trpth"/"$inpth_map" \
 --o-visualization "$trpth"/"$otpth_tabv" \
 --verbose
 
qiime feature-table tabulate-seqs \
  --i-data "$trpth"/"$inpth_seq" \
  --o-visualization "$trpth"/"$otpth_seqv" \
  --verbose

qiime taxa barplot \
  --i-table "$trpth"/"$inpth_tab" \
  --i-taxonomy "$trpth"/"$inpth_tax" \
  --m-metadata-file "$trpth"/"$inpth_map" \
  --o-visualization "$trpth"/"$otpth_bplv" \
  --verbose
