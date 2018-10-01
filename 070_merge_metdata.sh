#!/bin/bash

# 01.10.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# merging metadata

# 28.09.2018 - remove port names to include newly denoising data and check README's

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
tab[1]='/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_old.tsv'
tab[2]='/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.tsv'

otpth_tab='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# run script
# ----------
touch "$trpth"/"$otpth_tab"
head -n 1  "${tab[1]}" > "$trpth"/"$otpth_tab"
for ((i=1;i<=2;i++)); do
   tail -n +2 "${tab[$i]}" >> "$trpth"/"$otpth_tab"
done 
