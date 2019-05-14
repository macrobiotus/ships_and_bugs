#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# Paul Czechowski - 14.05.2019
# http://tuxette.nathalievilla.org/?p=1696

# call with
# Rscript --vanilla sillyScript.R iris.txt out.txt

#  test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).\n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "150_summary.txt"
  args[3] = "150_histogram.png"
}

## program...

# load libraries
library(plyr)

# functions
nonzero <- function(x) sum(x != 0)

# read-in
df = read.table(args[1],skip = 1,sep = '\t', header=TRUE)
# for debugging only
# df = read.table("/Users/paul/Documents/CU_combined/Zenodo/Qiime/145_18S_eDNA_samples_090_cl_100_Eukaryote_non_Metazoans_feature_qiime_artefacts/features-tax-meta.tsv", skip = 1,sep = '\t', header=TRUE)

# drop first column to enable summing
df$OTU.ID<-NULL

# isolate first two characters to enable grouping 
patterns <- unique(substr(names(df), 1, 2))  # store patterns in a vector

# calculate row sums per port(i.e. unique string group )
df_port <- sapply(patterns, function(xx) rowSums(df[,grep(xx, names(df)), drop=FALSE]))

# count non-zero values per column - test 
# df_port[1:4,1:4]
# colSums(df_port[1:4,1:4] != 0)

results <- colSums(df_port != 0)

# keep only first two characters to allow grouping by port
# names(df) <- substr(names(df), start = 1, stop = 2)

# save to file non-zero values per column in defined data and store  

print("Unique and non-unique features per port:")
print (results)
print("Summary of unique non-unique features per port:")
print(summary(results))


sink(file=args[2])

print("Unique and non-unique features per port:")
print (results)
print("Summary of unique non-unique features per port:")
print(summary(results))

sink()

png(file=args[3])
hist (results, 
      col = 'skyblue3', 
      xlab="Unique and Non-unique Features per Surveyed Port",
      ylab="Ports Surveyed", 
      breaks=20, 
      main=paste0("Features per Port in \"", basename(args[1]), "\"." ),
      )

dev.off()
