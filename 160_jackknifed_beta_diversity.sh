#!/bin/bash

# 07.05.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Qiime 1 jacknived beta diversity - in order to get (jackknifed) 
#   2d PCoA plots

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds="$(nproc --all)"
fi

# define relative input and output locations
# ---------------------------------
inpth_map='Zenodo/Manifest/05_18S_merged_metadata.tsv'
inpth_biom='Zenodo/Qiime/155_18S_097_cl_meta_biom/features-tax-meta.biom'
inpth_tree='Zenodo/Qiime/155_18S_097_cl_meta_biom/105_18S_097_cl_tree_mid.tre'
otpath_bd='Zenodo/Qiime/160_jackkn_beta_div'

depth='10000' # using frequency of 140_18S_097_cl_euk_tab.qzv to include most samples
              # Retained 1,210,000 (21.76%) sequences in 121 (68.36%) samples at the specified sampling depth.

# run script
# ----------
printf "... loading Qiime 1...\n"
source deactivate && source activate qiime1

mkdir -p "$trpth"/"$otpath_bd"

printf "... running Jack-Knived PCoAs...\n"
jackknifed_beta_diversity.py \
   -m "$trpth"/"$inpth_map" \
   -i "$trpth"/"$inpth_biom" \
   -o "$trpth"/"$otpath_bd" \
   -e "$depth" \
   -t "$trpth"/"$inpth_tree" \
   -f

printf "... generting 2d plots from unweighted UNIFRAC PCoA tables...\n"
make_2d_plots.py \
 -i "$trpth"/"$otpath_bd"/unweighted_unifrac/pcoa \
 -m "$trpth"/"$inpth_map" \
 -o "$trpth"/"$otpath_bd" \

printf "...unloading all environments.\n"
source deactivate
