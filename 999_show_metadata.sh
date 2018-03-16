#!/bin/bash

# 15.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

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
mdpth='Zenodo/Manifest/05_metadata.txt'
otpth='Zenodo/Qiime/050_18S_tabulated-combined-metadata.qzv'

# Run script
# ----------
# qiime2cli metadata tabulate \
#  --m-input-file "$trpth"/"$inpth" \
#  --m-input-file "$trpth"/"$mdpth" \
#  --o-visualization "$trpth"/"$otpth"

qiime2cli metadata tabulate \
  --m-input-file "$trpth"/"$mdpth" \
  --o-visualization "$trpth"/"$otpth" 
