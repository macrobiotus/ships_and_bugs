#!/bin/bash

# 16.12.2017 - Paul Czechowski - paul.czechowski@gmail.com 
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
    trpth="/data/CU_Pearl_Harbour"
    thrds='14'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/042_18S_paired-end-trimmed.qza'
otpth_tab='Zenodo/Qiime/060_18S_feature_table.qza'
otpth_rep='Zenodo/Qiime/060_18S_represe_seqs.qza'


# run script
# ----------
qiime2cli dada2 denoise-paired \
  --i-demultiplexed-seqs "$trpth"/"$inpth" \
  --p-trunc-len-f 240 \
  --p-trunc-len-r 240 \
  --p-n-threads "$thrds" \
  --o-representative-sequences "$trpth"/"$otpth_rep" \
  --o-table "$trpth"/"$otpth_tab"
