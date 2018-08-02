#' ---
#' title: "Check OTU Accumulation Across Samples"
#' author: "Paul Czechowski"
#' date: "August 3 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_33_draw_otus_per_sample.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.

# empty buffer
# ============
rm(list=ls())

# setting file export paths
# =========================
# - none so far - 

# load packages
# =============
library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("tidyverse")    # metapackage 
                        #   for blast table modification and lookups
                        #   for `rownames_to_column` and `column_to_rownames`
library("vegan")        # species accumulation curve

# functions
# ==========
# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

# data read-in
# ============

# Phyloseq
# --------

# Target these paths to the Qiime1 exported biom file with metadata and the
#   matching fasta file.
biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/250_18S_097_cl_edna_biom_export/features-tax-meta.biom"
sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/250_18S_097_cl_edna_biom_export/dna-sequences.fasta"
tree_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_tree_mdp_root.qza"

# Creation of this objects lets us take advantage of the Phyloseq's 
#  functionality 
phsq_ob <- get_phsq_ob(biom_path, sequ_path, tree_path)

# data formatting
# ================

# Phyloseq
# --------
phsq_ob <- remove_empty(phsq_ob) # NO EFFECT, AS EXPECTED

# Get a list of Phyloseq objects in which each object only contains samples
#   from one sampling location. Matching of samples is done by the first two 
#   characters of the sample name.
phsq_list <- get_phsq_list(phsq_ob)

# Extract OTU tables from Phyloseq object list and, in list, store as data 
#  frames, to enable working on OTU tables.
df_list <- lapply (phsq_list, get_df_from_phsq_list)

# Extract number of sampled ports and port identifiers to set plot dimensions
#   and have plot names
prt_number <- length(df_list)
prt_names  <- names(df_list)

# Calculate species accumulation curves and store in data frame list 
#   for plotting
df_list <- lapply (df_list, function(x) specaccum( t(x), method = "exact", permutations = 100,
                       conditioned = TRUE, gamma = "jack1"))

# Plot Object
par(mfrow=c(3,3))
lapply (df_list, function(x) plot(x, add = FALSE, ci.type = "polygon", 
                                  col= "blue", lwd=2, ci.lty=0, 
                                  ci.col="lightblue", 
                                  xlab = "Water Samples At Port",
                                  ylab = "Number Observed OTUs")
                                  )

#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
