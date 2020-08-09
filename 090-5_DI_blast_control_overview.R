# Get graphical representation of detected taxa in controls
# =========================================================
# akin to 
# E. E. Sigsgaard, F. Torquato, T. G. Frøslev, A. B. M. Moore, J. M. Sørensen, 
#   P. Range, R. Ben‐Hamadou, S. S. Bach, P. R. Møller, P. F. Thomsen, Using 
#   vertebrate environmental DNA from seawater in biomonitoring of marine 
#   habitats. Conserv. Biol. 34, 697–710 (2020). 

rm(list=ls(all=TRUE)) # clear memory
library("tidyverse")  # work using tibbles
library("reshape2")   # long data frames for ggplot
library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("data.table")   # possibly best for large data dimension

source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

# Part I a: Load Blast results and add read counts
# ------------------------------------------------

# Blast result
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200806_090-4_blast-xml-conversion_cntrl_with_ncbi.Rdata")

head(blast_results_final)

# load read counts

read_counts <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Qiime/090_18S_controls_features.csv", col_names = FALSE)

names(read_counts) <- c("iteration_query_def", "count")

# merge in read counts via hash field

BlRsSbsDfJn <- full_join(blast_results_final, read_counts, by = "iteration_query_def")

head(BlRsSbsDfJn)

# Part I b: Sort data for summary purposes
# ---------------------------------------
# - by abundance
# - possibly aggregate taxa


# remove 3 Bacterial ASVs - **report those: mismatch between NCBI and SILVA taxonomy assignment**
BlRsSbsDfJn <- BlRsSbsDfJn %>% filter(superkingdom == "Eukaryota")

# sort by read count
BlRsSbsDfJn <- BlRsSbsDfJn %>% arrange(desc(count))

# get number of distinct eukaryote species, orders 
BlRsSbsDfJn %>% distinct(species) %>% na.omit %>% nrow # 515 distinct species
BlRsSbsDfJn %>% distinct(order) %>% na.omit %>%  nrow # 180 distinct orders
BlRsSbsDfJn %>% distinct(class) %>% na.omit %>% nrow # 70 distinct classes
BlRsSbsDfJn %>% distinct(phylum) %>% na.omit %>% nrow # 25 distinct phyla

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

Top12Spec <- semi_join(BlRsSbsDfJn, head(coverage_per_asv, 12), by = c("iteration_query_def"))

# introduce line breaks
Top12Spec$species <- paste(Top12Spec$species, "\n(", Top12Spec$class,")", sep ="")


# Part I c: Plot and save data.
# ----------------------------

# 12 most common species, and ports
ggplot(Top12Spec, aes(x = reorder(species, +count), y = count)) + 
    geom_bar(position="stack", stat="identity", fill = "skyblue") +
    theme_bw() +
    theme(legend.position = "none") +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_text(hjust = 1), 
          axis.ticks.y = element_blank()) +
    labs( title = "Twelve most common species across \n positive and negative controls") + 
    xlab("species") + 
    ylab("sequence count") + 
    coord_flip()

ggsave("200806_12_most_common_sp_in_cntrls.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 100, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Part II a: Load Qiime artifacts for full plotting
# -------------------------------------------------

# Set paths:
sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/090-218S_controls_tab_qiime_artefacts_control/dna-sequences.fasta" 
biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/090-218S_controls_tab_qiime_artefacts_control/features-tax-meta.biom"

# Create Phyloseq object:
biom_table <- phyloseq::import_biom (biom_path)
sequ_table <- Biostrings::readDNAStringSet(sequ_path)  
  
# Construct Object:
phsq_ob <- merge_phyloseq(biom_table, sequ_table)

# Part II b: Format data for plotting
# -----------------------------------

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

# overwrite Silva taxonomy data in Phyloseq object with Blast taxonomy data
tax_table(phsq_ob) <- tax_mat_new

# get list of PH phylotypes for above - remove PH samples and phylotypes
asv_table <- as_tibble(as(otu_table(phsq_ob), "matrix"), rownames = "iteration_query_def")

# create a copy for later
phsq_ob_cp <- phsq_ob


# Part II c: Plotting data
# -----------------------------------
# Melt dataframe and do yourself
# ( in plot call abundances are aggregated in-call to avoid jagged edges)


# agglomerate on phylum level to avoid jagged barplots 
phsq_ob <- tax_glom(phsq_ob, taxrank = rank_names(phsq_ob)[2], NArm=FALSE, bad_empty=c(NA))

phsq_ob_lng <- psmelt(phsq_ob)
phsq_ob_lng <- phsq_ob_lng %>% arrange(Sample, desc(Abundance))
 
# ggplot(phsq_ob_lng, aes_string(x = "phylum", y = ave(phsq_ob_lng$Abundance, phsq_ob_lng$phylum, FUN=sum), fill = "phylum")) +
ggplot(phsq_ob_lng, aes_string(x = "phylum", y = "Abundance", fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Facility ~ ., shrink = TRUE, scales = "fixed") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla in positive and negative controls at all work locations") + 
  xlab("phyla at all work locations") + 
  ylab("sequence counts for each work location (y scales fixed)")

ggsave("200806_all_phyla_at_all_working_locations_in_control.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)


# Part III: Isolate and check controls further 
# ---------------------------------------------
# work with: 



# plot controls by control type
# ------------------------------

phsq_ob_cp
phsq_ob_cp_lng <- psmelt(phsq_ob_cp)

unique(phsq_ob_cp_lng$Type)

phsq_ob_cp_lng$Type[which(phsq_ob_cp_lng$Type %in% "ablk")] <- "PCR blank"
phsq_ob_cp_lng$Type[which(phsq_ob_cp_lng$Type %in% "bblk")] <- "Cooler blank"
phsq_ob_cp_lng$Type[which(phsq_ob_cp_lng$Type %in% "cblk")] <- "Filter blank"
phsq_ob_cp_lng$Type[which(phsq_ob_cp_lng$Type %in% "xblk")] <- "Extraction blank"
phsq_ob_cp_lng$Type[which(phsq_ob_cp_lng$Type %in% "moc")] <- "Mock community"

ggplot(phsq_ob_cp_lng, aes_string(x = "phylum", y = "Abundance", fill = "phylum")) +
  geom_bar(stat = "identity", position = "stack", colour = NA, size=0) +
  facet_grid(Type ~ ., shrink = TRUE, scales = "free_y") +
  theme_bw() +
  theme(legend.position = "none") +
  theme(strip.text.y = element_text(angle=0)) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        axis.text.y = element_text(angle = 0, hjust = 1,  size = 7), 
        axis.ticks.y = element_blank()) +
  labs( title = "Phyla in positive and negative controls") + 
  xlab("phyla in controld types") + 
  ylab("sequence counts for each work location (variable y scales)")
  
ggsave("200810_all_phyla_in_controls.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Inspect control types further - PCR blank and Mock community
# ------------------------------------------------------------