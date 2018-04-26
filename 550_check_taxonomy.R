#' ---
#' title: "Parse Blast output for overlapping taxa"
#' author: "Paul Czechowski"
#' date: "April 26th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/550_check_taxonomy.R")`.
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
library("dplyr")        # for blast table modification and lookups

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

# ... combining list elements to data frame. Using `do.call` since name checking is
#   to be done ...  
# If this is to slow rbindlist can be used:  https://stackoverflow.com/questions/5187794/can-i-combine-a-list-of-similar-dataframes-into-a-single-dataframe.
df_ports <- do.call("cbind", df_list)

# ... convert to logical (needed for Eulerr) ...
mat <- apply (df_ports, 2, as.logical)

# ... cary names over ...
colnames(mat) <- colnames(df_ports)
rownames(mat) <- rownames(df_ports)


# data analysis
# =============

# get port combinations
# ---------------------
test_mat <- mat[1:100, 1:4]

# Get all possible column name combinations that could have overlap
mat_list <- lapply ( seq( 2,(ncol(test_mat))), function (x)  combn(colnames(test_mat), x ))

# Get header values from columns of each matrix
vec_list <- unlist(lapply(mat_list, function(x) split(x, rep(1:ncol(x), each = nrow(x)))), recursive = FALSE)

# set continues names
names(vec_list) <- seq(length(vec_list))

# fill matrix list with otus from input list
mat_list <- lapply (vec_list, function (x) test_mat[ ,c(x)] )

# `x[ which(apply(x, 1, all)), ]` retunes vector if only on row in the matrix 
#  is returned, and the column names vor vectors are dropped. Need conversion
#  to data frame.
df_list <- lapply (mat_list, data.frame )

# remove non-overlapping taxa. The same approach works fine for data frames.
df_list <- lapply (df_list, function (x) x[ which(apply(x, 1, all)), ] )

# output taxa for port combinations
# ----------------------------------

# Set names to see port combinations
names(df_list) <- lapply (names(df_list), function(x) paste(names(df_list[[x]]), sep = " ") )
names(df_list) <- gsub("^c\\(|\\)$", "", names(df_list))

# fill list
lapply (df_list, function(x) data.frame(edna_tab %>% filter (qseqid %in% c(rownames(x)))))


#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
