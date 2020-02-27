#' ---
#' title: "Apply Mixed Effect Models to Extended Modelling Input Data"
#' output: 
#'   html_document:
#'   toc: true
#'   toc_float: true
#'   toc_collapsed: true
#' toc_depth: 3
#' number_sections: true
#' theme: lumen
#' ---

#' # Preamble
#' 
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R", clean = TRUE, output_format = "html_notebook")`.
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
library ("gdata")     # matrix functions
library ("reshape2")  # melting
library ("lme4")      # mixed effect model
library ("sjPlot")    # mixed effect model - with plotting
library ("cowplot")   # exporting ggplots
library ("formula.tools") # better formatting of formulas
library ("stringr")    # better string concatenation
library ("magrittr")  # back-piping (only used for type conversion)
#' Functions

# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

#' "Not in" function
`%!in%` = Negate(`%in%`)

#' Function to subset data to fit model variables. Currently there are more 
#' incomplete cases among Notre-Dame predictors then among Cornell predictors.
#' Consider running an extra analysis \n with Cornell data trimmed so as to match Notre Dame data.
match_data_to_formula <- function (formula_item, data_item){
  
  # package loading
  require ("tidyverse")
  
  # message
  message("\nData is subset to fit model variables, but currently there are more incomplete cases among Notre-Dame predictors then among Cornell predictors. Consider running an extra analysis with Cornell data trimmed so as to match Notre Dame data.")
  
  # Setting types
  #   for debugging only
  # print(head(data_item))
  
  message("- Setting types.")
  cols <- c("PORT", "DEST", "ECO_PORT", "ECO_DEST", "ECO_DIFF")
  data_item[cols] <- lapply(data_item[cols], as.factor)  

  #   for debugging only
  # print(head(data_item))
  
        
  # remove superflous columns
  vars_to_keep <- all.vars (formula_item)

  message("- Input dimensions are: ", paste0( (dim(data_item)), " "),  ".")
  message("- Removed variables are: ", paste0( names(data_item)[which(names(data_item) %!in% vars_to_keep)], " "), ".")
  message("- Kept variables are: ", paste0(vars_to_keep, " "), ".")
  
  data_item <- data_item %>% select(all_of(vars_to_keep))

  message("- Intermediate dimensions are: ", paste0( (dim(data_item)), " "), ".")
  
  # remove superflous rows
  message("- Undefined rows have been removed, assuming they were real \"NA\" and not \"0\".")
  
  data_item <- data_item %>% filter(complete.cases(.))
  
  message("- Final dimensions are: ", paste0( (dim(data_item)), " "), ".")
  
  # return table object suitable for modelling with model formula
  return(data_item)

}

#' Calculate random effect model results
calculate_model <- function(formula_item, data_item){
  
  message("\nModelling function received variables: ", paste0(names(data_item) , " "), ".")
  message("   ... dimensions: ", paste0( (dim(data_item)), " "), ".")
  message("   ... formula: ", paste0(formula_item , " "), "." )
  
  model <- lmer(formula_item, data = data_item, REML=FALSE)

  return(model)
}

#' # Model definitions
#' 
#' ##  Define full models
#'
#' following `https://stackoverflow.com/questions/25312818/using-lapply-to-fit-multiple-model-how-to-keep-the-model-formula-self-contain`

full_formulae <- list(
  
  # Original by Paul 
  # as.formula(RESP_UNIFRAC ~ PRED_TRIPS + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # as per email 04.02.2020
  # Unifrac ~ VOY_FREQ + env similarity + ecoregion + random port effects
  # as.formula(RESP_UNIFRAC ~ VOY_FREQ + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
   
  # Unifrac ~ B_FON_NOECO + env similarity + ecoregion + random port effects
  # as.formula(RESP_UNIFRAC ~ B_FON_NOECO + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # Unifrac ~ B_HON_NOECO + env similarity + ecoregion + random port effects
  # as.formula(RESP_UNIFRAC ~ B_HON_NOECO + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST))
  
  # Models as per Jose's email after phone conference 6.02.2020
  # Model 4:
  # as.formula(RESP_UNIFRAC ~ B_FON_NOECO + ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Model 5:
  # as.formula(RESP_UNIFRAC ~ B_HON_NOECO  + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # as per email 13.02.2020 - Erin Grey
  # Model 4:
  # as.formula(RESP_UNIFRAC ~ F_FON_NOECO + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # Model 5:
  # as.formula(RESP_UNIFRAC ~ F_HON_NOECO  + ECO_DIFF + (1 | PORT) + (1 | DEST))
  
  # as per email 27.02.2020
  # 
  # Model A:
  as.formula(RESP_UNIFRAC ~ PRED_TRIPS + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model B: 
  as.formula(RESP_UNIFRAC ~ B_FON_NOECO + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model C:
  as.formula(RESP_UNIFRAC ~ B_HON_NOECO + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model D:
  as.formula(RESP_UNIFRAC ~ B_FON_NOECO_NOENV + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model E: 
  as.formula(RESP_UNIFRAC ~ B_HON_NOECO_NOENV + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST))
)

#' 
#' ##  Define null models
#'
#' For Anova comparison. Order *must* be the same as in list `full_models`.

null_formulae <- list(
  
  # Original by Paul 
  # as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # as per email 04.02.2020
  # Unifrac ~ VOY_FREQ + env similarity + ecoregion + random port effects
  # as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
   
  # Unifrac ~ B_FON_NOECO + env similarity + ecoregion + random port effects
  # as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # Unifrac ~ B_HON_NOECO + env similarity + ecoregion + random port effects
  # as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST))
  
  # Models as per Jose's email after phone conference 6.02.2020
  # Model 4:
  # as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Model 5:
  # as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # as per email 13.02.2020 - Erin Grey
  # Model 4:
  # as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST)),
  
  # Model 5:
  # as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST))
  
  # as per email 27.02.2020
  # 
  # Model A:
  as.formula(RESP_UNIFRAC ~ PRED_ENV+ ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model B: 
  as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model C:
  as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model D:
  as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),
  # Model E: 
  as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST))

)

#' # Read in and format data
#'
#' Please refer to project README.md file for further details on previous processing steps (dated 31-Jan-2020). 

# define file path components for listing 
model_input_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Results"
model_input_pattern <- glob2rx("??_results_euk_asv00*UNIF_model_data_*_with_hon_info.csv")

# read all file into lists for `lapply()` usage
model_input_files <- list.files(path=model_input_folder, 
  pattern = model_input_pattern, full.names = TRUE)

# store all tables in list and save input filenames alongside - skipping "X1" 
#  in case previous tables have column numbers, which they should not have anymore.
model_input_data <- suppressWarnings(lapply(model_input_files, 
  function(listed_file)  read_csv(listed_file, col_types = cols('X1' = col_skip()))))
names(model_input_data) <- model_input_files

# After phone call 6.2.2020 keep only one dataset in list.
# After email call 27.2.2020 keep only one dataset in list. Same as previous.

# subset datasets
model_input_data <- list(model_input_data[[2]], model_input_data[[4]])
print(model_input_data)
  
# subset names
model_input_files <- list(model_input_files[[2]], model_input_files[[4]])
print(model_input_files)

# set names
names(model_input_data) <- model_input_files

#' # Obtaining modelling results
#'
#' ## Initialize results table
#' 
#' So that it can be filled in the loop.

analysis_summaries <- expand.grid(seq(model_input_data), seq(full_formulae))
analysis_summaries <- as_tibble(analysis_summaries)
analysis_summaries <- setNames(analysis_summaries, c("DIDX", "FIDX"))
analysis_summaries <- analysis_summaries %>% add_column(AKAI = 0, PVAL = 0, FRML = 0, DATA = 0)

analysis_summaries$AKAI  %<>% as.double
analysis_summaries$DATA %<>% as.character
analysis_summaries$FRML  %<>% as.character
analysis_summaries$PVAL  %<>% as.double

# use this approach to get around the loop - later
#   define all possible combinations for mapply call
#   for later - starting point
#   analysis_combinations <- expand.grid(seq(model_input_data), seq(full_formulae))
#   setNames(analysis_combinations, c("model_index", "formula_index"))
#   for later - starting point
#   list(model_input_data, full_formulae)

#'
#' ## Calculating Results
#' 
#' Initially using loops, for sanity reasons. While looping fill results table
#' `analysis_summaries`. 
#' Check raw model outputs below for `Writing above results to results table row: n` and look up `n` in both results tables all the way at the end of this page.

# loop over formulae
for (i in seq(full_formulae)){
  
  # loop over dat sets
  for (j in seq(model_input_data)){
  
    message("°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸ °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸ °º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸ ")
    message("\nStarting new analysis, with data index DIDX \"", j , "\" and formula index FIDX \"", i, "\" in Summary Tables." ) 
    message("Using formula: ", as.character(full_formulae[[i]]), " with data: ", as.character(basename(names(model_input_data)[[j]])), ". ")

    # define current model formula for parsing
    full_formula <- full_formulae[[i]]
    null_formula <- null_formulae[[i]]
     
    # define current data table for subsetting
    model_data_raw <- model_input_data[[j]]
         
    # match input table dimensions to current model formulae
    model_data <- match_data_to_formula(full_formula, model_data_raw)
    print(model_data, n = Inf)
  
    # calculate full model
    full_model <- calculate_model(full_formula, model_data)
     
    # calculate null model
    null_model <- calculate_model(null_formula, model_data)
     
    # print model summary and evaluations
    message("\nGetting Model Summary: ")
    sm <- summary(full_model)
    print(sm)
    message("\nGetting Model Coefficients from Summary: ")
    print(sm$coefficients)
      
    message("\nGetting Model ANOVA: ")
    an <- try(anova(null_model, full_model))
    try(print(an))

    # plot model coefficients
    message("\nPlotting Model Coefficients: ")
    plot <- plot_model(full_model, show.values = TRUE, value.offset = .3,
     type = "std", 
     title = paste("Coefficients for formula \"", as.character(full_formula),
     "\" and variables \"", str_c(names(model_data), collapse = "\", \""),"\" of input file: \"",
    basename(names(model_input_data)[[j]]), "\"." ))
  
    print(plot)
  
    # gather results
    #   set current row of results table
    crnt_row <- intersect(which(analysis_summaries$DIDX == j), which(analysis_summaries$FIDX == i))
    # message("Writing above results to results table row (but the table is re-sorted): ", crnt_row)
  
    #    fill results table
    analysis_summaries[crnt_row, ]$AKAI <- extractAIC(full_model)[2]
    analysis_summaries[crnt_row, ]$DATA <- as.character(basename(names(model_input_data)[[j]]))
    analysis_summaries[crnt_row, ]$FRML <- as.character(full_formulae[[i]])
    analysis_summaries[crnt_row, ]$PVAL <- an[2,8]
  
    # keep in mind for further elements from anova object:
    #  > str(an)
    #  Classes ‘anova’ and 'data.frame':	2 obs. of  8 variables:
    #  $ Df        : num  6 7
    #  $ AIC       : num  -158 -159
    #  $ BIC       : num  -145 -144
    #  $ logLik    : num  84.8 86.5
    #  $ deviance  : num  -170 -173
    #  $ Chisq     : num  NA 3.49
    #  $ Chi Df    : num  NA 1
    #  $ Pr(>Chisq): num  NA 0.0617

  }
}

#' # Show Results table
#'
#' Check above raw model out put for `Writing above results to results table row: n` and look up `n` in both tables below.

#'
#' Sort results table by AIC

analysis_summaries <- arrange(analysis_summaries, AKAI)

#' Show results table interactively:

analysis_summaries

#' Show results table on screen:

print(analysis_summaries, n = Inf)

#' # On warning ?`isSingular`
#' 
#'  Complex mixed-effect models (i.e., those with
#' a large number of variance-covariance
#' parameters) frequently result in singular fits,
#' i.e. estimated variance-covariance matrices
#' with less than full rank. Less technically,
#' this means that some "dimensions" of the
#' variance-covariance matrix have been estimated
#' as exactly zero. For scalar random effects such
#' as intercept-only models, or 2-dimensional
#' random effects such as intercept+slope models,
#' singularity is relatively easy to detect
#' because it leads to random-effect variance
#' estimates of (nearly) zero, or estimates of
#' correlations that are (almost) exactly -1 or 1.
#' However, for more complex models
#' (variance-covariance matrices of dimension >=3)
#' singularity can be hard to detect; models can
#' often be singular without any of their
#' individual variances being close to zero or
#' correlations being close to +/-1.
#' 
#'   This function performs a simple test to
#' determine whether any of the random effects
#' covariance matrices of a fitted model are
#' singular. The rePCA method provides more detail
#' about the singularity pattern, showing the
#' standard deviations of orthogonal variance
#' components and the mapping from variance terms
#' in the model to orthogonal components (i.e.,
#' eigenvector/rotation matrices).
#' 
#'   While singular models are statistically well
#' defined (it is theoretically sensible for the
#' true maximum likelihood estimate to correspond
#' to a singular fit), there are real concerns
#' that (1) singular fits correspond to overfitted
#' models that may have poor power; (2) chances of
#' numerical problems and mis-convergence are
#' higher for singular models (e.g. it may be
#' computationally difficult to compute profile
#' confidence intervals for such models); (3)
#' standard inferential procedures such as Wald
#' statistics and likelihood ratio tests may be
#' inappropriate.
#' 
#'   There is not yet consensus about how to deal
#' with singularity, or more generally to choose
#' which random-effects specification (from a
#' range of choices of varying complexity) to use.
#' Some proposals include:
#' 
#'   avoid fitting overly complex models in the
#' first place, i.e. design experiments/restrict
#' models a priori such that the
#' variance-covariance matrices can be estimated
#' precisely enough to avoid singularity
#' (Matuschek et al 2017)
#' 
#'   use some form of model selection to choose a
#' model that balances predictive accuracy and
#' overfitting/type I error (Bates et al 2015,
#' Matuschek et al 2017)
#' 
#'   “keep it maximal”, i.e. fit the most complex
#' model consistent with the experimental design,
#' removing only terms required to allow a
#' non-singular fit (Barr et al. 2013), or
#' removing further terms based on p-values or AIC
#' 
#'   use a partially Bayesian method that produces
#' maximum a posteriori (MAP) estimates using
#' regularizing priors to force the estimated
#' random-effects variance-covariance matrices
#' away from singularity (Chung et al 2013, blme
#' package)
#' 
#'   use a fully Bayesian method that both
#' regularizes the model via informative priors
#' and gives estimates and credible intervals for
#' all parameters that average over the
#' uncertainty in the random effects parameters
#' (Gelman and Hill 2006, McElreath 2015;
#' MCMCglmm, rstanarm and brms packages)

#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
