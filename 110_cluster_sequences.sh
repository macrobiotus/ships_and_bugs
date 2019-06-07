#!/usr/bin/env bash

# 29.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
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
# set -x

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
    cores=2
fi

# Define input and output locations
# ---------------------------------
in_seq='Zenodo/Qiime/100_18S_eDNA_samples_seq.qza'
in_tab='Zenodo/Qiime/100_18S_eDNA_samples_tab.qza'

cluster[1]='0.99'
cluster[2]='0.97'
cluster[3]='0.90'
cluster[4]='0.875'

clust_seq[1]='Zenodo/Qiime/110_18S_eDNA_samples_clustered99_seq.qza'
clust_seq[2]='Zenodo/Qiime/110_18S_eDNA_samples_clustered97_seq.qza'
clust_seq[3]='Zenodo/Qiime/110_18S_eDNA_samples_clustered90_seq.qza'
clust_seq[4]='Zenodo/Qiime/110_18S_eDNA_samples_clustered87_seq.qza'

clust_tab[1]='Zenodo/Qiime/110_18S_eDNA_samples_clustered99_tab.qza'
clust_tab[2]='Zenodo/Qiime/110_18S_eDNA_samples_clustered97_tab.qza'
clust_tab[3]='Zenodo/Qiime/110_18S_eDNA_samples_clustered90_tab.qza'
clust_tab[4]='Zenodo/Qiime/110_18S_eDNA_samples_clustered87_tab.qza'

log[1]='Zenodo/Qiime/110_18S_eDNA_samples_clustered99_log.txt'
log[2]='Zenodo/Qiime/110_18S_eDNA_samples_clustered97_log.txt'
log[3]='Zenodo/Qiime/110_18S_eDNA_samples_clustered90_log.txt'
log[4]='Zenodo/Qiime/110_18S_eDNA_samples_clustered87_log.txt'

# Run scripts
# ------------
for ((i=1;i<=4;i++)); do
  
  # continue only if output file isn't already there
  if [ ! -f "$trpth"/"${clust_tab[$i]}" ]; then

    qiime vsearch cluster-features-de-novo \
      --p-threads "$cores" \
      --i-table "$trpth"/"$in_tab" \
      --i-sequences "$trpth"/"$in_seq" \
      --p-perc-identity "${cluster[$i]}" \
      --o-clustered-table "$trpth"/"${clust_tab[$i]}" \
      --o-clustered-sequences "$trpth"/"${clust_seq[$i]}" \
      --verbose 2>&1 | tee -a "$trpth"/"${log[$i]}"
      
  else

    # diagnostic message
    printf "${bold}$(date):${normal} Analysis already done for \"$(basename "$trpth"/"$in_tab")\"...\n"

  fi
  
done
