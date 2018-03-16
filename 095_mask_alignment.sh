#!/bin/bash

# 19.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime alignment masking.
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
fi

# Define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/090_18S_raw_alignment.qza'
otpth='Zenodo/Qiime/095_18S_mskd_alignment.qza'

# Run scripts
# ------------

qiime2cli alignment mask \
  --i-alignment "$trpth"/"$inpth" \
  --o-masked-alignment "$trpth"/"$otpth"
  
