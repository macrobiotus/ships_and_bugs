#' ---
#' title: "Isolate Overlapping Features From eDNA Data"
#' author: "Paul Czechowski"
#' date: "1-Mai-2020"
#' output: pdf_document
#' toc: true
#' highlight: zenburn
#' bibliography: ./references.bib
#' ---

#' This code commentary is included in the R code itself and can be rendered at
#' any stage using `rmarkdown::render ("/Users/paul/Documents/CU_combined/Github/550_85_get_shared_taxa.R")`.
#' Please check the session info at the end of the document for further 
#' notes on the coding environment.
#'
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Preparing Environment
#'
#' ## Empty buffer

rm(list=ls())

#' ## Load Packages

library("ape")          # read tree file
library("Biostrings")   # read fasta file
library("phyloseq")     # filtering and utilities for such objects
library("tidyverse")    # handling data frames
library("data.table")   # possibly best for large data dimension

#' ## Functions
#' 
#'  Loading external functions:
source("/Users/paul/Documents/CU_combined/Github/500_00_functions.R")

#' Write Excel file from list of data frames:
write_df_list <- function(df_list, file_path){
  
  # per https://stackoverflow.com/questions/27524472/list-of-data-frames-to-individual-excel-worksheets-r
  require("openxlsx")     # write Excel Sheets
 
  # Create Workbook
  wb <- createWorkbook()

  # Iterate the same way as PavoDive, slightly different (creating an anonymous function inside Map())
  Map(function(data, nameofsheet){     

    addWorksheet(wb, nameofsheet)
    writeData(wb, nameofsheet, data)

  }, df_list, names(df_list))

  # Save workbook to excel file - writing to scratch currently, use other target lcation
  saveWorkbook(wb, file = file_path, overwrite = TRUE)

}


#'
#' ##  Data Read-in
#'
#' Set paths:
# sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/180_18S_eDNA_samples_tab_Eukaryotes_qiime_artefacts_non_phylogenetic/dna-sequences.fasta" 
# biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/180_18S_eDNA_samples_tab_Eukaryotes_qiime_artefacts_non_phylogenetic/features-tax-meta.biom"

sequ_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryote-shallow_features_tree-matched_qiime_artefacts/dna-sequences.fasta" 
biom_path <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/175_eDNA_samples_Eukaryote-shallow_features_tree-matched_qiime_artefacts/features-tax-meta.biom"


#' Create Phyloseq object:
biom_table <- phyloseq::import_biom (biom_path)
sequ_table <- Biostrings::readDNAStringSet(sequ_path)  
  
#' Construct Object:
phsq_ob <- merge_phyloseq(biom_table, sequ_table)

#' Clean Data:
phsq_ob <- remove_empty(phsq_ob)

#'
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Format Data
 
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

#'
#' <!-- #################################################################### -->



#' <!-- #################################################################### -->
#'
#' # Get Lists of Subset Data and Write to file
#'

#' `split(df, df$g)` returns a list of data.frames, one for each value of overlap.  
dfs_overlap_features <- split(features_shared, rowSums (features_shared != 0)-1 )

#' Write Excel tables:
write_df_list(dfs_overlap_features, "/Users/paul/Documents/CU_combined/Zenodo/Blast/500_85_18S_eDNA_samples_Eukaryotes-shallow_overlap.xlsx")

#'
#' <!-- #################################################################### -->


#' <!-- #################################################################### -->
#'
#' # Lookup Sequences and write Fasta Files
#'
#' Create a list with Biostring objects matching the feature id lists:
dfs_overlap_sequences <- lapply(dfs_overlap_features, function(x)  sequ_table[which(names(sequ_table) %in%  x$rn)])


#' Write files
for (i  in seq(1:length(dfs_overlap_sequences))){
  
  # One could use function `get_path()` as of 13-June-2019 here.
  
  # define path
  path="/Users/paul/Documents/CU_combined/Zenodo/Blast/500_85_18S_eDNA_samples_Eukaryotes-shallow_overlap.fasta.gz"
  
  # get file path without extensions
  prefix <- sub(pattern = "(.*?)\\..*$", replacement = "\\1", path)
  
  # create target file path
  path <- paste0(prefix, "_", i, "_ports.fasta.gz")
  
  # diagnostic message
  message ("Writing \"", path , "\".")
  
  # write files
  writeXStringSet(dfs_overlap_sequences[[i]], path, append=FALSE, compress=TRUE, format="fasta")

}

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
