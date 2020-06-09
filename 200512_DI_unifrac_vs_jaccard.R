#' ---
#' title: "Unifrac and Jaccard relationship."
#' author: "Paul Czechowski"
#' date: "09-Jun-2020"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---
#' 
#' # Preface
#' 
#' _"To be confident that UNIFRAC (phylogenetic based) is an appropriate
#'  biodiversity metric for our purposes, we need to show that it correlates with
#'  more conventional and intuitive biodiversity metrics, Jaccard index (species 
#'  based). We need to see a graph like the one below, based on port data (not 
#'  sample data). If our ports fall in the region where UNIFRAC asymptotes, we’ll
#'  need to think about using Jaccard or some other index instead, or multiple 
#'  indices. The sooner we get this nailed down, the better. We need to see a 
#'  plot like the one below (not just correlation statistics) for all of our port 
#'  pairs.  (As decided previously for later analyses, I believe we need this 
#'  including and excluding Pearl Harbor.)"_ (D.L. 14.01.2020)
#' 
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/200115_unifrac_vs_jaccard.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#' 
#' # Prepare Environment
#'
#' ## Empty buffer
rm(list=ls())

#'
#' ## Package loading 
library("data.table") # enhanced version of data.frame for fast data manipulations. 
library("tidyverse")  # for data handling and graphing
library("magrittr")   # setting row names during conversion from Tibble to Matrix
library("ggrepel")    # plot labelling
#' ## Functions
#'

#' Use functions from helper script:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

#' ## Data read-in
#'
#' Read in ASV tables (Unifrac and Jaccard). Paths defined in list are distance 
#  matrices for ports samples, without controls
#' samples, as described by the file name (and probably should match what is in 
#' file `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_tables.sh`)

paths <- list(
  "/Users/paul/Documents/CU_combined/Zenodo/Qiime/185_eDNA_samples_Eukaryotes_core_metrics_unweighted_UNIFRAC_distance_artefacts/185_unweighted_unifrac_distance_matrix.tsv",
  "/Users/paul/Documents/CU_combined/Zenodo/Qiime/190_18S_eDNA_samples_Eukaryotes_core_metrics_non_phylogenetic_JAQUARD_distance_artefacts/190_jaccard_distance_matrix.tsv"
  )

dist_list_raw <- lapply(paths, read_tsv)

#' ## Data formatting
#' 
#' Convert raw data to matrix with row- and colnames for speed reasons.
dist_list_mat <- lapply(dist_list_raw, function(mat) mat %>% set_rownames(.$X1) %>% select(-X1) %>% as.matrix)

#' Create port-wise collapsed, but empty receiving matrices from input list ...
dist_list_mat_collapsed <- lapply(dist_list_mat, get_collapsed_responses_matrix)

#' ... and fill these matrices with values. 
dist_list_mat_collapsed <- mapply(fill_collapsed_responses_matrix, dist_list_mat_collapsed, dist_list_mat, SIMPLIFY = FALSE)

#' Getting data for plotting, modified from section `Getting Dataframes for modelling`
#' of script `~/Documents/CU_combined/Github/500_80_get_mixed_effect_model_tables.R`.

# set names
dist_list_mat_collapsed <- setNames(dist_list_mat_collapsed, c("UNIFRAC", "JACCARD"))

# are all matrix dimesions are the same?
var(c(sapply (dist_list_mat_collapsed, dim))) == 0

# are all matrices symmetrical and have the same rownames and column names?
all(sapply (dist_list_mat_collapsed, rownames) == sapply (dist_list_mat_collapsed, colnames))

# flatten matrices, while keeping port identifiers
dist_df_collapsed <- lapply(dist_list_mat_collapsed, function(x) data.frame(x) %>% rownames_to_column("PORT") %>% reshape2::melt(., id.vars = "PORT"))

# join dataframes and name columns
dist_df_collapsed <- dist_df_collapsed %>% reduce(inner_join, by = c("PORT", "variable")) %>% setNames(c("PORT.A", "PORT.B", toupper(names(dist_df_collapsed))))

# remove incomplete cases - thereby ignoring lower diagonal half of input matrices matrices
dist_df_collapsed <- dist_df_collapsed %>% filter(complete.cases(.))

# remove self connections
dist_df_collapsed <- dist_df_collapsed  %>% filter(PORT.A != PORT.B)

## after https://gist.github.com/adamhsparks/e299e6d1beb82ed258c1052050d63bc5

mod <- lm(JACCARD ~ UNIFRAC, data = dist_df_collapsed)
summary(mod)
# see that p-value: < 2.2e-16

# function to create the text equation
lm_eqn <- function(df, lm_object) {
  eq <-
    substitute(
      italic(y) == a + b %.% italic(x) * "," ~  ~ italic(r) ^ 2 ~ "=" ~ r2,
      list(
        a = format(coef(lm_object)[1], digits = 2),
        b = format(coef(lm_object)[2], digits = 2),
        r2 = format(summary(lm_object)$r.squared, digits = 3),
        p = format(summary(lm_object)$coefficients[,"Pr(>|t|)"][[2]],digits = 2)
      )
    )
  as.character(as.expression(eq))
}

# get the equation object in a format for use in ggplot2
eqn <- lm_eqn(dist_df_collapsed, mod)

#' ## Plotting and saving

ggplot(data = dist_df_collapsed, aes(x = UNIFRAC, y = JACCARD)) +
  geom_smooth(method="auto", se=TRUE, fullrange=FALSE, level=0.95) +
  geom_point() +
  annotate("text",
           x = 0.8,
           y = 0.7, 
           label = "italic(p) <2e-16",
           parse = TRUE) +
  annotate("text",
           x = 0.8,
           y = 0.8, 
           label = eqn,
           parse = TRUE) +
  theme_bw() + 
  # geom_text_repel(aes(label = paste(PORT.A,"-",PORT.B, sep = "", collapse = NULL) ,  color = PORT.A), size = 3) +
  geom_smooth(method="auto", se=TRUE, fullrange=FALSE, level=0.95) +
  geom_point() + 
  theme(legend.position= "none") +
  labs(title=" ",
       x ="Unifrac distance", y = "Jaccard distance") 

ggsave("200512_DI_unifrac_vs_jaccard.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development",
         scale = 1.0, width = 160, height = 80, units = c("mm"),
         dpi = 500, limitsize = TRUE)
