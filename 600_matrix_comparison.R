#' ---
#' title: "Compare Unifrac and Env (not Risk yet) distance matrices and validate using permutation test"
#' author: "Paul Czechowski"
#' date: "April 19th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' Only ports with trips can be compared - this script version only tests the influence of environmental data.
#' With or without the influence of other factors.
#'
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
library("permute")

# functions
# ==========
# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

#'
#' <!-- #################################################################### -->

#' <!-- #################################################################### -->
#'

# data read-in
# ============

# read in Risk distance matrix (predictors)
# --------------------------------------------

# path to full risk matrix - needs to filtered and then should give upper triangle
#  of symmetrical matrix, all with Invasion Risk vales
#   filler code buggy using env distance alone - should be useful to test 0 hypothesis
#   check commit message `8bffcbaaadb7267fbcefa9895aab186c1dbbebd6` and notes 19.04.2018

# with risks:
# p_path <- "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_get_predictor_risk_matrix__output_risk_matrix.Rdata"

# without risks:
p_path <- "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata"
load(p_path); p_mat <- mat_env_dist_full; rm(mat_env_dist_full) # DO ERASE `r_mat` THIS NAME IS USED BELOW - names updated 24.4.2018

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
any(colnames(r_mat) == rownames(r_mat))

# convert matrix from dissimilarity to similarity ( dissim(x,y) = 1 - sim(x,y))
# r_mat <- apply (r_mat, 1, function(x) 1-x)

# Create empty receiving matrix ...
r_mat_clpsd <- get_collapsed_responses_matrix_empty(r_mat)

#   ... and stor rownames and column names....
rnclpsd <- rownames(r_mat_clpsd)
cnclpsd <- colnames(r_mat_clpsd)

#   ..fill empty receiving matrix ...
for (i in 1:nrow(r_mat_clpsd)){
  for (j in 1:ncol(r_mat_clpsd)){
    
    # debugging only 
    #  print(rnclpsd[i])
    #  print(cnclpsd[j])
    
    # average across matrix elements
    slctd_rows <- which ( substr (rownames (r_mat), start = 1, stop = 2) %in% rnclpsd[i]) # 
    slctd_cols <- which ( substr (colnames (r_mat), start = 1, stop = 2) %in% cnclpsd[j]) # 
    slctd_mat <- as.matrix(r_mat[c(slctd_rows), c(slctd_cols)]) # necessary for vectorisation
    
    # edge case - use only upper triangle for matrix calculation if source ports are the same
    if (rnclpsd[i] == cnclpsd[j]) {
      slctd_mat[lower.tri(slctd_mat, diag = TRUE)] <- NA  # although diagonal is defined with 
                                                           # "0" distance also setting diag to TRUE
                                                           # ( excluded) so that average isn't
                                                           # lowered by the number of replicates
                                                           # per port.
    }
    
    slctd_ave <- mean(slctd_mat, na.rm = TRUE) # na.rm = TRUE for edge cases, those will otherwise be NA
                                               #  but they do have a signal so can't NA
    
    # debugging only 
    #  print(slctd_ave)
   
   # fill collapsed matrix 
   r_mat_clpsd[rnclpsd[i], cnclpsd[j]] <- slctd_ave
  
  }
}

#   ...keep only upper triangle of matrix...
r_mat_clpsd[lower.tri(r_mat_clpsd,diag = FALSE)] <- NA 

#   ...check receiving matrix.  
r_mat_clpsd 
  

# format Risk distance matrix (predictors)
# -------------------------------------------

# filter matrix dimensions to match response matrix dimension:
#  .. discard completely undefined rows and columns (this shrinks the matrix
#  substantially, check via dim() if needed!)
p_mat <- p_mat[rowSums(is.na(p_mat))!=ncol(p_mat), colSums(is.na(p_mat))!=nrow(p_mat) ]

### FILLER CODE IS BUGGY WHEN RISK IS ASSOCIATED - check commit message `8bffcbaaadb7267fbcefa9895aab186c1dbbebd6`
#### and notes 19.04.2018

p_mat_xtr <- p_mat[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")] # quick and dirty - manual lookup
                                                         # use order order of response matrix (!!!)
                                                        # here "PH","SP","AD","CH"
                                                         # improve (!!!) this and improve risk adding code
                                                        # `open /Users/paul/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`


p_mat_xtr[lower.tri(p_mat_xtr, diag = FALSE)] <- NA

# data analysis
# =============

# predictors - copy names - make automatic !! 
colnames(p_mat_xtr) <- colnames(r_mat_clpsd)
rownames(p_mat_xtr) <- rownames(r_mat_clpsd)
p_mat_xtr

# response
r_mat_clpsd

#' Matrix structure is irrelevant and arbitrary - matrices can be dissolved into vectors:
rvec <- c(p_mat_xtr) # r = risk  - here environmental distance, later risk  - DIRTY
dvec <- c(r_mat_clpsd)  # d = distance - biological data - Unifrac -  response - DIRTY

rvec
dvec


#' # Data analysis 1 - correlation and _p_ value
#' 
#' Correlation and p-value based on Kendall (non-normal data):
# correlation
cor(rvec, dvec, use = "pairwise.complete.obs", method = "kendall") 
# "greater" corresponds to positive association,
cor.test(rvec, dvec, method = "kendall", alternative = "greater") 


#' # Data analysis 2 - correlation and permutation test 
#' 

perm_risk <- numeric(length = 10000) # create vector to store results, 
                                     #   with length equal to the amount of
                                     #   permutations
n = length(rvec)                     
set.seed(42)

#' Fill vector `perm_risk` with correlations between permuted risk vector and
#' vector containing biological species dissimilarities. 
#' Loop over integer vector with length of permutations.
for (i in seq_len(length(perm_risk) - 1)) {

     # create and store permuted vector indices to shuffle real data one line
     #   below
     perm1 <- shuffle(n)
     perm2 <- shuffle(n)
     
     # fill vector of defined length loop-by-loop  
     perm_risk[i] <- cor(rvec[perm1], dvec[perm2], use = "pairwise.complete.obs", method = "kendall")
  }


#' Fill vector `perm_risk` with correlations between measured risk vector and
#'  vector containing biological species dissimilarities.
perm_risk[length(perm_risk)] <- cor(rvec, dvec, use = "pairwise.complete.obs", method = "kendall") 

#' unshuffeled "true" correlation for input data:
perm_risk[length(perm_risk)]

#' ** DIRTY - Erase this later - lines can't be drawn some reason**
perm_risk[which(is.na(perm_risk))] <- 0

#' Show results graphically - see red dot of x-axis.
hist (perm_risk, 
      main = "Environmental Distance and Shuffled Correlations",
      sub = "Correlation between Environmental Distance and Biologic Site Similarity",
      xlab = "Correlation", 
      breaks = 75, 
      prob=TRUE)
lines(density(perm_risk))
lines(density(perm_risk, adjust=2), lty="dotted", col="darkgreen", lwd=2) 
rug(perm_risk[length(perm_risk)], col = "red", lwd = 5)

#' Count random correlations that are as high as the non-random one.
h_corr <- sum(perm_risk >=  perm_risk[length(perm_risk)])

#' Permutational _p_-value:
h_corr / length (perm_risk)

#' Slight evidence against the null hypothesis of no correlation between environmental
#' distance calculated by environmental variables and environmental distance estimated
#' by biological signal.
#' 
#'
#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
