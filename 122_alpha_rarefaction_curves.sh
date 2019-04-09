#!/usr/bin/env bash

# 09.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Generate interactive alpha rarefaction curves by computing rarefactions
#   between `min_depth` and `max_depth`. The number of intermediate depths to
#   compute is controlled by the `steps` parameter, with n `iterations` being
#   computed at each rarefaction depth. If sample metadata is provided,
#   samples may be grouped based on distinct values within a metadata column.

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# define input and output locations
# =================================

# input files
# ------------
query_tab[1]='Zenodo/Qiime/100_18S_097_cl_metzn_tab.qza'
map_txt[1]='Zenodo/Manifest/05_18S_merged_metadata.tsv'


# output files
# ------------
tax_crv[1]='Zenodo/Qiime/122_18S_097_cl_rarefaction_curves.qzv'

# set call parameters
# -------------------

depth[1]='2500' # see README and `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190403_rarefaction_depth.png`
               # "Retained 467,500 (7.35%) sequences in 187 (78.57%) samples at the specifed sampling depth."
               # default should be the same value as in /Users/paul/Documents/CU_combined/Github/120_get_metazoan_core_metrics.sh 
mptpth[1]='Zenodo/Qiime/115_18S_097_cl_tree_mid.qza' 
               # default should be the same value as in /Users/paul/Documents/CU_combined/Github/120_get_metazoan_core_metrics.sh 

# Run scripts
# ------------
for ((i=1;i<=1;i++)); do
  qiime diversity alpha-rarefaction \
    --i-table "$trpth"/"${query_tab[$i]}" \
    --p-max-depth "${depth[$i]}" \
    --i-phylogeny "$trpth"/"${mptpth[$i]}" \
    --m-metadata-file "$trpth"/"${map_txt[$i]}" \
    --p-min-depth 1 \
    --p-steps 100 \
    --p-iterations 10 \
    --o-visualization "$trpth"/"${tax_crv[$i]}" \
    --p-metrics shannon \
    --p-metrics faith_pd \
    --p-metrics goods_coverage \
    --p-metrics observed_otus \
    --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/122_18S_097_cl_tree_curves_log.txt"
done


#     --p-metrics pielou_e \
#     --p-metrics berger_parker_d \
#     --p-metrics gini_index \
#     --p-metrics chao1 \
#     --p-metrics doubles \
#     --p-metrics mcintosh_d \
#     --p-metrics simpson \
#     --p-metrics heip_e \
#     --p-metrics robbins \
#     --p-metrics fisher_alpha \

