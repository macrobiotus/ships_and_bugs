#!/usr/bin/env bash

# 21.03.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# merging metadata

# for debugging only
# ------------------ 
set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    trpth="/data/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    qiime2cli() { qiime "$@" ; }
    thrds='2'
fi

# define input locations
# ----------------------

# run 35 still missing, also re-check mapping files
tab[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Manifest/05_metadata.tsv'
tab[2]='/Users/paul/Documents/CU_RT_AN/Zenodo/Manifest/10_18S_mapping_file_10410623.tsv'
tab[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_34.tsv'
tab[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_29.tsv'
tab[5]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_26.tsv'
tab[6]='/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.tsv'

# define output locations
# -----------------------
otpth_tab='Zenodo/Manifest/05_18S_merged_metadata.tsv'

# run script
# ----------

# 'tail -c1 < "$f"' -  reads the last char from a file.
# 'read -r _' - exits with a nonzero exit status if a trailing newline is missing.
# '|| echo >> "$f"' - appends a newline to the file if the exit status of the previous command was nonzero.

touch "$trpth"/"$otpth_tab"
head -n 1  "${tab[1]}" > "$trpth"/"$otpth_tab"
for ((i=1;i<=6;i++)); do
   tail -c1 < "${tab[$i]}" | read -r _ || echo >> "${tab[$i]}"
   tail -n +2 "${tab[$i]}" >> "$trpth"/"$otpth_tab"
done 
