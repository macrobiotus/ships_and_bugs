#!/usr/bin/env bash

# 06.11.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

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

# define relative input locations - Qiime files
# --------------------------------------------------------
inpth_map='Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_all.tsv'
inpth_tax='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'

# define relative input locations - sequence files
# -----------------------------------------------------------

# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)
# (https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)

# Fill sequence array using find 
inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" \( -name '155_*_sequences_tree-matched.qza' \) -print0)

# for debugging - print unsorted sequences
# printf '%s\n'
# printf '%s\n' "${inpth_seq_unsorted[@]}"

# Sort array 
IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging  - print sorted sequences - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_seq[@]}"

# define relative input locations - feature tables
# ------------------------------------------------

# Fill table array using find 
inpth_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" \( -name '155_*_features_tree-matched.qza' \) -print0)

# for debugging -  print unsorted tables
# printf '%s\n'
# printf '%s\n' "${inpth_tab_unsorted[@]}"

# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_tab[@]}"

# define relative output locations - feature tables
# otpth_tabv='Zenodo/Qiime/080_18S_denoised_tab_vis.qzv'
# otpth_seqv='Zenodo/Qiime/080_18S_denoised_seq_vis.qzv'
# otpth_bplv='Zenodo/Qiime/080_18S_denoised_tax_vis.qzv'

# loop over filtering parameters, and corresponding file name names additions
for i in "${!inpth_seq[@]}"; do

  # check if files can be mathced otherwise abort script because it would do more harm then good
  seqtest="$(basename "${inpth_seq[$i]//_sequences_tree-matched/}")"
  tabtest="$(basename "${inpth_tab[$i]//_features_tree-matched/}")"
  
  # for debugging
  # echo "$seqtest"
  # echo "$tabtest"
  # continue
  
  if [ "$seqtest" == "$tabtest" ]; then
    echo "Sequence- and table files have been matched, continuing..."
  
    # get input sequence file name - for debugging 
    # echo "${inpth_seq[$i]}"
    
    # get input table file name  - for debugging
    # echo "${inpth_tab[$i]}"
    
    directory="$(dirname "$inpth_seq[$i]")"
    seq_file_tmp="$(basename "${inpth_seq[$i]%.*}")"
    seq_file_name="${seq_file_tmp:4}"
    
    tab_file_tmp="$(basename "${inpth_tab[$i]%.*}")"
    tab_file_name="${tab_file_tmp:4}"
    
    plot_file_temp="$(basename "${inpth_seq[$i]//_sequences/}")"
    plot_file_temp="${plot_file_temp:4}"
    plot_file_name="${plot_file_temp%.*}"
    
    extension=".qzv"
    
    # check string construction - for debugging
    # echo "$seq_file_name"
    # echo "$tab_file_name"
    # echo "$plot_file_name"
    
    seq_file_vis_path="$directory/165_$seq_file_name""$extension"
    tab_file_vis_path="$directory/165_$tab_file_name""$extension"
    plot_file_vis_path="$directory/165_$plot_file_name"_barplot"$extension"
    
    # check string construction - for debugging
    # echo "$seq_file_vis_path"
    # echo "$tab_file_vis_path"
    # echo "$plot_file_vis_path"
    
    # Qiime calls
    printf "\n${bold}$(date):${normal} Calling Qiime in iteration $i..."
    
    if [ ! -f "$plot_file_vis_path" ]; then
    
      qiime feature-table tabulate-seqs \
        --i-data "${inpth_seq[$i]}" \
        --o-visualization "$seq_file_vis_path" \
        --verbose

      qiime feature-table summarize \
        --m-sample-metadata-file "$trpth"/"$inpth_map" \
        --i-table "${inpth_tab[$i]}" \
        --o-visualization "$tab_file_vis_path" \
        --verbose
 
      qiime taxa barplot \
        --m-metadata-file "$trpth"/"$inpth_map" \
        --i-taxonomy "$trpth"/"$inpth_tax" \
        --i-table "${inpth_tab[$i]}" \
        --o-visualization "$plot_file_vis_path" \
        --verbose
            
    else

      # diagnostic message
      printf "${bold}$(date):${normal} Summary unnecessary for current triplett, skipping...\n"

    fi

  else
  
    echo "Sequence- and table files can't be matched, aborting."
    exit
  
  fi
  
done
