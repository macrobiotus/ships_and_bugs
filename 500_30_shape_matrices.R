#' ---
#' title: "Format Predictor Data and matrices"
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
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_30_shape_matrices.R")`.
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

library ("dplyr")       # sorting, table manipulation
library ("matrixStats") # here used (anymore?) for column median
library ("tidyverse")   # to `write_excel_csv()`
library ("readxl")      # to open excel files
library ("reshape2")    # plotting, table manipulation
library ("ggplot2")     # plotting, mapping
library ("maps")        # mapping
library ("ggrepel")     # plot labelling
library ("grid")        # handle graphical objects
library ("gridExtra")   # handle graphical objects

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


# getting distance matrix dimnames - for checking purposes
load (file =
   "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_20_get_predictor_euklidian_distances_dimnames__output.Rdata")

# check successful loading 
exists (c ("src_heap", "eucl_heap", "eucl_heap_dimnames"))

# show the data structure for future reference 
str (src_heap)           # all data
str (eucl_heap)          # eucledian distance matrix of `src_heap$TEMP[c("TMIN", "TMAX", "TMEN", "SMEN")]`
str (eucl_heap_dimnames) # 6551 names - from `src_heap$TEMP$PORT`


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

# for debugging - so that data cabn be recognized as a vector

dim(eucl_heap)      # 6551 x 6551 - yes! 19.04.2018
class (eucl_heap)
summary (c(eucl_heap)) #  Min.    1st Qu.  Median    Mean   3rd Qu.    Max. 
                       #  0.000   1.524    2.474     2.519   3.464     7.686 

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

# renaming the matrix rows and and columns - matrix was created from src_heap$TEMP
#  so this is ok. Used to be  `as.numeric()` instead of `as.character()` before
#  19.04.2018
colnames (eucl_heap) <- as.character(src_heap$TEMP$PID) 
rownames (eucl_heap) <- as.character(src_heap$TEMP$PID)

# remove duplicate values to save memory and avoid confusion
# NOOOO - lookup later is in two dimensions (?) commenting out 19.04.2018
# eucl_heap[lower.tri(eucl_heap)] <- NA

# testing the result - looks as desired
eucl_heap[c(1:10), c(1:10)]

# test 19.04.2018 - are test sample in the distance matrix? before calculating risk?
#           "PH",   "SP",   "AD",  "CH"     "PH",   "SP",   "AD",  "CH" 
eucl_heap[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")]
# YES for test data - may have no routes though - need data with verified routes e.g.:
#     Long Beach - Houston // Houston - Miami //  Baltimore - Houston   
eucl_heap[c("7597","2331","4899","854") , c("7597","2331","4899","854")]
# (always possible to calculate distance 


#' ## Export environmental distance matrix 
#'
#' No risks associated yet, just an intermediate step:
mat_env_dist_full <- eucl_heap # renaming for compatibility with downstrem (script 600)
save (mat_env_dist_full, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata")


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
#' 
#' Initially create an index matrix. Matrix positions containing environmental 
#' distance values are indexed by row and column numbers (0-6551 x 0 - 6551)
#' of the environmental distance matrix.
# rownames (eucl_heap) == colnames (eucl_heap) # check if those are identical before using them 
                                             # - they must be and should be 
env_val_pos <- cbind (
  match (src_heap$ROUT$PRTA, rownames (eucl_heap)),
  match (src_heap$ROUT$PRTB, colnames (eucl_heap))) 
  
#' The resulting list is of length 23656, which is the length of the route table
#' `src_heap$ROUT`. Position pairs with `NA`'s do not have a PORT ID in the matrix
#' column or row names. Probably because the number of routes is larger then the number of
#' ports that have environmental distances calculated (environmental data).
#' Euclidian distance matrices but some route in the route table `src_heap$ROUT`.
#' In those cases the Lloyds route information (table) is more comprehensive then the 
#' climate data (matrix). I am not erasing incomplete pairs, although these do 
#' not match a matrix position: this would screw up the table lookup unless the original
#' row numbers are saved. Not doing `pos <- na.omit(pos)`. Saving matrix position
#' in table instead. To check - square root of na-ommitted table should be dimension
#' of matrix 
#'
#' There are 23656 routes in the route table 
length (complete.cases(env_val_pos))

#' And 19672 routes have environmental data available 
sum (complete.cases(env_val_pos), na.rm=TRUE)

#' So that the data is 83% complete (17% missing data).

# Create variable by filling it with euclidian distance value from the distance matrix.
src_heap$ROUT$EDST <- eucl_heap[env_val_pos] 

# There are now 19672 environmental distances in the route table 
sum(!is.na(src_heap$ROUT$EDST)) 

# saving matrix source coordinates in tables - for later
src_heap$ROUT$EUKPOSR <- env_val_pos[,1]
src_heap$ROUT$EUKPOSC <- env_val_pos[,2]

# Check for missing data - quite ab it missing - 0.1684139
sum(is.na(src_heap$ROUT$EDST)) / length (src_heap$ROUT$EDST)

# test 19.04.2018 - are test sample in the route table?
# test_samples = c("2503","1165","3110","2907") 

# test 24.04.2018 - are test sample in the route table?
# Long Beach // Miami // Houston // Baltimore 
test_samples = c("7597","2331","4899","854")

src_heap$ROUT %>% filter (PRTA %in% test_samples & PRTB %in% test_samples) 
src_heap$ROUT %>% filter (PRTB %in% test_samples & PRTA %in% test_samples)

# A tibble: 6 x 11
#   ROUTE      PRTA PALATI PALONG  PRTB PBLATI PBLONG TRIPS  EDST EUKPOSR EUKPOSC
#   <chr>     <dbl>  <dbl>  <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl>   <int>   <int>
# 1 2331a854  2331.   29.8  -95.3  854.   39.3  -76.6  287.  1.52    6151    5971 -- Houston - Baltimore
# 2 4899a2331 4899.   25.8  -80.2 2331.   29.8  -95.3  429.  2.94    6230    6151 -- Miami - Houston
# 3 4899a854  4899.   25.8  -80.2  854.   39.3  -76.6   75.  3.16    6230    5971 -- Miami - Baltimore 
# 4 7597a2331 7597.   33.8 -118.  2331.   29.8  -95.3   93.  2.53    6198    6151 -- Long Beach - Houston 
# 5 7597a4899 7597.   33.8 -118.  4899.   25.8  -80.2   11.  1.50    6198    6230 -- Long Beach - Miami
# 6 7597a854  7597.   33.8 -118.   854.   39.3  -76.6   26.  2.14    6198    5971 -- Long Beach - Baltimore
#
# Routes are only listed in one direction!

## 24.April - continue here 

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
#' This could likely be improved. **Heavily modified 24.04.2018**

# Create a test data frame
test         <- src_heap$ROUT[c("TRIPS", "EDST")]

range(test$TRIPS) # Trips is never 0 - as expected - it wouldn't be in the route table otherwise

# scaling TRIPS with log, add 1
#  TRIPS can't be zero because this would make environmental distances zero in 
#  cases where there is only one TRIP per route
test$LTRIPS  <- log (test$TRIPS) + 1             
summary(test$LTRIPS) # This looks better
                     # Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
                     # 1.000   2.099   2.792   3.216   3.996  11.452

# remove undefined values, since we are testing here
test <- test[complete.cases(test), ]

range (test$EDST) # EDST is zero at identical ports - Closeness will be infinite
                  #  desirable

test$IDST   <- 1 / test$EDST   # inverse - "CLOSENESS"
                               # division by 0 with 0 EDST - keep in mind

summary(test$EDST) # Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
                   # 0.000   1.166   1.959   1.955   2.668   5.760

summary(test$IDST) # Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
                   # 0.1736  0.3748  0.5106     Inf  0.8576     Inf 


# changed test case 24.04.2018
test$RANK    <- test$LTRIPS * test$IDST 

summary(test$RANK)

# Remove Inf and NA values
test <- do.call (data.frame, lapply (test, function(x) replace(x, is.infinite (x), NA)))
test <- as_tibble(test)
test <- test [ complete.cases (test), ]

# Test plot
molten <- melt (test[c("LTRIPS", "EDST", "IDST", "RANK")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of test variables",
    subtitle = "LTRIPS are log-scaled TRIPS - EDIST is original - IDIST is closeness - RANK is compound")

#'
#' ### Multiply log of trips + 1 with inverse of environmental distance 
#'
#' This should give me an option to rank routes by trips and environmental
#' closeness. 
#'   *  Environmental distance will be "0" at identical ports.
#'   *  Environmental closeness will be "Inf" at identical ports.
#'   *  Trip number is log scaled to keep numbers small
#'   *  log scaled Trip number needs to be added to "1" in oder to always have something
#'      to multiply closeness with
#'   *  Only ports with available route data can be compared! 


# The `log()` shifts the density skew quite substantially 23.04.2018 - changed log to srt.
src_heap$ROUT$RISK <-  (log(src_heap$ROUT$TRIPS) + 1) * (1 / src_heap$ROUT$EDST)   

#' Keeping only complete cases - these are only onece that can be used for the anslysis 
#' also re-sorting columns
src_heap$ROUT <- src_heap$ROUT[complete.cases(src_heap$ROUT), ]
src_heap$ROUT <- src_heap$ROUT[c("ROUTE",  "PRTA",  "PALATI",
                                "PALONG", "PRTB", "PBLATI",  "PBLONG", "TRIPS",
                                "EDST",  "RISK", "EUKPOSR", "EUKPOSC")] 

# And the plot, quick and dirty.
molten <- melt (src_heap$ROUT[c("RISK")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of RANKS in route data",
  subtitle = "(log(src_heap$ROUT$TRIPS) + 1) * (1 / src_heap$ROUT$EDST)" )

#' # Creating and exporting Matrices 
#'
#' Matrix dimensions are those of the environmental distances `mat_env_dist_full`.
#' This matrix (currently) is treated as a full matrix.

#'
#' ## Matrix with invasions risks
#'

# Create matrix
mat_risks <- matrix(nrow = dim(mat_env_dist_full)[1], ncol = dim(mat_env_dist_full)[2])
colnames(mat_risks) <- colnames (mat_env_dist_full)
rownames(mat_risks) <- rownames (mat_env_dist_full)

#' Fill matrix by looping through content table  
for (i in 1:nrow(src_heap$ROUT)){
    mat_risks[ src_heap$ROUT$EUKPOSR[i], src_heap$ROUT$EUKPOSC[i]] <- src_heap$ROUT$RISK[i]
    mat_risks[ src_heap$ROUT$EUKPOSC[i], src_heap$ROUT$EUKPOSR[i]] <- src_heap$ROUT$RISK[i]
    }

# test 19.04.2018 - are test sample in the distance matrix after calculating risk?
#  looking ok for "PH","SP","AD","CH"
mat_risks[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")]
# 6 * 2 routes expected for Long Beach // Miami // Houston // Baltimore 
mat_risks[c("7597","2331","4899","854"), c("7597","2331","4899","854")]
# looking ok 

#' 
#' ## Matrix with trips
#' 

# Create matrix
mat_trips <- matrix(nrow = dim(mat_env_dist_full)[1], ncol = dim(mat_env_dist_full)[2])
colnames(mat_trips) <- colnames (mat_env_dist_full)
rownames(mat_trips) <- rownames (mat_env_dist_full)

#' Fill matrix by looping through content table  
for (i in 1:nrow(src_heap$ROUT)){
    mat_trips[ src_heap$ROUT$EUKPOSR[i], src_heap$ROUT$EUKPOSC[i]] <- src_heap$ROUT$TRIPS[i]
    mat_trips[ src_heap$ROUT$EUKPOSC[i], src_heap$ROUT$EUKPOSR[i]] <- src_heap$ROUT$TRIPS[i]
    }


# test 19.04.2018 - are test sample in the distance matrix after calculating risk?
#  looking ok for "PH","SP","AD","CH"
mat_trips[c("2503","1165","3110","2907") , c("2503","1165","3110","2907")]
# 6 * 2 routes expected for Long Beach // Miami // Houston // Baltimore 
mat_trips[c("7597","2331","4899","854"), c("7597","2331","4899","854")]
# looking ok 

#' # Garbage collection and file saving
#' 
#' **Port names are numbers, still needs filtering, should give symmetrical upper
#' matrix when filtered for available ports:**
save (mat_risks, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata")

#' **Port names are numbers, still needs filtering, should give symmetrical upper
#' matrix when filtered for available ports:**
save (mat_trips, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full.Rdata")

save (src_heap, file = "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_predictor_data.Rdata")

#' # Session info
#' 
#' The code and output in this document were tested and generated in the 
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References 

