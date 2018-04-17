#' ---
#' title: "Euler graphs from amplified port water DNA"
#' author: "Paul Czechowski"
#' date: "April 12th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/550_euler.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#'
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
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

library("eulerr")    # euler diagram
library("qualpalr")  # euler diagram colour palette
library("prabclus")  # also for euler diagram, perhaps unnecessary

# functions
# ==========
# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_functions.R")

#'
#' <!-- #################################################################### -->

#' <!-- #################################################################### -->
#'

# data read-in
# ============

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

phsq_ob <- remove_empty(phsq_ob) # NO EFFECT, AS EXPECTED


# data formatting
# ================

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

# generate colour palette
pal <- qualpal(n = ncol(df_ports), colorspace = "pretty", cvd = "deutan", cvd_severity = 0.8)
# plot(pal) # one can check the colors here

# fit plot
fit2 <- euler(mat)

# Cleveland dot plot of the residuals
# dotchart(resid(fit2))
# abline(v = 0, lty = 3)

# dissimilarity between replicates
kulczynski(mat)

# Combine figures

## window for Euler diagram
par (fig = c(0.3,1, 0,0.5), new=TRUE) 

## plot for Euler diagram
plot (fit2, main = "OTU counts and overlap between ports", quantities = TRUE)

#'
#' <!-- #################################################################### -->

#' <!-- #################################################################### -->
#'
#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
