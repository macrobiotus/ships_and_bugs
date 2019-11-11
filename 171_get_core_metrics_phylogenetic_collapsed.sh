#!/usr/bin/env bash

# 11.11.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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

# define relative input locations - Qiime files
# --------------------------------------------------------
inpth_map='Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_all.tsv'
secnd_map='Zenodo/Manifest/131_18S_5-sample-euk-metadata_deep_all_grouped.tsv'

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
    echo "Tree- and feature files have been matched, continuing..."
    
    # get input tree file name - for debugging 
    # echo "${inpth_tree[$i]}"
    
    # get input table file name  - for debugging
    # echo "${inpth_tab[$i]}"
        
    # adding collapsing functionality 24-Jul-2019 
    # --------------------------------------------
    cllps_tab_path="$(dirname "${inpth_tab[$i]}")"
    cllps_tab_base="$(basename "${inpth_tab[$i]}")"
    cllps_tab="$cllps_tab_path/171_${cllps_tab_base:4:-4}_port-collapsed.qza"
  
    # for debugging only
    # echo "$cllps_tab_path" 
    # echo "$cllps_tab_base"
    # echo "$cllps_tab" 
    # exit
        
    # create output file names
    output_name="$(dirname "${inpth_tab[$i]}")/171_${tabstump:4:-4}_core_metrics_port-collapsed"
    output_log="$(dirname "${inpth_tab[$i]}")/171_${tabstump:4:-4}_core_metrics_port-collapsed_log.txt"
     
    # echo "$output_name" 
    
    # setting depths
    case "${inpth_tab[$i]}" in
      *"Unassigned"* )
        depth=650
        echo "${bold}Depth set to $depth for Unassigned...${normal}"
        ;;
      *"Eukaryotes"* )
        depth=49974
        echo "${bold}Depth set to $depth for Eukaryotes...${normal}"
        ;;
      *"Eukaryote-shallow"* )
        depth=32982
        echo "${bold}Depth set to $depth for Eukaryotes (shallow set)...${normal}"
        ;;
      *"Eukaryote-non-metazoans"* )
        depth=40000
        echo "${bold}Depth set to $depth for Non-metazoan Eukaryotes...${normal}"
        ;;
      *"Metazoans"* )
        depth=3500
        echo "${bold}Depth set to $depth for Metazoans...${normal}"
        ;;
      *)
        echo "Depth setting error in case statement, aborting."
        exit
        ;;
    esac
    
    # Qiime calls   
    
    if [ ! -d "$output_name" ]; then
    
      printf "${bold}$(date):${normal} Collapsing table \"$(basename "${inpth_tab[$i]}")\"...\n"  
    
      qiime feature-table group \
        --i-table "${inpth_tab[$i]}" \
        --p-axis 'sample' \
        --m-metadata-file "$trpth"/"$inpth_map" \
        --m-metadata-column 'Port' \
        --p-mode 'sum' \
        --o-grouped-table "$cllps_tab" \
        --verbose
    
      printf "${bold}$(date):${normal} Starting analysis of \"$(basename "$cllps_tab")\"...\n"
    
      qiime diversity core-metrics-phylogenetic \
        --i-phylogeny "${inpth_tree[$i]}" \
        --i-table "$cllps_tab" \
        --m-metadata-file "$trpth"/"$secnd_map" \
        --output-dir "$output_name" \
        --p-sampling-depth "$depth" \
        --verbose 2>&1 | tee -a "$output_log"

      printf "${bold}$(date):${normal} ...finished analysis of \"$(basename "$cllps_tab")\".\n"
    
    else

      # diagnostic message
      printf "${bold}$(date):${normal} Detected readily available results, skipping analysis of one file set.\n"

    fi
  
  else
  
    echo "Tree- and table files can't be matched, aborting."
    exit
  
  fi
  
done
