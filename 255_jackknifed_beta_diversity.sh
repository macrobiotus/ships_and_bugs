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
    trpth="/data/CU_combined"
    thrds='14'
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi

# define relative input and output locations
# ---------------------------------
inpth_map='Zenodo/Manifest/05_18S_merged_metadata.tsv'
inpth_biom='Zenodo/Qiime/250_18S_097_cl_edna_biom_export/features-tax-meta.biom'
inpth_tree='Zenodo/Qiime/100_18S_tree_mdp_root.qza'


otpath_bd='Zenodo/Qiime/255_jackkn_beta_div'

# run script
# ----------

# get -e from `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/230_18S_097_cl_cntrl_tab.qzv`

printf "Loading Qiime 2 ...\n"
source deactivate && source activate qiime2-2018.4
 
printf "... exporting tree ...\n"
qiime tools export "$trpth"/"$inpth_tree" --output-dir "$trpth"/"$otpath_bd"
 
printf "... loading Qiime 1...\n"
source deactivate && source activate qiime1
 
 
printf "... running Jack-Knived PCoAs...\n"
jackknifed_beta_diversity.py \
   -i "$trpth"/"$inpth_biom" \
   -o "$trpth"/"$otpath_bd" \
   -e 5000 \
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
