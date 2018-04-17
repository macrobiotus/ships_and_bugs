#' ---
#' title: "Selecting samples stored at Cornell with connections to Japan"
#' author: "Paul Czechowski"
#' date: "April 16th, 2017"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: /Users/paul/Box Sync/CUCU_NIS-WRAPS/170831_bibtex/170831_r_script_references.bib
#' ---
#'
#' # Code rendering
#' 
#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Box Sync/CU_NIS-WRAPS/170912_code_r/180416_30_select_samples.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#'
#' # Preface
#' 
#' Please refer to file "/Users/paul/Box Sync/CUCU_NIS-WRAPS/170912_code_r/170901_30_select_samples.R"
#' for detailed explanations.
#' # Prerequisites to run this code
#'
#' * file `[...]/Box Sync/CU_NIS-WRAPS/170815_R_storage/170830_10_cleanup_tables__output__all.Rdata` is available
#' * or input data has been cleaned by `170830_10_cleanup_tables.R`  
#'   and the output files of that script were generated
#'   using the correct source tables (check commit hashes if necessary) and 
#'   are accesible.
#' * is that file `[...]/Box Sync/CU_NIS-WRAPS/170815_R_storage/170901_20_calculate_distances__output.Rdata` is available
#' * or that the distance matrix has been produced `170901_20_calculate_distances.R`  
#'   and the output files of that script  were generated
#'   using the correct source tables (check commit hashes if necessary) and 
#'   are accesible.
#' 
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Environment preparation
#'
#' ## Package loading and cleaning of workspace
#+ message=FALSE, results='hide'

library (dplyr)       # sorting, table manipulation
library (matrixStats) # here used (anymore?) for column median
library (tidyverse)   # to `write_excel_csv()`
library (readxl)      # to open excel files
library (reshape2)    # plotting, table manipulation
library (ggplot2)     # plotting, mapping
library (maps)        # mapping
library (ggrepel)     # plot labelling
library (grid)        # handle graphical objects
library (gridExtra)   # handle graphical objects

#' ## Flushing buffer
#' 
rm(list=ls())     # for safety only

#' 
#' ## Functions
#'

# none defined

#' 
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Data import
#' 
#' Data is imported using basic R functionality, generated from these scripts: 
#'
#'  *  `/Users/paul/Box Sync/CU_NIS-WRAPS/170720_code/170830_10_cleanup_tables.R`
#'  *  `/Users/paul/Box Sync/CU_NIS-WRAPS/170720_code/170901_20_calculate_distances.R`

# getting list of Tibbles
load (file = 
  "/Users/paul/Box Sync/CU_NIS-WRAPS/170815_R_storage/170830_10_cleanup_tables__output__all.Rdata")

# getting distance matrix
load (file =
  "/Users/paul/Box Sync/CU_NIS-WRAPS/170815_R_storage/170901_20_calculate_distances__output.Rdata")

# check successful loading 
exists (c ("src_heap", "eucl_heap"))

# show the data structure for future reference 
str (src_heap)
str (eucl_heap)

#' 
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Formatting the distance matrix
#'
#' Needs to be done so looking up distances between route endpoints
#' can be looked up.
#'
#' ## Converting the matrix
#'
#' Initially convert the `dist()` object to a normal matrix for labelling and
#' to speed up things. Refer to the previous script if more details are needed
#' from the `dist()` object. 
eucl_heap <- as.matrix(eucl_heap)

#' ## Label distance matrix with port ID's
#'
#' Matrix row and columns are best labelled using the PORT ID's. `src_heap$TEMP$PORT`
#' defines the matrix dimension, but only contains the written port names, which
#' are more difficult to match up. I need a vector of `length (src_heap$TEMP$PORT)`
#' containing the port IDs. The needed information is `src_heap$PORT[c("PID", "PORT")]`.
#' I will match this up in a new variable (`PID`):

# `match()` (or `%in%`) doesn't return `NA` thus needed is a left join:
src_heap$TEMP <- left_join (src_heap$TEMP, src_heap$PORT[c("PID", "PORT")], by = "PORT")

# of 6651 entries, 83 remain undefined, a very small percentage: 
sum(is.na(src_heap$TEMP$PID)) / length (src_heap$TEMP$PID)

# renaming the matrix rows and and columns
#   `as.numeric()` may prevent lookup problems later
colnames (eucl_heap) <- as.numeric(src_heap$TEMP$PID) 
rownames (eucl_heap) <- as.numeric(src_heap$TEMP$PID) 

# testing the result - looks as desired
eucl_heap[c(1:10), c(1:10)]

#' 
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Formatting the route information, including _route ranking_
#'
#' Needs adding in the distance information, and creating one compound variable
#' to rank route importance - I suggest the **the log of the number of 
#' trips multiplied by the inverse of the Euclidean distance (of four-dimensional
#' space)**. This will need to be discussed. 
#'
#' ## Getting the route information 
#' 
#' Route information is  stored in Tibble `src_heap$ROUT`
#'
#' ## Adding the environmental distances. 
#' 
#' Environmental distances are added to route info in variable `EDST` through
#' lookup in distance matrix via variables `src_heap$ROUT$PRTA` and
#' `src_heap$ROUT$PRTB`. 17% of data are missing, unless I get better data.
#' Since I am only selecting US-CHN routes below, this may not be a (big)
#' problem.

# Initially create index matrix - each row is a row / col index for the matrix
pos <- cbind (
  match (src_heap$ROUT$PRTA, rownames (eucl_heap)),
  match (src_heap$ROUT$PRTB, colnames (eucl_heap))
  )

# Define variable and fill with matrix contents
src_heap$ROUT$EDST <- eucl_heap[pos] 

# Check for missing data - quite ab it missing  
sum(is.na(src_heap$ROUT$EDST)) / length (src_heap$ROUT$EDST)

#' 
#' ## **Calculating the compound ranking variable** 
#' 
#' ### Plotting TRIPS
#'
#' Just so that I see what is going on I am plotting this:
molten <- melt (src_heap$ROUT[c("TRIPS")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of TRIPS in route data",
    subtitle = "no magic here")

#' ### Testing TRIPS, EDST and RANKS
#'
#' Before I create variables I'd like test the approach I will apply:
#' This could likely be improved.

# Create a test data frame
test         <- src_heap$ROUT[c("TRIPS", "EDST")]
test$LTRIPS  <- log (test$TRIPS)             # log only to down-scale
test$LIDST   <- log (1 / src_heap$ROUT$EDST) # log only to down-scale
test$RANK    <- log (src_heap$ROUT$TRIPS * (1 / src_heap$ROUT$EDST)) 

# Remove Inf and NA values
test <- do.call (data.frame, lapply (test, function(x) replace(x, is.infinite (x), NA)))
test <- as_tibble(test)
test <- test [ complete.cases (test), ]
test <- as_tibble (scale ( test[c("LTRIPS", "EDST", "LIDST", "RANK")]))

# Test plot
molten <- melt (test[c("LTRIPS", "EDST", "LIDST", "RANK")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of test variables",
    subtitle = "LTRIPS and LIDST are log-scaled, TRIPS and IDIST are multiplied to RANK")

#'
#' ### Multiply log of trips with inverse of environmental distance 
#'
#' This should give me an option to rank routes by trips and environmental
#' closeness. Naturally this will be an issue of content, I suppose. Routes
#' will always have a slight environmental distance, so division by zero
#' will not be an issue when inverting distance values.

# Naturally this will be an issue of content, I suppose. The `log()` also
#  shifts the density quite substantially.
src_heap$ROUT$RANK <-  log (src_heap$ROUT$TRIPS * (1 / src_heap$ROUT$EDST))   

# And the plot, quick and dirty.
molten <- melt (src_heap$ROUT[c("RANK")])
ggplot (molten, aes (x=value, fill=variable)) + 
  geom_density(alpha=0.25) +
  labs (title = "Density of RANKS in route data",
  subtitle = "log (src_heap$ROUT$TRIPS * (1 / src_heap$ROUT$EDST))" )

#' ### Garbage collection
#' 
#' Perhaps this helps to keep the R fast.
rm("eucl_heap", "pos") 

#' 
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Formatting local sample inventory
#' 
#' ## Adding `PID`'s to sample inventory 
#' 
#' Adding port IDs (`"PTID"`) to sampled ports in inventory file.
#' Can't find Pearl Harbor in places file - likely because it is a
#' military base (Jim Corbett). 23.8.2017: I am using Honolulus port ID from
#' the Lloyd data for samples from Pearl Harbor. Pearl Harbour
#' previously was marked `"0000"`, now `"2503"`. This ID will now in the
#' data twice - be mindful of possible bugs downstream!

# get port names from inventory file for lookup 
smpld_PORT <- unique (src_heap$INVE$PORT)

#' Manual lookup of sampled ports via  
#' `open /Users/paul/Dropbox/NSF\ NIS-WRAPS\ Data/raw\ data\ for\ Mandana/PlacesFile_updated_Aug2017.xlsx -a "Microsoft Excel"`
#' This file needs to be the same as used by `~/Box\ Sync/CU_NIS-WRAPS/170720_code/170830_10_cleanup_tables.R`.

#  alternatively try a fuzzy match with agrep()
#  Milne Inlet coded as Nanisivik (3371)
#  Pearl Harbour coded as Honolulu (2503)
smpld_PID <- c("3367", "2141", "2111", "3108", "7597",  "311", "2503", "2503",
                "238", "4021", "7598", "7976", "7975", "3381", "4899", "2331",
                "854", "3371")

# create concise inventory tibble 
 # 23.08.2017 duplicate harbour ID "2503" does not appear to be a problem

smpld <- data_frame (PORT = smpld_PORT, PTID = smpld_PID)

# this filename is variable and based on the script name 
save (smpld, file = 
  "/Users/paul/Box Sync/CU_NIS-WRAPS/170815_R_storage/180416_30_select_samples__smpld_ports.Rdata")

#' 
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Selecting and ranking of routes connecting to samples in the freezer
#'
#' ## Finding routes connecting to samples in the freezer
#'
#' Route information is in `src_heap$ROUT`. Sampled port ids are in `smpld$PTID`
#' Defining sampled routes (`srout`) by matching sampled port ids
#' with start or end points of routes file, and subsetting routes file: 

srout <- filter(src_heap$ROUT, 
  PRTA %in% smpld$PTID | 
  PRTB %in% smpld$PTID)

#' ## Removing duplicates in route file
#'
#' There are no duplicate routes in this file and paired duplicate detection
#' when tested switches coordinates - omitting this step (commented out)

# sort the two columns in questions, by row "1", and transpose "t" to fit back
#   into data structure

# sampld_rts[c("PRTA","PRTB")] <- t( apply (sampld_rts[c("PRTA","PRTB")], 1, sort) )

# remove duplicated entries

# sampld_rts[!duplicated(sampld_rts[c("PRTA","PRTB")]),]

#' ## Checking number of comple cases
#'
#' High value of complete cases desirable, other cases can't be sorted
#' Complete cases higher for `170804_all_connected_ports.csv` rather then the other
#' file (see above). Incomplete cases to data team? 85% of the subset route
#' information is complete: 

sum(complete.cases(srout)) / length(complete.cases(srout))

#' Route data is incomplete for these 678 cases and needs complete ecological, or
#' trip data (output not shown)

srout [!complete.cases(srout), ] # %>% print(n = nrow(.))

#' ## Add port names and countries
#' 
#' Add port names and countries (not correcting coordinates). Incomplete cases 
#' to Jim Corbett? Port name information is here (and should be 9,177 x 5): 
ports <- src_heap$PORT 

#' Adding in port name information for both route ends:
srout <- left_join (srout, ports[c("PID", "PORT", "COUN")],
  by = c("PRTA" = "PID"))   
names (srout)[11:12] <- c("PORTA", "COUNA")

srout <- left_join (srout, ports[c("PID", "PORT", "COUN")],
  by = c("PRTB" = "PID"))   
names(srout)[13:14] <- c("PORTB", "COUNB")

#' ## Removing incomplete cases
#' 
#' Incomplete cases can't be sorted and should be reported.
#' I am removing them here.
srout <-  srout [ which (complete.cases (srout)), ] 


#' ## Saving US outbound routes
#' 
#' Routes that start in the US and go to the world are saved:
save (srout, file =
  "/Users/paul/Box Sync/CU_NIS-WRAPS/170815_R_storage/180416_30_select_samples__smpld_routs.Rdata")

#' ## Route filtering - changing this tp see only Japanese routes 16.04.2018
#' 
#' Can be deactivated, modified.

#' * JPN - Japan

ac = c("JPN") 

srout <- srout %>% filter (PORTA == "Baltimore" & COUNB == ac[1] |
                           PORTA == "Houston" & COUNB == ac[1] |
                           PORTA == "Miami" & COUNB == ac[1] |
                           PORTA == "Long Beach" & COUNB == ac[1] |
                           PORTB == "Baltimore" & COUNA == ac[1] |
                           PORTB == "Houston" & COUNA == ac[1] |
                           PORTB == "Miami" & COUNA == ac[1] |
                           PORTB == "Long Beach" & COUNA == ac[1]) %>% print(n = nrow(.))


#' ## **Route ranking based on calculated rank**
#'
#' Ranking by `RANK` variable, printing, and keeping for mapping
us_world <- srout %>% arrange (desc (RANK), desc (ROUTE)) %>%  print(n = nrow(.))

#' Saving for R 
save (us_world, file =
  "/Users/paul/Box Sync/CU_NIS-WRAPS/170815_R_storage/180416_30_select_samples__US_xtr_JPN_routes__ranked.Rdata")

#' Saving for humans and external viewers:
write_excel_csv ( us_world, 
                 "/Users/paul/Box Sync/CU_NIS-WRAPS/170919_R_tables/180416_30_select_samples__US_xtr_JPN_routes__ranked.csv",
                 na = "NA", append = FALSE, col_names = TRUE)

#' ## **Route ranking based on environmental distance and trips**
#'
#' Copying object, original object needs to be kept for mapping
us_world_dt <- us_world # %>% print(n = nrow(.))

#' Add grouping variable indicating quartiles of `TRIPS`

# https://stackoverflow.com/questions/7508229/how-to-create-a-column-with-a-quartile-rank
us_world_dt <- within (us_world_dt, TQRT <- as.integer (cut (TRIPS, quantile (TRIPS,
  seq(0, 1, 1/3), na.rm = FALSE), include.lowest=TRUE))) %>% print(n = nrow(.))

#' Add grouping variable indicating quartiles of `EDST`

us_world_dt <- within (us_world_dt, EQRT <- as.integer (cut (EDST, quantile (EDST,
  seq(0, 1, 1/3), na.rm = FALSE), include.lowest=TRUE))) %>% print(n = nrow(.))

#' _"Sort routes by environmental similarity (temp & salinity index). Then deal only with the
#' routes at the end of this continuum where ports that are being connected are very 
#' similar to each other."_

us_world_dt <- us_world_dt %>% arrange (EDST) %>% filter (EQRT == 1)  %>% print(n = nrow(.))

#' _"Then sort the subset of routes that connect environmentally similar ports 
#' (identified above) by number of voyages, and create two priority lists:_
#'   a. _Routes with high traffic (one end of the list)._
#'   b. _Routes with very low traffic (the other end of the list)"._

us_world_dt <- us_world_dt %>% arrange ( desc(TRIPS)) %>% 
             filter (TQRT == 1 | TQRT == 3 ) %>% print(n = nrow(.))

#' _"One further qualification... If possible select 2(b) with another criterion 
#' also in mind: ports that are currently low traffic that we expect to become
#' high traffic (because of changes in infrastructure, etc). This would set
#' us up nicely for future before-after comparisons."_

#  ***** BEGIN: --OMITTING THIS SECTION 16.01.2018 AS THERE IS NOT ENOUGH DATA AVAILABALE *****

# get port information from external file
port_info <- read_excel("/Users/paul/Box Sync/CU_NIS-WRAPS/170727_port_information/160322_57_ports_selection.xlsx")
  # port_info %>% print(n = nrow(.))

# keep port information that is relavant to the list created here 
port_info <- port_info %>% 
  filter ( PLACE_ID %in% c(us_world_dt$PRTA, us_world_dt$PRTB) )
  # %>% print(n = nrow(.))

#  select columns, set 0's to NAs, convert types - get a cleaner table
port_info <- port_info %>% select("PLACE_ID", "CHANGES") %>% 
             mutate(CHANGES = replace(CHANGES, CHANGES == 0, NA)) %>% 
             na.omit() %>% mutate(PLACE_ID = as.numeric(PLACE_ID)) 

# left join changes to table  
us_world_dt <- left_join (us_world_dt, port_info, by = c("PRTA" = "PLACE_ID")) 
us_world_dt <- left_join (us_world_dt, port_info, by = c("PRTB" = "PLACE_ID"))


# merge columns and drop columns
us_world_dt <- us_world_dt %>% mutate(CHANGES = coalesce(CHANGES.x, CHANGES.y)) %>%
  select(-one_of(c("CHANGES.x", "CHANGES.y"))) 

# replace character in `Changes` column, for Excel compatibility
us_world_dt$CHANGES <- gsub("\\+", "more ", us_world_dt$CHANGES)
us_world_dt$CHANGES <- gsub("\\-", "less ", us_world_dt$CHANGES)

#  ***** END: -- OMITTING THIS SECTION 16.01.2018 AS THERE IS NOT ENOUGH DATA AVAILABALE *****

#' Print and save final list:
us_world_dt <- us_world_dt %>% arrange (desc(TQRT), desc(TRIPS), desc(RANK)) %>% print(n = nrow(.))


#' Saving for R 
save (us_world_dt, file =
  "/Users/paul/Box Sync/CU_NIS-WRAPS/170815_R_storage/180416_30_select_samples__US_xtr_JPN_routes__selected.Rdata")

#' Saving for humans and external viewers:
write_excel_csv ( us_world_dt, 
                 "/Users/paul/Box Sync/CU_NIS-WRAPS/170919_R_tables/180416_30_select_samples__US_xtr_JPN_routes__selected.csv",
                 na = "NA", append = FALSE, col_names = TRUE)


#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Create maps
#'
#' ## Prepare data to be mapped
#' 
#' Rename element, can be used for further subsetting if desired

# not using original ranking
#drawn_routes <- us_us 

drawn_routes <- us_world_dt 


#' This could be written up as function. Dividing point columns for `geom_line()`:
pointa <- dplyr::select(drawn_routes, c("ROUTE", "RANK", "EDST", "TRIPS", 
                                        "PALATI", "PALONG", "PORTA", "COUNA", "TQRT"))
pointb <- dplyr::select(drawn_routes, c("ROUTE", "RANK", "EDST", "TRIPS", 
                                        "PBLATI", "PBLONG", "PORTB", "COUNB", "TQRT"))
                                        
#' Rename variables to match each other and other sata to be plotted:
names(pointa) <- c("ROUTE", "RANK", "EDST", "TRIPS", "LATI", "LONG", "PORT",
                   "COUN", "TQRT")
                                        
names(pointb) <- c("ROUTE", "RANK", "EDST", "TRIPS", "LATI", "LONG", "PORT",
                   "COUN", "TQRT")


#' Stack Data Frames (Tibbles) on top of each other so that they can be parsed by `geom_line()`:
points_all <- rbind(pointa, pointb)

#' Sort Tibble rows to check - each `ROUTE` should be there twice:
points_all <- dplyr::arrange(points_all, desc(ROUTE)) %>% print(n = nrow(.))

#' ## Prepare base layer 
#' 
#' Initially defining the base map, without Antarctica.

world <- map_data("world")
world <- world[ which (world$region != "Antarctica"), ]   # remove Antarctica


#' This could be written up as function.
#' 
#' ## Compose map 
#' 
#' US - WORLD connections - all

m1 <-  ggplot() + 
  geom_polygon (
    data = world, 
    aes (x=long, y = lat, group = group)
  ) + 
  coord_fixed (
    xlim = c(-170, 175),  ylim = c(-50, 80), ratio = 1.3
  ) +
  geom_line ( data = points_all, 
    aes (x = LONG, y = LATI, group = ROUTE, colour = RANK)
  ) +
  scale_colour_gradient (
    low = "deepskyblue", high = "firebrick1"
  ) +
  geom_label_repel ( 
    data = distinct (points_all , PORT, .keep_all = TRUE),
    aes (LONG, LATI, label = PORT), 
    size = 2,
    segment.color = 'grey50'
  ) +
  xlab(
    "Longitude"
  ) +
  ylab(
    "Latitude"
  ) +
  ggtitle (
    "North American samples and their port connections to Japan"
  ) +
  theme (
    legend.position="bottom"
  ) +
  theme (
    plot.title = element_text (hjust = 0.5)
  )

#' ## Map printing
#'
#' Use multiplot if desirable (likely won't render or render well) in `.pdf`
print(m1)

#' 
#' <!-- #################################################################### -->

#' <!-- #################################################################### -->
#'
#' # Session info
#' 
#' The code and output in this document were tested and generated in the 
#' following computing environment:
#+ echo=FALSE
sessionInfo()

#' # References 

