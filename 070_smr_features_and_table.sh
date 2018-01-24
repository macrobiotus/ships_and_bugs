#!/bin/bash

# 18.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Summarizing demultiplexing procedure.

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
    trpth="$(dirname "$PWD")"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define relative input and output locations
# ---------------------------------
inpth_tab='Zenodo/Qiime/060_18S_feature_table.qza'
inpth_rep='Zenodo/Qiime/060_18S_represe_seqs.qza'

otpth_tab='Zenodo/Qiime/070_18S_sum_feature_table.qzv'
otpth_rep='Zenodo/Qiime/070_18S_sum_represe_seqs.qzv'

inpth_map='Zenodo/Manifest/05_metadata.tsv'

# run script
# ----------
  
qiime2cli feature-table summarize \
 --i-table "$trpth"/"$inpth_tab" \
 --o-visualization "$trpth"/"$otpth_tab" \
 --m-sample-metadata-file "$trpth"/"$inpth_map"

qiime2cli feature-table tabulate-seqs \
  --i-data "$trpth"/"$inpth_rep" \
  --o-visualization "$trpth"/"$otpth_rep"
