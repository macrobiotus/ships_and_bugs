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
in_tab[1]='Zenodo/Qiime/085_18S_all_samples_tab.qza'
in_seq[1]='Zenodo/Qiime/085_18S_all_samples_seq.qza'

# checked mapping files
map[1]='Zenodo/Manifest/06_18S_merged_metadata.tsv' 

# Define output paths 
# -------------------
out_tab[1]='Zenodo/Qiime/090_18S_controls_tab.qza'
out_seq[1]='Zenodo/Qiime/090_18S_controls_seq.qza'

out_tab[2]='Zenodo/Qiime/090_18S_eDNA_samples_tab.qza'
out_seq[2]='Zenodo/Qiime/090_18S_eDNA_samples_seq.qza'

# Run scripts 
# -----------

printf "Isolating control features...\n"
qiime feature-table filter-samples \
  --i-table "$trpth"/"${in_tab[1]}" \
  --m-metadata-file "$trpth"/"${map[1]}" \
  --p-min-frequency '1' \
  --p-min-features '1' \
  --p-exclude-ids \
  --p-where "Type IN ('eDNA')" \
  --o-filtered-table "$trpth"/"${out_tab[1]}" \
  --verbose

printf "Isolating control sequences...\n"
qiime feature-table filter-seqs \
  --i-data "$trpth"/"${in_seq[1]}" \
  --i-table "$trpth"/"${out_tab[1]}" \
  --o-filtered-data "$trpth"/"${out_seq[1]}" \
  --verbose

# printf "Isolating eDNA features...\n"
# qiime feature-table filter-samples \
#   --i-table "$trpth"/"${in_tab[1]}" \
#   --m-metadata-file "$trpth"/"${map[1]}" \
#   --p-min-frequency '1' \
#   --p-min-features '1' \
#   --p-no-exclude-ids \
#   --p-where "Type IN ('eDNA')" \
#   --o-filtered-table "$trpth"/"${out_tab[2]}" \
#   --verbose
# 
# printf "Isolating eDNA sequences...\n"
# qiime feature-table filter-seqs \
#   --i-data "$trpth"/"${in_seq[1]}" \
#   --i-table "$trpth"/"${out_tab[2]}" \
#   --p-where "Type IN ('eDNA')" \
#   --o-filtered-data "$trpth"/"${out_seq[2]}" \
#   --verbose
