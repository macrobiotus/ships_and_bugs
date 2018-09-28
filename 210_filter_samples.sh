#!/bin/bash

# 03.05.2018 - Paul Czechowski - paul.czechowski@gmail.com 
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
    trpth="/data/CU_combined"
    qiime() { qiime2cli "$@"; }
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    cores='2'
fi

# Define input paths 
# ------------------

clust_tab[1]='Zenodo/Qiime/200_18S_100_cl_tab.qza'
clust_tab[2]='Zenodo/Qiime/200_18S_097_cl_tab.qza'
clust_tab[3]='Zenodo/Qiime/200_18S_090_cl_tab.qza'

clust_seq[1]='Zenodo/Qiime/200_18S_100_cl_seq.qza'
clust_seq[2]='Zenodo/Qiime/200_18S_097_cl_seq.qza'
clust_seq[3]='Zenodo/Qiime/200_18S_090_cl_seq.qza'

mapping[1]='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# Define output paths 
# -------------------
edna_tab[1]='Zenodo/Qiime/210_18S_100_cl_edna_tab.qza'
edna_tab[2]='Zenodo/Qiime/210_18S_097_cl_edna_tab.qza'
edna_tab[3]='Zenodo/Qiime/210_18S_090_cl_edna_tab.qza'

cntrl_tab[1]='Zenodo/Qiime/210_18S_100_cl_cntrl_tab.qza'
cntrl_tab[2]='Zenodo/Qiime/210_18S_097_cl_cntrl_tab.qza'
cntrl_tab[3]='Zenodo/Qiime/210_18S_090_cl_cntrl_tab.qza'

edna_seq[1]='Zenodo/Qiime/210_18S_100_cl_edna_seq.qza'
edna_seq[2]='Zenodo/Qiime/210_18S_097_cl_edna_seq.qza'
edna_seq[3]='Zenodo/Qiime/210_18S_090_cl_edna_seq.qza'

cntrl_seq[1]='Zenodo/Qiime/210_18S_100_cl_cntrl_seq.qza'
cntrl_seq[2]='Zenodo/Qiime/210_18S_097_cl_cntrl_seq.qza'
cntrl_seq[3]='Zenodo/Qiime/210_18S_090_cl_cntrl_seq.qza'

# Run scripts - ADJUST I
# ----------------------
for ((i=1;i<=3;i++)); do
  printf "isolate eDNA features\n"
  qiime feature-table filter-samples \
    --i-table "$trpth"/"${clust_tab[$i]}" \
    --m-metadata-file "$trpth"/"${mapping[1]}" \
    --p-min-frequency '1' \
    --p-min-features '1' \
    --p-where "Type='eDNA'" \
    --p-no-exclude-ids \
    --o-filtered-table "$trpth"/"${edna_tab[$i]}" \
    --verbose
done

for ((i=1;i<=3;i++)); do
  printf "isolate eDNA sequences\n"
  qiime feature-table filter-seqs \
    --i-data "$trpth"/"${clust_seq[$i]}" \
    --i-table "$trpth"/"${edna_tab[$i]}" \
    --p-no-exclude-ids \
    --o-filtered-data "$trpth"/"${edna_seq[$i]}" \
    --verbose
done

for ((i=1;i<=3;i++)); do
  printf "isolate control features\n"
  qiime feature-table filter-samples \
    --i-table "$trpth"/"${clust_tab[$i]}" \
    --p-min-frequency '1' \
    --p-min-features '1' \
    --p-where "Type='eDNA'" \
    --p-exclude-ids \
    --m-metadata-file "$trpth"/"${mapping[1]}" \
    --o-filtered-table "$trpth"/"${cntrl_tab[$i]}" \
    --verbose
done

for ((i=1;i<=3;i++)); do
  printf "isolate control sequences \n"
  qiime feature-table filter-seqs \
    --i-data "$trpth"/"${clust_seq[$i]}" \
    --i-table "$trpth"/"${cntrl_tab[$i]}" \
    --p-no-exclude-ids \
    --o-filtered-data "$trpth"/"${cntrl_seq[$i]}" \
    --verbose
done
