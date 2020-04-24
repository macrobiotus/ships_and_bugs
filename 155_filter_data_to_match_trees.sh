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

# define relative input locations - tree files
# --------------------------------------------

# Fill sequence array using find 
inpth_tree_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_tree_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '150_18S_*_alignment_masked_tree_rooted.qza' -print0)

# Sort array 
IFS=$'\n' inpth_tree=($(sort <<<"${inpth_tree_unsorted[*]}"))
unset IFS

# for debugging  - print sequence file names sorted - 16
# printf '%s\n' "Sorted tree files in array:"
# printf '%s\n' "${inpth_tree[@]}"

# define relative input locations - feature tables
# ------------------------------------------------

# Fill table array using find 
inpth_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
     inpth_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '128_18S_*_tab_*.qza' -print0)
 
# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n' "Sorted feature files in array:"
# printf '%s\n' "${inpth_tab[@]}"

# define relative input locations - sequence files
# ------------------------------------------------

# could't get regex in find command correctly os had to hard-code

# Fill table array using find 
inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '128_18S_*_seq_*.qza' -print0)

# Sort array 
IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging -  print sorted input filenames
# printf '%s\n' "Sorted sequence files in array:"
# printf '%s\n' "${inpth_seq[@]}"

# define relative input locations - other files
# ---------------------------------------------

# omitting filtering alignments and masked alignments as those are not needed downstream

# loop over filtering parameters, and corresponding file name names additions
for i in "${!inpth_tree[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tretmp="$(basename "${inpth_tree[$i]//_alignment_masked_tree_rooted/}")"
  tretmp="${tretmp:4}"
  trestump="${tretmp//_seq/}"
  seqstump="$(basename "${inpth_seq[$i]//_seq/}")"
  seqstump="${seqstump:4}"
  tabstump="$(basename "${inpth_tab[$i]//_tab/}")"
  tabstump="${tabstump:4}"
  
  # echo "$trestump"
  # echo "$seqstump"
  # echo "$tabstump"
  # exit
  
  if [ "$seqstump" == "$tabstump" -a "$seqstump" == "$trestump" -a "$tabstump" == "$trestump" ]; then
  
    # diagnostic only 
    # echo "$trestump"
    # echo "$seqstump"
    # echo "$tabstump"
    printf "\n${bold}$(date):${normal} Sequence-, feature-, and tree files have been matched, continuing..."
    # continue
       
    # get input sequence file name - for debugging 
    # echo "${inpth_tree[$i]}"
    
    # get input sequence file name - for debugging 
    # echo "${inpth_seq[$i]}"
    
    # get input table file name  - for debugging
    # echo "${inpth_tab[$i]}"
    
    # create output file names
    
    tre_file_name="$(dirname "${inpth_tree[$i]}")"/155_"${trestump:4:-4}"_tree.qza
    seq_file_name="$(dirname "${inpth_seq[$i]}")"/155_"${seqstump:4:-4}"_sequences_tree-matched.qza
    tab_file_name="$(dirname "${inpth_tab[$i]}")"/155_"${tabstump:4:-4}"_features_tree-matched.qza
    
    # echo "$tre_file_name"
    # echo "$seq_file_name"
    # echo "$tab_file_name"
    # continue
    
    if [ ! -f "$seq_file_name" ]; then
    
      # Qiime calls: Remove features from a feature table if their identifiers are not tip
      # identifiers in tree.
        
      printf "\n${bold}$(date):${normal} Copying tree file to have new name available...\n"
      cp "${inpth_tree[$i]}" "$tre_file_name"
    
      printf "\n${bold}$(date):${normal} Filtering feature table to match tree...\n"
      qiime phylogeny filter-table \
        --i-table "${inpth_tab[$i]}" \
        --i-tree "$tre_file_name" \
        --o-filtered-table "$tab_file_name" \
        --verbose
    
      printf "\n${bold}$(date):${normal} Using feature table to yield unaligned sequences matching tree...\n"
      qiime feature-table filter-seqs \
        --i-data "${inpth_seq[$i]}" \
        --i-table "$tab_file_name" \
        --o-filtered-data "$seq_file_name" \
        --verbose
    
    else
 
      # diagnostic message
      printf "${bold}$(date):${normal} Analysis already done for \"$(basename "${inpth_tab[$i]}")\"...\n"

    fi
    

  else
  
    echo "Sequence- and table files can't be matched, aborting."
    exit
  
  fi
  
done
