#!/usr/bin/env bash

# 01.06.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Generate interactive alpha rarefaction curves by computing rarefactions
#   between `min_depth` and `max_depth`. The number of intermediate depths to
#   compute is controlled by the `steps` parameter, with n `iterations` being
#   computed at each rarefaction depth. If sample metadata is provided,
#   samples may be grouped based on distinct values within a metadata column.

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "macmini.staff.uod.otago.ac.nz" ]]; then
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
done < <(find "$trpth/Zenodo/Qiime" -name '155_*_features_tree-matched.qza' -print0)

# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "$(basename ${inpth_tab[@]})"

# define relative input locations - tree files
# ------------------------------------------------

# Fill table array using find 
inpth_tree_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_tree_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '155_*_tree.qza' -print0)

# Sort array 
IFS=$'\n' inpth_tree=($(sort <<<"${inpth_tree_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "$(basename ${inpth_tree[@]})"


# feature tables (an trees)

for i in "${!inpth_tab[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tabstump="$(basename "${inpth_tab[$i]//_features_tree-matched/}")"
  treestump="$(basename "${inpth_tree[$i]//_tree/}")"
  
  # echo "$tabstump"
  # echo "$treestump"
  
  if [ "$tabstump" == "$treestump" ]; then
  
    # diagnostic only 
    # echo "Tree- and feature files have been matched, continuing..."
    
    # get input tree file name - for debugging 
    # echo "${inpth_tree[$i]}"
    
    # get input table file name  - for debugging
    # echo "${inpth_tab[$i]}"
    
    # create output file names
    plot_vis_name="$(dirname "${inpth_tab[$i]}")"/160_"${treestump:4:-4}"_curves_tree-matched.qzv
   
    # get output file file name  - for debugging
    # echo "$plot_vis_name"
    
    #  continue
    
    # Qiime calls   
    printf "${bold}$(date):${normal} Starting analysis of \"$(basename "${inpth_tab[$i]}")\"...\n"
    qiime diversity alpha-rarefaction \
      --i-table "${inpth_tab[$i]}" \
      --i-phylogeny "${inpth_tree[$i]}" \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --p-max-depth 75000 \
      --p-min-depth 1 \
      --p-steps 1000 \
      --p-iterations 5 \
      --o-visualization "$plot_vis_name" \
      --verbose
    printf "${bold}$(date):${normal} ...finished analysis of \"$(basename "${inpth_tab[$i]}")\".\n"
  
  else
  
    echo "Tree- and table files can't be matched, aborting."
    exit
  
  fi
  
done
