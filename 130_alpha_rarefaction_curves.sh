#!/usr/bin/env bash

# 08.05.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Generate interactive alpha rarefaction curves by computing rarefactions
#   between `min_depth` and `max_depth`. The number of intermediate depths to
#   compute is controlled by the `steps` parameter, with n `iterations` being
#   computed at each rarefaction depth. If sample metadata is provided,
#   samples may be grouped based on distinct values within a metadata column.

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi

# define relative input locations - Qiime files
# --------------------------------------------------------
inpth_map='Zenodo/Manifest/06_18S_merged_metadata.tsv' # (should be  `b16888550ab997736253f741eaec47b`)

# define relative input locations - feature tables
# ------------------------------------------------

# Fill table array using find 
inpth_tab_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_tab_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '???_18S_*_tab_*100*.qza' -print0)

# for debugging -  print unsorted tables
# printf '%s\n'
# printf '%s\n' "${inpth_tab_unsorted[@]}"

# Sort array 
IFS=$'\n' inpth_tab=($(sort <<<"${inpth_tab_unsorted[*]}"))
unset IFS

# for debugging -  print sorted tables - ok!
# printf '%s\n'
# printf '%s\n' "${inpth_tab[@]}"


# loop over input tables
for i in "${!inpth_tab[@]}"; do

  # get input sequence file name - for debugging 
  # echo "${inpth_seq[$i]}"
   
  # get input table file name  - for debugging
  # echo "${inpth_tab[$i]}"
    
  directory="$(dirname "$inpth_tab[$i]")"
  tab_file_name="$(basename "${inpth_tab[$i]%.*}")"
  extension=".qzv"
    
  # check string construction - for debugging
  # echo "$seq_file_name"
  # echo "$tab_file_name"
  # echo "$plot_file_name"
    
  plot_file_vis_path="$directory/$plot_file_name"_105_plot_vis"$extension"
  
  ##### continue here #####
    
    # check string construction - for debugging
    # echo "$seq_file_vis_path"
    # echo "$tab_file_vis_path"
    # echo "$plot_file_vis_path"
    
    # Qiime calls
    qiime feature-table tabulate-seqs \
      --i-data "${inpth_seq[$i]}" \
      --o-visualization "$seq_file_vis_path" \
      --verbose

    qiime feature-table summarize \
      --m-sample-metadata-file "$trpth"/"$inpth_map" \
      --i-table "${inpth_tab[$i]}" \
      --o-visualization "$tab_file_vis_path" \
      --verbose
 
    qiime taxa barplot \
      --m-metadata-file "$trpth"/"$inpth_map" \
      --i-taxonomy "$trpth"/"$inpth_tax" \
      --i-table "${inpth_tab[$i]}" \
      --o-visualization "$plot_file_vis_path" \
      --verbose

  else
  
    echo "Sequence- and table files can't be matched, aborting."
    exit
  
  fi
  
done


#### old code ####

# define input and output locations
# =================================

# input files
# ------------
query_tab[1]='Zenodo/Qiime/100_18S_097_cl_metzn_tab.qza'
map_txt[1]='Zenodo/Manifest/05_18S_merged_metadata.tsv'


# output files
# ------------
tax_crv[1]='Zenodo/Qiime/122_18S_097_cl_rarefaction_curves.qzv'

# set call parameters
# -------------------

depth[1]='2500' # see README and `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190403_rarefaction_depth.png`
               # "Retained 467,500 (7.35%) sequences in 187 (78.57%) samples at the specifed sampling depth."
               # default should be the same value as in /Users/paul/Documents/CU_combined/Github/120_get_metazoan_core_metrics.sh 
mptpth[1]='Zenodo/Qiime/115_18S_097_cl_tree_mid.qza' 
               # default should be the same value as in /Users/paul/Documents/CU_combined/Github/120_get_metazoan_core_metrics.sh 

# Run scripts
# ------------
for ((i=1;i<=1;i++)); do
  qiime diversity alpha-rarefaction \
    --i-table "$trpth"/"${query_tab[$i]}" \
    --p-max-depth "${depth[$i]}" \
    --i-phylogeny "$trpth"/"${mptpth[$i]}" \
    --m-metadata-file "$trpth"/"${map_txt[$i]}" \
    --p-min-depth 1 \
    --p-steps 100 \
    --p-iterations 10 \
    --o-visualization "$trpth"/"${tax_crv[$i]}" \
    --verbose 2>&1 | tee -a "$trpth"/"Zenodo/Qiime/122_18S_097_cl_tree_curves_log.txt"
done

