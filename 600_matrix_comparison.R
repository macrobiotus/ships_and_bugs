#' ---
#' title: "Compare Unifrac and Risk distance matrices and validate using permutation test"
#' author: "Paul Czechowski"
#' date: "April 17th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/600_matrix_comparison.R")`.
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


# read in Risk distance matrix (predictors)
# --------------------------------------------
p_path <- "/path/to/predictor/matrix.tsv"

# read in Unifrac distance matrix (responses)
# -------------------------------------------

# this path should match the parameter combination of the Euler script
r_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/245_18S_097_cl_edna_core_metrics/distance-matrix.tsv"
r_mat <- read.table(file = r_path, sep = '\t', header = TRUE)

# data formatting
# ================

# format Unifrac distance matrix (responses)
# -------------------------------------------

# substitute dots `.` in column headers with minus `-` to match ro names
colnames(r_mat) <- gsub( '\\.' , '-', colnames(r_mat)) 

# set row-names correctly 
rownames(r_mat) <- r_mat$X; r_mat$X <- NULL

# check row and column formatting - better to have them equal 
colnames(r_mat) == rownames(r_mat)

# convert matrix from dissimilarity to similarity ( dissim(x,y) = 1 - sim(x,y))
r_mat <- apply (r_mat, 1, function(x) 1-x)


# format Risk distance matrix (predictors)
# -------------------------------------------

# expand matrix dimensions to match response matrix dimension

# (adjust row-names and column names ?)


# data analysis
# =============

# test correlation of matrices after vectorisation


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
