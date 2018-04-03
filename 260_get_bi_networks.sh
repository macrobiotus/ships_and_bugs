#!/bin/bash

# 19.03.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Converting clustering results to biom files for Qiime 1 and
# network graphics.

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    qiime() { qiime2cli "$@"; }
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="$(dirname "$PWD")"
    cores='2'
fi

# Define input files
# ------------------
biom[1]='Zenodo/Qiime/520_18S_100_cl_q1exp/features-tax-meta.biom'
biom[2]='Zenodo/Qiime/520_18S_099_cl_q1exp/features-tax-meta.biom'
biom[3]='Zenodo/Qiime/520_18S_098_cl_q1exp/features-tax-meta.biom'
biom[4]='Zenodo/Qiime/520_18S_097_cl_q1exp/features-tax-meta.biom'
biom[5]='Zenodo/Qiime/520_18S_096_cl_q1exp/features-tax-meta.biom'
biom[6]='Zenodo/Qiime/520_18S_095_cl_q1exp/features-tax-meta.biom'
biom[7]='Zenodo/Qiime/520_18S_090_cl_q1exp/features-tax-meta.biom'

mappng[1]='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# Define output files
# -------------------
netw[1]='Zenodo/Qiime/540_18S_100_cl_q1bnetw'
netw[2]='Zenodo/Qiime/540_18S_099_cl_q1bnetw'
netw[3]='Zenodo/Qiime/540_18S_098_cl_q1bnetw'
netw[4]='Zenodo/Qiime/540_18S_097_cl_q1bnetw'
netw[5]='Zenodo/Qiime/540_18S_096_cl_q1bnetw'
netw[6]='Zenodo/Qiime/540_18S_095_cl_q1bnetw'
netw[7]='Zenodo/Qiime/540_18S_090_cl_q1bnetw'


# Run Qiime one script 
# --------------------

for ((i=1;i<=7;i++)); do
   # get networks
   make_bipartite_network.py \
     -i "$trpth"/"${biom[$i]}" \
     -m "$trpth"/"${mappng[1]}" \
     -o "$trpth"/"${netw[$i]}" \
     -k taxonomy --md_fields 'k,p,c,o,f' \
   || { echo 'command failed' ; exit 1; }
   # tidy up
   mv "$trpth"/"${netw[$i]}"/otu_network/* "$trpth"/"${netw[$i]}"
done
