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

#   isolate eDNA samples from other samples
#   remove all samples below
#     49000 features per sample for normal depth - confirm visually using `/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.qzv`
#     (ignore here - needed later: 40000 features per sample for shallow depth - confirm visually using `/Users/paul/Documents/CU_combined/Zenodo/Qiime/120_18S_eDNA_samples_tab_Eukaryotes.qzv`)

fmlist <- fmerge %>% group_by(Type, add = TRUE) %>% group_split() 
fmeDNA <- fmlist[[4]] 

#   remove all "RID"s with with less then 5 samples
#   store in an (ordered) vector: from each "Location" get well covered samples, and discard all locations that don't have five samples 
keep <- fmeDNA %>% group_by(Location, add = TRUE) %>% filter(Count  >= 49700 ) %>% tally(.) %>% filter(n >= 5) %>% select(Location)

#   recreate table order as in above vector, and the use vector to subest input table, finally choose random five samples per location
hi_covrd <- fmeDNA %>% group_by(Location, add = TRUE) %>% filter(Count  >= 49700 ) %>% filter(Location %in% keep$Location) %>% sample_n(5)

#   restore grouping
hi_covrd <- hi_covrd %>% group_by(RID, Location)

#   inspect table before subsetting
hi_covrd %>% rmarkdown::paged_table()

# keep Singapore Yacht Club 
# keep Adelaide Container Dock 1 

excl_locs <- c("Adelaide_Container_Channel", "Adelaide_Container_Dock_II",
               "Adelaide_Fuel_Dock", "Adelaide_Marina_Dock", "Singapore_Woodlands") 
slctDNA <- hi_covrd %>% filter(!Location %in% excl_locs)

#   inspect table after subsetting
slctDNA %>% rmarkdown::paged_table()



## subset table - re-build table
# port-collapse
grpdDNA <- slctDNA %>% sample_n(1)

# recreate full tables
fmlist_fll <- fmlist
fmlist_grp <- fmlist

fmlist_fll[[4]] <- slctDNA
fmlist_grp[[4]] <- grpdDNA

fmerge_fll <- bind_rows(fmlist_fll)
fmerge_grp <- bind_rows(fmlist_grp)

# sorting for convenience
fmerge_fll <- fmerge_fll %>% group_by(Type, RID) %>%  arrange(., RID, Type)
fmerge_grp <- fmerge_grp %>% group_by(Type, RID) %>%  arrange(., RID, Type)

# recombine eDNA samples from other samples
# write two new metadata files for further processing
#   to `/Users/paul/Documents/CU_combined/Zenodo/Manifest`

# all samples - normal depth 
write_tsv(fmerge_fll, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_all.tsv")
# collapsed samples - normal depth 
# write_tsv(fmerge_grp, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_deep_grp.tsv")

# all samples - shallow depth 
write_tsv(fmerge_fll, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_shll_all.tsv")

# collapsed samples - shallow depth 
# write_tsv(fmerge_grp, "/Users/paul/Documents/CU_combined/Zenodo/Manifest/127_18S_5-sample-euk-metadata_shll_grp.tsv")
