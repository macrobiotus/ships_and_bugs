#!/bin/bash

# 19.01.2017 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime tree building and midpoint rooting,
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    qiime2cli() { qiime "$@"; }
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
fi

# Define input and output locations
# ---------------------------------
inpth='Zenodo/Qiime/095_18S_mskd_alignment.qza'
urtpth='Zenodo/Qiime/100_18S_tree_no_root.qza'
mptpth='Zenodo/Qiime/100_18S_tree_mdp_root.qza'

intab='Zenodo/Qiime/080_18S_merged_tab.qza'
ottab='Zenodo/Qiime/100_18S_merged_tab.qza'

# inseq='Zenodo/Qiime/080_18S_merged_seq.qza'
# otseq='Zenodo/Qiime/100_18S_merged_seq.qza'

tempdir='Zenodo/Qiime/100_filter_temp'

# Run scripts
# ------------
printf "Calculating tree...\n"
qiime2cli phylogeny fasttree \
 --i-alignment "$trpth"/"$inpth" \
 --o-tree "$trpth"/"$urtpth"

printf "Rooting at midpoint...\n"  
qiime2cli phylogeny midpoint-root \
 --i-tree "$trpth"/"$urtpth" \
 --o-rooted-tree "$trpth"/"$mptpth"

printf "Retaining features with tree-tips...\n"
qiime phylogeny filter-table \
  --i-table "$trpth"/"$intab" \
  --i-tree "$trpth"/"$mptpth" \
  --o-filtered-table "$trpth"/"$ottab" \
  --verbose 

printf "Re-filtering repset...\n"
printf " ... doesn't work so far - see script file - not yet (properly implemented)?\n"
 
# Exporting table
# qiime tools export "$trpth"/"$ottab" --output-dir "$trpth"/"$tempdir"
# 
# getting .tsv table
# biom convert -i "$trpth"/"$tempdir"/feature-table.biom -o "$trpth"/"$tempdir"/feature-table.txt --to-tsv
# 
# qiime feature-table filter-seqs \
#   --i-data "$trpth"/"$inseq" \
#   --m-metadata-file "$trpth"/"$tempdir"/feature-table.txt \
#   --o-filtered-data "$trpth"/"$otseq" \
#   --verbose || { echo 'filter failed' ; exit 1; }
