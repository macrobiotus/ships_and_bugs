#' ---
#' title: "Format Predictor Data"
#' author: "Paul Czechowski"
#' date: "April 19th, 2017"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references_2.bib
#' ---
#'
#' # Code rendering
#' 
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_30_get_predictor_risk_matrix.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#'
#' # Preface
#' 
#' # Prerequisites to run this code
#'
#' * file `/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_10_gather_predictor_tables__output__all.Rdata` is available
#' * or input data has been cleaned by `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R`  
#'   and the output files of that script were generated
#'   using the correct source tables (check commit hashes if necessary) and 
#'   are accesible.
#' * is that file `/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances__output.Rdata` is available
#' * or that the distance matrix has been produced via `/Users/paul/Documents/CU_combined/Github/500_20_get_predictor_euklidian_distances.R`  
#'   and the output files of that script  were generated
#'   using the correct source tables (check commit hashes if necessary) and 
#'   are accesible.
#'
#' # Environment preparation
#'
#' ## Package loading and cleaning of workspace
#+ message=FALSE, results='hide'

library (dplyr)       # sorting, table manipulation
library (matrixStats) # here used (anymore?) for column median
library (tidyverse)   # to `write_excel_csv()`
library (readxl)      # to open excel files
library (reshape2)    # plotting, table manipulation
library (ggplot2)     # plotting, mapping
library (maps)        # mapping
library (ggrepel)     # plot labelling
library (grid)        # handle graphical objects
library (gridExtra)   # handle graphical objects

#' ## Flushing buffer
#' 
rm(list=ls())     # for safety only

#'
#' # Data import
#' 
#' Data is imported using basic R functionality, generated from previous scripts: 
#'
#'  *  `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R`
#'  *  `/Users/paul/Documents/CU_combined/Github/500_20_get_predictor_euklidian_distances.R`

# getting list of Tibbles
load (file = 
   "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_10_gather_predictor_tables__output__all.Rdata")
 
# getting distance matrix
load (file =
   "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances__output.Rdata")


# getting distance matrix dimnames
load (file =
   "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances_dimnames__output.Rdata")

# check successful loading 
exists (c ("src_heap", "eucl_heap", "eucl_heap_dimnames"))

# show the data structure for future reference 
str (src_heap)
str (eucl_heap)
str (eucl_heap_dimnames) # 6551 names


#'
#' # Formatting the environmental distance matrix.
#'
#' Needs to be done so looking up distances between route endpoints can be looked up.
#'
#' ## Converting the matrix
#'
#' Initially convert the `dist()` object to a normal matrix for labelling and
#' to speed up things. Refer to the previous script if more details are needed
#' from the `dist()` object. 
eucl_heap <- as.matrix(eucl_heap)
dim(eucl_heap) # 6551 ? - yes! 19.04.2018

# 19.04.2018: adding dimnames
colnames(eucl_heap) <- c(eucl_heap_dimnames)
rownames(eucl_heap) <- c(eucl_heap_dimnames)

# checking - ok
colnames(eucl_heap)[1:10]
rownames(eucl_heap)[1:10]

#' ## Label distance matrix with port ID's
#'
#' Matrix row and columns are best labelled using the PORT ID's. `src_heap$TEMP$PORT`
#' defines the matrix dimension, but only contains the written port names, which
#' are more difficult to match up. I need a vector of `length (src_heap$TEMP$PORT)`
#' containing the port IDs. The needed information is `src_heap$PORT[c("PID", "PORT")]`.
#' I will match this up in a new variable (`PID`):

# `match()` (or `%in%`) doesn't return `NA` thus needed is a left join:
src_heap$TEMP <- left_join (src_heap$TEMP, src_heap$PORT[c("PID", "PORT")], by = "PORT")
src_heap$TEMP$PID <- as.integer(src_heap$TEMP$PID) # added 19.04.2018

# of 6651 entries, 83 remain undefined, a very small percentage: 
sum(is.na(src_heap$TEMP$PID)) / length (src_heap$TEMP$PID)

# renaming the matrix rows and and columns
#   `as.numeric()` may prevent lookup problems later
# colnames (eucl_heap) <- as.numeric(src_heap$TEMP$PID) 
# rownames (eucl_heap) <- as.numeric(src_heap$TEMP$PID) # modified 19.4.2018


colnames (eucl_heap) <- as.character(src_heap$TEMP$PID) 
rownames (eucl_heap) <- as.character(src_heap$TEMP$PID)

# remove duplicate values to save memory and avoid confusion
# NOOOO - lookup later is in two dimensions (?) commenting out 19.04.2018
#  eucl_heap[lower.tri(eucl_heap)] <- NA

# testing the result - looks as desired
eucl_heap[c(1:10), c(1:10)]

# test 19.04.2018 - are test sample in the distance matrix? before calculating risk?
eucl_heap[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")]
# YES :-)

#' ## Export distance matrix 
#'
#' No risks associated yet, just an intermediate step:
save (eucl_heap, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_get_predictor_risk_matrix__output_env_matrix.Rdata")


#' 19.04.2018 - needs debugging - commited  
#'
#' # Formatting the route information, including _route ranking_
#'
#' ## Getting the route information 
#' 
#' Route information is stored in Tibble `src_heap$ROUT` (`$TRIPS`)
#'
#' ## Adding the environmental distances. 
#' 
#' Environmental distances are added to route info in variable `EDST` through
#' lookup in distance matrix via variables `src_heap$ROUT$PRTA` and
#' `src_heap$ROUT$PRTB`. 17% of data are missing, unless I get better data.

# Initially create an index matrix - each position contains row and column position
# of matching ports.
rownames (eucl_heap) == colnames (eucl_heap)
pos <- cbind (
  match (src_heap$ROUT$PRTA, rownames (eucl_heap)),
  match (src_heap$ROUT$PRTB, colnames (eucl_heap))) 
  
#' Position pairs with `NA`'s do not have a matching row or column in the
#' Eucledian distance matrices but some route in the route table `src_heap$ROUT`.
#' In those cases the Lloyds route information (table) is more comprehensive then the 
#' climate data (matrix). I am not erasing incomplete pairs, although these do 
#' not match a matrix position: this would screw up the table lookup unless the original
#' row numbers are saved. Not doing `pos <- na.omit(pos)`. Saving matrix position
#' in table instead.

# Create variable by filling it with euclidian distance value from the distance matrix.
src_heap$ROUT$EDST <- eucl_heap[pos] 
sum(is.na(src_heap$ROUT$EDST))

# saving matrix source coordinates in tables - for later
src_heap$ROUT$EUKPOSR <- pos[,1]
src_heap$ROUT$EUKPOSC <- pos[,2]

# Check for missing data - quite ab it missing - 0.1684139
sum(is.na(src_heap$ROUT$EDST)) / length (src_heap$ROUT$EDST)

# test 19.04.2018 - are test sample in the route table?

test_samples = c("2503","1165","3110","2907") 

src_heap$ROUT %>% filter (PRTA == "2503" & PRTB %in% test_samples |
                          PRTB == "2503" & PRTA %in% test_samples &
                          PRTA == "1165" & PRTB %in% test_samples |
                          PRTB == "1165" & PRTA %in% test_samples &
                          PRTA == "3110" & PRTB %in% test_samples |
                          PRTB == "3110" & PRTA %in% test_samples &
                          PRTA == "2907" & PRTB %in% test_samples |
                          PRTB == "2907" & PRTA %in% test_samples )



#' ## **Calculating the compound ranking variable** 
#' 
#' ### Plotting TRIPS
#'
#' Just so that I see what is going on I am plotting this:
molten <- melt (src_heap$ROUT[c("TRIPS")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of TRIPS in route data")

#' ### Testing TRIPS, EDST and RANKS
#'
#' Before I create variables I'd like test the approach I will apply:
#' This could likely be improved.

# Create a test data frame
test         <- src_heap$ROUT[c("TRIPS", "EDST")]
test$LTRIPS  <- log (test$TRIPS)             # log only to down-scale
test$LIDST   <- log (1 / src_heap$ROUT$EDST) # log only to down-scale
test$RANK    <- log (src_heap$ROUT$TRIPS * (1 / src_heap$ROUT$EDST)) 

# Remove Inf and NA values
test <- do.call (data.frame, lapply (test, function(x) replace(x, is.infinite (x), NA)))
test <- as_tibble(test)
test <- test [ complete.cases (test), ]
test <- as_tibble (scale ( test[c("LTRIPS", "EDST", "LIDST", "RANK")]))

# Test plot
molten <- melt (test[c("LTRIPS", "EDST", "LIDST", "RANK")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of test variables",
    subtitle = "LTRIPS and LIDST are log-scaled, TRIPS and IDIST are multiplied to RANK")

#'
#' ### Multiply log of trips with inverse of environmental distance 
#'
#' This should give me an option to rank routes by trips and environmental
#' closeness. Routes will always have a slight environmental distance, so division by zero
#' will not be an issue when inverting distance values.

# The `log()` shifts the density skew quite substantially.
src_heap$ROUT$RANK <-  log (src_heap$ROUT$TRIPS * (1 / src_heap$ROUT$EDST))   

# And the plot, quick and dirty.
molten <- melt (src_heap$ROUT[c("RANK")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of RANKS in route data",
  subtitle = "log (src_heap$ROUT$TRIPS * (1 / src_heap$ROUT$EDST))" )

#' # Creating and exporting Risk Matrix 
#'
#' Create empty matrix with appropriate dimensions (match the euk. matrix).
r_mat <- matrix(nrow = dim(eucl_heap)[1], ncol = dim(eucl_heap)[2])
colnames(r_mat) <- colnames (eucl_heap)
rownames(r_mat) <- rownames (eucl_heap)

#' Isolate contents to be put in matrix (for simplicity).
r_mat_content <- na.omit(src_heap$ROUT[c("RANK","EUKPOSR","EUKPOSC")])

#' Fill matrix by looping through content table  
for (i in 1:nrow(r_mat_content)){
    r_mat[ as.numeric(r_mat_content[i, 2]), as.numeric(r_mat_content[i, 3])] <- 
      as.numeric(r_mat_content[i, 1])
    }

# test 19.04.2018 - are test sample in the distance matrix after calculating risk?
r_mat[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")]
# NOOOO :-(

#' **Port names are numbers, still needs filtering, should give symmetrical upper
#' matrix when filtered for available ports:**
save (r_mat, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_get_predictor_risk_matrix__output_risk_matrix.Rdata")

#' # Garbage collection and file saving
#' 
rm("eucl_heap", "pos", "r_mat", "i", "molten", "test") 
save (src_heap, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_get_predictor_risk_matrix__output_predictor data.Rdata")

#' # Session info
#' 
#' The code and output in this document were tested and generated in the 
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References 

