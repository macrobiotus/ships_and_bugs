#!/bin/bash

# 12.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Getting statistics from demultiplexing

# For debugging only
# ------------------ 
set -x

# Paths needs to change for remote execution, and executable paths have to be
# ---------------------------------------------------------------------------
# adjusted depending on machine location.
# ----------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote not yet tested...\n"
    cores='40'
    trpth="/data/CU_combined"
    exit
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Setting qiime alias, execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@"; }
    
fi

# input file array
inpth[1]='Zenodo/Qiime/040_18S_CH_paired-end-import.qza'
inpth[2]='Zenodo/Qiime/040_18S_SPW_paired-end-import.qza'
inpth[3]='Zenodo/Qiime/040_18S_PH_paired-end-import.qza'

# output file array
otpth[1]='Zenodo/Qiime/050_18S_CH_paired-end-import.qzv'
otpth[2]='Zenodo/Qiime/050_18S_SPW_paired-end-import.qzv'
otpth[3]='Zenodo/Qiime/050_18S_PH_paired-end-import.qzv'


# Run script
# ----------
for ((i=1;i<=3;i++)); do
   qiime2cli demux summarize \
      --i-data "$trpth"/"${inpth[$i]}" \
      --o-visualization "$trpth"/"${otpth[$i]}"
done
