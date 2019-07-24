#!/usr/bin/env bash

# 24.07.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Applies a collection of diversity metrics (both phylogenetic and non-
#   phylogenetic) to a feature table.
# also see for an explanation of metrics
#  https://forum.qiime2.org/t/alpha-and-beta-diversity-explanations-and-commands/2282

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]] && [[ "$HOSTNAME" != anat-dock-46.otago.ac.nz ]] ; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]] || [[ "$HOSTNAME" == anat-dock-46.otago.ac.nz ]]  ; then
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

# feature tables (an trees)

for i in "${!inpth_tab[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tabstump="$(basename "${inpth_tab[$i]//_tab/}")"  
  
  # echo "$tabstump"
  
    
  # get input tree file name - for debugging 
  # echo "${inpth_tree[$i]}"
    
  # get input table file name  - for debugging
  # echo "${inpth_tab[$i]}"
        
  # adding collapsing functionality 24-Jul-2019 
  # --------------------------------------------
  cllps_tab_path="$(dirname "${inpth_tab[$i]}")"
  cllps_tab_base="$(basename "${inpth_tab[$i]}")"
  cllps_tab="$cllps_tab_path/131_${cllps_tab_base:4:-4}_port-collapsed.qza"
  
  # for debugging only
  # echo "$cllps_tab_path" 
  # echo "$cllps_tab_base"
  # echo "$cllps_tab" 
  # exit
    
  # create output file names
  output_name="$(dirname "${inpth_tab[$i]}")/131_${tabstump:4:-4}_core_metrics_non_phylogenetic_port-collapsed"
  output_log="$(dirname "${inpth_tab[$i]}")/131_${tabstump:4:-4}_core_metrics_non_phylogenetic_port-collapsed_log.txt"
     
  # echo "$output_name" 
    
  # setting depths
  case "${inpth_tab[$i]}" in
    *"Unassigned"* )
      depth=650
      echo "${bold}Depth set to $depth for Unassigned...${normal}"
      ;;
    *"Eukaryotes"* )
      depth=65000
      echo "${bold}Depth set to $depth for Eukaryotes...${normal}"
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
  
    qiime diversity core-metrics \
      --i-table "$cllps_tab" \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --output-dir "$output_name" \
      --p-sampling-depth "$depth" \
      --verbose 2>&1 | tee -a "$output_log"
  
    printf "${bold}$(date):${normal} ...finished analysis of \"$(basename "$cllps_tab")\".\n"
  
  else

    # diagnostic message
    printf "${bold}$(date):${normal} Detected readily available results, skipping analysis of one file set.\n"

  fi

done
