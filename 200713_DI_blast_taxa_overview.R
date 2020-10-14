# Get graphical representation of detected taxa
# =============================================
#
# check Git history and README.md

rm(list=ls(all=TRUE)) # clear memory

library("tidyverse")  # work using tibbles
library("reshape2")   # long data frames for ggplot

library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("data.table")   # possibly best for large data dimension

library("openxlsx")   # write Excel tables

source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")


# Functions
# ~~~~~~~~~

`%notin%` <- Negate(`%in%`)

# Part I a: Load Blast results and read counts
# ------------------------------------------

# Blast result
# ~~~~~~~~~~~~
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_deep_with-ncbi-info.Rdata")
head(blast_results_final)

# load read counts
# ~~~~~~~~~~~~~~~~
read_counts <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/200706_165_eDNA_samples_Eukaryotes_features_tree-matched__feature-frequency-detail.csv", col_names = FALSE)
names(read_counts) <- c("iteration_query_def", "count")

# merge in read counts via hash field
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BlRsSbsDfJn <- full_join(blast_results_final, read_counts, by = "iteration_query_def")
head(BlRsSbsDfJn)

# load Kara's NIS list
# ~~~~~~~~~~~~~~~~
nis_kara <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/NIS_lookups/invasive_sp_multiple_ports.csv", col_names = TRUE)

# use extra column to mark Kara's NIS in current table
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BlRsSbsDfJn$ISNIS <- FALSE 
BlRsSbsDfJn$ISNIS[which(BlRsSbsDfJn$iteration_query_def %in% nis_kara$iteration_query_def)] <- TRUE 

# check if NIS were transcribed ok - yes they were
identical(nis_kara$iteration_query_def, BlRsSbsDfJn[which(BlRsSbsDfJn$ISNIS == TRUE ), ]$iteration_query_def)



# Part I b: Sort data for summary purposes
# ---------------------------------------
# - by abundance
# - possibly aggregate taxa

# remove Pearl Harbour samples - using hash keys - hash keys obtained below - not done
# [not done yet - and not necessary - no phylotypes exclusively at PH, see below]

# remove 3 Bacterial ASVs - **report those: mismatch between NCBI and SILVA taxonomy assignment**
BlRsSbsDfJn <- BlRsSbsDfJn %>% filter(superkingdom == "Eukaryota")
BlRsSbsDfJn <- BlRsSbsDfJn %>% filter(phylum != "Proteobacteria")

# sort by read count
BlRsSbsDfJn <- BlRsSbsDfJn %>% arrange(desc(count))

# get number of distinct eukaryote species, orders 
BlRsSbsDfJn %>% distinct(species) %>% na.omit %>% nrow # 2410 distinct species
BlRsSbsDfJn %>% distinct(order) %>% na.omit %>%  nrow # 336 distinct orders
BlRsSbsDfJn %>% distinct(class) %>% na.omit %>% nrow # 111 distinct classes
BlRsSbsDfJn %>% distinct(phylum) %>% na.omit %>% nrow # 39 distinct phyla

# get coverages per ASV - empty ASVs not yet filtered out!
coverage_per_asv <- aggregate(BlRsSbsDfJn$count, by = list(iteration_query_def = BlRsSbsDfJn$iteration_query_def), FUN = sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))

# add taxonomy to coverage list
taxon_strings <- distinct(BlRsSbsDfJn[c("iteration_query_def", "superkingdom", "phylum", "class", "order", "family", "genus", "species")])
coverage_per_asv <- left_join(coverage_per_asv, taxon_strings, by = c("iteration_query_def" = "iteration_query_def"))

# inspect 
head(coverage_per_asv, 12) # for now just this, summary below
summary(coverage_per_asv)

# full unique species list, without 0 abundances
coverage_per_asv %>% filter(x != 0) %>% select(superkingdom, phylum, class, order, family, genus, species) %>%
  distinct() %>% arrange(superkingdom, phylum, class, order, family) # 

# subset for species plot

Top12Spec <- semi_join(BlRsSbsDfJn, head(coverage_per_asv, 12), by = c("iteration_query_def"))

# getting indices to manually change factors - to be careful run part IIa below first
try(which(Top12Spec$"iteration_query_def" %in% ph_asv$"iteration_query_def"))

# manually changen factors - all one port less, as PH isn't conted
Top12Spec$src[1] <- "2 Port(s)" # from 3 Ports
Top12Spec$src[9] <- "3 Port(s)" # was 4 ports
Top12Spec$src[12] <- "5 Port(s)" # was 6 ports

# correct one name staring
Top12Spec$species[which(Top12Spec$species == "Pelagostrobilidium sp. LS781")] <- "Pelagostrobilidium sp."

# introduce line breaks
Top12Spec$species <- paste(Top12Spec$species, "\n(", Top12Spec$class,")", sep ="")


# Part I c: 12 most common species, and ports.
# --------------------------------------------
ggplot(Top12Spec, aes(x = reorder(species, +count), y = count, fill = src)) + 
    geom_bar(position="stack", stat="identity") +
    geom_label(label = Top12Spec$src, size = 1.5) +
    theme_bw() +
    theme(legend.position = "none") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.text.y = element_text(hjust = 1), 
          axis.ticks.y = element_blank()) +
    labs( title = "Twelve most common species") + 
    xlab("species") + 
    ylab("sequence count") + 
    coord_flip()

ggsave("200729_12_most_common_sp.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Part I d: Plot taxa and NIS per port  (as requested shortly before 14-Sep-2020)
# -------------------------------------------------------------------------------
# for details on what is plotted check the filtering command


# - all taxa - including putative nis -

blast_results_nis_reads <- BlRsSbsDfJn %>% na.omit %>% filter(count != 0)

ggplot(blast_results_nis_reads, aes(x = src, y = phylum, fill = phylum)) +
  geom_bar(position="stack", stat="identity") +
  labs( title = "phyla across ports") +
  xlab("Ports") + 
  ylab("Phyla") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank())

ggsave("200914_all_taxa_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 100, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# - only nis -

blast_results_nis_only_reads <- BlRsSbsDfJn %>% na.omit %>% filter(count != 0) %>% filter(ISNIS == TRUE)

ggplot(blast_results_nis_only_reads, aes(x = src, y = phylum, fill = phylum)) +
  geom_bar(position="stack", stat="identity") +
  labs( title = "phyla across ports") +
  xlab("Ports") + 
  ylab("Phyla") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank())

ggsave("200914_nis_taxa_acroos_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# - only metazoan nis (manually filtered) -

blast_results_nis_only_reads_metazoans <- BlRsSbsDfJn %>% 
  na.omit %>% filter(count != 0) %>% filter(ISNIS == TRUE) %>% filter(phylum %notin% "Bacillariophyta")

ggplot(blast_results_nis_only_reads_metazoans, aes(x = src, y = phylum, fill = phylum)) +
  geom_bar(position="stack", stat="identity") +
  labs( title = "putatively invasive metazoan phyla across ports") +
  xlab("Ports") + 
  ylab("Phyla") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank())

ggsave("201007_nis_metazoans_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# - only non metazoan nis (manually filtered) -

blast_results_nis_only_reads_non_metazoans <- BlRsSbsDfJn %>% 
  na.omit %>% filter(count != 0) %>% filter(ISNIS == TRUE) %>% filter(phylum %in% "Bacillariophyta")

ggplot(blast_results_nis_only_reads_non_metazoans, aes(x = src, y = phylum, fill = phylum)) +
  geom_bar(position="stack", stat="identity") +
  labs( title = "putatively invasive non-metazoan phyla across ports") +
  xlab("Ports") + 
  ylab("Phyla") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank())

ggsave("201007_nis_non_metazoans_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# Part II a: Load Qiime artifacts for full plotting
# -------------------------------------------------

# Set paths:
sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryotes_features_tree-matched_qiime_artefacts/dna-sequences.fasta" 
biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryotes_features_tree-matched_qiime_artefacts/features-tax-meta.biom"

# Create Phyloseq object:
biom_table <- phyloseq::import_biom (biom_path)
sequ_table <- Biostrings::readDNAStringSet(sequ_path)  
  
# Construct Object:
phsq_ob <- merge_phyloseq(biom_table, sequ_table)


# Part II b: Format data for plotting and species lists for collaborators
# -----------------------------------------------------------------------

# Clean Data:
phsq_ob <- remove_empty(phsq_ob)

# set rank names to match Blast information
colnames(tax_table(phsq_ob)) <- c("superkingdom", "phylum", "class", "order", "family",  "genus", "species")

# overwrite taxonomy information with Blast data
# ----------------------------------------------
class(tax_table(phsq_ob))

# export from Phyloseq object for merging
tax_tibble <- as_tibble(as(tax_table(phsq_ob), "matrix"), rownames = "iteration_query_def")

# get new taxonomy from blast results
new_taxonomy <- select(blast_results_final, "iteration_query_def", "superkingdom", "phylum", "class", "order", "family",  "genus", "species")

# join in new information, and correct column names
tax_tibble_new <- left_join(tax_tibble, new_taxonomy, by = "iteration_query_def") %>%
  select(-contains('.x')) %>%
  rename_with(., ~ gsub("\\.y", "", .))

# get a properly formatted matrix
tax_mat_new <- as.matrix(tax_tibble_new[-1]) 
rownames(tax_mat_new) <- tax_tibble_new$iteration_query_def
colnames(tax_mat_new) <- names(tax_tibble_new)[-1]
head(tax_mat_new)

# Replace NA's with alternative string 
# tax_mat_new[is.na(tax_mat_new)] <- "Undetermined"

# check old and new data - seems to match ok
tax_mat_new[(which (rownames(tax_mat_new) == "bb74f2d7c80cfd5b32c00f805caa44fe")), ]
blast_results_final[(which (blast_results_final$iteration_query_def == "bb74f2d7c80cfd5b32c00f805caa44fe")), ] %>%
  select ("superkingdom", "phylum", "class", "order", "family",  "genus", "species")

# overwrite Silva taxonomy data in Phyloseq object with Blast taxonomy data
tax_table(phsq_ob) <- tax_mat_new


# Insert: get species list for collaborators - Honolulu, Pearl Harbour (7. Oct. 2020)
# ----------------------------------------------------------------------------------

phsq_ob_hi <- subset_samples(phsq_ob, Port == "Honolulu")
phsq_ob_hi <- remove_empty(phsq_ob_hi)
phsq_ob_hi_molten <- psmelt(phsq_ob_hi)
write.xlsx(phsq_ob_hi_molten, "/Users/paul/Documents/CU_NIS-WRAPS/170728_external_presentations/201007_species_list_hi/200710_species_list_full_HI.xlsx", overwrite = FALSE)
# omitting writing full PhylSeq object 

phsq_ob_ar <- subset_samples(phsq_ob, Port == "Puerto-Madryn")
phsq_ob_ar <- remove_empty(phsq_ob_ar)
phsq_ob_ar_molten <- psmelt(phsq_ob_ar)
write.xlsx(phsq_ob_ar_molten, "/Users/paul/Documents/CU_NIS-WRAPS/170728_external_presentations/201007_species_list_ar/200710_species_list_full_AR.xlsx", overwrite = TRUE)
# omitting writing full PhylSeq object 


# Insert:  get list of PH phylotypes for above - remove PH samples and phylotypes
# --------------------------------------------------------------------------------
asv_table <- as_tibble(as(otu_table(phsq_ob), "matrix"), rownames = "iteration_query_def")

# some phylotypes are also found at exclusively at PH
ph_asv <- asv_table %>% filter(., select(., contains("PH")) > 0 ) %>% select("iteration_query_def")

# no phylotypes exclusively at PH - no filtering necessary to modify counts
asv_table %>% filter(., select(., contains("PH")) > 0 ) %>% filter(., select(., -contains("PH")) == 0) 


# Part II c: Plotting data with sequence counts
# -----------------------------------------------
# Melt dataframe and do yourself
# ( in plot call abundances are aggregated in-call to avoid jagged edges)

# ~ plot sequence counts per port ~

# agglomerate on phylum level to avoid jagged barplots - copy full object before discarding inforation 
phsq_ob_full <- phsq_ob 

phsq_ob <- tax_glom(phsq_ob, taxrank = rank_names(phsq_ob)[2], NArm=FALSE, bad_empty=c(NA))

# remove PH samples
phsq_ob_lng <- psmelt(phsq_ob)
phsq_ob_lng <- phsq_ob_lng %>% arrange(Sample, desc(Abundance)) %>% filter(Facility != c("PH"))
 
# ggplot(phsq_ob_lng, aes_string(x = "phylum", y = ave(phsq_ob_lng$Abundance, phsq_ob_lng$phylum, FUN=sum), fill = "phylum")) +
ggplot(phsq_ob_lng, aes_string(x = "phylum", y = "Abundance", fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Facility ~ ., shrink = TRUE, scales = "free_y") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla across all ports") + 
  xlab("phyla at all ports") + 
  ylab("sequence counts for each port (y scales variable)")

ggsave("200729_all_phyla_at_all_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# Part III: Plotting and data based on ASV counts
# -----------------------------------------------

# melting un-agglomerated Phyloseq object
phsq_ob_full_lng  <- psmelt(phsq_ob_full)

# remove PH and superflous phyla and check
phsq_ob_full_lng <- phsq_ob_full_lng %>% filter(Facility != c("PH"))
phsq_ob_full_lng <- phsq_ob_full_lng %>% filter(phylum != "Proteobacteria")

unique(phsq_ob_full_lng$Facility)

# remove undefined Phyla and check (questionable because, missing phylum string doesn't indicate missing data)
phsq_ob_full_lng <- phsq_ob_full_lng %>% filter(phylum != "NA") # NA here is a string, keep the ""
unique(phsq_ob_full_lng$Facility)

# remove 0 count Abundances
summary(phsq_ob_full_lng$Abundance)
phsq_ob_full_lng <- phsq_ob_full_lng %>% filter(Abundance != 0)
summary(phsq_ob_full_lng$Abundance)

# split objects into metazoans and non-metazoaa
metazoa <- c("Annelida", "Arthropoda", "Brachiopoda", "Bryozoa", "Chordata", "Cnidaria", "Ctenophora", "Echinodermata",
             "Entoprocta", "Gastrotricha", "Hemichordata", "Mollusca", "Nematoda", "Mermertea", "Platyhelminthes", "Porifera", 
             "Rotifera", "Tardigrada")

phsq_ob_metazoan_lng <- phsq_ob_full_lng %>% filter(phylum %in% metazoa) %>% as_tibble()
phsq_ob_nonmetaz_lng <- phsq_ob_full_lng %>% filter(phylum %notin% metazoa) %>% as_tibble()
phsqs_wide <- list("metazoa" = phsq_ob_metazoan_lng, "nonmeta" = phsq_ob_nonmetaz_lng)


# adding presence-absence to presence Abundance column (via lapply(<list-like-object>, function(x) <do stuff>))
#   and check
phsqs_wide <- lapply(phsqs_wide, function(x) mutate(x, Present = case_when(Abundance > 0 ~ 1, Abundance == 0  ~ 0)) %>% as_tibble())
lapply(phsqs_wide, function(x) sum(x$Present == 0))
lapply(phsqs_wide, function(x) sum(x$Present == 1))

# adding ASV counts per port, should be the same everywhere unless 0 cout OTUs are removed
phsqs_wide <- lapply(phsqs_wide, function(x) add_count(x, Facility, sort = FALSE, name = "ASVCountPerPort"))
lapply(phsqs_wide, function (x) unique(x$ASVCountPerPort))
# 19 values for 19 ports, metazoa not at all ports

# adding ASV counts per port and phylum, should be the same everywhere unless 0 cout OTUs are removed
phsqs_wide <- lapply(phsqs_wide, function (x) add_count(x, Facility, phylum, sort = FALSE, name = "ASVCountPerPortEachPhylum"))
lapply(phsqs_wide, function (x) unique(x$ASVCountPerPortEachPhylum)) # variable as expected, more then 19 values as expected

# add proportions of each phylum per port, for requested percentage plot
phsqs_wide <- lapply(phsqs_wide, function(x) mutate(x, PhylumPortProp = ASVCountPerPortEachPhylum / ASVCountPerPort ) %>% as_tibble())

# ***for plotting and subsequent analysis keeping distinct values only***
phsqs_wide_dstnct <- lapply(
  phsqs_wide, function (x) x %>%  
  select (Facility, Location, phylum, Present, ASVCountPerPort, ASVCountPerPortEachPhylum, PhylumPortProp) %>%
  arrange(Facility, phylum, ASVCountPerPort) %>%
  distinct()
  )

remotes::install_github("coolbutuseless/ggpattern")

# plot plain ASV per phylum and port
ggplot(phsqs_wide_dstnct[[1]], aes_string(x = "Facility", y = "ASVCountPerPortEachPhylum", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 90, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "observed metazoan ASVs across ports") + 
  xlab("ports") + 
  ylab("ASVs at each port")

ggsave("201014_observed_metazoan_ASVs_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

ggplot(phsqs_wide_dstnct[[2]], aes_string(x = "Facility", y = "ASVCountPerPortEachPhylum", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 90, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "observed non-metazoan ASVs across ports") + 
  xlab("ports") + 
  ylab("ASVs at each port")

ggsave("201014_observed_non-metazoan_ASVs_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# proportional plots 
ggplot(phsqs_wide_dstnct[[1]], aes_string(x = "Facility", y = "PhylumPortProp", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 90, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "observed metazoan ASV proportions across ports") + 
  xlab("ports") + 
  ylab("unique ASV proportion per port")

ggsave("201014_observed_metazoan_ASV_proportions_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

ggplot(phsqs_wide_dstnct[[2]], aes_string(x = "Facility", y = "PhylumPortProp", fill="phylum")) +
  geom_bar(stat = "identity", position = "stack", size = 0) +
  theme_bw() +
  theme(strip.text.y = element_text(angle = 0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 90, hjust = 1,  size = 8), 
        axis.ticks.y = element_blank()) +
  labs(title = "observed non-metazoan ASV proportions across ports") + 
  xlab("ports") + 
  ylab("unique ASV proportion per port")

ggsave("201014_observed_non-metazoan_ASV_proportions_across_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Part IV: Vegan analysis of ASV presence-absence (phyla)
# ------------------------------------------------------

# ~~~ format data ~~~

# get a wide ASV table from input object - metazoa
phsq_ob_dstnct_truncated <- as_tibble(data.table::dcast(setDT(phsqs_wide_dstnct[[1]]), Facility~phylum, value.var="ASVCountPerPortEachPhylum", fill=0))

# correct column names
phsq_ob_dstnct_truncated <- phsq_ob_dstnct_truncated %>% dplyr::rename(Port = Facility) 

# add ecoregion
phsq_ob_dstnct_truncated <- phsq_ob_dstnct_truncated %>% 
  dplyr::mutate(Ecoregion = case_when(Port %in% c("AD") ~ "South_Australia",
                               Port %in% c("AW", "ZB", "RT", "GH") ~ "Northeast_Atlantic",
                               Port %in% c("NO", "HT", "BT",  "WL", "MI", "WL") ~ "Caribbean",
                               Port %in% c("HS", "PL", "CB", "RC", "OK", "LB") ~ "North_Pacific",
                               Port %in% c("HN") ~ "Mid South Tropical Pacific",
                               Port %in% c("SI") ~ "Indo-Pacific",
                               Port %in% c("PM") ~ "Rio de La Plata"))

# tidy column order 
phsq_ob_dstnct_truncated <- phsq_ob_dstnct_truncated %>% relocate(Port, Ecoregion) %>% arrange (Ecoregion,  Port) %>% tibble()


# ~~~ ANOSIM ~~~

#  following: https://jkzorz.github.io/2019/06/11/ANOSIM-test.html
#  better done with UNIFRAC data?

vegan::anosim(data.matrix(phsq_ob_dstnct_truncated[,3:ncol(phsq_ob_dstnct_truncated)]), phsq_ob_dstnct_truncated$Ecoregion, permutations = 2000, distance = "bray",
    parallel = getOption("mc.cores"))
