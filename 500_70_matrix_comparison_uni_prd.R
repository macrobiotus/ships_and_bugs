#' ---
#' title: "Compare Unifrac and predictor value matrices and validate using permutation test"
#' author: "Paul Czechowski"
#' date: "April 25th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---
#' 
#' This script version tests the  influence of environmental data with and 
#' without the influence of voyages against biological responses. This script
#' only considers port in between which routes are present, such ports are
#' fewer the ports which have environmental distances available. (All ports 
#' with measurements have environmental distances available.)
#'
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_70_matrix_comparison_uni_prd.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#' 
#' # Environment preparation
#'
# empty buffer
# ============
rm(list=ls())

# load packages
# =============
library ("gdata")   # matrix functions

# functions
# ==========
# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

#' # Data read-in
#'
#' ## Predictors - environmental distances influenced by voyages
#'
#' This data is only available for ports in between which voyages exist.
#' Formula is currently `(log(src_heap$ROUT$TRIPS) + 1) * (1 / src_heap$ROUT$EDST)`
#' as defined in `500_30_shape_matrices.R`.

# loading matrix with risks
load("/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata")

# checking 
mat_risks[1:11,1:11]

#' ## Predictors - environmental distances alone
#'
#' This data is available for many ports (more ports then shipping routes)
load("/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata")

# checking -- see debugging notes: some port numbers in row-/colnames are not unique
mat_env_dist_full[1:11,1:11]

#' ## Responses - Unifrac distance matrix as produced by Qiime 2
#'

# this path should match the parameter combination of the Euler script
resp_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/245_18S_097_cl_edna_core_metrics/distance-matrix.tsv"
resp_mat <- read.table(file = resp_path, sep = '\t', header = TRUE)

# checking
resp_mat[1:11,1:11]
class(resp_mat)

#' # Data formatting 
#' 
#' ## Responses - Unifrac distance matrix as produced by Qiime 2
#'
#' Need to be done before the predictors: Matrix fields need to be averaged
#' across replicates. The resulting ports descriptors are then used to shape
#' predictor data. Inverting Unifrac distances to closeness in order to match 
#' `(1 / src_heap$ROUT$EDST)`, which also is a measure of closeness.

# substitute dots `.` in column headers with minus `-` to match row names
colnames(resp_mat) <- gsub( '\\.' , '-', colnames(resp_mat)) 

# set data frame row-names correctly 
rownames(resp_mat) <- resp_mat$X; resp_mat$X <- NULL

# check data frame row and column formatting - better to have them equal 
any(colnames(resp_mat) == rownames(resp_mat))


# Create empty receiving matrix from data frame ...
r_mat_clpsd <- get_collapsed_responses_matrix(resp_mat)

# ... and fill empty receiving matrix. 
r_mat_clpsd <- fill_collapsed_responses_matrix(r_mat_clpsd, resp_mat)

# convert matrix from dissimilarity to similarity ( dissim(x,y) = 1 - sim(x,y))
#  this also requires moving lower triangle to upper triangle, and resetting the
#  lower tiangle. 
r_mat_clpsd <- apply (r_mat_clpsd, 1, function(x) 1-x)

upperTriangle(r_mat_clpsd) <- lowerTriangle(r_mat_clpsd, byrow=TRUE)

r_mat_clpsd[lower.tri(r_mat_clpsd, diag = FALSE)] <- NA

#' Finished matrix - Unifrac closeness
r_mat_clpsd

#'
#' ## Predictors - environmental distances influenced by voyages
#' 

# to save memory: discard completely undefined rows and columns (shrinks from
#  6651 * 6651 to 2332 * 2332
mat_risks <- mat_risks[rowSums(is.na(mat_risks))!=ncol(mat_risks), colSums(is.na(mat_risks))!=nrow(mat_risks) ]

# quick and dirty - manual lookup
#   use order  of response matrix (!!!)
#   here "PH","SP","AD","CH"
#   improve (!!!) this. Manual lookup via:
#   `open /Users/paul/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`
mat_risks <- mat_risks[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")] 

mat_risks[lower.tri(mat_risks, diag = FALSE)] <- NA

# predictors - copy names - make automatic !! 
colnames(mat_risks) <- colnames(r_mat_clpsd)
rownames(mat_risks) <- rownames(r_mat_clpsd)

#' Finished matrix - Risks. Needs to be used to filter both other matrices
#' (Other predictors and responses) to the same non-`NA` before (during) vectorisation.
mat_risks

#'
#' ## Predictors - environmental distances alone
#'

# quick and dirty - manual lookup - as above 
#   use order  of response matrix (!!!)
#   here "PH","SP","AD","CH"
mat_env_dist <- mat_env_dist_full[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")] 

#' Convert distances to closeness in order to comply with formula part `(1 / src_heap$ROUT$EDST)`
mat_env_dist <- 1/mat_env_dist

# Keep only upper triangle
mat_env_dist[lower.tri(mat_env_dist, diag = FALSE)] <- NA

# predictors - copy names - make automatic !! 
colnames(mat_env_dist) <- colnames(r_mat_clpsd)
rownames(mat_env_dist) <- rownames(r_mat_clpsd)

#' Finished matrix - Inverted environmental distances. Needs to be filtere
#' to match predictors influenced by available voyages during vectorisation.
mat_env_dist

#'
#' ## Checking and vectorisation
#'

# create named list with objects
mat_list <- list (r_mat_clpsd, mat_risks, mat_env_dist) 
setNames(mat_list, c("resp", "risks", "envs"))

# Are all matrix dimesions are the same?
var(c(sapply (mat_list, dim))) == 0

# Are all matrices symmetrical and have the same rownames and column names
all(sapply (mat_list, rownames) == sapply (mat_list, colnames))

# get data frame
vec_list <- lapply(mat_list, c)
vec_df <- as.data.frame(do.call(cbind, vec_list))
vec_df <- setNames(vec_df, c("resp", "risks", "envs"))

# keep only values for which risks are available 
vec_df <-  vec_df [complete.cases( vec_df[ , "risks"]), ]


#' Finished data frame
vec_df

#' # Data analysis 1 - correlation and _p_ value
#' 
#' Correlation and p-value based on Kendall (non-normal data):
# correlation
cor(vec_df$resp, vec_df$risks, use = "pairwise.complete.obs", method = "kendall") 
cor(vec_df$resp, vec_df$envs, use = "pairwise.complete.obs", method = "kendall") 

# "greater" corresponds to positive association -- ties: "0" Unifrac distance is still 
#  correlated with several different environmental distances:
cor.test(vec_df$resp, vec_df$risks, method = "kendall", alternative = "greater") 
cor.test(vec_df$resp, vec_df$envs, method = "kendall", alternative = "greater") 

#' # Data analysis 2 - correlation and permutation test 
#' 
#' Creating permutation test objects
set.seed(42)
resp_vs_risk <- shuffle_vectors (vec_df$resp, vec_df$risks, perm = 5000)
resp_vs_envs <- shuffle_vectors (vec_df$resp, vec_df$envs, perm = 5000)

#' unshuffeled "true" correlation for input data:
resp_vs_risk[length(resp_vs_risk)]
resp_vs_envs[length(resp_vs_envs)]

#'
#' ## Show first results graphically -- `resp_vs_risk`
#'
hist (resp_vs_risk, 
      main = "Shuffled Correlations of invasion risk variable and UNIFRAC similarity",
      xlab = "Correlation", 
      breaks = 75, 
      prob=TRUE)
lines(density(resp_vs_risk))
lines(density(resp_vs_risk, adjust=2), lty="dotted", col="darkgreen", lwd=2) 
rug(resp_vs_risk[length(resp_vs_risk)], col = "red", lwd = 5)

#' Count random correlations that are as high as the non-random one.
h_corr <- sum(resp_vs_risk >=  resp_vs_risk[length(resp_vs_risk)])

#' Permutational _p_-value:
h_corr / length (resp_vs_risk)

#'
#' ## Show second results graphically -- `resp_vs_envs`
#'
hist (resp_vs_envs, 
      main = "Shuffled Correlations of environmental distances and UNIFRAC similarity",
      xlab = "Correlation", 
      breaks = 75, 
      prob=TRUE)
lines(density(resp_vs_envs))
lines(density(resp_vs_envs, adjust=2), lty="dotted", col="darkgreen", lwd=2) 
rug(resp_vs_envs[length(resp_vs_envs)], col = "red", lwd = 5)

#' Count random correlations that are as high as the non-random one.
h_corr <- sum(resp_vs_envs >=  resp_vs_envs[length(resp_vs_envs)])

#' Permutational _p_-value:
h_corr / length (resp_vs_envs)

#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
