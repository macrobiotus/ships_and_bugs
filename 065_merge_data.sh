#!/bin/bash

# 26.02.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.10/tutorials/moving-pictures/
# merging data from different runs, after denoising
# https://docs.qiime2.org/2018.2/tutorials/fmt/

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    thrds='40'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define input and output locations
# ---------------------------------
tab[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Qiime/060_18S_PH_feature_table.qza'
tab[2]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_26_SPW_paired-end-tab.qza'
tab[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_29_AD_paired-end-tab.qza'
tab[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_34_CH_paired-end-tab.qza'

seq[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Qiime/060_18S_PH_rep_seq.qza'
seq[2]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_26_SPW_paired-end-rep.qza'
seq[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_29_AD_paired-end-rep.qza'
seq[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_34_CH_paired-end-rep.qza'

otpth_tab='Zenodo/Qiime/065_18S_merged_tab.qza'
otpth_seq='Zenodo/Qiime/065_18S_merged_seq.qza'

# run script
# ----------
qiime feature-table merge \
  --i-tables "${tab[1]}" \
  --i-tables "${tab[2]}" \
  --i-tables "${tab[3]}" \
  --i-tables "${tab[4]}" \
  --o-merged-table "$trpth"/"$otpth_tab"
qiime feature-table merge-seqs \
  --i-data "${seq[1]}" \
  --i-data "${seq[2]}" \
  --i-data "${seq[3]}" \
  --i-data "${seq[4]}" \
  --o-merged-data "$trpth"/"$otpth_seq"
