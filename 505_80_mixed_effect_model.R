#' ---
#' title: "Compare Response and Predictor Matrices using Mixed Effect Models SGP EXCLUDED"
#' author: "Paul Czechowski"
#' date: "June 20th, 2018"
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
#' In preparation for the meeting in Fort Collins the following may be implemented below.
#' If you want to go back to an earlier version check commit before 2018-07-20 13:00.
#'  - Removal of singapore samples. Singapore samples need to be divided in the next data
#'    import iteration. This is potentially time consuming and requires large rewrites
#'    so that it only makes sense when more data is imported, as well.
#'  - PCoA of Unifrac matrix. This is done in order to make up for a inaccurate Qiime 2
#'    PCoA (which still includes the Singapore data)
#'  - Simplification. There is a lot of clutter in here, which should be removed for
#'    reasons of simplicity.
#'
#'
#'
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paulczechowski/Documents/CU_combined/Github/500_80_mixed_effect_model.R")`.
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
source("/Users/paulczechowski/Documents/CU_combined/Github/500_00_functions.R")

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

# loading matrix with trips (not risks), not loading "/Users/paulczechowski/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_risks_full.Rdata")
load("/Users/paulczechowski/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output_mat_trips_full.Rdata")

# checking 
mat_trips[35:50, 35:50]

#' ## Predictors 2 of 2: Environmental Distances
#'
#' This data is available for many ports (more ports then shipping routes)
load("/Users/paulczechowski/Documents/CU_combined/Zenodo/R_Objects/500_30_shape_matrices__output__mat_env_dist_full.Rdata")

# checking -- see debugging notes: some port numbers in row-/colnames are not unique
mat_env_dist_full[35:50, 35:50]

#'
#' <!-- -------------------------------------------------------------------- -->
#'      
#' ## Responses 1 of 3: Unifrac distance matrix as produced by Qiime 2
#'

# this path should match the parameter combination of the Euler script
resp_path <- "/Users/paulczechowski/Documents/CU_combined/Zenodo/Qiime/245_18S_097_cl_edna_core_metrics/distance-matrix.tsv"
resp_mat <- read.table(file = resp_path, sep = '\t', header = TRUE)

# checking import and format
resp_mat[35:50, 35:50]
class(resp_mat)

#' ## Responses 2 of 3: Kulczynski distances between ports if all overlap is considered - COMMENTED OUT
kulczynski_mat_all_path <- "/Users/paulczechowski/Documents/CU_combined/Zenodo/R_Objects/500_35_shape_overlap_matrices__output__97_overlap_kulczynski_mat_all.Rdata"
load(kulczynski_mat_all_path)
kulczynski_mat_all

#' ## Responses  3 of 3:  Kulczynski distances between ports if pairwise overlap is considered - COMMENTED OUT
kulczynski_mat_ovrlp_path <- "/Users/paulczechowski/Documents/CU_combined/Zenodo/R_Objects/500_35_shape_overlap_matrices__output__97_overlap_kulczynski_mat_dual.Rdata"
load(kulczynski_mat_ovrlp_path)
kulczynski_mat_ovrlp

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

# ---- begin insert 20.07.2018  ----  
#
#  PCoA of uncollapsed response matrix with SIngapore removed
#  (can be re-run in Qiime once Singapore issue is dealt with)

# copying for plotting
plt_mat <- resp_mat

# removing Singapore samples
slctd_rows <- which ( substr (rownames (plt_mat), start = 1, stop = 2) %!in% "SP") # 
slctd_cols <- which ( substr (colnames (plt_mat), start = 1, stop = 2) %!in% "SP") # 
plt_mat <- as.matrix(plt_mat[c(slctd_rows), c(slctd_cols)]) # btw: data frame to matrix
                                                            # Singapore is removed

mds_plt_mat <- metaMDS (plt_mat, distance = "euc")
stressplot(mds_plt_mat)
# dull plot - but how to improve (?)
ordiplot(mds_plt_mat, type = "t")

# ---- end insert 20.07.2018  ----  

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
r_mat_clpsd # SP needs to be removed here




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
#   `open /Users/paulczechowski/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`
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
#   `open /Users/paulczechowski/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`

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


# insert - remove Singapore from data frama
model_data <- model_data %>% filter(PORT != "SP" & DEST != "SP")

class(model_data)

# add ecoregion as per:
#   @1. Spalding, M. D. et al. Marine Ecoregions of the World: A Bioregionalization 
#    of Coastal and Shelf Areas. Bioscience 57, 573@583 (2007).
# write as function !!!!!!!!
# here using REALMS, there are 12 Realms listed in the paper

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
pairs(RESP_UNIFRAC ~ PRED_ENV * PRED_TRIPS, data=model_data, main="Simple Scatterplot Matrix")

#' # Select variables for modelling and build models 
model_data

model_data$PORT <- as.factor(model_data$PORT)
model_data$DEST <- as.factor(model_data$DEST)
model_data$ECO_DIFF <- as.factor(model_data$ECO_DIFF)

vars <- model_data %>% select(RESP_UNIFRAC, PORT, DEST, ECO_DIFF, PRED_ENV, PRED_TRIPS)

# filter PH to get rid of coverage differences
# vars <- model_data %>% filter(PORT != "PH") %>% filter(DEST != "PH") %>%  droplevels %>% select(RESP_UNIFRAC, PORT, DEST, ECO_DIFF, PRED_ENV, PRED_TRIPS)

#' ## Full Model and checking 
vars_model_full <- lmer(RESP_UNIFRAC ~ PRED_ENV + PRED_TRIPS + ECO_DIFF + (1 | PORT) + (1 | DEST), data=vars, REML=FALSE)

#' ### Model Summary
summary(vars_model_full)
coef(vars_model_full) #intercept for each level

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

## some diagnostics - 1 ---- UNIFRAC distance ~ Environmental Distance

plot(RESP_UNIFRAC ~ PRED_ENV, xlab = "Environmental Distance", ylab = "UNIFRAC distance", data=vars)
label_vec <- with(vars, paste(PORT, DEST, ECO_DIFF,  sep = " "))
with(vars, text(RESP_UNIFRAC ~ PRED_ENV, labels = label_vec, pos = 4))
devlm1 <- lm(RESP_UNIFRAC ~ PRED_ENV, data = vars)
abline(devlm1)
conflm1<-confint(devlm1)
abline(coef=conflm1[,1],lty=2)
abline(coef=conflm1[,2],lty=2) 
title(main = "UNIFRAC distance ~ Environmental Distance\n (without accounting for random effects)")

pdf("/Users/paulczechowski/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/180627_meeting_Fort_Collins/180220_slides/180720__500_80__unifrac_vs_env_dist.pdf", 
    width = 8, height = 8)
plot(RESP_UNIFRAC ~ PRED_ENV, xlab = "Environmental Distance", ylab = "UNIFRAC distance", data=vars)
label_vec <- with(vars, paste(PORT, DEST, ECO_DIFF,  sep = " "))
with(vars, text(RESP_UNIFRAC ~ PRED_ENV, labels = label_vec, pos = 4))
devlm1 <- lm(RESP_UNIFRAC ~ PRED_ENV, data = vars)
abline(devlm1)
conflm1<-confint(devlm1)
abline(coef=conflm1[,1],lty=2)
abline(coef=conflm1[,2],lty=2) 
title(main = "UNIFRAC distance ~ Environmental Distance\n (without accounting for random effects)")
dev.off()


## some diagnostics - 2 ---- RESP_UNIFRAC ~ PRED_TRIPS
plot(RESP_UNIFRAC ~ PRED_TRIPS, xlab = "Voyages (log - scaled)", ylab = "UNIFRAC distance", 
     data=vars )
label_vec <- with(vars, paste(PORT, DEST, ECO_DIFF,  sep = " "))
with(vars, text(RESP_UNIFRAC ~ PRED_TRIPS, labels = label_vec, pos = 4))
devlm2 <- lm(RESP_UNIFRAC ~ PRED_TRIPS, data = vars)
abline(devlm2)
conflm2<-confint(devlm2)
abline(coef=conflm1[,1],lty=2)
abline(coef=conflm1[,2],lty=2)
title(main = "UNIFRAC distance ~ Voyages\n (without accounting for random effects)")

pdf("/Users/paulczechowski/Box Sync/CU_NIS-WRAPS/170724_internal_meetings/180627_meeting_Fort_Collins/180220_slides/180720__500_80__unifrac_vs_voyages.pdf",
    width = 8, height = 8)
plot(RESP_UNIFRAC ~ PRED_TRIPS, xlab = "Voyages (log - scaled)", ylab = "UNIFRAC distance", 
     data=vars )
label_vec <- with(vars, paste(PORT, DEST, ECO_DIFF,  sep = " "))
with(vars, text(RESP_UNIFRAC ~ PRED_TRIPS, labels = label_vec, pos = 4))
devlm2 <- lm(RESP_UNIFRAC ~ PRED_TRIPS, data = vars)
abline(devlm2)
conflm2<-confint(devlm2)
abline(coef=conflm1[,1],lty=2)
abline(coef=conflm1[,2],lty=2)
title(main = "UNIFRAC distance ~ Voyages\n (without accounting for random effects)")
dev.off()

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
