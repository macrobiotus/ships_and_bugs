################################################################
### Check & Merge Mandana and Paul's data
### E.K. 2020-03-18 - modified: P.C. 2020-03-27
###############################################################

# Housekeeping
rm(list=ls(all=TRUE)) ## clear memory
setwd("/Users/paul/Documents/CU_combined/Github") # set working directory, or (possibly) omit
packages<- c() # name required packages in this vector
lapply(packages, require, character.only=T) # load required packages

# Load and format Mandana's dataset
mdat <- read.table("/Users/paul/Documents/CU_combined/Zenodo/HON_predictors/200227_All_links_1997_2018_updated.csv", sep=",", header=TRUE) # read in Mandana's data
mdat$Combo1 <- paste(mdat$source, mdat$target, sep="-") #Combine two ports into one character string (source-target direction)
mdat$Combo2 <- paste(mdat$target, mdat$source, sep="-") #Combine ports into one character string (target-source direction)
head(mdat) #quick eye check of Mandana's data

# Load and format Paul's dataset
pdat <- read.table("/Users/paul/Documents/CU_combined/Zenodo/Results/01_results_euk_asv00_deep_UNIF_model_data_2020-Mar-13-13-16-52_no_ph_with_hon_info.csv", sep=",", header=TRUE) # read in Paul's input data emailed 2020-03-12)
pdat$Combo <-paste(pdat$PORT, pdat$DEST, sep="-") #Combine two ports into one character string (PORT-DEST)
head(pdat)# quick eye check of Paul's data

# Merge Madana's into Paul by summing up to two directed risk estimates for every port pair into one undirected estimate
output <- cbind(pdat,data.frame(matrix(nrow=dim(pdat)[1], ncol=13, 0)))  # create and output data frame - start with Paul's data then add Mandana's variables all set to 0
colnames(output)[9:21] <- colnames(mdat)[3:15] # name Mandana's risk columns
head(output) # quick eye check of the empty output data

for (i in 1:dim(output)[1]) # loop through each of Pauls Combo to find and sum Mandana's directed risk estimates
{
  match1 <- match(output$Combo[i], mdat$Combo1); match1[is.na(match1)] <- 0 # search Mandana's Combo1 for a match, if no match then 0
  match2 <- match(output$Combo[i], mdat$Combo2); match2[is.na(match2)] <- 0 # search Mandana's Combo2 for a match, if no match then 0
  sums <- colSums(mdat[c(match1, match2), 3:15]) # sum the two matched rows in Mandana's data
  output[i, 9:21]= sums # add summed risks to the output dataset
  rm(sums) # clear the sums variable (so it doesn't carry over)
} 

head(output) # quick eye check of the filled output data - raw version
output <- output[!(as.character(output$PORT)== as.character(output$DEST)),] # remove port pairs between the same ports
head(output) # quick eye check of the filled output data - pairs with identical ports removed
output$voyage_freq # quick eye check of the voyage frequency counts


write.table(output, "Output.csv", sep=",", row.names=FALSE) #write the output table

