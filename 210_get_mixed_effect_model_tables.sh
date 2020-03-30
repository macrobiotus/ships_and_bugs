#!/usr/bin/env bash

# 31.03.2020 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# abort on error
# --------------- 
set -e

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
    cores="2"
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

# Define file names to get order without extensively modifying modeling script 
tmp_dm[1]="$TMPDIR/01_results_euk_asv00_deep_UNIF.tsv"
tmp_dm[2]="$TMPDIR/02_results_euk_otu99_deep_UNIF.tsv"

tmp_dm[3]="$TMPDIR/03_results_euk_asv00_deep_JAQU.tsv"
tmp_dm[4]="$TMPDIR/04_results_euk_otu99_deep_JAQU.tsv"

tmp_dm[5]="$TMPDIR/05_results_euk_asv00_shal_UNIF.tsv" 
tmp_dm[6]="$TMPDIR/06_results_euk_otu99_shal_UNIF.tsv"

tmp_dm[7]="$TMPDIR/07_results_euk_asv00_shal_JAQU.tsv" 
tmp_dm[8]="$TMPDIR/08_results_euk_otu99_shal_JAQU.tsv"

# Define output paths 
# ------------------
output_dir="Zenodo/Results/" # keep trailing slash for `get_path()` in `/Users/paul/Documents/CU_combined/Github/500_00_functions.R`
logfile="$trpth"/"$output_dir"210_model_data_export_log.txt 


# Run scripts 
# -----------

printf "Exiting conda environment, to have system-wide R available.\n"

set +e
# conda deactivate
set -e

for i in "${!input_dm[@]}"; do

    printf "${bold}$(date):${normal} Creating temp files \"${tmp_dm[$i]}\" \n"
    
    cp "$trpth"/"${input_dm[$i]}" "${tmp_dm[$i]}" 

    printf "${bold}$(date):${normal} Obtaining model results using R from \""$(basename $trpth/${tmp_dm[$i]})"\" writing to \""$trpth"/"$output_dir" \"...\n"
    
    Rscript --vanilla "$trpth/Github/500_80_get_mixed_effect_model_tables.R" \
      "${tmp_dm[$i]}" \
      "$trpth"/"$output_dir" 2>&1 | tee -a "$logfile"
    
    printf "${bold}$(date):${normal} Erasing temp files...\n"
    rm "${tmp_dm[$i]}"
      
done
