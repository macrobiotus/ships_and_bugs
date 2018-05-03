#!/bin/bash

# 03.05.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
#   "Given a feature table and the associated feature sequences, cluster the
#   features based on user-specified percent identity threshold of their
#   sequences. This is not a general-purpose de novo clustering method, but
#   rather is intended to be used for clustering the results of quality-
#   filtering/dereplication methods, such as DADA2, or for re-clustering a
#   FeatureTable at a lower percent identity than it was originally clustered
#   at. When a group of features in the input table are clustered into a
#   single feature, the frequency of that single feature in a given sample is
#   the sum of the frequencies of the features that were clustered in that
#   sample. Feature identifiers and sequences will be inherited from the
#   centroid feature of each cluster. See the vsearch documentation for
#   details on how sequence clustering is performed."

# For debugging only
# ------------------ 
set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    dbugp="/workdir/pc683/CU_combined"
    qiime() { qiime2cli "$@"; }
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    dbugp="$(dirname "$PWD")"
    cores='2'
fi

# Define input and output locations
# ---------------------------------
in_tab='Zenodo/Qiime/100_18S_merged_tab.qza'
in_seq='Zenodo/Qiime/100_18S_merged_seq.qza'

cluster[1]='1.00'
cluster[2]='0.97'
cluster[3]='0.90'

clust_tab[1]='Zenodo/Qiime/200_18S_100_cl_tab.qza'
clust_tab[2]='Zenodo/Qiime/200_18S_097_cl_tab.qza'
clust_tab[3]='Zenodo/Qiime/200_18S_090_cl_tab.qza'

clust_seq[1]='Zenodo/Qiime/200_18S_100_cl_seq.qza'
clust_seq[2]='Zenodo/Qiime/200_18S_097_cl_seq.qza'
clust_seq[3]='Zenodo/Qiime/200_18S_090_cl_seq.qza'

# Run scripts
# ------------
for ((i=1;i<=3;i++)); do
  qiime vsearch cluster-features-de-novo \
    --p-threads "$cores" \
    --i-sequences "$trpth"/"$in_seq" \
    --i-table "$trpth"/"$in_tab" \
    --p-perc-identity "${cluster[$i]}" \
    --o-clustered-table "$trpth"/"${clust_tab[$i]}" \
    --o-clustered-sequences "$trpth"/"${clust_seq[$i]}" \
    --verbose | tee -a "$dbugp"/'Zenodo/Qiime/200_18S_cluster_log.txt'
done
