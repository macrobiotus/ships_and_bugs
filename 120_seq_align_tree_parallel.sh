#!/usr/bin/env bash

# 21.04.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Visualising reads after denoising and merging procedure.


# for debugging only
# ------------------ 
# set -x


# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
    export PATH=/programs/parallel/bin:$PATH
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi


# define input locations - sequence files
# ----------------------------------------

# Fill sequence array using find 
# (https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash)

inpth_seq_unsorted=()
while IFS=  read -r -d $'\0'; do
    inpth_seq_unsorted+=("$REPLY")
done < <(find "$trpth/Zenodo/Qiime" -name '???_18S_eDNA_samples_seq_*_115_masked.qza' -print0)

# Sort array 
# (https://stackoverflow.com/questions/7442417/how-to-sort-an-array-in-bash)

IFS=$'\n' inpth_seq=($(sort <<<"${inpth_seq_unsorted[*]}"))
unset IFS

# for debugging -  print sorted input filenames
# printf '%s\n' "${inpth_seq[@]}"


# define output locations - tree files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_tree=("${inpth_seq[@]}")

# create output filenames 
for i in "${!otpth_tree[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_tree[$i]")"
  tree_file_name_in="$(basename "${otpth_tree[$i]%.*}")"
  extension=".qza"
  
  # reconstruct string
  otpth_tree["$i"]="$directory/$tree_file_name_in"_120_tree"$extension"
done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_tree[@]}"


# define output locations - rooted tree files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_rtree=("${otpth_tree[@]}")

# create output filenames 
for i in "${!otpth_rtree[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_rtree[$i]")"
  rtree_file_name_in="$(basename "${otpth_rtree[$i]%.*}")"
  extension=".qza"
  
  # reconstruct string
  otpth_rtree["$i"]="$directory/$rtree_file_name_in"_rooted"$extension"
done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_rtree[@]}"


# define output locations - log files
# ----------------------------------------

# copy previous array to create array for output file names
otpth_log=("${otpth_tree[@]}")

# create output filenames 
for i in "${!otpth_log[@]}"; do
 
  # deconstruct string
  directory="$(dirname "$otpth_log[$i]")"
  seq_file_name_in="$(basename "${otpth_log[$i]%.*}")"
  extension=".txt"
  
  # reconstruct string
  otpth_log["$i"]="$directory/$seq_file_name_in"_log"$extension"
done

# for debugging -  print output filenames
# printf '%s\n'
# printf '%s\n' "${otpth_log[@]}"


# Run scripts
# ------------

for k in "${!inpth_seq[@]}"; do
  
  printf "\n"
  printf "Calculating tree ${inpth_seq[$k]}...\n"
  qiime phylogeny iqtree-ultrafast-bootstrap \
    --i-alignment "${inpth_seq[$k]}" \
    --o-tree "${otpth_tree[$k]}" \
    --p-seed 42 \
    --p-n-cores 0 \
    --p-n-runs 20 \
    --p-bootstrap-replicates 5000 \
    --p-allnni \
    --p-alrt 2000 \
    --p-abayes \
    --p-lbp 2000 \
    --p-bnni \
    --p-safe \
    --verbose  2>&1 | tee -a "${otpth_log[$k]}"
  
  printf "\n"
  printf "Midpoint-rooting "${otpth_tree[$k]}"...\n"  
  qiime phylogeny midpoint-root \
    --i-tree "${otpth_tree[$k]}" \
    --o-rooted-tree "${otpth_rtree[$k]}"

done
