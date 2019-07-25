#!/usr/bin/env bash

# 17.06.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  Mantel test and Procrustes analysis of 
#    * between UNIFRAC and Jacquard distance matrices
#    * using ASV and 99% clustered data
#   (* different rarefaction levels - possibly later)

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]] && [[ "$HOSTNAME" != "macmini.staff.uod.otago.ac.nz" ]] ; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]] || [[ "$HOSTNAME" == "macmini.staff.uod.otago.ac.nz" ]]  ; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# Define input paths 
# ------------------
map='Zenodo/Manifest/06_18S_merged_metadata.tsv' 

# asv data
dm_first[1]="Zenodo/Qiime/170_eDNA_samples_Eukaryotes_core_metrics/unweighted_unifrac_distance_matrix.qza"
dm_secnd[1]="Zenodo/Qiime/130_18S_eDNA_samples_Eukaryotes_core_metrics_non_phylogenetic/jaccard_distance_matrix.qza" 

lb_first[1]="18S_eDNA_samples_Eukaryotes_unweighted_unifrac"
lb_secnd[1]="18S_eDNA_samples_Eukaryotes_jaccquard_non-phylogenetic" 

mntl_vis[1]="Zenodo/Qiime/205_18S_eDNA_samples_Eukaryotes_mantel-test.qzv"

pcoa_first[1]="Zenodo/Qiime/170_eDNA_samples_Eukaryotes_core_metrics/unweighted_unifrac_pcoa_results.qza"
pcoa_secnd[1]="Zenodo/Qiime/130_18S_eDNA_samples_Eukaryotes_core_metrics_non_phylogenetic/jaccard_pcoa_results.qza"


# 99% otu data
dm_first[2]="Zenodo/Qiime/170_eDNA_samples_clustered99_Eukaryotes_core_metrics/unweighted_unifrac_distance_matrix.qza"
dm_secnd[2]="Zenodo/Qiime/130_18S_eDNA_samples_clustered99_Eukaryotes_core_metrics_non_phylogenetic/jaccard_distance_matrix.qza" 

lb_first[2]="18S_eDNA_samples_clustered99_Eukaryotes_unweighted_unifrac"
lb_secnd[2]="18S_eDNA_samples_clustered99_Eukaryotes_jaccquard_non-phylogenetic" 

mntl_vis[2]="Zenodo/Qiime/205_18S_eDNA_samples_clustered99_Eukaryotes_mantel-test.qzv"

pcoa_first[2]="Zenodo/Qiime/170_eDNA_samples_clustered99_Eukaryotes_core_metrics/unweighted_unifrac_pcoa_results.qza"
pcoa_secnd[2]="Zenodo/Qiime/130_18S_eDNA_samples_clustered99_Eukaryotes_core_metrics_non_phylogenetic/jaccard_pcoa_results.qza"


# Define output paths 
# -------------------

# asv data
tr_pcoa_first[1]="Zenodo/Qiime/170_eDNA_samples_Eukaryotes_core_metrics/unweighted_unifrac_pcoa_results_transformed.qza"
tr_pcoa_secnd[1]="Zenodo/Qiime/130_18S_eDNA_samples_Eukaryotes_core_metrics_non_phylogenetic/jaccard_pcoa_results_transformed.qza"

prc_vis[1]="Zenodo/Qiime/205_18S_eDNA_samples_Eukaryotes_procrustes.qzv"

# 99% otu data
tr_pcoa_first[2]="Zenodo/Qiime/170_eDNA_samples_clustered99_Eukaryotes_core_metrics/unweighted_unifrac_pcoa_results.qza"
tr_pcoa_secnd[2]="Zenodo/Qiime/130_18S_eDNA_samples_clustered99_Eukaryotes_core_metrics_non_phylogenetic/jaccard_pcoa_results.qza"

prc_vis[2]="Zenodo/Qiime/205_18S_eDNA_samples_clustered99_Eukaryotes_procrustes.qzv"


# Run scripts 
# -----------

for i in "${!dm_first[@]}"; do

  if [ ! -f "$trpth"/"${mntl_vis[$i]}" ]; then

    printf "${bold}$(date):${normal} Mantel-testing \"$(basename ${dm_first[$i]})\" against \"$(basename ${dm_secnd[$i]})\"...\n"
    qiime diversity mantel \
      --i-dm1 "$trpth"/"${dm_first[$i]}" \
      --i-dm2 "$trpth"/"${dm_secnd[$i]}" \
      --p-method 'pearson' \
      --p-permutations 9999 \
      --p-label1 "${lb_first[$i]}" \
      --p-label2 "${lb_secnd[$i]}" \
      --o-visualization "$trpth"/"${mntl_vis[$i]}" \
      --verbose
  
  else

    # diagnostic message
    printf "${bold}$(date):${normal} Mantel test already available: \"$(basename "$trpth"/"${mntl_vis[$i]}")\".\n"

  fi
  
  
  if [ ! -f "$trpth"/"${prc_vis[$i]}" ]; then
  
    printf "${bold}$(date):${normal} Matching matrices \"$(basename ${pcoa_first[$i]})\" and \"$(basename ${pcoa_secnd[$i]})\"...\n"
    qiime diversity procrustes-analysis \
      --i-reference "$trpth"/"${pcoa_first[$i]}" \
      --i-other "$trpth"/"${pcoa_secnd[$i]}" \
      --p-dimensions 5 \
      --o-transformed-reference "$trpth"/"${tr_pcoa_first[$i]}" \
      --o-transformed-other "$trpth"/"${tr_pcoa_secnd[$i]}" \
      --verbose
  
    printf "${bold}$(date):${normal} Plotting matrices \"$(basename ${pcoa_first[$i]})\" and \"$(basename ${pcoa_secnd[$i]})\"...\n"
    qiime emperor procrustes-plot \
      --i-reference-pcoa "$trpth"/"${tr_pcoa_first[$i]}" \
      --i-other-pcoa "$trpth"/"${tr_pcoa_secnd[$i]}" \
      --m-metadata-file "$trpth"/"$map" \
      --p-no-ignore-missing-samples \
      --o-visualization "$trpth"/"${prc_vis[$i]}" \
      --verbose
  
  else

    # diagnostic message
    printf "${bold}$(date):${normal} Procrustes visualisation already available: \"$(basename "$trpth"/"${prc_vis[$i]}")\".\n"

  fi

done
