#' ---
#' title: "UNIFRAC value change in dependence of included samples."
#' author: "Paul Czechowski"
#' date: "Apr 04 2019"
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
#' using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment. Check `README.md` for further documentation.
#' Code was developed in `/Users/paul/Documents/CU_cmbd_rf_test` around Oct 02 2018.
#'
#' # Prepare Environment
#'
#' ## Empty buffer
rm(list=ls())

#'
#' ## Package loading 

library("data.table") # enhanced version of data.frame for fast data manipulations. 
library("tidyverse") # for data handling and graphing

#' ## Functions
#'
#' ### Check if names of input matrix are congruent
#' 
#'   * input: any matrix
#'   * outputs: stops if row and column lengths aren't the same 

check_matrix_dims_and_names <- function(mat){

  # extracting names
  unq_row_nms <- unique (substr (rownames (mat), start = 1, stop = 2))
  unq_col_nms <- unique (substr (colnames (mat), start = 1, stop = 2))
  
  # testing names and dimensions
  if(!(identical(unq_col_nms, unq_col_nms) & dim(mat)[1] == dim(mat)[2])) {
    stop("Samples names or matrix dimensions wrong, aborted.")
    }
}

#' ### Get first two characters of row- and column names of matrix
#' 
#'   * input: formatted raw matrix
#'   * outputs: vector with substrings 

get_port_strings_from_matrix <- function (unifrac_matrix) {
  # isolate as many first unique two letters as there are in matrix labes 
  port_strings <- unique (substr (rownames (unifrac_matrix), start = 1, stop = 2))
  # spit out
  return (port_strings)
}

#' ### Get list of port combinations, without 0 distance ports
#' 
#'   * input: vector with substrings
#'   * outputs: (list?) of data frames with Var1 and Var2 (default variable names for port pairs)  

get_port_combinations_from_port_strings <- function(port_strings) { 
  # get all possible combinations as data frame remove columns with same origin and destination port 
  port_combinations <- expand.grid(port_strings, port_strings, stringsAsFactors = FALSE) %>% filter (Var1 != Var2)
  # return
  return(port_combinations)
}

#' ### Get list of port combinations, without 0 distance ports
#' 
#'   * input: (list?) of data frames with Var1 and Var2 (default variable names for port pairs)
#'   * outputs: vector of all numerical matrix row- or column indices that match substring of port pairs 

get_matrix_row_or_col_indices = function(prt_elmt, unifrac_matrix) {
  # getting indices of destination ports - as list 
  elmt_ind <- sapply(prt_elmt, function (elmt) grep(pattern = elmt, x = rownames(unifrac_matrix)))
  # convert list to vector
  elmt_ind <- unlist(elmt_ind, use.names=FALSE)
  # return vector
  return(elmt_ind)
}

#' ### Get subset matrix for port pair - index based
#' 
#'   * input: both vectors of all numerical matrix row- or column indices that match 
#'            substring of port pairs, formatted raw input data
#'   * outputs: matrix subset for port port pairs

get_subset_matrix_from_indices <- function(ind_elmnt_a,ind_elmnt_b, unifrac_matrix) {
  # subset matrix and store
  subset_matrix <-  unifrac_matrix[ c(ind_elmnt_a), c(ind_elmnt_b)]
  #return stored
  return (subset_matrix)
}


#' ### Get subset matrix for port pair - index based
#' 
#'   * input: letter combinations for ports
#'   * outputs: matrix subset for port port pairs

get_matrix_from_port_pair <- function (prt_elmt_a, prt_elmt_b, unifrac_matrix) {
  
  # testing only
  # prt_elmt_a <- c("PH")
  # prt_elmt_b <- c("LB")
  # unifrac_matrix <- unifrac_matrix
  
  # extract row and column indices based on beginning of sample string 
  ind_elmnt_a <- get_matrix_row_or_col_indices(prt_elmt_a, unifrac_matrix)
  ind_elmnt_b <- get_matrix_row_or_col_indices(prt_elmt_b, unifrac_matrix)
  
  # call get_subset_matrix_from_indices
  # get subset matrix from row- and column strings  
  subset_matrix <- get_subset_matrix_from_indices(ind_elmnt_a,ind_elmnt_b, unifrac_matrix)
  
  # return matrix
  return(subset_matrix)
}

#' ### From input matrix, generate list of port-pair specific matrices
#'
#' Calls all functions above apart from `check_matrix_dims_and_names`()
#' 
#'   * input: raw, properly formatted symmetric distance matrix
#'   * outputs: list of matrices subset per port pair, without duplicates or
#'               zero distance port pairs.

get_many_matrices_from_input_matrix <- function (unifrac_matrix) {
  
  # checking input - check matrix dims and names 
  check_matrix_dims_and_names(unifrac_matrix)
  
  # generating matrices from input matrix, step 1 - get port strings from matrix
  port_strings <- get_port_strings_from_matrix(unifrac_matrix)
  
  # generating matrices from input matrix, step 2 - get port combinations from port strings
  port_combinations <- get_port_combinations_from_port_strings(port_strings)
  
  # generating matrices from input matrix, step 3 - get list of matrices from  port combinations
  unifrac_matrices <- apply(port_combinations, 1, function (prt_elmt) get_matrix_from_port_pair(prt_elmt[1], prt_elmt[2], unifrac_matrix))
  
  # return
  return(unifrac_matrices)
}

#' ### Labelling List Elements of Matrix List
#'
#' Needs matrix list, and source matrix, generated by, and used by `get_many_matrices_from_input_matrix()`

label_matrix_list = function(unifrac_matrix_list, unifrac_matrix) { 
  
  # getting port strings as in `get_many_matrices_from_input_matrix()`
  port_strings <- get_port_strings_from_matrix(unifrac_matrix)
  
  # getting port combinations as in `get_many_matrices_from_input_matrix()`
  port_combinations <- get_port_combinations_from_port_strings(port_strings)
  
  # generating labels for list elements congruent with list of matrices generated
  #   `get_many_matrices_from_input_matrix()` 
  pair_labels <- apply(port_combinations, 1, function (prt_strg) paste(prt_strg[1], prt_strg[2], sep = " ") )
  
  # writing labels vector into hitherto empty slist label slots
  names(unifrac_matrix_list) <- pair_labels  

  # return labeled list
  return(unifrac_matrix_list)
}

#' ### Generate tuples of dimension indices for n-samples out of m-samples,
#'
#' Instead of using all combinations, as discussed with CSCU Sep. 19. 2018
#' 
#'   * input: how many samples to chose from available samples, ho many times
#'   * outputs: vector of n=`limit` tupels, each with `count_ports_chosen` random values 

get_dim_indices_bootstrap <- function (ports_per_dim, count_ports_chosen, limit) {
  # sample function used instead of previously checking all combinations
  # 20.09.2018 - `ports_pairs` can be set manually as function parameter of 
  #   `get_results_vector_list_current_port()`, when `get_dim_indices_bootstrap()`
  #   samples with replacement, and hence more indices then available in each
  #   source matrix dimension cane be sampled. To undo set here `replace = FALSE`
  #   and re-enable automatic setting of `ports_pairs_available` in function 
  #   `get_results_vector_list_current_port()`
  tuples <- sapply(1:limit, function(tuple) sample(ports_per_dim, count_ports_chosen, replace = TRUE))
  # for edge case `count_ports_chosen` = 1 forcing vector to not "tip over" into having only a length
  #   dimension, but to stay upright, having a height and width dimension
  dim(tuples) <- c(count_ports_chosen, limit)
  # transformation for downstream compaitibility (format has to match `comboGeneral` output format
  #   that was used previously, needs to be vector, possible also for 1 x 1 samples)
  return(t(tuples))
}

#' ### Get matrix list for current port at current_sample_count
#'
#' This function is now obsolete, and while working for small sample numbers,
#' it won't work for large sample numbers, if true combinations are considered.
#' With the implementation of bootstrapping I don't need to walk through
#' all combinations of row and column tuples anymore, since they are random 
#' anyways, and now always of equal length. Commenting this old code out.
#' 
#'  * Used all combinations for rows and column indices in arrays generated by 
#'    `get_dim_indices_bootstrap()` to generate a list of matrices representing possible
#'    combinations of taking n-samples (= `ports_pairs_available`-samples)
#'    from current port. Nested loop iterates over two combination arrays and subsets
#'    the current port matrix repeatedly. Nested loop modified from 
#'    https://stackoverflow.com/questions/31627697/using-apply-family-of-functions-to-replace-nested-for-loop-in-r
#'   `sapply(1:4, function(i) sapply(1:4, function(j) dummy(nfl_teams[i], years[j])))`
#' 

# get_matrix_list_current_port_current_sample_count = function (
#   dim_indices_rows_p_mat,
#   dim_indices_cols_p_mat,
#   port_matrix)
#   {
#    mt_list_tpls <- sapply(1:dim(dim_indices_rows_p_mat)[1], function (curent_row_indices)  
#                      sapply(1:dim(dim_indices_cols_p_mat)[1], function (curent_col_indices)  
#                        port_matrix [ c(dim_indices_rows_p_mat[curent_row_indices, ]) , 
#                                      c(dim_indices_cols_p_mat[curent_col_indices, ]) ],
#                      simplify = FALSE), 
#                    simplify = FALSE)
#    
#    # diagnostic, 21.09.2018: function creates list of lists 
#    # print(mt_list_tpls)
#    # return list of list with matrices
#    return(mt_list_tpls)
# }

get_matrix_list_current_port_current_sample_count = function (
  dim_indices_rows_p_mat,
  dim_indices_cols_p_mat,
  port_matrix)
  {
  # both vectors need to be at the same length, which may not be the case if
  #  sample picking per ports is restricted by unequal matrix dimensions.
  #  This shouldn't happen anymore, but can still be enabled by small downstream
  #  code modifications.
  if(length(dim(dim_indices_rows_p_mat)[1]) != length(dim(dim_indices_cols_p_mat)[1]))
    {
  # Currently program aborts if old functionality is needed and tupel list lengths
  #   are unequal, as in old implementation, before 19.09.2018. If you need to 
  #  reenable past function contents from above where the `stop()` call is.
    stop("Tupel lists with matrix dimension indices are of unequal length.")
  } else {
  # I tried to iterate over two matrices ate once using each row as a
  #  and column tupel, respectively, for matrix subsetting. This may
  #  work via `purr::map2(.x, .y, .f, ...)`. I couldn't get it to work though
  #  because the output type didn't match the required type, and `map2`
  #  may not work on matrices (i.e. vectors with dimensions). Since both
  #  tuple lists have the same langths, and this is checked above, initially
  #  I just loop over the index of one dimensions, and use that to extract
  #  tuples for both dimensions. This is a bit dodgy, but only needs minor
  #  modifications. Striiping of one `sapply()` needs one suptitution with `list()`
  #  to match output above.
      mt_list_tpls <-list( sapply(1:dim(dim_indices_rows_p_mat)[1], function (curent_row_indices)
                        port_matrix [ c(dim_indices_rows_p_mat[curent_row_indices, ]) , 
                                      c(dim_indices_cols_p_mat[curent_row_indices, ]) ], 
                       simplify = FALSE))
  }
  # diagnostic, 21.09.2018: function creates list of lists 
  # print(mt_list_tpls)
  
  # return list of list with matrices
  return(mt_list_tpls)
}

#' ### Get median vector for current port matrix at current sample collection number
#' 
#'   * input:  distance matrix for port pair, number of samples to test for, 
#'             upper limit since not all subset matrices can be searched, and 
#'             since bootstrapping is needed for n=1 sample and n=all samples in matrix  
#'   * output: vector with means of distance matrices of all possible combinations
#'             of collecting n samples from 2 port pairs, length limited 
#'             and bootstarp replicated by 'limit'.
#'

get_distance_matrix_means_current_port_matrix_at_sample_count = function (port_matrix, count_ports_chosen, limit) {
  
  # get all combinations of row and column indices for the current number of samples
  #   to be chosen from current port for current port matrix list generation
  #   **05.05.2019** - changed below from mean to median, committed - see commit history
   
  nrow_p_mat <- dim(port_matrix)[1]
  ncol_p_mat <- dim(port_matrix)[2]
  
  # diagnostic
  # print(nrow_p_mat)
  # print(ncol_p_mat)
   
  # new call using boot strapping
  dim_indices_rows_p_mat <- get_dim_indices_bootstrap(nrow_p_mat, count_ports_chosen, limit)
  dim_indices_cols_p_mat <- get_dim_indices_bootstrap(ncol_p_mat, count_ports_chosen, limit)
   
  # diagnostic
  # dim_indices_rows_p_mat <- head(dim_indices_rows_p_mat, 5)
  # dim_indices_cols_p_mat <- head(dim_indices_cols_p_mat, 5)

  current_port_matrix_list <- get_matrix_list_current_port_current_sample_count(dim_indices_rows_p_mat, dim_indices_cols_p_mat, port_matrix)

  # diagnostic - check matrix list dimensions 
  #   tested for subset 1 port pair out of 20, variable for each port
  #   each matrix has dimension of `count_ports_chosen` * count_ports_chosen`,
  #   (samples taken at each port pair)
  #   list is nested
  # length(current_port_matrix_list)      # length equals tupel count of dim_indices_rows_p_mat
  # length(current_port_matrix_list[[2]]) # length equals tupel count of dim_indices_cols_p_mat

  # diagnostic - flattens list one level, length will equal product
  #   of row and column tupel count e.g. 455 * 35 = 15965 for 3 samples and
  #   one port of 20
  # unlist(current_port_matrix_list, recursive = FALSE) 

  current_port_and_sample_tupel_comb_matrices <- unlist(current_port_matrix_list, recursive = FALSE)

  # diagnostic - get mean values of current port and sample_tupel combination matrices
  #   as a vector of length of product of row and column tupel count 
  #   e.g. 455 * 35 = 15965 for 3 samples and one port of 20
  # sapply(current_port_and_sample_tupel_comb_matrices, mean, simplify = TRUE)
  # ***05.04.2018 - changed from mean to median***

  current_port_and_sample_tupel_comb_means <- sapply(current_port_and_sample_tupel_comb_matrices, median, simplify = TRUE)
  
  # returning long vector of means from matrices - should be approximately
  #   `dim(dim_indices_rows_p_mat)[1] * dim(dim_indices_cols_p_mat)[1]`
  return(current_port_and_sample_tupel_comb_means) 

}

#' ### Get bootstrap results for all numbers of samples per port
#' 
#'  All samples `1` to `n` will be subsampled `limit` times, and the result vector is returned in full
#'
#'   * input:  one matrix fro one port pair, 
#'   * output: labelled list of vectors (ordered from 1 sample to n samples, port specifically)
#'              with length of sample number vector will contain averaged distance values from all
#'              from all sampled matrixes

get_results_vector_list_current_port = function(port_matrix, limit, ports_pairs){

  # extract dimension to get count to get upper limit of ports to sample
  nrow_p_mat <- dim(port_matrix)[1] 
  ncol_p_mat <- dim(port_matrix)[2]

  # definition upper limit
  # get all possible samples explicitly, for `lapply()` call below
  #   20.09.2018 - `ports_pairs_available` can be set manually as function parameter, 
  #   when `get_dim_indices_bootstrap()` samples with replacement, and hence
  #   more indices then available in each source matrix dimension cane be sampled
   
  # ports_pairs_available <- min(nrow_p_mat, ncol_p_mat)
  ports_pairs_available <- ports_pairs_available
  
  # create sequences for subsequent functions
  ports_pairs <- seq(1:ports_pairs_available)
  
  # create a means vetor list for all possible samples and the current_port
  rslts_vector_list_current_port <- lapply (ports_pairs, function(count_ports_chosen) get_distance_matrix_means_current_port_matrix_at_sample_count(port_matrix, count_ports_chosen, limit)) 

  # get lists labels
  list_labels <-  sapply(ports_pairs, function (n_samples) paste0( n_samples, " sample(s)"))

  # writing labels vector into hitherto empty list label slots
  names(rslts_vector_list_current_port) <- list_labels  

  # return labeled list
  return(rslts_vector_list_current_port)
}

#' ## Data read-in
#'
#' Paths defined in list are UNIFRAC matrices for ports samples, without control
#  samples, for:
#'   
#'   * unclustred 18S eDNA data, unfiltered for anything but control samples
#'   * 97% clustered data, unfiltered for anything but control samples
#'   * 97% clustered data, filtered for metazoans
#'    

paths <- list(
  "/Users/paul/Documents/CU_combined/Zenodo/Qiime/125_18S_metazoan_unweighted_unifrac_distance_matrix/distance-matrix.tsv")
       
raw_unifrac_values <- read_tsv(paths[[1]])

#'
#' ## Data formatting
#' 
#' Convert raw data to matrix with row- and colnames for speed reasons.

unifrac_matrix <- as.matrix(raw_unifrac_values[1:nrow(raw_unifrac_values),2:ncol(raw_unifrac_values)])
rownames(unifrac_matrix) <- raw_unifrac_values$X1
colnames(unifrac_matrix) <- colnames(raw_unifrac_values[2:ncol(raw_unifrac_values)])

# get one smaller test unifrac matrix
# test_matrix <- unifrac_matrix[c(105:155),c(105:155)]

#'
#' Get a list of unique, unduplicated port-specific matrices.
#'

unifrac_matrix_list <- get_many_matrices_from_input_matrix(unifrac_matrix) 

#'
#' Label list elements 
#' 

unifrac_matrix_list <- label_matrix_list(unifrac_matrix_list, unifrac_matrix)

# just checking correct naming and amount of matrices - perhaps define later after data processing
names(unifrac_matrix_list)

# for plotting, counter part to `n_pairs` below
n_pairs_orig <- length(names(unifrac_matrix_list))

#' # Bootstrapping
#'
#' ## Bootstrap each distance matrix element for minimal to maximal sample numbers 
#' 
#' Number of bootstrap replicates is defined by the square of `limit`:

limit <- 10000 # loading data for 10000 replicates below 

# 20.09.2018 - `ports_pairs_available` can be set manually as function parameter of 
#   get_results_vector_list_current_port(), when `get_dim_indices_bootstrap()`
#   samples with replacement, and hence more indices then available in each
#   source matrix dimension cane be sampled.
ports_pairs_available <- 5 # slow at 20, 04.04.2018 reduced from 10 to 5

# get the list - main work, may take a long time for limit > 35 - 20.09.2018 `port_pairs` introduced as parameter
# ***updated results 04.04.2019 - comment this line out and load below***
bootstrap_results_list <- lapply(unifrac_matrix_list, get_results_vector_list_current_port, limit, ports_pairs_available)

# obtaining results can be time intensive, save and load here (15 MB for 10000 replicates at 15 pairs)
# ***updated results 05.04.2019 - comment this line out and load below***
save(bootstrap_results_list, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_05_UNIFRAC_behaviour_10k_results_list.Rdata")

# ***updated results 05.04.2019 - load below***
load("/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_05_UNIFRAC_behaviour_10k_results_list.Rdata")

# reformat nested list to (very large) data table
bootstrap_results <- rbindlist(bootstrap_results_list, idcol = TRUE, use.names=TRUE, fill = TRUE)

# for ggplot2 it may be necessary to have the port pairs as factors
bootstrap_results$.id <- as.factor(bootstrap_results$.id)

# for ggplot2 counting maximum amount of graphs to be drawn - more then 20
#  at most is nonsensical and may not even work in R. Alleviating this by
#  first counting number of available port pairs:

pair_list <- bootstrap_results %>%  # take the data.frame "bootstrap_results"
  group_by(.id) %>%                 # Then, with the filtered data, group it by ".id"
  summarise(Unique_Port_Pairs = n_distinct(.id))  # Summarise with unique elements per group
pair_list

#  Then, selecting a few randomly to display (adjust number of graphs via `n_rpairs`)
n_pairs = 64  # do not set this value higher then then the number of lines in `pair_list`
             #   you probably don't want to select more port pairs then available
             #   If you do, set `replace` to `TRUE`
set.seed(123)
rand_pairs <- sample_n(pair_list, n_pairs, replace = FALSE)

# I am not sure about the warning, but some pairs seem to contain more bootstrap results then
#   but I think its caused by some port pairs having less ports available then
#   `ports_pairs_available` which I adressed in the bootstrapping code already. 
#   Not chasing this further here, since this is meant only to prepare plotting. 
selected_bootstrap_results <- bootstrap_results %>% filter(bootstrap_results$.id == rand_pairs$.id) %>%  data.table()


#' # Results
#'
#' Calculating MAD values for plotting. (Using `selected_bootstrap_results`
#' instad of `bootstrap_results` with full data)
mad_bootstrap_results <- selected_bootstrap_results[, lapply(.SD, mad), by=.id]

#' Calculating log(MAD) values for plotting.
log_mad_bootstrap_results <- selected_bootstrap_results[, lapply(.SD, function(x) log(mad(x))), by=.id]


#' Melting raw data and MAD values to long format for `ggplot2`

raw_bootstrap_results_long <- melt(selected_bootstrap_results, id.vars=".id")
mad_bootstrap_results_long <- melt(mad_bootstrap_results, id.vars=".id")
log_mad_bootstrap_results_long <- melt(log_mad_bootstrap_results, id.vars=".id")

# quick and dirty, logging x axis as well
log_mad_bootstrap_results_long$variable <- log(as.numeric(log_mad_bootstrap_results_long$variable))

#' ## Plotting UNIFRAC means
#'

ggplot (
 raw_bootstrap_results_long, aes(x = variable, y = value)
   ) + 
 geom_violin(
   ) +
 facet_wrap(
   ~ .id
   ) +
 theme_bw(
   ) +
 theme(
   axis.text.x = element_text(size = 6, angle = 45, hjust = 1),
   axis.text.y = element_text(size = 6, angle = 45, hjust = 1)
   ) +
  labs(x = "Samples Taken From Each Port of Pair", y = "Distribution of Means of Bootstrap-Replicated Matrices") +
  ggtitle ("Variability of UNIFRAC Values in Dependence of Sampling Effort", subtitle = paste("for", n_pairs, "randomly selected of",n_pairs_orig, "port pairs"))

#' ## Plotting MAD-values
#'

ggplot (
 mad_bootstrap_results_long, aes(x = variable, y = value)
   ) + 
 geom_point(
   ) +
 facet_wrap(
   ~ .id
   ) +
 theme_bw(
   ) +
 theme(
   axis.text.x = element_text(size = 6, angle = 45, hjust = 1),
   axis.text.y = element_text(size = 6, angle = 45, hjust = 1)
   ) +
  labs(x = "Samples Taken From Each Port of Pair", y = "Median Absolute Deviation of Means of Bootstrap-Replicated Matrices") +
  ggtitle ("Variability of UNIFRAC Values in Dependence of Sampling Effort", subtitle = paste("for", n_pairs, "randomly selected of",n_pairs_orig, "port pairs"))

#' ## Plotting log-MAD-values
#'
ggplot (
 log_mad_bootstrap_results_long, aes(x = variable, y = value)
   ) + 
 geom_point(
   ) +
 facet_wrap(
   ~ .id
   ) +
 theme_bw(
   ) +
 theme(
   axis.text.x = element_text(size = 6, angle = 45, hjust = 1),
   axis.text.y = element_text(size = 6, angle = 45, hjust = 1)
   ) +
  labs(x = "Samples Taken From Each Port of Pair", y = "log of Median Absolute Deviation of Means of Bootstrap-Replicated Matrices") +
  ggtitle ("Variability of UNIFRAC Values in Dependence of Sampling Effort", subtitle = paste("for", n_pairs, "randomly selected of",n_pairs_orig, "port pairs"))

#' # Discussion
#'
#' Decided to use no more then 5 samples for extraction and sequencing.
#'
#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
