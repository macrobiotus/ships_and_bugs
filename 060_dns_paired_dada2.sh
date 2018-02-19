#!/bin/bash

# 19.02.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.10/tutorials/moving-pictures/
# Citing this plugin: DADA2: High-resolution sample inference from Illumina
# amplicon data. Benjamin J Callahan, Paul J McMurdie, Michael J Rosen,
# Andrew W Han, Amy Jo A Johnson, Susan P Holmes. Nature Methods 13, 581–583
# (2016) doi:10.1038/nmeth.3869.


# for debugging only
# ------------------ 
set -x

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
inpth[1]='Zenodo/Qiime/040_18S_CH_paired-end-import.qza'
inpth[2]='Zenodo/Qiime/040_18S_PH_paired-end-import.qza'
inpth[3]='Zenodo/Qiime/040_18S_SPW_paired-end-import.qza'

otpth_tab[1]='Zenodo/Qiime/060_18S_CH_feat_tab.qza'
otpth_tab[2]='Zenodo/Qiime/060_18S_PH_feat_tab.qza'
otpth_tab[3]='Zenodo/Qiime/060_18S_SPW_feat_tab.qza'

otpth_rep[1]='Zenodo/Qiime/060_18S_CH_rep_seq.qza'
otpth_rep[2]='Zenodo/Qiime/060_18S_PH_rep_seq.qza'
otpth_rep[3]='Zenodo/Qiime/060_18S_SPW_rep_seq.qza'

len-f[1]='275'
len-r[1]='240'

len-f[2]='220'
len-r[2]='180'

len-f[3]='260'
len-r[3]='220'

# run script
# ----------
for ((i=1;i<=3;i++)); do
   qiime2cli dada2 denoise-paired \
      --i-demultiplexed-seqs "$trpth"/"${inpth[$i]}" \
      --p-trunc-len-f "${len-f[$i]}" \
      --p-trunc-len-r "${len-r[$i]}" \
      --p-n-threads "$thrds" \
      --o-representative-sequences "$trpth"/"${otpth_rep[$i]}" \
      --o-table "$trpth"/"${otpth_tab[$i]}"
done
