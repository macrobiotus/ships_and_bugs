#!/usr/bin/env bash

# 20.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.


# for debugging only
# ------------------ 
# set -x


# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    export PATH=/programs/parallel/bin:$PATH
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi

# define input locations - sequence files
# ----------------------------------------

# Fill sequence array using find 
# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)

inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '???_18S_*_seq_*100*.qza' -print0)

# Sort array 
# (https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)

IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging -  print sorted input filenames
# printf '%s\n' "${inpth_seq[@]}"


# define output locations - sequence files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_seq=("${inpth_seq[@]}")

# create output filenames 
for i in "${!otpth_seq[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_seq[$i]")"
  seq_file_name_in="$(basename "${otpth_seq[$i]%.*}")"
  extension=".qza"
  
  # reconstruct string
  otpth_seq["$i"]="$directory/$seq_file_name_in"_110_alignment"$extension"
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
  seq_file_name_in="$(basename "${otpth_log[$i]%.*}")"
  extension=".txt"
  
  # reconstruct string
  otpth_log["$i"]="$directory/$seq_file_name_in"_log"$extension"
done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_log[@]}"


# Run scripts
# ------------

for k in "${!inpth_seq[@]}"; do
  
  printf "\n"
  printf "Alignining file ${inpth_seq[$k]}...\n"
  qiime alignment mafft \
    --i-sequences "${inpth_seq[$k]}" \
    --o-alignment "${otpth_seq[$k]}" \
    --p-n-threads "$thrds" \
    --verbose 2>&1 | tee -a "${otpth_log[$k]}"
    
done
