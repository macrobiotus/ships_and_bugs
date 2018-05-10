#' ---
#' title: "Compare Response and Predictor Matrices using Mixed Effect Models"
#' author: "Paul Czechowski"
#' date: "May 8th, 2018"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---
#' 
#' This script version tests the influence of environmental data and 
#' the influence of voyages against biological responses. This script
#' only considers port in between which routes are present, such ports are
#' fewer the ports which have environmental distances available. (All ports 
#' with measurements have environmental distances available.)
#'
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/500_80_mixed_effect_model.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#' 
#' # Environment preparation
#'
# empty buffer
# ============
rm(list=ls())

# load packages
# =============
library ("gdata")     # matrix functions
library ("gplots")    # R text as image
library ("tidyverse") # dplyr and friends
library ("reshape2")  # melting
library ("lme4")      # mixed effect model
library ("stargazer")
library ("gplots")


# functions
# ==========
# Loaded from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

#'
#' <!-- #################################################################### -->
#'
#' # Data read-in
#'
#' ## Predictors 1 of 2: Voyages
#'
#' This data is only available for ports in between which voyages exist.
#' (Risk Formula is currently `(log(src_heap$ROUT$TRIPS) + 1) * (1 / src_heap$ROUT$EDST)`
#' as defined in `500_30_shape_matrices.R`. Using voyages only for now)

# loading matrix with trips (not risks), not loading "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata")
load("/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full.Rdata")
# checking 
mat_trips[1:10,1:10]

#' ## Predictors 2 of 2: Environmental Distances
#'
#' This data is available for many ports (more ports then shipping routes)
load("/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata")

# checking -- see debugging notes: some port numbers in row-/colnames are not unique
mat_env_dist_full[1:10,1:10]

#'
#' <!-- -------------------------------------------------------------------- -->
#'      
#' ## Responses 1 of 3: Unifrac distance matrix as produced by Qiime 2
#'

# this path should match the parameter combination of the Euler script
resp_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/245_18S_097_cl_edna_core_metrics/distance-matrix.tsv"
resp_mat <- read.table(file = resp_path, sep = '\t', header = TRUE)

# checking
resp_mat[1:10,1:10]
class(resp_mat)

#' ## Responses 2 of 3: Kulczynski distances between ports if all overlap is considered
#'

kulczynski_mat_all_path <- "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_35_shape_overlap_matrices__output__97_overlap_kulczynski_mat_all.Rdata"
load(kulczynski_mat_all_path)
kulczynski_mat_all

#' ## Responses  3 of 3:  Kulczynski distances between ports if pairwise overlap is considered
#'

kulczynski_mat_ovrlp_path <- "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_35_shape_overlap_matrices__output__97_overlap_kulczynski_mat_dual.Rdata"
load(kulczynski_mat_ovrlp_path)
kulczynski_mat_ovrlp

#'
#' <!-- #################################################################### -->
#'
#'
#' <!-- #################################################################### -->
#'
#' # Data formatting 
#' 
#' ## Responses 1 of 3: Unifrac distance matrix as produced by Qiime 2
#'
#' Need to be done before the predictors: Matrix fields need to be averaged
#' across replicates. The resulting ports descriptors are then used to shape
#' predictor data. **NOT** Inverting Unifrac distances to closeness in order to match 
#' `(1 / src_heap$ROUT$EDST)`, which also is a measure of closeness.

# substitute dots `.` in column headers with minus `-` to match row names
colnames(resp_mat) <- gsub( '\\.' , '-', colnames(resp_mat)) 

# set data frame row-names correctly 
rownames(resp_mat) <- resp_mat$X; resp_mat$X <- NULL

# check data frame row and column formatting - better to have them equal 
any(colnames(resp_mat) == rownames(resp_mat))


# Create empty receiving matrix from data frame ...
r_mat_clpsd <- get_collapsed_responses_matrix(resp_mat)

# ... and fill empty receiving matrix. 
r_mat_clpsd <- fill_collapsed_responses_matrix(r_mat_clpsd, resp_mat)

## BEGIN OMISSION
## convert matrix from dissimilarity to similarity ( dissim(x,y) = 1 - sim(x,y))
##  this also requires moving lower triangle to upper triangle, and resetting the
##  lower tiangle. 
# r_mat_clpsd <- apply (r_mat_clpsd, 1, function(x) 1-x)

# upperTriangle(r_mat_clpsd) <- lowerTriangle(r_mat_clpsd, byrow=TRUE)
# END OMMISION 

r_mat_clpsd[lower.tri(r_mat_clpsd, diag = FALSE)] <- NA

#' Finished matrix - Unifrac distance
r_mat_clpsd

#' ## Responses 2 of 3: Kulczynski distances between ports if all overlap is considered
#'
kulczynski_mat_all
kulczynski_mat_all[lower.tri(kulczynski_mat_all, diag = FALSE)] <- NA
kulczynski_mat_all

#' ## Responses  3 of 3:  Kulczynski distances between ports if pairwise overlap is considered
#'
kulczynski_mat_ovrlp
kulczynski_mat_ovrlp[lower.tri(kulczynski_mat_ovrlp, diag = FALSE)] <- NA
kulczynski_mat_ovrlp

#'
#' <!-- -------------------------------------------------------------------- -->
#'      
#' ## Predictors 1 of 2: Voyages
#'

# to save memory: discard completely undefined rows and columns (shrinks from
#  6651 * 6651 to 2332 * 2332
mat_trips <- mat_trips[rowSums(is.na(mat_trips))!=ncol(mat_trips), colSums(is.na(mat_trips))!=nrow(mat_trips) ]

# quick and dirty - manual lookup
#   use order  of response matrix (!!!)
#   here "PH","SP","AD","CH", "BT", "HN", "HT", "LB", "MI"
#   improve (!!!) this. Manual lookup via:
#   `open /Users/paul/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`
mat_trips <- mat_trips[c("2503","1165","3110","2907", "4899", "854", "2503", "2331", "7597"),
                       c("2503","1165","3110","2907", "4899", "854", "2503", "2331", "7597")] 

# Keep lower triangle
mat_trips[lower.tri(mat_trips, diag = FALSE)] <- NA

# predictors - copy names - make automatic !! 
colnames(mat_trips) <- colnames(r_mat_clpsd)
rownames(mat_trips) <- rownames(r_mat_clpsd)

#' Finished matrix - Trips. Needs to be used to filter all other matrices
#' (Other predictors and responses) to the same non-`NA` before analysis.
mat_trips

#'
#' ## Predictors 2 of 2: Environmental distances
#'
# quick and dirty - manual lookup
#   use order  of response matrix (!!!)
#   here "PH","SP","AD","CH", "BT", "HN", "HT", "LB", "MI"
#   improve (!!!) this. Manual lookup via:
#   `open /Users/paul/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`

mat_env_dist <- mat_env_dist_full[c("2503","1165","3110","2907", "4899", "854", "2503", "2331", "7597"),
                                  c("2503","1165","3110","2907", "4899", "854", "2503", "2331", "7597")] 

mat_env_dist[lower.tri(mat_env_dist, diag = FALSE)] <- NA

# predictors - copy names - make automatic !! 
colnames(mat_env_dist) <- colnames(r_mat_clpsd)
rownames(mat_env_dist) <- rownames(r_mat_clpsd)

#' Convert distances to closeness in order to comply with formula part `(1 / src_heap$ROUT$EDST)`
# mat_env_dist <- 1/mat_env_dist


#' Finished matrix - Inverted environmental distances. Needs to be filtered
#' to match predictors influenced by available voyages before analysis.
mat_env_dist

#'
#' <!-- #################################################################### -->
#'
#'
#' <!-- #################################################################### -->
#'
#' ## Getting Dataframes for modelling 
#'

# create named list with objects
mat_list <- list (r_mat_clpsd, kulczynski_mat_all, kulczynski_mat_ovrlp, 
                   mat_env_dist, mat_trips) 

mat_list <- setNames(mat_list, c("resp_unifrac", "resp_kulczynski_all", "resp_kulczynski_pair", 
                     "pred_env", "pred_trips"))

# Are all matrix dimesions are the same?
var(c(sapply (mat_list, dim))) == 0

# Are all matrices symmetrical and have the same rownames and column names
all(sapply (mat_list, rownames) == sapply (mat_list, colnames))

# melt data frames for joining 
df_list <- lapply (mat_list, function(x) data.frame(x)  %>%
                             rownames_to_column("PORT") %>%
                             melt(., id.vars = "PORT"))

# join dataframes and name columns
model_data_raw <- df_list %>% reduce(inner_join, by = c("PORT", "variable")) %>%
                          setNames(c("PORT", "DEST", toupper(names(mat_list))))
class(model_data_raw)

# remove incomplete cases - only ignoring lower half of matrix, otherwise remove 
#  column selector
#model_data <- model_data_raw %>% filter(complete.cases(.[3:6]))
model_data <- model_data_raw %>% filter(complete.cases(.))

class(model_data)

# add ecoregion as per:
#   @1. Spalding, M. D. et al. Marine Ecoregions of the World: A Bioregionalization 
#    of Coastal and Shelf Areas. Bioscience 57, 573@583 (2007).
# write as function !!!!!!!!

model_data <- model_data %>% add_column("ECO_PORT" = NA)
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("HN", "PH"), "EIP", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("SP"), "CIP", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("AD"), "TAA", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("CH","BT","MI", "HT"), "TNA", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("LB"), "TNP", model_data$"ECO_PORT"))

model_data <- model_data %>% add_column("ECO_DEST" = NA)
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("HN", "PH"), "EIP", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("SP"), "CIP", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("AD"), "TAA", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("CH","BT","MI", "HT"), "TNA", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("LB"), "TNP", model_data$"ECO_DEST"))

model_data <- model_data %>% add_column("ECO_DIFF" = NA)
model_data <- model_data %>% mutate (ECO_DIFF = ifelse(ECO_PORT == ECO_DEST , FALSE, TRUE))

#'
#' <!-- #################################################################### -->
#'
#' <!-- #################################################################### -->
#'

# quick and dirty - improves model (apparently) - move elsewhere
model_data$PRED_TRIPS <- log(model_data$PRED_TRIPS)
# model_data <- model_data %>%  mutate_if(is.numeric, scale(.,scale = FALSE))

pairs(RESP_UNIFRAC ~ PRED_ENV * PRED_TRIPS,data=model_data, main="Simple Scatterplot Matrix")

#' # Select variables for modelling and build models 
head (model_data)

vars <- model_data %>% select(RESP_UNIFRAC, PORT, DEST, ECO_DIFF, PRED_ENV, PRED_TRIPS)

#' ## Full Model and checking 

vars_model_full <- lmer(RESP_UNIFRAC ~ PRED_ENV*PRED_TRIPS + ECO_DIFF + (1 | PORT) + (1 | DEST), data=vars, REML=FALSE)

#' ### Model Summary
summary(vars_model_full)

# stargazer(vars_model_full, type = "html", title="Regression Results", align=TRUE,
#             dep.var.labels=c("UNIFRAC distance"), covariate.labels=c("Environmental Distance",
#             "Voyage Count", "Different Ecoregions", "Env. Dist. and Voyage Count"), omit.stat=c("LL","ser","f"),
#             no.space=TRUE, out = "/Users/paul/Box Sync/CU_NIS-WRAPS/170728_external_presentations/171128_wcmb/180429_wcmb_talk/500_80_mixed_effect_model__full.html")

# following https://www.ssc.wisc.edu/sscc/pubs/MM/MM_DiagInfer.html

#' ### Model Residuals
plot(vars_model_full)

## check normality of the residuals
qqnorm(residuals(vars_model_full))

## plots of the residuals versus each of the variables - 1 of 2 - linear model ok?
ggplot(data.frame(x1=vars$PRED_ENV,pearson=residuals(vars_model_full,type="pearson")),
      aes(x=x1,y=pearson)) + geom_point() + theme_bw()

## plots of the residuals versus each of the variables - 2 of 2 - linear model ok?
ggplot(data.frame(x2=vars$PRED_TRIPS,pearson=residuals(vars_model_full,type="pearson")),
      aes(x=x2,y=pearson)) + geom_point() + theme_bw()

#' ### Leverage of Observations

## model is not influenced by one or a small set of observations ?
ggplot(data.frame(lev=hatvalues(vars_model_full),pearson=residuals(vars_model_full, type="pearson")),
      aes(x=lev,y=pearson)) + geom_point() + theme_bw()

#' ### _p_value using `lmertest()`

# extract coefficients
coefs <- data.frame(coef(summary(vars_model_full)))

# re-fit model
library ("lmerTest") 

m.semTest <- lmer(RESP_UNIFRAC ~ PRED_ENV * PRED_TRIPS + ECO_DIFF + (1| PORT) + (1| DEST), data=vars, REML=FALSE)

# get Satterthwaite-approximated degrees of freedom
# coefs$df.Satt <- coef( )[, 3]
# 
# # get approximate p-values
# coefs$p.Satt <- coef(summary(m.semTest))[, 5]
# coefs
summary(m.semTest)

#' ## Null Model and checking 

vars_model_null <- lmer(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST), data=vars, REML=FALSE)
#' ### Model Summary
summary(vars_model_null)


#' ## Model Significance
anova(vars_model_null, vars_model_full)

#' <!-- #################################################################### -->
#'
#' # Session info
#'
#' The code and output in this document were tested and generated in the
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References
