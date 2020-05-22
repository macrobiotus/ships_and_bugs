# Calculations for Results section Taxonomy plots possibly per route
# =====================================================================
# For Blast results of shalloly rarfied ssamples in
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
blast_results_folder <- "/Users/paul/Documents/CU_combined/Zenodo/Blast"
blast_results_pattern <- glob2rx("*shallow_overlap_*_ports_blast_result_no_env.txt", trim.head = FALSE, trim.tail = TRUE) 

# read all file into lists for `lapply()` usage
blast_results_files <- list.files(path=blast_results_folder, pattern = blast_results_pattern, full.names = TRUE)

# read in xmls files - last done for shallow set 21.05.2020 ********************* ********************* ********************* 
plan(multiprocess) # enable 
blast_results_list <- furrr::future_map(blast_results_files, blastxml_dump, form = "tibble", .progress = TRUE) # takes 7-10 hours on four cores - avoid by reloading full object from disk 

# continue here after 21.05.2020  ********************* ********************* ********************* *********************

# save(blast_results_list, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_shallow.Rdata")
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_shallow.Rdata", verbose = TRUE)


names(blast_results_list) <- blast_results_files # works

# create one large item from many few, while keeping source file info fo grouping or subsetting
blast_results_list %>% bind_rows(, .id = "src" ) %>%        # add source file names as column elements
                       clean_names(.) %>%                   # clean columns names 
                       group_by(iteration_query_def) %>%    # isolate groups of hits per sequence hash
                       slice(which.max(hsp_bit_score)) -> blast_results # save subset

nrow(blast_results) # 12882

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

# continue here 22.05.2020
# save(blast_results_appended, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_shallow_with-tax-id.Rdata")
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_shallow_with-tax-id.Rdata", verbose=TRUE)

length(blast_results_appended$tax_id) # 11978

# look up taxonomy table
tax_table <- as_tibble(get_strng(blast_results_appended$tax_id), rownames = "tax_id") %>% mutate(tax_id= as.numeric(tax_id))

# continue here 22.05.2020
nrow(tax_table) # 12882

# getting a tax table without duplicates to enable proper join command later
tax_table <- tax_table %>% arrange(tax_id) %>% distinct(tax_id, superkingdom, phylum, class, order, family, genus, species, .keep_all= TRUE)

# checks
head(tax_table)
nrow(tax_table)             # 3298 - as it should
all(!duplicated(tax_table)) #        and no duplicated tax ids anymore
lapply(list(blast_results_appended,tax_table), nrow) # first 12882, second deduplicated and with 3298 - ok 

# https://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join
blast_results_final <- left_join(blast_results_appended, tax_table, copy = TRUE) 
nrow(blast_results_final) # 12882 - table has correct length now 

# correcting factors
blast_results_final %>% ungroup(.) %>% mutate(src = as.factor(src)) -> blast_results_final
levels(blast_results_final$src) 

# diagnostic plot - ok
# ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
#     geom_bar(position="stack", stat="identity") +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))

blast_results_final$src <- plyr::revalue(blast_results_final$src, c("/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_1_ports_blast_result_no_env.txt"  =  "1 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_10_ports_blast_result_no_env.txt" =  "10 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_11_ports_blast_result_no_env.txt" =  "11 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_12_ports_blast_result_no_env.txt" =  "12 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_13_ports_blast_result_no_env.txt" =  "13 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_14_ports_blast_result_no_env.txt" =  "14 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_15_ports_blast_result_no_env.txt"  = "15 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_2_ports_blast_result_no_env.txt"  =  "2 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_3_ports_blast_result_no_env.txt"  =  "3 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_4_ports_blast_result_no_env.txt"  =  "4 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_5_ports_blast_result_no_env.txt"  =  "5 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_6_ports_blast_result_no_env.txt"  =  "6 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_7_ports_blast_result_no_env.txt"  =  "7 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_8_ports_blast_result_no_env.txt"  =  "8 Port(s)",
                                                                    "/Users/paul/Documents/CU_combined/Zenodo/Blast/110_85_18S_eDNA_samples_Eukaryotes-shallow_overlap_9_ports_blast_result_no_env.txt"  =  "9 Port(s)"))

blast_results_final$src <- factor(blast_results_final$src, levels = c("1 Port(s)", "2 Port(s)","3 Port(s)","4 Port(s)","5 Port(s)","6 Port(s)",
                                                                      "7 Port(s)","8 Port(s)","9 Port(s)","10 Port(s)","11 Port(s)","12 Port(s)",
                                                                      "13 Port(s)","14 Port(s)", "15 Port(s)"))


# diagnostic plot -ok 
# ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
#     geom_bar(position="stack", stat="identity") +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1))


# save object and save some time by reloading it
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# save(blast_results_final, file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_shallow_with-ncbi-info.Rdata")
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_shallow_with-ncbi-info.Rdata")

write.xlsx(blast_results_final, "/Users/paul/Documents/CU_combined/Zenodo/Blast/200520_560_blast-xml-conversion_shallow_with-ncbi-info.xlsx", overwrite = FALSE)

# Part II: Plot Tax at ports with blast taxonomy 
# ----------------------------------------------

ggplot(blast_results_final, aes(x = src, y = phylum, fill = phylum)) + 
    geom_bar(position="stack", stat="identity") +
    ggtitle("Phyla at port(s) (shallowly rarefied data)") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())

ggsave("200521_phyla_at_ports_shallow.pdf", plot = last_plot(), 
         device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/",
         scale = 1.5, width = 140, height = 105, units = c("mm"),
         dpi = 500, limitsize = TRUE)

# Part III: relate taxonomy ids with route data and plot  
# -----------------------------------------------------

# (copy and adjust original blast subsetting code)

# use alluvial diagram
# https://cran.r-project.org/web/packages/ggalluvial/vignettes/ggalluvial.html
