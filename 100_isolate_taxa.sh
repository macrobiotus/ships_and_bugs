#!/usr/bin/env bash

# 18.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Retain only samples needed for analysis 

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Define input paths 
# ------------------
# define more arrays for other files if needed

# checked mapping files
map='Zenodo/Manifest/06_18S_merged_metadata.tsv' 
inpth_tax='Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.qza'

# input table and sequences - unclustered eDNA samples
in_seq[1]='Zenodo/Qiime/085_18S_all_samples_seq.qza'
in_tab[1]='Zenodo/Qiime/085_18S_all_samples_tab.qza'

# input table and sequences - clustered eDNA samples
in_seq[2]='Zenodo/Qiime/090_18S_eDNA_samples_seq.qza'
in_tab[2]='Zenodo/Qiime/090_18S_eDNA_samples_tab.qza'

in_seq[3]='Zenodo/Qiime/095_18S_eDNA_samples_seq_090_cl.qza'
in_tab[3]='Zenodo/Qiime/095_18S_eDNA_samples_tab_090_cl.qza'

in_seq[4]='Zenodo/Qiime/095_18S_eDNA_samples_seq_097_cl.qza'
in_tab[4]='Zenodo/Qiime/095_18S_eDNA_samples_tab_097_cl.qza'

in_seq[5]='Zenodo/Qiime/095_18S_eDNA_samples_seq_099_cl.qza'
in_tab[5]='Zenodo/Qiime/095_18S_eDNA_samples_tab_099_cl.qza'

# controls
in_seq[6]='Zenodo/Qiime/090_18S_controls_seq.qza'
in_tab[6]='Zenodo/Qiime/090_18S_controls_tab.qza'

# Define filtering strings
# -----------------------

# for file name
string[1]='100_Unassigned'
string[2]='100_Eukaryotes'
string[3]='100_Metazoans'
string[4]='100_Eukaryote_non_Metazoans'

# for filtering
# for '--p-mode exact \'
# taxon[1]='Unassigned'
# taxon[2]='D_0__Eukaryota'
# taxon[3]='D_3__Metazoa (Animalia)'

taxon[1]='Unassigned'
taxon[2]='Eukaryota'
taxon[3]='Metazoa'

# loop over input files
for k in "${!in_seq[@]}"; do  
  
  # loop over filtering parameters, and corresponding file name names additions
  for i in ((i=1;i<=3;i++)); do
  
    # print diagnostic message
    printf "\nFiltering for ${taxon[$i]}...\n"
  
    # uncomment for debugging or redesign
    # get input sequence file name  
    # echo "${in_seq[$k]}"
    
    # get input table file name  
    # echo "${in_tab[$k]}"
    
    # get filter string
    # echo "${taxon[$i]}"
    
    # get output sequence file name  
    extension="${in_seq[$k]##*.}"                 # get the extension
    filename="${in_seq[$k]%.*}"                   # get the filename
    out_seq[$k]="${filename}_${string[$i]}.${extension}" # get name string    
    # echo "${out_seq[$k]}"
    
    # get output table file name  
    extension="${in_tab[$k]##*.}"                 # get the extension
    filename="${in_tab[$k]%.*}"                   # get the filename
    out_tab[$k]="${filename}_${string[$i]}.${extension}" # get name string    
    # echo "${out_tab[$k]}"
       
    # actual filtering
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
  done
  
  
  # loop over fourth filtering strings
  #   Was added on 07.05.2019 after we decided to also want all Eukaryotes 
  #   that are not Metazoans. Syntax is shameless copied from above to
  #   mitigate regressions. Crossing fingers that it works.
  #   Note restricted loop, and hard pointers to index positions in Qiime 
  #   filtering commands.
    
  for i in ((i=4;i<=4;i++)); do
  
    # print diagnostic message
    printf "Filtering of special case.\n"
  
    # uncomment for debugging or redesign
    # get input sequence file name  
    # echo "${in_seq[$k]}"
    
    # get input table file name  
    # echo "${in_tab[$k]}"
    
    # get filter string
    # echo "${taxon[$i]}"
    
    # get output sequence file name  
    extension="${in_seq[$k]##*.}"                 # get the extension
    filename="${in_seq[$k]%.*}"                   # get the filename
    out_seq[$k]="${filename}_${string[$i]}.${extension}" # get name string    
    # echo "${out_seq[$k]}"
    
    # get output table file name  
    extension="${in_tab[$k]##*.}"                 # get the extension
    filename="${in_tab[$k]%.*}"                   # get the filename
    out_tab[$k]="${filename}_${string[$i]}.${extension}" # get name string    
    # echo "${out_tab[$k]}"
       
    # actual filtering
    qiime taxa filter-seqs \
      --i-taxonomy "$trpth"/"$inpth_tax" \
      --i-sequences "$trpth"/"${in_seq[$k]}" \
      --o-filtered-sequences "$trpth"/"${out_seq[$k]}" \
      --p-include  "${taxon[2]}"
      --p-exclude "${taxon[3]}"

    qiime taxa filter-table \
      --i-taxonomy "$trpth"/"$inpth_tax" \
      --i-table "$trpth"/"${in_tab[$k]}" \
      --o-filtered-table "$trpth"/"${out_tab[$k]}" \
      --p-include  "${taxon[2]}"
      --p-exclude "${taxon[3]}"
  done

done

