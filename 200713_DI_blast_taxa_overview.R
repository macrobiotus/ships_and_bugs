# Get graphical representation of detected taxa
# =============================================
# akin to 
# E. E. Sigsgaard, F. Torquato, T. G. Frøslev, A. B. M. Moore, J. M. Sørensen, 
#   P. Range, R. Ben‐Hamadou, S. S. Bach, P. R. Møller, P. F. Thomsen, Using 
#   vertebrate environmental DNA from seawater in biomonitoring of marine 
#   habitats. Conserv. Biol. 34, 697–710 (2020). 


rm(list=ls(all=TRUE)) # clear memory

library("tidyverse")  # work using tibbles
library("ggrepel")
library("data.tree")  # https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html
library("reshape2")   # long data frames for ggplot

# Part I: Load Blast results and read counts
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

# Part II: Sort data for summary purposes
# ---------------------------------------
# - by abundance
# - possibly aggregate taxa

# remove 3 Bacterial ASVs - **report those: mismatch between NCBI and SILVA taxonomy assignment
BlRsSbsDfJn <- BlRsSbsDfJn %>% filter(superkingdom == "Eukaryota")

# sort by read count
BlRsSbsDfJn <- BlRsSbsDfJn %>% arrange(desc(count))

# get number of distinct eukaryote species, orders 
BlRsSbsDfJn %>% distinct(species) %>% na.omit %>% nrow # 3171 distinct species
BlRsSbsDfJn %>% distinct(order) %>% na.omit %>%  nrow # 418 distinct orders
BlRsSbsDfJn %>% distinct(class) %>% na.omit %>% nrow # 134 distinct classes
BlRsSbsDfJn %>% distinct(phylum) %>% na.omit %>% nrow # 40 distinct phyla

# inspect data subset - taxonomy columns of 12 most abundant species
BlRsSbsDfJn %>% select(superkingdom, phylum, class, order, family, genus, species, count, src) %>% print (n = 12)

# subset for species plot
Top12Spec <- BlRsSbsDfJn %>% slice_max(count, n = 12)   # %>% select(superkingdom, phylum, class, order, family, genus, species, count, src) %>% print

# correct one name staring
Top12Spec$species[which(Top12Spec$species == "Pelagostrobilidium sp. LS781")] <- "Pelagostrobilidium sp."

Top12Spec$species <- paste(Top12Spec$species, "\n(", Top12Spec$class,")", sep ="")

Top12Spec$species[10]

# continue here with order aggregation and sorting


# Part III: Format data for plotting
# ----------------------------------

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

# 12 most common orders
