#!/usr/bin/env bash

# 28.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime alignment masking.
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds="3"
fi

# Define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/095_18S_097_cl_seq_algn.qza'
otpth='Zenodo/Qiime/100_18S_097_cl_seq_algn.qza'

# Run scripts
# ------------

qiime alignment mask \
  --i-alignment "$trpth"/"$inpth" \
  --o-masked-alignment "$trpth"/"$otpth" \
  --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/100_18S_097_cl_seq_algn_log.txt"
