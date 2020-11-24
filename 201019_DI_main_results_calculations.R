#' ---
#' title: "Get graphical representation of detected taxa"
#' author: "Paul Czechowski"
#' date: "24-Nov-2020"
#' output: pdf_document
#' ---
#' 
#' 
#' Use `rmarkdown::render("/Users/paul/Documents/CU_combined/Github/201019_DI_main_results_calculations.R")` to render.
#'
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

# save data for collaborators
save(phsq_ob_unfiltered_molten_merged, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/201019_DI_main_results_calculations.Rdata")


# Data plotting and analysis - all ASV analysis and plotting
# ==========================================================

# Formatting and numerical summaries 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# added 21-11-2020

# keep all - no-PH samples - eDNA samples - no bacteria
all_asv_lng <- phsq_ob_unfiltered_molten_merged[RID != "PH" & Type == "eDNA" & superkingdom == "Eukaryota"]

# remove Blast information (starting with "hsp_..." ) for clarity (at least temporarily)
all_asv_lng[, grep("^hsp_", colnames(all_asv_lng)):=NULL]

# understand data structures by counting unique elements among varibels and their products
future_apply(all_asv_lng, 2, function(x) length(unique(x)))
nrow(all_asv_lng)

# aggregate on Port (=RID) level
#   https://stackoverflow.com/questions/16513827/summarizing-multiple-columns-with-data-table
all_asv_lng <- all_asv_lng[, lapply(.SD, sum, na.rm=TRUE), by=c("RID", "ASV", "src", "tax_id", "superkingdom",  "phylum",  "class",  "order",  "family",  "genus",  "species"), .SDcols=c("Abundance") ]

#  resort for clarity
keycol <-c("ASV","RID")
setorderv(all_asv_lng, keycol)

# add presence-absence abundance column
all_asv_lng <- all_asv_lng[ , AsvPresent :=  fifelse(Abundance == 0 , 0, 1, na=NA)]

# understand data structures
future_apply(all_asv_lng, 2, function(x) length(unique(x)))
head(all_asv_lng, 100)
nrow(all_asv_lng)

# Plots
# ~~~~~

# plot plain ASV per phylum and port - not facetted
ggplot(all_asv_lng, aes_string(x = "RID", y = "AsvPresent", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  scale_y_continuous(breaks = int_breaks) +
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "eukaryote ASVs (NCBI taxonomy)") + 
  xlab("ports") + 
  ylab("ASV count")

ggsave("201121_observed_eukaryote_ASVs_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

ggsave("201124_fig_S9_asv_at_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/201124_di_supplement",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# plot plain ASV per phylum and port - facetted
ggplot(all_asv_lng, aes_string(x = "RID", y = "AsvPresent", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  facet_grid(src ~ ., shrink = TRUE, scales = "free_y") + 
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "eukaryote ASVs (NCBI taxonomy)") + 
  xlab("ports") + 
  ylab("ASV count")

ggsave("201121_observed_eukaryote_ASVs_across_ports_facetted.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)


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
  labs(title = "putative eukaryote NIS ASVs (NCBI taxonomy)") + 
  xlab("ports") + 
  ylab("ASV count")

ggsave("201020_observed_ASVs_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)
  
ggsave("201124_fig_S10_asv_at_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/201124_di_supplement",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)



# Further analysis
# ~~~~~~~~~~~~~~~~

# - Prepare Jaccard matrix for merging - 

# get Jaccard distance matrix for invasive taxa Jaccard distances between ports based on ASV presence
cd <- as.matrix(data.table::dcast(setDT(nis_asv_lng), RID~ASV, value.var="AsvPresent", fill=0), rownames=TRUE)

# just checking - row sums should all be larger then zero
rowSums(cd)

cd_dm <- vegdist(cd, method="jaccard", binary=FALSE, diag=TRUE, upper=TRUE, na.rm = FALSE)


# melt for merging
cd_pj <- reshape2::melt(as.matrix(cd_dm), varnames = c("PORT", "DEST"), value.name = "JACC_NIS")

# sort by RID for key creation  - create key for merging - move key to front for visibility
cd_pj <- cd_pj %>% arrange(PORT, DEST) %>% mutate(JoinKey = paste0(PORT, "_", DEST)) %>% relocate(JoinKey)


# - Prepare old model data for merging - 

# read old model data (check - must be the same as Jose) - using unscaled data
mdl_tb <- readr::read_csv("/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2020-Apr-27-16-48-06_no_ph_joined_no-nas.csv", col_names = TRUE)

#  sort by RID for key creation  - create key for merging - move key to front for visibility
mdl_tb <- mdl_tb %>% arrange(PORT, DEST) %>% mutate(JoinKey = paste0(PORT, "_", DEST)) %>% relocate(JoinKey)


# UNIFRAC summary - 21.11.2020
hist(mdl_tb$RESP_UNIFRAC)
summary(mdl_tb$RESP_UNIFRAC)
mean(mdl_tb$RESP_UNIFRAC)
sd(mdl_tb$RESP_UNIFRAC)

# routes are bidirectional - check both variables to see all 19 ports - 21.11.2020
unique(mdl_tb$PORT)
unique(mdl_tb$DEST)

# - Merge data for further analysis -  

# merging
nis_corr <- dplyr::left_join(cd_pj, mdl_tb, by = c("JoinKey"), copy = TRUE, keep = FALSE)

# tidying up
nis_corr <- nis_corr %>% filter(!is.na(PORT.y)) %>% dplyr::select(-one_of(c("JoinKey", "PORT.y", "DEST.y"))) %>% rename("PORT.x"= "PORT" , "DEST.x" = "DEST") %>% as_tibble()

# check data 
head(nis_corr)

# - check response of Unifrac to and ecoregion crossing  - 24.11.2020

uni_check <- nis_corr %>% dplyr::select("RESP_UNIFRAC", "PRED_ENV", "ECO_DIFF")

uni_eco <- uni_check %>% dplyr::group_by(ECO_DIFF) %>%
  mutate(MEANUNI = mean(RESP_UNIFRAC, na.rm = T))

ggplot(uni_eco, aes (x=RESP_UNIFRAC, color = ECO_DIFF)) +  
  geom_density() +
  geom_vline(aes(xintercept=MEANUNI, color=ECO_DIFF),linetype="dashed") +
  annotate("text", x=unique(uni_eco$MEANUNI), y=c(3.5, 4.5), label=paste("mean =", round(unique(uni_eco$MEANUNI), digits = 2)), size=4) +
  annotate("text", x=0.525, y=5.75, label=paste("n =", length(uni_eco$RESP_UNIFRAC)), size=4) +
  labs(title = "mean UNIFRAC values and crossing of marine realms") +
  labs(x = "mean UNIFRAC distance between port pairs (5 samples per port)") +
  labs(y = "Density") +
  guides(color=guide_legend(title="realm crossed")) +
  theme_bw()

ggsave("201124_fig_S5_unifrac_realms.pdf", plot = last_plot(), 
  device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/201124_di_supplement",
  scale = 5, width = 30, height = 15, units = c("mm"),
  dpi = 500, limitsize = TRUE)

# - check response of Unifrac environmental distance  - 24.11.2020

## after https://gist.github.com/adamhsparks/e299e6d1beb82ed258c1052050d63bc5

mod <- lm(RESP_UNIFRAC ~ PRED_ENV, data = uni_check)
summary(mod)
# see that p-value: < 1.75e-07

# function to create the text equation
lm_eqn <- function(df, lm_object) {
  eq <-
    substitute(
      italic(y) == a + b %.% italic(x) * "," ~  ~ italic(r) ^ 2 ~ "=" ~ r2,
      list(
        a = format(coef(lm_object)[1], digits = 2),
        b = format(coef(lm_object)[2], digits = 2),
        r2 = format(summary(lm_object)$r.squared, digits = 3),
        p = format(summary(lm_object)$coefficients[,"Pr(>|t|)"][[2]],digits = 2)
      )
    )
  as.character(as.expression(eq))
}

# get the equation object in a format for use in ggplot2
eqn <- lm_eqn(uni_check, mod)

#' ## Plotting and saving

ggplot(data = uni_check, aes(x = RESP_UNIFRAC, y = PRED_ENV)) +
  geom_smooth(method="auto", se=TRUE, fullrange=FALSE, level=0.95) +
  geom_smooth(method="lm", se=FALSE, fullrange=FALSE, level=0.95, color="red", linetype="dashed") +
  geom_point() +
  annotate("text",
           x = 0.85,
           y = 0.15, 
           label = "italic(p) < 1.75e-07",
           parse = TRUE, color="red") +
  annotate("text",
           x = 0.85,
           y = 0.35, 
           label = eqn,
           parse = TRUE, color="red") +
  annotate("text", x=0.5, y=4, label=paste("n =", length(uni_check$RESP_UNIFRAC)), size=4) +
  theme_bw() + 
  theme(legend.position= "none") +
  labs(title=" ",
       x ="Unifrac distance", y = "Environmental Distance") 

ggsave("201124_fig_S6_unifrac_env_dist.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/201124_di_supplement",
         scale = 1.0, width = 200, height = 140, units = c("mm"),
         dpi = 500, limitsize = TRUE)


#  and subset for sorter command downstream  
#   not sure which variable to choose from Jose's modeling results using "J_VOY_FREQ" not "J_B_HON_NOECO_NOENV" 
#   assuming this corresponds to highlighted model in Table 1
#     Traffic | Stepping | UNIFRAC = ENV+ SHP + ENV*SHP + (ORG) + (DEST) | -479.34 | -457.35

nis_corr_ss <- nis_corr %>% dplyr::select(c("JACC_NIS", "PRED_ENV", "J_VOY_FREQ"))

# - plot variables of interests - 

plot(nis_corr_ss, pch=20 , cex=1.5 , col="#69b3a2")
hist(nis_corr_ss$"JACC_NIS")   # high values frequent - must be distance
hist(nis_corr_ss$"J_VOY_FREQ") # low values frequent - looks like index - unstandardized  
nis_corr_ss$"J_VOY_FREQ" <- 1 - nis_corr_ss$"J_VOY_FREQ" # convert index to distance - all others in table are distance, too
hist(nis_corr_ss$"J_VOY_FREQ") # high values frequent - looks like distance now
hist(nis_corr_ss$"PRED_ENV")   # just a normal distribution, distance goes from 0 to 4

# - Spearman correlations - 

# just plain correlations between variables - 
cor(nis_corr_ss, method="spearman")

# - Partial Spearman correlation - 

# partial correlation
pcor(nis_corr_ss, method = c("spearman"))

# partial correlation between "JACC_NIS" and "VOY_FREQ" given "PRED_ENV"s effect on both variables (possibly applicable)
pcor.test(nis_corr_ss$"JACC_NIS",nis_corr_ss$"J_VOY_FREQ", nis_corr_ss$"PRED_ENV", method = c("spearman"))


# - Semi-Partial Spearman correlation - 

# Semi-partial correlation is the correlation of two variables with variation 
#  from a third or more other variables removed only from the second variable. 
#  When the determinant of variance-covariance matrix is numerically zero, 
#  Moore-Penrose generalized matrix inverse is used. In this case, no p-value 
#  and statistic will be provided if the number of variables are greater than
#  or equal to the sample size.

# sem-partial correlation
spcor(nis_corr_ss, method = c("spearman"))

# partial correlation between "JACC_NIS" and "J_VOY_FREQ" given "PRED_ENV"s removed from second variables (likely applicable)
#  assuming only first variale "JACC_NIS" affected by "PRED_ENV", but not, "J_VOY_FREQ" 
#  still seems like the right choice to me 
spcor.test(nis_corr_ss$"JACC_NIS",nis_corr_ss$"J_VOY_FREQ", nis_corr_ss$"PRED_ENV", method = c("spearman"))

# JA: partial correlation between "J_VOY_FREQ" and "JACC_NIS" given "PRED_ENV"s removed from second variables (possibly applicable)
spcor.test(nis_corr_ss$"J_VOY_FREQ", nis_corr_ss$"JACC_NIS", nis_corr_ss$"PRED_ENV", method = c("spearman")) 

### JA: Plotting of semipartial correlation of Jaccard NIS and traffic. (Jaccard NIS controlled for env similarity) ####  

Jacc_resid<-resid(lm(JACC_NIS~J_VOY_FREQ,nis_corr_ss))

ggplot(nis_corr_ss, aes(x=J_VOY_FREQ, y=Jacc_resid)) +
  geom_point() +
  geom_smooth(method=lm) + 
  labs(x="J_VOY_FREQ", y = "JACC_NIS | PRED_ENV")+
  theme_bw() 

# Removing outliers in VOY_FREQ 
#  https://www.statsandr.com/blog/outliers-detection-in-r/#percentiles
# 
# lower_bound <- quantile(nis_corr_ss$"VOY_FREQ", 0.025)
# lower_bound
# upper_bound <- quantile(nis_corr_ss$"VOY_FREQ", 0.975)
# upper_bound
# outlier_ind <- which(nis_corr_ss$"VOY_FREQ" < lower_bound | nis_corr_ss$"VOY_FREQ" > upper_bound)
# 
# nis_corr_ss <- nis_corr_ss[-outlier_ind, ]
# 
# Jacc_resid<-resid(lm(JACC_NIS~PRED_ENV,nis_corr_ss))
# 
# ggplot(nis_corr_ss, aes(x=VOY_FREQ, y=Jacc_resid)) +
#   geom_point() +
#   geom_smooth(method=lm) + 
#   labs(x="VOY_FREQ", y = "JACC_NIS | PRED_ENV")+
#   theme_classic() 
