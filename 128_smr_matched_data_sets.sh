#!/usr/bin/env bash

# 09.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Filter data to match branches contained in trees.


# for debugging only
# ------------------ 
# set -x


# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi


# define relative input locations - Qiime files
# ---------------------------------------------
inpth_map='Zenodo/Manifest/06_18S_merged_metadata.tsv' # (should be  `b16888550ab997736253f741eaec47b`)
inpth_tax='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'

# define relative input locations - feature tables
# ------------------------------------------------

# Fill table array using find 
inpth_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
     inpth_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '127_18S_eDNA_samples*features.qza' -print0)
 
# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n' "Sorted feature files in array:"
# printf '%s\n' "${inpth_tab[@]}"

# define relative input locations - sequence files
# ------------------------------------------------

# Fill table array using find 
inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '127_18S_eDNA_samples*sequences.qza' -print0)

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
for i in "${!inpth_tab[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  seqstump="$(basename "${inpth_seq[$i]//_sequences/}")"
  tabstump="$(basename "${inpth_tab[$i]//_features/}")"
  
  # echo "$seqstump"
  # echo "$tabstump"
  
  if [ "$seqstump" == "$tabstump" ]; then
  
    # diagnostic only 
    echo "Sequence- and feature files have been matched, continuing..."
    
    # get input sequence file name - for debugging 
    # echo "${inpth_seq[$i]}"
    
    # get input table file name  - for debugging
    # echo "${inpth_tab[$i]}"

    # create output file names
    seq_vis_name="$(dirname "${inpth_seq[$i]}")"/128_"${seqstump:4:-4}"_sequences.qzv
    tab_vis_name="$(dirname "${inpth_tab[$i]}")"/128_"${tabstump:4:-4}"_features.qzv
    plot_vis_name="$(dirname "${inpth_tab[$i]}")"/128_"${tabstump:4:-4}"_barplot.qzv
    
    
    # echo "$seq_vis_name"
    # echo "$tab_vis_name"
    # echo "$plot_vis_name"
    
    # Qiime calls
    qiime feature-table tabulate-seqs \
      --i-data "${inpth_seq[$i]}" \
      --o-visualization "$seq_vis_name" \
      --verbose

    qiime feature-table summarize \
      --m-sample-metadata-file "$trpth"/"$inpth_map" \
      --i-table "${inpth_tab[$i]}" \
      --o-visualization "$tab_vis_name" \
      --verbose
 
    qiime taxa barplot \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --i-taxonomy "$trpth"/"$inpth_tax" \
      --i-table "${inpth_tab[$i]}" \
      --o-visualization "$plot_vis_name" \
      --verbose

  else
  
    echo "Sequence- and table files can't be matched, aborting."
    exit
  
  fi
  
done
