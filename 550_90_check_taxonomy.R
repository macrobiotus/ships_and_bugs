#' ---
#' title: "Parse Blast Output to show Overlapping Taxa"
#' author: "Paul Czechowski"
#' date: "May 7nd, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/550_90_check_taxonomy.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#'

# empty buffer
# ============
rm(list=ls())

# load packages
# =============
library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("biomformat")   # perhaps unnecessary
library("tidyverse")    # metapackage 
                        #   for blast table modification and lookups
                        #   for `rownames_to_column` and `column_to_rownames`

# functions
# ==========
# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

# data read-in
# ============

# Blast
# -----

# Define paths to blast results
edna_blast_path <- "/Users/paul/Documents/CU_combined/Zenodo/Blast/270_18S_097_cl_cntrl_biom_export_fasta_blast/blastn_results.txt"
ctrl_blast_path <- "/Users/paul/Documents/CU_combined/Zenodo/Blast/270_18S_097_cl_edna_biom_export_fasta_blast/blastn_results.txt"

# Read in Blast data (must match parameter combination).
edna_blast_tab <- read.table(edna_blast_path, sep = '\t', quote = "", 
                             stringsAsFactors = FALSE, header = FALSE)

# Phyloseq
# --------

# Target these paths to the Qiime1 exported biom file with metadata and the
#   matching fasta file.

biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/250_18S_097_cl_edna_biom_export/features-tax-meta.biom" # TEST DATA
sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/250_18S_097_cl_edna_biom_export/dna-sequences.fasta" # TEST DATA
tree_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_tree_mdp_root.qza" # UNCLUSTUSTERED TREE

# Creation of this objects let's us take advantage of the Phyloseq's 
#  functionality 
phsq_ob <- get_phsq_ob(biom_path, sequ_path, tree_path)

# data clean
# ==========

# Blast
# -----

# set column names as to match script `/Users/paul/Documents/CU_combined/Github/270_blast_clusters.sh` 
#    ommiting "gapope", which seems to be missing from the file
colnames(edna_blast_tab) <- c("qseqid", "sseqid", "pident", "qlen",  "length",
                               "mismatch", "evalue", "bitscore", "sscinames",
                               "scomnames")

# Phyloseq
# --------
phsq_ob <- remove_empty(phsq_ob) # NO EFFECT, AS EXPECTED


# data formatting
# ================

# Blast
# -----

# get a unique table of queries, with highest bitscore, number of ties is 
#   preserved, for later checking
edna_tab <-  edna_blast_tab %>% group_by(qseqid) %>% top_n(., n = 1, wt = bitscore) %>%
                   add_count(qseqid) %>% slice(1) %>% ungroup


# Phyloseq
# --------

# Get a list of Phyloseq objects in which each object only contains samples
#   from one sampling location. Matching of samples is done by the first two 
#   characters of the sample name.
phsq_list <- get_phsq_list(phsq_ob)

# Extract OTU tables from Phyloseq object list and store as data frames...
df_list <- lapply (phsq_list, get_df_from_phsq_list)

# ...get row sums - summing observations per OTU across multiple samples per port.. 
df_list <- lapply (df_list, rowSums)

# ... combining list elements to matrix. Using `do.call` since name checking is
#   to be done ...  
# If this is to slow rbindlist can be used:  https://stackoverflow.com/questions/5187794/can-i-combine-a-list-of-similar-dataframes-into-a-single-dataframe.
df_ports <- do.call("cbind", df_list)

# 02.05.2018: for cumulative abundance sorting of OTUs - scale OTU counts to range
#  0-1 per sample, then add percentages per sample across rows
df_counts <- as.data.frame(sweep(df_ports, 2, colSums(df_ports),`/`))
df_counts$RWSUM <- rowSums(df_counts)
df_counts <- df_counts %>% rownames_to_column("qseqid")

# ... convert to logical (needed for Eulerr) ...
mat <- apply (df_ports, 2, as.logical)
# ... cary names over ...
colnames(mat) <- colnames(df_ports)
rownames(mat) <- rownames(df_ports)

# results table
# -------------

# conversion to use dplyr functions.
bin_df_raw <- data.frame(mat)

# sorting tibble - full data - needed for later (and for matrix generation in other?
#  script)
bin_df_full <- bin_df_raw %>% rownames_to_column("qseqid") %>%
                              group_by(.dots = names(bin_df_raw))  %>%
                              add_count(.dots = names(bin_df_raw)) %>%
                              arrange(desc(n), .by_group = TRUE)

# Remove non-overlapping OTUs and sort again
bin_df_ovrl <- bin_df_full[which(rowSums(bin_df_full[3:length(names(bin_df_full))-1]) >=2), ] %>%
               group_by(.dots = names(bin_df_full[3:length(names(bin_df_full))-1]))  %>%
               arrange(desc(n)) %>% ungroup()

# Join in count variables to get abundance information during sorting.
bin_df_ovrl <- bin_df_ovrl %>% left_join(df_counts, bin_df_ovrl, by = "qseqid", copy = FALSE, suffix = c("_LGC", "_SPERC")) 



# Join in taxonomic string, bit score and redundancy count, if any.
bin_df_ovrl <- bin_df_ovrl %>% left_join(edna_tab, by = "qseqid", copy = TRUE,
                                        suffix = c("_A", "_B")) #  %>% print(n = nrow(.))


# Sort by bitscore
bin_df_ovrl %>% arrange(desc(bitscore)) # %>% print(n = nrow(.))

# write results
# -------------

write_csv(bin_df_ovrl, path = "/Users/paul/Documents/CU_combined/DI_R_tables/550_90_check_taxonomy__output__blast_results.csv")
write_csv(bin_df_ovrl, path = "/Users/paul/Box Sync/CU_NIS-WRAPS/170728_external_presentations/171128_wcmb/180429_wcmb_talk/550_90_check_taxonomy__output__blast_results.csv")

#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
