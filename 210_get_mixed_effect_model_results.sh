#!/usr/bin/env bash

# 05.09.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#  This script will call boldly 
#    * /Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R
#  Consult that file to understand the 7 parameters that can be specified to control the output.  

# abort on first error
set -e

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.local" ]]; then
    printf "Execution on remote not implemented, aborting.\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    bold=$(tput bold)
    normal=$(tput sgr0)
elif [[ "$HOSTNAME" == "macmini.local" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
    bold=$(tput bold)
    normal=$(tput sgr0)
fi

# Define input paths 
# ------------------
# Consult `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` for more info
input_dm[1]="Zenodo/Qiime/185_eDNA_samples_Eukaryotes_core_metrics_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv"
input_dm[2]="Zenodo/Qiime/185_eDNA_samples_clustered99_Eukaryotes_core_metrics_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv"


input_dm[3]="Zenodo/Qiime/190_18S_eDNA_samples_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv"
input_dm[4]="Zenodo/Qiime/190_18S_eDNA_samples_clustered99_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv"

input_dm[5]="Zenodo/Qiime/185_eDNA_samples_Eukaryote-shallow_core_metrics_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv"
input_dm[6]="Zenodo/Qiime/185_eDNA_samples_clustered99_Eukaryote-shallow_core_metrics_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv"

input_dm[7]="Zenodo/Qiime/190_18S_eDNA_samples_Eukaryote-shallow_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv"
input_dm[8]="Zenodo/Qiime/190_18S_eDNA_samples_clustered99_Eukaryote-shallow_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv"




# Define output paths 
# ------------------
output_dir="Zenodo/Results/" # keep trailing slash for `get_path()` in `/Users/paul/Documents/CU_combined/Github/500_00_functions.R`
logfile="$trpth"/"$output_dir"210_modelling_run_log.txt 


# Run scripts 
# -----------

printf "Exiting conda environment, to have system-wide R available.\n"

set +e
conda deactivate
set -e

for i in "${!input_dm[@]}"; do

    printf "${bold}$(date):${normal} Obtaining model results using R from \""$(basename $trpth/${input_dm[$i]})"\" writing to \""$trpth"/"$output_dir" \"...\n"
    
    Rscript --vanilla "$trpth/Github/500_80_get_mixed_effect_model_results.R" \
      "$trpth"/"${input_dm[$i]}" \
      "$trpth"/"$output_dir" 2>&1 | tee -a "$logfile"
      
done
