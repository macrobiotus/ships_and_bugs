#!/usr/bin/env bash

# 06.11.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.

# abort on error
# --------------- 
set -e

# Paths need to be adjusted for remote execution
# ==============================================
if [[ "$HOSTNAME" != "macmini.local" ]] && [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "macmini.local" ]]  || [[ "$HOSTNAME" = "macmini.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    cores="2"
fi

# define input locations - alignment files
# ----------------------------------------

# Fill sequence array using find 
# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)

inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '140_18S_*_alignment_masked.qza' -print0)

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
  input_qza_tmp="$(basename "${inpth_seq[$k]%.*}")"
  input_qza="145_${input_qza_tmp:4}"
  extension=".fasta"
  
  # reconstruct string
  otpth_seq[$k]="$directory/$input_qza$extension"
  
  # debugging 
  # printf '%s\n' "${otpth_seq[@]}"
  # continue
  
  # calling export function
  printf "\n${bold}$(date):${normal} Exporting file ${inpth_seq[$k]}...\n"
  
  # erase possibly existing  tempfile
  [ -f "$TMPDIR"/aligned-dna-sequences.fasta ] && rm "$TMPDIR"/aligned-dna-sequences.fasta
  
  # export file
  qiime tools export \
    --input-path  "${inpth_seq[$k]}" \
    --output-path "$TMPDIR" 
  
  mv "$TMPDIR"aligned-dna-sequences.fasta "${otpth_seq[$k]}"
  pigz "${otpth_seq[$k]}"
  
  # erase tempfile
  [ -f "$TMPDIR"/aligned-dna-sequences.fasta ] && rm "$TMPDIR"/aligned-dna-sequences.fasta

done
