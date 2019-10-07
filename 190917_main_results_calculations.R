# load packages
library("tidyverse")
library("reshape2")

library("readxl")
library("ggridges")
library ("ggrepel")

library("phyloseq")


# Calculations for Results section 1: Summary of amplification and sequencing
# ===========================================================================

# libraries per run
libs <- c(14,71,25,16,94,96,64)
sum(libs)

# non chimeric reads per run
non_chim <- c(6530859, 5849748, 648191, 10971590, 9438355, 9412053, 5941544)
summary(non_chim)

# Overall average of sequence counts per library
sum(non_chim)/sum(libs) 

# distribution of per library averages
summary(non_chim/libs)

# Calculations for Results section 2: Summary of predictor values
# ===============================================================

# Ridge plot and summary of environmental data
# --------------------------------------------

# - from Erins table at open  `-a "Microsoft Excel" "/Users/paul/Documents/CU_combined/Zenodo/Display_Items/190916_genetic_network_data.xlsx"`


pred_env <- read_excel("/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190916_genetic_network_data.xlsx", n_max=23)
selected <- pred_env[c("Genetics_Abbrev", "MIN_T","MAX_T","RANGE_T", "YR_MEAN_T", "Salinity")]

summary(selected) # for import in SI file possibly update and use `/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_supplement/190917_environmental_predictor_summary.png`

colnames(selected) <- c("PORT", "MIN_T","MAX_T","RANGE_T", "MEAN_T_YR", "SALI")
molten <- melt(selected, id="PORT")

ggplot(molten, aes(x = value, y = variable, fill = variable)) + 
   theme_bw() + 
   geom_density_ridges(scale = 0.5, size = 0.25, rel_min_height = 0.0003, alpha = 0.5, jittered_points = FALSE) +
   geom_label_repel ( aes (label = PORT)) + 
   theme( plot.title = element_text (hjust = 0.5)) +
   theme(legend.position="none", 
         axis.title.x=element_blank(),
         axis.text.x=element_blank(),
         axis.ticks.x=element_blank())
        
ggsave("190917_environmental_predictor_distribution.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_supplement/",
         scale = 4, width = 70, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# *** add textual summary code for 5 variables in plot

# Ridge plot of voyage sums
# -------------------------

# raw data of voyages per year as used by
#  `/Users/paul/Documents/CU_combined/Github/500_10_gather_predictor_tables.R`
pred_voy  <- read_excel("/Users/paul/Documents/CU_NIS-WRAPS/170727_port_information/160318_57_connected_ports_DERIVATIVE.xlsx")

# shallow depth model data produced when running modelling script
#  `/Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R` through
#  `/Users/paul/Documents/CU_combined/Github/210_get_mixed_effect_model_results.sh`
#  doesn't have route ids incorporated anymore. Getting routes by port id's anticipating that they match
#  and then final sums need to be checked with model data. (Alternativle re-run modeeling csripts and output full route tables)
mod_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Results/05_results_euk_asv00_shal__UNIF_model_data_2019-Sep-06-15-20-29.csv")
# 118 connections

# Port ids (shallow) from /Users/paul/Documents/CU_combined/Github/500_80_get_mixed_effect_model_results.R

pids <- c("2503", "1165","3110", "854","2503","2331","7597","4899", "576",
          "2729","2141","3367","3108","3381","7598", "238", "193","4777", "830",
          "311","4538","7975","1675")

pred_voy_selected <- pred_voy %>% filter(.,  PortA  %in% pids & PortB  %in% pids) 
# only 91 connections? - map 
# 118 connections in model data
#  minus 7 (non)connections from/ towPEARL HARBOUR -
#  minus 20  duplicated connections from to Singapore (SY / SW dichotomie)
#  equals 91 

world <- map_data("world")
world <- world[ which (world$region != "Antarctica"), ]   # remove Antarctica
ggplot() + 
  geom_polygon(data = world, aes (x=long, y = lat, group = group), fill = "darkgrey") + 
  coord_fixed(xlim = c(-170, 175),  ylim = c(-50, 80), ratio = 1.3) +
  geom_point(data = pred_voy_selected, aes (PortALon, PortALat), fill = "forestgreen", colour="black", pch=21, size=3) +  
  geom_point(data = pred_voy_selected, aes (PortBLon, PortBLat), fill = "skyblue", colour="black", pch=21, size=3) +          
  geom_label_repel ( data = distinct(pred_voy_selected, PortB, .keep_all = TRUE) , aes (PortBLon, PortBLat, label = PortB), size = 5, segment.color = 'grey50') + 
  geom_label_repel ( data = distinct(pred_voy_selected, PortA, .keep_all = TRUE) , aes (PortALon, PortALat, label = PortA), size = 2, segment.color = 'grey50')

# map congruent with "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/190917_1_map.pdf"
#  of script "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/190917_DI_map_curves.R"

# add column sums of voyage data
pred_voy_sum <- pred_voy_selected %>% mutate( Trips_Sum =  select(. ,contains("Trips_")) %>% apply(1, sum, na.rm=TRUE))

# despite dropping a lot of information,  use `select()` here rather then having to `filter()` molten data further below
pred_voy_sum <- pred_voy_sum %>% select(., contains("Trips_"), "Route_Name")

summary(pred_voy_sum) # for import in SI file, possibly

molten <- melt(pred_voy_sum, id="Route_Name")  

ggplot(molten, aes(x = value, y = variable, fill = variable)) + 
   theme_bw() + 
   geom_density_ridges(scale = 0.5, size = 0.25, rel_min_height = 0.0003, alpha = 0.5, jittered_points = FALSE) +
   # geom_label_repel ( aes (label = Route_Name)) + 
   theme( plot.title = element_text (hjust = 0.5)) +
   theme(legend.position="none")
   
ggsave("190926_voyage_predictor_distribution.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_supplement/",
         scale = 4, width = 70, height = 50, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Calculations for Results section 3: Density and Chord diagrams of model data
# ============================================================================

# same call as above (line~ 72)
mod_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2019-Sep-06-15-19-43.csv")

# summary of the variables that are suitable for summary
summary(mod_data  %>% select(. , -c("X1", "ECO_PORT","ECO_DEST" )))

# Show density and mean lines for all variables in dependence of ecoregion
# ------------------------------------------------------------------------

# choose the correct data for plotting
mod_sel <- mod_data  %>% select(. , -c("X1", "ECO_PORT","ECO_DEST", "PORT", "DEST"))

# calculate per group means, needs ddplyr loaded, may be masked by plyr
mod_sel %>% dplyr::group_by(ECO_DIFF) %>%
  mutate(MEANUNI = mean(RESP_UNIFRAC, na.rm = T))  %>%
  mutate(MEANENV = mean(PRED_ENV, na.rm = T))  %>%
  mutate(MEANTRP = mean(PRED_TRIPS, na.rm = T)) -> mod_sel

# UNIFRAC per Ecoregion:
ggplot(mod_sel, aes (x=RESP_UNIFRAC, color = ECO_DIFF)) +  
  geom_density() +
  geom_vline(aes(xintercept=MEANUNI, color=ECO_DIFF),linetype="dashed") +
  annotate("text", x=unique(mod_sel$MEANUNI), y=c(3.5, 4.5), label=paste("mean =", round(unique(mod_sel$MEANUNI), digits = 2)), size=4) +
  annotate("text", x=0.525, y=5.75, label=paste("n =", length(mod_sel$RESP_UNIFRAC)), size=4) +
  labs(title = "UNIFRAC values and crossing of Ecoregions") +
  labs(x = "UNIFRAC") +
  labs(y = "Density") +
  guides(color=guide_legend(title="Crossed")) +
  theme_bw()

ggsave("190927_2c_deep_unifrac_per_ecoregion.pdf", plot = last_plot(), 
  device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/",
  scale = 5, width = 30, height = 15, units = c("mm"),
  dpi = 500, limitsize = TRUE)

# Environmental Distance per Ecoregion:
ggplot(mod_sel, aes (x=PRED_ENV, color = ECO_DIFF)) +
  geom_density() +
  coord_cartesian(ylim = c(min(0),max(0.75))) +
  geom_vline(aes(xintercept=MEANENV, color=ECO_DIFF),linetype="dashed") +
  annotate("text", x=unique(mod_sel$MEANENV), y=c(0.4, 0.6), label=paste("mean =", round(unique(mod_sel$MEANENV), digits = 2)), size=4) +
  annotate("text", x=0.125, y=0.7, label=paste("n =", length(mod_sel$PRED_ENV)), size=4) +
  labs(title = "Environmental distances and Ecoregion crossing") +
  labs(x = "Environmental distance") +
  labs(y = "Density") +
  guides(color=guide_legend(title="Crossed")) +
  theme_bw()

ggsave("190927_2a_deep_envdist_per_ecoregion.pdf", plot = last_plot(), 
  device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/",
  scale = 5, width = 30, height = 15, units = c("mm"),
  dpi = 500, limitsize = TRUE)

# Summed voyages per Ecoregion:
ggplot(mod_sel, aes (x=PRED_TRIPS, color = ECO_DIFF)) +
  geom_density() +
  scale_x_log10() +
  geom_vline(aes(xintercept=MEANTRP, color=ECO_DIFF),linetype="dashed") +
  annotate("text", x=unique(mod_sel$MEANTRP), y=c(0.41, 0.62), label=paste("mean =", round(unique(mod_sel$MEANTRP), digits = 2)), size=4) + 
  annotate("text", x=2.5, y=0.7, label=paste("n =", length(mod_sel$PRED_TRIPS)), size=4) +
  labs(title = "Summed Voyages and Ecoregion crossing") +
  labs(x = expression( "summed annual voyages 1997-2013 ("* bold(log[10])*"-scale)"))  +
  labs(y = "Density") +
  guides(color=guide_legend(title="Crossed")) +
  theme_bw()
  
ggsave("190927_2b_deep_trips_per_ecoregion.pdf", plot = last_plot(), 
  device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS/181113_mn_cu_portbio/190812_display_items_main/",
  scale = 5, width = 30, height = 15, units = c("mm"),
  dpi = 500, limitsize = TRUE)


# Show chord diagrams of routes, for all predictors and responses
# ---------------------------------------------------------------

# same call as above (lines ~72 and ~125)
mod_data <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2019-Sep-06-15-19-43.csv")

# testing chord diagrams
# ~~~~~~~~~~~~~~~~~~~~~~
# can be improved following https://stackoverflow.com/questions/39188761/circlize-chord-diagram-with-multiple-levels-of-data
#  to show ecoregion
# Loading
library("circlize")

mod_data %>% arrange (.$PRED_TRIPS) -> mod_data
selected <- select(mod_data, from = PORT, to = DEST, value = PRED_TRIPS,ECO_DIFF )
chordDiagram(selected, self.link = 1, order = mod_data$value)
circos.clear()

# testing network graphic 
# ~~~~~~~~~~~~~~~~~~~~~~~
# igraph wants symbolic edge list in the first two columns
mod_sel <- mod_data  %>% select(. , -c("X1", "ECO_PORT", "ECO_DEST"))

#library
library(igraph)

# create the network object
network <- graph_from_data_frame(d=mod_sel, directed=F) 

V(network)$vertex_degree <-  degree(network)
l <- layout_with_fr(network, weights = E(network)$PRED_TRIPS)

# plot it
plot(network,
  vertex.label.cex = 0.5,
  edge.lty = (1 * !(E(network)$ECO_DIFF)) + 1,
  vertex.size = V(network)$vertex_degree,
  networklayout=1)

# Calculations for Results section 4: Taxonomy plots possibly per route
# =====================================================================


# Part I: Get taxonomy strings for Blast results
# -----------------------------------------------

# see https://ropensci.org/tutorials/taxize_tutorial/
#  for handling blast data and getting correct taxonomy strings from the net

library("blastxml")   # read blast xml - get via `library(devtools); install_github("BigelowLab/blastxml")`
library("tidyverse")  # work using tibbles
library("janitor")    # clean column names
library("taxonomizr") # query taxon names
library("purrr")      # dplyr applies
library("furrr")      # parallel purrrs

# Extracting straight from zip didn't work - aborted
# store file path
# blast_results_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Blast"
# blast_results_pattern <- "_blast_result_euk_only_no_env.txt.gz"
# 
# read all file into lists for `lapply()` usage
# blast_results_files <- list.files(path=blast_results_folder, pattern = blast_results_pattern, full.names = TRUE)
# 
# doesn't work, but I don't know why.
# lapply(blast_results_files, zip::unzip, exdir = tmp_dir)

# workaround - use readily extracted files

# define file path components for listing 
blast_results_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development"
blast_results_pattern <- "_blast_result_euk_only_no_env.txt"

# read all file into lists for `lapply()` usage
blast_results_files <- list.files(path=blast_results_folder, pattern = blast_results_pattern, full.names = TRUE)

# importing - for small subset subset list - names need to be set for keeping source file info
#  informing on overlap

# function to possibly save memory - slows down code - not needed
# get_condensed_dump = function(x) {x %>% 
#                                   blastxml_dump(.) %>%
#                                   as_tibble(. ) %>%
#                                   clean_names(.) %>%                 # clean columns names 
#                                   group_by(iteration_query_def) %>%  # isolate groups of hits per sequence hash
#                                   slice(which.max(hsp_bit_score)) %>%
#                                   return(.)
#                                   }

# benchmarking
# ------------
# system.time(blast_results_list <- purrr::map(blast_results_files[12:16], blastxml_dump, form = "tibble")) # takes a very long time - avoid by reloading full object from disk 
# system.time(blast_results_list <- purrr::map(blast_results_files[12:16], get_condensed_dump)) # takes a very long time - avoid by reloading full object from disk 
# plan(multiprocess)
# system.time(blast_results_list <- furrr::future_map(blast_results_files[12:16], blastxml_dump, form = "tibble")) # takes a very long time - avoid by reloading full object from disk 
# system.time(blast_results_list <- furrr::future_map(blast_results_files[12:16], get_condensed_dump)) # takes a very long time - avoid by reloading full object from disk 

plan(multiprocess) # enable 
blast_results_list <- furrr::future_map(blast_results_files, blastxml_dump, form = "tibble", .progress = TRUE) # takes 7-10 hours on four cores - avoid by reloading full object from disk 
names(blast_results_list) <- blast_results_files # <- execute next 

# save object and some time by reloading it - comment in if necessary
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results_list, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_results_list.Rdata")
# load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_results_list.Rdata", verbose = TRUE)

# create one large item from many few, while keeping source file info fo grouping or subsetting
blast_results_list %>% bind_rows(, .id = "src" ) %>%        # add source file names as column elements
                       clean_names(.) %>%                   # clean columns names 
                       group_by(iteration_query_def) %>%    # isolate groups of hits per sequence hash
                       slice(which.max(hsp_bit_score)) -> blast_results # save subset

# save object and some time by reloading it - comment in if necessary
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_results_list_sliced.Rdata")
# load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_results_list_sliced.Rdata", verbose = TRUE)
# nrow(blast_results) 17586

# prepareDatabase not needed to be run multiple times
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# prepareDatabase(sqlFile = "accessionTaxa.sql", tmpDir = "/Users/paul/Sequences/References/taxonomizR/", vocal = TRUE) # takes a very long time - avoid by reloading full object from disk

# function for mutate to convert NCBI accession numbers to taxonomic IDs.
get_taxid <- function(x) {accessionToTaxa(x, "/Users/paul/Sequences/References/taxonomizR/accessionTaxa.sql", version='base')}

# function for mutate to use taxonomic IDs and add taxonomy strings
get_strng <- function(x) {getTaxonomy(x,"/Users/paul/Sequences/References/taxonomizR/accessionTaxa.sql")}

# add tax ids to table for string lookup - probably takes long time
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
blast_results_appended <- blast_results %>% mutate(tax_id = get_taxid(hit_accession))
# save(blast_results_appended, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_results_with_taxid.Rdata")
# load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_results_with_taxid.Rdata", verbose=TRUE)

length(blast_results_appended$tax_id) # 17586

# look up taxonomy table
tax_table <- as_tibble(get_strng(blast_results_appended$tax_id), rownames = "tax_id") %>% mutate(tax_id= as.numeric(tax_id))
nrow(tax_table) # 17586

tax_table <- tax_table %>% arrange(tax_id) %>% distinct(tax_id, superkingdom, phylum, class, order, family, genus, species, .keep_all= TRUE)

# checks
nrow(tax_table)             # 3891 - as it should
all(!duplicated(tax_table)) #        and no duplicated tax ids anymore
lapply(list(blast_results_appended,tax_table), nrow) # first 17586, second deduplicated and with 3891 - ok 

# https://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join
blast_results_final <- left_join(blast_results_appended, tax_table, copy = TRUE) 
nrow(blast_results_final) # 17586 - table has correct length now 

# save object and some time by reloading it
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
save(blast_results_final, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_with_ncbi_taxonomy.Rdata")
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/190917_main_results_calculations__blast_with_ncbi_taxonomy.Rdata")


# Part II: Plot Blast results
# ---------------------------


blast_results_final %>% ungroup() %>% mutate(src = as.numeric(src)) -> blast_results_final



blast_results_final %>% group_by("src") %>% count( name = "src")








# Part III: relate taxonomy ids with route data and plot  
# -----------------------------------------------------

# (copy and adjust original blast subsetting code)

# use alluvial diagram
# https://cran.r-project.org/web/packages/ggalluvial/vignettes/ggalluvial.html

#' Get a list of Phyloseq objects in which each object only contains samples
#' from one Port. Matching of samples is done by the first two 
#' characters of the sample name.
phsq_list <- get_phsq_list(phsq_ob)

#' Extract OTU tables from Phyloseq object list and store as data frames...
df_list <- lapply (phsq_list, get_df_from_phsq_list)

#' ...get row sums - summing observations per OTU across multiple samples per port.. 
df_list <- lapply (df_list, rowSums)

#' ... combining list elements to matrix and data.table. Feature id;'s are names "rs".
features_shared <- data.table(do.call("cbind", df_list), keep.rownames=TRUE)


