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
printf '%s\n'
printf '%s\n' "$(basename ${inpth_tree[@]})"

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
    if [ ! -f "$plot_vis_name" ]; then
    
      # Qiime calls   
      printf "${bold}$(date):${normal} Starting analysis of \"$(basename "${inpth_tab[$i]}")\"...\n"
      
      # setting correct sampling selection file
      if [[ "${inpth_tab[$i]}" == *"shallow"* ]]; then
        inpth_map="Zenodo/Manifest/127_18S_5-sample-euk-metadata_shll_all.tsv"
        printf "${bold}Detected shallow set, using:${normal} $trpth/$inpth_map \n"
      elif [[ "${inpth_tab[$i]}" != *"shallow"* ]]; then
        inpth_map="Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_all.tsv"
        printf "${bold}Using normal sample set:${normal} $trpth/$inpth_map \n"
      fi
      
      qiime diversity alpha-rarefaction \
        --i-table "${inpth_tab[$i]}" \
        --i-phylogeny "${inpth_tree[$i]}" \
        --m-metadata-file "$trpth"/"$inpth_map" \
        --p-max-depth 55000 \
        --p-min-depth 1 \
        --p-steps 1000 \
        --p-iterations 4 \
        --o-visualization "$plot_vis_name" \
        --verbose
      printf "${bold}$(date):${normal} ...finished analysis of \"$(basename "${inpth_tab[$i]}")\".\n"
    
    else
 
      # diagnostic message
      printf "${bold}$(date):${normal} Analysis already done for \"$(basename "${inpth_tab[$i]}")\"...\n"

    fi
  
  else
  
    echo "Tree- and table files can't be matched, aborting."
    exit
  
  fi
  
done
