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
library("igraph")     # many graphs
library("ggraph")     # many graphs, nicer


# Part I: Load Blast results and read counts
# ------------------------------------------

# Blast result
load(file="/Users/paul/Documents/CU_combined/Zenodo/R_Objects/200520_560_blast-xml-conversion_deep_with-ncbi-info.Rdata")

head(blast_results_final)

# load read counts

read_counts <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/200706_165_eDNA_samples_Eukaryotes_features_tree-matched__feature-frequency-detail.csv", col_names = FALSE)
names(read_counts) <- c("iteration_query_def", "count")

# subset blast data for performance reasons

BlRsSbsDf <- blast_results_final %>% 
  select(superkingdom, phylum, class, order, family, genus, species, iteration_query_def, src, tax_id) %>%
  arrange(superkingdom, phylum, class, order, family, genus, species, tax_id)

head(BlRsSbsDf)

# merge in read counts via hash field

BlRsSbsDfJn <- full_join(BlRsSbsDf, read_counts, by = "iteration_query_def")
head(BlRsSbsDfJn)


# Part II: Format data for graphical purposes
# -------------------------------------------
#   https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html

# - everything below is clutter - consider treemap as in data.tree tutorial,
#   link below 
# inform data.tree about hierarchy by creating a column
BlRsSbsDfJn$pathString <- paste("18S", 
  BlRsSbsDfJn$superkingdom, 
  BlRsSbsDfJn$phylum, 
  BlRsSbsDfJn$class, 
  sep = "+")

#   BlRsSbsDfJn$order, 
#   BlRsSbsDfJn$family,
#   BlRsSbsDfJn$species,


# create a data.tree data structure
BlRsNds <- as.Node(BlRsSbsDfJn, pathDelimiter = "+")
print(BlRsNds, "count", "iteration_query_def", "src", "tax_id", "class" limit = 20)


# Part III: Get tree map   
# -----------------------------------------------------

# for treemap see: 
#   https://cran.r-project.org/web/packages/data.tree/vignettes/applications.html#world-populationtreemap-visualization


# Part III: Get tree graph   
# -----------------------------------------------------
# for basics see https://www.r-graph-gallery.com/309-intro-to-hierarchical-edge-bundling.html
# for more graphics see https://www.r-graph-gallery.com/310-custom-hierarchical-edge-bundling.html

# create a data frame giving the hierarchical structure of your individuals. 
# Origin on top, then groups, then subgroups

BlRsNdsNw <- ToDataFrameNetwork(BlRsNds, "count", "iteration_query_def", "src", "tax_id", "class")
head(BlRsNdsNw)

# Remove NA's from lebelling sstring
BlRsNdsNw$class[which(is.na(BlRsNdsNw$class))] <- " "

# create a vertices data.frame. One line per object of our hierarchy, giving features of nodes.
#  extend this fro more plotting options

length(BlRsNdsNw$from)
length(BlRsNdsNw$to)

vertices <- data.frame(name = unique(c(as.character(BlRsNdsNw$from), as.character(BlRsNdsNw$to))) ) 


head(vertices)
length(vertices$name)

# Create a graph object with the igraph library
mygraph <- graph_from_data_frame(BlRsNdsNw, vertices = vertices)

# igraph
plot(mygraph, vertex.label = BlRsNdsNw$class, edge.arrow.size=0, vertex.size=2)

# Visualize with ggraph:
#  see https://www.data-imaginist.com/2017/ggraph-introduction-edges/
#  for customisation see https://www.r-graph-gallery.com/339-circular-dendrogram-with-ggraph.html
#  vertices need more attributes

ggraph(mygraph, 'igraph', algorithm = 'tree', circular = TRUE) +
  geom_edge_diagonal(aes(alpha = ..index.., label = class)) +
  geom_node_point(aes(filter = degree(mygraph, mode = 'out') == 0), color = 'steelblue', size = 2) +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none")
