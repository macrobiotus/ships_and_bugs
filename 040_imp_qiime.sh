#!/bin/bash

# 19.02.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Wrapper for Qiime2 import script, manifest file must be available.
# More info at https://docs.qiime2.org/2017.10/tutorials/importing/

# For debugging only
# ------------------ 
set -x

# Paths needs to change for remote execution, and executable paths have to be
# ---------------------------------------------------------------------------
# adjusted depending on machine location.
# ----------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote not implemented, exiting ...\n"
    exit
    
    # trpth="/data/CU_combined"
    
    # input file array - these do not exist 
    # inpth[1]='Zenodo/Manifest/05_manifest_PH_remote.txt'
    # inpth[2]='Zenodo/Manifest/05_manifest_SPW_remote.txt'
    # inpth[3]='Zenodo/Manifest/05_manifest_SPY_remote.txt'
    # inpth[4]='Zenodo/Manifest/05_manifest_CH_remote.txt'
    
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Setting qiime alias, execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@"; }
    
    # input file array
    inpth[1]='Zenodo/Manifest/05_manifest_PH_local.txt'
    inpth[2]='Zenodo/Manifest/05_manifest_SPW_local.txt'
    inpth[3]='Zenodo/Manifest/05_manifest_SPY_local.txt'
    inpth[4]='Zenodo/Manifest/05_manifest_CH_local.txt'
fi

# output file array
otpth[1]='Zenodo/Qiime/040_18S_PH_paired-end-import.qza'
otpth[2]='Zenodo/Qiime/040_18S_SPW_paired-end-import.qza'
otpth[3]='Zenodo/Qiime/040_18S_SPY_paired-end-import.qza'
otpth[4]='Zenodo/Qiime/040_18S_CH_paired-end-import.qza'

# Run import script
# -----------------------------
for ((i=1;i<=4;i++)); do
    qiime2cli tools import \
        --type 'SampleData[PairedEndSequencesWithQuality]' \
        --input-path  "$trpth"/"${inpth[$i]}" \
        --output-path "$trpth"/"${otpth[$i]}" \
        --source-format PairedEndFastqManifestPhred33
done
