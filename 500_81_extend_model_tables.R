#' ---
#' title: "Extend modelling input"
#' author: "Paul Czechowski"
#' date: "11-March-2020"
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
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#' 

## Environment preparation
## -----------------------

# Clear Environment
rm(list=ls())

# Load Packages
library ("tidyverse") # dplyr and friends
library ("ggplot2")   # for ggCaterpillar

# Functions

# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

# Function to remove "PH" rows from input data - written for `lapply` call
remove_ph_rows = function(listed_table){
  require("tidyverse")
  listed_table %>% filter(!PORT %in% c("PH")) %>% filter(!DEST %in% c("PH")) -> listed_table
  return(listed_table)
}

# Function to merge Mandanas dat with my data, minding the differences in orders of source and
#  destination columns - written for `lapply` call
left_join_using_port_sets = function(tab_in_list, tab_single_cleaned){
  
  # needed for pretty much all this function does
  require("dplyr")
  
  # function to add port pairs in both orientations 
  add_concatenated_pairs = function (any_table){
    require("dplyr")
    any_table %>% mutate(ORIA = paste0(PORT,"-", DEST)) %>% arrange(PORT, DEST) -> any_table
    any_table %>% mutate(ORIB = paste0(DEST,"-", PORT)) %>% arrange(PORT, DEST) -> any_table
    message("Attention, table has been sorted.")
    return(any_table)
  }
  
  # add columns to allow left-joining regardsles of port id order
  tab_in_list <- add_concatenated_pairs(tab_in_list)
  tab_single_cleaned <- add_concatenated_pairs(tab_single_cleaned)

  # match up port-ids independent of their order in in table pair being matched
  return_tabl <- bind_rows (
    left_join(tab_in_list, tab_single_cleaned, by = "ORIA"),
    left_join(tab_in_list, tab_single_cleaned, by = "ORIB"),
    left_join(tab_in_list, tab_single_cleaned, by = c("ORIA","ORIB")),
    left_join(tab_in_list, tab_single_cleaned, by = c("ORIB","ORIA")),
  ) 
  
  # data needs to be uniform to identify duplicates - remove variables used to join data 
  return_tabl <- return_tabl  %>% 
    select (-c(ORIA, ORIB, ORIB.x, PORT.y, DEST.y, ORIB.y, ORIA.x, ORIA.y)) %>%
    rename(PORT = PORT.x) %>% rename(DEST = DEST.x) %>% arrange(PORT, DEST)
  
  # keep only non-duplicated entries in table
  return_tabl <- return_tabl  %>%  distinct(PORT, DEST, RESP_UNIFRAC, PRED_ENV,
    PRED_TRIPS, ECO_PORT, ECO_DEST, ECO_DIFF, VOY_FREQ, B_FON_NOECO, 
    B_HON_NOECO, B_FON_SMECO, B_HON_SMECO, F_FON_NOECO, F_HON_NOECO, F_FON_SMECO,
    F_HON_SMECO, .keep_all = TRUE)
  
  return(return_tabl)

}

## Read in and format data
## -----------------------

# define file path components for listing 
model_input_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Results"
model_input_pattern <- glob2rx("??_results_euk_asv00_*_UNIF_model_data_2020-Mar-11-12*.csv") # adjust here for other / newer data sets

# read all file into lists for `lapply()` usage
model_input_files <- list.files(path=model_input_folder, pattern = model_input_pattern, full.names = TRUE)

# store all tables in list and save input filenames alongside - skipping "X1" 
#  in case previous tables have column numbers, which they should not have anymore.
#  Warnings for column names X1 are not a worry.
model_input_data <- lapply(model_input_files, function(listed_file)  read_csv(listed_file, col_types = cols('X1' = col_skip())))
names(model_input_data) <- model_input_files

##  Copy data but exclude `PH` rows
## ----------------------------------

# checking filtering command - full data
# model_input_data[[1]] %>% rmarkdown::paged_table()

# checking filtering command - filtered data
# model_input_data[[1]] %>% filter(!PORT %in% c("PH")) %>% filter(!DEST %in% c("PH")) %>% rmarkdown::paged_table()

# remove "PH entries in copied table data and modify list labels for later file names 
model_no_ph_data <- lapply(model_input_data, remove_ph_rows)
names(model_no_ph_data) <- gsub(".csv", "_no_ph.csv", names(model_no_ph_data))


## Combine lists of tables with PH and non-PH data
## -----------------------------------------------

all_model_data <- append(model_input_data, model_no_ph_data)
names(all_model_data)


## Read and format Mandana's results
## ---------------------------------

# read in Mandana's results and name columns
# old incomplete data (19.11.2019)
# mandanas_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/191105_shipping_estimates.csv")

# newer more complete data 2020-01-28
# mandanas_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200128_all_links_1997_2018.csv")
# names(mandanas_data)
# 
# old names
# ---------
#     "source"              "target"              "voyage_freq"         "Ballast FON noEco"   "Ballast HON noEco"   "Ballast FON sameEco"
#     "Ballast HON sameEco" "Fouling FON noEco"   "Fouling HON noEco"   "Fouling FON sameEco" "Fouling HON sameEco
#
# new names 
# ---------
#      "PORT",                "DEST",              "VOY_FREQ",           "B_FON_NOECO",        "B_HON_NOECO",        "B_FON_SMECO", 
#      "B_HON_SMECO",         "F_FON_NOECO",       "F_HON_NOECO",        "F_FON_SMECO",        "F_HON_SMECO")


# latest data 2020
mandanas_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_All_links_1997_2018_updated.csv")
names(mandanas_data)

# old names
# ---------
#      "source"                  "target"                  "voyage_freq"             "Ballast FON noEco"       "Ballast HON noEco"      
#      "Ballast FON sameEco"     "Ballast HON sameEco"     "Ballast FON noEco_noEnv" "Ballast HON noEco_noEnv" "Fouling FON noEco"      
#      "Fouling HON noEco"       "Fouling FON sameEco"     "Fouling HON sameEco"     "Fouling FON noEco_noEnv" "Fouling HON noEco_noEnv"
# new names 
# ---------
#      "PORT",                   "DEST",                   "VOY_FREQ",               "B_FON_NOECO",            "B_HON_NOECO",
#      "B_FON_SMECO",            "B_HON_SMECO",            "B_FON_NOECO_NOENV",      "B_HON_NOECO_NOENV",      "F_FON_NOECO", 
#      "F_HON_NOECO",            "F_FON_SMECO",            "F_HON_SMECO",            "F_FON_NOECO_NOENV",      "F_HON_NOECO_NOENV"

names(mandanas_data) <- c("PORT", "DEST", "VOY_FREQ", "B_FON_NOECO", "B_HON_NOECO", "B_FON_SMECO",
                          "B_HON_SMECO", "B_FON_NOECO_NOENV", "B_HON_NOECO_NOENV",  "F_FON_NOECO", 
                          "F_HON_NOECO", "F_FON_SMECO", "F_HON_SMECO", "F_FON_NOECO_NOENV", 
                          "F_HON_NOECO_NOENV")


# rename SY to SI to match my data
mandanas_data$PORT[which (mandanas_data$PORT == "SY")] <- "SI"
mandanas_data$DEST[which (mandanas_data$DEST == "SY")] <- "SI"
mandanas_data$PORT[is.na(mandanas_data$PORT)] <- "NX"
mandanas_data$DEST[is.na(mandanas_data$DEST)] <- "NX"

# check full table 
mandanas_data <- mandanas_data %>% arrange(PORT, DEST) %>% print(n = Inf)


## Left-join Mandana's results to model data 
## -----------------------------------------

# add Mandanas information to model data tables 
all_model_data_appended <- lapply(all_model_data, left_join_using_port_sets, mandanas_data)

# correct list labels as these will be used as file names
names(all_model_data_appended) <- gsub(".csv", "_with_hon_info.csv", names(all_model_data_appended))

# write files
for (i  in seq(1:length(all_model_data_appended))){
   # set destination path from list label
   path = names(all_model_data_appended[i])
   # diagnostic message
   message ("Writing \"", path , "\".")
   # write files
   write_csv(all_model_data_appended[[i]], path)
}

#' <!-- #################################################################### -->
#'
#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
