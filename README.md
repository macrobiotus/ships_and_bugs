# Analysing combined 18S data from all ports with available sequence data

## Abstract
We tested if the null hypothesis "Increasing shipping traffic does not
homogenize overall eukaryotic biodiversity between shipping ports" can be
rejected. To do so, we used used a linear random effect model. Considered
parameters where 5-year-summed first order voyage counts between 24 ports, a
compound variable calculated from salinity and temperature values, and the
crossing of different ecoregions, while each unique route was assumed to have
specific, random factors influencing survival of taxa potentially contained in
ballast water pr on the hull. We find that changes in Unifrac distances indeed
are positively and significantly correlated with increasing counts of Voyages.
Consequently, high shipping traffic between the considered ecologically distant
ports appear to be correlated with high similarity of their respective
eukaryotic communities. It remains to be determined if the observed effect is
caused by transport of organisms between ports, or the presence of depauperate
communities in polluted port waters, or both.

## Notes
This folder was created 24.01.2018 by copying folder
`/Users/paul/Documents/CU_Pearl_Harbour`. Folder was and last updated
23.03.2018. The `GitHub` and `Transport` folders are version tracked, and they
are copies from earlier repositories.

This folder will be used to combine all project data from individual runs.
Sequence runs are processed individually until the denoising step and then
merged here.

Data will be included via manifest files and metadate files linked in at
`065_merge_data.sh`. Current samples include: * data of Singapore, Adelaide,
Chicago, sourced from `/Users/paul/Documents/CU_SP_AD_CH` 7   * data of Pearl
Harbor, sourced from `/Users/paul/Documents/CU_SP_AD_CH`


## History and Progress Notes
*  **24.01.2018** - creating and adjusted folder structure and contents
   * removed unneeded files from previous analysis
   * adjusted pathnames in work scripts: `find /Users/paul/Documents/CU_combined/Github -name '*.sh' -exec sed -i 's|CU_Pearl_Harbour|CU_combined|g' {} \;`
   * adjusted pathnames in transport scripts: `find /Users/paul/Documents/CU_combined/Transport -name '*.sh' -exec sed -i 's|CU_Pearl_Harbour|CU_combined|g' {} \;`
   * copy manifest files from Adelaide, Singapore data `cp ~/Documents/CU_inter_intra/Zenodo/Manifest/05_manifest_local.txt ~/Documents/CU_combined/Zenodo/Manifest/05_manifest_ADL_SNG_CHC.txt`
   * adjusted manifest files
      * `05_manifest_local.txt` includes paths to all `fastq` files (PH, CG, SH)
      * `05_metadata.tsv` is draft version only (PH, CG, SH)
      * `05_barcode.tsv` contains PH info only, likely not needed soon.
   * getting files to local:
       * creating dir `mkdir -p /Users/paul/Sequences/Raw/180111_CU_Lodge_lab/`
       * copy files from remote `rsync -avzuin pc683@cbsulogin2.tc.cornell.edu:/home/pc683/Sequences/180109_M01032_0565_000000000-BHB4G/demultiplexed/ /Users/paul/Sequences/Raw/180111_CU_Lodge_lab`
   * adjusted and running import script `/Users/paul/Documents/CU_combined/Github/040_imp_qiime.sh`
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
   * adjusted and running `040_imp_qiime.sh` to process individual _runs_.
   * adjusted and running `042_cut_adapt.sh` to process individual _runs_.
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
   * adjusted and running `090_align_repseqs.sh`
   * adjusted and running `100_build_tree.sh`
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
   * adjusted `/Users/paul/Documents/CU_combined/Github/080_re_cut_adapt_and_filter.sh`
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
  * adjusted and running (marked green):
     * `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
     * `/Users/paul/Documents/CU_combined/Github/070_merge_metdata.sh`
     * `/Users/paul/Documents/CU_combined/Github/075_smr_features_and_table.sh`
     * `/Users/paul/Documents/CU_combined/Github/080_re_cut_adapt_and_filter.sh`
     * `/Users/paul/Documents/CU_combined/Github/085_smr_features_and_table.sh`
  * adjusted and running on cluster after commit (marked purple):
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
       * adjusted `200_cluster_sequences.sh` to **use**
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
    * adjusted `/Users/paul/Documents/CU_combined/Github/130_classify_reads.sh`
    * adjusted `/Users/paul/Documents/CU_combined/Github/220_classify_clusters.sh`
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
   * check commit history - this change to the README is committed as well and marks the pre-conference stage
   * played around for hours - git reset hard - everything rendered with result as in talk - committed 10.05.2018 - ca. 21:00 - also backup 
* **10.07.2018** - organisation
   * undo these steps by using a backup 10 Jul 2018 between 01:00 and 10:00 o'clock.
   * copying this folder "/Users/paul/Documents/CU_combined" to "180124-180510__CU_combined", locking, for later compression and moving to "/Users/paul/Archive/Cornell_superseeded_analyses"
   * continuing to work on this folder
* **20.07.2018** - organisation and preparation for Fort Collins
   * commit current repository (11:14)
   * installing Qiime 2018.6 - updating conda
* **31.07.2018** - check after data migration to SSD
   * updated R and packages
   * checked commit history - seem all good
* **02.08.2018** - coding of species accumulation curves
   * species accumulation curves encoded in `/Users/paul/Documents/CU_combined/Github/500_33_draw_otus_per_sample.R`
   * 18S data does not seem to reach plateau - needs to be filtered for metazoans - or establish that UNIFRAC distance is independant
* **31.08.2018** - change of mapping code
   * see commnets therein
   * code in script `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R` was adjusted for David
   * code and dependencies were copied to `/Users/paul/Box Sync/CU_NIS-WRAPS/170728_external_presentations/180910_neobiota`
* **25.09.2018** - preparation for Argentina
    * postponing Arctic data import, only correct Singapore, clean code, get new display items, make compatible with rarefaction test
    * needs backtracking to `/Users/paul/Documents/CU_SP_AD_CH`, moving there. 
* **28.09.2018** - preparation for Argentina
    * see README.md `/Users/paul/Documents/CU_SP_AD_CH` for current progress of redenoising
       * takes very long and may not finish in time
       * attempting to rename old data of current dir as described in `https://forum.qiime2.org/t/change-sample-ids-after-running-dada2/3918`
    * for renaming of samples copied `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata.tsv` to `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_for_rename.tsv`
    * adding column `SIDnew` to metadata files with sample ids from recently corrected individual files at `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/180925_port_coordinates.csv`
    * resetting all execution flags on shell scripts (`chmod -x *`)
    * creating `/Users/paul/Documents/CU_combined/Github/073_rename_samples.sh`
    * renaming to `/Users/paul/Documents/CU_combined/Github/135_rename_samples.sh`
    * skipping re-running of all shell scripts before `/Users/paul/Documents/CU_combined/Github/135_rename_samples.sh`, and marking related Qiime output grey - all these files have wrong sample ids for Singapore.
    * ran successfully `140_show_classification`
    * modified `150_cluster_sequences` from `200_cluster_sequences.sh` and ran successfully
       * 7488396 nt in 22225 seqs, min 185, max 459, avg 337 
       * Clusters: 13540 Size min 1, max 136, avg 1.6
       * Singletons: 10224, 46.0% of seqs, 75.5% of clusters
    * renaming old data fails with clustering step, since this requires pulling seq id's matching sampl'id's which have been altered
    * possible work around:
       * try script 135 with new debugging plot that crashed today at work end.
       * use `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata.tsv` with old data files in scripts `140...`, `150...`, use script `135...`, then use script `160...`, `170...`. Committing now, continuing denoising as fall-back. 
* ***01.10.2018** - denoising finished yesterday on 24 core cluster
    * also check `/Users/paul/Documents/CU_SP_AD_CH/Github/README.md`
    * adjusted and ran `/065_merge_data.sh`
    * renamed metadata file `mv ../Manifest/05_18S_merged_metadata_for_rename.tsv ../Manifest/05_18S_merged_metadata.tsv` and kept only new sample ids
    * adjusted and ran `./075_smr_features_and_table.sh`
    * now running clustering early, as script `085...`
       * 7108026 nt in 21106 seqs, min 195, max 459, avg 337
       * Clusters: 13135 Size min 1, max 131, avg 1.6
       * Singletons: 9984, 47.3% of seqs, 76.0% of clusters
    * running cluster classification script (`115...`) on 40 core cluster (here)
    * 10x speed increase(?)
    * tested `qiime2r` on Github but decided to stick with adjusted shell solution: `./155...`
    * committed script folder for tomorrows R run
* ***02.10.2018** - R scripting
    * adjusted and running `/Users/paul/Documents/CU_combined/Github/155_get_unifrac_mat.sh`
    * adjusted and running `/Users/paul/Documents/CU_combined/Github/160_convert_artifact.sh`
    * last backup 11:21, 12:05 erasing old output files in
       * `/Users/paul/Documents/CU_combined/Zenodo/Qiime`
       * running `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R` and saving results (`Results`) and R.data files `R_Objects`
    * checking scripts and `Rdata` files of:
       * `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R`
       * `/Users/paul/Documents/CU_combined/Github/500_20_get_predictor_euklidian_distances.R`
    * adjusted and running `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R`
    * moving to scratch `/Users/paul/Documents/CU_combined/Github/500_80_mixed_effect_model.R`
    * committing after running modeling
    * moved more files to `Scratch`: 
        * `/Users/paul/Documents/CU_combined/Github/500_35_shape_overlap_matrices.R`
        * `/Users/paul/Documents/CU_combined/Github/500_50_matrix_comparison_uni_env.R`
        * `/Users/paul/Documents/CU_combined/Github/500_70_matrix_comparison_uni_prd.R`
    * committing after running modeling again.
* ***03.10.2018** - R scripting
   * updated map with newly adjusted mapping script - lot of crap and clutter in there needs to be simplified - saved map - path might still be wonky (output file names)
   * erased blast results, moved all unused scripts to scratch
* ***15.01.2019** - Happy New Year - R scripting
   * attempting implementation of marine realms as suggested by DL and noted in
      * Costello, M. J., Tsai, P., Wong, P. S., Cheung, A. K. L., Basher, Z. and Chaudhary, C. (2017) “Marine biogeographic realms and species endemicity,” Nature Communications. Springer US, 8(1), p. 1057. doi: 10.1038/s41467-017-01121-2.
      * modifying `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R` accordingly
      * commenting old code out
      * changes done, no change to results for preliminary set of ports, committing repository
* **01.03.2019** - quick correction
   * accidentally messed around with classifier files, copied out and back in from `/Users/paul/Documents/CU_mock/Zenodo/Classifier`
* **06.03.2019** - **prepare for improved final data set**
  * **goals**
    * **use adequate merging procedure, and check merging**
    * **use improved classification `blast+` with settings obtained from `CU_mock`**
    * **use `qiime 2018-11` throughout, as this is the version available on cluster**
      * 25.03.2019: using `qiime 2019.1` for clustering and beyond, clustering doesn't work with qiime 2018-11? 
    * **use and Sanger reference data (and later, further streamlined classification if necessary)**
    * **check for batch effects using extra column in mapping files**
  * **this will take some time, and be work over a couple of days at least**
  * for these repositories available to date:
    * `CU_Pearl_Harbour` - denoising on cluster (08.03.2019)
    * `CU_RT_AN` - obtained from cluster (08.03.2019)
    * `CU_SP_AD_CH` - partly denoised (11.03.2019)
    * `CU_US_ports_a` - not started yet (08.03.2019)
  * do this in each repository
     * re-import using `qiime 2018.11`
     * trim adapters as previously
     * re-merge data with less stringent trimming settings
   * once done:
      * re-estimate classification parameters with  `CU_mock/`
      * re-run `CU_cmbd_rf_test/`
      * re-run `CU_combined`
      * analyse `CU_combined`
    * saved compressed copy of `/Users/paul/Archive/Cornell_superseeded_analyses/180501-190306_CU_combined.zip` prior to modifying repository
    * created and executed file to commit all data handling scripts at once: `/Users/paul/Documents/CU_commit_uncombined_transport_scripts.sh`
    * created and executed file to commit all transport scripts at once: `/Users/paul/Documents/CU_commit_uncombined_transport_scripts.sh`
* **07.03.2019** - starting re-merging of individual data sets
   * starting with repository `CU_Pearl_Harbour` as described therein
      * next time add adapter reference to Fastqc script call
      * **updated adapter cutadapt trimming code** - newly trimmed pre-denoised data saved locally
   * starting with repository `CU_RT_AN` as described therein
      * **updated adapter cutadapt trimming code** - newly trimmed pre-denoised data saved locally
* **08.03.2019** - starting re-merging of individual data sets
   * denoising still running for `CU_Pearl_Harbour`
   * **denoising finished for `CU_RT_AN`**
      * retrieved files - merging statistics better - denoising was finished very quick though
   * **starting with repository `CU_SP_AD_CH` as described therein**
* **09.03.2019** - setting up merge of next repositories
  * merging and denoising went ok according to graphic for `CU_Pearl_Harbour` and `CU_RT_AN`
  * denoising was very quick for `CU_RT_AN`
  * repository `CU_SP_AD_CH` is ready for denoise and merge, commit all repositories locally (then added gnuplot code)
* **11.03.2019** - setting up merge of next repositories
  * repository `CU_SP_AD_CH` is still denoising - now finished
  * opening  `CU_US_ports_a` script files for edit
  * obtained `CU_SP_AD_CH` from cluster and checked merging - ok
  * `CU_US_ports_a` is last to be re-merged and denoied
  * committing all repositories, refreshing `CU_US_ports_a` on cluster before starting to work on it
  * `CU_US_ports_a` currently denoising on cluster
* **20.03.2019** - preparing data merging, incl. manifests
  * checking, adjusted, and running  `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh` - ok
* **21.03.2019** - continuing data combination
  * revising mapping files to encode for run origin, creating mapping file for last run (from sample sheets)
    * encode for sequencing run - ok
    * check coordinates - check thoroughly for `CU_RT_AN` only so far
    * check Singapore sample naming - ok
    * check for consistency - ok: Location column can be added to all tables as done in Adelaide data, this column is only in the xlsx sheets for now, for Adelaide, and only there
  * revised and saved Pearl Harbour metadata
    * with columns `SampleID`, `BarcodeSequence`, `LinkerPrimerSequence`, `Port`,`Type`,`Temp`,`Sali`,`Lati`,`Long`,`Run`,`Facility`,`CollYear`
    * re-created `/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Manifest/05_metadata.xlsx`, and
    * overwrote `/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Manifest/05_metadata.tsv` (use this one)
    * updated `PH`-`README.md`
* **22.03.2019** - continuing data combination
  * created and saved mapping file for `CU_RT_AN` data
    * file path is `/Users/paul/Documents/CU_RT_AN/Zenodo/Manifest/10_18S_mapping_file_10410623.xlsx`, and 
    * file path is `/Users/paul/Documents/CU_RT_AN/Zenodo/Manifest/10_18S_mapping_file_10410623.tsv` (use this one)
    * updated `/Users/paul/Documents/CU_RT_AN/Github/README.md`
  * revising metadata for data set `CU_SP_AD_CH`
    * revising and checking data for Chicago - ok
      * use `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_34.xlsx`- as source file, 
      * use `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_34.tsv` - for script
    * revising and checking data for Adleaide - ok
      * `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_29.xlsx` - this file includes sub-locations
      * `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_29.tsv` - this file does not include sub-locations
    * revising and checking for Singapore - ok
      * `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_26.xlsx` - as source file
      * `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_26.tsv` - for script
   * revising metadata for data set `CU_US_ports_a`
      * `/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.xlsx` - as source file
      * `/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.tsv` - for script
* **25.03.2019** - continuing preliminary data combination and analysis
   * checking, adjusted, and running `/Users/paul/Documents/CU_combined/Github/070_merge_metdata.sh` - 
   * created `/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.tsv`
   * created backup copy `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata.xlsx`
   * commit after running script `/Users/paul/Documents/CU_combined/Github/085_cluster_sequences.sh`
   * installing `qiime2-2019.1` as clustering fails, doesn't change anything, script `/Users/paul/Documents/CU_combined/Github/085_cluster_sequences.sh` is buggy
   * testing whether script `~/Documents/CU_combined/Github/080_re_cut_adapt_and_filter.sh` is buggy - yes - possible cause
   * logical error? - filters only COI reads with adapter, but remnants stay in file, with results in crash during clustering ?
   * using untrimmed files in script `~/Documents/CU_combined/Github/085_cluster_sequences.sh` that may contain COI?
   * **NO:** back to inherited data for better cleanup - please check `/Users/paul/Documents/CU_SP_AD_CH/Github/README.md`
   * commit
* **27.03.2019** - preparing data combination after re-cleaning of inherited data
   * mock data available and can be used
     * copying reference data to project directory for inclusion of Sanger Sequences
       * `cp /Users/paul/Sequences/References/SILVA_128_QIIME_release/rep_set/rep_set_18S_only/99/99_otus_18S.fasta \
           /Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract/99_otus_18S.fasta`
       * `cp /Users/paul/Sequences/References/SILVA_128_QIIME_release/taxonomy/18S_only/99/majority_taxonomy_7_levels.txt \
           /Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract/majority_taxonomy_7_levels.txt`
     * copying Sanger data to project directory:
       * `cp "/Users/paul/Box Sync/CU_NIS-WRAPS/170926_mock_communities/190326_checked_mock_sequences_degapped.fasta" \
              /Users/paul/Documents/CU_combined/Zenodo/References/190326_checked_mock_sequences_degapped.fasta`
     * in `/Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract_extended/*`:
       * using md5 sum (`md5 -s`) of fasta sequence to tie together taxonomy and sequence
       * taxonomy from NCBI
       * finished incluions of mock in  `/Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract_extended/99_otus_18S.fasta`
       * finished inclusion of tax strings from NCBI to `/Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract_extended/majority_taxonomy_7_levels.txt`
   * denoising finished for `CU_SP_AD_CH` - needs attention - commit README before return - next
      * review all metadata files
      * export
      * commit
      * re-combine data and files
   * starting revision of metadata files - introducing `Location` column, but accepting unused inconsistent salinity values
      * revised `/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Manifest/05_metadata.xlsx` - not yet exported
      * revised `/Users/paul/Documents/CU_RT_AN/Zenodo/Manifest/10_18S_mapping_file_10410623.xlsx` - not yest exported`
      * revised `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_26.xlsx` - not yet exported
      * revised `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_29.xlsx` - not yet exported
      * revised `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_34.xlsx` - not yet exported
      * revised `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_35.xlsx` although currently unneeded - not yet exported
* **28.03.2019** - preparing data combination after re-cleaning of inherited data
   * continuing revision of metadata files - introducing `Location` column, but accepting unused inconsistent salinity values
      * revised `/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.xlsx`- not yet exported
      * exporting tsv of above files **check for consistency after merging!**
   * exporting files via `open -a "Microsoft Excel"` **check for consistency after merging!**
      * created `/Users/paul/Documents/CU_Pearl_Harbour/Zenodo/Manifest/05_metadata.tsv`
      * created `/Users/paul/Documents/CU_RT_AN/Zenodo/Manifest/10_18S_mapping_file_10410623.tsv`
      * created `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_26.tsv`
      * created `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_29.tsv`
      * created `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_34.tsv`
      * erasing unneeded `/Users/paul/Documents/CU_SP_AD_CH/Zenodo/Manifest/005_metadata_35.tsv` -  recreate if necessary
      * created `/Users/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.tsv`
  * committing all directories centrally to commit all up-to-date `README`s
  * switching to `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
  * adjusted, committing and running `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/065_18S_merged_seq.qza` hash: `2c5ddd2d41d3b1a5c196350dfb1127fa`
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/065_18S_merged_tab.qza` hash: `66ab218cfa3c7b29db4641b9e485a0ad`
  * adjusted, committing and running `/Users/paul/Documents/CU_combined/Github/070_merge_metadata.sh`
  * checking for consistency and resorting `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata.tsv` (`b43365a014d7ac27ea712520e54aca78`)
  * sorted file is `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_checked.tsv` (`c1ca7209941aa96ee9ce9f843b629f98`)
    * ND indices missing
    * salinity values inconsistent
  * adjusted running `/Users/paul/Documents/CU_combined/Github/075_smr_features_and_table.sh` - ok, commit
    * checking manually `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/075_18S_sum_feat_tab.qzv`
    * checking manually `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/075_18S_sum_repr_seq.qzv` - see this file for stats!
    * exporting fasta `/Users/paul/Documents/CU_combined/Zenodo/Qiime/075_18S_sum_repr_seq.fasta.gz` (`cc624f993c7f95d408bc15e625662d53`), noting hash in Geneious import - available in Geneious
  * omitting `/Users/paul/Documents/CU_combined/Github/080_re_cut_adapt_and_filter.sh` and moving to Scratch
  * checking and running `/Users/paul/Documents/CU_combined/Github/085_cluster_sequences.sh`
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_097_cl_tab.qza` - `18b4968f20536432d90294216f9024cc`
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_097_cl_seq.qza` - `4ed466d51ad85d28c9af126595fc5675`
  * checking and running `/Users/paul/Documents/CU_combined/Github/090_smr_features_and_table.sh`
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_097_cl_seq.qzv` 
    * exporting fasta, also to Geneious `/Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_097_cl_seq.fasta.gz` -`ef53e1defcc4b8883f99d94b5b3a23c0`
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_097_cl_tab.qzv` -  see this file for stats!
  * commit for cluster round-trip, committed after those actions (and even more checking) 
    * checking `/Users/paul/Documents/CU_combined/Github/095_align_repseqs.sh` - cluster execution pending
    * checking `/Users/paul/Documents/CU_combined/Github/100_mask_alignment.sh`- cluster execution pending
    * checking `/Users/paul/Documents/CU_combined/Github/105_build_tree.sh` - cluster execution pending
  * daisy chaining scripts `095_align_repseqs.sh` `100_mask_alignment.sh` `105_build_tree.sh` - results pending (after corrections)
  * tree builing running using raxml optimized for speed - meanwhile
     * sync to local - **later only update**  
     * compress full alignment(s) - for masked and unmasked
        * available now on local: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_097_cl_seq_algn.fasta.gz` - `d9489844d01d3f56b2f8e5c82e82a9d8`
        * available now on local: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_097_cl_seq_algn.fasta.gz` - `23537c11b0709f3d88295a7636d029e1` 
     * get hash value(s) - for masked and unmasked - ok
     * in Geneious inspect masked and unmasked - pending
     * restart tree building after `raxml` crashed - modified script on local for `iqtree` - syncing up - starting - waiting... .. running with warning on full 18S alignment.. check end of logfile! ... 
        * keep in mind cool command `watch -n3 tail -"$(($LINES-6))" foo.txt`
  * later (Friday)
    * check tree with all 18S sequences
    * decide if should be run only on metazoans - probably yes - then:
       * sync home adjust script for cluster - classify reads - tree builing etc - reapeat 
* **29.03.2019** - working with metazoan data to get results for Washington DC
  * tree calculation ongoing on cluster `cbsumm05`: **update only, don't commit until finished, do not tocuh scripts `095_align_repseqs.sh`, `100_mask_alignment.sh`, `105_build_tree.sh` **
  * aborted as per Jose - todays plan
    * sync to local - ok 
    * erase output files - ok
    * establish new script order - ok 
    * assigning taxonomy to unaligned sequences, using extende SILVA db - working on it 
    * build second tree parallel - will be done
  * adjusted `/Users/paul/Documents/CU_combined/Github/095_classify_reads.sh` - ***pushing to cluster and running*** -  
    * reference data extract: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_Silva128_Qiime_sequence_import.qza` - `57b8fb7dc5cb40401e2a94e3e5bd1cdc`
    * reference data extract: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_Silva128_Qiime_taxonomy_import.qza` - `fd28a68633a22bc57f3b4e1c3527398d`
  * on cluster: taxonomy is running:
     * in taxonomy assignemnt script `095_classify_reads.sh` blast can't be multithreaded
     * needed to use vsaecrh - needs to be evaluated later & commited once back at local
  * while classification is running, revised: `100_filter_samples.sh`
  * while classification is running, revised: `105_smr_features_and_table.sh`
  * classification crashed due to mis-formated reference data - inserting tabs in reference data files - restart
* **02.04.2019** - restarting classification with properly formatted reference data
  * on local, commit and check, upload to cluster and restart classification
  * using script `/Users/paul/Documents/CU_combined/Github/095_classify_reads.sh`
  * downloaded results to local and cancelled reservationm
  * adjusted and attempting to run `100_filter_samples.sh` after commit - ok
  * ran `100_filter_samples.sh` - ok 
* **03.04.2019** - inspect files - export for R import
  * adjust and run `/Users/paul/Documents/CU_combined/Github/105_sumr_filtered_data_sets.sh` - ok
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_cntrl_barplot.qzv` - ok (huge)
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_cntrl_barplot.qzv`
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_edna_barplot.qzv` - ok (huge)
  * manually exporting metazoan sequences to `/Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_metzn_seq.fasta.gz` - `8f3cdcd2ca1b7c4cfb9b6d262e0be744`
  * testing alignment in Geneious incl. 50% masking - ok (check for hash `8f3cdcd2ca1b7c4cfb9b6d262e0be744`)
  * ran `/Users/paul/Documents/CU_combined/Github/110_align_repseqs.sh`
    * manually exporting and checking in Geneious `/Users/paul/Documents/CU_combined/Zenodo/Qiime/110_18S_097_cl_metzn_seq_algn.fasta.gz` - `91ebd48b842f34feaaa5e800845da8b8`
  * ran `/Users/paul/Documents/CU_combined/Github/110_mask_alignment.sh`
    * manually exporting and checking in Geneious `/Users/paul/Documents/CU_combined/Zenodo/Qiime/110_18S_097_cl_metzn_seq_algn_masked.fasta.gz` - `cdf8cc437665e1e8767a13c88ebc1963`
  * running `/Users/paul/Documents/CU_combined/Github/115_build_tree.sh` - pending
    * manually check tree:
    * export (and un-nest)`qiime tools export --input-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/115_18S_097_cl_tree_mid.qza --output-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/115_18S_097_cl_tree_mid.nwk`
    * get hash `md5 /Users/paul/Documents/CU_combined/Zenodo/Qiime/115_18S_097_cl_tree_mid.nwk`- `03f5934a0467b5b1b6809925c5d31ef4`
    * tree `03f5934a0467b5b1b6809925c5d31ef4` imported to Geneious - not yet prefect
  * adjusted `/Users/paul/Documents/CU_combined/Github/120_get_metazoan_core_metrics.sh`
    * checking sampling depth of `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_metzn_tab.qzv`
    * settling on 2500 seqs, excluding Buenos Aires and others, but keeping at least 4 samples per port
    * for exported screenshot `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190403_rarefaction_depth.png`
    * `"Retained 467,500 (7.35%) sequences in 187 (78.57%) samples at the specifed sampling depth."`
    * commit and run 
  * for interpretation using **unweighted unifrac measure**:
    * as per `https://forum.qiime2.org/t/unweighted-vs-weighted-unifrac-explanation/2206/3`
    * low count OTU's would be most important
    * saved video as `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190403_120_18S_metazoan_core_metrics_Unweihted_unifrac.mov`
 * adjusted and running `/Users/paul/Documents/CU_combined/Github/125_isolate_unifrac_results.sh` - ok, after some fighting, needed to add more explicit commands
 * later - ready to run R scripts
* **04.04.2019** - starting to work on R scripts
  * adjust and run  `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R`
    * data files at `/Users/paul/Documents/CU_combined/Zenodo/R_Objects` are kept for now but most are outdated and will be overwritten - check file dates
    * overwriting `/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_05_UNIFRAC_behaviour_10k_results_list.Rdata`
    * bootstrapping started, executed until lien 429 - ok
    * limit result plotting to less then ~350 port pairs later - ok - rendered results as `.pdf`:
       * see `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190404_500_05_UNIFRAC_behaviour__means.pdf`
       * see: `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190404_500_05_UNIFRAC_behaviour__mad.pdf`
    * save results files as `.Rdata` - ok `/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_05_UNIFRAC_behaviour_10k_results_list.Rdata`
    * commit - check date, should be `4.4.2019` - some corrections after `.pdf` rendering - see `/Users/paul/Documents/CU_combined/Zenodo/Documentation/500_05_UNIFRAC_behaviour.pdf`
    * check and commit repository `/Users/paul/Documents/CU_cmbd_rf_test` - ok 
    * tick off todo list if possible - ok
* **05.04.2019** - starting to work on R scripts
  * in  `500_05_UNIFRAC_behaviour.R`:
     * matrix "lumping" of different sample pair Unifrac distances now done using `median` and not `mean` 
     * check 1st commit 05.05.2019 - in `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R` done in function `get_distance_matrix_means_current_port_matrix_at_sample_count`
     * check 2nd commit 05.05.2019 - in `/Users/paul/Documents/CU_combined/Github/500_00_functions.R`done in function `fill_collapsed_responses_matrix`
     * re-running analyses `500_05_UNIFRAC_behaviour` - pending
     * saving display items - pending
     * re-rendering output - ok
       * old image shows more smoothing due to averages - `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190404_500_05_UNIFRAC_behaviour_via_means_mad_(old).pdf`
       * new image is more realistic - keeping it this way - `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190405_500_05_UNIFRAC_behaviour_via_medians_mad.pdf`
     * commit
* **08.04.2019** - , included rarefaction analysis, continued to work on R scripts
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/122_alpha_rarefaction_curves.sh` - test ok 
  * committed
  * starting full analysis using default values for now - pending
  * can't call `
  * Qiime forum post posted - corrected in script - redoing with mant more metrics
  * continue with R scripts:
    * check `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R`
      * modified for rendering, loading old results, rendered to `.pdf`, committed.
    * check `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R`
      * run, understood, output saved, rendered to `.pdf`, committed.
      * checking `open -a "Microsoft Excel" "/Users/paul/Box Sync/CU_NIS-WRAPS/170727_port_information/170901_Keller_2010_suppl/DDI_696_sm_TableS3.xlsx"`
     * check `/Users/paul/Documents/CU_combined/Github/500_20_get_predictor_euklidian_distances.R`
      * run, **not quite understood (matrix returned as vector?)**, output saved, rendered to `.pdf`, committed.
      * checking hashes of in- and output files 
        * checking `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances__output_old.Rdata) = 203ebd759029b1a317c158106afa2c9f`
        * checking `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances__output.Rdata) = 203ebd759029b1a317c158106afa2c9f` - erasing old file
        * checking `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances_dimnames__output_old.Rdata) = 3fd6a5310a4a49243ed08ea06cef7d9a`
        * checking `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances_dimnames__output.Rdata) = 3fd6a5310a4a49243ed08ea06cef7d9a` - erasing old file
        * checking `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full_old.Rdata) = 5af9364e806e3547dcd8c09d507d3360`
        * checking `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata) = 8c1fe801414f3d4d98e5b4fc0bd1d350` - keeping old file
     * check `/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R`
       * run **understood (matrix formatted to matrix here)**
       * getting first two characters of lines in  mapping file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_checked.tsv`
       * `cut -c 1-2 /Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_checked.tsv | sort | uniq`
       * getting port IDs manually from 
         * `open -a "Microsoft Excel" "/Users/paul/Dropbox/NSF NIS-WRAPS Data/raw data for Mandana/PlacesFile_updated_Aug2017.xlsx"`
         * updated port IDs by manual lookup in this script, use also for later
         * for model use `/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_predictor_data.Rdata"`
         * probably used for sample sorting earlier `/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata"`
         * checking test matrix
           * using `open -a "Microsoft Excel" "/Users/paul/Box Sync/CU_NIS-WRAPS/170727_port_information/160318_57_connected_ports_DERIVATIVE.xlsx"
           * using ` > # 6 * 2 routes expected for Long Beach // Miami // Houston // Baltimore 
                     > mat_trips[c("7597","2331","4899","854"), c("7597","2331","4899","854")]
                           7597 2331 4899 854
                      7597   NA   93   11  26
                      2331   93   NA  429 287
                      4899   11  429   NA  75
                      854    26  287   75  NA`
          *  `7597a2331` in Excel file should be `93` - ok
          *  `2331a854` in Excel file should be `287` - ok 
          *  `4899a7597` in Excel file should be `11` - ok - phew.
       * checking hashes - keeping old files
         * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full_old.Rdata) = 6814d3ba1037f7207db2e28dedef27f2`
         * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full_old.Rdata) = 2c45dfa6251ed1003412e34e3364438e`
         * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_predictor_data_old.Rdata) = 458da23823a94d7010c31d33b6cec39a`
         * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata) = 33bf6915c32ba6bc8c283a2a015ba34c`
         * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full.Rdata) = 2e63d866dc4f7a1011a399ed2f40e1d0`
         * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_predictor_data.Rdata) = 3c07b79451199a2cdd3840c9fe24e72a`
  * continue manuscript and `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R`
* **09.04.2019** - continue to work on R scripts
  * restarted `/Users/paul/Documents/CU_combined/Github/122_alpha_rarefaction_curves.sh` requesting less parameters (after crash)
  * starting to revise `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R`
    * error - Rotterdam not included in `/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R`
      * re run and re-render `/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R`
      * hashes (no changes - only added to test samples):
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_predictor_data.Rdata) = 3c07b79451199a2cdd3840c9fe24e72a`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full.Rdata) = 2e63d866dc4f7a1011a399ed2f40e1d0`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata) = 33bf6915c32ba6bc8c283a2a015ba34c`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata) = 8c1fe801414f3d4d98e5b4fc0bd1d350`
    * continue with adding ecoregions as per Costello - commit
    * finished - inconclusive - render R scripts
    * saving main model output to `/Users/paul/Documents/CU_combined/Zenodo/Results/505_80_mixed_effect_model__model_output.pdf`
  * moving R renders to Results folder via `/Users/paul/Documents/CU_combined/Github/move_preliminary_documentation.sh`
  * script `/Users/paul/Documents/CU_combined/Github/122_alpha_rarefaction_curves.sh* still throws errors` - use new metadata?`
  * commit
  * in `/Users/paul/Documents/CU_combined/Github/500_00_functions.R` changing matrix lumping back to `mean` - commit
  * re-running `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R`
  * in `/Users/paul/Documents/CU_combined/Github/500_00_functions.R` changing matrix lumping back to `median` - commit
  * finished successfully `/Users/paul/Documents/CU_combined/Github/122_alpha_rarefaction_curves.sh`
  * results inconclusive - back to drawing board
    * (include data currently on the sequencer - 2 ports)
    * improve taxonomic classification by means of iterating a analysis concerning the mock samples - we need more then half the data assigned with at least some deeper taxonomy
    * improve alignment
    * improve tree calculation
    * re-run Mixed effect Model on Voyage counts (although I do not think this will improve much) 
    * include HON adjacency values from Mandana instead of trips.
* **10.04.2019** get hashes of DB files - for test in `CU_mock` today
 * consistent with `CU_mock`: `/Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract_extended/99_otus_18S.fasta` `05c54da004175a5f6220f5f4439f8a8d`
 * consistent with `CU_mock`: `/Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract_extended/majority_taxonomy_7_levels.txt` `7c765f8a740c07def24922c1ef8cee20`
 * check classification
   * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_cntrl_barplot.qzv`
   * `iime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_edna_barplot.qzv`
   * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_097_cl_metzn_barplot.qzv`
   * created images
     * controls - unassigned and found reference sequences 
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/190410_controls_clustered_level-7-bars.svg`
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/190410_controls_clustered_level-7-legend.svg`
     * eDNA - unassigned and found metazoans
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/190410_metazoans_clustered_level-4-bars.svg`
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/190410_metazoans_clustered_level-4-legend.svg`
     * metazoans - unassigned and 5 most common phyla - ecluding the most abundant group of copepods 
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/190410_metazoans_clustered_level-5-bars.svg`
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/190410_metazoans_clustered_level-5-legend.svg`
   * committing to save README
* **11.04.2019**  manual inspection
  * exporting (and viewing) data for manual inspection - files are likely edited manually
    * `qiime tools export --input-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_097_cl_seq_taxonomic_assigmnets.qza --output-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_097_cl_seq_taxonomic_assigmnets`
    * `qiime tools export --input-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_097_cl_metzn_seq.qza --output-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_097_cl_metzn_seq`
    * `qiime tools export --input-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_097_cl_metzn_tab.qza --output-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_097_cl_metzn_tab`
    * `biom convert -i /Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_097_cl_metzn_tab/feature-table.biom -o /Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_097_cl_metzn_tab/feature-table.from_biom_w_taxonomy.txt --to-tsv --header-key taxonomy`
    * `qiime tools view ../Zenodo/Qiime/105_18S_097_cl_metzn_tab.qzv`
    * `qiime tools view ../Zenodo/Qiime/105_18S_097_cl_metzn_seq.qzv`
  * from now on use Vsearch parameters as established today in `CU_mock` with `qiime 2019.1`.
  * if possible include  include new data denoised with Qiime 2018-11 for consistency
* **12.04.2019** - break
  * returning to analysis re-iteration once all data from `/Users/paul/Documents/CU_WL_GH_ZEE` is included - committed
* **17.04.2019** - data from `/Users/paul/Documents/CU_WL_GH_ZEE` ready to be included - see commit history and README there
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh` - committed afterwards
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/070_merge_metadata.sh` - ok.
    * raw file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_preliminary.tsv` 
      * hashes to `1a18bd7bfd966c2438a92a76830b09b2`
      * check mapping file manually
    * in revised file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv`
       * with hash `42968ca85ed88b695eafff5d16ef8f2`
       * erased salinity and temperature values
       * place names have underscores, not minuses (in case soem shell work is required)
       * added column `RID` for with two letter abbreviations for R, if needed later
  * adjusted and run `/Users/paul/Documents/CU_combined/Github/075_smr_features_and_table.sh`
  * omitting clustering and summarizing again, may be done later
    * `mv /Users/paul/Documents/CU_combined/Github/085_cluster_sequences.sh /Users/paul/Documents/CU_combined/Scratch/Shell/`
    * `mv /Users/paul/Documents/CU_combined/Github/090_smr_features_and_table.sh  /Users/paul/Documents/CU_combined/Scratch/Shell/`
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/080_classify_reads.sh`
    * use extended reference data - ok
    * use assignment as established in `CU_mock` - ok
    * checking and committing transport scripts
    * commit
    * upload to cluster and run
    * files arrived on cluster - possibly need to change some comments in assigmnet script  - commit once local again
    * started tax assignment on cluster - committed on cluster - results pending
  * evening - remotely
    * tax assignment was completed after 3 hours on 64 cores - pull to macmini via remote - continue with filtering, alignmnet etc.
* **18.04.2019** - sample filtering, alignment, tree - see pictures of todays meeting
  * creating `/Users/paul/Documents/CU_combined/Github/085_filter_project.sh`
    * isolate project features and sequences
    * isolate Arctic features and sequences (for spin-offs)
  * creating `/Users/paul/Documents/CU_combined/Github/090_filter_controls.sh`
    * isolate control features
    * isolate eDNA samples
  * creating  `/Users/paul/Documents/CU_combined/Github/095_cluster_sequences.sh`
    * as collaborators want clustering done, as well
    * filtering is buggy
  * next 
    * plot intermediate results by todays scripts using `/Users/paul/Documents/CU_combined/Github/100_sumr_filtered_data_sets.sh`
    * improve filtering so that clustering can be run
    * finalize `/Users/paul/Documents/CU_combined/Github/100_sumr_filtered_data_sets.sh`
  * improving approach
    * resetting x- flags
    * script order is now (path in script are adjusted)
      * `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
      * `/Users/paul/Documents/CU_combined/Github/070_merge_metadata.sh`
      * `/Users/paul/Documents/CU_combined/Github/075_classify_reads.sh`
  * creating initial summary script with `/Users/paul/Documents/CU_combined/Github/080_smr_features_and_table.sh`
  * taxonomy assignment failed - error in `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
     * commit
     * erasing all files in `/Users/paul/Documents/CU_combined/Zenodo/Qiime`
     * correcting `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
     * keeping `/Users/paul/Documents/CU_combined/Github/070_merge_metadata.sh`
       * and thus `/Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv`
  * ran `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
  * no need to run `/Users/paul/Documents/CU_combined/Github/070_merge_metadata.sh`
  * adjusted `/Users/paul/Documents/CU_combined/Github/075_classify_reads.sh` - not yet run
  * adjusted `/Users/paul/Documents/CU_combined/Github/080_smr_features_and_table.sh` - not yet run
  * next: 
    * commit - move to cluster - order and update scripts
  * on cluster executing `/Users/paul/Documents/CU_combined/Github/075_classify_reads.sh` - ok
    * per `/Users/paul/Documents/CU_combined/Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.txt`:
    * **Matching query sequences: 12035 of 28383 (42.40%)**
  * pulled to local
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/080_smr_features_and_table.sh`
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/080_18S_denoised_tax_vis.qzv`
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/085_split_projects.sh`
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/090_split_controls.sh`
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/095_cluster_sequences.sh`
    * now running - check for counts the following files - done
      * less `/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_log_090_cl.txt`
      * less `/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_log_097_cl.txt`
      * less `/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_log_099_cl.txt`
  * started on `/Users/paul/Documents/CU_combined/Github/100_isolate_taxa.sh`
    * complicated committed draft stage - commit `a03dbe93d6c5481b7ae1857961d8435aa8cad691`
    * completed - filters unclustered and all clustered and control data by three taxa
    * many output files (n = 2 x 6 x 3 = 36)- can be identified by `*100*.qza`
    * ran successfully - commit `30e489568b7e2cbca6cf8d2c2bd9fb152eda3375`
  * drafted on `/Users/paul/Documents/CU_combined/Github/105_smr_filtered_data_sets.sh`
    * commit `e8e377aed57b84047b38fc42ef7b494c79ecf03`
    * many output files (n = 3 x 6 x 3 = 54 for sequence, table, and barplot visualisation)- can be identified by `*105*vis.qzv`
    * commit `8e25e3a3498cf964608d51af64e201e1e722fde`
  * corrected file call in script `100`, re-ran scripts `100` and `105`, commit `de1b3276efa59a4d415ef759514584b76ae649d`
* **20.04.2019** - alignment, tree - see pictures of Thursday's meeting
  * drafted `/Users/paul/Documents/CU_combined/Github/110_seq_align.sh`
  * drafted `/Users/paul/Documents/CU_combined/Github/115_seq_align_mask.sh`
  * drafted `/Users/paul/Documents/CU_combined/Github/120_seq_align_tree.sh`
  * commit `3e65c33034b323273f964508cd192cd974f5f183`
  * tested scripts with subset (restricted through `find` query) - seem to be working - commit `223fbfd54311024500b01bf75bf5dcb5b23246a8`
  * widened script scope (through `find` query) - commit - uploading to cluster for daisy chaining 
  * return pending - on cluster:
    * calling `./110_seq_align.sh && ./115_seq_align_mask.sh && ./120_seq_align_tree.sh`
    * **do overwrite local home afterwards** (and then reorder script names a local home)
    * **check logfiles** - Unassigned sequences could not be put in in masked alignments 
* **21.04.2019** - tree calculation ongoing
  * on cluster - tree calculation takes very long -
  * after aligning and masking restricted scope of files entering tree calculation to only consider eDNA samples at various taxonomic levesls - otherwise takes too long - also tree of controls isn't necessary
  * ***Update, and not overwrite local home**
  * preparing results meeting
    * preparing script `/Users/paul/Documents/CU_combined/Github/145_alignment_export.sh` to export Qiime alignment files to fasta - ok
      * for sanity getting has values of current fasta exports
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_eDNA_samples_seq_099_cl_100_Metazoans_110_alignment_115_masked.fasta) = 602b651222bf83dc0c0c02a100011bfe`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_eDNA_samples_seq_099_cl_100_Eukaryotes_110_alignment_115_masked.fasta) = 9988767dff0346f1a7d810737ff47ee4`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_eDNA_samples_seq_097_cl_100_Metazoans_110_alignment_115_masked.fasta) = f77b69b7062bdcafbd99c2bc7c847f23`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_eDNA_samples_seq_097_cl_100_Eukaryotes_110_alignment_115_masked.fasta) = 782cae00f1f386ba02ef6affc54ef8ce`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_eDNA_samples_seq_090_cl_100_Metazoans_110_alignment_115_masked.fasta) = a95791ecbab2bc03f68dbee4f6047dfe`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_eDNA_samples_seq_090_cl_100_Eukaryotes_110_alignment_115_masked.fasta) = 827653882d29bd2013359a6037d07d76`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_eDNA_samples_seq_100_Metazoans_110_alignment_115_masked.fasta) = 74021e7b165190ec1f18c76d522b470e`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_eDNA_samples_seq_100_Eukaryotes_110_alignment_115_masked.fasta) = 1aa1ad4c034176e8a71324f90b755343`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_seq_100_Metazoans_110_alignment_115_masked.fasta) = 5c8b479a6c95007134c3f43b7446bbe7`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_seq_100_Eukaryotes_110_alignment_115_masked.fasta) = d1e1507bdb9e68cb8d76411d02529afc`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_all_samples_seq_100_Metazoans_110_alignment_115_masked.fasta) = bb3766df4edbf2a1f8156518e7dfc30e`
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_all_samples_seq_100_Eukaryotes_110_alignment_115_masked.fasta) = 070f203376c1b70a8654dc78e99b1dd9`
    * prepare command line for plot inspection - ok 
    * sync to laptop and adjust paths (not shown here) - ok 
  * tree calculation crashed  **crashed - see both logfiles**
  * next:
    * trouble-shoot tree calculation
    * generate Unifrac graphs
    * prepare rarefaction curves
  * commit
* **22.04.2019**
  * after meeting, next steps:
     * get better taxonomy assignment treshhold via unclustered sequences 
       * doing this in different repository now
       * doing alter after coming back
         * repeat taxonomic analysis with more the one treshhold as determined
         * get better alignment
         * trouble-shoot tree calculation `https://www.gnu.org/software/parallel/parallel_cheat.pdf`
         * generate Unifrac graphs
         * prepare rarefaction curves
         * get modelling framework
  * committed repository
* **23.04.2019**
  * in addition to what is noted yesterday, perhaps revise naming conventions to maintain consecutive script numbers
    * see also `Users/paul/Documents/CU_tx_test/Github/095_isolate_taxa.sh` (commit `05513af98dea68b4556ef072f8217acdee89ca46`)
* **06.05.2019**
  * latest backup before the following changes is `/Volumes/Time Machine Backups/Backups.backupdb/macmini/2019-05-06-144701`
  * in `075_classify_reads.sh` setting `--p-perc-identity` from `0.97` to `0.86` as per `~/Documents/CU_tx_test/Github/README.md`
  * redoing taxonomic classification with new settings
    * keeping backup copy until next talk with Jose: `/Users/paul/Documents/CU_combined/Zenodo/190509_Qiime.zip`
    * in `/Users/paul/Documents/CU_combined/Zenodo/Qiime` erasing all files with script numbers `075` or higher
    * after local commit uploading to cluster to run `~/Documents/CU_combined/Github/075_classify_reads.sh` and subsequent scripts
    * return pending
       * files arrived on cluster
       * on cluster running updated `075_classify_reads.sh`
       * needed to restart after adjusted parameter from `0.86` to `0.875` so as to match `CU_tx_test`
       * commit once on local
* **07.05.2019** - continuing to re-run pipeline on cluster
  * running `080_smr_features_and_table.sh` - ok 
  * running `085_split_projects.sh` - ok
  * running `090_split_controls.sh` - ok
  * running `095_cluster_sequences.sh` - ok
  * running `100_isolate_taxa.sh` - ok
  * running `105_smr_filtered_data_sets.sh` - ok
  * running `110_seq_align.sh` - ok
  * running `115_seq_align_mask.sh` - ok
  * running `145_alignment_export.sh`
  * todo next
    * filter out non-metazoan Eukaryotes
    * create distance matrices
    * create PCoA plot with Bray Curtis
  * removing files generated after `095_cluster_sequences.sh`
    * `rm *100_Unassigned*`
    * `rm *100_Eukaryotes*`
    * `rm *100_Metazoans*`
  * adjusted `/Users/paul/Documents/CU_combined/Github/100_isolate_taxa.sh` with additional filtering - committed
  * running `/Users/paul/Documents/CU_combined/Github/100_isolate_taxa.sh` with additional filtering - working
  * updated flags and script order **adjust all scripts for which x-flags are unset** - committed
  * daisy chaining all scripts on local (starting 22:57 overnight):
     * `./100_isolate_taxa.sh && ./105_smr_filtered_data_sets.sh` abort due to power outage 
     *  continue at `./110_seq_align.sh && ./115_seq_align_mask.sh && ./120_alignment_export.sh` 
* **08.05.2019** - continuing to re-run pipeline on cluster
  * removed update flags in Transport overwrite scripts
  * pushing data to cluster, on cluster running `./110_seq_align.sh && ./115_seq_align_mask.sh && ./120_alignment_export.sh` - pending
  * on local adjusted **update on pull** - ok 
    * tree calculation script
      * `/Users/paul/Documents/CU_combined/Github/125_seq_align_tree_iqtree.sh`- logically correct but crashed last time
      * `/Users/paul/Documents/CU_combined/Github/126_seq_align_tree_fasttree.sh` -  FastTree used for better parallel execution 
    * rarefaction script - needs tree
      * started `/Users/paul/Documents/CU_combined/Github/130_alpha_rarefaction_curves.sh`
  * updated tree calculation scripts arrived on cluster - commit - **overwrite on pull** - ok
  * synced masked alignments and masked alignments exports to local - commit - sync to cluster
  * running tree calculation on cluster - pending
  * todo afterwards
    * susbet tables to features in trees  
    * rarefaction
* **09.05.2019** - continuing to re-develop pipeline
  * **Note**: Naming conventions change - prepending script number again, instead of appending.  
  * touched `/Users/paul/Documents/CU_combined/Github/127_filter_data_to_match_trees.sh`
  * touched `/Users/paul/Documents/CU_combined/Github/128_smr_matched_data_sets.sh`
  * starting to draft `/Users/paul/Documents/CU_combined/Github/127_filter_data_to_match_trees.sh`
    * reading in sequence files
    * reading in trees
    * reading in feature tables
    * omitting filtering alignments and masked alignments as those are not needed downstream.
    * done - very complicated but running
  * ran successfully `/Users/paul/Documents/CU_combined/Github/127_filter_data_to_match_trees.sh`
  * starting to draft `/Users/paul/Documents/CU_combined/Github/127_filter_data_to_match_trees.sh`
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/128_smr_matched_data_sets.sh`
* **10.05.2019** - continuing to re-develop pipeline
  * adjusted `/Users/paul/Documents/CU_combined/Github/130_alpha_rarefaction_curves.sh`
    * depth is manually set to `10000` as per `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/128_18S_eDNA_samples_100_Metazoans_features.qzv`
    * for later scripts adjusted as required using rarefaction plots.
  * adjusted `/Users/paul/Documents/CU_combined/Github/135_get_core_metrics.sh` 
    * check feature table visualizations created by `/Users/paul/Documents/CU_combined/Github/128_smr_matched_data_sets.sh`
      * `depth` setting `50000` for Eukaryotes to the total exclusion of `Chicago`.
      * `depth` setting `3000` for Metazoans to the total exclusion of `Haines`.
      * `depth` setting `500` for Unassigned to the total exclusion of `Chicago`.
      * `depth` setting `50000` for Non-Metazoan Eukaryotes to the total exclusion of `Chicago`.
   * commit (`c93e204112c60f53e6bdc9465a1dd20d8b537f86`) and run.
   * syntax corrections and re-run of `0c21fd1bf061036971198e52519e65ddaef82e4c`
     * `/Users/paul/Documents/CU_combined/Github/135_get_core_metrics.sh` (check log files for warnings) and
     *  `/Users/paul/Documents/CU_combined/Github/130_alpha_rarefaction_curves.sh` - finish pending
   * commit `0c21fd1bf061036971198e52519e65ddaef82e4c`
* **13.05.2019** - continuing to re-develop pipeline
  * wrote, corrected, and ran successfully `/Users/paul/Documents/CU_combined/Github/140_export_distance_artefacts.sh`
  * wrote, and ran successfully `/Users/paul/Documents/CU_combined/Github/145_convert_qiime_artifacts.sh` - committed
* **14.05.2019** - continuing to re-develop pipeline
  * adjusted, and ran successfully `/Users/paul/Documents/CU_combined/Github/145_convert_qiime_artifacts.sh` - committed
  * wrote, and run successfully `/Users/paul/Documents/CU_combined/Github/150_parse_otu_tables.R`\
* **15.05.2019** - continuing to re-develop pipeline
  * wrote and ran successfully `/Users/paul/Documents/CU_combined/Github/147_check_qiime_artifacts.sh`
  * wrote and ran successfully `/Users/paul/Documents/CU_combined/Github/133_beta_rarefaction_pcoa.sh`
* **15.05.2019** - preparing talk(s) for next weeks project meeting
  * adjusted slightly and ran `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R`
  * started working on file `/Users/paul/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/190516_meeting_Ithaca/190516_slides_draft.md`
* **16.05.2019** - preparing talk(s) for next weeks project meeting
  * re-running `/Users/paul/Documents/CU_combined/Github/145_convert_qiime_artifacts.sh` - wasn't exporting trees
  * re-running `/Users/paul/Documents/CU_combined/Github/147_check_qiime_artifacts.sh` - wasn't exporting trees
  * to check unfiltered files creating and running `/Users/paul/Documents/CU_combined/Github/091_check_qiime_artifacts.sh` - ok
  * to create summary of raw counts and eDNA counts using:
    * ```qiime feature-table summarize \
           --m-sample-metadata-file "/Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv" \
           --i-table /Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_all_samples_tab.qza \
           --o-visualization /Users/paul/Documents/CU_combined/Zenodo/Qiime/085_18S_all_samples_tab_vis.qzv```
    * ```qiime feature-table summarize \
           --m-sample-metadata-file "/Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv" \
           --i-table /Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_eDNA_samples_tab.qza \
           --o-visualization /Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_eDNA_samples_tab_vis.qzv```
  * started `/Users/paul/Documents/CU_combined/Github/160_parse_otu_tables_phyloseq.R` - unfinished - commit `5353db8fc326a9670eeb1c37627b2ca88597612b`
* **20.05.2019** - preparing talk(s) for this weeks project meeting
  * modified `/Users/paul/Documents/CU_combined/Github/160_parse_otu_tables_phyloseq.R` - simple bar plot
  * continued to work on `/Users/paul/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/190516_meeting_Ithaca/190516_slides_draft.md`
  * worked on FON
    * running and rendering `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R` - no manual handling necessary
    * running and rendering `/Users/paul/Documents/CU_combined/Github/500_20_get_predictor_euklidian_distances.R` - no manual handling necessary
    * running and rendering `/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R` - no manual handling necessary
    * running and rendering `/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R` - no manual handling necessary
    * running and rendering `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R` - manual port lookup necessary
    * exporting UNIFRAC matrix for R ingestion `qiime tools export --input-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/135_18S_eDNA_samples_100_Metazoans_core_metrics/unweighted_unifrac_distance_matrix.qza --output-path /Users/paul/Documents/CU_combined/Zenodo/Qiime/135_18S_eDNA_samples_100_Metazoans_core_metrics/190520_unweighted_unifrac_distance_matrix.txt`
    * running and rendering `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R` - manual port lookup necessary - no significant changes
      * 24 Ports in Unifrac Matrix are `PH SW SY AD CH BT HN HT LB MI AW BA CB NA NO OK PL PM RC RT VN GH WL ZB`
      * added comment to `~/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R` - conflation still based on median, should be mean
      * in `/Users/paul/Documents/CU_combined/Github/500_00_functions.R` function `fill_collapsed_responses_matrix` used mean again for matrix conflation
  * starting to work on HON
    * adjusted `/Users/paul/Documents/CU_combined/Github/510_85_hon_model.R`
    * copying Mandana's data over:
      * `cp "/Users/paul/Box Sync/CU_NIS-WRAPS/190208_hon_data/"* "/Users/paul/Documents/CU_combined/Zenodo/HON_predictors"`
      * data is assymetrical - both lower and upper halves need to be kept
    * adding `function fill_collapsed_responses_matrix_full` to `/Users/paul/Documents/CU_combined/Github/500_00_functions.R` which doesn't half matrices
    * code in `/Users/paul/Documents/CU_combined/Github/510_85_hon_model.R` is draft stage and needs thorough re-coding
    * commit
* **21.05.2019** - meeting - working on Macbook Pro
  * created copies of modeling script - check names
  * starting to adjust FON modeling script for eukaryotes
    * file is `/Users/paulczechowski/Documents/CU_combined/Github/505_80_mixed_effect_model.R`
    * 24 Ports in UNIFRAC Matrix should be `PH SW SY AD CH BT HN HT LB MI AW BA CB NA NO OK PL PM RC RT VN GH WL ZB`
    * exporting UNIFRAC matrix for R ingestion `qiime tools export --input-path /Users/paulczechowski/Documents/CU_combined/Zenodo/Qiime/135_18S_eDNA_samples_100_Eukaryotes_core_metrics/unweighted_unifrac_distance_matrix.qza --output-path /Users/paulczechowski/Documents/CU_combined/Zenodo/Qiime/135_18S_eDNA_samples_100_Eukaryotes_core_metrics/unweighted_unifrac_distance_matrix` 
    * modelling on Eukaryotes improves model
    * model is presumed to become more then slightly significant if HON network is incorporated
    * but, check effect of random UNIFRAC data
  * starting to adjust HON modeling script for eukaryotes
    * `/Users/paulczechowski/Documents/CU_combined/Github/510_85_hon_model.R`
    * results preliminary
  * slides in `/Users/paulczechowski/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/190516_meeting_Ithaca/190520_slides.md`
    * have UNIFRAC PCoA and reafaction curves of metazoan data
    * have simple random effect model based on Eukaryotes
    * modelling script both have eukaryotes included, but / and check for filnames and read in sections
    * commit
* **28.05.2019** - starting final pipeline revision
  * compressing backup copy for later deletion `/Users/paul/Documents/CU_combined/Zenodo/190528_qiime_bup.zip`
  * erasing older files in `/Users/paul/Documents/CU_combined/Zenodo/Qiime`
  * loading `qiime2-2019.4`
  * running `/Users/paul/Documents/CU_combined/Github/085_split_projects.sh` - ok 
  * running `/Users/paul/Documents/CU_combined/Github/090_split_controls.sh` - ok
  * adjusted and running `/Users/paul/Documents/CU_combined/Github/095_summarize_data.sh` - ok
  * adjusted flags and commit
  * implementing control data subtraction via `/Users/paul/Documents/CU_combined/Github/100_subtract_controls.sh`
    * running manually ` qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_controls_tab.qzv`
    * exporting lower frequency table: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_features.csv`
    * converting: `echo "feature-id	frequency" | cat - /Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_features.csv | tr "," "\\t" > /Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_features.tsv`
  * running `/Users/paul/Documents/CU_combined/Github/105_summarize_data.sh`
  * comparing counts before and after control removal via
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_preliminary_eDNA_samples_tab.qzv`
    * `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/105_18S_eDNA_samples_tab.qzv`
  * commit for today
* **29.05.2019** - continuing final pipeline revision
  * adjusted script numbers
  * adjusted, committing, and running `/Users/paul/Documents/CU_combined/Github/110_cluster_sequences.sh` - ok 
  * adjusted, committing, and running `/Users/paul/Documents/CU_combined/Github/115_isolate_taxa.sh` - ok 
  * adjusted, committing, and running `/Users/paul/Documents/CU_combined/Github/120_seq_align.sh` - ok 
  * opening for adjustments `/Users/paul/Documents/CU_combined/Github/125_seq_align_mask.sh` - ok
* **30.05.2019** - continuing final pipeline revision
  * adjusted, and running `/Users/paul/Documents/CU_combined/Github/125_seq_align_mask.sh` - pending
  * updated file script order and committed
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/130_alignment_export.sh` - ok
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/135_calculate_fasttree.sh` - ok
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/140_filter_data_to_match_trees.sh` - ok
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/145_summarize_data.sh` - ok
  * adjusting for cluster usage `/Users/paul/Documents/CU_combined/Github/150_alpha_rarefaction_curves.sh` - ok
  * commit and upload to cluster
  * on cluster running `/Users/paul/Documents/CU_combined/Github/150_alpha_rarefaction_curves.sh` - aborted
* **31.05.2019** - continuing final pipeline revision
  * need to rearrange pipeline to account for sequence removal after tree building
  * adjusting script order and erasing superflous files, and commit - ok.
  * update todo
  * adjusted and ran: `/Users/paul/Documents/CU_combined/Github/120_summarize_data_non_phylogenetic.sh` - ok
  * adjusted, commit, and **running on cluster**: `/Users/paul/Documents/CU_combined/Github/125_alpha_rarefaction_curves_non_phylogenetic.sh` - ok
  * adjusted `/Users/paul/Documents/CU_combined/Github/130_get_core_metrics_non_phylogenetic.sh` - **not run**
    * **run depending on rarefaction results**
    * set rarefaction depth per curves and visualisations in files beginning with number 120
      * Unassigned - 650 - Retained 102,700 (12.37%) features in 158 (67.23%) samples at the specifed sampling depth.
      * Metazoans - 3500 - Retained 731,500 (9.88%) features in 209 (82.61%) samples at the specified sampling depth.
      * Eukaryotes - 75000 - Retained 11,250,000 (39.55%) features in 150 (59.29%) samples at the specifed sampling depth.
      * Eukaryote-non-metazoans - 50000 - Retained 6,100,000 (29.00%) features in 122 (48.22%) samples at the specifed sampling depth.
  * adjusted and run `/Users/paul/Documents/CU_combined/Github/135_seq_align.sh` - ok
  * adjusted and run `/Users/paul/Documents/CU_combined/Github/140_seq_align_mask.sh` - ok
* **01.06.2019** - continuing final pipeline revision
  * adjusted and run `/Users/paul/Documents/CU_combined/Github/145_alignment_export.sh` - ok
  * adjusted and run `/Users/paul/Documents/CU_combined/Github/150_calculate_fasttree.sh` - ok
  * adjusted and run `/Users/paul/Documents/CU_combined/Github/155_filter_data_to_match_trees.sh` - ok
  * finished running `/Users/paul/Documents/CU_combined/Github/120_summarize_data_non_phylogenetic.sh`
    * next: check results, run core metrics and next rarefaction script - commit
  * adjusted for cluster run `~/Documents/CU_combined/Github/160_alpha_rarefaction_curves_phylogenetic.sh`
    * commit, upload to cluster, and running - return pending
* **03.06.2019** - continuing final pipeline revision
  * pulled results from cluster of `~/Documents/CU_combined/Github/160_alpha_rarefaction_curves_phylogenetic.sh`
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/165_summarize_data_phylogenetic.sh`
  * adjusting rarefaction depths
    * in `/Users/paul/Documents/CU_combined/Github/130_get_core_metrics_non_phylogenetic.sh`
      * set rarefaction depths - checking `120_*.qzv`
        * Unassigned - 650 - Retained 102,700 (12.37%) features in 158 (67.23%) samples at the specifed sampling depth - **ok**
        * Eukaryotes - 65000 - Retained 11,245,000 (39.53%) features in 173 (68.38%) samples at the specifed sampling depth. - **ok**
        * Eukaryote-non-metazoans - 40000 - Retained 6,320,000 (30.04%) features in 158 (62.45%) samples at the specifed sampling depth. - **ok**
        * Metazoans - 3500 - Retained 731,500 (9.88%) features in 209 (82.61%) samples at the specified sampling depth. - **ok**
    * and `/Users/paul/Documents/CU_combined/Github/165_get_core_metrics_phylogenetic.sh`
      * set rarefaction depths - checking `165_*.qzv` - seems to be identical to above - all features are also tree tip identifiers?
        * Unassigned - 650 - Retained 102,700 (12.37%) features in 158 (67.23%) samples at the specifed sampling depth. - **ok**
        * Eukaryotes - 65000 - Retained 11,245,000 (39.53%) features in 173 (68.38%) samples at the specifed sampling depth - **ok**
        * Eukaryote-non-metazoans - Retained 6,320,000 (30.04%) features in 158 (62.45%) samples at the specifed sampling depth. - **ok**
        * Metazoans - 3500 - Retained 731,500 (9.88%) features in 209 (82.61%) samples at the specifed sampling depth - **ok**
    * compare numbers of Eukaryotic sequences:
      * unfiltered: 17586 -  `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_seq_Eukaryotes.qzv`
      * alignment: 17586 -  `gzcat /Users/paul/Documents/CU_combined/Zenodo/Qiime/145_18S_eDNA_samples_seq_Eukaryotes_alignment_masked.fasta.gz | grep ">" | wc`
      * filtered: 17586 -  `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/165_eDNA_samples_Eukaryotes_sequences_tree-matched.qzv`.
    * run core metric scripts
  * running `/Users/paul/Documents/CU_combined/Github/130_get_core_metrics_non_phylogenetic.sh` - ok - but throws warnings check logfiles
  * running `/Users/paul/Documents/CU_combined/Github/165_get_core_metrics_phylogenetic.sh` - ok - but throws warnings check logfiles
  * commit `d20641079f14bac850428f46f4470b367e18d360`
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/175_export_all_qiime_artifacts_phylogenetic.sh`
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/180_export_all_qiime_artifacts_non_phylogenetic.sh`
  * commit `36030bd3351e065fc41ad51720ad46af03dfac6a`
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/185_export_UNIFRAC_distance_artefacts.sh` - ok
  * adjusted and ran `/Users/paul/Documents/CU_combined/Github/190_export_JAQUARD_distance_artefacts.sh` - ok
    * **exports both tree-filtered and tree-unfiltered Jacquard results**
  * commit `c18c35ba6aedcca6e4531b2b944a8a2ffaac297d`
* **05.06.2019** - checking distance matrices and starting modelling
  * PCOA of distance matrices 
    * non-phylogenetic, clustered: `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/130_18S_eDNA_samples_clustered90_Eukaryotes_core_metrics_non_phylogenetic/jaccard_emperor.qzv`
    * phylogenetic, unclustered: `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/170_eDNA_samples_Eukaryotes_core_metrics/unweighted_unifrac_emperor.qzv`
  * distance matrices for R import
    * non-phylogenetic, clustered: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/190_18S_eDNA_samples_clustered90_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv`
    * phylogenetic, unclustered: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/185_eDNA_samples_Eukaryotes_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv`
  * sorting scripts and commit
* **06.06.2019** - working on FON of unweighted UNIFRAC and Jacquard indices
  * running and rendering `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R` - no manual handling necessary
  * running and rendering `/Users/paul/Documents/CU_combined/Github/500_20_get_predictor_euklidian_distances.R` - no manual handling necessary
  * running and rendering `/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R` - no manual handling necessary
  * **currently commented out** with UNIFRAC matrix of unclustered data ran and rendered `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R` - Env dist not significant - model significant 
    * 23 Ports in Unifrac Matrix are  `PH SW SY AD BT HN HT LB MI AW CB HS NA NO OK PL PM RC RT VN GH WL ZB`
  * **currently commented in**  with JAQUARD matrix of 90% clustered data ran and rendered `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R` - JAQUARD dist not significant - model not significant 
    * 23 Ports in Jacquard Matrix are `PH SW SY AD BT HN HT LB MI AW CB HS NA NO OK PL PM RC RT VN GH WL ZB`
  * commit
* **07.06.2019** - adding data sets with more inclusive clustering threshold (possibly still marked in purple in finder view)
  * saving compresses copy of project folder to `/Users/paul/Documents/CU_combined.zip` - erased already.
  * adjusting files to skip readily available analyses:
    * adjusting and running `/Users/paul/Documents/CU_combined/Github/110_cluster_sequences.sh` - ok 
    * adjusting and running `/Users/paul/Documents/CU_combined/Github/115_isolate_taxa.sh` - ok 
    * adjusting and running `/Users/paul/Documents/CU_combined/Github/120_summarize_data_non_phylogenetic.sh` - ok
    * adjusted but did not yet run `/Users/paul/Documents/CU_combined/Github/125_alpha_rarefaction_curves_non_phylogenetic.sh` - run pending
    * adjusted and ran `/Users/paul/Documents/CU_combined/Github/130_get_core_metrics_non_phylogenetic.sh` - ok
    * adjusted and ran `/Users/paul/Documents/CU_combined/Github/190_export_JAQUARD_distance_artefacts.sh`
  * minimal data set available for modelling juts trials:
    * Jacquard matrix of 87% clustered Eukaryote data
    * include in `/Users/paul/Documents/CU_combined/Github/500_80_mixed_effect_model.R`:
      * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/190_18S_eDNA_samples_clustered87_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv`
      * and deemed unnecessary - keeping files but ignoring them
  * commit
  * **To brainstorm overlap analysis:**
    * Trying Procrustes analysis to transform UNIFRAC and Jacquard matrices:
      * careful with folders
        * data set are both matching respective trees - not necessarily the same as in modelling script
          * because data need to be congruent for Procrustes test
          * because need not to be congruent in modelling script see **31.05.2019** (- but  in fact are see **03.06.2019**)
        * clustering as currently read-in in modelling script: 
  
```
    qiime diversity procrustes-analysis \
      --i-reference /Users/paul/Documents/CU_combined/Zenodo/Qiime/170_eDNA_samples_Eukaryotes_core_metrics/unweighted_unifrac_pcoa_results.qza \
      --i-other /Users/paul/Documents/CU_combined/Zenodo/Qiime/170_eDNA_samples_clustered99_Eukaryotes_core_metrics/jaccard_pcoa_results.qza \
      --p-dimensions 5 \
      --o-transformed-reference /Users/paul/Documents/CU_combined/Zenodo/Qiime/170_eDNA_samples_Eukaryotes_core_metrics/unweighted_unifrac_pcoa_results_transformed.qza \
      --o-transformed-other /Users/paul/Documents/CU_combined/Zenodo/Qiime/170_eDNA_samples_clustered99_Eukaryotes_core_metrics/jaccard_pcoa_results_transformed.qza \
      --verbose
    
    qiime emperor procrustes-plot \
      --i-reference-pcoa /Users/paul/Documents/CU_combined/Zenodo/Qiime/170_eDNA_samples_Eukaryotes_core_metrics/unweighted_unifrac_pcoa_results_transformed.qza \
      --i-other-pcoa /Users/paul/Documents/CU_combined/Zenodo/Qiime/170_eDNA_samples_clustered99_Eukaryotes_core_metrics/jaccard_pcoa_results.qza \
      --m-metadata-file /Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv \
      --p-no-ignore-missing-samples \
      --o-visualization /Users/paul/Documents/CU_combined/Zenodo/Qiime/190607_eukaryotes_asv_unifrac_vs_99otu_jaccquard_distanace_matrices.qzv \
      --verbose  
```  
   * kept sorted matrices but erased visualization file
  * **To brainstorm overlap analysis:**: 
    * Checking actual overlap of tree-filtered `asv` data by reviving script `/Users/paul/Documents/CU_combined/Github/550_85_euler.R`
    * code doesn't scale well with large sample numbers
* **10.06.2019** - scripting taxon overlap in R
  * created copy of Euler script from scratch: `/Users/paul/Documents/CU_combined/Github/550_85_get_shared_taxa.R`
  * worked on copy: `/Users/paul/Documents/CU_combined/Github/550_85_get_shared_taxa.R`
  * started function to write fasta files, as well, not yet finished - commit for today.
  * finished and rendered `/Users/paul/Documents/CU_combined/Github/550_85_get_shared_taxa.R` - commit `aeeb47b59992bc707c25ad91a14304a90c98b2fc`
  * adjusting `/Users/paul/Documents/CU_combined/Github/200_fasta_blast.sh` to blast files - ok
    * file written by `/Users/paul/Documents/CU_combined/Github/550_85_get_shared_taxa.R`
    * written to `/Users/paul/Documents/CU_combined/Zenodo/Blast`
  * adjusting `/Users/paul/Documents/CU_combined/Transport/350_sync_ncbi_nt_to_scratch.sh`
  * prepare to run Blast on cluster
    * call on cluster `/Users/paul/Documents/CU_combined/Transport/350_sync_ncbi_nt_to_scratch.sh` - pending 
    * call on cluster `~/Documents/CU_combined/Github/200_fasta_blast.sh` - pending 
    * commit (`5185e628172e16dff1a4abfea08b8b1d49bb66f`)
* **10.06.2019** - formalizing Mantel test and Procrustes analyses
  * retrieved yesterdays blast results
    * subsetting selected fasta files and feature tables in `/Users/paul/Documents/CU_combined/Github/550_85_get_shared_taxa.R`
    * blasting done using `/Users/paul/Documents/CU_combined/Github/200_fasta_blast.sh`
    * can be read in using Megan from `/Users/paul/Documents/CU_combined/Zenodo/Blast`
  * formalizing Mantel test and Procrustes analyses
    * drafted `~/Documents/CU_combined/Github/205_compare_matrices.sh`
    * commit `e60770796a2e40e304855c7c8173b944de19e297`
    * syntax corrections - ok 
      * running unclustered Unifrac vs Jaccquard - ok
      * running 99clustered Unifrac vs Jaccquard - ok
    commit - `1e19901da4e6811142671bb8a7ecfc4e6ad00c1a`
* **12.06.2019** - parsing and saving copy of Blast results
  * creating MEGAN 6 file `/Users/paul/Documents/CU_combined/Zenodo/Results/190612_18S_eDNA_samples_Eukaryotes_2-16_ports_overlap.rma6`
    * blasting done using `/Users/paul/Documents/CU_combined/Github/200_fasta_blast.sh`
    * was be read in using Megan from `/Users/paul/Documents/CU_combined/Zenodo/Blast`
    * read in OTU's found between 2 to 16 port
    * use in conjunction with `/Users/paul/Documents/CU_combined/Zenodo/Blast/500_85_18S_eDNA_samples_Eukaryotes_qiime_artefacts_non_phylogenetic_features_overlap.xlsx`
* **13.06.2019** - as done yesterday - formalizing model calls
  * `Rscript --vanilla` has been added to scripts:
    * `/Users/paul/Documents/CU_combined/Github/175_export_all_qiime_artifacts_phylogenetic.sh` and
    * `/Users/paul/Documents/CU_combined/Github/180_export_all_qiime_artifacts_non_phylogenetic.sh`
  * formalizing model calls
    * revising modelling script:
      * created by copying file to `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` - **ok**
      * commit (`72e9d86af6c4a5f24bae240c8ad7f77114c0b701`) - **ok**
      * moving template file `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R ` to `/Users/paul/Documents/CU_combined/Scratch/R` - **ok**
      * variables to be re-defined in `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` - **finished draft**
      * commit (`897285e9429ea7c1005bab254e7e741045377ae`) - **ok**
      * **draft version finished - continuing below**
  * created draft version of `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`:
    * commit (`3d328473f87c1188048284a2a86b8c73da385172`) including the following
    * executed call is `Rscript --vanilla /Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R /Users/paul/Documents/CU_combined/Zenodo/Qiime/190_18S_eDNA_samples_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv /Users/paul/Documents/CU_combined/Zenodo/Results/`
  * updated function `get_path()` in `/Users/paul/Documents/CU_combined/Github/500_00_functions.R`
    * `get_path = function(source_path = NULL, dest_path=NULL path_addition = NULL, path_suffix = NULL)`
  * updated `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` for new function `get_path()`
    * testing code
       * call: `./210_get_mixed_effect_model_results.sh`
       * monitor: `/Users/paul/Documents/CU_combined/Zenodo/Results/`
  * code is running and ran:
    * `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh` calling
    * `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` calling
    * `/Users/paul/Documents/CU_combined/Github/500_00_functions.R` and writing to
    * `/Users/paul/Documents/CU_combined/Zenodo/Results`
  * commit `f7886d4b083240642d9d3115248809b411d0d004`
  * adding to `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R``
    * time stamp to avoid overwriting in case of identical file names ``/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R`
    * needs matching with order of input files in `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh` - first files executed first
  * commit `f85d137c8a112f022fd5b5c41e2881708b685219`
* **13.06.2019** - preparing slides for results meeting
  * also updated todo with new ideas
  * `.pdf` and Qiime exports for slide generation are copied to `/Users/paul/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/190618_cu_lab_meeting/images/` from:
    * `/Users/paul/Documents/CU_combined/Zenodo/Results/`
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/`
  * re-run  `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R`
    * current map saved to  `/Users/paul/Documents/CU_combined/Zenodo/Results/190614_map.pdf`
    * alongside `/Users/paul/Documents/CU_combined/Zenodo/Results/500_40_get_maps_output__current_routes_sorted.csv`
  * `.md` slides and `.pdf` renders at
    * `/Users/paul/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/190618_cu_lab_meeting`
  * `.pdf` renders also at
    * `/Users/paul/Documents/CU_combined/Zenodo/Documentation/190618_slides.pdf`
    * `/Users/paul/Documents/CU_combined/Zenodo/Documentation/190618_slides_compressed.pdf`
  * commit (`41d1b4e8d2ce84e73ec9358658e8cac43df1d0a`)
* **17.06.2019** - started Mantel test extension but aborted
  * commit `4ae98cb15e414f9c0517971c16e0b78701826db1`
* **17.07.2019** - **work pick-up at Otago University**
  * **updated todo as far as comprehensible**
    * re-run Blast so that Erin is happy (and environmental samples are excluded)
    * modify Mantel test to run on port collapsed samples
    * accommodate different rarefaction depth to check results
    * see word document after updating it from the photographs
  * re-starting to adjust `/Users/paul/Documents/CU_combined/Github/200_fasta_blast.sh`  to exclude environmental samples
   * possible solution: 
    * as per `https://bioinformatics.stackexchange.com/questions/7384/taxon-exclude-list-for-searching-local-blast-database-using-blastn`
    * an as per: `https://ftp.ncbi.nlm.nih.gov/blast/db/v5/blastdbv5.pdf`
      * `blast 2.9.0` running on local
      * `blast 2.9.0` called in script used for cornell biohpc
      * database version needs to be five or higher on local  (unchecked) and / or remote (unchecked) - assuming version are - downloaded after release notes
* **18.07.2019**
  * attempting to install NCBI's Edirect utilities as per `https://www.ncbi.nlm.nih.gov/books/NBK179288/`
  * failed multiple times - requested help from NCBI, Erin & Jose
  * exploring solution as per `https://github.com/bioconda/bioconda-recipes/issues/13415`
    * `conda remove perl`
    * `conda install -c bioconda entrez-direct` - (now removed)
    * not working either - installed on second computer without Anaconda
  * the query file should be able to be generated as per `https://ftp.ncbi.nlm.nih.gov/blast/db/v5/blastdbv5.pdf`
  * creating files for inclusion of eukaryotic samples:
    * on different machine running blast+'s `get_species_taxids.sh -t 2759` (Eukaryota) - saving to file ok.
    * file with Eukaryotic tax ids can be found at: `/Users/paul/Documents/CU_combined/Zenodo/Blast/190718_gi_list_2759.txt`
  * creating files for exclusion of environmental samples:
    * searching for env. samples on NCBI: `https://www.ncbi.nlm.nih.gov/nuccore/?term=%22environmental%20samples%22%5Borganism%5D%20OR%20metagenomes%5Borgn%5D`
    * (search query is "environmental samples"[organism] OR metagenomes[orgn])
    * saving GI list in default order to `/Users/paul/Documents/CU_combined/Zenodo/Blast/190718_gi_list_environmental.txt`
  * adjusting Blast script `/Users/paul/Documents/CU_combined/Github/200_fasta_blast.sh`
    * adding to Blast call:
      * `-taxidlist "$trpth"/Zenodo/Blast/190718_gi_list_2759.txt \` and
      * `-negative_gilist "$trpth"/Zenodo/Blast/190718_gi_list_environmental.txt \`
    * adjusting code that generates file names
    * waiting for Gi list to finish downloading
    * commit repository - ok (`15e27bf9a22b28aada0b0327754ac8479d61b768`).
* **19.07.2019** - re-run Blast so that environmental samples are excluded
  * created `/Users/paul/Documents/CU_combined/Zenodo/Blast/README.md` to document Blast data sets
  * calling `/200_overwrite_remote_push.sh` first time from New Zealand - finished ok. 
  * testing `/Users/paul/Documents/CU_combined/Github/200_fasta_blast.sh` - on local machine - seems to be working
  * commit locally (`a3deb25d4020d7ad928a937998d534fa44dccbe3`) - overwrite cluster (ok)
  * loaded blast db on `cbsumm22` (ok)
  * removing command from blast call as incompatibe: `-taxidlist "$trpth"/Zenodo/Blast/190718_gi_list_2759.txt \ `
  * run on cluster (ok) - retrieve (ok)
* **23.07.2019** - obtaining Blast results - port-collapsing for Mantel test repetition
  * started writing-up methods
  * dowloaded new non-environmental Blast results
  * updated `/Users/paul/Documents/CU_combined/Zenodo/Blast/README.md`
  * results are here:
    * all: `/Users/paul/Documents/CU_combined/Zenodo/Results/190612_18S_eDNA_samples_Eukaryotes_2-16_ports_overlap.rma6`
    * non-environmental: `/Users/paul/Documents/CU_combined/Zenodo/Results/190723_18S_eDNA_samples_Eukaryotes_non_environmental_2-16_ports_overlap.rma6`
  * checked summary file and mailed of
  * for repetion of Mantel/Procrustes script functionality using port collapsed data
    * inspecting original script `/Users/paul/Documents/CU_combined/Github/205_compare_matrices.sh`
      * need to created collapsed matrices first 
        * need to create modified versions of script `130` which collapses tables 
        * need to create modified versions of script `170` which collapses tables
        * need to create modified version of script `205` which uses collapsed tables
    * creating templates for new scripts - not adjusted yet
      * `/Users/paul/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh`
      * `/Users/paul/Documents/CU_combined/Github/171_get_core_metrics_phylogenetic_collapsed.sh`
      * `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices.sh`
      * commit `da7d3db01172a614229fae764004f9a8b7f18faf`
* **24.07.2019** - continuing port-collapsing for Mantel and Procrustes test extensions
  * keeping subsampling depth the same as in parent script to allow comparisons with parent script results
  * collapsed mapping file needs to be created manually - created collapsed mapping file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/07_18S_merged_metadata grouped.tsv`
  * adjusted `/Users/paul/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh` - likely run ok (output not checked yet) 
  * adjusted `/Users/paul/Documents/CU_combined/Github/171_get_core_metrics_phylogenetic_collapsed.sh` - likely run ok (output not checked yet) 
  * next
    * adjust `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices.sh`
      * new in an out paths, new mapping file
    * test and/or run all scripts above
  * committed repository
    * before running (`334f8aaf7e27cad593a0aa775bdb7328fbf1d75a`)
    * and after running and adding comments to this section (`77fa0274c536d5d64359fde7b0f023524efe7f12`)
  * started adjusting `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices.sh`
* **25.07.2019** - encoding Mantel and Procrustes test extensions
  * hostname has been set to `macmini.staff.uod.otago.ac.nz`
  * further adjusting script `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices.sh`
  * testing script `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices.sh`
    * Mantel tests are available:
      * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/206_18S_eDNA_samples_Eukaryotes_mantel-test_prt-cllps.qzv`
      * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/206_18S_eDNA_samples_clustered99_Eukaryotes_mantel-test_prt-cllps.qzv`
    * Procrustes tests are available 
      * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/206_18S_eDNA_samples_Eukaryotes_procrustes_port-collapsed.qzv`
      * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/206_18S_eDNA_samples_clustered99_Eukaryotes_procrustes_port-collapsed.qzv`
    * commit for today `f944a914bf0005ebba591c79fe7b7041d2fa04a`
* **30.07.2019** - encoding Mantel and Procrustes test extensions
  * started to work on map DI for manuscript, in QGIS, 
  * later QGIS versions also downloaded
  * map retrieved as listed at `http://planet.qgis.org/planet/tag/world%20imagery/`
    * in Python Console pasted `qgis.utils.iface.addRasterLayer("http://server.arcgisonline.com/arcgis/rest/services/ESRI_Imagery_World_2D/MapServer?f=json&pretty=true","raster")`
    * continue at `/Users/paul/Documents/CU_combined/Zenodo/Qgis/190730_sample_map.qgz`
* **31.07.2019** - pick-up afer conference call
  * downloaded SILVA 132 reference data
* **06.08.2019**
  * received all Chinese sample data and metadata, saving to `/Users/paul/Sequences/Raw/190726_CU_Aibin_lab_external_run/`
  * updating Cornell cluster, as well. Via `/Users/paul/Sequences/Raw/190726_CU_Aibin_lab_external_run/000_upload_update.sh`
  * for Argentinean collaborators collated `/Users/paul/Documents/CU_combined/Zenodo/Blast/190806_NIS-WRAPS_Megan_input_eukaryotes_all_ports.zip`
    * also see `/Users/paul/Documents/CU_argentina/Github/README.md`
* **09.08.2019**
  * aborted inclusion of Chinese data, see `/Users/paul/Documents/CU_China/Github/README.md`
  * started to work more seriously on Display Items, see `/Users/paul/Documents/CU_combined/Zenodo/Display_Items/README.md` 
* **13.08.2019** - checking overlap between references and queries 
  * importing to Geneious folder `Silva128_extended_overlap_check`
    * `/Users/paul/Documents/CU_combined/Zenodo/References/Silva128_extract_extended/99_otus_18S.fasta`
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/180_18S_eDNA_samples_tab_Eukaryotes_qiime_artefacts_non_phylogenetic/dna-sequences.fasta`
  * randomly sample `5000` sequences with seed `42` from both files
  * importing alignment file `/Users/paul/Sequences/References/SILVA_128_QIIME_release/core_alignment`
  * generating majority consensus sequence and editing this - does work with mapping - little mapping success
  * aligning both 5000-sequence-sets using MAFFT with default parameters - running
  * committed
* **15.08.2019** - checking overlap between references and queries 
  * **alignment didn't tell much, erase and align primers instead**
* **21.08.2019** - splitting and summarizing controls for results section
  * creating and modifying `/Users/paul/Documents/CU_combined/Github/091_split_controls_further.sh` - ran ok
  * modifying array fill in `/Users/paul/Documents/CU_combined/Github/095_summarize_data.sh` - ran ok
  * commit `d16eeb4f80daa89d4eeb316be66f7ed1b32cce77`
* **26.08.2019** - **implementing different rarefaction depths analysis**
  * possible scripts to **modify** are:
    * `/Users/paul/Documents/CU_combined/Github/115_isolate_taxa.sh` - **ok**
    * `/Users/paul/Documents/CU_combined/Github/130_get_core_metrics_non_phylogenetic.sh` - **ok**
    * `/Users/paul/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh` - **ok**
    * and more (R scripts, mantel and procrustes tests - after Mandanas input?) - **see below**
  * adjusting `/Users/paul/Documents/CU_combined/Github/115_isolate_taxa.sh`
    * namely `string[2]='Eukaryote-shallow'` and loop counters
    * running script, ok, created files: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/115_*_Eukaryote-shallow.qza`
    * commit `d52f11e7a706dac928122533ed6b92a09b95131a` and later `f3b8a5bea7a7bf6cd3bba65f54787832546e87ad`
  * adjusted hostnames in work scripts: `find /Users/paul/Documents/CU_combined/Github -name '*.sh' -exec gsed -i 's|"pc683.eeb.cornell.edu"|"macmini.staff.uod.otago.ac.nz"|g' {} \;`
    * commit 
  * adjusting `/Users/paul/Documents/CU_combined/Github/130_get_core_metrics_non_phylogenetic.sh`
    * checking rarefaction curve 1 `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/125_18S_eDNA_samples_tab_Eukaryotes_non_phylogenetic_curves.qzv` - **aborted**
    * checking rarefaction curve 2 `qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/160_eDNA_samples_Eukaryotes_curves_tree-matched.qzv` - ok 
    * setting shallow depth to 40000 sequences - ok
    * done via new case - run script - see folder `130_18S_eDNA_samples_Eukaryote-shallow_core_metrics_non_phylogenetic` - ok

```
      *"Eukaryote-shallow"* )
      depth=40000
      echo "${bold}Depth set to $depth for Eukaryotes (shallow set)...${normal}"
      ;;
```
  * adjusting script `/Users/paul/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh`
    * inserted new `case` statement
    * running - ok - needed re-run 03.09.2019
  * possible scripts to **modify** and  **re-run** are:
    * `/Users/paul/Documents/CU_combined/Github/140_seq_align_mask.sh` - ok - commit `def5d15bcc2262402a29f22e99b4cf1c2190f63b`
    * `/Users/paul/Documents/CU_combined/Github/145_alignment_export.sh` - ok - commit `d9ab92f75d57878b9351f8980628b6ba28489f0d`
* **29.08.2019** - continuing **implementing different rarefaction depths analysis**
  * adjusted script `/Users/paul/Documents/CU_combined/Github/150_calculate_fasttree.sh`
    * added check for readily available data - ran ok
  * adjusted script `/Users/paul/Documents/CU_combined/Github/155_filter_data_to_match_trees.sh`
    * added check for readily data - ran ok
  * adjusted script `~/Documents/CU_combined/Github/160_alpha_rarefaction_curves_phylogenetic.sh`
    * adjusted case and added check for readily available data
    * not run, no new insights gained - available available via old plot 
    * also did not run `~/Documents/CU_combined/Github/125_alpha_rarefaction_curves_non_phylogenetic.sh` - results available via old plot
    * commit with further comments in commit message `8e78a34e04125f6d3dc9e3becc86f97a9649e6ce`
  * adjusted exit conditions in `~/Documents/CU_combined/Github/120_summarize_data_non_phylogenetic.sh` - ran ok
* **30.08.2019** - continuing **implementing different rarefaction depths analysis**
  * adjusted exit conditions in `/Users/paul/Documents/CU_combined/Github/165_summarize_data_phylogenetic.sh` - ran ok
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/170_get_core_metrics_phylogenetic.sh` - ran ok
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/171_get_core_metrics_phylogenetic_collapsed.sh` - ran ok
  * for clarity erasing all files `clustered87` in Qimme folder - last backup was 30.08.2019 16:41
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/175_export_all_qiime_artifacts_phylogenetic.sh` - ran ok
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/180_export_all_qiime_artifacts_non_phylogenetic.sh` - ran ok
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/185_export_UNIFRAC_distance_artefacts.sh`
    * erased all old output files
    * not truncating filename anymore
    * re-run for all data - ok
    * abort condition test - will not re-run on available data
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/190_export_JAQUARD_distance_artefacts.sh
    * as previous script - was already done? - re-running
  * commit ` 63bf24eeea504cff259408e0f1341512f887d911`
* **03.09.2019** - continuing **implementing different rarefaction depths analysis**
  * re-running `/Users/paul/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh`
  * creating and adjusting
    * `/Users/paul/Documents/CU_combined/Github/205_compare_matrices_shallow.sh` - ran ok 
    * `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices_shallow.sh` - ran ok
  * adjusted hostname check in some other scripts
  * commit `c993b3aa2a6dea43ec67b19f2b88747f1e5929c9`
* **05.09.2019** - continuing **implementing different rarefaction depths analysis** - now adjusting modelling
  * all data synced to Cornell cluster
  * adjusted `~/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
    * added distance matrices four to eight of shallow rarefaction depth fo UNIFRAC and JAQUARDD values and unclustered and clustered data
    * can be run after checking script `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` **ok**
  * checking and correcting script `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R`
    * testing execution with expanded file `~/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
    * needs adjustment
       * use large if loop around line 232 - commit running version before these large-scale changes - **ok**
       * write logfile in `~/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh` - **ok**
* **06.09.2019** - continuing **implementing different rarefaction depths analysis** - now adjusting modelling
  * modify `~/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh` script to use more descriptive file names - **ok**
  * commit `dde144cda117d87efa95adc518d2a8e97cfab9de`
  * in `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` also consider that Pearl Harbour does not have commercial routes - **ok**
  * compare if output columns are identical - check for identical first columns - **ok** 

```
gawk -F "," 'NR==FNR{a[FNR]=$1;next}$1!=a[FNR]{print "They are dfifferent"; exit 1}' \
  /Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2019-Sep-06-15-19-43.csv \
  /Users/paul/Documents/CU_combined/Zenodo/Results/02_results_euk_otu99_deep_UNIF_model_data_2019-Sep-06-15-19-55.csv \
  /Users/paul/Documents/CU_combined/Zenodo/Results/03_results_euk_asv00_deep_JAQU_model_data_2019-Sep-06-15-20-06.csv \
  /Users/paul/Documents/CU_combined/Zenodo/Results/04_results_euk_otu99_deep_JAQU_model_data_2019-Sep-06-15-20-18.csv
 
gawk -F "," 'NR==FNR{a[FNR]=$1;next}$1!=a[FNR]{print "They are dfifferent"; exit 1}' \
 /Users/paul/Documents/CU_combined/Zenodo/Results/05_results_euk_asv00_shal__UNIF_model_data_2019-Sep-06-15-20-29.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/05_results_euk_asv00_shal__UNIF_model_data_2019-Sep-06-15-20-29.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/06_results_euk_otu99_shal__UNIF_model_data_2019-Sep-06-15-20-41.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/07_results_euk_asv00_shal__JAQU_model_data_2019-Sep-06-15-20-52.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/08_results_euk_otu99_shal__JAQU_model_data_2019-Sep-06-15-21-04.csv
```
  
  * compare if output columns are identical - check for identical second columns - **ok** 

```
gawk -F "," 'NR==FNR{a[FNR]=$2;next}$2!=a[FNR]{print "They are dfifferent"; exit 1}' \
  /Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2019-Sep-06-15-19-43.csv \
  /Users/paul/Documents/CU_combined/Zenodo/Results/02_results_euk_otu99_deep_UNIF_model_data_2019-Sep-06-15-19-55.csv \
  /Users/paul/Documents/CU_combined/Zenodo/Results/03_results_euk_asv00_deep_JAQU_model_data_2019-Sep-06-15-20-06.csv \
  /Users/paul/Documents/CU_combined/Zenodo/Results/04_results_euk_otu99_deep_JAQU_model_data_2019-Sep-06-15-20-18.csv
 
gawk -F "," 'NR==FNR{a[FNR]=$2;next}$2!=a[FNR]{print "They are dfifferent"; exit 1}' \
 /Users/paul/Documents/CU_combined/Zenodo/Results/05_results_euk_asv00_shal__UNIF_model_data_2019-Sep-06-15-20-29.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/05_results_euk_asv00_shal__UNIF_model_data_2019-Sep-06-15-20-29.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/06_results_euk_otu99_shal__UNIF_model_data_2019-Sep-06-15-20-41.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/07_results_euk_asv00_shal__JAQU_model_data_2019-Sep-06-15-20-52.csv \
 /Users/paul/Documents/CU_combined/Zenodo/Results/08_results_euk_otu99_shal__JAQU_model_data_2019-Sep-06-15-21-04.csv
```

* **16.09.2019** - building display items, waiting for tables of HON modelling 
 * email HON data request to Mandana **ok**
 * working on building display items
   * keeping scaffold `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190821_main_results_calculations_blank_checks.R`
   * working in `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190821_main_results_calculations.R`
* **17.09.2019** - building display items, waiting for tables of HON modelling 
  * working on `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_DI_map_curves.R` - aborted
  * working on `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_DI_map_straight_lines.R` - still works, but aborted
* **18.09.2019** - building display items, waiting for tables of HON modelling 
  * finished `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_DI_map_curves.R`
    * writing and written to `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/190917_1_map.pdf` and
    * writing and written to `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_supplement/190816_sample_map_simple.pdf`
    * continued to work on `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
      * exported Keller DI's - but more to do
* **26.09.2019** - building display items, waiting for tables of HON modelling
  * extending `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
    * continue into section `Calculations for Results section 3: Chord diagram of model data`
* **27.09.2019** - building display items, waiting for tables of HON modelling
  * extending `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
    * continued into section `Calculations for Results section 3: Chord diagram of model data`
* **30.09.2019** - building display items, waiting for tables of HON modelling
  * extending `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
    * stared into section `Calculations for Results section 4: Taxonomy plots`
* **04.10.2019** - building display items, waiting for more tables of HON modelling
  * extending `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
    * continued into section `Calculations for Results section 4: Taxonomy plots`
    * finished first of three parts
  * saved first HON data to `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/191001_selected_links_Ballast_env_2012.csv`
  * also saved geographical distances to `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/191004_Unique_Voyages_ALL_YEARS_UDforQAwithErin.xlsx`
  * _"I checked your first sheet and the records are correct. I have prepared
     your data with FON and HON invasion risks. Please note that I have fewer rows
     than yours since I didn't include the 0-risk pairs. Also, I used averaging
     (over HON nodes) to obtain the pairwise physical risk. We can try aggregating
     as well and see which one is a better fit! Unfortunately, I haven't gotten a
     chance to extract direct shipping risks. I couldn't find my previous files so I
     have to generate them again. I didn't want to send this to you in two pieces
     but figured maybe it's better to send you what I have for now. I'm traveling
     next week so I will send it to you the week after that. Sorry for the delay!"_
  * moved DI scripts to `/Users/paul/Documents/CU_combined/Github/` to enable version control, but kept soft links
  * all R objects now written to `/Users/paul/Documents/CU_combined/Zenodo/R_Objects`
  * in ~/Documents/CU_combined/Github/190917_main_results_calculations.R
  * continue at line 300 (`<- execute next`)
* **04.10.2019** - building display items, waiting for more tables of HON modelling
  * extending `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
  * _" I have parsed the Blast result xml I created and attach this as an R object
     for you consideration - I hope that you may find this useful to streamline your
     work and keep it consistent with the results I have here (and that are on the
     cluster and with Erin). I have read in the old(er) blast xml, kept only the
     highest (bit-)scoring matches from each query, and added NCBI taxonomy
     information as columns to this filtered Blast output. The lookup was possible
     via the NCBI taxonomy id (tax_id), which in turn I retrieved via the base
     version of the accession of the respective Blast match. There should be 3891
     unique taxa among the 17586 queries below. The src column indicates at how
     many ports the query was found. Via the sequence hash `iteration_query_def` and
     the Phyloseq object you have at hand, you could of course back-reference
     occurrences to port and bioregions, or you may find this table useful for other
     plots."_
  * count results are weird - check again - grouping command may have gone wrong somewhere
  * updated code and comments to avoid mistake in the future - slicing keeps first occurence of hash, even if it is in the data multiple times (?)
* **09.10.2019** - building display items, waiting for more tables of HON modelling
  * running again parts of file `/Users/paul/Documents/CU_combined/Github/190917_main_results_calculations.R`, after import
* **10.10.2019** - building display items, waiting for more tables of HON modelling
  * corrected naming of list elements
  * saved new output files and mailed off
  * erased older output files in `/Users/paul/Documents/CU_combined/Zenodo/R_Objects`
  * drafted plot code in Part II
  * next 
    * improve plot code in Part II
    * code plot in part III
* **11.10.2019** - building display items, waiting for more tables of HON modelling
  * corrected naming of list elements
  * saved new output files and mailed off
  * erased older output files in `/Users/paul/Documents/CU_combined/Zenodo/R_Objects`
  * drafted plot code in Part II
  * next 
    * improve plot code in Part II
    * code plot in part III
* **25.10.2019** - starting to resolve Singpore dichotomy
  * have HON modelling data from Mandana
    * `/Users/paul/Documents/CU_NIS-WRAPS/190208_hon_data/19102019_all_links_emails.pdf`
    * `/Users/paul/Documents/CU_NIS-WRAPS/190208_hon_data/19102019_all_links.csv`
  * copied and compressed all date prior to today and saved at `/Users/paul/Documents/CU_combined.zip`
  * keeping copy of `/Users/paul/Documents/CU_SP_AD_CH` at `/Users/paul/Documents/CU_SP_AD_CH.zip`
  * starting to work on re-import of `/Users/paul/Documents/CU_SP_AD_CH`
  * as further described in `/Users/paul/Documents/CU_SP_AD_CH/Github/README.md`
* **29.10.2019** - continuing to resolve Singpore dichotomy
  * erasing all files in Qiime folder
  * running `/Users/paul/Documents/CU_combined/Github/065_merge_data.sh`
  * running `/Users/paul/Documents/CU_combined/Github/070_merge_metadata.sh`
  * created checksum for new file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/05_18S_merged_metadata_preliminary.tsv`
  * swapped in Silva 132 reference data at
    * `/Users/paul/Documents/CU_combined/Zenodo/References/Silva132_extract_extended/majority_taxonomy_7_levels.txt`
    * `/Users/paul/Documents/CU_combined/Zenodo/References/Silva132_extract_extended/silva_132_99_18S.fasta`
  * update for cluster operation `/Users/paul/Documents/CU_combined/Github/075_classify_reads.sh`
  * commit - move to cluster - start taxonomy assignment
  * taxonomy assignemnt started on cluster successfully
* **30.10.2019** - continuing to resolve Singpore dichotomy
  * downloaded Silva 132 classification from Cornell cluster: `Matching query sequences: 22064 of 28394 (77.71%)`
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/075_18S_denoised_seq_taxonomy_assignment.txt`
  * revising `/Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv` md5 is `7874420a1a886b7823bc7335`
  * running `/Users/paul/Documents/CU_combined/Github/080_summarize_data.sh` - ok 
  * running `/Users/paul/Documents/CU_combined/Github/085_split_projects.sh` - ok
  * running `/Users/paul/Documents/CU_combined/Github/090_split_controls.sh` - ok
  * running `/Users/paul/Documents/CU_combined/Github/091_split_controls_further.sh` - ok
  * running `/Users/paul/Documents/CU_combined/Github/095_summarize_data.sh` - ok
  * re-implementing control data subtraction via `/Users/paul/Documents/CU_combined/Github/100_subtract_controls.sh`
    * running manually ` qiime tools view /Users/paul/Documents/CU_combined/Zenodo/Qiime/095_18S_controls_tab.qzv`
    * exporting lower frequency table: `/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_features.csv`
    * converting: `echo "feature-id	frequency" | cat - /Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_features.csv | tr "," "\\t" > /Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_features.tsv`
    * running `/Users/paul/Documents/CU_combined/Github/100_subtract_controls.sh` - ok
  * running `/Users/paul/Documents/CU_combined/Github/100_subtract_controls.sh`- ok
  * running adjusted `/Users/paul/Documents/CU_combined/Github/110_cluster_sequences.sh` - ok
    * only clustering at 99% and 97%.
    * check `/Users/paul/Documents/CU_combined/Zenodo/Qiime/110_18S_eDNA_samples_clustered97_log.txt`
    * check `/Users/paul/Documents/CU_combined/Zenodo/Qiime/110_18S_eDNA_samples_clustered99_log.txt`
  * running adjusted `/Users/paul/Documents/CU_combined/Github/115_isolate_taxa.sh`
  * running `/Users/paul/Documents/CU_combined/Github/120_summarize_data_non_phylogenetic.sh` - ok
  * running `/Users/paul/Documents/CU_combined/Github/125_alpha_rarefaction_curves_non_phylogenetic.sh` on cluster after commit
* **31.10.2019** - continuing to resolve Singpore dichotomy
  * retrieved results of  `/Users/paul/Documents/CU_combined/Github/125_alpha_rarefaction_curves_non_phylogenetic.sh` from cluster - ok .
* **01.11.2019** - continuing to resolve Singpore dichotomy
  * designing R script to create metadata files suitable for subsetting available Eukaryote data
    * name `/Users/paul/Documents/CU_combined/Github/127_select_random_samples.R`
    * function and purpose documented therein
    * rarefaction treshhold redefined using the following identical files (infecting the first of each pairs):
      * summary `/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.qzv`
      * summary (another identical "shallow" file is available with identical contents)
      * curves `/Users/paul/Documents/CU_combined/Zenodo/Qiime/125_18S_eDNA_samples_tab_Eukaryotes_non_phylogenetic_curves.qzv`
      * curves `/Users/paul/Documents/CU_combined/Zenodo/Qiime/125_18S_eDNA_samples_tab_Eukaryote-shallow_non_phylogenetic_curves.qzv`
    * rarefaction result of `49000` and `40000` 
      * **needs to be updated for Eukaryotes in subsequent scripts**
      * should keep `RID`s `c("AD","AW","BT","CB","GH","HN","HS","HT","LB","MI","NO","OK","PH","PL","PM","RC","RT","SI","WL","ZB")`
      * is on the the accumulation curve for observed OTUS:
        * for `49000` in the plateau or at least pretty stable
        * for `40000` in the plateau or at least pretty stable
  * writing R script to create metadata files suitable for subsetting available Eukaryote data - ok
  * calling R script - ok - output files added at `/Users/paul/Documents/CU_combined/Zenodo/Manifest`
  * added `prelim` suffix to grouped files
  * commit (`cc8e58a9f7eea9f3456dc5955fe1266a12e8c5e7`) - next - filter input data based on new tables - or think about next step
* **04.11.2019** - continuing to resolve Singpore dichotomy
  * working on `/Users/paul/Documents/CU_combined/Github/128_adjust_sample_counts.sh` - draft done
    * backup (next after 15:31, 4.11.2019)
    * commit (`b25bc1ba9d13fc7341747a9ce07af3d54b919de0`)
    * from `filter-samples` command removing `--p-min-frequency '49000' \`
    * and correcting file paths
    * script seems to be running ok
    * next: revise summary script
* **05.11.2019** - continuing to resolve Singpore dichotomy
  * received new HON data:
    * `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/191105_shipping_estimates.csv`
    * `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/191105_shipping_estimates_data_doc.pdf`
  * adjusted and ran summary script `/Users/paul/Documents/CU_combined/Github/129_summarize_data_non_phylogenetic.sh`
  * inspecting summary script results:
    * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/129_18S_eDNA_samples_tab_Eukaryotes.qzv`
      * `5` samples per port everywhere - ok
      * deepest possible depth is `49974` for Eukaryotes
      * Included `RID`'s are `c("AD","AW","BT","CB","GH","HN","HS","HT","LB","MI","NO","OK","PH","PL","PM","RC", "RT","SI","WL","ZB")` as above.
    * adjusted and ran `/Users/paul/Documents/CU_combined/Github/130_get_core_metrics_non_phylogenetic.sh`
    * adjusting `~/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh`
      * script seems to group? No, but creating file manually: `/Users/paul/Documents/CU_combined/Zenodo/Manifest/131_18S_5-sample-euk-metadata_deep_all_grouped.tsv`
      * disabling grouping in `/Users/paul/Documents/CU_combined/Github/127_select_random_samples.R`
      * grouping on port - thereby lumping Pearl Harbour and Honolulu, as they are not kept separately in the other mapping file, unfortunately
      * will not allow seperate analysis of Pearl Harbour and Honolulu in Procrustes and Mantel, but also not really necessary if I remember correctly
   * adjusted and ran `/Users/paul/Documents/CU_combined/Github/135_seq_align.sh` - finished ok
   * adjusting and running `/Users/paul/Documents/CU_combined/Github/140_seq_align_mask.sh` - running
   * commit for today `8f5799f021f2020ac1101ec34ea33026f377fa20`
* **06.11.2019** - continuing to resolve Singpore dichotomy
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/145_alignment_export.sh` - *ok*
  * importing masked Eukaryote alignment to Geneious (check date of imported file `/Users/paul/Documents/CU_combined/Zenodo/Qiime/145_18S_eDNA_samples_seq_Eukaryotes_alignment_masked.fasta.gz`)  - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/150_calculate_fasttree.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/155_filter_data_to_match_trees.sh` - *ok*
  * skipping adjustment of `/Users/paul/Documents/CU_combined/Github/160_alpha_rarefaction_curves_phylogenetic.sh` - results wont be largely different, run later
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/165_summarize_data_phylogenetic.sh` - *ok*
  * commit (`53ae7a784937374a59b6bef8cdfa1751971ca2ec`)
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/170_get_core_metrics_phylogenetic.sh` - *ok*
* **07.11.2019** - continuing to resolve Singpore dichotomy and finalizing analysis for five random samples per port
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/171_get_core_metrics_phylogenetic_collapsed.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/175_export_all_qiime_artifacts_phylogenetic.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/180_export_all_qiime_artifacts_non_phylogenetic.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/185_export_UNIFRAC_distance_artefacts.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/190_export_JAQUARD_distance_artefacts.sh` - *ok*
  * renamed `/Users/paul/Documents/CU_combined/Github/177_parse_otu_tables.R`
    * adjusted calls in `/Users/paul/Documents/CU_combined/Github/175_export_all_qiime_artifacts_phylogenetic.sh` - *ok*
    * adjusted calls in `/Users/paul/Documents/CU_combined/Github/180_export_all_qiime_artifacts_non_phylogenetic.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/205_compare_matrices.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/205_compare_matrices_shallow.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices_shallow.sh` - *ok*
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/206_compare_collpased_matrices.sh` - *ok*
  * preparing modelling re-run
    * adjusting wrapper script `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
    * adjusting write destination folder
      * keeping results with all samples as `/Users/paul/Documents/CU_combined/Zenodo/Results_old_all_samples`
      * creating empty `/Users/paul/Documents/CU_combined/Zenodo/Results`
    * adjusting modelling script - in R - circumventing wrapper script functionality at code start
      * should likely keep `RID`s `c("AD","AW","BT","CB","GH","HN","HS","HT","LB","MI","NO","OK","PH","PL","PM","RC","RT","SI","WL","ZB")`
      * deep table: `Collapsed matrix has 20 rows and 20 columns.`
      * deep table: `Collapsed matrix should receive data for samples: PH SI AD BT HN HT LB MI AW CB HS NO OK PL PM RC RT GH WL ZB.`
      * shallow table: `Collapsed matrix has 20 rows and 20 columns.`
      * shallow table: `Collapsed matrix should receive data for samples: PH SI AD BT HN HT LB MI AW CB HS NO OK PL PM RC RT GH WL ZB.`
      * commenting out test conditions at file read-in stage
    * and running script via: `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
      * results stored at `/Users/paul/Documents/CU_combined/Zenodo/Results`
    * running some parts of `~/Documents/CU_combined/Github/190917_main_results_calculations.R` and rewriting:
      * `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/191107_2a_deep_envdist_per_ecoregion.pdf`
      * `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/191107_2b_deep_trips_per_ecoregion.pdf`
      * `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/191107_2c_deep_unifrac_per_ecoregion.pdf`
* **07.11.2019** - rework pipeline, stratified random sample selection of five sample per port
  * rework all results from **01.11.2019** onwards
  * committing (`1f883a42fb8f20cd0e20e13157a5476e364c0586`)
  * working on `~/Documents/CU_combined/Github/127_select_random_samples.R`
* **11.11.2019** - rework pipeline, stratified random sample selection of five sample per port
  * continue work on `~/Documents/CU_combined/Github/127_select_random_samples.R` in line `50`
    * keep Singapore Yacht Club 
    * keep Adelaide Container Dock 1
    * rewrote file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_all.tsv`
    * rewrote file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_shll_all.tsv`
  * adjusted and ran: `./128_adjust_sample_counts.sh && ./129_summarize_data_non_phylogenetic.sh && ./130_get_core_metrics_non_phylogenetic.sh /Users/paul/Documents/CU_combined/Github/128_adjust_sample_counts.sh` - *ok*
  * checking summary for rarefaction data lost for five samples per port: `Retained 4,997,500 (37.93%) features in 100 (100.00%) samples at the specifed sampling depth.`
  * adjusted and ran: `/Users/paul/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh`
  * adjusted and ran: `/135_seq_align.sh && ./140_seq_align_mask.sh && ./145_alignment_export.sh && ./150_calculate_fasttree.sh`
  * running `/Users/paul/Documents/CU_combined/Github/155_filter_data_to_match_trees.sh` -  *ok* 
  * running `./165_summarize_data_phylogenetic.sh && ./170_get_core_metrics_phylogenetic.sh && ./171_get_core_metrics_phylogenetic_collapsed.sh` - *ok*
  * running `/Users/paul/Documents/CU_combined/Github/175_export_all_qiime_artifacts_phylogenetic.sh` - *ok*
  * running `/Users/paul/Documents/CU_combined/Github/180_export_all_qiime_artifacts_non_phylogenetic.sh` - *ok*
  * running `/Users/paul/Documents/CU_combined/Github/185_export_UNIFRAC_distance_artefacts.sh && /Users/paul/Documents/CU_combined/Github/190_export_JAQUARD_distance_artefacts.sh` - *ok*
  * running `./205_compare_matrices.sh && ./205_compare_matrices_shallow.sh`
  * running `./206_compare_collpased_matrices.sh && ./206_compare_collpased_matrices_shallow.sh`
  * commit
    * skipping revision for now:
    * `500_00_functions.R`
    * `500_05_UNIFRAC_behaviour.R`
    * `500_10_gather_predictor_tables.R`
    * `500_20_get_predictor_euklidian_distances.R`
    * `500_30_shape_matrices.R`
    * `500_40_get_maps.R`
  * adjusting modelling script (`/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R`) - circumventing wrapper script functionality at code start - *pending*
    * should likely keep `RID`s `c("AD","AW","BT","CB","GH","HN","HS","HT","LB","MI","NO","OK","PH","PL","PM","RC","RT","SI","WL","ZB")`
    * keeps same samples as above - no change necessary - for either deep or shallow table
    * Collapsed matrix should receive data for samples: PH SI AD BT HN HT LB MI AW CB HS NO OK PL PM RC RT GH WL ZB.
      * deep table: `Collapsed matrix has 20 rows and 20 columns.`
      * deep table: `Collapsed matrix should receive data for samples: PH SI AD BT HN HT LB MI AW CB HS NO OK PL PM RC RT GH WL ZB.`
      * shallow table: `Collapsed matrix has 20 rows and 20 columns.`
      * shallow table: `Collapsed matrix should receive data for samples: PH SI AD BT HN HT LB MI AW CB HS NO OK PL PM RC RT GH WL ZB.`
    * compressing previous results from 07.11.2019 to `/Users/paul/Documents/CU_combined/Zenodo/Results_old191107.zip`
    * emptying `/Users/paul/Documents/CU_combined/Zenodo/Results`
  * running modelling script `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R`
  * via `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
* **12.11.2019** - adjusting modeling script to accomodate HON data
  * work plan
    * save backup copy of script `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` - *ok*
      * `cp /Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R /Users/paul/Documents/CU_combined/Scratch/R`  - *ok*
    * save backup copy of results from yesterday - *ok*
      * backup of `/Users/paul/Documents/CU_combined/Zenodo/Results` saved at `/Users/paul/Documents/CU_combined/Zenodo/Results_old191111.zip`
    * split above modeling script
      * former upper part only writes modelling tables - `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R` - *ok*
        * testing script - *ok*
        * new results written to `/Users/paul/Documents/CU_combined/Zenodo/Results`
        * committed progress at 
      * new script  - *write*
        * parses tables
        * copies data but excludes `PH`
        * adds in Mandana's results - `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R`
      * former lower part does modelling and using tables - `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R` - *adjust*
  * adjusted `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh` - *ok*
  * started on `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R` - next steps:
    * close function and write files
    * request subsetting parameters and model formulas
    * start on modelling script
  * for now commit (` 09131d85e61e6cdc19d460237e3bfc25a3713594`)
* **13.11.2019** - adjusting modeling functionality to accomodate HON data
  * finished script `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R`
    * during read-in  with subsequent script from location
    * use files with suffix `_with_hon_info.csv`
  * restarted work sample sufficiency test - *pending*
    * renaming script `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R`
      * to `/Users/paul/Documents/CU_combined/Github/500_05_test_sampling_effort.R` - *ok*
    * update input file list and output file list - *ok*
    * update conflation code from `median` to `mean` if not already done - *ok*
    * apply call or function doesn't work properly: *pending*
      * needs debugging (`apply(port_combinations, 1, function (prt_elmt) get_matrix_from_port_pair(prt_elmt[1], prt_elmt[2], unifrac_matrix))`)
      * try functionality with old input file (was`Users/paul/Documents/CU_combined/Zenodo/Qiime/125_18S_metazoan_unweighted_unifrac_distance_matrix/distance-matrix.tsv`)
      * from backup `/Users/paul/Archive/Cornell/CU_cmbd_rf_test.zip`
        * copying from backup working file `cp /Users/paul/Archive/Cornell/CU_cmbd_rf_test/Zenodo/Qiime/150_18S_097_cl_edna_mat/distance-matrix.tsv /Users/paul/Documents/CU_combined/Scratch/Data`
      * old file is working as intended - *ok*
      * compare input files for oddities. - *pending*
  * next steps for modelling  - *pending*
    * receive answers to questions
    * adjust modelling script for agreed-upon variables and data sets
      * script `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
      * use file ending in `_with_hon_info.csv` from `/Users/paul/Documents/CU_combined/Zenodo/Results`
  * commit (`31695804431ed96461aa26a235e8fb0da823f57a`)
* **15.01.2020** - starting script `/Users/paul/Documents/CU_combined/Github/200115_unifrac_vs_jaccard.R` for reasons outlined therein
  * only plotting (and rendering) is needed to do  - committing.
  * plotting is now working - saved file to `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/200115_port_pairs_UNIFRAC_vs_JACCARD.pdf`
* **28.01.2020** - received data from Mandana and saved it 
  * `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/280120_all_links_1997_2018_info.pdf`
  * `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/280120_all_links_1997_2018.csv`
  * check Things and below to get new todo list
* **31.01.2020** - swapping in Mandana's new data
  * following notes 12.11.2010
  * adjusting and running `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh` - ok
  * which calls, on all tables: `~/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R` - ok
  * erasing old files in `/Users/paul/Documents/CU_combined/Zenodo/Results` - ok
  * adjusting for new data from Mandana and running `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R` - ok
    * still missing data in Mandanas files
    * erasing needed files in `/Users/paul/Documents/CU_combined/Zenodo/Results` (i.e. data without HON info)
  * **committing before adjusting next script** commit hash is `d74bcf73f8f0044445091d226bb5c7b0bf4cb061`
  * adjust and run  `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
    * **ok**: read in results tables from `/Users/paul/Documents/CU_combined/Zenodo/Results`
    * **pending**: subset model table to exclude NA - finish function - commit hash is `d74bcf73f8f0044445091d226bb5c7b0bf4cb061`
    * **pending**: adjust code for several model formulas
    * **pending**: verify model formulas
    * do better plotting, using functions
* **03.02.2020** - swapping in Mandana's new data
  * adjusting and running  `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
    * **ok**: read in results tables from `/Users/paul/Documents/CU_combined/Zenodo/Results`
    * **ok**: subset model table to exclude NA - finish function - commit hash is `d74bcf73f8f0044445091d226bb5c7b0bf4cb061`
    * **ok**: adjust code for several model formulas
    * **ok**: verify model formulas
    * **pending**: sort by AIC
    * **pending**: get useful summary render, take notes (and mail off)
    * **pending**: improve looping
    * commit `730112fb8ab984d254d80db9a399eb869a4ce0f3`
* **04.02.2020** - swapping in Mandana's new data 
  * commit before implementing the following models `79180c34dc340a08e0a87a63540015038b11dfe6`
    * `Unifrac ~ VOY_FREQ + env similarity + ecoregion + random port effects`
    * `Unifrac ~ B_FON_NOECO + env similarity + ecoregion + random port effects`
    * `Unifrac ~ B_HON_NOECO + env similarity + ecoregion + random port effects`
    * emailed off draft - commit: `5695e9a69e4c59c240812718b7b396a5fcf2876f`
* **06.02.2020** - running models as discussed at phone call today
  * see `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
* **13.02.2020** - running models as discussed at phone call today
  * see `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
  * rendered html and sent off for AAAS meeting
  * commit `f0550950a0f3070cefda6efe872aa373fd1d2fb1`
  * for comments on results check `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190220_working_notes/200214_modelling_results_nterpretation_EG.pdf`
* **13.02.2020** - new models and data received
  * models to run and data to use are documented: 
    * in `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_models_to_run.pdf`
    * in `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_data_info_mandana.pdf`
    * raw data is in `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_All_links_1997_2018_updated.csv`
      * update variable names
        * to match file `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200128_all_links_1997_2018.csv`
        * in, and to be used with, script `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R`
    * running script `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R` via
      * script `~/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh` - seems to be running ok.
    * adjusted `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R`
    * erased superflous, previous output files of `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R`
    * **started** adjusting script: `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
      * as per `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_models_to_run.pdf`
    * **pending** / **deferred** - get new data for shallow rarefaction depth
    * **pending** / **deferred** - check out old commit - re-render, and compare results
* **11.03.2020**
  * implement changes from Post-It note for phone call tomorrow.
    * test if files used are the ones that Erin has sent and declared the latest.
      * `[[ "$(tail -n +2 /Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_All_links_1997_2018_updated.csv)" == "$(tail -n +2 /Users/paul/Desktop/All_links_1997_2018_updated.csv)" ]] && echo "same" || echo "not same"`
      * files are the same - **ok**
    * use `VOYAGE` variable instead of `PRED_TRIPS` - **ok**
    * output tables as Excel files - **ok**
      * check for presence of incomplete cases - **chasing possible inconsistencies**
        * Mandana's data has 200 rows in file `/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_All_links_1997_2018_updated.csv`
        * re-running `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R`
          * via running `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh`
          * all three checked of eight datasets have 70 rows - **ok**
        * re-running `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R` 
          * only considering relevant files (`"^.._results_euk_asv00_.*_UNIF_model_data_2020-Mar-11-12.*\\.csv$"`)
          * created files:
            * `/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2020-Mar-11-12-49-54_with_hon_info.csv`
            * `/Users/paul/Documents/CU_combined/Zenodo/Results/05_results_euk_asv00_shal_UNIF_model_data_2020-Mar-11-12-50-38_with_hon_info.csv`
            * `/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2020-Mar-11-12-49-54_no_ph_with_hon_info.csv`
            * `/Users/paul/Documents/CU_combined/Zenodo/Results/05_results_euk_asv00_shal_UNIF_model_data_2020-Mar-11-12-50-38_no_ph_with_hon_info.csv`
            * with 70 rows (including PH) and 65 rows (excluding PH), respectively  - **ok**
        * adjusting data selection to current files and re-running `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
          * spot checking input data  `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_result_DIDX_1_FIDX_1__unmodified_input_data.xlsx`
            * 70 rows - **ok**
            * missing from Mandanas data in file (examples only: `AD-BT`, `AD-HT`, `AD-WL`) - **check Mandanas original data file**
            * checking Mandana's data file: `AD-BT`, `AD-HT`, `AD-WL` missing in Mandanas file, and others **need new data or ignore**
  * mail off results to Cornell - **ok** 
    * HTML file created today - **ok** 
    * collection of results tables (zipped) -  **ok** 
      * connections among 18 ports with Mandanas data and Unifrac values (and M's voyage data): - ~49 connections
      * connections among 19 ports with Mandanas data and Unifrac values (and P's voyage data): - ~70 connections
    * chase rarefaction depth **ok**
     * from `/Users/paul/Documents/CU_combined/Github/170_get_core_metrics_phylogenetic.sh`
       * deep: `49974` sequences per sample in each of five samples per port
       * shallow: `32982` sequences per sample in each of five samples per port
     * included ports (from mapping file `/Users/paul/Documents/CU_combined/Zenodo/Manifest/131_18S_5-sample-euk-metadata_deep_all_grouped.tsv`):
       * Adelaide	Antwerp	Buenos-Aires	Baltimore	Coos-Bay	Chicago	Cornell	Ghent	Honolulu	Haines	Houston	Long_Beach	Miami	Milne_Inlet	New-Orleans	Nanaimo	Oakland	Portland	Puerto-Madryn	Richmond	Rotterdam	Singapore	Vancouver	Wilmington	Zeebrugge
       * AD	      AW	    BA	          BT	      CB	      CH	    CU	    GH	   HN     	HS	    HT	    LB	        MI	  ML	        NO	        NX	    OK	    PL	      PM	          RC	      RT	       SI     	VN	      WL        	ZB
  * commit  ` dc5a3e522d44e9958b316c9c9632a94d6a6a4852`
* **13.03.2020** - starting to work on new branch (`full_unifrac`)
  * creating branch
    * `git checkout -b full_unifrac`
    * for more info check `https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging`
    * `Switched to a new branch 'full_unifrac'`
  * todo
    * don't filter UNIFRCA with Jim Corbetts data - add fon 0s - **ok**
    * HON add up in Erins data if scaled to 1  - **ok**
    * Erin get HON variables from Mandana  - **ok** (script does the summing now)
    * Mandana's data - set all FON to 0 - what with HON variable?  - **ok**
    * re-run Model A B D - all Fon is 0  - **pending**
    * zero columns possibly all variables included in FON  - **pending**
  * adjusting script `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R` - **ok**
    * re-running via script `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh` **ok**
    * new tables created in `/Users/paul/Documents/CU_combined/Zenodo/Results`
    * commit `b42cc52956b71418050383a3f147ffbd47d29cec`
  * adjusting script `~/Documents/CU_combined/Github/500_81_extend_model_tables.R` - **ok**
    * to and fro information needs to be unified to make bidirectional information unidirectional - choosing plain summing for simplicity - **ok**
    * **Attention! Attention! Setting NAs is implemented hastily and needs to be checked if input files change.**
  * adjusting script `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
    * temporarily commenting out models `C` and `E`.
  * todo
    * test results wit NA setting - **ok**
      * `/Users/paul/Documents/CU_combined/Github/500_83_mixed_effect_model_results_NAs_set_to_0.html`
      * `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_result_NAs_set_to_0.zip`
    * test results without NA setting - **ok**
      * `/Users/paul/Documents/CU_combined/Github/500_83_mixed_effect_model_results_NAs_excluded.html`
      * `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_result_NAs_excluded.zip`
    * in `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R` - **pending**
      * rewrite left joining function based on alphabetical sorting in  - pending  - **pending**
      * instead of summing values, use mean() to stay in scale from 0 to 1  - **pending**
      * scale env dit value from 0 to 1  - **pending**
    * test results again with NA setting - **pending**
    * test results again without NA setting - **pending**
* **25.03.2020** - continuing work on new branch (`full_unifrac`)
  * implementing new modelling technique and new data
  * using new data, verified by Erin
    * file (work on copy): `/Users/paul/Documents/CU_NIS-WRAPS/170720_code_collaborators/200325_EG_code.R` 
    * check and incorporate - **pending**
  * using new modeling technique as in guide received by Jose
    * file: `/Users/paul/Documents/CU_NIS-WRAPS/200325_ja_glm_approach/ZeroInflated_GLM_guide_PaulC_24March20.pdf`
    *  check and incorporate - **pending**
    * postponed
* **27.03.2020** - continuing work on new branch (`full_unifrac`)
  * continuing with last work days items
  * from where is file `Paul_2020_03_12.csv` in Erins R script?
  * saved back from email `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_results.zip`
    * comparing hashes of sent files:
      * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_result_NAs_excluded.zip) = 06a9dbcecbf8a5624d2bd095f67a5703`
      * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_result_NAs_set_to_0.zip) = 94a5d6b6d40c53e7fa32ff05ced9ff00`
      * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_results.zip) = 405b0b182b071f0b449a44d0be5caa80`
      * all different, last, pertinent file is from 11.03.2019 as re-downloaded from my own mail
        * `MD5 (/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_results.zip) = 405b0b182b071f0b449a44d0be5caa80`
   * unpacking and checking that file:
     * file name patterns are:
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_results/20201103_Rscrpt-500-83_mme_result_DIDX_1_FIDX_1__subset_input_table.xlsx`
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_results/20201103_Rscrpt-500-83_mme_result_DIDX_1_FIDX_1__unmodified_input_data.xlsx`
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_results/20201103_Rscrpt-500-83_mme_result_DIDX_1_FIDX_2__subset_input_table.xlsx`
       * `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_results/20201103_Rscrpt-500-83_mme_result_DIDX_1_FIDX_2__unmodified_input_data.xlsx`
    * as per email - trace history of file `20201103_Rscrpt-500-83_mme_result_DIDX_2_FIDX_3__unmodified_input_data`
      * written by `/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R`
      * file is copy of one of the input `.csv` files in `/Users/paul/Documents/CU_combined/Zenodo/Results`
    * committing before doing the following
      * commit `d661557ff882cf63bd7cc6954de7717412d9144`
    * checking Erins script with file: `/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2020-Mar-13-13-16-52_no_ph_with_hon_info.csv`.
      * checking `/Users/paul/Documents/CU_combined/Github/500_83_mixed_effect_model_results_NAs_set_to_0.html`
      * script results should
        * have dimensions 210 x 20, 
        * be the same as: `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_result_DIDX_1_FIDX_1__unmodified_input_data.xlsx`
      * and the result of Erins script 
        * should be similar to: `/Users/paul/Documents/CU_combined/Zenodo/Results/20201103_Rscrpt-500-83_mme_result_DIDX_1_FIDX_1__subset_input_table.xlsx"`
        * with dimensions 210 X 6
      * **script results so far can't be replicated - options:** 
        * use alternative adding approach
        * check again script `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables_eg_partial.R`
* **31.03.2020** - continuing work on new branch (`full_unifrac`)
  * adjust `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R` 
     * encode alternative adding approach - **ok**
     * scale variables - **ok**
     * check with Erins results at `/Users/paul/Documents/CU_NIS-WRAPS/170720_code_collaborators/200331_Erins_sums` - **ok**
  * for sanity reasons - rerunning:
    * `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh`
    * `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R`
      * files are dated `2020-Mar-31-11-18`
    * re-creating `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables_new.R`
      * adding of Mandana's data now newly implemented -  **ok**
      * in a copy of all data all `NA`'s are set to `0` -  **ok**
      * in a copy of all data pertinent variables are scaled and centered - **ok**
    * archived results: `/Users/paul/Documents/CU_combined/Zenodo/Results/200319_500_81_extend_model_tables__temp__input_output.zip`
    * emailed off results 
    * committed: `fe3324f23cf126206b0d3bb17d9bc85673948fa8`
    * **next steps** 
      * implement new modelling as per Jose - **pending**
      * graph variables - **pending**
      * check residuals of model as per Erin - **pending**
* **01.04.2020** - continuing work on new branch (`full_unifrac`)
  * created `/Users/paul/Documents/CU_combined/Github/500_83_test_zero-inflated_glms.R`
  * for appropriate file naming - rerunning:
    * `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh`
    * `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R`
    * adjusting and running `/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R`
      * further processed only:
        * `05_results_euk_asv00_shal_UNIF_model_data_2020-Apr-01-11-14-16.csv`
        * `01_results_euk_asv00_deep_UNIF_model_data_2020-Apr-01-11-13-59.csv`
    * working through `/Users/paul/Documents/CU_NIS-WRAPS/200325_ja_glm_approach/ZeroInflated_GLM_guide_PaulC_24March20.pdf`
      * none of this makes sense to me - seems to be tailored to count data ?
      * working with files `/Users/paul/Documents/CU_combined/Zenodo/Results/200401_500_81_extend_model_tables__temp__input_output.zip`
      * emailing off files and script `/Users/paul/Documents/CU_combined/Github/500_83_test_zero-inflated_glms.R`
      * commit ``
  




## Todo

### More important 
  * before re-run safe repository for spin-off - ecoregion paper
  * re-run for factors:
     * include Mandanas results for all voyage esrs
     * include 
       * several modelling approaches
       * many ports - high coverage
       * clustered - unclustered
       * follow word document with outline
  * debug `rf_test` script with input data file in scratch folder - that file must be somehow differently formated then later version of distance matrices
  * re run modelling and associated scripts to *resolve Singapore dichotomy* and to *recalculate UNIFRAC distances with single locations*
    * deferred running `/Users/paul/Documents/CU_combined/Github/160_alpha_rarefaction_curves_phylogenetic.sh` - *pending*
    * check summaries created by `/Users/paul/Documents/CU_combined/Github/165_summarize_data_phylogenetic.sh`  - *pending*
    * importing tree and alignment files into Geneious (check for import date in Geneious)   - *pending*
    * check modeling and re-run script
    * re-run modelling with and without Pearl Harbour
  * build display items in `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190821_main_results_calculations.R`
    * Voyages summary per year - **add bioregions**
    * taxon plots - **continue parser, update phyloseq object, plot** (correct grouping of Blast variables)
  * email Costello for a GIS layer
  * `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R`
    * possibly re-run modeling scripts and output full route tables for `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
    * split modeling functions from `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R`
    * possible re-write more concise R pipeline
  * revise `/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_main_results_calculations.R`
  * formalize implementation of `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R`
    * while doing so take care that matrix conflation is done using averages.
  * adjust display items (Procrustes and Mantel results)
  * adjust text (shallow depth sampel inclusion from table summary)
  * check all script marked yellow for required corrections

#### Less important 
  * accomodate randomized matrices
  * run and render `/Users/paul/Documents/CU_combined/Github/500_40_get_maps.R` - manual port lookup necessary
  * extend `/Users/paul/Documents/CU_combined/Github/205_compare_matrices.sh` - include more diversity metrics
  * get numbers and display items
  * check eigenvalues on core-metrics log files `130` and `170` 
  * **keep in mind** that in `#SampleID` mapping file  **must** start with two letter abbrivation, needed for R code!
  * adjust `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh` to use more metrcis such as 
    * observed OTUs, if desirable
  * Which Richmond is meant? Mapped is Richmond, California **as it should**, and not anymore Virginia. Other inconsistencies in data?

#### Done
  * ~~Correlate identified invasives with high shipping traffic, for this isolate and inspect highly connected ports only.~~
  * ~~Include latest reference data~~
  * ~~Accomodate Chinase data~~

## Known issues and bugs

### High priority
* _09.04.2019_ - **confirmed** some matrix column names and row names that are expected to have port numbers as Id'd do have "NA"'s only
  * as seen in `/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full.Rdata`
  * called via `/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R`
  * generated by `/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R` 
* _10.05.2018_ - **confirmed** - `/Users/paul/Documents/CU_combined/Github/500_35_shape_overlap_matrices.R`
  * plotting code does not label nor draw all connections - rewrite (?)
* _25.04.2018_ - **unconfirmed** - non-unique rownames _may be_ assigned to all (?) output (?) matrices in `500_30_shape_matrices`  due to duplicate values in the input tables (script 10)? - possibly affected:
  * `500_30_shape_matrices`
  * `500_70_matrix_comparison_uni_prd.R` and precursors
  * possible unconfirmed reason: some table has only first instances of port names filled, all others port names set NA by previous scripts

### Low priority
* _02.05.2018_ - **unconfirmed** - list output is sparse in `/Users/paul/Documents/CU_combined/Github/550_check_taxonomy.R`
  * possible unconfirmed reason: blast OTU list shorter the OTU list in Phyloseq object - perhaps blast is dropping queries?
