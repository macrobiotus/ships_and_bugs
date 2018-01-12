#!/bin/bash

# 11.01.2017 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Metadata formatting for Qiime if artefact contains metadata, 
# it can be combined with the mapping file
# by incorporating the .qza file below

# for debugging only
# ------------------ 
# set -x


# Paths needs to change for remote execution, and executable paths have to be
# ---------------------------------------------------------------------------
# adjusted depending on machine location.
# ----------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_inter_intra"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Setting qiime alias, execution on local...\n"
    trpth="$(dirname "$PWD")"
    qiime2cli() { qiime "$@"; }
fi

# define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/040_18S_paired-end-demux.qza'
mppth='Zenodo/Manifest/05_metadata.txt'
otpth='Zenodo/Qiime/050_18S_tabulated-combined-metadata.qzv'

# run script
# ----------
qiime2cli metadata tabulate \
  --m-input-file "$trpth"/"$mppth" \
  --o-visualization "$trpth"/"$otpth"

printf "Check results with: qiime tools view %s/%s\n" "$trpth" "$otpth"

