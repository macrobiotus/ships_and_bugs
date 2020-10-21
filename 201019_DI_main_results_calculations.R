#' ---
#' title: "Get graphical representation of detected taxa"
#' author: "Paul Czechowski"
#' date: "21-Oct-2020"
#' output: pdf_document
#' ---
#' 
#' 
#' Use `rmarkdown::render("/Users/paul/Documents/CU_combined/Github/201019_DI_main_results_calculations.R")` to render.

#' # Prepare Environment
#' 
#' Empty memory
rm(list=ls(all=TRUE)) # clear memory


# Packages
# --------
library("tidyverse")  # work using tibbles
library("Biostrings") # read fasta file
library("phyloseq")   # filtering and utilities for such objects

library("data.table")   # faster handling of large tables
library("future.apply") # faster handling of large tables

library("scales")   # better axis labels

library("vegan")    # distance calculation from community data
library("ppcor")    # partial correlations

# Functions
# --------
`%notin%` <- Negate(`%in%`)

# integer breaks on plots
#   https://stackoverflow.com/questions/15622001/how-to-display-only-integer-values-on-an-axis-using-ggplot2 
int_breaks <- function(x, n = 5) {
  l <- pretty(x, n)
  l[abs(l %% 1) < .Machine$double.eps ^ 0.5] 
}


source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")


# Loading data
# ============

# loading Kara's data:
# ~~~~~~~~~~~~~~~~~~~
# checking what Kara did as documented in `/Users/paul/Documents/CU_combined/Zenodo/NIS_lookups/201019_nis_lookups_kara/reBLAST_WRiMS_10.17.2020.R`
# loading relevant file
blast_results_final_with_nis <- readr::read_csv("/Users/paul/Documents/CU_combined/Zenodo/NIS_lookups/201019_nis_lookups_kara/blast_results_final.csv", col_names = TRUE) 

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

# understand data structures by counting unique elements among varibels and their products
future_apply(phsq_ob_unfiltered_molten_merged, 2, function(x) length(unique(x)))


# Data plotting and analysis - all ASV analysis and plotting
# ==========================================================

# Formatting and numerical summaries 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# - not done yet - 



# Data plotting and analysis -  NIS ASV analysis and plotting
# ==========================================================

# Formatting and numerical summaries 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# keep NIS' - no-PH samples - eDNA samples
nis_asv_lng <- phsq_ob_unfiltered_molten_merged[wrims_98_unambiguous == TRUE & RID != "PH" & Type == "eDNA"]

# remove Blast information (starting with "hsp_..." ) for clarity (at least temporarily)
nis_asv_lng[, grep("^hsp_", colnames(nis_asv_lng)):=NULL]

# understand data structures by counting unique elements among varibels and their products
future_apply(nis_asv_lng, 2, function(x) length(unique(x)))
nrow(nis_asv_lng)

# aggregate on Port (=RID) level
#   https://stackoverflow.com/questions/16513827/summarizing-multiple-columns-with-data-table
nis_asv_lng <- nis_asv_lng[, lapply(.SD, sum, na.rm=TRUE), by=c("RID", "ASV", "src", "tax_id", "superkingdom",  "phylum",  "class",  "order",  "family",  "genus",  "species"), .SDcols=c("Abundance") ]

#  resort for clarity
keycol <-c("ASV","RID")
setorderv(nis_asv_lng, keycol)

# add presence-absence abundance column
nis_asv_lng <- nis_asv_lng[ , AsvPresent :=  fifelse(Abundance == 0 , 0, 1, na=NA)]

# understand data structures
future_apply(nis_asv_lng, 2, function(x) length(unique(x)))
head(nis_asv_lng, 100)
nrow(nis_asv_lng)


# Plots
# ~~~~~

# plot plain ASV per phylum and port - not facetted
ggplot(nis_asv_lng, aes_string(x = "RID", y = "AsvPresent", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  scale_fill_manual(values= c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")) +
  scale_y_continuous(breaks = int_breaks) +
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "present putatively invasive ASVs") + 
  xlab("ports") + 
  ylab("present ASVs at each port")

ggsave("201020_observed_ASVs_across_ports_facetted.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# plot plain ASV per phylum and port - facetted
ggplot(nis_asv_lng, aes_string(x = "RID", y = "AsvPresent", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  scale_fill_manual(values= c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")) +
  scale_y_continuous(breaks = int_breaks) +
  facet_grid(src ~ ., shrink = TRUE, scales = "free_y") + 
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "present putatively invasive ASVs") + 
  xlab("ports") + 
  ylab("present ASVs at each port")

ggsave("201020_observed_ASVs_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)
  

# Further analysis
# ~~~~~~~~~~~~~~~~

# - Prepare Jaccard matrix for merging - 

# get Jaccard distance matrix for invasive taxa Jaccard distances between ports based on ASV presence
cd <- as.matrix(data.table::dcast(setDT(nis_asv_lng), RID~ASV, value.var="AsvPresent", fill=0), rownames=TRUE)
cd_dm <- vegdist(cd, method="jaccard", binary=FALSE, diag=TRUE, upper=TRUE, na.rm = FALSE)

# melt for merging
cd_pj <- reshape2::melt(as.matrix(cd_dm), varnames = c("PORT", "DEST"), value.name = "JACC_NIS")

# sort by RID for key creation  - create key for merging - move key to front for visibility
cd_pj <- cd_pj %>% arrange(PORT, DEST) %>% mutate(JoinKey = paste0(PORT, "_", DEST)) %>% relocate(JoinKey)


# - Prepare old model data for merging - 

# read old model data (check - must be the same as Jose)
mdl_tb <- readr::read_csv("/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2020-Apr-27-16-48-06_joined_no-nas_scaled.csv", col_names = TRUE)

#  sort by RID for key creation  - create key for merging - move key to front for visibility
mdl_tb <- mdl_tb %>% arrange(PORT, DEST) %>% mutate(JoinKey = paste0(PORT, "_", DEST)) %>% relocate(JoinKey)

# - Merge data for further analysis - 

# merging
nis_corr <- dplyr::left_join(cd_pj, mdl_tb, by = c("JoinKey"), copy = TRUE, keep = FALSE)

# tidying up
nis_corr <- nis_corr %>% filter(!is.na(PORT.y)) %>% dplyr::select(-one_of(c("JoinKey", "PORT.y", "DEST.y"))) %>% rename("PORT.x"= "PORT" , "DEST.x" = "DEST") %>% as_tibble()

# check data 
head(nis_corr)

#  and subset for sorter command downstream 
nis_corr_ss <- nis_corr %>% dplyr::select(c("JACC_NIS", "PRED_ENV", "VOY_FREQ"))

# - plot variables of interests - 

plot(nis_corr_ss, pch=20 , cex=1.5 , col="#69b3a2")

# - Spearman correlations - 

# just plain correlations between variables - 
cor(nis_corr_ss, method="spearman")

# - Partial Spearman correlation - 

# partial correlation
pcor(nis_corr_ss, method = c("spearman"))

# partial correlation between "JACC_NIS" and "VOY_FREQ" given "PRED_ENV"s effect on both variables (possibly applicable)
pcor.test(nis_corr_ss$"JACC_NIS",nis_corr_ss$"VOY_FREQ", nis_corr_ss$"PRED_ENV", method = c("spearman"))


# - Semi-Partial Spearman correlation - 

# Semi-partial correlation is the correlation of two variables with variation 
#  from a third or more other variables removed only from the second variable. 
#  When the determinant of variance-covariance matrix is numerically zero, 
#  Moore-Penrose generalized matrix inverse is used. In this case, no p-value 
#  and statistic will be provided if the number of variables are greater than
#  or equal to the sample size.

# sem-partial correlation
spcor(nis_corr_ss, method = c("spearman"))

# partial correlation between "JACC_NIS" and "VOY_FREQ" given "PRED_ENV"s removed from second variables (likely applicable)
spcor.test(nis_corr_ss$"JACC_NIS",nis_corr_ss$"VOY_FREQ", nis_corr_ss$"PRED_ENV", method = c("spearman"))
