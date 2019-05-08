#!/usr/bin/env bash

# 21.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Export alignments, e.g. for pretty printing


# for debugging only
# ------------------ 
# set -x


# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
    export PATH=/programs/parallel/bin:$PATH
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    cores='2'
fi


# define input locations - alignment files
# ----------------------------------------

# Fill sequence array using find 
# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)

inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '???_18S_*_seq_*100*110_alignment_115_masked.qza' -print0)

# Sort array 
# (https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)

IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging -  print sorted input filenames
# printf '%s\n' "${inpth_seq[@]}"

# Run scripts
# ------------

for k in "${!inpth_seq[@]}"; do

  # deconstruct string
  directory="$(dirname "$inpth_seq[$k]")"
  input_qza="$(basename "${inpth_seq[$k]%.*}")"
  extension=".fasta"
  
  # reconstruct string
  otpth_seq[$k]="$directory/$input_qza$extension"
  
  # calling export function
  printf "\n"
  printf "Exporting  file ${inpth_seq[$k]}...\n"
  
  # erase possibly existing  tempfile
  [ -f "$TMPDIR"/aligned-dna-sequences.fasta ] && rm "$TMPDIR"/aligned-dna-sequences.fasta
  
  # export file
  qiime tools export \
    --input-path  "${inpth_seq[$k]}" \
    --output-path "$TMPDIR" 
  
  mv "$TMPDIR"aligned-dna-sequences.fasta "${otpth_seq[$k]}"
  
  # erase tempfile
  [ -f "$TMPDIR"/aligned-dna-sequences.fasta ] && rm "$TMPDIR"/aligned-dna-sequences.fasta

done
