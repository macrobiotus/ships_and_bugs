#!/usr/bin/env bash

# 24.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Retain only samples needed for analysis 

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
fi

# Define input paths 
# ==================

# Fill table array using find 
# ---------------------------
in_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
    in_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '115_*_tab_*.qza' -print0)

# Sort array 
IFS=$'\n' in_tab=($(sort <<<"${in_tab_unsorted[*]}"))
unset IFS

# for debugging - works
# printf '%s\n' "${in_tab[@]}"
# exit

# Fill sequence array using find 
in_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    in_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '115_*_seq_*.qza' -print0)

# Sort array 
IFS=$'\n' in_seq=($(sort <<<"${in_seq_unsorted[*]}"))
unset IFS

# for debugging - works
# printf '%s\n' "${in_seq[@]}"
# exit


# Run scripts - loop over array of input paths
# ============================================


# loop over files
for i in "${!in_seq[@]}"; do
  
  # check if files can be mathced otherwise abort script because it would do more harm then good
  tabtest="$(basename "${in_tab[$i]//_tab/}")"
  seqtest="$(basename "${in_seq[$i]//_seq/}")"
  
  # for debugging - works
  # echo "$seqtest"
  # echo "$tabtest"
  # exit
  
  if [ "$seqtest" == "$tabtest" ]; then
    printf "${bold}$(date):${normal} Sequence- and table files have been matched, continuing...\n"
    
    # for debugging - get input table file name - works 
    # echo "${in_tab[$i]}"
    # exit

    # for debugging - get input sequence file name - works
    # echo "${in_seq[$i]}"
    # exit

    directory="$(dirname "${in_seq[$i]}")"
    
    in_tab_tmp="$(basename "${in_tab[$i]}")"
    tab_file_name="${in_tab_tmp:4}"

    
    in_seq_tmp="$(basename "${in_seq[$i]}")"
    seq_file_name="${in_seq_tmp:4}"

    # for debugging - check string construction - works
    # echo "$in_tab_tmp"
    # echo "$in_seq_tmp"
    # exit
    
    # echo "$tab_file_name"
    # echo "$seq_file_name"
    # exit
    

    out_tab_path="$directory/128_$tab_file_name"
    out_seq_path="$directory/128_$seq_file_name"
    
   # for debugging - check string construction - works
   # echo "$out_tab_path"
   # echo "$out_seq_path"
   # exit
 
   if [ ! -f "$out_seq_path" ]; then
     
     printf "${bold}$(date):${normal} Subsetting eDNA features of file \"$(basename "${in_tab[$i]}")\"...\n"
     
     # setting correct sampling selection file
     if [[ "${in_tab[$i]}" == *"shallow"* ]]; then
       mf="Zenodo/Manifest/127_18S_5-sample-euk-metadata_shll_all.tsv"
       printf "${bold}Detected shallow set, using:${normal} $trpth/$mf \n"
     elif [[ "${in_tab[$i]}" != *"shallow"* ]]; then
       mf="Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_all.tsv"
       printf "${bold}Using normal sample set:${normal} $trpth/$mf \n"
     fi
     
     # see https://docs.qiime2.org/2018.6/tutorials/filtering/#identifier-based-filtering
     #   section `Identifier-based filtering`
     qiime feature-table filter-samples \
       --i-table "${in_tab[$i]}" \
       --m-metadata-file "$trpth"/"$mf" \
       --p-min-features '1' \
       --o-filtered-table "$out_tab_path" \
       --verbose

     printf "${bold}$(date):${normal} Subsetting eDNA sequences of file \"$(basename "${in_seq[$i]}")\"...\n"
     qiime feature-table filter-seqs \
       --i-data "${in_seq[$i]}" \
       --i-table "$out_tab_path" \
       --o-filtered-data "$out_seq_path" \
       --verbose
      
   else

        # diagnostic message
        printf "${bold}$(date):${normal} File \"$(basename "$out_seq_path")\" already available, skipping.\n"

   fi

  else
  
    echo "Sequence- and table files can't be matched, aborting."
    exit
  
  fi

done
