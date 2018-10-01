#!/bin/bash

# 01.10.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime align of representative sequences
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
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/085_18S_097_cl_seq.qza'
otpth='Zenodo/Qiime/095_18S_097_cl_seq_algn.qza'

# Run scripts
# ------------
qiime alignment mafft \
  --i-sequences "$trpth"/"$inpth" \
  --o-alignment "$trpth"/"$otpth" \
  --p-n-threads '2'\
  --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/095_18S_097_cl_algn_log.txt"
