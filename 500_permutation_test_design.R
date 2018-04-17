#' ---
#' title: "Permutation Test design to evaluate correlations between invasion risk and biological site dissimilarity."
#' author: "Paul Czechowski"
#' date: "April 17th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---
#'
#' # Preface
#'
#' Path names are defined relative  to the project directory. This code 
#' commentary is included in the R code itself and can be rendered at any stage
#' using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_permutation_test_design.R")`. Please check the
#' session info at the end of the document for further notes on the coding environment.
#' 
#' # Background
#'
#' Required is a test to compare two matrices of identical dimensions, the first
#' containing Invasion Risks (continuous data between 1 and 7 of unknown distribution)
#' and Site (Dis)Similarity (retrieved from sequencing data). Permutation testing modified
#' from the vignette of the `permute` package, and can likely be sped up.  
#'
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Prepare Environment

rm(list=ls())
set.seed(42)

#' ## Functions
#'
#' Function to get normal.
get_normal <- function(m){
     (m - min(m))/(max(m)-min(m))
}

#'  This function takes in a matrix and adds some random noise
#'  (from  `https://stats.stackexchange.com/questions/46302/adding-noise-to-a-matrix-vector`)
add_noise <- function(mtx, mini = -0.00001, maxi = 0.0001) {
  if (!is.matrix(mtx)) mtx <- matrix(mtx, byrow = TRUE, nrow = 1)
  random.stuff <- matrix(runif(prod(dim(mtx)), min = mini, max = maxi), nrow = dim(mtx)[1])
  random.stuff + mtx
}

#' # Data read-in
#'
#' Create matrix to simulate invasion risk: `1` = low risk, `6` = high risk. And add
#' some noise to data.
rmat_orig <- matrix(sample(1:6, size=100, replace=TRUE), ncol = 10)
rmat <- add_noise(rmat_orig, mini = -0.01, maxi = 0.01)

#' Original and noisy risk matrices:
rmat_orig
rmat

#' Create matrix to simulate species similarity matrix, based on invasion risk
#' scaling between 0 - 1 to simulate similarity. Then adding some noise to data.
dmat_orig <- apply (rmat_orig, 2, get_normal)
dmat <- add_noise(dmat_orig, mini = 0.000, maxi = 0.01) 

#' Original and noisy dissimilarity matrices:
dmat_orig
dmat

#' # Data Formatting
#' 
#' Matrix structure is irrelevant and arbitrary - matrices can be dissolved into vectors:
rvec <- c(rmat)
dvec <- c(dmat)

rvec
dvec

#' # Data analysis 1 - correlation and _p_ value
#' 
#' Correlation and p-value based on Kendall (non-normal data):
# correlation
cor(rvec, dvec) 
# "greater" corresponds to positive association,
cor.test(rvec, dvec, method = "kendall", alternative = "greater") 


#' # Data analysis 2 - correlation and permutation test 
#' 

perm_risk <- numeric(length = 100000) # create vector to store results, 
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
     perm <- shuffle(n)
     
     # fill vector of defined length loop-by-loop  
     perm_risk[i] <- cor(rvec[perm], dvec)
  }


#' Fill vector `perm_risk` with correlations between measured risk vector and
#'  vector containing biological species dissimilarities.
perm_risk[length(perm_risk)] <- cor(rvec, dvec) 

#' Show results graphically - see red dot of x-axis.
hist (perm_risk, 
      main = "Simulated and Shuffled Correlations",
      sub = "Correlation between Invasion Risk and Biologic Site Similarity",
      xlab = "Correlation", 
      breaks=50, 
      prob=TRUE)
lines(density(perm_risk))
rug(perm_risk[length(perm_risk)], col = "red", lwd = 5)

#' Count random correlations that are as high as the non-random one.
h_corr <- sum(perm_risk >=  perm_risk[length(perm_risk)])

#' Permutational _p_-value:
h_corr / length (perm_risk)

#' Strong evidence against the null hypothesis of no correlation between the two
#' matrices.

#' <!-- #################################################################### -->
#'
#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
