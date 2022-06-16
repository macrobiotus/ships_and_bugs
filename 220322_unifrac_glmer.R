library(lme4) # GLMM (mixed models)
library(emmeans) # for studying/ploting interactions in the (G)LM models
library(MASS)
library(car) #qqp plots
library(StatisticalModels) # GLMER and GLMER function. Generalized lineal mixed model selection and testing for overdispersion see https://rdrr.io/github/timnewbold/StatisticalModels/ 
library("PerformanceAnalytics")

########## SAME DATASETS AS 18-APRIL-20 ANALYSES, INCLUDING VARIABLE FOR DNA EXTRACTION PROTOCOL (SAME::DIFERENT)##
###################################################################################################################

portA=read.csv("~/Downloads/Corrected_tables/01_results_euk_asv00_deep_UNIF_model_data_2020-Apr-17-10-33-17_no_ph_joined_no-nas_scaled_extraction.csv",header=T)
portB=read.csv("~/Downloads/NIS_WRAPS__new_data_sets_available_and_attached/200427_model_tables/02_results_euk_asv00_shal_UNIF_model_data_2020-Apr-27-16-48-11_no_ph_joined_no-nas_scaled_extraction.csv", header=T)
# USING STATISTICALMODELS
 ####### PortA dataset deep rarefaction. 19 ports.
model.FreqTrip <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE)
                      
 model.JFreqTrip <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
  model.JAC_B_F <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE)                    
                      
                       
model.B_F <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE) 

######## PortB dataset shallow rarefaction. 22 ports.                      
                      
 model.FreqTripB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE)
                      
 model.JFreqTripB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
  model.JAC_B_FB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE)                    
                      
model.B_FB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|EXTRACT)+(1|PORT)+(1|DEST)",verbose = TRUE) 





 