#!/bin/bash

# 17.04.2018 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Run Qiime 2's `qiime2cli diversity core-metrics-phylogenetic` on clustered data
#   mainly to get the Unifrac matrices, but also to get visualisations.

# For debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    cores="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@" ; }
    cores='2'
fi

# input files
# ------------
map_file='Zenodo/Manifest/05_18S_merged_metadata.tsv'
tab_file='Zenodo/Qiime/100_18S_merged_tab.qza'
tree_file='Zenodo/Qiime/100_18S_tree_mdp_root.qza' 
viz_dir='Zenodo/Qiime/110_18S_core_metrics'
depth='12334' # using value from
              #   /Users/paul/Documents/CU_combined/Zenodo/Qiime/230_18S_090_cl_cntrl_tab.qzv
              #   minimum frequencies per sample stay the same across clustering threshold
              #   total feature count changes
              #   VISUALISATIONS FROM CONTROLS WILL (LIKELY) BE USELESS - NOT ENOUGH SEQS IN
              #   TO MATCH DEPTH
# output files
# ------------
# generated from input file names in loop - see below

# Run scripts
# ------------

shopt -s nullglob
for tab_file in $trpth/Zenodo/Qiime/210_18S_???_cl_*_tab.qza ; do
  
  # check if input file exists
  [ -f "$tab_file" ] || continue
  
  # get matching taxonomy filename (dependent input file, which needs to be available)
  filename=$(basename "$tab_file")
  prefix="${filename%.*}"
  prefix="220${prefix:3}"
  ### if `/Users/paul/Documents/CU_combined/Github/220_classify_clusters.sh`
  ### was run uncomment the following line and comment the line below that
  # tax_file="Zenodo/Qiime/${prefix::${#prefix}-4}_tax.qza" # Bash 4: ${foo::-4}
  tax_file="Zenodo/Qiime/130_18S_taxonomy.qza"

  
  # check if dependent input file exists
  [ -f "$trpth"/"$tax_file" ] || continue
  
  # create output directory path
  filename=$(basename "$tab_file")
  prefix="${filename%.*}"
  prefix="245${prefix:3}"
  viz_dir="Zenodo/Qiime/${prefix::${#prefix}-4}_core_metrics" # Bash 4: ${foo::-4}
  
  # for debugging only: 
  
  # list being looped over
  # printf "$tab_file\n"
  
  # dependent input files
  # printf "$trpth"/"$tax_file\n"
  
  # output directory
  # printf "$trpth"/"$viz_dir\n"

  qiime2cli diversity core-metrics-phylogenetic \
    --i-phylogeny "$trpth"/"$tree_file" \
    --i-table "$tab_file" \
    --m-metadata-file "$trpth"/"$map_file" \
    --output-dir "$trpth"/"$viz_dir" \
    --p-sampling-depth "$depth"
  
  qiime2cli tools export \
    "$trpth"/"$viz_dir"/unweighted_unifrac_distance_matrix.qza \
    --output-dir "$trpth"/"$viz_dir"
done
