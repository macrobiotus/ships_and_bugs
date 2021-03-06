#!/usr/bin/env bash

# 29.10.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================

# for debugging only
# ------------------ 
# set -x

# paths need to be adjusted for remote execution
# ----------------------------------------------
if [[ "$HOSTNAME" != "macmini.local" ]]; then
    printf "Execution on remote...\n"
    trpth="/workdir/pc683/CU_combined"
    thrds="$(nproc --all)"
elif [[ "$HOSTNAME" == "macmini.local" ]]; then
    printf "Execution on local...\n"
    trpth="/Users/paul/Documents/CU_combined"
    thrds='2'
fi

# define input locations
# ----------------------

tab[1]='/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Manifest/05_metadata.tsv'             # bf76840a9a267058d2d9a1bff27c6787
tab[2]='/Users/paul/Documents/CU_RT_AN/Zenodo/Manifest/10_18S_mapping_file_10410623.tsv'    # eb22141bc414b4e3782688b1da04760e
tab[3]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_26.tsv'              # f5fdb49fb8944f26a22e8e55a670b0c7
tab[4]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_29.tsv'              # 701c19009b5765a49abd1d7a97db5103
tab[5]='/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_34.tsv'              # 096040394156041a5316aff9457c9b3e
tab[6]='/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.tsv'     # ba096cf526b694f540e090fb4c5f7d1e
tab[7]='/Users/paul/Documents/CU_WL_GH_ZEE/Zenodo/Manifest/05_18S_mapping_file_run_10414227_full.txt' # c090127193c521b27e8cdc96c616fe3d

# define output locations
# -----------------------
otpth_tab='Zenodo/Manifest/05_18S_merged_metadata_preliminary.tsv' # unrevised file: 7e5793b431e9fd28d58715ab65bcae1f

# run script
# ----------

# 'tail -c1 < "$f"' -  reads the last char from a file.
# 'read -r _' - exits with a nonzero exit status if a trailing newline is missing.
# '|| echo >> "$f"' - appends a newline to the file if the exit status of the previous command was nonzero.

touch "$trpth"/"$otpth_tab"
head -n 1  "${tab[1]}" > "$trpth"/"$otpth_tab"
for ((i=1;i<=7;i++)); do
   tail -c1 < "${tab[$i]}" | read -r _ || echo >> "${tab[$i]}"
   tail -n +2 "${tab[$i]}" >> "$trpth"/"$otpth_tab"
done 
