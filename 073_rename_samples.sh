#!/bin/bash

# 28.09.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Renaming data with corrected metadate for Singapore as stored 
#   in `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_for_rename.tsv`
#   Additionally there is currently denoising running (see 28.09.2018
#   /Users/paul/Documents/CU_SP_AD_CH/Github/README.md, this date may be included
#   using all previous scripts (BUT NOT this one).

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@" ; }
    thrds="$(nproc --all)"
fi

# define relative input and output locations
# ---------------------------------
inpth_map='Zenodo/Manifest/05_18S_merged_metadata_for_rename.tsv'
inpth_tab='Zenodo/Qiime/065_18S_merged_tab.qza'
otpth_tab='Zenodo/Qiime/073_18S_sum_feat_tab.qza'

# run script
# ----------
qiime2cli feature-table group \
 --i-table "$trpth"/"$inpth_tab" \
 --p-axis sample \
 --m-metadata-file "$trpth"/"$inpth_map" \
 --m-metadata-column 'SIDnew' \
 --p-mode sum \
 --o-grouped-table "$trpth"/"$otpth_tab" \
 --verbose
