#!/bin/bash

# 26.02.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# merging metadata

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
tab[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Manifest/05_metadata.tsv'
tab[2]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_26_SPW.tsv'
tab[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_29_AD.tsv'
tab[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_34_CH.tsv'

otpth_tab='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# run script
# ----------
touch "$trpth"/"$otpth_tab"
head -n 1  "${tab[1]}" > "$trpth"/"$otpth_tab"
for ((i=1;i<=4;i++)); do
   tail -n +2 "${tab[$i]}" >> "$trpth"/"$otpth_tab"
done 
