#' ---
#' title: "Compare Unifrac and Risk distance matrices and validate using permutation test"
#' author: "Paul Czechowski"
#' date: "April 19th, 2018"
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
p_path <- "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_get_predictor_risk_matrix__output_risk_matrix.Rdata"
load(p_path); p_mat <- r_mat; rm(r_mat) # DO ERASE `r_mat` THIS NAME IS USED BELOW

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
      slctd_mat[lower.tri(slctd_mat, diag = TRUE)] <- NA   # although diagonal is defined with 
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

### FILLER CODE IS BUGGY

p_mat[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")] # quick and dirty - manual lookup
                                                         # use order order of response matrix (!!!)
                                                        # here "PH","SP","AD","CH"
                                                        # improve (!!!)
                                                        # `open /Users/paul/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`

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
