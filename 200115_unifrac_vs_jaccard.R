#' ---
#' title: "UUnifrac and Jaccard relationship."
#' author: "Paul Czechowski"
#' date: "15-Jan-2020"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---
#' 
#' # Preface
#' 
#' _"To be confident that UNIFRAC (phylogenetic based) is an appropriate
#'  biodiversity metric for our purposes, we need to show that it correlates with
#'  more conventional and intuitive biodiversity metrics, Jaccard index (species 
#'  based). We need to see a graph like the one below, based on port data (not 
#'  sample data). If our ports fall in the region where UNIFRAC asymptotes, we’ll
#'  need to think about using Jaccard or some other index instead, or multiple 
#'  indices. The sooner we get this nailed down, the better. We need to see a 
#'  plot like the one below (not just correlation statistics) for all of our port 
#'  pairs.  (As decided previously for later analyses, I believe we need this 
#'  including and excluding Pearl Harbor.)"_ (D.L. 14.01.2020)
#' 
#' # Prepare Environment
#'
#' ## Empty buffer
rm(list=ls())

#'
#' ## Package loading 
library("data.table") # enhanced version of data.frame for fast data manipulations. 
library("tidyverse")  # for data handling and graphing
library("magrittr")   # setting row names during conversion from Tibble to Matrix

#' ## Functions
#'

#' Use functions from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

#' ## Data read-in
#'
#' Read in ASV tables (Unifrac and Jaccard). Paths defined in list are distance 
#  matrices for ports samples, without controls
#' samples, as described by the file name (and probably should match what is in 
#' file `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh`)

paths <- list(
  "/Users/paul/Documents/CU_combined/Zenodo/Qiime/185_eDNA_samples_Eukaryotes_core_metrics_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv",
  "/Users/paul/Documents/CU_combined/Zenodo/Qiime/190_18S_eDNA_samples_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv"
  )

dist_list_raw <- lapply(paths, read_tsv)

#' ## Data formatting
#' 
#' Convert raw data to matrix with row- and colnames for speed reasons.
dist_list_mat <- lapply(dist_list_raw, function(mat) mat %>% set_rownames(.$X1) %>% select(-X1) %>% as.matrix)

#' Create port-wise collapsed, but empty receiving matrices from input list ...
dist_list_mat_collapsed <- lapply(dist_list_mat, get_collapsed_responses_matrix)

#' ... and fill these matrices with values. 
dist_list_mat_collapsed <- mapply(fill_collapsed_responses_matrix, dist_list_mat_collapsed, dist_list_mat, SIMPLIFY = FALSE)

#' Getting data for plotting, modified from section `Getting Dataframes for modelling`
#' of script `~/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R`.

# set names
dist_list_mat_collapsed <- setNames(dist_list_mat_collapsed, c("UNIFRAC", "JACCARD"))

# are all matrix dimesions are the same?
var(c(sapply (dist_list_mat_collapsed, dim))) == 0

# are all matrices symmetrical and have the same rownames and column names?
all(sapply (dist_list_mat_collapsed, rownames) == sapply (dist_list_mat_collapsed, colnames))

# flatten matrices, while keeping port identifiers
dist_df_collapsed <- lapply(dist_list_mat_collapsed, function(x) data.frame(x) %>% rownames_to_column("PORT") %>% reshape2::melt(., id.vars = "PORT"))

# join dataframes and name columns
dist_df_collapsed <- dist_df_collapsed %>% reduce(inner_join, by = c("PORT", "variable")) %>% setNames(c("PORT.A", "PORT.B", toupper(names(dist_df_collapsed))))

# remove incomplete cases - thereby ignoring lower diagonal half of input matrices matrices
dist_df_collapsed <- dist_df_collapsed %>% filter(complete.cases(.))

#' ## Plotting

dist_df_collapsed
