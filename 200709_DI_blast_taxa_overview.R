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


# Part IV: Get tree graph   
# -----------------------------------------------------
#  for basics see https://www.r-graph-gallery.com/309-intro-to-hierarchical-edge-bundling.html
#  for more graphics see https://www.r-graph-gallery.com/310-custom-hierarchical-edge-bundling.html
#  for customisation see https://www.r-graph-gallery.com/339-circular-dendrogram-with-ggraph.html
#  also see https://www.data-imaginist.com/2017/ggraph-introduction-edges/


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
#  vertices need more attributes

ggraph(mygraph, 'igraph', algorithm = 'tree', circular = TRUE) +
  geom_edge_diagonal(aes(alpha = ..index.., label = class)) +
  geom_node_point(aes(filter = degree(mygraph, mode = 'out') == 0), color = 'steelblue', size = 2) +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none")


# Part V: rebuild from scratch (started)
# -----------------------------------------------------
# using https://www.r-graph-gallery.com/339-circular-dendrogram-with-ggraph.html

# Libraries
library(ggraph)
library(igraph)
library(tidyverse)
library(RColorBrewer) 

# create a data frame giving the hierarchical structure of your individuals
d1=data.frame(from="origin", to=paste("group", seq(1,10), sep=""))
d2=data.frame(from=rep(d1$to, each=10), to=paste("subgroup", seq(1,100), sep="_"))
edges=rbind(d1, d2)
 
# create a vertices data.frame. One line per object of our hierarchy
vertices = data.frame(
  name = unique(c(as.character(edges$from), as.character(edges$to))) , 
  value = runif(111)
) 
# Let's add a column with the group of each name. It will be useful later to color points
vertices$group = edges$from[ match( vertices$name, edges$to ) ]
 
 
#Let's add information concerning the label we are going to add: angle, horizontal adjustement and potential flip
#calculate the ANGLE of the labels
vertices$id=NA
myleaves=which(is.na( match(vertices$name, edges$from) ))
nleaves=length(myleaves)
vertices$id[ myleaves ] = seq(1:nleaves)
vertices$angle= 90 - 360 * vertices$id / nleaves
 
# calculate the alignment of labels: right or left
# If I am on the left part of the plot, my labels have currently an angle < -90
vertices$hjust<-ifelse( vertices$angle < -90, 1, 0)
 
# flip angle BY to make them readable
vertices$angle<-ifelse(vertices$angle < -90, vertices$angle+180, vertices$angle)
 
# Create a graph object
mygraph <- graph_from_data_frame( edges, vertices=vertices )
 
# Make the plot
ggraph(mygraph, layout = 'dendrogram', circular = TRUE) + 
  geom_edge_diagonal(colour="grey") +
  scale_edge_colour_distiller(palette = "RdPu") +
  geom_node_text(aes(x = x*1.15, y=y*1.15, filter = leaf, label=name, angle = angle, hjust=hjust, colour=group), size=2.7, alpha=1) +
  geom_node_point(aes(filter = leaf, x = x*1.07, y=y*1.07, colour=group, size=value, alpha=0.2)) +
  scale_colour_manual(values= rep( brewer.pal(9,"Paired") , 30)) +
  scale_size_continuous( range = c(0.1,10) ) +
  theme_void() +
  theme(
    legend.position="none",
    plot.margin=unit(c(0,0,0,0),"cm"),
  ) +
  expand_limits(x = c(-1.3, 1.3), y = c(-1.3, 1.3))
