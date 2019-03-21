#!/bin/bash

# 20.03.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.10/tutorials/moving-pictures/
# merging data from different runs, after denoising
# https://docs.qiime2.org/2018.2/tutorials/fmt/

# 28.09.2018 - remove port names to include newly denoising data and check README's

# for debugging only
# ------------------ 
# set -x

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

# define input and output locations
# ---------------------------------
tab[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Qiime/060_18S_PH_feature_table.qza'   #  Mar  9 07:33
tab[2]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_26_paired-end-tab.qza'       #  96K Mar 11 08:00
tab[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_29_paired-end-tab.qza'       #  60K Mar 11 13:20
tab[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_34_paired-end-tab.qza'       #  41K Mar  9 20:35
tab[5]='/Users/paul/Documents/CU_US_ports_a/Zenodo/Qiime/050_18S_paired-end-tab.qza'        # 493K Mar 12 03:15
tab[6]='/Users/paul/Documents/CU_RT_AN/Zenodo/Qiime/050_18S_10410623-tab.qza'               # 406K Mar  7 22:46

seq[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Qiime/060_18S_PH_rep_seq.qza'   # 263K Mar  9 07:33
seq[2]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_26_paired-end-rep.qza' # 210K Mar 11 08:00
seq[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_29_paired-end-rep.qza' #  53K Mar 11 13:20
seq[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_34_paired-end-rep.qza' #  53K Mar  9 20:35
seq[5]='/Users/paul/Documents/CU_US_ports_a/Zenodo/Qiime/050_18S_paired-end-rep.qza'  # 1.3M Mar 12 03:15
seq[6]='/Users/paul/Documents/CU_RT_AN/Zenodo/Qiime/050_18S_10410623-seq.qza'         # 949K Mar  7 22:46 

otpth_tab='Zenodo/Qiime/065_18S_merged_tab.qza'
otpth_seq='Zenodo/Qiime/065_18S_merged_seq.qza'

# run script
# -----------
qiime feature-table merge \
  --i-tables "${tab[1]}" \
  --i-tables "${tab[2]}" \
  --i-tables "${tab[3]}" \
  --i-tables "${tab[4]}" \
  --i-tables "${tab[5]}" \
  --i-tables "${tab[6]}" \
  --o-merged-table "$trpth"/"$otpth_tab"

qiime feature-table merge-seqs \
  --i-data "${seq[1]}" \
  --i-data "${seq[2]}" \
  --i-data "${seq[3]}" \
  --i-data "${seq[4]}" \
  --i-data "${seq[5]}" \
  --i-data "${seq[6]}" \
  --o-merged-data "$trpth"/"$otpth_seq"
