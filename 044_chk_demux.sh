#!/bin/bash

# 12.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Wrapper for Qiime2 import script

# For debugging only
# ------------------ 
# set -x

# Paths needs to change for remote execution, and executable paths have to be
# ---------------------------------------------------------------------------
# adjusted depending on machine location.
# ----------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    # trpth="/data/CU_inter_intra"
    echo "Parent directory not yet defined"
    exit
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Setting qiime alias, execution on local...\n"
    trpth="$(dirname "$PWD")"
    qiime2cli() { qiime "$@"; }    
fi

inpth='Zenodo/Qiime/042_18S_paired-end-trimmed.qza'
otpth='Zenodo/Qiime/045_18S_demux-check.qzv'

# Run script
# ----------
qiime2cli demux summarize \
  --i-data "$trpth"/"$inpth" \
  --o-visualization "$trpth"/"$otpth"
