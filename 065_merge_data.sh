#!/usr/bin/env bash

# 28.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi

# define input and output locations
# ---------------------------------
tab[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Qiime/060_18S_PH_feature_table.qza'   #  Mar  9 07:33     9defa08cedfaf54f75d292a2afd40106
tab[2]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_26_paired-end-tab.qza'       #  60K Mar 27 04:24 7265e758a24855c4d9ebbc6cc2160467
tab[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_29_paired-end-tab.qza'       #  58K Mar 27 12:28 13dee7dc8b6732d4aa89211518d4da30
tab[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_34_paired-end-tab.qza'       #  29K Mar 26 21:55 be9c9e4a551ed482dfa5cbacb34a7296
tab[5]='/Users/paul/Documents/CU_US_ports_a/Zenodo/Qiime/050_18S_paired-end-tab.qza'        # 493K Mar 12 03:15 eef7f558305ffbbf6af9dfd179f7d5c9
tab[6]='/Users/paul/Documents/CU_RT_AN/Zenodo/Qiime/050_18S_10410623-tab.qza'               # 406K Mar  7 22:46 024a90ddce5149c9b0f9f86c6d5c6094
tab[7]='/Users/paul/Documents/CU_WL_GH_ZEE/Zenodo/Qiime/050_18S_10414227_full_trimmed-tab.qza'  # 177K Apr 17 00:03 c308ca068f2e39858d2f297ee9cdb402               

seq[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Qiime/060_18S_PH_rep_seq.qza'   # 263K Mar  9 07:33   9414b3dc3902360560827571a2c7f068
seq[2]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_26_paired-end-rep.qza' #  96K Mar 27 04:24   b1055e7c7930edbe159508fff97ff659
seq[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_29_paired-end-rep.qza' #  51K Mar 27 12:28   3a1550e758537869fb9fb1e2c990cb35
seq[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Qiime/050_18S_34_paired-end-rep.qza' #  32K Mar 26 21:55   e7c8ba9532eba5d31ae048f52071e5d3
seq[5]='/Users/paul/Documents/CU_US_ports_a/Zenodo/Qiime/050_18S_paired-end-rep.qza'  # 1.3M Mar 12 03:15   1072ce96838c0e0ace59e0af9c4f8a6b
seq[6]='/Users/paul/Documents/CU_RT_AN/Zenodo/Qiime/050_18S_10410623-seq.qza'         # 949K Mar  7 22:46   5da8a6144085bca357e6e824107bbde3
seq[7]='/Users/paul/Documents/CU_WL_GH_ZEE/Zenodo/Qiime/050_18S_10414227_full_trimmed-seq.qza' # 337K Apr 17 00:03  05f643ce5ff7c3afb40b8dd1ba309bbe 

otpth_tab='Zenodo/Qiime/065_18S_denoised_tab.qza'
otpth_seq='Zenodo/Qiime/065_18S_denoised_seq.qza'

# run script
# -----------
qiime feature-table merge \
  --i-tables "${tab[1]}" \
  --i-tables "${tab[2]}" \
  --i-tables "${tab[3]}" \
  --i-tables "${tab[4]}" \
  --i-tables "${tab[5]}" \
  --i-tables "${tab[6]}" \
  --i-tables "${tab[7]}" \
  --o-merged-table "$trpth"/"$otpth_tab"

qiime feature-table merge-seqs \
  --i-data "${seq[1]}" \
  --i-data "${seq[2]}" \
  --i-data "${seq[3]}" \
  --i-data "${seq[4]}" \
  --i-data "${seq[5]}" \
  --i-data "${seq[6]}" \
  --i-data "${seq[7]}" \
  --o-merged-data "$trpth"/"$otpth_seq"
  
