#!/usr/bin/env bash

# 26.08.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Retain only samples needed for analysis 

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
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

# Define input paths 
# ------------------
# define more arrays for other files if needed

# checked mapping files
map='Zenodo/Manifest/06_18S_merged_metadata.tsv' 
inpth_tax='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'

# unclustered data
in_seq[1]='Zenodo/Qiime/100_18S_eDNA_samples_seq.qza'
in_tab[1]='Zenodo/Qiime/100_18S_eDNA_samples_tab.qza'

# clustered data
in_seq[2]='Zenodo/Qiime/110_18S_eDNA_samples_clustered99_seq.qza'
in_tab[2]='Zenodo/Qiime/110_18S_eDNA_samples_clustered99_tab.qza'

in_seq[3]='Zenodo/Qiime/110_18S_eDNA_samples_clustered97_seq.qza'
in_tab[3]='Zenodo/Qiime/110_18S_eDNA_samples_clustered97_tab.qza'

in_seq[4]='Zenodo/Qiime/110_18S_eDNA_samples_clustered90_seq.qza'
in_tab[4]='Zenodo/Qiime/110_18S_eDNA_samples_clustered90_tab.qza'

in_seq[5]='Zenodo/Qiime/110_18S_eDNA_samples_clustered87_seq.qza'
in_tab[5]='Zenodo/Qiime/110_18S_eDNA_samples_clustered87_tab.qza'

# controls
in_seq[6]='Zenodo/Qiime/090_18S_controls_seq.qza'
in_tab[6]='Zenodo/Qiime/090_18S_controls_tab.qza'

# Define filtering strings
# -----------------------

# for file name
string[1]='Unassigned'
string[2]='Eukaryotes'
string[3]='Eukaryote-shallow'
string[4]='Metazoans'
string[5]='Eukaryote-non-metazoans'

# for filtering
# for '--p-mode exact \'
# taxon[1]='Unassigned'
# taxon[2]='D_0__Eukaryota'
# taxon[3]='D_3__Metazoa (Animalia)'

taxon[1]='Unassigned'
taxon[2]='Eukaryota'
taxon[3]='Eukaryota'
taxon[4]='Metazoa'

# loop over input files
for k in "${!in_seq[@]}"; do  
  
  # loop over filtering parameters, and corresponding file name names additions
  for ((i=1;i<=4;i++)); do
  
    # print diagnostic message
    printf "\n${bold}$(date):${normal} Filtering for ${taxon[$i]}...\n"
  
    # uncomment for debugging or redesign
    # get input sequence file name  
    # echo "${in_seq[$k]}"
    
    # get input table file name  
    # echo "${in_tab[$k]}"
    
    # get filter string
    # echo "${taxon[$i]}"
    
    # get output sequence file name 
    directory="Zenodo/Qiime"
    seq_file_tmp="$(basename "${in_seq[$k]%.*}")"
    seq_file_name="115_${seq_file_tmp:4}"
    extension="${in_seq[$k]##*.}"                    # get the extension
    out_seq[$k]="$directory"/"${seq_file_name}_${string[$i]}.${extension}" # get name string
    # debugging only
    # echo "${out_seq[$k]}"
    
    # get output table file name 
    directory="Zenodo/Qiime"
    tab_file_tmp="$(basename "${in_tab[$k]%.*}")"
    tab_file_name="115_${tab_file_tmp:4}"
    extension="${in_tab[$k]##*.}"                    # get the extension
    out_tab[$k]="$directory"/"${tab_file_name}_${string[$i]}.${extension}" # get name string    
    # debugging only
    # echo "${out_tab[$k]}"
    
    # debugging only
    # continue
    
    # actual filtering
    # continue only if output file isn't already there
    if [ ! -f "$trpth"/"${out_seq[$k]}" ]; then
  
      qiime taxa filter-seqs \
        --i-taxonomy "$trpth"/"$inpth_tax" \
        --i-sequences "$trpth"/"${in_seq[$k]}" \
        --o-filtered-sequences "$trpth"/"${out_seq[$k]}" \
        --p-include  "${taxon[$i]}"

      qiime taxa filter-table \
        --i-taxonomy "$trpth"/"$inpth_tax" \
        --i-table "$trpth"/"${in_tab[$k]}" \
        --o-filtered-table "$trpth"/"${out_tab[$k]}" \
        --p-include  "${taxon[$i]}"
    
    else

      # diagnostic message
      printf "${bold}$(date):${normal} Analysis already done for \"$(basename "$trpth"/"${out_seq[$k]}")\" and \"$(basename "$trpth"/"${out_tab[$k]}")\"...\n"

    fi
    
  done
  
  
  # loop over fourth filtering strings
  #   Was added on 07.05.2019 after we decided to also want all Eukaryotes 
  #   that are not Metazoans. Syntax is shameless copied from above to
  #   mitigate regressions. Crossing fingers that it works.
  #   Note restricted loop, and hard pointers to index positions in Qiime 
  #   filtering commands.
    
  for ((i=5;i<=5;i++)); do
  
    # print diagnostic message
    printf "\n${bold}$(date):${normal} Filtering of special case.\n"
  
    # uncomment for debugging or redesign
    # get input sequence file name  
    # echo "${in_seq[$k]}"
    
    # get input table file name  
    # echo "${in_tab[$k]}"
    
    # get filter string
    # echo "${taxon[$i]}"
    
    # get output sequence file name 
    directory="Zenodo/Qiime"
    seq_file_tmp="$(basename "${in_seq[$k]%.*}")"
    seq_file_name="115_${seq_file_tmp:4}"
    extension="${in_seq[$k]##*.}"                    # get the extension
    out_seq[$k]="$directory"/"${seq_file_name}_${string[$i]}.${extension}" # get name string    
    # debugging only
    # echo "${out_seq[$k]}"
    
    # get output table file name 
    directory="Zenodo/Qiime"
    tab_file_tmp="$(basename "${in_tab[$k]%.*}")"
    tab_file_name="115_${tab_file_tmp:4}"
    extension="${in_tab[$k]##*.}"                    # get the extension
    out_tab[$k]="$directory"/"${tab_file_name}_${string[$i]}.${extension}" # get name string    
    # debugging only
    # echo "${out_tab[$k]}"
    
    # debugging only
    # continue
    
    # actual filtering
    # continue only if output file isn't already there
    if [ ! -f "$trpth"/"${out_seq[$k]}" ]; then
  
      # actual filtering
      qiime taxa filter-seqs \
        --i-taxonomy "$trpth"/"$inpth_tax" \
        --i-sequences "$trpth"/"${in_seq[$k]}" \
        --o-filtered-sequences "$trpth"/"${out_seq[$k]}" \
        --p-include  "${taxon[2]}" \
        --p-exclude "${taxon[3]}"
    
      qiime taxa filter-table \
        --i-taxonomy "$trpth"/"$inpth_tax" \
        --i-table "$trpth"/"${in_tab[$k]}" \
        --o-filtered-table "$trpth"/"${out_tab[$k]}" \
        --p-include  "${taxon[2]}" \
        --p-exclude "${taxon[3]}"
    
    else

      # diagnostic message
      printf "${bold}$(date):${normal} Analysis already done for \"$(basename "$trpth"/"${out_seq[$k]}")\" and \"$(basename "$trpth"/"${out_tab[$k]}")\"...\n"

    fi
    
  done

done

