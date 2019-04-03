#!/usr/bin/env bash

# 28.01.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime tree building and midpoint rooting,
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds="3"
fi

# Define input and output locations
# ---------------------------------
inseq='Zenodo/Qiime/110_18S_097_cl_metzn_seq_algn_masked.qza'

urtpth='Zenodo/Qiime/115_18S_097_cl_tree_urt.qza'

mptpth='Zenodo/Qiime/115_18S_097_cl_tree_mid.qza'


# Run scripts
# ------------
# Alexandros Stamatakis. Raxml version 8: a tool for phylogenetic analysis and 
# post-analysis of large phylogenies. Bioinformatics, 30(9):1312–1313, 2014. 
# URL: http://dx.doi.org/10.1093/bioinformatics/btu033, doi:10.1093/bioinformatics/btu033.

printf "Calculating tree...\n"
#   qiime phylogeny raxml-rapid-bootstrap \
#     --p-seed 1723 \
#     --p-raxml-version AVX2 \
#     --p-rapid-bootstrap-seed 9384 \
#     --p-bootstrap-replicates 100 \
#     --p-substitution-model GTRCAT \
#     --p-n-threads "$thrds" \
#     --i-alignment "$trpth"/"$inseq" \
#     --o-tree "$trpth"/"$urtpth" \
#     --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/105_18S_097_cl_tree_urt_log.txt"
    
qiime phylogeny iqtree \
   --p-seed 1723 \
   --p-n-cores 0 \
   --p-n-runs 10 \
   --p-alrt 1000 \
   --i-alignment "$trpth"/"$inseq" \
   --p-safe \
   --o-tree "$trpth"/"$urtpth" \
   --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/115_18S_097_cl_tree_urt_log.txt"
 
printf "Rooting at midpoint...\n"  
 qiime phylogeny midpoint-root \
  --i-tree "$trpth"/"$urtpth" \
  --o-rooted-tree "$trpth"/"$mptpth" \
  --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/115_18S_097_cl_tree_mid_log.txt"
