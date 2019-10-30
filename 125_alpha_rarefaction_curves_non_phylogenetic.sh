#!/usr/bin/env bash

# 30.10.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Generate interactive alpha rarefaction curves by computing rarefactions
#   between `min_depth` and `max_depth`. The number of intermediate depths to
#   compute is controlled by the `steps` parameter, with n `iterations` being
#   computed at each rarefaction depth. If sample metadata is provided,
#   samples may be grouped based on distinct values within a metadata column.

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

# define relative input locations - feature tables
# ------------------------------------------------

# Fill table array using find 
inpth_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '115_*_tab_*.qza' -print0)

# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "$(basename ${inpth_tab[@]})"
# exit 

for i in "${!inpth_tab[@]}"; do
    
  # get input table file name  - for debugging
  echo "${inpth_tab[$i]}"
  
  # create output file names
  directory="$(dirname "$inpth_tab[$i]")"
  plot_file_temp="$(basename "${inpth_tab[$i]//_seq/}")"
  plot_file_temp="${plot_file_temp:4}"
  plot_file_name="${plot_file_temp%.*}"
  extension=".qzv"
    
  plot_vis_name="$directory/125_$plot_file_name"_non_phylogenetic_curves"$extension"
  
  
  # get output file file name  - for debugging
  # echo "$plot_vis_name"    
  # continue
    
  if [ ! -f "$plot_vis_name" ]; then
  
    # Qiime calls   
    printf "${bold}$(date):${normal} Starting analysis of \"$(basename "${inpth_tab[$i]}")\"...\n"
    qiime diversity alpha-rarefaction \
      --i-table "${inpth_tab[$i]}" \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --p-max-depth 75000 \
      --p-min-depth 1 \
      --p-steps 1000 \
      --p-iterations 5 \
      --o-visualization "$plot_vis_name" \
      --verbose
    printf "${bold}$(date):${normal} ...finished analysis of \"$(basename "${inpth_tab[$i]}")\".\n"
  
  else

    # diagnostic message
    printf "${bold}$(date):${normal} File \"$(basename "$plot_vis_name")\" already available, skipping.\n"

  fi

done
