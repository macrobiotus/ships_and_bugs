# Plot ASV accumlations per port
# for Supplmental Information
# paul.czechowski@gmail.com
# code started 8-Jun-2020
# appended 24-Nov-2022

library("tidyverse") # for ggplot()
library("reshape2")  # for melting data frames
library("ggrepel")

# import data
tbl <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/200608_125_18S_eDNA_samples_tab_Eukaryotes_non_phylogenetic_curves.csv")

# format data - short format
tbl <- as_tibble(tbl)                  # better viewing options in this case  
sort(unique(tbl$Port)) # show port names
tbl <- tbl %>%  rename_all(make.names) # R compliant names
tbl <- tbl %>% select(., contains("depth"), "sample.id") # drop uneeded (?) columns
tbl <- tbl[which(!substr(tbl$sample.id, start = 1, stop = 2) %in% c("BA", "PH", "CH")), ] # filter out ports not included in final sample selection

#             - long format
tbl_long <- melt(tbl, id.vars =  "sample.id", variable.name = "calc", value.name = "ASVs")
tbl_long <- tbl_long %>% group_by(substr(tbl_long$sample.id, start = 1, stop = 2)) # identify ports
tbl_long <- tbl_long %>% rename(port = `substr(tbl_long$sample.id, start = 1, stop = 2)`) # correct variable name for plotting
tbl_long <- tbl_long %>% group_by(sub(".*_", "", calc)) # identify iterations
tbl_long <- rename(tbl_long, iter = `sub(".*_", "", calc)`) # rename depths group
tbl_long <- tbl_long %>% group_by(sub("_.*", "", calc)) # identify depth
tbl_long <- rename(tbl_long, depth = `sub("_.*", "", calc)`) # rename depths group


# convert numerical variables for plotting, and set other types
tbl_long$iter <- as.numeric(sub('.....', '', tbl_long$iter))
tbl_long$depth <- as.numeric(sub('......', '', tbl_long$depth))
tbl_long$port <- as.factor(tbl_long$port)
tbl_long$sample.id <- as.factor(tbl_long$sample.id)

# inspect data shape
tbl_long

# plotting old accumulation curves - see https://stackoverflow.com/questions/32669473/plotting-the-means-with-confidence-intervals-with-ggplot
# "mean_cl_normal" -> "Hmisc::smean.cl.normal()"
# - computes 3 summary variables: the sample mean and lower and upper Gaussian confidence limits based on the t-distribution
# - see https://rdrr.io/cran/Hmisc/man/smean.sd.html
ggplot(tbl_long, aes( x = depth, y = ASVs, colour = port)) +
  stat_summary(geom = "ribbon", fun.data = mean_cl_normal, fill="lightblue", alpha=0.3) +
  geom_vline(xintercept = 37900, linetype = "dotted", color = "black", linewidth=0.2) +
  geom_vline(xintercept = 49900, linetype = "dashed", color = "black", linewidth=0.2) +
  facet_wrap(~ port) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  guides(colour=FALSE)

# saving to old location
ggsave("200608_DI_accummulation_curves.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development",
       scale = 1.0, width = 175, height = 175, units = c("mm"),
       dpi = 500, limitsize = TRUE)

# saving to new location
ggsave("201124_DI_accummulation_curves_per_port.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS_manuscript/221111_Mol_Ecol_revision/2_new_display_items",
       scale = 1.0, width = 210, height = 148, units = c("mm"),
       dpi = 500, limitsize = TRUE)

ggplot(tbl_long, aes( x = depth, y = ASVs, colour = port, group = sample.id)) +
  geom_line(linewidth = 0.1) +
  geom_label_repel(box.padding = 0.5, label = "sample.id" ) +
  geom_vline(xintercept = 37900, linetype = "dotted", color = "black", linewidth=0.2) +
  geom_vline(xintercept = 49900, linetype = "dashed", color = "black", linewidth=0.2) +
  facet_wrap(~ port) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  guides(colour=FALSE)

# saving to new location
ggsave("201124_DI_accummulation_curves_per_port_per_sample.pdf", plot = last_plot(), 
       device = "pdf", path = "/Users/paul/Documents/CU_NIS-WRAPS_manuscript/221111_Mol_Ecol_revision/2_new_display_items",
       scale = 1.0, width = 210, height = 297, units = c("mm"),
       dpi = 500, limitsize = TRUE)



