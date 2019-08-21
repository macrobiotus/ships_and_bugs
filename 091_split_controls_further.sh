#!/usr/bin/env bash

# 21.08.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Retain only samples needed for analysis 

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Define input paths 
# ------------------
# define more arrays for other files if needed

# input table and sequences
in_seq='Zenodo/Qiime/090_18S_controls_seq.qza'
in_tab='Zenodo/Qiime/090_18S_controls_tab.qza'

# checked mapping files
map='Zenodo/Manifest/06_18S_merged_metadata.tsv' 

# Define output paths 
# -------------------
out_seq[1]='Zenodo/Qiime/091_18S_neg_controls_seq.qza'
out_tab[1]='Zenodo/Qiime/091_18S_neg_controls_tab.qza'

out_seq[2]='Zenodo/Qiime/091_18S_pos_controls_seq.qza'
out_tab[2]='Zenodo/Qiime/091_18S_pos_controls_tab.qza'

# Run scripts 
# -----------

printf "Isolating positive control features...\n"
qiime feature-table filter-samples \
  --i-table "$trpth"/"$in_tab" \
  --m-metadata-file "$trpth"/"$map" \
  --p-min-frequency '1' \
  --p-min-features '1' \
  --p-exclude-ids \
  --p-where "Type IN ('moc')" \
  --o-filtered-table "$trpth"/"${out_tab[1]}" \
  --verbose

printf "Isolating positive control sequences...\n"
qiime feature-table filter-seqs \
  --i-data "$trpth"/"$in_seq" \
  --i-table "$trpth"/"${out_tab[1]}" \
  --o-filtered-data "$trpth"/"${out_seq[1]}" \
  --verbose

printf "Isolating negative control features...\n"
qiime feature-table filter-samples \
  --i-table "$trpth"/"$in_tab" \
  --m-metadata-file "$trpth"/"$map" \
  --p-min-frequency '1' \
  --p-min-features '1' \
  --p-no-exclude-ids \
  --p-where "Type IN ('moc')" \
  --o-filtered-table "$trpth"/"${out_tab[2]}" \
  --verbose

printf "Isolating negative control features...\n"
qiime feature-table filter-seqs \
  --i-data "$trpth"/"$in_seq" \
  --i-table "$trpth"/"${out_tab[2]}" \
  --o-filtered-data "$trpth"/"${out_seq[2]}" \
  --verbose
