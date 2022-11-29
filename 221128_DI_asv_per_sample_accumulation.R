# ASV accumulation per port
#
# Paul Czechowski, 28-Nov-2022, paul.czechowski@gmail.com

# Clean environment ----

rm(list = ls())

# Load packages ----

library("tidyr")     # data formatting
library("dplyr")     # data formatting
library("readr")     # data read-in
library("magrittr")  # more pipes
library("vegan")     # accumulation curves
library("gglot2")    # for ggplot()
library("reshape2")  # for melting data frames
library("ggpubr")    # plot arrangements

# Functions ----

get_vegan_format = function (asv_tibl) {
  require("tidyr")
  require("magrittr")
  
  asv_tibl %<>% pivot_wider(names_from = asv_hash, values_from = asv_count)
  asv_tibl %<>% select(-port)
  
  # oddly needed by vegan - sample id's appear to be needed as numeric
  asv_tibl %<>% group_by(sample) %>% mutate(sample = cur_group_id())
  
  return(asv_tibl)
  
}

get_vegan_sac = function (asv_tibl_wide) {
  require("magrittr")
  require("vegan")
  
  sac <- specaccum(
    asv_tibl_wide,
    method = "exact",
    permutations = 500,
    conditioned = TRUE,
    gamma = "species",
    w = NULL,
    ci.type = "polygon"
  )
  return(sac)
  
}

# Load data ----
# 
# Rarefied Data 
# * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryotes_features_tree-matched_qiime_artefacts/features-tax-meta.tsv`
# The following folder pairs should hold identical information: 
# * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_controls_tab_Eukaryote-shallow_qiime_artefacts_custom`
# * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_controls_tab_Eukaryotes_qiime_artefacts_custom`
# and: 
# * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_eDNA_samples_tab_Eukaryote-shallow_qiime_artefacts_custom`
# * `/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_eDNA_samples_tab_Eukaryotes_qiime_artefacts_custom`

asv_table_path <-
  c(
    "/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryotes_features_tree-matched_qiime_artefacts/features-tax-meta.tsv",
    
    "/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_controls_tab_Eukaryote-shallow_qiime_artefacts_custom/features-tax-meta.tsv",
    "/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_controls_tab_Eukaryotes_qiime_artefacts_custom/features-tax-meta.tsv",
    
    "/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_eDNA_samples_tab_Eukaryote-shallow_qiime_artefacts_custom/features-tax-meta.tsv",
    "/Users/paul/Documents/CU_combined/Zenodo/Qiime/181_18S_eDNA_samples_tab_Eukaryotes_qiime_artefacts_custom/features-tax-meta.tsv"
  )

asv_table <-
  read_delim(
    asv_table_path[4],
    skip = 1,
    col_names = TRUE,
    trim_ws = TRUE,
    name_repair = "universal"
  )

# Format data ----

# tibble works better with dplyr
asv_tibble <- as_tibble(asv_table)
colnames(asv_table)

# some port ought to be removed
# asv_tibble %<>% select(!contains(c("BA", "PH", "CH")))
colnames(asv_tibble)

# for vegan, data needs to be split first, so long format is required
asv_tibble_long <-
  pivot_longer(asv_tibble,
               !OTU.ID,
               names_to = "sample",
               values_to = "asv_count")

# better name for asv identifier column
asv_tibble_long %<>% rename(asv_hash = OTU.ID)

# enable splitting data by port
asv_tibble_long %<>% mutate(port = as.factor(substr(
  sample, start = 1, stop = 2
)))

# reorder to keep sanity
asv_tibble_long %<>% relocate(asv_hash, port, sample, asv_count)

# check ports in data
# - "SI" "AD" "BT" "HN" "HT" "LB" "MI" "AW" "CB" "HS" "NO" "OK" "PL" "PM"
#   "RC" "RT" "GH" "WL" "ZB"
asv_tibble_long[["port"]] %>% unique

# get a list of Tibbles for portwise plotting
asv_tibble_long_split <-
  split(asv_tibble_long, f = asv_tibble_long[["port"]])

# Pivot wider and transpose for vegan
asv_tibble_wide_split <-
  lapply (asv_tibble_long_split, get_vegan_format)

# Generate Species Accumulation Curves ----

sac_list <- lapply (asv_tibble_wide_split, get_vegan_sac)

# Plot Species Accumulation Curves ----

length(sac_list)

par(mfrow = c (7, 4), mar = c(2.0, 2.0, 2.0, 2.0))

for (i in seq(length(sac_list))) {
  plot(
    sac_list[[i]],
    main =  names(sac_list[i]),
    ylab = "ASVs",
    xlab = "Samples"
  )
}

dev.print(
  pdf,
  "/Users/paul/Documents/CU_NIS-WRAPS_manuscript/221111_Mol_Ecol_revision/2_new_display_items/201124_DI_asv_per_sample_per_port_unfiltered.pdf"
)
