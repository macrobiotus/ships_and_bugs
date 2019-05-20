#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Paul Czechowski - 17.05.2019
# http://tuxette.nathalievilla.org/?p=1696

# call with
# Rscript --vanilla sillyScript.R iris.txt out.txt

#  test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).\n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "foo.txt"
  args[3] = "fara.txt"
}

## program...

# load libraries
library(tidyverse) 
library(ape)        # tree import
library(biostring)  # sequence import
library(phyloseq)   # objects used as data units
library(ggplot2)    # plotting 
library(wesanderson) # colour schemes

# define paths
path_feat <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/147_18S_eDNA_samples_100_Metazoans_feature_qiime_feature_check/features-tax-meta.biom"
path_sequ <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/147_18S_eDNA_samples_100_Metazoans_feature_qiime_feature_check/dna-sequences.fasta"
path_tree <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/147_18S_eDNA_samples_100_Metazoans_feature_qiime_feature_check/tree.nwk"

# path_feat <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/145_18S_eDNA_samples_100_Metazoans_feature_qiime_artefacts/features-tax-meta.biom"
# path_sequ <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/145_18S_eDNA_samples_100_Metazoans_feature_qiime_artefacts/dna-sequences.fasta"
# path_tree <- "/Users/paul/Documents/CU_combined/Zenodo/Qiime/145_18S_eDNA_samples_100_Metazoans_feature_qiime_artefacts/tree.nwk"

# read data into R 
feat <- import_biom(path_feat)
sequ <- Biostrings::readDNAStringSet(path_sequ)  
tree <- ape::read.tree(path_tree)

# create Phyloseq object
physeq <- merge_phyloseq(feat, sequ, tree)

## agglomerate one level below Eukaryotes
physeq_glom = tax_glom(physeq, "Rank5")

## barplot
plot_bar(physeq_glom, x="Port", fill="Rank5") + theme_bw() + theme(axis.text.x = element_text(angle = 45, hjust = 1))

# do stuff with Phyloseq object - e.g. melting it for plotting
mdf <- psmelt(physeq)
class(mdf)
head(mdf, 20)
names(mdf)




