#!/usr/bin/env bash

# 30.10.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.local" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "macmini.local" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# define relative input locations - Qiime files
# --------------------------------------------------------
inpth_map='Zenodo/Manifest/06_18S_merged_metadata.tsv' # (should be  `b16888550ab997736253f741eaec47b`)
inpth_tax='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'

# define relative input locations - sequence files
# -----------------------------------------------------------

# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)
# (https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)

# Fill sequence array using find 
inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" \( -name '100_18S_*_seq.qza' \) -print0)

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
done < <(find "$trpth/Zenodo/Qiime" \( -name '100_18S_*_tab.qza' \) -print0)

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
  seqtest="$(basename "${inpth_seq[$i]//_seq/}")"
  tabtest="$(basename "${inpth_tab[$i]//_tab/}")"
  
  # for debugging
  # echo "$seqtest"
  # echo "$tabtest"
  
  
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
    
    plot_file_temp="$(basename "${inpth_seq[$i]//_seq/}")"
    plot_file_temp="${plot_file_temp:4}"
    plot_file_name="${plot_file_temp%.*}"
    
    extension=".qzv"
    
    # check string construction - for debugging
    # echo "$seq_file_name"
    # echo "$tab_file_name"
    # echo "$plot_file_name"
    
    seq_file_vis_path="$directory/105_$seq_file_name""$extension"
    tab_file_vis_path="$directory/105_$tab_file_name""$extension"
    plot_file_vis_path="$directory/105_$plot_file_name"_barplot"$extension"
    
    # check string construction - for debugging
    # echo "$seq_file_vis_path"
    # echo "$tab_file_vis_path"
    # echo "$plot_file_vis_path"
    
    # Qiime calls
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
  
    echo "Sequence- and table files can't be matched, aborting."
    exit
  
  fi
  
done
