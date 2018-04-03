#!/usr/local/bin/bash

# 02.04.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Blast fasta file against locally installed copy of NCBI nt database. Modified
# from https://stackoverflow.com/questions/45014279/running-locally-blastn-against-nt-db-thru-python-script


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
    dbpath="/workdir/pc683/BLAST_NCBI/nt"
    export PATH=/programs/ncbi-blast-2.3.0+/bin:$PATH
    blastn() { /programs/ncbi-blast-2.3.0+/bin/blastn "$@"; }
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    cores='2'
    blastn() { /usr/local/bin/blastn "$@"; }
    dbpath="/Users/paul/Sequences/References/blastdb/nt"
fi

# Define input paths and parameters for blasting 
# ----------------------------------------------
# find all .fasta files incl. their paths and put them into an array
#   see https://stackoverflow.com/questions/23356779/how-can-i-store-find-command-result-as-arrays-in-bash
fasta_files=()
while IFS=  read -r -d $'\0'; do
    fasta_files+=("$REPLY")
done < <(find "$trpth"/"Zenodo/Qiime" -type f \( -iname "dna-sequences.fasta" \) -print0)

# loop over array of fasta files, create result directory, call blast
# ----------------------------------------------------------------
for fasta in "${fasta_files[@]}";do
  
  # create result folders names
  filename=$(dirname "$fasta")
  src_dir=$(basename "$filename")
  tgt_dir="270${src_dir:3}_fasta_blast"
  
  # for debugging only 
  # printf "$trpth"/Zenodo/Qiime/"$tgt_dir\n"
  
  # don't know if blast will throw an error if directory in output path doesn't exist
  # blast locally - or else adjust -db flag and set -remote flag
  
  printf "Blastn started at $(date +"%T") ...\n" && \
  mkdir -p "$trpth"/Zenodo/Qiime/"$tgt_dir" && \
  blastn -query "$fasta" -task blastn -evalue 1e-5  \
    -max_target_seqs 5 -max_hsps 5 -db "$dbpath" \
    -outfmt 7 -html \
    -out "$trpth"/Zenodo/Qiime/"$tgt_dir"/blastn_results.txt \
    -num_threads "$cores" || \
    { printf "Blastn failed, aborting at $(date +"%T")\n" ; exit 1; }

done
