# Analysing combined 18S data from Pearl Harbour, Singapore, Chicago and Adelaide

This folder was created 24.01.2018 by copying folder `/Users/paul/Documents/CU_Pearl_Harbour`.
Folder was and last updated 26.02.2018. The GitHub and Transport folders are 
version tracked, since they are copies from earlier repositories. The first iteration of this
sub-project has been overwritten with the second iteration.

## Background

This folder will be used to combine all project data from individual runs. Sequence runs are processed (at least) until the denoising step and then merged here. Current samples include
   * data of Singapore, Adelaide, Chicago, sourced from `/Users/paul/Documents/CU_SP_AD_CH`
   * data of Pearl Harbor, sourced from `/Users/paul/Documents/CU_SP_AD_CH`
Data will be included via manifest files and metadate files linkedin at `065_merge_data.sh`. The following progress notes document the history of the whole repository. The latest reprocessing was started on the 26.02.2018.

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
* **19.02.2018**
   * updated manifests, scripts 40 and 42, reset execution bits to run-ready scripts
   * import has to be done locally, PH data is difficult to move over to cluster
   * running `040_imp_qiime.sh` - merging is done after demultiplexing
   * FMT tutorial workflow (`https://docs.qiime2.org/2018.2/tutorials/fmt/`) is:
      * `qiime demux summarize`
      * `qiime dada2 denoise-single` (used PE option instead)
      * `qiime feature-table merge`
      * `qiime feature-table merge-seqs`
   * running `040_imp_qiime.sh`
       * Singapore Yacht Club with (almost) no data -- excluding these
       * Chicago only with very few data  -- including these
   * running `045_cut_adapt.sh` - **may not be necessary for combining but keeping dummy file**
       * still failing for Chicago - excluding in next run
       * still failing for Singapore - excluding in next run
       * still working for Pearl Harbour - using and copying file from `/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Qiime/040_18S_paired-end-import.qza`
   * checking demultiplexed quality scores via `050_chk_demux.sh`
       * all visualisations going through ok (`CH`, `SPW`, `PH` )
       * `PH` data poor quality compared to `SPW` and `CH` - need better filtering in earlier steps 
   * pushing to cluster via script `200` (Overwrite remote)
   * running denoising script `60...` on clsuter for `CH`, `PH`, `SPW`
   * files generated on cluster belong to root?
   * CH files are very small - processing error?
* **20.02.2018**
   * denoising finished - next time de-noise only for the necessary data, don't unnecessarily redo
   * pulled files to local - created and run `065_merge_data.sh`
   * created and ran `070_merge_metdata.sh`
   * created and ran `075_smr_features_and_table.sh`
        * in current repset there are still 145 forward primers and 345 reverse primers, these need to get cleaned out in next iteration
   * created `080_re_cut_adapt_and_filter.sh` to clean primer remnants from set of representative sequences. This can also be used to clean repset by blast using Qiime 1 features as per `https://forum.qiime2.org/t/removing-non-target-dna-from-representative-sequences/772/3`.
   * there are still 3' adapter in there, which could be removed? I am setting `-n 2` in cutadapt for a second pass. I don't think the matches are random, is is improbable. Makes few (20?) sequences very short (~50 bp)
   * created and ran `085_smr_features_and_table.sh` (copy for filtered data)
   * adjusting and running `090_align_repseqs.sh`
   * adjusting and running `100_build_tree.sh`
   * script `110` complains because underscores of sample names needed to be removed for script `65`
       * putting underscores back in `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata.tsv` as per error dump
       * re-run `/Users/paul/Documents/CU_combined/Github/070_merge_metdata.sh` to undo this
       * to include more sequences sampling frequency is set from median `6,964` to 1st quartile `847` (PH way more data)
       * metadate a bit dodgy unsurprisingly
    * training classifier with script `120`, running script `130`.
* **26.02.2018** - re-running combination with reprocessed data.
   * current samples include:
      * data of Singapore, Adelaide, Chicago, sourced from `/Users/paul/Documents/CU_SP_AD_CH`
      * data of Pearl Harbor, sourced from `/Users/paul/Documents/CU_SP_AD_CH`
      * data will be included via manifest files and metadate files linkedin at `065_merge_data.sh`.
   * ran `065_merge_data.sh`, `070_merge_metdata.sh`, `075_smr_features_and_table.sh`.
   * running `080_re_cut_adapt_and_filter.sh` with one iteration of `cutadapt` - 3.8% adapter remnants was not too bad
   * running `085_smr_features_and_table.sh`,`090_align_repseqs.sh`, and all others until script `140_show_classification`.
   * metadata file merge was buggy
      * added line breaks to all isolated manifest files
      * add rearranged order of input array in script `65`
      * re-ran `./110_get_core_metrics.sh && ./130_classify_reads.sh && ./140_show_classification.sh` 
* **16.03.2018** - getting rid of COI data and re-running
   * according to YY COI reads can be removed using COI primers:
      * mlCOI (Leray et al. 2013): `GGWACWGGWTGAACWGTWTAYCCYCC`
      * jgHCOI (Geller et al. 2013)`TAIACYTCIGGRTGICCRAARAAYCA`
   * adjusting `/Users/paul/Documents/CU_combined/Github/080_re_cut_adapt_and_filter.sh`
      * now filtering (in the correct orientation - checked) - 18S and COI reads  
      * erasing all old output past this acript in folder `Qiime`
   * re-running scripts starting from script `085...`, using 11626 sequences at cut-off (CH-34-23)
      * ran script `90..`(alignment), `95...` (alignment masking), `100...` (tree building), `110...` (core metrics)
      * re-training classifier after removal of COI reads (in script `120...`) 
      * classify reads using script `130...`
      * showing classification using script `140...`
* **19.03.2018** - some tweaks and analysis start after meeting 
   * filtering alignment and feature table, expanding and re-running script `./100_` and thereafter (`./110...`,`./140...`) - do I need to re-filter the rep-sets after masking alignment? I could not solve this. Posted on Qiime forum.
   * Clustering at different thresholds in script `/Users/paul/Documents/CU_combined/Github/500_cluster_sequences.sh`
   * Created and ran cluster classification script `/Users/paul/Documents/CU_combined/Github/510_classify_clusters.sh`
   * Started `/Users/paul/Documents/CU_combined/Github/520_convert_clusters.sh` (for Cytoscape import and Qiime 1)
          

## Todo
   * (Necessary to remove features from feature  table and sequence set based on masked alignments and tree?)
   * (Blast away unwanted stuff from repset using Qiime 1 as documented in the Qiime 2 forum)
      * analysis of OTU overlap preparation
      * cluster sequences (done 19.03.2018) 
      
      * analysis of covariance preparation
          * exporting Unifrac distance matrix `qiime tools export /Users/paul/Documents/CU_combined/Zenodo/Qiime/110_18S_core_metrics/unweighted_unifrac_distance_matrix.qza --output-dir /Users/paul/Documents/CU_combined/Scratch`
          * renaming Unifrac distance matrix `mv /Users/paul/Documents/CU_combined/Scratch/distance-matrix.tsv /Users/paul/Documents/CU_combined/Scratch/180316_18S_uf_dm.tsv`
          * check `/Users/paul/Box Sync/CU_NIS-WRAPS/170912_code_r/180116_30_select_samples.R` to get invasion risk distance matrix between worldwide ports
          * continue here... 
              * ... normalize by location 


## Relevant Repository contents:

### Folders
* `CU_combined/Github` - analysis scripts
* `CU_combined/Transport` - cluster transport scripts
* `CU_combined/Zenodo` -  data and metadata for upload
* `CU_combined/Zenodo` - useful scripts from previous analysis iterations and draft analyses
*
