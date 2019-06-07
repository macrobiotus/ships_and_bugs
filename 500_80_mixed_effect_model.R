#' ---
#' title: "Compare Response and Predictor Matrices using Mixed Effect Models"
#' author: "Paul Czechowski"
#' date: "07-June-2019"
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
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/505_80_mixed_effect_model.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#' 
#' # Environment preparation

# empty buffer
# ============
rm(list=ls())

# load packages
# =============
library ("ggplot2")   # for ggCaterpillar
library ("ggbiplot")  # better PCoA plotting, get via `library(devtools); install_github("vqv/ggbiplot")`
                      # uses `plyr` and needs to be loaded before `dplyr` in `tidyverse` 
library ("gdata")     # matrix functions
library ("tidyverse") # dplyr and friends
library ("reshape2")  # melting
library ("lme4")      # mixed effect model - with plotting 

library ("vegan")     # metaMDS


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

# loading matrix with trips (not risks), not loading "/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata"
load("/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full.Rdata")

# checking - see debugging notes: row- and colnames are undefined
mat_trips[35:50, 35:50]

#' ## Predictors 2 of 2: Environmental Distances
#'
#' This data is available for many ports (more ports then shipping routes)
load("/Users/paul/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata")

# checking - see debugging notes: some port numbers in row-/colnames are not unique
#          - see debugging notes: row- and colnames are undefined, bu seemingly consitent with above
#             so likley less problematic
mat_env_dist_full[35:50, 35:50]

#'
#' <!-- -------------------------------------------------------------------- -->
#'      
#' ## Response: A distance matrix as produced by Qiime 2 (UNIFRAC or Jacquard)
#'
resp_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/190_18S_eDNA_samples_clustered99_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv"
# resp_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/185_eDNA_samples_Eukaryotes_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv"

resp_mat <- read.table(file = resp_path, sep = '\t', header = TRUE)

# checking import and format
resp_mat[35:50, 35:50]
resp_mat[01:10, 01:10]
class(resp_mat)

#' <!-- #################################################################### -->
#'
#'
#' <!-- #################################################################### -->
#'
#' # Data formatting 
#' 
#' ## Responses 1 of 3: Unifrac distance matrix as produced by Qiime 2
#'
#' Need to be done before the predictors: Matrix fields need to be averaged (09-Apr-2019: using median)
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

# Collapsed matrix should receive data for samples: 
# (unclustered) Unifrac input:  PH SW SY AD BT HN HT LB MI AW CB HS NA NO OK PL PM RC RT VN GH WL ZB 
# (clustered)   Jaquard input:  PH SW SY AD BT HN HT LB MI AW CB HS NA NO OK PL PM RC RT VN GH WL ZB 

r_mat_clpsd <- fill_collapsed_responses_matrix(r_mat_clpsd, resp_mat)

write.csv(r_mat_clpsd, file = "/Users/paul/Documents/CU_combined/Zenodo/Results/505_80_mixed_effect_model__output__collapsed_matrix.csv")
dim(r_mat_clpsd)
#'
#' <!-- -------------------------------------------------------------------- -->
#'      
#' ## Predictors 1 of 2: Voyages
#'

# to save memory: discard completely undefined rows and columns (shrinks from
#  6651 * 6651 to 2332 * 2332
dim(mat_trips)
mat_trips <- mat_trips[rowSums(is.na(mat_trips))!=ncol(mat_trips), colSums(is.na(mat_trips))!=nrow(mat_trips) ]
dim(mat_trips) 

# quick and dirty - manual lookup for subsetting
#   improve this. Manual lookup via:
#   `open  -a "Microsoft Excel" "/Users/paul/Dropbox/NSF NIS-WRAPS Data/raw data for Mandana/PlacesFile_updated_Aug2017.xlsx"`
colnames(r_mat_clpsd)

# "PH" "SW" "SY" "AD" "BT"
# "HN" "HT" "LB" "MI" "AW"
# "CB" "HS" "NA" "NO" "OK"
# "PL" "PM" "RC" "RT" "VN"
# "GH" "WL" "ZB"
#

##### erase custom ports when necessary ##### 
# r_mat_clpsd <- r_mat_clpsd[, colnames(r_mat_clpsd) != "CH"]
# r_mat_clpsd <- r_mat_clpsd[rownames(r_mat_clpsd) != "CH", ]
# 
# 
# "2503", "1165", "1165", "3110",  "854",
# "2503", "2331", "7597", "4899",  "576",
# "2141", "3367", "3108", "3381", "7598",
#  "238",  "193", "4777",  "830",  "311",
# "4538", "7975", "1675"

head(mat_trips)
mat_trips <- mat_trips[c("2503","1165","1165","3110", "854", 
                         "2503","2331","7597","4899", "576",
                         "2141","3367","3108","3381","7598",
                          "238", "193","4777", "830", "311",
                         "4538","7975","1675"),
                         c("2503","1165","1165","3110", "854", 
                         "2503","2331","7597","4899", "576",
                         "2141","3367","3108","3381","7598",
                          "238", "193","4777", "830", "311",
                         "4538","7975","1675")]

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

mat_env_dist <- mat_env_dist_full[c("2503","1165","1165","3110", "854",
                         "2503","2331","7597","4899", "576",
                         "2141","3367","3108","3381","7598",
                          "238", "193","4777", "830", "311",
                         "4538","7975","1675"),
                         c("2503","1165","1165","3110", "854",
                         "2503","2331","7597","4899", "576",
                         "2141","3367","3108","3381","7598",
                          "238", "193","4777", "830", "311",
                         "4538","7975","1675")]

mat_env_dist[lower.tri(mat_env_dist, diag = FALSE)] <- NA

# predictors - copy names - make automatic !! 
colnames(mat_env_dist) <- colnames(r_mat_clpsd)
rownames(mat_env_dist) <- rownames(r_mat_clpsd)

#' Finished matrix -
#' to match predictors influenced by available voyages before analysis.
mat_env_dist

#'
#' <!-- #################################################################### -->
#'
#'
#' <!-- #################################################################### -->
#'
#' ## Getting Dataframes for modelling 

# create named list with objects
mat_list <- list (r_mat_clpsd, mat_env_dist, mat_trips) 

mat_list <- setNames(mat_list, c("resp_unifrac", "pred_env", "pred_trips"))

# Are all matrix dimesions are the same?
var(c(sapply (mat_list, dim))) == 0

# Are all matrices symmetrical and have the same rownames and column names
all(sapply (mat_list, rownames) == sapply (mat_list, colnames))

# melt data frames for joining 
df_list <- lapply (mat_list, function(x) data.frame(x)  %>%
                             rownames_to_column("PORT") %>%
                             melt(., id.vars = "PORT"))

# join dataframes and name columns - "NA" (Nanaimo) becomes "NA." to not be R's "NA"
#  also one column isn't a factor variable - correcting this
model_data_raw <- df_list %>% reduce(inner_join, by = c("PORT", "variable")) %>%
                          setNames(c("PORT", "DEST", toupper(names(mat_list))))
class(model_data_raw)

levels(model_data_raw$DEST)[ which (levels(model_data_raw$DEST) == "NA.")] <- "NX"
model_data_raw$PORT <- as.factor(model_data_raw$PORT)
levels(model_data_raw$PORT)[ which (levels(model_data_raw$PORT) == "NA")] <- "NX"

# check this table carefully for consistent column names
# model_data_raw

# remove incomplete cases - only ignoring lower half of matrix, otherwise remove 
#  column selector
model_data <- model_data_raw %>% filter(complete.cases(.))
class(model_data)
model_data

# add ecoregion as per:  # <-- continue here
#   @Costello, M. J., Tsai, P., Wong, P. S., Cheung, A. K. L., Basher, Z. 
#   and Chaudhary, C. (2017) “Marine biogeographic realms and species endemicity,” 
#   Nature Communications. Springer US, 8(1), p. 1057. doi: 10.1038/s41467-017-01121-2..
#   write as function !!!!!!!!
#   here using REALMS, there are 30 Realms listed in the paper (Fig 1, Fig2b)

model_data <- model_data %>% add_column("ECO_PORT" = NA)
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("HN", "PH"), "17", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("SY", "SW"), "13", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("AD"), "26", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("CH","BT","MI", "HT", "NO", "WL"), "11", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("LB", "CB", "OK", "PL", "RC", "VN", "NX", "HS"), "7", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("PM", "BA"), "24", model_data$"ECO_PORT"))
model_data <- model_data %>% mutate (ECO_PORT = ifelse( .$"PORT"  %in% c("AW", "RT", "GH", "ZB"), "3", model_data$"ECO_PORT"))

model_data <- model_data %>% add_column("ECO_DEST" = NA)
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("HN", "PH"), "17", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("SY", "SW"), "13", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("AD"), "26", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("CH","BT","MI", "HT", "NO", "WL"), "11", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("LB", "CB", "OK", "PL", "RC", "VN", "NX", "HS"), "7", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("PM", "BA"), "24", model_data$"ECO_DEST"))
model_data <- model_data %>% mutate (ECO_DEST = ifelse( .$"DEST"  %in% c("AW", "RT",  "GH", "ZB"), "3", model_data$"ECO_DEST"))

model_data <- model_data %>% add_column("ECO_DIFF" = NA)
model_data <- model_data %>% mutate (ECO_DIFF = ifelse(ECO_PORT == ECO_DEST , FALSE, TRUE))

write.csv(model_data, file = "/Users/paul/Documents/CU_combined/Zenodo/Results/505_80_mixed_effect_model__output__model_input.csv")

# Checking response and predictor variable distributions

## Responses
ggplot(model_data, aes (x=RESP_UNIFRAC))+ 
  geom_density()+
  facet_grid(~ECO_DIFF)+
  theme_bw()

# differences are tiny
aggregate(model_data$RESP_UNIFRAC~model_data$ECO_DIFF, FUN=mean)

ggplot(model_data,aes (x=PRED_ENV))+ 
  geom_density()+
  facet_grid(~ECO_DIFF)+
  theme_bw()

# differences are a bit better
aggregate(model_data$PRED_ENV~model_data$ECO_DIFF, FUN=mean)

## Pedictors
ggplot(model_data,aes (x=PRED_TRIPS))+ 
  geom_density()+
  facet_grid(~ECO_DIFF)+
  theme_bw()

# more trips within ecoregions in data - not surprising
aggregate(model_data$PRED_TRIPS~model_data$ECO_DIFF, FUN=mean)

#'
#' <!-- #################################################################### -->
#'
#' <!-- #################################################################### -->
#'

# model_data <- model_data %>%  mutate_if(is.numeric, scale(.,scale = FALSE))
pairs(RESP_UNIFRAC ~ PRED_ENV * PRED_TRIPS, data=model_data, main="Simple Scatterplot Matrix")

#' # Select variables for modelling and build models 
model_data

model_data$PORT <- as.factor(model_data$PORT)
model_data$DEST <- as.factor(model_data$DEST)
model_data$ECO_DIFF <- as.factor(model_data$ECO_DIFF)

# reordering columns for model
vars <- model_data %>% select(RESP_UNIFRAC, PORT, DEST, ECO_DIFF, PRED_ENV, PRED_TRIPS)

#' ## Full Model and checking 
vars_model_full <- lmer(RESP_UNIFRAC ~ PRED_ENV + PRED_TRIPS + ECO_DIFF + (1 | PORT) + (1 | DEST), data=vars, REML=FALSE)

# vars_model_full <- lm(RESP_UNIFRAC ~ PRED_ENV + PRED_TRIPS + ECO_DIFF, data=vars)

#' ### Model Summary
vars_model_full
summary(vars_model_full)
coef(vars_model_full) #intercept for each level

# For linear models, you can also plot standardized beta coefficients,
# https://cran.r-project.org/web/packages/sjPlot/vignettes/plot_model_estimates.html
# using type = "std" or type = "std2". These two options differ in the way how
# coefficients are standardized. type = "std2" plots standardized beta values,
# however, standardization follows Gelman’s (2008) suggestion, 
# rescaling the estimates by dividing them by two standard deviations
# instead of just one. (Use, type = std)

library("sjPlot")
plot_model(vars_model_full, show.values = TRUE, value.offset = .3,
   type = "std", 
   title = "Changes in eukaryotic UNIFRAC distances between ports related to Ecoregion-crossing and Environmental distance (in SD)")

#' Residuals
plot(vars_model_full)

## check normality of the residuals
qqnorm(residuals(vars_model_full))

## plotting random effects - trial after https://stackoverflow.com/questions/13847936/in-r-plotting-random-effects-from-lmer-lme4-package-using-qqmath-or-dotplot
# qqplot of the random effects with their variances
# "The last line of code produces a really nice plot of each intercept with the error around each estimate."
qqmath(ranef(vars_model_full, condVar = TRUE), strip = FALSE)$PORT
qqmath(ranef(vars_model_full, condVar = TRUE), strip = FALSE)$DEST


#' ### Leverage of Observations

## model is not influenced by one or a small set of observations ?
ggplot(data.frame(lev=hatvalues(vars_model_full),pearson=residuals(vars_model_full, type="pearson")),
      aes(x=lev,y=pearson)) + geom_point() + theme_bw()

#' ## Null Model and checking 

vars_model_null <- lmer(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF + (1 | PORT) + (1 | DEST), data=vars, REML=FALSE)

# vars_model_null <- lm(RESP_UNIFRAC ~ PRED_ENV + ECO_DIFF, data=vars)

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
