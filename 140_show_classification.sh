#!/bin/bash

# 28.09.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "This script needs at least qiime2-2018.08. Execution on remote...\n"
    trpth="/data/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "This script needs at least qiime2-2018.08. Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# define input and output locations
# --------------------------------

# input files
# ------------
ftab='Zenodo/Qiime/135_18S_merged_tab.qza'                   # corrected sample id's for Singapore
mdat='Zenodo/Manifest/05_18S_merged_metadata_for_rename.tsv' # corrected sample id's for Singapore
taxo='Zenodo/Qiime/130_18S_taxonomy.qza'

# output files
# ------------
plot='Zenodo/Qiime/140_18S_taxvis_merged.qzv'

# Run scripts
# ------------
qiime taxa barplot \
  --i-table "$trpth"/"$ftab" \
  --i-taxonomy "$trpth"/"$taxo" \
  --m-metadata-file "$trpth"/"$mdat" \
  --o-visualization "$trpth"/"$plot" \
  --verbose

