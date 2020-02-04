#' ---
#' output: "pdf_document"
#' title: "Apply Mixed Effect Models to Extended Modelling Input Data"
#' name: "Paul Czechowski"
#' date: "31-January-2020"
#' toc: "true"
#' highlight: "zenburn"
#' ---
#' 
#' # Preamble
#' 
#' This script version tests the influence of environmental data and 
#' the influence of voyages against biological responses. This script
#' only considers port in between which routes are present, such ports are
#' fewer the ports which have environmental distances available. (All ports 
#' with measurements have environmental distances available.)
#'
#' This script needs all R scripts named `500_*.R` to have run successfully,
#' apart from `/Users/paul/Documents/CU_combined/Github/500_05_UNIFRAC_behaviour.R`
#' It should then be called using a shell script. It will only accept certain files
#' currently, and otherwise abort. For further information understand section Environment
#' preparation. Also check `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
#'
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_83_get_mixed_effect_model_results.R", clean = TRUE)`.
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
  
  data_item <- data_item %>% select(vars_to_keep)

  message("- Intermediate dimensions are: ", paste0( (dim(data_item)), " "), ".")
  
  # remove superflous rows
  message("- Undefined rows have been removed, assuming they were real \"NA\" and not \"0\".")
  
  data_item %>% na.omit
  
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
  # Original formula used by Paul:
  # Unifrac ~ Voyage counts  + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ PRED_TRIPS + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Original formula adjusted with Mandana's frequencies:
  # Unifrac ~ Voyage frequencies + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ VOY_FREQ + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Formulas from Word document with Mandana's ballast risk estimates:
  # Unifrac ~ Ballast FON shipping + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ B_FON_NOECO + ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Unifrac ~ Ballast HON shipping + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ B_HON_NOECO + ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Unifrac ~ Ballast FON risk* + ~~ecoregion~~ / env similarity + random port effects
  as.formula(RESP_UNIFRAC ~ B_FON_SMECO + (1 | PORT) + (1 | DEST)),

  # Unifrac ~ Ballast HON risk* + ~~ecoregion~~ / env similarity + random port effects
  as.formula(RESP_UNIFRAC ~ B_HON_SMECO + (1 | PORT) + (1 | DEST))
)

#' 
#' ##  Define null models
#'
#' For Anova comparison. Order *must* be the same as in list `full_models`.

null_formulae <- list(
  # Original formula used by Paul:
  # Unifrac ~ Voyage counts  + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Original formula adjusted with Mandana's frequencies:
  # Unifrac ~ Voyage frequencies + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Formulas from Word document with Mandana's ballast risk estimates:
  # Unifrac ~ Ballast FON shipping + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Unifrac ~ Ballast HON shipping + env similarity + ecoregion + random port effects
  as.formula(RESP_UNIFRAC ~ ECO_DIFF + (1 | PORT) + (1 | DEST)),

  # Unifrac ~ Ballast FON risk* + ~~ecoregion~~ / env similarity + random port effects
  # message("Considering only random effects in null model - unsure if this is possible.")
  as.formula(RESP_UNIFRAC ~ (1 | PORT) + (1 | DEST)),

  # Unifrac ~ Ballast HON risk* + ~~ecoregion~~ / env similarity + random port effects
  # message("Considering only random effects in null model - unsure if this is possible.")
  as.formula(RESP_UNIFRAC ~ (1 | PORT) + (1 | DEST))
)

#' # Read in and format data
#'
#' Please refer to project README.md file for further details on previous processing steps (dated 31-Jan-2020). 

# define file path components for listing 
model_input_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Results"
model_input_pattern <- glob2rx("??_results_euk_*_model_data_*.csv")

# read all file into lists for `lapply()` usage
model_input_files <- list.files(path=model_input_folder, 
  pattern = model_input_pattern, full.names = TRUE)

# store all tables in list and save input filenames alongside - skipping "X1" 
#  in case previous tables have column numbers, which they should not have anymore.
model_input_data <- suppressWarnings(lapply(model_input_files, 
  function(listed_file)  read_csv(listed_file, col_types = cols('X1' = col_skip()))))
names(model_input_data) <- model_input_files



#' # Obtaining modelling results
#'
#' ## Initialize results table
#' 
#' So that it can be filled in the loop.

analysis_summaries <- expand.grid(seq(model_input_data), seq(full_formulae))
analysis_summaries <- as_tibble(analysis_summaries)
analysis_summaries <- setNames(analysis_summaries, c("DIDX", "FIDX"))
analysis_summaries <- analysis_summaries %>% add_column(AIC = 0, DATA = 0, FRML = 0, SIGN = 0)

analysis_summaries$AIC  %<>% as.double
analysis_summaries$DATA %<>% as.character
analysis_summaries$FRML  %<>% as.character
analysis_summaries$SIGN  %<>% as.double

# data sets are at 
as.integer(analysis_summaries[1, 1])

# formulas are at 
as.integer(analysis_summaries[1, 2])

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

# loop over formulae
for (i in seq(full_formulae)){
  
  # loop over dat sets
  for (j in seq(model_input_data)){
  
  message("**Using formula: ", as.character(full_formulae[[i]]), " with data: ", as.character(basename(names(model_input_data)[[j]])), "** ")
  
  # define current model formula for parsing
  full_formula <- full_formulae[[i]]
  null_formula <- null_formulae[[i]]
     
  # define current data table for subsetting
  model_data_raw <- model_input_data[[j]]
         
  # match input table dimensions to current model formulae
  model_data <- match_data_to_formula(full_formula, model_data_raw)
     
  # calculate full model
  full_model <- calculate_model(full_formula, model_data)
     
  # calculate null model
  null_model <- calculate_model(null_formula, model_data)
     
  # print model summary and evaluations
  message("\nGetting Model Summary: ")
  sm <- summary(full_model)
  print(sm)
      
  message("\nGetting Model ANOVA: ")
  an <- try(anova(full_model, null_model))
  print(sm)
  try(print(an))

  # plot model coefficients
  message("\nPlotting Model Coefficients: ")
  plot <- plot_model(full_model, show.values = TRUE, value.offset = .3,
   type = "std", 
   title = paste("Coefficients for formula \"", as.character(full_formula),
   "\" and variables \"", str_c(names(model_data), collapse = "\", \""),"\" of input file: \"",
   basename(names(model_input_data)[[j]]), "\"." ))
    
  print(plot)

  }
}




#' # Modelling

#' ## Get full models

# loop over input tables and models

# full_models














# flatten list





#' ## Get ANOVAs

#' ## Check AICs

#' ## Plot model results





# lmer( full_models[[1]], data = model_input_data[[1]], REML=FALSE)
# 
# 
# #' # Define null models
# 
# 
# # 
# 
# # anova using mapply over lists
# 
# 
# #' For reasons of simplicity loop over list to generate model results and plots for each inout data set.
# 
# #'
# #' # Apply models to list of formatted input tables 
# #' 
# #' ## Model formulas: 
# #'
# #' ### Original formula used by Paul:
# #' 
# #' 0. ` Unifrac ~ Voyage counts  + env similarity + ecoregion + random port effects`:
# 
# # full_model <- lmer(RESP_UNIFRAC ~ PRED_TRIPS + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST), data = vars, REML=FALSE)
# 
# #' ### Original formula adjusted with Mandana's frequencies:
# #'
# #' 1. `Unifrac ~ Voyage frequencies + env similarity + ecoregion + random port effects`:
# 
# # full_model <- lmer(RESP_UNIFRAC ~ VOY_FREQ + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST), data = vars, REML=FALSE)
# 
# #' ### Formulas from Word document with Mandana's ballast risk estimates:
# #' 
# #' 2.  `Unifrac ~ Ballast FON shipping + env similarity + ecoregion + random port effects`:
# 
# # full_model <- lmer(RESP_UNIFRAC ~ B_FON_NOECO + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST), data = vars, REML=FALSE)
# 
# #' 3.  `Unifrac ~ Ballast HON shipping + env similarity + ecoregion + random port effects`:
# 
# # full_model <- lmer(RESP_UNIFRAC ~ B_HON_NOECO + PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST), data = vars, REML=FALSE)
# 
# #' 4.  `Unifrac ~ Ballast FON risk* + ~~ecoregion~~ / env similarity + random port effects` (Ecoregion from Word documents substituted with Environmental Similarity since Mandana considers Ecoregions?):
# 
# # full_model <- lmer(RESP_UNIFRAC ~ B_FON_SMECO + PRED_ENV + (1 | PORT) + (1 | DEST), data = vars, REML=FALSE)
# 
# #' 5.  `Unifrac ~ Ballast HON risk* + ~~ecoregion~~ / env similarity + random port effects` (Ecoregion from Word documents substituted with Environmental Similarity since Mandana considers Ecoregions?):
# 
# # full_model <- lmer(RESP_UNIFRAC ~ B_HON_SMECO + PRED_ENV + (1 | PORT) + (1 | DEST), data = vars, REML=FALSE)
# 
# #'
# 
# # ------------------------- old code below ----------------------
# # 
# # Checking response and predictor variable distributions
# # 
# # # Plots -  create list to store plots for export further below
# # 
# # ## Responses
# # plot_l <- list()
# # 
# # plot_l[[1]] <- ggplot(model_data, aes (x=RESP_UNIFRAC)) + 
# #               geom_density() +
# #               facet_grid(~ECO_DIFF) +
# #               theme_bw()
# # 
# # plot_l[[2]] <- ggplot(model_data,aes (x=PRED_ENV))+ 
# #               geom_density()+
# #               facet_grid(~ECO_DIFF)+
# #               theme_bw()
# # 
# # 
# # ## Pedictors
# # 
# # plot_l[[3]] <-  ggplot(model_data,aes (x=PRED_TRIPS))+ 
# #                geom_density()+
# #                facet_grid(~ECO_DIFF)+
# #                theme_bw()
# # 
# # plots <- plot_grid(plot_l[[1]], plot_l[[2]], plot_l[[3]],
# #           labels=c("Eco(T/F)", "Eco(T/F)", "Eco(T/F)" ))
# # 
# # save_plot(args[5], plots, ncol = 1, nrow = 1, base_height = 5,
# #   base_aspect_ratio = 1.1, base_width = 10)
# #   
# # 
# # Appending to output file.
# # capture.output( file=args[6], append=TRUE, print("Aggregation of biological distance means per ecoregion. (Response variable)"))
# # capture.output( file=args[6], append=TRUE, aggregate(model_data$RESP_UNIFRAC~model_data$ECO_DIFF, FUN=mean))
# # 
# # capture.output( file=args[6], append=TRUE, print("Aggregation of environmental distance means per ecoregion (Predictor variable)."))
# # capture.output( file=args[6], append=TRUE, aggregate(model_data$PRED_ENV~model_data$ECO_DIFF, FUN=mean))
# # 
# # capture.output( file=args[6], append=TRUE, print("Aggregation of summed voyage counts means per ecoregion (Predictor variable)."))
# # capture.output( file=args[6], append=TRUE, aggregate(model_data$PRED_TRIPS~model_data$ECO_DIFF, FUN=mean))
# # 
# # '
# # ' <!-- #################################################################### -->
# # '
# # ' <!-- #################################################################### -->
# # '
# # 
# # model_data <- model_data %>%  mutate_if(is.numeric, scale(.,scale = FALSE))
# # pairs(RESP_UNIFRAC ~ PRED_ENV * PRED_TRIPS, data=model_data, main="Simple Scatterplot Matrix")
# # 
# # ' # Select variables for modelling and build models 
# # message("Saving this model data to file:")
# # print(model_data)
# # 
# # Sorting columns
# # model_data <- model_data %>% arrange(PORT, desc(PRED_TRIPS), DEST)
# # 
# # correcting trips for Pearl Harbour
# # model_data <- model_data %>% mutate (PRED_TRIPS = ifelse(PORT  == "PH", "0", PRED_TRIPS))
# # model_data <- model_data %>% mutate (PRED_TRIPS = ifelse(DEST  == "PH", "0", PRED_TRIPS))
# # 
# # model_data$PORT <- as.factor(model_data$PORT)
# # model_data$DEST <- as.factor(model_data$DEST)
# # model_data$ECO_DIFF <- as.factor(model_data$ECO_DIFF)
# # model_data$PRED_TRIPS <- as.numeric(model_data$PRED_TRIPS)
# # 
# # 
# # write data as per input path - keep close to variable selection below
# # write.csv(model_data, file = args[4])
# # 
# # select  columns for model
# # vars <- model_data %>% select(RESP_UNIFRAC, PORT, DEST, ECO_DIFF, PRED_ENV, PRED_TRIPS)
# # message("Using this model data for regression:")
# # print(vars)
# # 
# # ' ## Full Model and checking 
# # vars_model_full <- lmer(RESP_UNIFRAC ~ PRED_ENV + PRED_TRIPS + ECO_DIFF + (1 | PORT) + (1 | DEST), data=vars, REML=FALSE)
# # 
# # vars_model_full <- lm(RESP_UNIFRAC ~ PRED_ENV + PRED_TRIPS + ECO_DIFF, data=vars)
# # 
# # ' ### Model Summary
# # 
# # Appending to output file.
# # capture.output( file=args[6], append=TRUE,   message("Considered vraiables"))
# # capture.output( file=args[6], append=TRUE,   print(vars_model_full))
# #   
# # capture.output( file=args[6], append=TRUE,   message("Random effect model summary"))
# # capture.output( file=args[6], append=TRUE,   print(summary(vars_model_full)))
# #   
# # capture.output( file=args[6], append=TRUE,  message("Intercepts for factor levels"))
# # capture.output( file=args[6], append=TRUE,  print(coef(vars_model_full))) #intercept for each level
# # 
# # For linear models, you can also plot standardized beta coefficients,
# # https://cran.r-project.org/web/packages/sjPlot/vignettes/plot_model_estimates.html
# # using type = "std" or type = "std2". These two options differ in the way how
# # coefficients are standardized. type = "std2" plots standardized beta values,
# # however, standardization follows Gelman’s (2008) suggestion, 
# # rescaling the estimates by dividing them by two standard deviations
# # instead of just one. (Use, type = std)
# # 
# # p <- plot_model(vars_model_full, show.values = TRUE, value.offset = .3,
# #    type = "std", 
# #    title = args[8])
# # 
# # save_plot(args[7], p, ncol = 1, nrow = 1, base_height = 8,
# #   base_aspect_ratio = 1.1, base_width = 8)
# # 
# # ' Residuals
# # plot(vars_model_full)
# # 
# # # check normality of the residuals
# # qqnorm(residuals(vars_model_full))
# # 
# # # plotting random effects - trial after https://stackoverflow.com/questions/13847936/in-r-plotting-random-effects-from-lmer-lme4-package-using-qqmath-or-dotplot
# # qqplot of the random effects with their variances
# # "The last line of code produces a really nice plot of each intercept with the error around each estimate."
# # qqmath(ranef(vars_model_full, condVar = TRUE), strip = FALSE)$PORT
# # qqmath(ranef(vars_model_full, condVar = TRUE), strip = FALSE)$DEST
# # 
# # 
# # ' ### Leverage of Observations
# # 
# # # model is not influenced by one or a small set of observations ?
# # ggplot(data.frame(lev=hatvalues(vars_model_full),pearson=residuals(vars_model_full, type="pearson")),
# #       aes(x=lev,y=pearson)) + geom_point() + theme_bw()
# # 
# # ' ## Null Model and checking 
# # 
# # vars_model_null <- lmer(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST), data=vars, REML=FALSE)
# # 
# # vars_model_null <- lm(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF, data=vars)
# # 
# # ' ### Model Summary
# # summary(vars_model_null)
# # 
# # Appending to output file.
# # ' ## Model Significance
# # capture.output( file=args[6],   anova(vars_model_null, vars_model_full))
# 
# #' <!-- #################################################################### -->
# #'
# #' # Session info
# #'
# #' The code and output in this document were tested and generated in the
# #' following computing environment:
# #+ echo=FALSE
# sessionInfo()
# 
# #' # References
