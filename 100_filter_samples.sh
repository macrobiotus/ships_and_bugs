#!/usr/bin/env bash

# 29.03.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Isolate but keep control samples
#  for closer analysis and removal (via `qiime
#  feature-table filter-features`). Control evaluation cann then be done via 
#  (`decontam` Qiime plugin or R package and `evaluate-composition`)

# For debugging only
# ------------------ 
# set -x

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

# clustered input sequences
clust_tab[2]='Zenodo/Qiime/085_18S_097_cl_tab.qza'
clust_seq[2]='Zenodo/Qiime/085_18S_097_cl_seq.qza'

# checked mapping files
metad_tsv[2]='Zenodo/Manifest/05_18S_merged_metadata_checked.tsv' # (should be  `c1ca7209941aa96ee9ce9f843b629f98`)

# in last increment run via vsearch
tax_assignemnts[2]='Zenodo/Qiime/115_18S_taxonomy.qza'

# Define output paths 
# -------------------
edna_tab[2]='Zenodo/Qiime/100_18S_097_cl_edna_tab.qza'
cntrl_tab[2]='Zenodo/Qiime/100_18S_097_cl_cntrl_tab.qza'
metzn_tab[2]='Zenodo/Qiime/100_18S_097_cl_metzn_tab.qza'

edna_seq[2]='Zenodo/Qiime/100_18S_097_cl_edna_seq.qza'
cntrl_seq[2]='Zenodo/Qiime/100_18S_097_cl_cntrl_seq.qza'
metzn_seq[2]='Zenodo/Qiime/100_18S_097_cl_metzn_seq.qza'

# Run scripts 
# -----------
# (check that i is set correctly to loop over the intended files)
for ((i=2;i<=2;i++)); do
  printf "Isolating eDNA features...\n"
  qiime feature-table filter-samples \
    --i-table "$trpth"/"${clust_tab[$i]}" \
    --m-metadata-file "$trpth"/"${metad_tsv[1]}" \
    --p-min-frequency '1' \
    --p-min-features '1' \
    --p-where "Type='eDNA'" \
    --p-no-exclude-ids \
    --o-filtered-table "$trpth"/"${edna_tab[$i]}" \
    --verbose
  printf "Isolating eDNA sequences...\n"
  qiime feature-table filter-seqs \
    --i-data "$trpth"/"${clust_seq[$i]}" \
    --i-table "$trpth"/"${edna_tab[$i]}" \
    --p-no-exclude-ids \
    --o-filtered-data "$trpth"/"${edna_seq[$i]}" \
    --verbose
done

for ((i=2;i<=2;i++)); do 
  printf "Isolating control features...\n"
  qiime feature-table filter-samples \
    --i-table "$trpth"/"${clust_tab[$i]}" \
    --p-min-frequency '1' \
    --p-min-features '1' \
    --p-where "Type='eDNA'" \
    --p-exclude-ids \
    --m-metadata-file "$trpth"/"${mapping[1]}" \
    --o-filtered-table "$trpth"/"${cntrl_tab[$i]}" \
    --verbose
  printf "Isolating control sequences...\n"
  qiime feature-table filter-seqs \
    --i-data "$trpth"/"${clust_seq[$i]}" \
    --i-table "$trpth"/"${cntrl_tab[$i]}" \
    --p-no-exclude-ids \
    --o-filtered-data "$trpth"/"${cntrl_seq[$i]}" \
    --verbose
done

for ((i=2;i<=2;i++)); do
  printf "Isolating Metazoan features...\n"
  qiime taxa filter-table \
    --i-table "$trpth"/"${edna_tab[$i]}" \
    --p-include metazoa \
    --i-taxonomy "$trpth"/"$taxo" \
    --o-filtered-table "$trpth"/"${metzn_tab[$i]}" \
    --verbose

  printf "Isolating Metazoan sequences...\n"
  qiime taxa filter-seqs \
    --i-sequences "$trpth"/"${edna_seq[$i]}" \
    --i-taxonomy "$trpth"/"$taxo" \
    --p-include metazoa \
    --o-filtered-sequences "$trpth"/"${metzn_seq[$i]}" \
    --verbose
done
