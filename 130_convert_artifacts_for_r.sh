#!/usr/bin/env bash

# 03.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Converting clustering results to biom files for Qiime 1 and
# network graphics. (Trees are neglected here, they can be incorporated
# later if this is deemed desirable for clusters)

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
    cores="$(nproc --all)"
fi

# Define input files
# ------------------

map_file='Zenodo/Manifest/05_18S_merged_metadata_checked.tsv' # (after correction: `9704c8ce6cf9f8acbd08c88d124b4a5b`)
tax_file='Zenodo/Qiime/095_18S_097_cl_seq_taxonomic_assigmnets.qza'
seq_file='Zenodo/Qiime/100_18S_097_cl_metzn_seq.qza'
tab_file='Zenodo/Qiime/100_18S_097_cl_metzn_tab.qza'
tree_file='Zenodo/Qiime/115_18S_097_cl_tree_mid.qza'

biom_dir='Zenodo/Qiime/130_18S_097_cl_metazoan_biom_export' 
tree_out='130_18S_097_cl_metazoan_tree'

# Run scripts
# ------------
printf "Exporting Qiime 2 files at $(date +"%T")...\n"
qiime tools export --input-path "$trpth"/"$tab_file" --output-path "$trpth"/"$biom_dir" && \
qiime tools export --input-path "$trpth"/"$seq_file" --output-path "$trpth"/"$biom_dir" && \
qiime tools export --input-path "$trpth"/"$tax_file" --output-path "$trpth"/"$biom_dir" || \
{ echo 'Export failed' ; exit 1; }
 
# Tree unzipping is not implemented
qiime tools export --input-path "$trpth"/"$tree_file" --output-path "$trpth"/"$biom_dir"/"$tree_out"
 
printf "Modifying taxonomy file to match exported feature table at $(date +"%T") ...\n" && \
new_header='#OTUID  taxonomy    confidence' && \
sed -i.bak "1 s/^.*$/$new_header/" "$trpth"/"$biom_dir"/taxonomy.tsv || { echo 'Edit failed' ; exit 1; }
  
printf "Adding taxonomy information to .biom file at $(date +"%T") ...\n"
biom add-metadata \
  -i "$trpth"/"$biom_dir"/feature-table.biom \
  -o "$trpth"/"$biom_dir"/features-tax.biom \
  --observation-metadata-fp "$trpth"/"$biom_dir"/taxonomy.tsv \
  --observation-header OTUID,taxonomy,confidence \
  --sc-separated taxonomy || { echo 'taxonomy addition failed' ; exit 1; }
  
printf "Adding metadata information to .biom file at $(date +"%T")...\n"
  biom add-metadata \
  -i "$trpth"/"$biom_dir"/features-tax.biom \
  -o "$trpth"/"$biom_dir"/features-tax-meta.biom \
  -m "$trpth"/"$map_file" \
  --observation-header OTUID,taxonomy,confidence \
  --sample-header SampleID,BarcodeSequence,LinkerPrimerSequence,Port,Location,Type,Temp,Sali,Lati,Long,Run,Facility,CollYear || { echo 'metadata addition failed' ; exit 1; }
