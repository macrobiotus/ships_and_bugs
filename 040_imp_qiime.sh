#!/bin/bash

# 22.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
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
    printf "Execution on remote...\n"
    # trpth="/data/..."
    echo "Parent directory not yet defined"
    exit
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Setting qiime alias, execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@"; }
    inpth='Zenodo/Manifest/05_manifest_local.txt'
fi

otpth='Zenodo/Qiime/040_18S_paired-end-import.qza'

# Run import script
# -----------------------------
qiime2cli tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path  "$trpth"/"$inpth" \
  --output-path "$trpth"/"$otpth" \
  --source-format PairedEndFastqManifestPhred33
