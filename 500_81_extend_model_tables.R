#' ---
#' title: "Extend modelling input"
#' author: "Paul Czechowski"
#' date: "09-April-2020"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---
#' 
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_81_extend_model_tables.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.

# Environment preparation
# =======================

# Clear Environment
rm(list=ls())

# Load Packages
library ("tidyverse") # dplyr and friends

# Functions
# ---------

# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

# Function removing "PH" rows via `lapply` call
remove_ph_rows = function(listed_table){
  require("tidyverse")
  listed_table %>% filter(!PORT %in% c("PH")) %>% filter(!DEST %in% c("PH")) -> listed_table
  return(listed_table)
}

# Function for sorting columns in a Tibble to prepare left join
prepare_join = function (list_element) {
  
  require ("tidyverse")
   
  # Step 1: In each line sort values in `PORT`, and `DEST` columns alphabetically
  # for joining with downstream data
  list_element[ ,1:2] <- as_tibble(t(apply(list_element[ ,1:2], 1,  sort)))
  
  # Step 2: Re-sort
  list_element <- list_element %>% arrange(PORT, DEST)
  
  return(list_element)
}

# Function to left-join column-corrected data. 
left_join_data <- function (tibble_list, tibble_single){

  # copy data within function 
  data_left <- tibble_list
  data_right <- tibble_single

  # in each data set, create ROUTE variables at beginning of tibble
  data_left  <- data_left %>% unite(ROUTE, PORT, DEST, sep = "-", remove = FALSE) %>%
 			  select(ROUTE, everything()) 
  data_right <- data_right %>% unite(ROUTE, PORT, DEST, sep = "-", remove = FALSE) %>%
                select(ROUTE, everything())

  # join by route variable by route vector
  data_joined <- left_join(data_left, data_right, by = "ROUTE") # %>% print(n = Inf)

  # reformat table - 1: delete superfluous columns; 2: rename columns
  data_joined <- data_joined %>% select(-one_of("ROUTE", "PORT.y", "DEST.y")) %>% 
                 rename(PORT = PORT.x, DEST = DEST.x) # %>% print(n = Inf)

  # return data
  return (data_joined)

}

# Function to convert NA values to 0 values
set_zeros <- function (tibble_list, variables){
  
  # set zeros for in cases where there are NA's among selected columns
  tibble_list[c(variables)][is.na(tibble_list[c(variables)])] <- 0
  
  return(tibble_list)
}

# Function to standardize selected variables
scale_variables <- function (tibble_list, variables){
  
  message("Scaling and centering a copy of the data")
  
  tibble_list <- tibble_list %>% mutate_at(variables, funs(c(scale(., center = TRUE, scale = TRUE))))
  
  return(tibble_list)
}

remove_self_connections <- function(tibble) {
  tibble <- tibble  %>% filter(PORT != DEST)
  return (tibble)
}

# Function to remove intra-port rows

# Read and format network predictors 
# ==================================

# data  from 19.11.2019
# ---------------------
# mandanas_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/191105_shipping_estimates.csv")
#
# data from 28.01.2020
# ---------------------
# mandanas_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200128_all_links_1997_2018.csv")
#
# data from 27.02.2020
# ---------------------

mandanas_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_All_links_1997_2018_updated.csv")
names(mandanas_data)

# correct variable names for downstream compatibility 
# ----------------------------------------------------
# notes for names correction:
# 
# old names
#     "source"              "target"              "voyage_freq"         "Ballast FON noEco"   "Ballast HON noEco"   "Ballast FON sameEco"
#     "Ballast HON sameEco" "Fouling FON noEco"   "Fouling HON noEco"   "Fouling FON sameEco" "Fouling HON sameEco
#
# new names 
#      "PORT",                "DEST",              "VOY_FREQ",           "B_FON_NOECO",        "B_HON_NOECO",        "B_FON_SMECO", 
#      "B_HON_SMECO",         "F_FON_NOECO",       "F_HON_NOECO",        "F_FON_SMECO",        "F_HON_SMECO")

names(mandanas_data) <- c("PORT", "DEST", "VOY_FREQ", "B_FON_NOECO", "B_HON_NOECO", "B_FON_SMECO",
                          "B_HON_SMECO", "B_FON_NOECO_NOENV", "B_HON_NOECO_NOENV",  "F_FON_NOECO", 
                          "F_HON_NOECO", "F_FON_SMECO", "F_HON_SMECO", "F_FON_NOECO_NOENV", 
                          "F_HON_NOECO_NOENV")

# correct port names for downstream compatibility 
# -----------------------------------------------

mandanas_data$PORT[which (mandanas_data$PORT == "SY")] <- "SI"
mandanas_data$DEST[which (mandanas_data$DEST == "SY")] <- "SI"
mandanas_data$PORT[is.na(mandanas_data$PORT)] <- "NX"
mandanas_data$DEST[is.na(mandanas_data$DEST)] <- "NX"

# make bidirectional information unidirectional 
# ----------------------------------------------

# Step 1: Check groups and tally of unmodified data.  
#  200 groups and each group with 1 PORT and DEST combination (= route)
mandanas_data %>% arrange(PORT, DEST) %>% group_by(PORT, DEST) %>% 
                  add_tally() %>% print(n = Inf)

# Step 2: In each line sort values in `PORT`, and `DEST` columns alphabetically
#  for regrouping
mandanas_data_bi <- mandanas_data # copy for sanity reasons.
# could also call function 
mandanas_data_bi <- prepare_join(mandanas_data_bi) %>% print(n = Inf)

# Step 3: Check groups and tally of unmodified data.  
#  113 groups and each group with 2 or 1 PORT and DEST combination (= route)
mandanas_data_bi %>% arrange(PORT, DEST) %>% group_by(PORT, DEST) %>% 
                     add_tally() %>% print(n = Inf)

# Step 4: Apply re-grouping.
mandanas_data_bi <- mandanas_data_bi %>% arrange(PORT, DEST) %>% group_by(PORT, DEST) %>%
                    print(n = Inf)

# Step 5: Sum routes within newly defined groups 
# not averaging so as to not disort data with only one original connection 
mandanas_data_bi <- mandanas_data_bi %>% summarise_if(is.numeric, sum, na.rm = TRUE) %>%
                    arrange(PORT, DEST) %>% print(n = Inf)

# Step 6: Check groups and tally of modified data.  
#  113 groups and each group with 1 PORT and DEST combination (= route) - ok!
mandanas_data_bi %>% arrange(PORT, DEST) %>% group_by(PORT, DEST) %>% 
                     add_tally() %>% print(n = Inf)


# Read-in and format biological responses and environmental predictors
# ====================================================================

# Create list of data frames for downstream application
# -----------------------------------------------------

# define file path components for listing 
model_input_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Results"
model_input_pattern <- glob2rx("??_results_euk_*2020-Apr-09*.csv") # adjust here for other / newer data sets

# read all file into lists for `lapply()` usage
model_input_files <- list.files(path=model_input_folder, pattern = model_input_pattern, full.names = TRUE)

# store all tables in list and save input filenames alongside - skipping "X1" 
#  in case previous tables have column numbers, which they should not have anymore.
#  Warnings for column names X1 are not a worry.
model_input_data <- lapply(model_input_files, function(listed_file)  read_csv(listed_file, col_types = cols('X1' = col_skip())))
names(model_input_data) <- model_input_files

# Copy data but exclude `PH` rows
# --------------------------------

# remove "PH entries in copied table data and modify list labels for later file names 
model_no_ph_data <- lapply(model_input_data, remove_ph_rows)
names(model_no_ph_data) <- gsub(".csv", "_no_ph.csv", names(model_no_ph_data))

# Combine lists of tables with PH and non-PH data
# -----------------------------------------------

all_model_data <- append(model_input_data, model_no_ph_data)
names(all_model_data)

# match PORT DEST columns with Mandana's format to simplify downstream joining
# ---------------------------------------------------------------------------

# for debugging only - unmodified data
all_model_data[[1]] %>% print(n = Inf)

# sort PORT DEST columns and re-sort columns for subsequent left joining
all_model_data <-  lapply(all_model_data, prepare_join)

# for debugging only - prepared data 
all_model_data[[1]] %>% print(n = Inf)


# Left-join Mandana's results to model data 
# =========================================

model_data_joined <- lapply(all_model_data, left_join_data, mandanas_data_bi)

# change file names
names(model_data_joined) <- gsub(".csv", "_joined.csv", names(model_data_joined))


# Create datasets with and without zeros
# =======================================

# Which variables to be set to 0? 
selected_vars <- c("VOY_FREQ", "B_FON_NOECO", "B_HON_NOECO", "B_FON_SMECO",
                   "B_HON_SMECO", "B_FON_NOECO_NOENV", "B_HON_NOECO_NOENV",
                   "F_FON_NOECO", "F_HON_NOECO", "F_FON_SMECO", "F_HON_SMECO",
                   "F_FON_NOECO_NOENV", "F_HON_NOECO_NOENV")

# Replace NA's with 0 in dat set copy
model_na_to_zero <- lapply(model_data_joined, set_zeros, selected_vars)

# Adjust names in data set copy
names(model_na_to_zero) <- gsub(".csv", "_no-nas.csv", names(model_na_to_zero))

# Combine lists of tables with NA and 0 data
all_model_data <- append(model_data_joined, model_na_to_zero)
names(all_model_data)


# Create scaled and unscaled data sets 
# =======================================

# Which variables to be set to scale? 
selected_vars <- c("PRED_ENV", "VOY_FREQ","B_FON_NOECO", "B_HON_NOECO", "B_FON_SMECO",
                   "B_HON_SMECO", "B_FON_NOECO_NOENV", "B_HON_NOECO_NOENV", "F_FON_NOECO",
                   "F_HON_NOECO", "F_FON_SMECO", "F_HON_SMECO", "F_FON_NOECO_NOENV",
                   "F_HON_NOECO_NOENV")

# Scale variables data set copy
all_model_data_scaled <- lapply(all_model_data, scale_variables, selected_vars)

# Adjust names in data set copy
names(all_model_data_scaled) <- gsub(".csv", "_scaled.csv", names(all_model_data_scaled))

# Combine lists of tables with scaled and unscaled data
data_to_write <- append(all_model_data, all_model_data_scaled)
names(data_to_write)


# Remove intra-port rows 
# =========================

data_to_write <- lapply(data_to_write, remove_self_connections)


# Write files
# ===========
for (i  in seq(1:length(data_to_write))){
   # set destination path from list label
   path = names(data_to_write[i])
   # diagnostic message
   message ("Writing \"", path , "\".")
   # write files
   write_csv(data_to_write[[i]], path)
}

# Session info
# ============


#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

