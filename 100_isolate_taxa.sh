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
in_seq[2]='Zenodo/Qiime/085_18S_all_samples_seq.qza'
in_tab[2]='Zenodo/Qiime/085_18S_all_samples_tab.qza'

in_seq[3]='Zenodo/Qiime/095_18S_eDNA_samples_tab_090_cl.qza'
in_tab[3]='Zenodo/Qiime/095_18S_eDNA_samples_seq_090_cl.qza'

in_seq[4]='Zenodo/Qiime/095_18S_eDNA_samples_seq_097_cl.qza'
in_tab[4]='Zenodo/Qiime/095_18S_eDNA_samples_tab_097_cl.qza'

in_seq[5]='Zenodo/Qiime/095_18S_eDNA_samples_seq_099_cl.qza'
in_tab[5]='Zenodo/Qiime/095_18S_eDNA_samples_tab_099_cl.qza'

# controls
in_seq[6]='/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_seq.qza'
in_tab[6]='/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_tab.qza'

# Define filtering strings
# -----------------------

# for filtering
# for '--p-mode exact \'
# taxon[1]='Unassigned'
# taxon[2]='D_0__Eukaryota'
# taxon[3]='D_3__Metazoa (Animalia)'

taxon[1]='Unassigned'
taxon[2]='Eukaryota'
taxon[3]='Metazoa'


# for file name
string[1]='Unassigned'
string[2]='Eukaryotes'
string[3]='Metazoans'

# loop over filtering parameters, and corresponding file name names additions
for i in "${!string[@]}"; do
  
  # print diagnostic message
  printf "\nFiltering for ${string[$i]}...\n"
  
  # loop over input files
  for k in "${!in_seq[@]}"; do
    
    # get input sequence file name  
    echo "${in_seq[$k]}"
    
    # get input table file name  
    echo "${in_tab[$k]}"
    
    # get filter string
    echo "${taxon[$i]}"
    
    # get output sequence file name  
    extension="${in_seq[$k]##*.}"                 # get the extension
    filename="${in_seq[$k]%.*}"                   # get the filename
    out_seq[$k]="${filename}_${string[$i]}.${extension}" # get name string    
    echo "${out_seq[$k]}"

    
    # get output table file name  
    extension="${in_tab[$k]##*.}"                 # get the extension
    filename="${in_tab[$k]%.*}"                   # get the filename
    out_tab[$k]="${filename}_${string[$i]}.${extension}" # get name string    
    echo "${out_tab[$k]}"
    
    qiime taxa filter-table \
      --i-table table.qza \
      --i-taxonomy taxonomy.qza \
      --p-exclude "k__Bacteria; p__Proteobacteria; c__Alphaproteobacteria; o__Rickettsiales; f__mitochondria" \
      --o-filtered-table table-no-mitochondria-exact.qza
  
  
  done


done




# Run scripts 
# -----------
# 
# printf "Isolating control features...\n"
# qiime feature-table filter-samples \
#   --i-table "$trpth"/"$in_tab" \
#   --m-metadata-file "$trpth"/"$map" \
#   --p-min-frequency '1' \
#   --p-min-features '1' \
#   --p-exclude-ids \
#   --p-where "Type IN ('eDNA')" \
#   --o-filtered-table "$trpth"/"${out_tab[1]}" \
#   --verbose
# 
# printf "Isolating control sequences...\n"
# qiime feature-table filter-seqs \
#   --i-data "$trpth"/"$in_seq" \
#   --i-table "$trpth"/"${out_tab[1]}" \
#   --o-filtered-data "$trpth"/"${out_seq[1]}" \
#   --verbose
# 
# printf "Isolating eDNA features...\n"
# qiime feature-table filter-samples \
#   --i-table "$trpth"/"$in_tab" \
#   --m-metadata-file "$trpth"/"$map" \
#   --p-min-frequency '1' \
#   --p-min-features '1' \
#   --p-no-exclude-ids \
#   --p-where "Type IN ('eDNA')" \
#   --o-filtered-table "$trpth"/"${out_tab[2]}" \
#   --verbose
# 
# printf "Isolating eDNA sequences...\n"
# qiime feature-table filter-seqs \
#   --i-data "$trpth"/"$in_seq" \
#   --i-table "$trpth"/"${out_tab[2]}" \
#   --o-filtered-data "$trpth"/"${out_seq[2]}" \
#   --verbose
