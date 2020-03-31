# Environment preparation
# =======================

rm(list=ls())

# Load Packages
# --------------
library ("tidyverse") # dplyr and friends
library ("ggplot2")   # for ggCaterpillar
library ("gdata")     # matrix functions
library ("reshape2")  # melting
library ("lme4")      # mixed effect model
library ("sjPlot")    # mixed effect model - with plotting
library ("cowplot")   # exporting ggplots
library ("formula.tools") # better formatting of formulas
library ("stringr")   # better string concatenation
library ("magrittr")  # back-piping (only used for type conversion)
library ("knitr")     # to output results table
library("rmarkdown")  # to output results table
library("kableExtra") # better table formatting in this script
library("lme4")
library("MASS")
library("lattice")


# Functions
# ----------

# helper script 
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

# Function "Not in"
`%!in%` = Negate(`%in%`)

# Data read-in 
# =============

# define file path components for listing 
model_input_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Results"
input_pattern <- glob2rx("01_results_euk_asv00_deep_UNIF_model_data_2020-Apr-01-11-13-59_joined*.csv")

# read all file into lists for `lapply()` usage
model_input_files <- list.files(path=model_input_folder, 
  pattern = input_pattern, full.names = TRUE)

# store all tables in list and save input filenames alongside - skipping "X1" 
#  in case previous tables have column numbers, which they should not have anymore.
model_input_data <- suppressWarnings(lapply(model_input_files, 
  function(listed_file)  read_csv(listed_file, col_types = cols('X1' = col_skip()))))
names(model_input_data) <- model_input_files

# subset datasets
model_input_data <- list(model_input_data[[2]])
  
# subset names
model_input_files <- list(model_input_files[[2]])
print(model_input_files)

# set names
names(model_input_data) <- model_input_files

# final ***list*** for downstream analysis - here only with one item
# joined, no NA's, with Pearl Harbour data
model_input_data

# extract data from (currently one-item) list 
dta <-  model_input_data[[1]]

# Poisson GLM - doesn't run 
# ===========
# also check https://ase.tufts.edu/gsc/gradresources/guidetomixedmodelsinr/mixed%20model%20guide.html

M1 <- glmer(RESP_UNIFRAC ~ VOY_FREQ + ECO_DIFF + PRED_ENV + (1 | PORT) + (1 | DEST), family = 'poisson', data = dta)

# Poisson won't work with non integer values, I guess because modelling count data with non-integers is nonsensical.

# Run look at results  
summary(M1) # no meaningful results

# Check for over/under-dispersion in the model 
E2 <- resid(M1, type = "pearson")
N <- nrow(dta)
p <- length(coef(M1))
sum(E2^2) / (N - p) # 0.008241595, should be close to 1

# Negative Binomial GLM - doesn't run
# =====================

M2 <- glm.nb(glm(RESP_UNIFRAC ~ VOY_FREQ + ECO_DIFF + PRED_ENV + (1 | PORT) + (1 | DEST), link = 'log', data = dta))

summary(M2)

# Dispersion statistic
E2 <- resid(M2, type = "pearson")
N <- nrow(OBFL)
p <- length(coef(M2)) + 1 # '+1' is for variance para meter in NB
sum(E2^2) / (N - p)

# Zero-inflated mode
# ================== 


M3 <- zeroinfl(RESP_UNIFRAC ~ VOY_FREQ + ECO_DIFF + ENV_DIFF_ (1 | PORT) + (1 | DEST)) ## Predictor for the Poisson p rocess
VOY_FREQ + ECO_DIFF + ENV_DIFF_ (1 | P ORT) + (1 | DEST), ## Predictor for the Bernoulli process;
summary(M3)
dist = 'poisson',
data = your data)## Log-likelihood: -177.1 on 4 Df# Dispersion statistic
E2 <- resid(M3, type = "pearson") N <- nrow(OBFL)
p <- length(coef(M3)) sum(E2^2) / (N - p)











