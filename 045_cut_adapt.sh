# Wrapper for Qiime2 import script, manifest file must be available.
# More info at https://docs.qiime2.org/2017.10/tutorials/importing/

printf "Running this script may not be necessary, check README \n"

# For debugging only
# ------------------ 
set -x

# Paths needs to change for remote execution, and executable paths have to be
# ---------------------------------------------------------------------------
# adjusted depending on machine location.
# ----------------------------------------
if [[ "$HOSTNAME" != "pc683.eeb.cornell.edu" ]]; then
    printf "Execution on remote...\n"
    cores='40'
    trpth="/data/CU_combined"
    
elif [[ "$HOSTNAME" == "pc683.eeb.cornell.edu" ]]; then
    printf "Setting qiime alias, execution on local...\n"
    cores='2'
    trpth="$(dirname "$PWD")"
    qiime2cli() { qiime "$@"; }
fi

# Defining paths
# --------------
# input file array - ordered ascending by size of input files - check README
#  inpth[1]='Zenodo/Qiime/040_18S_CH_paired-end-import.qza' - cutadapt failing
#  inpth[2]='Zenodo/Qiime/040_18S_SPW_paired-end-import.qza' - cutadapt failing
#  inpth[3]='Zenodo/Qiime/040_18S_PH_paired-end-import.qza'  - cutadapt already done in single project folder
#  inpth[4]='Zenodo/Qiime/040_18S_SPY_paired-end-import.qza' - no data 

# output file array -- ordered ascending by size of input files - check README
#  otpth[1]='Zenodo/Qiime/045_18S_CH_paired-end-trimmed.qza'  - cutadapt failing
#  otpth[2]='Zenodo/Qiime/045_18S_SPW_paired-end-trimmed.qza' - cutadapt failing
#  otpth[3]='Zenodo/Qiime/045_18S_PH_paired-end-trimmed.qza'  - cutadapt already done in single project folder

#  otpth[3]='Zenodo/Qiime/045_18S_SPY_paired-end-import.qza' - no data

# Defining sequences to be cut out:
# ---------------------------------
#  Keep in mind this configuration:
#  *  forward read(5'-3'): - 5' adapter , pad and linker:
#     `AATGATACGGCGACCACCGAGATCTACAC GACTGCACTGA CG`
#  *  reverse read(5'-3'): - 3' adapter, barcode, pad and linker:
#     `CAAGCAGAAGACGGCATACGAGAT NNNNNNNNNNNN GTCTGCTCGCTCAGT CA`
# For now I will only check for linkers at the 5' end, and assume that I do
# not have to worry about read-through. 

# # first assumed configuration - searching for linker:
# fwdcut='GACTGCACTGACG'
# revcut='GTCTGCTCGCTCAGTCA'
# hardly any removed this way (0.1%) - wrong orientation? mismatch?

# second assumed configuration - switching sequences - searching for linker:
# fwdcut='GTCTGCTCGCTCAGTCA'
# revcut='GACTGCACTGACG'
# hardly any removed this way (0.1%) - wrong orientation? mismatch?

# third assumed configuration - switch and reverse-complement - better for R1 (1.6%)
#   - relaxing error parameter to from 10% to 20% (0.5% - 1.5%) - searching for linker: 
# fwdcut='TGACTGAGCGAGCAGAC'
# revcut='CGTCAGTGCAGTC'

# checking FASTQs:
# R1 reads: primers already trimmed reads start after forward primer  GCGGTAATTCCAGCTCCAA
# R2 reads should start after reverse primer TTGGCAAATGCTTTCGC 
# searching for primers:
fwdcut='GCGGTAATTCCAGCTCCAA'
revcut='TTGGCAAATGCTTTCGC'

# run trimming script
# -----------------------------
for ((i=1;i<=3;i++)); do
    qiime cutadapt trim-paired \
        --i-demultiplexed-sequences "$trpth"/"${inpth[$i]}" \
        --p-cores "$cores" \
        --p-front-f "$fwdcut" \
        --p-front-r "$revcut" \
        --p-error-rate 0.1 \
        --o-trimmed-sequences "$trpth"/"${otpth[$i]}" \
        --verbose
done
