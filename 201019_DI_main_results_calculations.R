# Get graphical representation of detected taxa
# =============================================
#
# check Git history and README.md

# Prepare Environment
# ===================
rm(list=ls(all=TRUE)) # clear memory


# Packages
# --------
library("tidyverse")  # work using tibbles
library("Biostrings") # read fasta file
library("phyloseq")   # filtering and utilities for such objects
library("data.table")


# Functions
# --------
`%notin%` <- Negate(`%in%`)
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")


# Loading data
# ============

# loading Kara's data:
# ~~~~~~~~~~~~~~~~~~~
# checking what Kara did as documented in `/Users/paul/Documents/CU_combined/Zenodo/NIS_lookups/201019_nis_lookups_kara/reBLAST_WRiMS_10.17.2020.R`
# loading relavant file
blast_results_final_with_nis <- readr::read_csv("/Users/paul/Documents/CU_combined/Zenodo/NIS_lookups/201019_nis_lookups_kara/blast_results_final.csv", col_names = TRUE) %>% select(-X1)

# inspecting relevant columns and how many are there of each combination
blast_results_final_with_nis %>% group_by(wrims, wrims_98_unambiguous) %>% count(group_n = n_distinct(wrims, wrims_98_unambiguous))

names(blast_results_final_with_nis)

# loading Phyloseq results:
# ~~~~~~~~~~~~~~~~~~~~~~~~~

# set paths:
sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryotes_features_tree-matched_qiime_artefacts/dna-sequences.fasta" 
biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryotes_features_tree-matched_qiime_artefacts/features-tax-meta.biom"

# create Phyloseq object:
biom_table <- phyloseq::import_biom (biom_path)
sequ_table <- Biostrings::readDNAStringSet(sequ_path)  
  
# construct Object:
phsq_ob <- merge_phyloseq(biom_table, sequ_table)

# correct column names
head(sample_data(phsq_ob))
names(sample_data(phsq_ob)) <- c("BarcodeSequence", "SampleSums", "RID", "Run", "LinkerPrimerSequence", "Location", "Facility", "Port", "CollYear", "Long", "Lati", "Type")
head(sample_data(phsq_ob))

# checking read counts per sample
#   as per `~/Documents/CU_combined/Github/127_select_random_samples.R`
#   samples kept with more then 49900 sequences - all AVS should be in there
#   rarefaction only done for UNIFRAC analysis at depth 49899 as per 
#   `/Users/paul/Documents/CU_combined/Github/170_get_core_metrics_phylogenetic.sh`
#   sample_data has been amended with sample sum counts for preselection in column "SampleSums"
sample_sums(phsq_ob)
summary(sample_sums(phsq_ob))


# merging Kara's data, (incl. Pauls Blast results) and Phylsoeq object
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# melting Phyloseq object to data table for merging and speed
phsq_ob_unfiltered_molten <- psmelt(phsq_ob) %>% data.table()
names(phsq_ob_unfiltered_molten$OTU)

# set sorting key properly
setnames(phsq_ob_unfiltered_molten, "OTU", "ASV")
setkey(phsq_ob_unfiltered_molten,ASV) 

# remove old taxonomy strings
phsq_ob_unfiltered_molten[  , c( grep("Rank", names(phsq_ob_unfiltered_molten))) := NULL]

# merge Kara's data
phsq_ob_unfiltered_molten_merged <- merge(phsq_ob_unfiltered_molten, blast_results_final_with_nis, 
              by.x = "ASV", by.y = "iteration_query_def", 
              all.x = TRUE, all.y = FALSE)

# checking data
head(phsq_ob_unfiltered_molten_merged,3)
colnames(phsq_ob_unfiltered_molten_merged) 

# formatting data for plotting
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# continue here afre 19-Oct-2020
# f1 <- function() DT[x %in% letters[1:2]]
