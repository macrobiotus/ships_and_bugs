#!/usr/bin/env bash

# 03.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Getting UNIFRAC matrices from eDNA samples

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
  trpth="/workdir/pc683/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
  trpth="/Users/paul/Documents/CU_combined"
fi

# define relative input and output locations
# ==========================================

inpth_mat[1]='Zenodo/Qiime/120_18S_metazoan_core_metrics/unweighted_unifrac_distance_matrix.qza'
inpth_pcoa[1]='Zenodo/Qiime/120_18S_metazoan_core_metrics/unweighted_unifrac_pcoa_results.qza'

otpth_mat[1]='Zenodo/Qiime/125_18S_metazoan_unweighted_unifrac_distance_matrix'
otpth_pcoa[1]='Zenodo/Qiime/125_18S_metazoan_unweighted_unifrac_pcoa_results'

# run script
# ==========

for ((i=1;i<=1;i++)); do

  qiime tools export \
    --input-path  "$trpth"/"${inpth_mat[$i]}" \
    --output-path "$trpth"/"${otpth_mat[$i]}"

  qiime tools export \
    --input-path  "$trpth"/"${inpth_pcoa[$i]}" \
    --output-path "$trpth"/"${otpth_pcoa[$i]}"

done
