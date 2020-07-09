# Get graphical representation of detected taxa
# =============================================
# akin to 
# E. E. Sigsgaard, F. Torquato, T. G. Frøslev, A. B. M. Moore, J. M. Sørensen, 
#   P. Range, R. Ben‐Hamadou, S. S. Bach, P. R. Møller, P. F. Thomsen, Using 
#   vertebrate environmental DNA from seawater in biomonitoring of marine 
#   habitats. Conserv. Biol. 34, 697–710 (2020). 

# looks like Reingold-Tilford graph layout algorithm
# Reingold, E and Tilford, J (1981). Tidier drawing of trees. IEEE Trans. on Softw. Eng., SE-7(2):223–228. 

rm(list=ls(all=TRUE)) # clear memory

library("tidyverse")  # work using tibbles
library("data.tree")  # https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html


# Part I: Load Blast results
# --------------------------

load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_deep_with-ncbi-info.Rdata")

head(blast_results_final)


# Part II: Format data
# --------------------

# add pathString variable for data.tree package
blast_results_final$pathString <- paste("18S", 
  blast_results_final$superkingdom, 
  blast_results_final$phylum, 
  blast_results_final$class, 
  blast_results_final$order, 
  blast_results_final$family,
  sep = "/")

# blast_results_final$genus,
# blast_results_final$species,

# Part III: Get tree graph   
# -----------------------------------------------------

# *** Using networkD3 ***
require("networkD3")

blast_results_final$superkingdom[which(is.na(blast_results_final$superkingdom))] <- "sk_na"
blast_results_final$phylum[which(is.na(blast_results_final$phylum))] <- "ph_na"
blast_results_final$class[which(is.na(blast_results_final$class))] <- "cl_na"
blast_results_final$order[which(is.na(blast_results_final$order))] <- "or_na"
blast_results_final$family[which(is.na(blast_results_final$family))] <- "fm_na"
blast_results_final$genus[which(is.na(blast_results_final$genus))] <- "gn_na"
blast_results_final$species[which(is.na(blast_results_final$species))] <- "sp_na"


# create nodes
useRtree <- as.Node(blast_results_final, pathDelimiter = "/")
useRtreeList <- ToListExplicit(useRtree, unname = TRUE)
radialNetwork(useRtreeList)  


# *** Using iGraph  *** 
require("igraph")

# not working: 
#  name NA instances uniquely for tree algorithm
#  could likley be made prettier, but could find a better solution

# blast_results_final$superkingdom[which(is.na(blast_results_final$superkingdom))] <- paste(blast_results_final$superkingdom[which(is.na(blast_results_final$superkingdom))], seq_along(blast_results_final$superkingdom[which(is.na(blast_results_final$superkingdom))]), sep = "_" )
# blast_results_final$phylum[which(is.na(blast_results_final$phylum))] <- paste(blast_results_final$phylum[which(is.na(blast_results_final$phylum))], seq_along(blast_results_final$phylum[which(is.na(blast_results_final$phylum))]), sep = "_" )
# blast_results_final$class[which(is.na(blast_results_final$class))] <- paste(blast_results_final$class[which(is.na(blast_results_final$class))], seq_along(blast_results_final$class[which(is.na(blast_results_final$class))]), sep = "_" )
# blast_results_final$order[which(is.na(blast_results_final$order))] <- paste(blast_results_final$order[which(is.na(blast_results_final$order))], seq_along(blast_results_final$order[which(is.na(blast_results_final$order))]), sep = "_" )
# blast_results_final$family[which(is.na(blast_results_final$family))] <- paste(blast_results_final$family[which(is.na(blast_results_final$family))], seq_along(blast_results_final$family[which(is.na(blast_results_final$family))]), sep = "_" )
# blast_results_final$genus[which(is.na(blast_results_final$genus))] <- paste(blast_results_final$genus[which(is.na(blast_results_final$genus))], seq_along(blast_results_final$genus[which(is.na(blast_results_final$genus))]), sep = "_" )
# blast_results_final$species[which(is.na(blast_results_final$species))] <- paste(blast_results_final$species[which(is.na(blast_results_final$species))], seq_along(blast_results_final$species[which(is.na(blast_results_final$species))]), sep = "_" )

# create nodes
taxonomy <- as.Node(blast_results_final)

# textual summary
print(taxonomy, "src", limit = 500)

# graphical summary
plot(as.igraph(taxonomy, directed = TRUE, direction = "climb"))
