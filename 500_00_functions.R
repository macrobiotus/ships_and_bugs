#!/usr/local/bin/R
#' ---
#' title: "Helper functions for R scripts"
#' author: "Paul Czechowski"
#' date: "April 12th, 2018"
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
#' using `rmarkdown::render ("./500_functions.R")`. Please check the
#' session info at the end of the document for further notes on the coding environment.
#' May contain unused functions and could be written up as a package for greater
#' clarity.
#'
#' <!-- #################################################################### -->
#'
#' # Functions for `phyloseq` objects
#'
#' ## Create phyloseq object.
#'
#' Creates `phyloseq` objects from Qiime` compatible data.
get_phsq_ob <- function(biom_path, sequ_path, tree_path){

  # read data into R 
  btab <- phyloseq::import_biom (biom_path)
  # tree <- ape::read.tree(tree_path)
  sequ <- Biostrings::readDNAStringSet(sequ_path)  
  
  # construct object  
  phsq_ob <- merge_phyloseq(btab, tree_path, sequ)
  
  # return object
  return (phsq_ob)
}

#' ## Remove empty data
#'
#' This function removes "0" count phylotypes from samples and samples with "0"
#' phylotypes.
remove_empty <- function(phsq_ob){

  # filter Phylotypes
  phsq_ob <- phyloseq::prune_taxa (taxa_sums (phsq_ob) > 0, phsq_ob)
  
  # filter samples
  phsq_ob <- phyloseq::prune_samples (sample_sums (phsq_ob) > 0, phsq_ob)
  
  # return object
  return (phsq_ob)
}

#' ## Get port-sorted Phyloseq objects 
#' 
#' Get a list of Phyloseq objects in which each object only contains samples
#' from one sampling location. Matching of samples is done by the first two 
#' characters of the sample name.

get_phsq_list <- function(phsq_ob){
  
  # load package
  library("phyloseq")
  
  # wrapper function for Phyloseq's prune_samples
  prune_phsq <- function(port_keys, phsq_ob){
    
    #isolate subsets of samples based on port key - gives indivudual Phyloseq objects 
    isolated_ports <- prune_samples (grepl(port_keys, smpl_keys), phsq_ob)
    
    # diagnostic message
    message("Port ", port_keys, " has ", length(sample_names(isolated_ports)), " samples in Phyloseq object.") 
    
    # return sub-set Phyloseq objects, filling a list if called via lapply (as it is done below)
    return (isolated_ports)
    }
  
  # diagnostic
  message("Input Phyloseq object has ", length(sample_names(phsq_ob)), " samples.") 
  
  # store sample names in vector
  smpl_keys <- sample_names(phsq_ob)
  
  # isolate first two characters of vector and find unique values
  #   to give the shipping port locations
  port_keys <- unique(substr(smpl_keys, start = 1, stop = 2))
  
  # call subsetting function
  phsq_list <- lapply (port_keys, prune_phsq, phsq_ob)
  
  # set names for later
  setNames(object = phsq_list, port_keys)
 }

#' ## Get OTU table data frames from Phyloseq objects 
#'
#' As the description says.
get_df_from_phsq_list <- function (phsq_list){
  
  # package loading
  require(phyloseq)
  
  # isolate OTU table
  df <- data.frame(otu_table(phsq_list))
  
  # return OTU table 
  return (df)
  }


#' # Plain R functions 
#'
#' ## Operator "not in" 

# not in
'%!in%' <- function(x,y)!('%in%'(x,y))


#' ## Create empty matrix with necessary dimensions to receive average or median Unifrac values
#' 
get_collapsed_responses_matrix <- function(r_mat){

  #  extract necessary unique dimensions (also to be used later)
  unq_row_port <-  unique (substr (rownames (r_mat), start = 1, stop = 2))
  unq_col_port <-  unique (substr (colnames (r_mat), start = 1, stop = 2))
  
  #  create matrix with required dimensions
  r_mat_cllpsd <- matrix (nrow = length(unq_row_port),
                          ncol = length (unq_col_port))

   #  set col / row names appropriately   
   colnames(r_mat_cllpsd) = unq_row_port
   rownames(r_mat_cllpsd) = unq_row_port
   
   # diagnostic
   message("Collapsed matrix has ",dim(r_mat_cllpsd)[1]," rows and ",dim(r_mat_cllpsd)[1]," columns.")
   message("Collapsed matrix should receive data for samples: ", paste0(unq_row_port, " "),".")
   
   return(r_mat_cllpsd)
}

#' ## Fill empty response matrix with matrix field averages of full matrix
#' 
fill_collapsed_responses_matrix <- function(r_mat_clpsd = NULL, r_mat = NULL){
  
  # store row and column names for indexing 
  rnclpsd <- rownames(r_mat_clpsd)
  cnclpsd <- colnames(r_mat_clpsd)
  
  # loop over collapsed matrix and fill with contents of full input matrix 
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
      if (rnclpsd[i] == cnclpsd[j]){
         slctd_mat[lower.tri(slctd_mat, diag = TRUE)] <- NA  # although diagonal is defined with 
                                                             # "0" distance also setting diag to TRUE
                                                             # (excluded) so that average isn't
                                                             # lowered by the number of replicates
                                                             # per port.
      }
    
    slctd_ave <- median(slctd_mat, na.rm = TRUE) # na.rm = TRUE for edge cases, those will otherwise be NA
                                               #  but they do have a signal so can't NA
    # debugging only 
    #  print(slctd_ave)
    
    # fill collapsed matrix 
    r_mat_clpsd[rnclpsd[i], cnclpsd[j]] <- slctd_ave
    
    }
  }

  #   ...keep only upper triangle of matrix...
  r_mat_clpsd[lower.tri(r_mat_clpsd,diag = FALSE)] <- NA 

  #   ...return filled receiving matrix.  
  return(r_mat_clpsd)

}
                        
#' ## Correlate between two permuted vectors
#' 
shuffle_vectors <- function (rvec = NULL, pvec = NULL, perm = 10000){
  
  require(permute)
  
  # input vectors must be the same length 
  stopifnot(length(rvec) == length (pvec), local = TRUE)
    
  # create vector to store results, with length equal to the amount of
  #   permutations
  results <- numeric(length = perm)
  
  # info
  message("Shuffling one vector ", perm, " times.")
  
  # setting lengths of shuffled vectors
  n = length(rvec)
  m = length(pvec)
  
  # fill all but one vector position with permuted correlations 
  for (i in seq_len(length(results) - 1)) {

     # create and store permuted vector indices to shuffle real data one line
     #   below
     shffld1 <- shuffle(n)
     shffld2 <- shuffle(m)
     
     # fill vector of defined length loop-by-loop  - use pvec[shffld2]
     results[i] <- cor (rvec[shffld1], pvec, 
                        use = "pairwise.complete.obs", method = "kendall")    
  }
  
  #' Fill last position of results vector with correlations between measured 
  #'   risk vector and vector containing biological species dissimilarities.
  results[length(results)] <- cor (rvec, pvec, use = "pairwise.complete.obs", 
                                method = "kendall")
  
  return (results)
}

#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
