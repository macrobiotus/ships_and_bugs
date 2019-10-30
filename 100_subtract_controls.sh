#!/usr/bin/env bash

# 30.10.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Retain only samples needed for analysis 

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.local" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "macmini.local" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Define input paths 
# ------------------
# define more arrays for other files if needed

# input table and sequences
in_seq[1]='Zenodo/Qiime/090_18S_preliminary_eDNA_samples_seq.qza'
in_tab[1]='Zenodo/Qiime/090_18S_preliminary_eDNA_samples_tab.qza'

in_seq[2]='Zenodo/Qiime/090_18S_controls_seq.qza'
in_tab[2]='Zenodo/Qiime/090_18S_controls_tab.qza'

# checked mapping files
map='Zenodo/Manifest/06_18S_merged_metadata.tsv' 
seq='Zenodo/Qiime/090_18S_controls_features.tsv'

# Define output paths 
# -------------------
out_seq[2]='Zenodo/Qiime/100_18S_eDNA_samples_seq.qza'
out_tab[2]='Zenodo/Qiime/100_18S_eDNA_samples_tab.qza'

# Run scripts 
# -----------

printf "Subtracting control sequences from sequences...\n"
qiime feature-table filter-seqs \
  --i-data "$trpth"/"${in_seq[1]}" \
  --m-metadata-file "$trpth"/"$seq" \
  --p-exclude-ids \
  --o-filtered-data "$trpth"/"${out_seq[2]}" \
  --verbose

printf "Subtracting control sequences from table...\n"
qiime feature-table filter-features \
  --i-table "$trpth"/"${in_tab[1]}" \
  --m-metadata-file "$trpth"/"$seq" \
  --p-exclude-ids \
  --o-filtered-table "$trpth"/"${out_tab[2]}" \
  --verbose
