# Analysing 18S data from Pearl Harbour 

First look at sequence data arriving 11.01.2018. Needed to see if approach is successful.
If so, 18S data can be generated on large scale. This data also needs to be combined
with the old sequence data. This folder was created 11.01.2018 and last updated
19.01.2018 (on local after 1st roundtrip) The GitHub folder is version tracked.

## Progress notes

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
   
## Todo
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
