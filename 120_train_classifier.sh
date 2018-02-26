#!/bin/bash

# 19.01.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

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

# define input and output locations
# --------------------------------
wdir="Zenodo/Classifier"
mkdir -p "$trpth"/"$wdir"

# primers
# -------
p18S952R='TTGGCAAATGCTTTCGC'
p18S574F='GCGGTAATTCCAGCTCCAA'

# database files
# --------------
taxdbseq="/Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta"
taxdbmed="/Users/paul/Sequences/References/SILVA_128_QIIME_release/taxonomy/18S_only/99/majority_taxonomy_7_levels.txt"

# target files
# ------------
seqf="120_18S_otus.qza"
taxf="120_18S_ref-taxonomy.qza"
refseq="120_18S_ref-seqs.qza"
clssf="120_18S_classifier.qza"

# Run scripts
# ------------
printf "Importing reference sequences into Qiime...\n"
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path "$taxdbseq" \
  --output-path "$trpth"/"$wdir"/"$seqf"

printf "Importing reference taxonomy into Qiime...\n"
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --source-format HeaderlessTSVTaxonomyFormat \
  --input-path "$taxdbmed" \
  --output-path "$trpth"/"$wdir"/"$taxf"

printf "Extracting reference reads from database, using primers...\n"
qiime feature-classifier extract-reads \
  --i-sequences "$trpth"/"$wdir"/"$seqf" \
  --p-f-primer "$p18S952R" \
  --p-r-primer "$p18S574F"\
  --p-trunc-len 500 \
  --o-reads "$trpth"/"$wdir"/"$refseq"

printf "Training classifier...\n"  
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads "$trpth"/"$wdir"/"$refseq" \
  --i-reference-taxonomy "$trpth"/"$wdir"/"$taxf" \
  --o-classifier "$trpth"/"$wdir"/"$clssf"
