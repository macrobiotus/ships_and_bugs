#!/bin/bash

# 19.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Converting clustering results to biom files for Qiime 1 and
# network graphics.

# For debugging only
# ------------------ 
set -x

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

# Define input files
# ------------------
clust_tab[1]='Zenodo/Qiime/500_18S_100_cl_tab.qza'
clust_tab[2]='Zenodo/Qiime/500_18S_099_cl_tab.qza'
clust_tab[3]='Zenodo/Qiime/500_18S_098_cl_tab.qza'
clust_tab[4]='Zenodo/Qiime/500_18S_097_cl_tab.qza'
clust_tab[5]='Zenodo/Qiime/500_18S_096_cl_tab.qza'
clust_tab[6]='Zenodo/Qiime/500_18S_095_cl_tab.qza'
clust_tab[7]='Zenodo/Qiime/500_18S_090_cl_tab.qza'

clust_seq[1]='Zenodo/Qiime/500_18S_100_cl_seq.qza'
clust_seq[2]='Zenodo/Qiime/500_18S_099_cl_seq.qza'
clust_seq[3]='Zenodo/Qiime/500_18S_098_cl_seq.qza'
clust_seq[4]='Zenodo/Qiime/500_18S_097_cl_seq.qza'
clust_seq[5]='Zenodo/Qiime/500_18S_096_cl_seq.qza'
clust_seq[6]='Zenodo/Qiime/500_18S_095_cl_seq.qza'
clust_seq[7]='Zenodo/Qiime/500_18S_090_cl_seq.qza'

clust_tax[1]='Zenodo/Qiime/510_18S_100_cl_tax.qza'
clust_tax[2]='Zenodo/Qiime/510_18S_099_cl_tax.qza'
clust_tax[3]='Zenodo/Qiime/510_18S_098_cl_tax.qza'
clust_tax[4]='Zenodo/Qiime/510_18S_097_cl_tax.qza'
clust_tax[5]='Zenodo/Qiime/510_18S_096_cl_tax.qza'
clust_tax[6]='Zenodo/Qiime/510_18S_095_cl_tax.qza'
clust_tax[7]='Zenodo/Qiime/510_18S_090_cl_tax.qza'

mptpth='Zenodo/Qiime/100_18S_tree_mdp_root.qza'
mappng='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# Define output files files
# -------------------------
clust_exp[1]='Zenodo/Qiime/520_18S_100_cl_q1exp'
clust_exp[2]='Zenodo/Qiime/520_18S_099_cl_q1exp'
clust_exp[3]='Zenodo/Qiime/520_18S_098_cl_q1exp'
clust_exp[4]='Zenodo/Qiime/520_18S_097_cl_q1exp'
clust_exp[5]='Zenodo/Qiime/520_18S_096_cl_q1exp'
clust_exp[6]='Zenodo/Qiime/520_18S_095_cl_q1exp'
clust_exp[7]='Zenodo/Qiime/520_18S_090_cl_q1exp'

ottre="520_18S_tree_midpoint_root.tre"


for ((i=1;i<=7;i++)); do
   
   printf "Exporting Qiime 2 files at $(date +"%T")...\n"
   qiime tools export "$trpth"/"${clust_tab[$i]}" --output-dir "$trpth"/"${clust_exp[$i]}" && \
   qiime tools export "$trpth"/"${clust_seq[$i]}" --output-dir "$trpth"/"${clust_exp[$i]}" && \
   qiime tools export "$trpth"/"${clust_tax[$i]}" --output-dir "$trpth"/"${clust_exp[$i]}" && \
   unzip -p "$trpth"/"$mptpth" > "$trpth"/"${clust_exp[$i]}"/"$ottre" || { echo 'export failed' ; exit 1; }
   
   printf "Modifying taxonomy file to match exported feature table at $(date +"%T") ...\n" && \
   new_header='#OTUID  taxonomy    confidence' && \
   sed -i.bak "1 s/^.*$/$new_header/" "$trpth"/"${clust_exp[$i]}"/taxonomy.tsv || { echo 'edit failed' ; exit 1; }
   
   printf "Adding taxonomy information to .biom file at $(date +"%T") ...\n"
   biom add-metadata \
     -i "$trpth"/"${clust_exp[$i]}"/feature-table.biom \
     -o "$trpth"/"${clust_exp[$i]}"/features-tax.biom \
     --observation-metadata-fp "$trpth"/"${clust_exp[$i]}"/taxonomy.tsv \
     --observation-header OTUID,taxonomy,confidence \
     --sc-separated taxonomy || { echo 'taxonomy addition failed' ; exit 1; }
   
   printf "Adding metadata information to .biom file at $(date +"%T")...\n"
   biom add-metadata \
     -i "$trpth"/"${clust_exp[$i]}"/features-tax.biom \
     -o "$trpth"/"${clust_exp[$i]}"/features-tax-meta.biom \
     --sample-metadata-fp "$trpth"/"$mappng" \
     --observation-header OTUID,taxonomy,confidence || { echo 'metadata addition failed' ; exit 1; }
done
