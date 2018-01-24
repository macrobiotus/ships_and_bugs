# Analysing combined 18S data from Pearl Harbour, Singapore, Chicago

This folder was created 24.01.2018 by copying folder `/Users/paul/Documents/CU_Pearl_Harbour`.
Folder was and last updated 24.01.2018. The GitHub and Transport folders are 
version tracked, since they are copies from earlier repositories.

## Background

This folder will be used to combine all project data from individual runs. To 
set this up samples sites included are Singapore Woodlands (SP) and Chicago (CH;both
from Notre Dame sequencing efforts), and Pearl Harbour (PH) samples (first run
conducted at Cornell). Adding samples will likely need trimming of primers, 
denoising and re-classifying the RDP classifier each time, since species may be
shared among locations.

## Progress notes
*  **24.01.2018** - creating and adjusting folder structure and contents
   * removed unneeded files from previous analysis
   * adjusted pathnames in work scripts: `find /Users/paul/Documents/CU_combined/Github -name '*.sh' -exec sed -i 's|CU_Pearl_Harbour|CU_combined|g' {} \;`
   * adjusted pathnames in transport scripts: `find /Users/paul/Documents/CU_combined/Transport -name '*.sh' -exec sed -i 's|CU_Pearl_Harbour|CU_combined|g' {} \;`
   * copy manifest files from Adelaide, Singapore data `cp ~/Documents/CU_inter_intra/Zenodo/Manifest/05_manifest_local.txt ~/Documents/CU_combined/Zenodo/Manifest/05_manifest_ADL_SNG_CHC.txt`
   * adjusting manifest files
      * `05_manifest_local.txt` includes paths to all `fastq` files (PH, CG, SH)
      * `05_metadata.tsv` is draft version only (PH, CG, SH)
      * `05_barcode.tsv` contains PH info only, likely not needed soon.
   * getting files to local:
       * creating dir `mkdir -p /Users/paul/Sequences/Raw/180111_CU_Lodge_lab/`
       * copy files from remote `rsync -avzuin pc683@cbsulogin2.tc.cornell.edu:/home/pc683/Sequences/180109_M01032_0565_000000000-BHB4G/demultiplexed/ /Users/paul/Sequences/Raw/180111_CU_Lodge_lab`
   * adjusting and running import script `/Users/paul/Documents/CU_combined/Github/040_imp_qiime.sh`

   
## Todo
  * erase files (which are duplicated on remote): `/Users/paul/Sequences/Raw/180111_CU_Lodge_lab`


## Old Progress notes

*  **11.01.2018** - starting data analysis
   *  created Qiime2 manifest file (which also point to location of raw data).
   *  working with Qiime2 2017.12 for `cutadapt` functionality.
   *  starting with script `040_imp_qiime.sh`
   *  creating `.git` repository in script folder
* **12.01.2017**
   *  forward read(5'-3'): - 5' adapter , pad and linker: `AATGATACGGCGACCACCGAGATCTACAC GACTGCACTGA CG`
   *  reverse read(5'-3'): - 3' adapter, barcode, pad and linker: `CAAGCAGAAGACGGCATACGAGAT	NNNNNNNNNNNN GTCTGCTCGCTCAGT CA`
   *  completed `/Zenodo/Manifest/05_metadata.txt` in case it is needed, `/Manifest/05_barcode.tsv` is ok to use as well if needed
   *  completed `042_cut_adapt.sh` - tried 1,2,3 adapter orientations, checked `.fastq`. R1 reads are primer-free, since primers are in sequencing primers (?). 
   Thus checking for remnants of primers instead, as documented in script itself. 
   *  adjusted transport scripts and committed
   * started `042_cut_adapt.sh` and logging output in `/Zenodo/Qiime/042_log.txt`. Re-run may be necessary later.
* **15.01.2017**
   * ran `demux summarize` of script `044_[...]`  - mean 1177340 sequences / sample, total 20014787 sequences
   * `050_show_metadata.sh` only converts metadata file to Qiime visualisation
* **16.01.2017**
   * copied and adjusted `060_dns_paired_dada2.sh`
   * copied all files to cluster and then to workdir
   * running `060_dns_paired_dada2` on cluster (now Qiime version 17.12)
* **18.01.2017**
  * demultiplxing done
  * created, adjusted and run `070_smr_features_and_table` (on cluster)
* **19.01.2017**
  * completed Pearl Harbour analysis until basic metrics and annotation - committed Github
   
## Old Todo
* filter sequences for metazoans

## Relevant Repository contents:

### Scripts
*  `040_imp_qiime.sh` - import demultiplexed `fastq` files
*  `042_cut_adapt.sh` - read trimming (by trimming everything before the linkers
*  `044_chk_demux.sh` - read counts and quality check of demultiplexed reads
*  [incomplete]

### Folders
* `CU_Pearl_Harbour/Github` - analysis scripts
* `CU_Pearl_Harbour/Transport` - cluster transport scripts
* `CU_Pearl_Harbour/Zenodo` -  data and metadata
* `CU_Pearl_Harbour/Zenodo` - scratch files (e.g. for checking read orientation)
