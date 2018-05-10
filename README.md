# Analysing combined 18S data from all ports with available sequence data

This folder was created 24.01.2018 by copying folder `/Users/paul/Documents/CU_Pearl_Harbour`.
Folder was and last updated 23.03.2018. The `GitHub` and `Transport` folders are 
version tracked, and they are copies from earlier repositories. 

This folder will be used to combine all project data from individual runs. Sequence
runs are processed individually until the denoising step and then merged here.

Data will be included via manifest files and metadate files linked in at 
`065_merge_data.sh`. Current samples include:
   * data of Singapore, Adelaide, Chicago, sourced from `/Users/paul/Documents/CU_SP_AD_CH`
   * data of Pearl Harbor, sourced from `/Users/paul/Documents/CU_SP_AD_CH`


## History and progress notes
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
* **19.03.2018** - _Clustering and Network trials_ - some tweaks and analysis start after meeting 
   * filtering alignment and feature table, expanding and re-running script `./100_` and thereafter (`./110...`,`./140...`) - do I need to re-filter the rep-sets after masking alignment? I could not solve this. Posted on Qiime forum.
   * Clustering at different thresholds in script `/Users/paul/Documents/CU_combined/Github/500_cluster_sequences.sh`
   * Created and ran cluster classification script `/Users/paul/Documents/CU_combined/Github/510_classify_clusters.sh`
   * Started and ran `520_convert_clusters.sh` (for Cytoscape import and Qiime 1)
* **20.03.2018** - _Clustering and Network trials_ - network file generation
   * implemented `530_get_networks.sh` and `540_get_bi_networks.sh`
   * loading files into Cytoscape 3.6.
      * filtering for OTUs more then one degree (6 max for 6 ports): ca. 10 discovered via network filter and collapsing ports
      * see `/Users/paul/Documents/CU_combined/Zenodo/Cytoscape/180320_540_18S_097_cl_q1bnetw_shared_nodes.csv`, filtered `TRUE`
      * via `grep "true"` see `/Users/paul/Documents/CU_combined/Zenodo/Cytoscape/180320_540_18S_097_cl_q1bnetw_shared_nodes_isolated.csv`
      * samples still contain control samples which will need to be filtered out
  * updated `/Users/paul/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/180326_cu_group_meeting/180326_results.md`
* **21.03.2018**
  * expanded `Scratch` folder structure to hold scripts `500...` to `540...` at a later stage
  * copied `500_cluster_sequences.sh` to `200_cluster_sequences.sh` in order to start filtering (also copied output files and changed names)
  * started script `220...`: filtering should run (untested so far!), but grouping is not yet implemented (changed execution flags of scripts and committed)
  * pipeline idea
     * moving superflous scripts to `Scratch`: `mv  5??_* ../Scratch/Shell/`
     * new workflow:
        * `200_cluster_sequences.sh` - get clusters of different similarities
        * `210_filter_samples.sh` - separate eDNA and control samples 
        * `220_classify_clusters.sh` - get a preliminary taxonomic ID via SILVA database - sample inspection to be bolted in here
        * `230_convert_clusters.sh` - get eDNA tables for R and Qiime 1 (`.biom` format):
        * `240_get_bi_networks.sh` (Qiime 1) - create Cytoscape network files (in which ports can be collapsed)   
        * `250_collapse_clusters.sh` (Qiime 1) - collapse clusters for blasting, alternatively collapse using R or network output   
        * `260_blast_clusters.sh` (Qiime 1) - get Blast IDs for eDNA tables (from `.biom` format)
    * analysis and Display items
        * in Cytoscape (Display Item 1)
           * overlap analysis
           * feature visualisation (must and should match R Euler diagrams)
        * in R (Display Item 2 and 3):
          * overlap analysis in Euler diagrams
          * testing of Overlap Matrix versus Risk Matrix
       * blasting and (contamination inspection) - Display Item 4 (and 5)
  * adjusted and ran successfully `210_filter_samples.sh`
  * set x bits and committed
* **22.03.2018**
  * wrote and running classification script `220...`. 
* **23.03.2018**
  * improved classification script `220...`, filenames set correctly now.
  * started to work on scrip `230...` and ran it.
  * updated script list
* **02.04.2018**
  * started to work on scripts `240...`, `250..` and `270...` and ran and ran them.
  * Blasting script 270 could be implemented in Python or employ parallel to be faster.
* **03.04.2018**
  * Blasting failed on local - not enough memory?
  * Extending Blast script to work on cluster
  * Commit and move to cluster
  * on cluster - overwrite was needed - old data was still on cluster
  * copied over nt db to scratch
  * checked script `270...` and trying - blasting script working - addeing taxlookup to script
  * adding download of taxonomy database to ncbi install script (in `Transport` folder)
  * taxdb looup doesn't work properly - email Qi? - changing wierd characters for proper "" and testing again - working now
  * blasting on cluster correctly, including taxonomy ID
* **05.03.2018**
  * blasting done 1:48 in the morning on 16 cores - copying out - chacelling reservation 88900 after 47 hours
* **09.03.2018**
  * wrote and ran script `260...`
  * started preliminary Cytoscape network
     * Cytoscape 3.6
     * importing Edge Table files as _network_ files
     * importing Node and other files as attribute _tables_
     * running Compound Spring Embedder (COSE) layout
* **10.03.2018** - Cytoscape network testing
  * collapsing ports, starting with Pearl Harbour
  * edit Node Type for collapsed groups and set colours
  * save style `180410_18S` and `180410_18S_0` in style file `180410_18S_style.xml`
  * map node size to OTU abundance, save style file again
  * set zoom to 200% (2117 x 1133 px)
  * set Abundance size mapping approximately 8.7 to 30
  * defining filter `180410_18S_overlap_filter`, saving as same file, here selecting 666 higher degree nodes
  * saving group of selected OTUS with name `higher_degree`
  * colouring `higher_degree` notes red via bypassing fill colour in Node options - image exported
  * trying Edge weighted force directed Layout
* **11.03.2018** - Cytoscape
  * Cytoscape 
     * saving new layout as `180411_270_18S_97.cys`
     * inverting filter on network, erasing 1-degree nodes and saving as `180411_270_18S_97_subnet.cys`
     * exporting image as `180409_18S_97_eDNA.png`
  * Analysis design as per talk
    * **Display Item 1** in Cytoscape **functional**
      * feature visualisation (must and should match R Euler diagrams)
      * number of one-degree nodes and higher degree nodes (e.g. 675) - via table export and count
   * **Display Item 2 and 3** via R:
      * overlap analysis in Euler diagrams ***functional**
      * testing of Overlap Matrix versus Risk Matrix  **PENDING**
   * **Display Item 4 (and 5)** via Qiime 1 (and Qiime 2)
     * blasting **functional**
     * and contamination inspection) **PENDING**
   * **Display Item 6 (and 7)** (for talk only
     * maps of all routes and analysed routes **PENDING**
* **12.04.2018** - Blast output to dedicated directory - R scripting
  * moving results of script `270...` there (`Blast` instead of `Qiime`)
  * starting R scripting:
    * Euler graphs, creating `/Users/paul/Documents/CU_combined/Github/500_functions.R`
    * to contain function, creating `/Users/paul/Documents/CU_combined/Github/550_euler.R`
    * Eulerr script is working - overlap numbers showing ok.
      * needs prettying up, possibly
* **16.04.2018** - R scripting
  * copied over sample selection script to use with data feed in
* **17.04.2018** - R scripting - Shell scripting 
  * finished permutation test design `/Users/paul/Documents/CU_combined/Github/500_permutation_test_design.R`
    * need to be evaluated by Giles Hooker
    * can be sped up
    * committed repository
    * needs data feed in
  * started on `/Users/paul/Documents/CU_combined/Github/600_matrix_comparison.R`
    * imports and format Unifrac matrix fine
    * needs properly formatted Risk matrix
      * risk matrix needs to be expanded 
      * would benefit from (some) possible script-backtracking (also for maps later) 
  * worked on data feed-in
    * `./245_get_cluster_core_metrics.sh` (writing to folders `245....`)
      * calls `diversity core-metrics-phylogenetic` of Qiime 2
      * produces all plots and **importantly** Unifrac matrices
      * for data-feed-in to R Unifrac matrices are quick-and-dirty exported to script target directory
      * control files are processed as well, but there are likely no usable results in those folders
  * copied `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R` from `/Users/paul/Box Sync/CU_NIS-WRAPS/170912_code_r/170830_10_cleanup_tables.R`
    * input and output locations adjusted as well as `.Rdata files in `Zenodo/R_Objects`
* **18.04.2018** - R scripting
  * test-rendered: `500_10_gather_predictor_tables.R` - reading / writing ok but using old storage files.
  * test-rendered: `500_20_get_predictor_euklidian_distances.pdf` - reading / writing ok but using old storage files. Copy of `/Users/paul/Box Sync/CU_NIS-WRAPS/170912_code_r/170901_20_calculate_distances.R`.
  * duplicating `/Users/paul/Documents/CU_combined/Github/500_select_samples_SCRATCH.R` and renaming 
    * for risk matrix creation (upper half of script): `/Users/paul/Documents/CU_combined/Github/500_30_get_predictor_risk_matrix.R`
    * foo maps and table creation (lower half of script): `/Users/paul/Documents/CU_combined/Github/500_40_get maps_and_tables.R`
* **19.04.2018** - R scripting
  * improved stats test script after meeting Giles Hooker (and rendered it).
  * filled `/Users/paul/Documents/CU_combined/Github/500_40_get maps_and_tables.R` with lower half of original code, now only for mapping.
  * renamed `/Users/paul/Documents/CU_combined/Github/500_40_get maps_and_tables.R` to `/Users/paul/Documents/CU_combined/Github/500_40_get maps.R`
  * got a working `/Users/paul/Documents/CU_combined/Github/500_30_get_predictor_risk_matrix.R` which writes three files (as documented in script) to `/Users/paul/Documents/CU_combined/Zenodo/R_Objects`.
    * last output file to be used by: `/Users/paul/Documents/CU_combined/Github/500_40_get maps.R`
    * second output file to be used by `/Users/paul/Documents/CU_combined/Github/600_matrix_comparison.R`
  * commit `8bffcbaaadb7267fbcefa9895aab186c1dbbebd6` - `/Users/paul/Documents/CU_combined/Github/500_30_get_predictor_risk_matrix.R` does not yield enough TRIPS to re-calculate environmental matrix
* **24.04.2018** - R scripting
  * `working on /Users/paul/Documents/CU_combined/Github/500_30_get_predictor_risk_matrix.R`
    * renamed to `500_30_shape_matrices.R`
    * outputs for all port pairs: matrix with environmental distances `500_30_shape_matrices__output__mat_env_dist_full.Rdata`
    * outputs for all port pairs: matrix with new invasion risks `500_30_shape_matrices__output__mat_risks_full.Rdata`
    * outputs for all port pairs: matrix with `TRIPS` variable `500_30_shape_matrices__output_mat_trips_full.Rdata`
    * predictor data for mapping script `... /CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_predictor_data.Rdata`
    * script was re-rendered
    * updated todo in this file
    * committed everthing
* **25.04.2018** - R scripting
  * bug chase  - discovered 25.04.2018 -  debug route data not congruent between matrix and table
    * in `500_30_shape_matrices__output_predictor_data.Rdata` - test matrix shows route between ADL 3110 and SINGAPORE 1165
    * in `500_40_get_maps.R` tibble `srout` - does not show route between ADL 3110 and SINGAPORE 1165 - why?
    * in `500_40_get_maps.R` needs to be included into sampled ports `smpld_PID`
    * was desired function.
    * in ` 500_40_get_maps.R` - added ports for which re-processing from old project data was accomplished. This list will not grow so this is a (possibly shaky) solution. The proper (?) alternative _may_ be to add these samples to `src_heap$INVE$PORT`via the input file in `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R`.
  * completed mapping script `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R` - writes to `DI...` folders above `Zenodo` - committed
  * adjusted script `/Users/paul/Documents/CU_combined/Github/500_00_permutation_test_design.R` - `NA`s removed from vectorized matrices - committed
  * adjusted script `/Users/paul/Documents/CU_combined/Github/500_50_matrix_comparison_uni_env.R` - committed
  * adjusted script `/Users/paul/Documents/CU_combined/Github/500_60_matrix_comparison_uni_rsk.R` - need more then 2 routes - committed
* **26.04.2018** - R scripting
  * created `/Users/paul/Documents/CU_combined/Github/500_70_matrix_comparison_uni_prd.R`
  * permutation test is moved to functions script
  * created `/Users/paul/Documents/CU_combined/Github/550_check_taxonomy.R`
* **01.05.2018** - new data availaible
  * commit
  * creating backup copy of this repository which is to be deleted later: `/Users/paul/Documents/CU_combined_BUP`
  * continue work in `/Users/paul/Documents/CU_combined`
* **02.05.2018** - R scripting while new data is being processed
  * `/Users/paul/Documents/CU_combined/Github/550_check_taxonomy.R` now generating a list output **BUT SEE ISSUES**
  * renaming `550_euler.R` to `550_80_euler.R` 
  * renaming `550_check_taxonomy.R`to `550_90_check_taxonomy.R`
  * re-render and commit
  * created `/Users/paul/Documents/CU_combined/Github/500_35_shape_overlap_matrices.R` using Euller code - creates Kulczynski distances from OTU overlap at ports - script generates tabel and can be further expnded
  * moved superseded `550_80_euler.R` to `/Users/paul/Documents/CU_combined/Scratch/R`
  * updated issues
  * commit
* **03.05.2018** - data addition and shell scripting
  * new data is available in `/Users/paul/Documents/CU_US_ports_a` , check that project `README.md`
  * adjusting and running (marked green):
     * `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
     * `/Users/paul/Documents/CU_combined/Github/070_merge_metdata.sh`
     * `/Users/paul/Documents/CU_combined/Github/075_smr_features_and_table.sh`
     * `/Users/paul/Documents/CU_combined/Github/080_re_cut_adapt_and_filter.sh`
     * `/Users/paul/Documents/CU_combined/Github/085_smr_features_and_table.sh`
  * adjusting and running on cluster after commit (marked purple):
     * **OVERWRITING CLUSTER DATA PREVIOUS PROJECT FILES ON CLUSTER ARE DELETED**
     * `/Users/paul/Documents/CU_combined/Github/090_align_repseqs.sh`
     * `/Users/paul/Documents/CU_combined/Github/095_mask_alignment.sh`
     * `/Users/paul/Documents/CU_combined/Github/100_build_tree.sh`
     * running on cluster ok, continuing on cluster:
     * running `./110_get_core_metrics.sh` - needs to be repeated see below
     * ommiting `120_train_classifier.sh`
     * running `130_classify_reads.sh`
       * [Errno 28] - No space left on device
       * defining TMPDIR="/workdir/pc683/tmp/" in command line - no luck
       * defining TMPDIR="/workdir/pc683/tmp/" in script `130` - no luck - no luck
       * omitting `130_classify_reads.sh`
       * omitting `140_show_classification.sh`
    * running adjusted `200_cluster_sequences.sh` - moving to local
       * won't accept `Zenodo/Qiime/100_18S_merged_tab.qza` - features without tree tips removed and not matching with seq file anymore (?)
       * possible solution: using `Zenodo/Qiime/080_18S_merged_tab.qz` or filtering sequence table by feature table `100`
       * adjusted and ran `/Users/paul/Documents/CU_combined/Github/100_build_tree.sh` to generate `/Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_merged_seq.qza`, the latter being 1 MB larger then the input file - metadata / Qiime 2 magic (?)
       * adjusting `200_cluster_sequences.sh` to **use**
          * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_merged_seq.qza`
          * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_merged_tab.qza`
          * **not using** `/Users/paul/Documents/CU_combined/Zenodo/Qiime/080_18S_merged_seq.qza` anymore
          * test run `200_cluster_sequences.sh` on local - ok - updating cluster
          * update with errors - `110_18S_coremetrics` has root permissions
          * restting cluster
      * running adjusted `./110_get_core_metrics.sh` (with newly filtered seqfile 100) - uneccessary - script is not using sequence file (phew)
    * running adjusted `200_cluster_sequences.sh`  - seems to be running ok now
    * running adjusted `/210_filter_samples.sh` - ran ok 
    * copying to local for next steps
    * creating `/Users/paul/Documents/CU_combined/Github/105_smr_features_and_table.sh to inspect filtered results`, comparing
        * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_sum_feat_tab.qzv`
        * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_sum_feat_tab.qzv`
        * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_sum_repr_seq.qzv`
        * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_sum_repr_seq.qzv`
        * seems to be all good
    * adjusting `/Users/paul/Documents/CU_combined/Github/130_classify_reads.sh`
    * adjusting `/Users/paul/Documents/CU_combined/Github/220_classify_clusters.sh`
    * commit and daisy chain both script above overnight - last backup before startin 19:29 - 5 minutes ago
* **04.05.2018** - data addition and shell scripting
   * running adjusted `/Users/paul/Documents/CU_combined/Github/140_show_classification.sh`
   * visualisation `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/140_18S_taxvis_merged/visualization.qzv`
   * ran `/Users/paul/Documents/CU_combined/Github/230_summarize_features_and_sequences.sh`
   * not running `/Users/paul/Documents/CU_combined/Github/220_classify_clusters.sh`:
     * `/Users/paul/Documents/CU_combined/Github/240_visualize_features_and_sequences.sh` and 
     * `/Users/paul/Documents/CU_combined/Github/245_get_cluster_core_metrics.sh` and
     * `/Users/paul/Documents/CU_combined/Github/250_convert_clusters.sh` are now reading taxonomy straight from
     * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/130_18S_taxonomy.qza` (unclustered raw taxonomic assignments)
   * running `/Users/paul/Documents/CU_combined/Github/240_visualize_features_and_sequences.sh` - ok 
   * running `/Users/paul/Documents/CU_combined/Github/245_get_cluster_core_metrics.sh` - ok 
   * running `/Users/paul/Documents/CU_combined/Github/250_convert_clusters.sh` - ok 
   * running `/Users/paul/Documents/CU_combined/Github/260_get_bi_networks.sh` - ok
   * commit and move to cluster to run `/Users/paul/Documents/CU_combined/Github/270_blast_clusters.sh`
   * **USE UPDATE FOR NEXT CLUSTER PULL** pulling back to local, blast results to be included later
* **07.05.2018** - R script running
   * pulled all files off cluster after BLAST completed yesterday
   * adjusted and ran `/Users/paul/Documents/CU_combined/Github/500_35_shape_overlap_matrices.R`
   * adjusted and ran `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R`
   * adjusted and ran `/Users/paul/Documents/CU_combined/Github/550_90_check_taxonomy.R`
   * composed `/Users/paul/Documents/CU_combined/Github/255_jackknifed_beta_diversity.sh` to generate 2d PCoA plots
* **08.05.2018** - R scripting - implementing Mantel tests
   * created `/Users/paul/Documents/CU_combined/Github/500_80_mantel_comparison_uni_prd.R` as copy of `/Users/paul/Documents/CU_combined/Github/500_70_matrix_comparison_uni_prd.R`
   * moved `/Users/paul/Documents/CU_combined/Github/500_60_matrix_comparison_uni_rsk.R` to scratch
* **10.05.2018** - R scripting - implementing mixed effect model during the last days
   * check commit history - this chenge to the README is committed as well and marks the pre-conference stage 


## Todo

## Known issues and bugs
* _25.04.2018_ - **unconfirmed** - non-unique rownames _may be_ assigned to all (?) output (?) matrices in `500_30_shape_matrices`  due to duplicate values in the input tables (script 10)? - possibly affected:
  * `500_30_shape_matrices`
  * `500_70_matrix_comparison_uni_prd.R` and precursors
  * possible unconfirmed reason: some table has only first instances of port names filled, all others port names set NA by previous scripts
* _02.05.2018_ - **unconfirmed** - list output is sparse in `/Users/paul/Documents/CU_combined/Github/550_check_taxonomy.R`
  * possible unconfirmed reason: blast OTU list shorter the OTU list in Phyloseq object - perhaps blast is dropping queries ?
* _02.05.2018_ - **unconfirmed** - `/Users/paul/Documents/CU_combined/Github/500_35_shape_overlap_matrices.R`
  * Kulczynski distances may be unsuitable to describe overlap between ports, both for all overlap or dual overlap.

### R analysis

#### before conference
* adjust transport script paths
* adjust script paths
* add export code to scripts
* export matrix with overlap counts for partial mantel tests
* partial mantel tests -  3 matrices - shuffle predictors - also for talk
    1. partial Mantel: OTU Overlap vs UNIFRAC to setup predictors
    2. partial Mantel: UNIFRAC vs Environmental distance, controlling for Voyages (possibly HON traffic)  
    3. partial Mantel: UNIFRAC vs Voyages, controlling for Environmental distance (possibly HON traffic)  
* include HON distance matrix
* also see `/Users/paul/Box\ Sync/CU_NIS-WRAPS/170728_external_presentations/171128_wcmb/180429_wcmb_practice_talk/180429_wcmb_practice_talk.md`
 
#### later
* test eulerr with unclustered data (?)
* correct OTU numbers (?) - use 97% for now - address both issues though
* stats test - pull quantities from eulerr (?)
* erase `/Users/paul/Documents/CU_combined_BUP` once `/Users/paul/Documents/CU_combined` is processed.
* implement `glm()` between defined samples
  * between Unifrac distances
  * and `500_30_shape_matrices__output__mat_env_dist_full.Rdata`
  * and `500_30_shape_matrices__output__mat_risks_full.Rdata` or `500_30_shape_matrices__output_mat_trips_full.Rdata` ?
  * checked script - `500_30_shape_matrices__output__mat_env_dist_full.Rdata` seem ok

### Shell scripts

### later
* include `decontam` close to script `220...` or bolt in R package `https://github.com/benjjneb/decontam`
* include `evaluate-composition` close to script `220..`(?) to check mock samples
* improve logging during clustering script (see AAD data 26.03.2018 - clustering script usage of `tee`)

## Miscellaneous Notes
* alignment masking does not remove sequences, so filtering the repset in `script 100` is not necessary
* but also calling `qiime phylogeny filter-table` in `script 100` doesn't change the data, so can be left in 
* clustering-free analysis after cluster-based analysis

## Relevant Repository contents:

### Folders
* `CU_combined/Github` - analysis scripts
* `CU_combined/Transport` - cluster transport scripts
* `CU_combined/Zenodo` -  data and metadata for upload
* `CU_combined/Zenodo/Scratch` - useful scripts from previous analysis iterations and draft analyses

### Scripts (likley not up to date)
* `065_merge_data.sh` -  merging sequences and rep.-sequence sets from multiple runs
* `070_merge_metdata.sh` - merging of metadata files
* `075_smr_features_and_table.sh` - get feature table summaries of merged data created above
* `080_re_cut_adapt_and_filter.sh` - removing adapter remnants and COI data that uses the same barcodes as 18S data
* `085_smr_features_and_table.sh` - get feature table summaries of merged and cleaned data created above
* `090_align_repseqs.sh` - self explanatory 
* `095_mask_alignment.sh` - self explanatory
* `100_build_tree.sh` - self explanatory
* `110_get_core_metrics.sh` - creates varies distance measures describing the diversity of the samples
* `120_train_classifier.sh` - discard unnecessary reference data by feeding primers to the reference database
* `130_classify_reads.sh` - get SILVA identifications for the unclustered Amplicon Variants
* `140_show_classification.sh` - show SILVA identifications for the unclustred Amplicon Variants
* `200_cluster_sequences.sh` - analysis of overlap across samples needs clustering, here done for several treshholds
* `210_filter_samples.sh` - among clusters seperate controls from actual data
* `220_classify_clusters.sh` - compare clusters again to reference database, since cluster ID could have changed, create taxonomy visualisations
* `230_summarize_clusters.sh` - get visualisations (in table form) for sequences in clusters and sequences in each samples
* `240_convert_clusters.sh` - get `.biom` files for R import and Cytoscape (can be collapsed in R)
* `250_get_bi_networks.sh` - (via Qiime 1) - get bipartite network files for Cytoscape (can be collapsed in Cytoscape)
* `260_blast_clusters.sh` - (via Qiime 1) - get blast IDs for clusters, in case SILVA is not good enough
