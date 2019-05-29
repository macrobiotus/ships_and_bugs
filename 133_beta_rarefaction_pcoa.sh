#!/usr/bin/env bash

# 15.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Generate interactive beta rarefaction curves by computing rarefactions

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
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
done < <(find "$trpth/Zenodo/Qiime" -name '127_18S_eDNA_samples_*_features.qza' -print0)

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
done < <(find "$trpth/Zenodo/Qiime" -name '127_18S_eDNA_samples_*_tree.qza' -print0)

# Sort array 
IFS=$'\n' inpth_tree=($(sort <<<"${inpth_tree_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "$(basename ${inpth_tree[@]})"


# feature tables (an trees)

for i in "${!inpth_tab[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tabstump="$(basename "${inpth_tab[$i]//_features/}")"
  treestump="$(basename "${inpth_tree[$i]//_tree/}")"
  
  # echo "$tabstump"
  # echo "$treestump"
  
  if [ "$tabstump" == "$treestump" ]; then
  
    # diagnostic only 
    echo "Tree- and feature files have been matched, continuing..."
    
    # get input tree file name - for debugging 
    # echo "${inpth_tree[$i]}"
    
    # get input table file name  - for debugging
    # echo "${inpth_tab[$i]}"
    
    # create output file names
    plot_vis_name="$(dirname "${inpth_tab[$i]}")"/133_"${treestump:4:-4}"_beta_rarefaction.qzv
   
    # echo "$plot_vis_name"
    
    # set depths
    case "${inpth_tab[$i]}" in
      *"100_Unassigned"* )
        depth=500
        echo "${bold}Depth set to $depth for Unassigned...${normal}"
        ;;
      *"100_Eukaryotes"* )
        depth=50000
        echo "${bold}Depth set to $depth for Eukaryotes...${normal}"
        ;;
      *"100_Metazoans"* )
        depth=3000
        echo "${bold}Depth set to $depth for Metazoans...${normal}"
        ;;
      *"100_Eukaryote_non_Metazoans"* )
        depth=50000
        echo "${bold}Depth set to $depth for Non-Metazoan Eukaryotes...${normal}"
        ;;
      *"100_Unassigned"* )
        depth=500
        echo "${bold}Depth set to $depth for Unassigned...${normal}"
      ;;
      *)
        echo "Depth setting error in case statemnet, aborting."
        exit
        ;;
    esac
    
    # Qiime calls - beta-rarefaction
    printf "${bold}$(date):${normal} Starting beta-rarefaction of \"$(basename "${inpth_tab[$i]}")\"...\n"
    qiime diversity beta-rarefaction \
      --i-table "${inpth_tab[$i]}" \
      --i-phylogeny "${inpth_tree[$i]}" \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --p-metric unweighted_unifrac \
      --p-clustering-method nj \
      --p-sampling-depth "$depth" \
      --p-iterations 10 \
      --p-correlation-method spearman \
      --o-visualization "$plot_vis_name" \
      --verbose
    printf "${bold}$(date):${normal} ...finished beta-rarefaction of \"$(basename "${inpth_tab[$i]}")\".\n"
  
  else
  
    echo "Tree- and table files can't be matched, aborting."
    exit
  
  fi
  
done