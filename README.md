# Analysing combined 18S data from Pearl Harbour, Singapore, Chicago

This folder was created 24.01.2018 by copying folder `/Users/paul/Documents/CU_Pearl_Harbour`.
Folder was and last updated 26.01.2018. The GitHub and Transport folders are 
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
   * tried adapter trimming on local 
       * `/042_cut_adapt.sh > ../Zenodo/Qiime/042_cutlog.txt`
       * throws error - move all to cluster - hopefully only low RAM error
    * copying files to cluster: `/Users/paul/Documents/CU_combined/Transport/250_update_remote_push.sh`
    * Chicago reads are "improperly paired" on cluster - deleted files on workdir
* **25.01.2018**
   * altered manifest file to pint to unmerged data, sorted for 18S primer
       * merged data pointed to: `/Users/paul/Documents/CU_inter_intra/Zenodo/Fastq/030_trimmed_18S/`
       * unmerged data now referenced: `/Users/paul/Documents/CU_inter_intra/Zenodo/Fastq/010_sorted/sorted_18S/`
       * re-ran `~/Documents/CU_combined/Github/040_imp_qiime.sh`
       * re-ran `~/Documents/CU_combined/Github/042_cut_adapt.sh`
       * `CH00-0301_62_L001_R1_001.fastq.gz` throws error again. Creating backup copy (`.bak`) and re-run 2 scripts from above, without incorporating Chicago reads.
       * `cutadapt` running successfully when Chicago data is excluded for the time being.
* **26.01.2018**
   * split `05_manifest_local` in three to allow importing and denoising on a per-run basis as recommended.
   * doing the same for `05_metadata_??.tsv`
   * renaming `05_barcode.tsv` to `05_barcode_PH.tsv`, others don't have barcode file
   * adjusting and running `040_imp_qiime.sh` to process individual _runs_.
   * adjusting and running `042_cut_adapt.sh` to process individual _runs_.
* **15.02.2018**
   * erased files created by `042_cut_adapt.sh`, as this is failing
   * creating manifest and `.tsv` metadata file for Singapore Yacht Club
   * `CH`, `SPW`, `SPY` manifest files point to trimmed 18S data at `/Users/paul/Documents/CU_inter_intra/Zenodo/Fastq/030_trimmed_18S`
   * re-trimming input data of `/Users/paul/Documents/CU_inter_intra/`, primers need to be removed
* **16.02.2018**
   * still re-trimming input data of `/Users/paul/Documents/CU_inter_intra/`, primers need to be removed
   * this is done on machine `cbsumm22`, check README.md of other project folder!
* **18.02.2018**
   * primer trimming completed successfully for `CU_inter_intra`
   
## Todo
   * integrate newly trimmed data from `CU_inter_intra`
      * **keep in mind that both repositories need to be on the same machine and in the correct state to pull data from the other project to this one**
      * update manifest file paths and check import paths
      * demultiplexing to be done on a per-run basis
   * find out why reads are improperly paired (filenames? in manifest etc?)
   * if successful
       * collate and adjust subsequent scripts
       * git-commit
       * move to cluster
   * erase files (which are duplicated on remote): `/Users/paul/Sequences/Raw/180111_CU_Lodge_lab`
   * add manifest files and metadata files for Adelaide
   * include Adelaide - needs raw data pull 
   * include other locations into the analysis

## Relevant Repository contents:

### Scripts
*  `040_imp_qiime.sh` - import demultiplexed `fastq` files
*  `042_cut_adapt.sh` - read trimming (by trimming everything before the linkers
*  `044_chk_demux.sh` - read counts and quality check of demultiplexed reads
*  [incomplete]

### Folders
* `CU_combined/Github` - analysis scripts
* `CU_combined/Transport` - cluster transport scripts
* `CU_combined/Zenodo` -  data and metadata
* `CU_combined/Zenodo` - scratch files (e.g. for checking read orientation)
