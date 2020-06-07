# Plot ASV accumlations per port
# for Supplmental Information
# paul.czechowski@gmail.com
# code started 8-Jun-2020

library("tidyverse") # for ggplot()
library("reshape2")  # for melting data frames

# import data
tbl <- read_csv("/Users/paul/Documents/CU_combined/Zenodo/Display_Item_Development/200625_125_18S_eDNA_samples_tab_Eukaryotes_non_phylogenetic_curves.csv")

# format data
tbl <- as_tibble(tbl)


# plot curves