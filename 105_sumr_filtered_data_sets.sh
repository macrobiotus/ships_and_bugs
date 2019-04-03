#!/usr/bin/env bash

# 03.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# https://docs.qiime2.org/2017.11/tutorials/moving-pictures/

# For debugging only
# ------------------ 
# set -x

# Paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "This script needs at least qiime2-2018.08. Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "This script needs at least qiime2-2018.08. Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
fi

# define input and output locations
# --------------------------------

# input files
# ------------
query_seq[1]='Zenodo/Qiime/100_18S_097_cl_cntrl_seq.qza'
query_seq[2]='Zenodo/Qiime/100_18S_097_cl_edna_seq.qza'
query_seq[3]='Zenodo/Qiime/100_18S_097_cl_metzn_seq.qza'

query_tab[1]='Zenodo/Qiime/100_18S_097_cl_cntrl_tab.qza'
query_tab[2]='Zenodo/Qiime/100_18S_097_cl_edna_tab.qza'
query_tab[3]='Zenodo/Qiime/100_18S_097_cl_metzn_tab.qza'

map_txt='Zenodo/Manifest/05_18S_merged_metadata.tsv'
tax_agn='Zenodo/Qiime/095_18S_097_cl_seq_taxonomic_assigmnets.qza'

# output files
# ------------
tabv[1]='Zenodo/Qiime/105_18S_097_cl_cntrl_tab.qzv'
tabv[2]='Zenodo/Qiime/105_18S_097_cl_edna_tab.qzv'
tabv[3]='Zenodo/Qiime/105_18S_097_cl_metzn_tab.qzv'

seqv[1]='Zenodo/Qiime/105_18S_097_cl_cntrl_seq.qzv'
seqv[2]='Zenodo/Qiime/105_18S_097_cl_edna_seq.qzv'
seqv[3]='Zenodo/Qiime/105_18S_097_cl_metzn_seq.qzv'

plot[1]='Zenodo/Qiime/105_18S_097_cl_cntrl_barplot'
plot[2]='Zenodo/Qiime/105_18S_097_cl_edna_barplot'
plot[3]='Zenodo/Qiime/105_18S_097_cl_metzn_barplot'

# Run scripts
# ------------
for ((i=1;i<=3;i++)); do
  qiime feature-table summarize \
   --i-table "$trpth"/"${query_tab[$i]}" \
   --o-visualization "$trpth"/"${tabv[$i]}"  \
   --m-sample-metadata-file "$trpth"/"$map_txt"

  qiime feature-table tabulate-seqs \
    --i-data "$trpth"/"${query_seq[$i]}" \
    --o-visualization "$trpth"/"${seqv[$i]}"

  qiime taxa barplot \
    --i-table "$trpth"/"${query_tab[$i]}" \
    --i-taxonomy "$trpth"/"$tax_agn" \
    --m-metadata-file "$trpth"/"$map_txt" \
    --o-visualization "$trpth"/"${plot[$i]}" \
    --verbose
done
