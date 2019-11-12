#' ---
#' title: "Extend modelling input"
#' author: "Paul Czechowski"
#' date: "12-November-2019"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---
#' 
#' This script needs all R scripts named `500_*.R` to have run successfully,
#' apart from `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R`
#' It should then be called using a shell script. It will only accept certain files
#' currently, and otherwise abort. For further information understand section Environment
#' preparation. Also check `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
#'
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#' 
#' # Environment preparation
#'
#' Empty buffer.

rm(list=ls())

#' Load Packages
library ("tidyverse") # dplyr and friends
library ("ggplot2")   # for ggCaterpillar

#' Functions

# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

# remove "PH" rows from input data - written for `lapply call`
remove_ph_rows = function(listed_table){
  require("tidyverse")
  listed_table %>% filter(!PORT %in% c("PH")) %>% filter(!DEST %in% c("PH")) -> listed_table
  return(listed_table)
}

# function to add port pairs in both orientations 
add_concatenated_pairs = function (any_table){
  require("dplyr")
  any_table %>% mutate(ORIA = paste0(PORT,"-", DEST)) %>% arrange(PORT, DEST) -> any_table
  any_table %>% mutate(ORIB = paste0(DEST,"-", PORT)) %>% arrange(PORT, DEST) -> any_table
  message("Attention, table has been sorted.")
  return(any_table)
}

##  Read in all tables

# define file path components for listing 
model_input_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Results"
model_input_pattern <- glob2rx("??_results_euk_*_model_data_*.csv")

# read all file into lists for `lapply()` usage
model_input_files <- list.files(path=model_input_folder, pattern = model_input_pattern, full.names = TRUE)

# store all tables in list and save input filenames alongside - skipping "X1" 
#  in case previous tables have column numbers, which they should not have anymore.
model_input_data <- lapply(model_input_files, function(listed_file)  read_csv(listed_file, col_types = cols('X1' = col_skip())))
names(model_input_data) <- model_input_files

##  Copy data but exclude `PH` rows

# checking filtering command - full data
# model_input_data[[1]] %>% rmarkdown::paged_table()

# checking filtering command - filtered data
# model_input_data[[1]] %>% filter(!PORT %in% c("PH")) %>% filter(!DEST %in% c("PH")) %>% rmarkdown::paged_table()

# remove "PH entries in copied table data and modify list labels for later file names 
model_no_ph_data <- lapply(model_input_data, remove_ph_rows)
names(model_no_ph_data) <- gsub(".csv", "_no_ph.csv", names(model_no_ph_data))

# write out "PH" filtered lists 
for (i  in seq(1:length(model_no_ph_data))){
  # set destination path from list label
  path = names(model_no_ph_data[i])
  # diagnostic message
  message ("Writing \"", path , "\".")
  # write files
  write_csv(model_no_ph_data[[i]], path)
}


##  Read in all tables again

# define file path components for listing 
model_input_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Results"
model_input_pattern <- glob2rx("??_results_euk_*_model_data_*.csv")

# read all file into lists for `lapply()` usage
model_input_files <- list.files(path=model_input_folder, pattern = model_input_pattern, full.names = TRUE)

# store all tables in list and save input filenames alongside - skipping "X1" 
#  in case previous tables have column numbers, which they should not have anymore.
model_input_data <- lapply(model_input_files, function(listed_file)  read_csv(listed_file, col_types = cols('X1' = col_skip())))
names(model_input_data) <- model_input_files

##  Add in Mandana's results

# read in Mandana's resu;ts and name columns
mandanas_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/191105_shipping_estimates.csv")
names(mandanas_data) <- c("PORT", "DEST", "TRIPS", "VOY_FON", "VOY_HON", "BLL_HON_NOECO", "BLL_FON_NOECO", "BLL_HON_SMECO", "BLL_FON_SMECO")

# rename SY to SI to match my data
mandanas_data$PORT[which (mandanas_data$PORT == "SY")] <- "SI"
mandanas_data$DEST[which (mandanas_data$DEST == "SY")] <- "SI"
mandanas_data$PORT[is.na(mandanas_data$PORT)] <- "NX"
mandanas_data$DEST[is.na(mandanas_data$DEST)] <- "NX"

# check full table 
mandanas_data <- mandanas_data %>% arrange(PORT, DEST) %>% print(n = Inf)

# add sorting variables to data sets
mandanas_data_source <- add_concatenated_pairs(mandanas_data)
mandanas_data_destin <- lapply(model_input_data, add_concatenated_pairs)

# check tables
mandanas_data_source %>% print(n = Inf)
mandanas_data_destin[[1]] %>% print(n = Inf)


# match Mandana's data source with Mandana's data destination - write as function: 


# create all possible join table
destination_table <- bind_rows (
  left_join(mandanas_data_destin[[1]], mandanas_data_source, by = "ORIA" ),
  left_join(mandanas_data_destin[[1]], mandanas_data_source, by = "ORIB" ),
  left_join(mandanas_data_destin[[1]], mandanas_data_source, by = c("ORIA","ORIB" )),
  left_join(mandanas_data_destin[[1]], mandanas_data_source, by = c("ORIB", "ORIA")),
  ) %>% select (-c(ORIA, ORIB, ORIB.x, PORT.y, DEST.y, ORIB.y, ORIA.x, ORIA.y)) %>%
  rename(PORT = PORT.x) %>% rename(DEST = DEST.x) %>% arrange(PORT, DEST) %>% 
  distinct(PORT, DEST, RESP_UNIFRAC, PRED_ENV, PRED_TRIPS, ECO_PORT,
    ECO_DEST, ECO_DIFF, TRIPS, VOY_FON, VOY_HON, BLL_HON_NOECO, BLL_FON_NOECO, 
    BLL_HON_SMECO, BLL_FON_SMECO, .keep_all = TRUE) %>% print(n = Inf)
  
# concatenate
 


# erase keys

# de-duplicate

# correct column names

# -- pending --

# remove sorting variables

# -- pending --

# write sorted data

# -- pending --

# get source indices for destination indices in all ordinations

# check input data length 
nrow(mandanas_data_destin[[1]]) #  64
nrow(mandanas_data_source)      # 111

# get indices two match up two data sets
srce_indices <- which (mandanas_data_source$ORIA %in% mandanas_data_destin[[1]]$ORIA | mandanas_data_source$ORIA %in% mandanas_data_destin[[1]]$ORIB)
dest_indices <- which (mandanas_data_destin[[1]]$ORIA %in% mandanas_data_source$ORIA  | mandanas_data_destin[[1]]$ORIB %in% mandanas_data_source$ORIA)

srce_indices # indices pointing tow rows in Mandanas data - not 111, two few
dest_indices # indices pointing tow rows in my data - not 64, two few

# subset two matching datasets 

test_source <-  mandanas_data_source[srce_indices, ]
test_destin <-  mandanas_data_destin[[1]][dest_indices,  ] 

test_source %>% arrange(PORT, DEST)
test_destin %>% arrange(PORT, DEST)

# sort two data sets on first then on second column





#' <!-- #################################################################### -->
#'
#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
