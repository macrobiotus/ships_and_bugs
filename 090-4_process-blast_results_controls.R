# Calculations for Results section Taxonomy plots possibly per route
# =====================================================================
# For Blast results of deeply rarfied ssamples in
# /Users/paul/Documents/CU_combined/Zenodo/Blast

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
library("openxlsx")   # write Excel tables

# define file path components for listing 
blast_results_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/090-218S_controls_tab_qiime_artefacts_control"
blast_results_pattern <- glob2rx("090-3_-sequences_blast_result_no_env*", trim.head = FALSE, trim.tail = TRUE) 

# read all file into lists for `lapply()` usage
blast_results_files <- list.files(path=blast_results_folder, pattern = blast_results_pattern, full.names = TRUE)

# read in xmls files - last done for controls 04.08.2020 ********************* ********************* ********************* 
plan(multiprocess) # enable 
blast_results_list <- furrr::future_map(blast_results_files, blastxml_dump, form = "tibble", .progress = TRUE) # takes 7-10 hours on four cores - avoid by reloading full object from disk 


# continue here after 20.05.2020  ********************* ********************* ********************* *********************
# save(blast_results_list, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200806_090-4_blast-xml-conversion_cntrl.Rdata")
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200806_090-4_blast-xml-conversion_cntrl.Rdata", verbose = TRUE)
names(blast_results_list) <- blast_results_files # works

# create one large item from many few, while keeping source file info fo grouping or subsetting
blast_results_list %>% bind_rows(, .id = "src" ) %>%        # add source file names as column elements
                       clean_names(.) %>%                   # clean columns names 
                       group_by(iteration_query_def) %>%    # isolate groups of hits per sequence hash
                       slice(which.max(hsp_bit_score)) -> blast_results # save subset

nrow(blast_results) # was 11978, now 2846 

# prepareDatabase not needed to be run multiple times
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# prepareDatabase(sqlFile = "accessionTaxa.sql", tmpDir = "/Users/paul/Sequences/References/taxonomizR/", vocal = TRUE) # takes a very long time - avoid by reloading full object from disk

# function for mutate to convert NCBI accession numbers to taxonomic IDs.
get_taxid <- function(x) {accessionToTaxa(x, "/Volumes/HGST1TB/Users/paul/Sequences/References/taxonomizR/accessionTaxa.sql", version='base')}

# function for mutate to use taxonomic IDs and add taxonomy strings
get_strng <- function(x) {getTaxonomy(x,"/Volumes/HGST1TB/Users/paul/Sequences/References/taxonomizR/accessionTaxa.sql")}

# add tax ids to table for string lookup - probably takes long time
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
blast_results_appended <- blast_results %>% mutate(tax_id = get_taxid(hit_accession)) # takes some time... 

# continue here 06.08.2020
# save(blast_results_appended, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200806_090-4_blast-xml-conversion_cntrl_with-tax-id.Rdata")
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200806_090-4_blast-xml-conversion_cntrl_with-tax-id.Rdata", verbose=TRUE)

length(blast_results_appended$tax_id) # was 11978, now 2846 

# look up taxonomy table
tax_table <- as_tibble(get_strng(blast_results_appended$tax_id), rownames = "tax_id") %>% mutate(tax_id= as.numeric(tax_id))

# continue here 21.05.2020
nrow(tax_table) # was 11978, now 2846 

# getting a tax table without duplicates to enable proper join command later
tax_table <- tax_table %>% arrange(tax_id) %>% distinct(tax_id, superkingdom, phylum, class, order, family, genus, species, .keep_all= TRUE)

# checks
head(tax_table)
nrow(tax_table)             #  540 - as it should
all(!duplicated(tax_table)) #    and no duplicated tax ids anymore
lapply(list(blast_results_appended,tax_table), nrow) # first 2846, second deduplicated and with 540 - ok 

# https://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join
blast_results_final <- left_join(blast_results_appended, tax_table, copy = TRUE) 
nrow(blast_results_final) # 11978 - table has correct length now 

# correcting factors
blast_results_final %>% ungroup(.) %>% mutate(src = as.factor(src)) -> blast_results_final
levels(blast_results_final$src) 

# diagnostic plot - ok
# ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
#     geom_bar(position="stack", stat="identity") +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))


# save object and some time by reloading it
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results_final, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200806_090-4_blast-xml-conversion_cntrl_with_ncbi.Rdata")
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200806_090-4_blast-xml-conversion_cntrl_with_ncbi.Rdata")

write.xlsx(blast_results_final, "/Users/paul/Documents/CU_combined/Zenodo/Qiime/090-218S_controls_tab_qiime_artefacts_control/200806_090-4_blast-xml-conversion_cntrl_with_ncbi.xlsx", overwrite = FALSE)

# Part II: Plot Tax at ports with blast taxonomy 
# ----------------------------------------------

ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
    geom_bar(position="stack", stat="identity") +
    ggtitle("Phyla in positive and negative controls") +
    theme_bw() +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())

ggsave("200806_phyla_in_controls.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 140, height = 105, units = c("mm"),
         dpi = 500, limitsize = TRUE)
