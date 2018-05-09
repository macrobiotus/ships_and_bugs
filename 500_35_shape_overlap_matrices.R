#' ---
#' title: "Create Kulczynski distance matrices to encode overlapping taxa among port pairs"
#' author: "Paul Czechowski"
#' date: "May 7th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_35_shape_overlap_matrices.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.

# empty buffer
# ============
rm(list=ls())

# setting file export paths
# =========================
image_path <- "/Users/paul/Box Sync/CU_NIS-WRAPS/170728_external_presentations/171128_wcmb/180429_wcmb_talk/500_35_shape_overlap_matrices__eullerr.png"
matrx_path <- "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_35_shape_overlap_matrices__output__97_overlap_kulczynski_mat_all.Rdata"
matrx_ovrlp_path <- "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_35_shape_overlap_matrices__output__97_overlap_kulczynski_mat_dual.Rdata"
# load packages
# =============
library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("biomformat")   # perhaps unnecessary
library("tidyverse")    # metapackage 
                        #   for blast table modification and lookups
                        #   for `rownames_to_column` and `column_to_rownames`
                        
library("eulerr")    # euler diagram
library("qualpalr")  # euler diagram colour palette
library("prabclus")  # also for euler diagram, perhaps unnecessary

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

biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/250_18S_097_cl_edna_biom_export/features-tax-meta.biom" # TEST DATA
sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/250_18S_097_cl_edna_biom_export/dna-sequences.fasta" # TEST DATA
tree_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/100_18S_tree_mdp_root.qza" # UNCLUSTUSTERED TREE

# Creation of this objects let's us take advantage of the Phyloseq's 
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

# Extract OTU tables from Phyloseq object list and store as data frames...
df_list <- lapply (phsq_list, get_df_from_phsq_list)

# ...get row sums - summing observations per OTU across multiple samples per port.. 
df_list <- lapply (df_list, rowSums)

# ... combining list elements to matrix. Using `do.call` since name checking is
#   to be done ...  
# If this is to slow rbindlist can be used:  https://stackoverflow.com/questions/5187794/can-i-combine-a-list-of-similar-dataframes-into-a-single-dataframe.
df_ports <- do.call("cbind", df_list)

# ... convert to logical (needed for Eulerr) ...
mat <- apply (df_ports, 2, as.logical)
# ... cary names over ...
colnames(mat) <- colnames(df_ports)
rownames(mat) <- rownames(df_ports)

# diagnostic Eulerr graph 
# -----------------------

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

## plot for Euler diagram...
plot (fit2, main = "OTU counts and overlap between ports", quantities = TRUE)

# ... and save
png(file = image_path, width = 3, height = 3, units = "in", pointsize = 20, res = 200)
    plot (fit2, main = "OTU counts and overlap between ports", quantities = TRUE)
dev.off()

# overlap summary by Eulerr package - `original` are the same counts that are
#  used below, `fitted` are shown quantities in graphic 
##  fit2

# format matrices
# ---------------

# 02.05.2018: for cumulative abundance sorting of OTUs - scale OTU counts to range
#  0-1 per sample, then add percentages per sample across rows
df_counts <- as.data.frame(sweep(df_ports, 2, colSums(df_ports),`/`))
df_counts$SUM_norm <- rowSums(df_counts)
df_counts <- df_counts %>% rownames_to_column("OTU")


# conversion to use dplyr functions.
bin_df_raw <- data.frame(mat)

# sorting tibble - full data - needed for later (and for matrix generation in other?
#  script)
bin_df_full <- bin_df_raw %>% rownames_to_column("OTU") %>%
                              group_by(.dots = names(bin_df_raw))  %>%
                              add_count(.dots = names(bin_df_raw)) %>%
                              arrange(desc(n), .by_group = TRUE)

# Remove non-overlapping OTUs and sort again
bin_df_ovrl <- bin_df_full[which(rowSums(bin_df_full[3:length(names(bin_df_full))-1]) >=2), ] %>%
               group_by(.dots = names(bin_df_full[3:length(names(bin_df_full))-1]))  %>%
               arrange(desc(n)) %>% ungroup()

# Join in count variables to get abundance information during sorting.
bin_df_ovrl <- bin_df_ovrl %>% left_join(df_counts, bin_df_ovrl, by = "OTU", copy = FALSE, suffix = c("_logic", "_norm")) 

# matrix can be generated with this information
bin_df_ovrl

# data output
# ===========

# For now using Kulczynski distances between as ports done in `eulerr()` code above
#  (and used in the `eulerr()` manual): This might be the most straight forward
#  way of handling cases where more then one port has shared species.

kulczynski_mat_all <- kulczynski(mat)
colnames(kulczynski_mat_all) <- colnames(df_ports)
rownames(kulczynski_mat_all) <- colnames(df_ports)
kulczynski_mat_all
save (kulczynski_mat_all, file = matrx_path)

# Also getting overlap
kulczynski_mat_ovrlp <- kulczynski(mat [ which (rowSums(mat[  , 1:ncol(mat)]) == 2 ), ])
colnames(kulczynski_mat_ovrlp) <- colnames(df_ports)
rownames(kulczynski_mat_ovrlp) <- colnames(df_ports)
kulczynski_mat_ovrlp
save (kulczynski_mat_ovrlp, file = matrx_ovrlp_path)

#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
