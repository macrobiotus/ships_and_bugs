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
inpth_biom='Zenodo/Qiime/250_18S_097_cl_edna_biom_export/features-tax-meta.biom'
inpth_tree='Zenodo/Qiime/100_18S_tree_mdp_root.qza'


otpath_bd='Zenodo/Qiime/255_jackkn_beta_div'

depth='10000' # using frequency of 140_18S_097_cl_euk_tab.qzv to include most samples
              # Retained 1,210,000 (21.76%) sequences in 121 (68.36%) samples at the specified sampling depth.


# run script
# ----------


printf "Loading Qiime 2 ...\n"
source deactivate && source activate qiime2-2018.8
 
printf "... exporting tree ...\n"
qiime tools export "$trpth"/"$inpth_tree" --output-dir "$trpth"/"$otpath_bd"
 
printf "... loading Qiime 1...\n"
source deactivate && source activate qiime1
 
 
printf "... running Jack-Knived PCoAs...\n"
jackknifed_beta_diversity.py \
   -i "$trpth"/"$inpth_biom" \
   -o "$trpth"/"$otpath_bd" \
   -e "$depth" \
   -m "$trpth"/"$inpth_map" \
   -t "$trpth"/"$otpath_bd"/tree.nwk \
   -f

printf "... generting 2d plots from unweighted UNIFRAC PCoA tables...\n"
make_2d_plots.py \
 -i "$trpth"/"$otpath_bd"/unweighted_unifrac/pcoa \
 -m "$trpth"/"$inpth_map" \
 -o "$trpth"/"$otpath_bd" \

printf "...unloading all environments.\n"
source deactivate
