#!/usr/bin/env bash

# 03.06.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Export of Qiime artifacts for the purpose of checking feature counts 
# at rarefaction depth used for Unifrac analysis 

# for debugging only
# ================== 
# set -x

# paths need to be adjusted for remote execution
# ==============================================
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

# define relative input and output locations
# ==========================================

# Qiime files
# -----------
inpth_map='Zenodo/Manifest/06_18S_merged_metadata.tsv'
tax_assignemnts='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'


# Find all feature tables and put into array
# ------------------------------------------
inpth_features_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_features_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '115_*_tab_*.qza' -print0)

# Sort array 
IFS=$'\n' inpth_features=($(sort <<<"${inpth_features_unsorted[*]}"))
unset IFS

# Find all sequence tables and put into array
# ------------------------------------------
inpth_sequences_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_sequences_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '115_18S_*_seq*.qza' -print0)

# Sort array 
IFS=$'\n' inpth_sequences=($(sort <<<"${inpth_sequences_unsorted[*]}"))
unset IFS

# print all sorted arrays (debugging)
# ------------------------------------------

# printf '%s\n'
# printf '%s\n' "${inpth_features[@]}"
# printf '%s\n'
# printf '%s\n' "${inpth_sequences[@]}"

for i in "${!inpth_features[@]}"; do

  # check if files can be matched otherwise abort script because it would do more harm then good
  tabstump=$(basename "${inpth_features[$i]//tab_/}")
  seqstump=$(basename "${inpth_sequences[$i]//seq_/}")
  
  # echo "$tabstump"
  # echo "$seqstump"
  # exit
  
  if [ "$seqstump" == "$tabstump" ]; then
  
    # diagnostic only 
    echo "Sequence-, and feature files have been matched, continuing..."
    
    # create path for output directory
    results_tmp=$(basename "${inpth_features[$i]}".qza)
    results_tmp=${results_tmp:4:-8}
    results_dir="$trpth/Zenodo/Qiime/180_"$results_tmp"_qiime_artefacts_non_phylogenetic"
    # echo "$results_dir"
    # exit
    mkdir -p "$results_dir"
    
    # Exporting Qiime 2 files
    printf "${bold}$(date):${normal} Exporting Qiime 2 files...\n"
    qiime tools export --input-path "${inpth_features[$i]}" --output-path "$results_dir" && \
    qiime tools export --input-path "${inpth_sequences[$i]}" --output-path "$results_dir" && \
    qiime tools export --input-path "$trpth"/"$tax_assignemnts" --output-path "$results_dir" || \
    { echo "${bold}$(date):${normal} Qiime export failed" ; exit 1; }
    
    # Editing taxonomy file
    printf "${bold}$(date):${normal} Rewriting headers of taxonomy information (backup copy is kept)...\n"
    new_header='#OTUID  taxonomy    confidence' && \
    gsed -i.bak "1 s/^.*$/$new_header/" "$results_dir"/taxonomy.tsv || \
    { echo "${bold}$(date):${normal} Taxonomy Edit failed" ; exit 1; }
  
    # Adding taxonomy information to .biom file
    printf "${bold}$(date):${normal} Adding taxonomy information to .biom file...\n"
    biom add-metadata \
      -i "$results_dir"/feature-table.biom \
      -o "$results_dir"/features-tax.biom \
      --observation-metadata-fp "$results_dir"/taxonomy.tsv \
      --observation-header OTUID,taxonomy,confidence \
      --sc-separated taxonomy || { echo 'taxonomy addition failed' ; exit 1; }
   
    # Adding metadata to .biom file
    printf "${bold}$(date):${normal} Adding metadata to .biom file...\n"
    biom add-metadata \
      -i "$results_dir"/features-tax.biom \
      -o "$results_dir"/features-tax-meta.biom \
      -m "$trpth"/"$inpth_map" \
      --observation-header OTUID,taxonomy,confidence \
      --sample-header SampleID,BarcodeSequence,LinkerPrimerSequence,Port,Location,Type,Temp,Sali,Lati,Long,Run,Facility,CollYear || { echo 'Metadata addition failed' ; exit 1; }
  
    # Exporting .biom file to .tsv
    printf "${bold}$(date):${normal} Exporting to .tsv file...\n"
    biom convert \
      -i "$results_dir"/features-tax-meta.biom \
      -o "$results_dir"/features-tax-meta.tsv \
      --to-tsv && \
    gsed -i.bak 's/#//' "$results_dir"/features-tax-meta.tsv \
    || { echo 'TSV export failed' ; exit 1; }
     
    # Summarize exported OTU tables
    printf "${bold}$(date):${normal} Summarizing .tsv files...\n"
    Rscript --vanilla "$trpth/Github/195_parse_otu_tables.R" \
      "$results_dir/features-tax-meta.tsv" \
      "$results_dir/features-tax-meta-feature-summary.txt" \
      "$results_dir/features-tax-meta-feature-histogram.png"

  else
  
    echo "Files triplets can't be matched, aborting."
    exit
  
  fi
  
done
