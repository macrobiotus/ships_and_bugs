#!/usr/bin/env bash

# 25.03.2019 - Paul Czechowski - paul.czechowski@gmail.com 
# ========================================================
# Re-trimming of primers from set of representative sequences
# and filtering feature table. For 18S to get rid of remnants,
# for COI to remove them completely, COI data may be in there since
# samples from 18S and COI were pooled with the same barcode.

# For debugging only
# ------------------ 
set -x

# Paths needs to change for remote execution, and executable paths have to be
# ---------------------------------------------------------------------------
# adjusted depending on machine location.
# ----------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    cores="$(nproc --all)"
    trpth="/workdir/pc683/CU_combined"
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Setting qiime alias, execution on local...\n"
    cores="2"
    trpth="/Users/paul/Documents/CU_combined"
fi

# Defining paths
# --------------
# input file
inpth='Zenodo/Qiime/065_18S_merged_seq.qza'
intbl='Zenodo/Qiime/065_18S_merged_tab.qza' 

# temp dir
tppth='Zenodo/Qiime/080_cutadapt_temp'

# output files
otpth='Zenodo/Qiime/080_18S_merged_seq.qza'
ottbl='Zenodo/Qiime/080_18S_merged_tab.qza'

# 18S primers:
# ------------
# trimming 1.3% of reads (trimming 365 of 27,162)
fwdcut[1]='GCGGTAATTCCAGCTCCAA'
adpfcut[1]='GCGAAAGCATTTGCCAA' # was revcutrc

# COI primers 
# -----------
# discarding 1,026 reads with adapters (3.8%), reating 26,136 (96.2%) 
fwdcut[2]='GGWACWGGWTGAACWGTWTAYCCYCC'
adpfcut[2]='TGRTTYTTYGGDCAYCCDGARGTDTA' # was "revcutrc"

# 1) export rep seqs from .qza to .fasta
# ------------------------------------
qiime tools export --input-path "$trpth"/"$inpth" --output-path "$trpth"/"$tppth" || \
  { echo 'export failed' ; exit 1; }

# 2) re-trim 18S sequences  - see http://cutadapt.readthedocs.io/en/stable/guide.html
# ---------------------------------------------------------------------------
cutadapt \
   -j "$cores" \
   -g "${fwdcut[1]}" \
   -a "${adpfcut[1]}" \
   "$trpth"/"$tppth"/"dna-sequences.fasta" \
   -o "$trpth"/"$tppth"/"80_18S_trimmed_seqs.fasta" \
   -O 10 |\
   tee -a "$trpth"/"$tppth"/"80_18S_trimmed_log.txt" ||\
   { echo '18S trim failed' ; exit 1; }

# 3) discard COI sequences  - see http://cutadapt.readthedocs.io/en/stable/guide.html
# ---------------------------------------------------------------------------
cutadapt \
   -j "$cores" -n 1 \
   -g "${fwdcut[2]}" \
   -a "${adpfcut[2]}" \
   "$trpth"/"$tppth"/"80_18S_trimmed_seqs.fasta" \
   -o "$trpth"/"$tppth"/"80_18S_COI_trimmed_seqs.fasta" \
   --discard-trimmed \
   -O 10 | \
   tee -a "$trpth"/"$tppth"/"80_18S_COI_trimmed_log.txt" || \
   { echo 'COI trim failed' ; exit 1; }

# 4) re-import trimmed sequences as qiime artifact
# ----------------------------------------------
qiime tools import --input-path "$trpth"/"$tppth"/"80_18S_COI_trimmed_seqs.fasta" \
  --output-path "$trpth"/"$otpth" \
  --type 'FeatureData[Sequence]'

# 4) filter feature by sequences https://forum.qiime2.org/t/removing-non-target-dna-from-representative-sequences/772/3
# ----------------------------------------------------------------------------
# creating a file containing sequences to keep - manually using bash tools
touch "$trpth"/"$tppth"/"seqs-to-keep.txt" && echo '#OTUID' > "$trpth"/"$tppth"/"seqs-to-keep.txt"
grep '^>' "$trpth"/"$tppth"/"80_18S_COI_trimmed_seqs.fasta" | \
  cut -c 2- >> "$trpth"/"$tppth"/"seqs-to-keep.txt"

# using file to filter out sequences from feature table
qiime feature-table filter-features \
  --m-metadata-file "$trpth"/"$tppth"/"seqs-to-keep.txt" \
  --i-table "$trpth"/"$intbl" \
  --o-filtered-table "$trpth"/"$ottbl" \
  --verbose || \
  { echo 'filter failed' ; exit 1; }
