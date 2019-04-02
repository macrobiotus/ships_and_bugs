#!/usr/bin/env bash

# 02.10.2018 - Paul Czechowski - paul.czechowski@gmail.com 
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
  qiime2cli() { qiime "$@"; }
  trpth="/Users/paul/Documents/CU_combined"
fi

# define relative input and output locations
# ==========================================

inpth_tre='Zenodo/Qiime/105_18S_097_cl_tree_mid.qza'

inpth_tab[1]='Zenodo/Qiime/130_18S_097_cl_meta_tab.qza'
inpth_tab[2]='Zenodo/Qiime/130_18S_097_cl_edna_tab.qza'
inpth_tab[3]='Zenodo/Qiime/130_18S_097_cl_cntrl_tab.qza'

otpth_mat[1]='Zenodo/Qiime/155_18S_097_cl_meta_mat.qza'
otpth_mat[2]='Zenodo/Qiime/155_18S_097_cl_edna_mat.qza'
otpth_mat[3]='Zenodo/Qiime/155_18S_097_cl_cntrl_mat.qza'

otpth_txt[1]='Zenodo/Qiime/155_18S_097_cl_meta_mat'
otpth_txt[2]='Zenodo/Qiime/155_18S_097_cl_edna_mat'
otpth_txt[3]='Zenodo/Qiime/155_18S_097_cl_cntrl_mat'


# run script
# ==========

for ((i=1;i<=3;i++)); do
  qiime diversity beta-phylogenetic \
    --i-phylogeny "$trpth"/"$inpth_tre" \
    --i-table "$trpth"/"${inpth_tab[$i]}" \
    --o-distance-matrix "$trpth"/"${otpth_mat[$i]}" \
    --p-metric unweighted_unifrac \
    --verbose
  qiime tools export \
    --input-path  "$trpth"/"${otpth_mat[$i]}" \
    --output-path "$trpth"/"${otpth_txt[$i]}"
done
