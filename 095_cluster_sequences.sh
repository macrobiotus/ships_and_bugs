#!/usr/bin/env bash

# 18.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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
    printf "This script needs at least qiime2-2018.08. Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "This script needs at least qiime2-2018.08. Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    # cores="$(nproc --all)"
    cores=1
fi

# Define input and output locations
# ---------------------------------
in_seq='Zenodo/Qiime/090_18S_eDNA_samples_seq.qza'
in_tab='Zenodo/Qiime/090_18S_eDNA_samples_tab.qza'


cluster[1]='0.99'
cluster[2]='0.97'
cluster[3]='0.90'

clust_seq[1]='Zenodo/Qiime/095_18S_eDNA_samples_seq_099_cl.qza'
clust_seq[2]='Zenodo/Qiime/095_18S_eDNA_samples_seq_097_cl.qza'
clust_seq[3]='Zenodo/Qiime/095_18S_eDNA_samples_seq_090_cl.qza'

clust_tab[1]='Zenodo/Qiime/095_18S_eDNA_samples_tab_099_cl.qza'
clust_tab[2]='Zenodo/Qiime/095_18S_eDNA_samples_tab_097_cl.qza'
clust_tab[3]='Zenodo/Qiime/095_18S_eDNA_samples_tab_090_cl.qza'

log[1]='Zenodo/Qiime/095_18S_log_099_cl.txt'
log[2]='Zenodo/Qiime/095_18S_log_097_cl.txt'
log[3]='Zenodo/Qiime/095_18S_log_090_cl.txt'

# Run scripts
# ------------
for ((i=1;i<=3;i++)); do
  qiime vsearch cluster-features-de-novo \
    --p-threads "$cores" \
    --i-table "$trpth"/"$in_tab" \
    --i-sequences "$trpth"/"$in_seq" \
    --p-perc-identity "${cluster[$i]}" \
    --o-clustered-table "$trpth"/"${clust_tab[$i]}" \
    --o-clustered-sequences "$trpth"/"${clust_seq[$i]}" \
    --verbose 2>&1 | tee -a "$trpth"/"${log[$i]}"
done
