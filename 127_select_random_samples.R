rm(list=ls()) # for safety only

library("tidyverse")

# 2019-11-05 - Attention: data is being grouped by script
#   `/Users/paul/Documents/CU_combined/Github/131_get_core_metrics_non_phylogenetic_collpased.sh`
#   any grouping in this file is unnecessary, and the writing of the final objects has been disabled. 

# data read-in 
#   read in metadata file - `/Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv`
#   read in frequency per sample file
#     manual export of table summary from `/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.qzv`
#     named `/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.csv`

fmdata <- read_tsv("/Users/paul/Documents/CU_combined/Zenodo/Manifest/06_18S_merged_metadata.tsv")
fcount <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.csv", col_names = c("SampleID", "Count"))

# data manipulations - use "RID" column
#   add read counts to table

fmerge <- left_join(fmdata, fcount, by = "SampleID")

# check counts 
fcount %>% print.data.frame
fmerge %>% print.data.frame

#   isolate eDNA samples from other samples
#   remove all samples below
#     49000 features per sample for normal depth - confirm visually using `/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.qzv`
#     (ignore here - needed later: 40000 features per sample for shallow depth - confirm visually using `/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.qzv`)

# isolate eDNA samples - will be 1 items in sample-type grouped lists
fmlist <- fmerge %>% group_by(Type, add = TRUE) %>% group_split() 
fmeDNA <- fmlist[[4]] 

#   remove all "RID"s with with less then 5 samples
#   store in an (ordered) vector: from each "Location" get covered samples as per README.md, and discard all locations that don't have five samples 
keep_hi <- fmeDNA %>% group_by(Location, add = TRUE) %>% filter(Count  >= 49900 ) %>% tally(.) %>% filter(n >= 5) %>% select(Location)
keep_lo <- fmeDNA %>% group_by(Location, add = TRUE) %>% filter(Count  >= 37900 ) %>% tally(.) %>% filter(n >= 5) %>% select(Location)

#   recreate table order as in above vector, and the use vector to subest input table, finally choose random five samples per location
covrd_hi <- fmeDNA %>% group_by(Location, add = TRUE) %>% filter(Count  >= 49700 ) %>% filter(Location %in% keep_hi$Location) %>% sample_n(5)
covrd_lo <- fmeDNA %>% group_by(Location, add = TRUE) %>% filter(Count  >= 37900 ) %>% filter(Location %in% keep_lo$Location) %>% sample_n(5)

#   restore grouping
covrd_hi <- covrd_hi %>% group_by(RID, Location)
covrd_lo <- covrd_lo %>% group_by(RID, Location)

#   inspect table before subsetting
covrd_hi %>% print.data.frame()
covrd_lo %>% print.data.frame()

# keep Singapore Yacht Club and Adelaide Container Dock 1 but no other samples
# from Singapore or Adelaide

excl_locs <- c("Adelaide_Container_Channel", "Adelaide_Container_Dock_II",
               "Adelaide_Fuel_Dock", "Adelaide_Marina_Dock", "Singapore_Woodlands") 
slctDNA_hi <- covrd_hi %>% filter(!Location %in% excl_locs)
slctDNA_lo <- covrd_lo %>% filter(!Location %in% excl_locs)

#   inspect table after subsetting
slctDNA_hi %>% print.data.frame()
slctDNA_lo %>% print.data.frame()


## subset table - re-build table
# port-collapse - not done anymore
# grpdDNA <- slctDNA %>% sample_n(1)

# recreate full tables
fmlist_hi <- fmlist
fmlist_lo <- fmlist

fmlist_hi[[4]] <- slctDNA_hi
fmlist_lo[[4]] <- slctDNA_lo

fmerge_hi <- bind_rows(fmlist_hi)
fmerge_lo <- bind_rows(fmlist_lo)

# sorting for convenience
fmerge_hi <- fmerge_hi %>% group_by(Type, RID) %>%  arrange(., RID, Type)
fmerge_lo <- fmerge_lo %>% group_by(Type, RID) %>%  arrange(., RID, Type)

# recombine eDNA samples from other samples
# write two new metadata files for further processing
#   to `/Users/paul/Documents/CU_combined/Zenodo/Manifest`

# all samples - deep depth 
write_tsv(fmerge_hi, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_all.tsv")
# collapsed samples - normal depth 
# write_tsv(fmerge_grp, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_grp.tsv")

# all samples - shallow depth 
write_tsv(fmerge_lo, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_shll_all.tsv")

# collapsed samples - shallow depth 
# write_tsv(fmerge_grp, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_shll_grp.tsv")
