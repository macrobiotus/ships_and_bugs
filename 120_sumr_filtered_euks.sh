#!/bin/bash

# 01.10.2018 - Paul Czechowski - paul.czechowski@gmail.com 
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
meta_tab='Zenodo/Qiime/105_18S_097_cl_seq.qza'
meta_seq='Zenodo/Qiime/105_18S_097_cl_tab.qza'

mdat='Zenodo/Manifest/05_18S_merged_metadata.tsv'
taxo='Zenodo/Qiime/115_18S_taxonomy.qza'

# output files
# ------------
tabv='Zenodo/Qiime/120_18S_097_cl_euk_tab.qzv'
seqv='Zenodo/Qiime/120_18S_097_cl_euk_seq.qzv'
plot='Zenodo/Qiime/120_18S_097_cl_euk_plot.qzv'

# Run scripts
# ------------
qiime feature-table summarize \
 --i-table "$trpth"/"$meta_tab" \
 --o-visualization "$trpth"/"$otpth_tabv"  \
 --m-sample-metadata-file "$trpth"/"$mdat"

qiime feature-table tabulate-seqs \
  --i-data "$trpth"/"$meta_seq" \
  --o-visualization "$trpth"/"$otpth_seqv"

qiime taxa barplot \
  --i-table "$trpth"/"$meta_tab" \
  --i-taxonomy "$trpth"/"$taxo" \
  --m-metadata-file "$trpth"/"$mdat" \
  --o-visualization "$trpth"/"$plota" \
  --verbose
