#!/usr/bin/env bash

# 24.04.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Applies a collection of diversity metrics (both phylogenetic and non-
#   phylogenetic) to a feature table.
# also see for an explanation of metrics
#  https://forum.qiime2.org/t/alpha-and-beta-diversity-explanations-and-commands/2282

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

# define relative input locations - feature tables
# ------------------------------------------------

# Fill table array using find 
inpth_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '128_*_tab_*.qza' -print0)

# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "$(basename ${inpth_tab[@]})"

# feature tables (an trees)

for i in "${!inpth_tab[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tabstump="$(basename "${inpth_tab[$i]//_tab/}")"  
  # echo "$tabstump"
  
  # get input tree file name - for debugging 
  # echo "${inpth_tree[$i]}"
    
  # get input table file name  - for debugging
  # echo "${inpth_tab[$i]}"
        
  # create output file names
  output_name="$(dirname "${inpth_tab[$i]}")/130_${tabstump:4:-4}_core_metrics_non_phylogenetic"
  output_log="$(dirname "${inpth_tab[$i]}")/130_${tabstump:4:-4}_core_metrics_non_phylogenetic_log.txt"
     
  # echo "$output_name" 
    
  # setting depths
  case "${inpth_tab[$i]}" in
    *"Unassigned"* )
      depth=650
      echo "${bold}Depth set to $depth for Unassigned...${normal}"
      ;;
    *"Eukaryotes"* )
      depth=49899
      echo "${bold}Depth set to $depth for Eukaryotes...${normal}"
      ;;
    *"Eukaryote-shallow"* )
      depth=37899
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
    
  if [ ! -d "$output_name" ]; then
  
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
    
    qiime diversity core-metrics \
      --i-table "${inpth_tab[$i]}" \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --output-dir "$output_name" \
      --p-sampling-depth "$depth" \
      --verbose 2>&1 | tee -a "$output_log"
  
    printf "${bold}$(date):${normal} ...finished analysis of \"$(basename "${inpth_tab[$i]}")\".\n"
  
  else

    # diagnostic message
    printf "${bold}$(date):${normal} Detected readily available results, skipping analysis of one file set.\n"

  fi

done
