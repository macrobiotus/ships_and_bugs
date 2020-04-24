#!/usr/bin/env bash

# 24.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# For debugging only
# ------------------ 
# set -x
set -e
set -u

# Paths need to be adjusted for remote execution
# ==============================================
if [[ "$HOSTNAME" != "Pauls-MacBook-Pro.local" ]] && [[ "$HOSTNAME" != "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "Pauls-MacBook-Pro.local" ]]  || [[ "$HOSTNAME" = "macmini-fastpost.staff.uod.otago.ac.nz" ]]; then
    bold=$(tput bold)
    normal=$(tput sgr0)
    printf "${bold}$(date):${normal} Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    cores='2'
fi

# define input locations - sequence files
# ----------------------------------------

# Fill sequence array using find 
# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)

inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '135_18S_*_seq_*_alignment.qza' -print0)

# Sort array 
# (https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)

IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging -  print sorted input filenames
# printf '%s\n' "${inpth_seq[@]}"
# exit

# define output locations - alignment files
# -----------------------------------------

# copy previous array to create array for output file names
otpth_seq=("${inpth_seq[@]}")

# create output filenames 
for i in "${!otpth_seq[@]}"; do

  # deconstruct string
  directory="$(dirname "$otpth_seq[$i]")"
  seq_file_tmp="$(basename "${otpth_seq[$i]%.*}")"
  seq_file_name="140_${seq_file_tmp:4}"
  extension="${otpth_seq[$i]##*.}"                                  # get the extension
  otpth_seq[$i]="$directory"/"${seq_file_name}_masked.${extension}" # get name string

done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_seq[@]}"

# define output locations - log files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_log=("${otpth_seq[@]}")

# create output filenames 
for i in "${!otpth_log[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_log[$i]")"
  seq_file_tmp="$(basename "${otpth_log[$i]%.*}")"
  seq_file_name="140_${seq_file_tmp:4}"
  extension=".txt"                                               # get the extension
  otpth_log[$i]="$directory"/"${seq_file_name}_log${extension}" # get name string    
  
done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_log[@]}"

# exit

# Run scripts
# ------------

for k in "${!inpth_seq[@]}"; do
  
  # actual filtering
  # continue only if output file isn't already there
  if [ ! -f "${otpth_seq[$k]}" ]; then

    printf "\n${bold}$(date):${normal} Masking alignment file ${inpth_seq[$k]}...\n"
    qiime alignment mask \
      --i-alignment "${inpth_seq[$k]}" \
      --o-masked-alignment "${otpth_seq[$k]}" \
      --p-min-conservation 0.5 \
      --p-max-gap-frequency 0.1 \
      --verbose 2>&1 | tee -a "${otpth_log[$k]}"

  else
 
    # diagnostic message
    printf "${bold}$(date):${normal} Analysis already done for \"$(basename "${inpth_seq[$k]}")\"...\n"

  fi

done
