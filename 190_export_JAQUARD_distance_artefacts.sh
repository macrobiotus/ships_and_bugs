#!/usr/bin/env bash

# 27.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
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

# define relative input and output locations
# ==========================================

# Find all distance matrices and put into arrayinpth_matrix_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_matrix_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name 'jaccard_distance_matrix.qza' -print0)

# Sort array 
IFS=$'\n' inpth_matrix=($(sort <<<"${inpth_matrix_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_matrix[@]}"
# exit

# Find all pcoa result files and put into array
inpth_pcoa_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_pcoa_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name 'jaccard_pcoa_results.qza' -print0)

# Sort array 
IFS=$'\n' inpth_pcoa=($(sort <<<"${inpth_pcoa_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_pcoa[@]}"

# exit

# run script
# ==========

for i in "${!inpth_matrix[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  matxstump="$(dirname "${inpth_matrix[$i]}")"
  pcoastump="$(dirname "${inpth_pcoa[$i]}")"
  
  # echo "$matxstump"
  # echo "$pcoastump"
  
  if [ "$matxstump" == "$pcoastump" ]; then

    # diagnostic only 
    echo "Matrix- and PCOA files have been matched, continuing..."
    
    # create path for output directory
    results_tmp=$(dirname "${inpth_matrix[$i]}")
    results_tmp=$(basename "$results_tmp")
    results_tmp=${results_tmp:4}
    results_dir="$trpth/Zenodo/Qiime/190_"$results_tmp"_JAQUARD_distance_artefacts"
    # echo "$results_dir"
    
    if [ ! -d "$results_dir" ]; then

      mkdir -p "$results_dir"
    
      # create output filenames - pcoa
      tmp_pcoa="${inpth_pcoa[$i]:0:-4}"
      results_pcoa="190_"$(basename "$tmp_pcoa")".txt"
    
      # create output filenames - matrix
      tmp_matx="${inpth_matrix[$i]:0:-4}"
      results_matx="190_"$(basename "$tmp_matx")".tsv"
    
      printf "${bold}$(date):${normal} Exporting \"$(basename "${inpth_pcoa[$i]}")\".\n"
      # erase possibly existing temp files
      rm -f "$TMPDIR"ordination.txt
      # export to temp file
      qiime tools export \
        --input-path  "${inpth_pcoa[$i]}" \
        --output-path "$TMPDIR"
      # move temp file in place
      mv "$TMPDIR"ordination.txt "$results_dir"/"$results_pcoa"

      printf "${bold}$(date):${normal} Exporting \"$(basename "${inpth_matrix[$i]}")\".\n"
      # erase possibly existing temp files
      rm -f "$TMPDIR"distance-matrix.tsv 
      # export to temp file
      qiime tools export \
        --input-path  "${inpth_matrix[$i]}" \
        --output-path "$TMPDIR"
      # move temp file in place
      mv "$TMPDIR"distance-matrix.tsv "$results_dir"/"$results_matx"
   
    else

    # diagnostic message
    printf "${bold}$(date):${normal} Detected readily available results, skipping export of one file set.\n"

  fi

  else

    echo "Matrix- and PCOA files can't be  matched, aborting."
    exit

  fi
  
done
