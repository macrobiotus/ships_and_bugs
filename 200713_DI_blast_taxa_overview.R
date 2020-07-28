# Get graphical representation of detected taxa
# =============================================
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

# Part I a: Load Blast results and read counts
# ------------------------------------------

# Blast result
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_deep_with-ncbi-info.Rdata")

head(blast_results_final)

# load read counts

read_counts <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/200706_165_eDNA_samples_Eukaryotes_features_tree-matched__feature-frequency-detail.csv", col_names = FALSE)

names(read_counts) <- c("iteration_query_def", "count")

# merge in read counts via hash field

BlRsSbsDfJn <- full_join(blast_results_final, read_counts, by = "iteration_query_def")

head(BlRsSbsDfJn)

# Part I b: Sort data for summary purposes
# ---------------------------------------
# - by abundance
# - possibly aggregate taxa

# remove Pearl Harbour samples - suing hash keys - hash keys obtained below - not done
# [not done yet - and not necessary - no phylotypes exclusively at PH, see below]

# remove 3 Bacterial ASVs - **report those: mismatch between NCBI and SILVA taxonomy assignment**
BlRsSbsDfJn <- BlRsSbsDfJn %>% filter(superkingdom == "Eukaryota")

# sort by read count
BlRsSbsDfJn <- BlRsSbsDfJn %>% arrange(desc(count))

# get number of distinct eukaryote species, orders 
BlRsSbsDfJn %>% distinct(species) %>% na.omit %>% nrow # 3171 distinct species
BlRsSbsDfJn %>% distinct(order) %>% na.omit %>%  nrow # 418 distinct orders
BlRsSbsDfJn %>% distinct(class) %>% na.omit %>% nrow # 134 distinct classes
BlRsSbsDfJn %>% distinct(phylum) %>% na.omit %>% nrow # 40 distinct phyla

# below: new code 28-7-2020

# get coverages per ASV - empty ASVs not yet filtered out!
coverage_per_asv <- aggregate(BlRsSbsDfJn$count, by = list(iteration_query_def = BlRsSbsDfJn$iteration_query_def), FUN = sum)
coverage_per_asv <- coverage_per_asv %>% arrange(desc(x))

# add taxonomy to coverage list
taxon_strings <- distinct(BlRsSbsDfJn[c("iteration_query_def", "superkingdom", "phylum", "class", "order", "family", "genus", "species")])
coverage_per_asv <- left_join(coverage_per_asv, taxon_strings, by = c("iteration_query_def" = "iteration_query_def"))

# inspect 
head(coverage_per_asv, 12) # for now just this, summary below
summary(coverage_per_asv)

coverage_per_asv %>% filter(x != 0) %>% select(superkingdom, phylum, class, order, family, genus, species) %>%
  destinct() %>% arrange(superkingdom, phylum, class, order, family, genus, species)


# above: new code 28-7-2020

# subset for species plot
Top12Spec <- BlRsSbsDfJn %>% slice_max(count, n = 12)   # %>% select(superkingdom, phylum, class, order, family, genus, species, count, src) %>% print

# getting indices to manually change factors - careful
try(which(Top12Spec$"iteration_query_def" %in%  ph_asv$"iteration_query_def"))

# manually changen factors - all one port less, as PH isn't conted
Top12Spec$src[1] <- "2 Port(s)" # from 3 Ports
Top12Spec$src[9] <- "3 Port(s)" # was 4 ports
Top12Spec$src[12] <- "5 Port(s)" # was 6 ports

# correct one name staring
Top12Spec$species[which(Top12Spec$species == "Pelagostrobilidium sp. LS781")] <- "Pelagostrobilidium sp."

# introduce line breaks
Top12Spec$species <- paste(Top12Spec$species, "\n(", Top12Spec$class,")", sep ="")


# Part I c: Plot and save data.
# ----------------------------

# 12 most common species, and ports

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

ggsave("200714_12_most_common_sp.pdf", plot = last_plot(), 
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

# check old and new data - seems to match ok
tax_mat_new[(which (rownames(tax_mat_new) == "bb74f2d7c80cfd5b32c00f805caa44fe")), ]
blast_results_final[(which (blast_results_final$iteration_query_def == "bb74f2d7c80cfd5b32c00f805caa44fe")), ] %>%
  select ("superkingdom", "phylum", "class", "order", "family",  "genus", "species")

# overwrite Silva taxonomy data in Phyloseq object with Blast taxonomy data
tax_table(phsq_ob) <- tax_mat_new

# get list of PH phylotypes for above - remove PH samples and phylotypes
asv_table <- as_tibble(as(otu_table(phsq_ob), "matrix"), rownames = "iteration_query_def")

# no phylotypes exclusively at PH - filtering necessary to port counts
ph_asv <- asv_table %>% filter(., select(., contains("PH")) > 0 ) %>% select("iteration_query_def")

# no phylotypes exclusively at PH - no filtering necessary to modify counts

asv_table %>% filter(., select(., contains("PH")) > 0 ) %>% filter(., select(., -contains("PH")) == 0) 


# Part II c: Plotting data
# -----------------------------------
# Melt dataframe and do yourself
# ( in plot call abundances are aggregated in-call to avoid jagged edges)


# agglomerate on phylum level to avoid jagged barplots 
phsq_ob <- tax_glom(phsq_ob, taxrank = rank_names(phsq_ob)[2], NArm=FALSE, bad_empty=c(NA))

# remove PH samples
phsq_ob_lng <- psmelt(phsq_ob)
phsq_ob_lng <- phsq_ob_lng %>% arrange(Sample, desc(Abundance)) %>% filter(Facility != c("PH"))

ggplot(phsq_ob_lng, aes_string(x = "phylum", y = ave(phsq_ob_lng$Abundance, phsq_ob_lng$phylum, FUN=sum), fill = "phylum")) +
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

ggsave("200714_all_phyla_at_all_ports.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 3, width = 75, height = 100, units = c("mm"),
         dpi = 500, limitsize = TRUE)
