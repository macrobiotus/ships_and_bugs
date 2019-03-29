#!/usr/bin/env bash

# 29.03.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

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

# database files - SILVA128 extended with Sanger sequences
# ---------------------------------------------------------

# import from
refdbseq="Zenodo/References/Silva128_extract_extended/99_otus_18S.fasta"
refdbtax="Zenodo/References/Silva128_extract_extended/majority_taxonomy_7_levels.txt"

# export to 
qiime_import_seq="Zenodo/Qiime/095_Silva128_Qiime_sequence_import.qza"
qiime_import_tax="Zenodo/Qiime/095_Silva128_Qiime_taxonomy_import.qza"

# query and assignment files
# --------------------------

# check thes sequences against reference data
query="Zenodo/Qiime/085_18S_097_cl_seq.qza"

# write taxonomic assignments to this file
tax_assignemnts="Zenodo/Qiime/095_18S_097_cl_seq_taxonomic_assigmnets.qza"

# rolling log
qiime_assign_log="Zenodo/Qiime/095_Silva128_Qiime_taxonomy_assignment_log.txt"

# Run scripts
# ------------
printf "Importing reference sequences into Qiime...\n"
qiime tools import \
  --input-path  "$trpth"/"$refdbseq"   \
  --output-path "$trpth"/"$qiime_import_seq"    \
  --type 'FeatureData[Sequence]' || { echo 'Reference data import failed' ; exit 1; }

printf "Importing reference taxonomy into Qiime...\n"
qiime tools import \
  --input-path  "$trpth"/"$refdbtax" \
  --output-path "$trpth"/"$qiime_import_tax" \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat || { echo 'Taxonomy import failed' ; exit 1; }

# Blast+ classifier - preliminarily adjusted with mock data (but Zebra fish only)
  qiime feature-classifier classify-consensus-blast \
    --i-reference-reads    "$trpth"/"$qiime_import_seq" \
    --i-reference-taxonomy "$trpth"/"$qiime_import_tax" \
    --i-query              "$trpth"/"$query" \
    --o-classification     "$trpth"/"$tax_assignemnts" \
    --p-maxaccepts 4 \
    --p-perc-identity 0.99 \
    --p-evalue 0.0000000001 \
    --p-min-consensus 0.75 \
    --verbose 2>&1 | tee -a "$trpth"/"$qiime_assign_log"
