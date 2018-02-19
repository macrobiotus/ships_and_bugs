#!/bin/bash

# 07.12.2017 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime align.
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    qiime() { qiime2cli "$@"; }
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
fi

# Define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/060_18S_represe_seqs.qza'
otpth='Zenodo/Qiime/080_18S_raw_alignment.qza'

# Run scripts
# ------------

qiime alignment mafft \
  --i-sequences "$trpth"/"$inpth" \
  --o-alignment "$trpth"/"$otpth"
