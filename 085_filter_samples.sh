#!/usr/bin/env bash

# 18.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Retain only samples needed for analysis 

# For debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Define input paths 
# ------------------
# define more arrays for other files if needed

# input sequences
in_tab[1]='Zenodo/Qiime/065_18S_merged_tab.qza'
in_tab[2]='Zenodo/Qiime/065_18S_merged_tab.qza'

in_seq[1]='Zenodo/Qiime/065_18S_merged_seq.qza'
in_seq[2]='Zenodo/Qiime/065_18S_merged_seq.qza'

# checked mapping files
map[1]='Zenodo/Manifest/06_18S_merged_metadata.tsv' 
map[2]='Zenodo/Manifest/06_18S_merged_metadata.tsv' 

# Define output paths 
# -------------------
out_tab[1]='Zenodo/Qiime/085_18S_Milne_Inlet_tab.qza'
out_tab[2]='Zenodo/Qiime/085_18S_all_samples_tab.qza'

out_seq[1]='Zenodo/Qiime/085_18S_Milne_Inlet_seq.qza'
out_seq[2]='Zenodo/Qiime/085_18S_all_samples_seq.qza'

# Run scripts 
# -----------

printf "Isolating Arctic features...\n"
qiime feature-table filter-samples \
  --i-table "$trpth"/"${in_tab[1]}" \
  --m-metadata-file "$trpth"/"${map[1]}" \
  --p-min-frequency '1' \
  --p-min-features '1' \
  --p-no-exclude-ids \
  --p-where "Port IN ('Milne_Inlet')" \
  --o-filtered-table "$trpth"/"${out_tab[1]}" \
  --verbose

printf "Isolating Arctic sequences...\n"
qiime feature-table filter-seqs \
  --i-data "$trpth"/"${in_seq[1]}" \
  --i-table "$trpth"/"${out_tab[1]}" \
  --p-where "Port IN ('Milne_Inlet')" \
  --p-no-exclude-ids \
  --o-filtered-data "$trpth"/"${out_seq[1]}" \
  --verbose


printf "Isolating project features...\n"
qiime feature-table filter-samples \
  --i-table "$trpth"/"${in_tab[2]}" \
  --m-metadata-file "$trpth"/"${map[2]}" \
  --p-min-frequency '1' \
  --p-min-features '1' \
  --p-exclude-ids \
  --p-where "Port IN ('Milne_Inlet','unknown','nowhere')" \
  --o-filtered-table "$trpth"/"${out_tab[2]}" \
  --verbose

printf "Isolating project sequences...\n"
qiime feature-table filter-seqs \
  --i-data "$trpth"/"${in_seq[2]}" \
  --i-table "$trpth"/"${out_tab[2]}" \
  --p-exclude-ids \
  --p-where "Port IN ('Milne_Inlet','unknown','nowhere')" \
  --o-filtered-data "$trpth"/"${out_seq[2]}" \
  --verbose

