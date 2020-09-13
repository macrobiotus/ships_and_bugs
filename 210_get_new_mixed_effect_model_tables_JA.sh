library(lme4) # GLMM (mixed models)
library(emmeans) # for studying/ploting interactions in the (G)LM models
library(MASS)
library(car) #qqp plots
library(StatisticalModels) # GLMER and GLMER function. Generalized lineal mixed model selection and testing for overdispersion see https://rdrr.io/github/timnewbold/StatisticalModels/ 
library("PerformanceAnalytics")

portA=read.table("~/Downloads/Corrected_tables/01_results_euk_asv00_deep_UNIF_model_data_2020-Apr-17-10-33-17_no_ph_joined_no-nas_scaled.csv",header=T)
portB=read.table("~/Downloads/NIS_WRAPS__new_data_sets_available_and_attached/200427_model_tables/02_results_euk_asv00_shal_UNIF_model_data_2020-Apr-27-16-48-11_no_ph_joined_no-nas_scaled.csv", header=T)
comp=read.table("~/Downloads/NIS_WRAPS__new_data_sets_available_and_attached/ports_S22_D19_comparison.txt",header=T)
portC=read.table("~/Downloads/NIS_WRAPS__new_data_sets_available_and_attached/ports_S22_noNX_noVN.txt",header=T)
correl=comp[, c('UNIFRAC_S22', 'UNIFRAC_D19')]
chart.Correlation(correl, histogram=TRUE, pch=19)



hist(portB$RESP_UNIFRAC)
#fitting noraml and Gamma distributions to the UNIFRAC DISTANCES ## Note both distributions fit equally well. 
norm=fitdistr(portB$RESP_UNIFRAC,"normal")
qqp(portB$RESP_UNIFRAC, "norm")
gama=fitdistr(portA$RESP_UNIFRAC,"gamma")
qqp(portA$RESP_UNIFRAC, "gamma", shape = gama$estimate[[1]], rate = gama$estimate[[2]])

# GLM modelling
M1_N<- glmer(RESP_UNIFRAC ~ F_FON_NOECO_NOENV + ECO_DIFF+PRED_ENV + ECO_DIFF:PRED_ENV +(1|PORT) +(1|DEST),family = gaussian, data = portA)
M2_G<- glmer(RESP_UNIFRAC ~ F_FON_NOECO_NOENV + ECO_DIFF+PRED_ENV + ECO_DIFF:PRED_ENV + (1|PORT) +(1|DEST),family = Gamma, data = port)

summary(M1_N)
summary(M2_G)

# plotting residues for models 
qqnorm(resid(M1_N)) 
qqline(resid(M1_N))

qqnorm(resid(M2_G)) 
qqline(resid(M2_G))


#Studying interactions
emtrends(M1, pairwise ~ ECO_DIFF, var="PRED_ENV") #comparing slops of env effect by Ecoregion
emtrends(M1, ~ ECO_DIFF, var="PRED_ENV") # same as above without contrast test

#plotting interactions
min(PRED_ENV)
max(PRED_ENV)
(mylist <- list(PRED_ENV=seq(-2,2,by=0.4),ECO_DIFF=c("FALSE","TRUE")))
emmip(M2_G, ECO_DIFF~PRED_ENV, at=mylist,CIs=TRUE)

# USING STATISTICALMODELS
 ####### PortA dataset deep rarefaction. 19 ports.
model.FreqTrip <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE)
                      
 model.JFreqTrip <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
  model.JAC_B_F <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE)                    
                      
  model.JAC_B_H <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_HON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
 
 model.JAC_B_F.risk <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(J_B_FON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
            
 model.JAC_B_H.risk <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(J_B_HON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
model.B_F <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

  model.B_H <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, B_HON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

 model.B_F.risk <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(B_FON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

 model.B_H.risk <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(B_HON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
######## PortB dataset shallow rarefaction. 22 ports.                      
                      
 model.FreqTripB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE)
                      
 model.JFreqTripB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
  model.JAC_B_FB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE)                    
                      
  model.JAC_B_HB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_HON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
 
 model.JAC_B_FB.risk <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(J_B_FON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
            
 model.JAC_B_HB.risk <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(J_B_HON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
model.B_FB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

  model.B_HB <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, B_HON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

 model.B_FB.risk <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(B_FON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

 model.B_HB.risk <- GLMERSelect(modelData = portB,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(B_HON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
                     
                      
                      
                      
                      
                      
                      



model.comb.FreqTrip <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, VOY_FREQ=1, J_VOY_FREQ=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE)
                      
  model.comb.B_F <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_FON_NOECO_NOENV=1, B_FON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

  model.comb.B_H <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(PRED_ENV=1, J_B_HON_NOECO_NOENV=1, B_HON_NOECO_NOENV=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE)         

 model.comb.B_F.risk <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(B_FON_NOECO=1,J_B_FON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 

 model.comb.B_H.risk <- GLMERSelect(modelData = portA,responseVar = "RESP_UNIFRAC",
                      fitFamily = "gaussian",fixedFactors = "ECO_DIFF",
                      fixedTerms = list(B_HON_NOECO=1,J_B_HON_NOECO=1),
                      fitInteractions=TRUE,
                      randomStruct = "(1|PORT)+(1|DEST)",verbose = TRUE) 
                      
                                                                                                                                                
                   ###############
                      
       JAc_B_F=glmer(RESP_UNIFRAC ~ PRED_ENV +  J_B_FON_NOECO_NOENV + PRED_ENV:J_B_FON_NOECO_NOENV+  (1 | PORT) + (1 | DEST),family=Gamma,data=portA )  
       JAc_B_H=glmer(RESP_UNIFRAC ~ PRED_ENV +  J_B_HON_NOECO_NOENV + PRED_ENV:J_B_HON_NOECO_NOENV+  (1 | PORT) + (1 | DEST),family=Gamma,data=portA )
       vog=glmer(RESP_UNIFRAC~PRED_ENV+J_VOY_FREQ+PRED_ENV:J_VOY_FREQ+(1|PORT)+(1|DEST),family=gaussian,data=portA )
       comb.vog=glmer(RESP_UNIFRAC~PRED_ENV+J_VOY_FREQ+VOY_FREQ+J_VOY_FREQ:VOY_FREQ+(1|PORT)+(1|DEST),family=Gamma,data=portA )
       comb.FON=glmer(RESP_UNIFRAC~PRED_ENV+J_B_FON_NOECO_NOENV+B_FON_NOECO_NOENV+PRED_ENV:pol(J_B_FON_NOECO_NOENV+J_B_FON_NOECO_NOENV:B_FON_NOECO_NOENV+(1|PORT)+(1|DEST)
         
       #plotting interactions between to continous variables (e.g. dist -distance between islands- and size of the receptor island)
      #1.- determining levels for on of the variables (In this case logR island size)
       effa <- mean(portA$PRED_ENV) + .2*sd(portA$PRED_ENV) #"big islands"
       eff <- mean(portA$PRED_ENV)   #medium islands"
       effb <- mean(portA$PRED_ENV) - sd(portA$PRED_ENV) #"small islands"
       
       erra <- mean(portA$J_VOY_FREQ) + sd(portA$J_VOY_FREQ)
       err <- mean(portA$J_VOY_FREQ)
       errb <- mean(portA$J_VOY_FREQ) -sd(portA$J_VOY_FREQ)
       
      #2.- generate list values for plotting variables
      min(portA$PRED_ENV)
      max(portA$PRED_ENV)
      min(portA$J_B_FON_NOECO_NOENV)
      max(portA$J_B_FON_NOECO_NOENV)
      (mylist <- list(PRED_ENV=seq(-1.5,2.5,by=.5),J_VOY_FREQ=c(errb,err,erra)))
      (mylist2 <- list(J_B_FON_NOECO_NOENV=seq(-0.8,3.8,by=0.8),PRED_ENV=c(effb,eff,effa)))
      (mylist3 <- list(J_VOY_FREQ=seq(-1,1,by= 1),PRED_ENV=c(effb,eff,effa)))

      
    #3 plots the effect of the interactions
    emmip(JAc_B_F,J_B_FON_NOECO_NOENV~PRED_ENV,at=mylist, CIs=TRUE) 
    emmip(JAc_B_F,PRED_ENV~J_B_FON,at=mylist2, CIs=TRUE)
emmip(vog,J_VOY_FREQ~PRED_ENV,at=mylist3, CIs=TRUE) 
emmip(jf,J_B_FON_NOECO_NOENV~PRED_ENV,at=mylist3, CIs=TRUE) 

library("viridis")
cols <- viridis(20)
p= emmip(jf,J_B_FON_NOECO_NOENV~PRED_ENV,at=mylist3, CIs=TRUE)
p+scale_color_manual(values=c(cols[1],cols[12],cols[18]))+theme(panel.grid =element_blank(),axis.line = element_line(colour = "black",size = 1,),panel.background = element_rect(fill = "white", colour = "white"),legend.background = element_rect(fill = "white"),legend.key = element_rect(fill = "white"))+labs(y="UNIFRAC distance (linear prediction)", x = "Same Ecoregion", colour = "Traffic")
            
q= emmip(eo2,J_VOY_FREQ~PRED_ENV,at=mylist3, CIs=TRUE)
     q+scale_color_manual(values=c(cols[1],cols[12],cols[18]))+theme(panel.grid =element_blank(),axis.line = element_line(colour = "black",size = 1,),panel.background = element_rect(fill = "white", colour = "white"),legend.background = element_rect(fill = "white"),legend.key = element_rect(fill = "white"))+labs(y="UNIFRAC distance (linear prediction)", x = "Environmental similarity", colour = "Traffic")
     
 z=emmip(vog,J_VOY_FREQ~PRED_ENV,at=mylist3, CIs=TRUE) 
   z+scale_color_manual(values=c(cols[1],cols[12],cols[18]))+theme(panel.grid =element_blank(),axis.line = element_line(colour = "black",size = 1,),panel.background = element_rect(fill = "white", colour = "white"),legend.background = element_rect(fill = "white"),legend.key = element_rect(fill = "white"))+labs(y="UNIFRAC distance (linear prediction)", x = "Environmental similarity", colour = "Traffic")
     

     
     ggsave(file= "~/Documents/eDNA/NSF-ports/shallow_env_inter",device= "eps")
       
                      
        ###################              
                      
      JAC_B_F.risk=glmer(RESP_UNIFRAC~J_B_FON_NOECO+(1|PORT)+(1|DEST),family=Gamma, data=portA) 
      
      #######################
      
      VOY_trp =glmer(RESP_UNIFRAC ~ VOY_FREQ+PRED_ENV + ECO_DIFF:PRED_ENV+  ECO_DIFF + (1 | PORT) + (1 | DEST),family=Gamma, data=portA)             
                    
                      
final=GLMER(modelData = port,responseVar = "RESP_UNIFRAC",fitFamily = "Gamma",
            fixedStruct = "  ECO_DIFF +PRED_ENV +ECO_DIFF:PRED_ENV ",
randomStruct = "(1|PORT)+(1|DEST)",REML = TRUE) #using GLMER to fit he best model according the selection.

# testing for overdispersion
GLMEROverdispersion(final$model)

 finalR=glmer(RESP_UNIFRAC ~ F_FON_NOECO_NOENV + ECO_DIFF+PRED_ENV + ECO_DIFF:PRED_ENV + (1|PORT) +(1|DEST),family = Gamma, data = port) #final model for plotting resifues, same as final different package
qqnorm(resid(finalR)) 
qqline(resid(finalR))

min(PRED_ENV)
max(PRED_ENV)
(mylist <- list(PRED_ENV=seq(-2,2,by=0.4),ECO_DIFF=c("FALSE","TRUE")))
emmip(eo2, ECO_DIFF~J_VOY_FREQ, at=mylist3,CIs=TRUE)

library("igraph")
settlers=portA[,1:2]
settlers$weight=portA$J_VOY_FREQ #generates object with combination of ports and a value (distance of interest)
G <- graph.data.frame(settlers,directed=FALSE) # next two steps (G and A) convert the object into a simmetrical matrix.
A <- as_adjacency_matrix(G,type="both",names=TRUE,sparse=FALSE,attr="weight")
heatmap(A, symm=T)




settlers[,1]=as.character(settlers[,1])
settlers[,2]=as.character(settlers[,2])  

 
ggp <- ggplot(portA, aes(PORT, DEST)) +                           # Create heatmap with ggplot2
+   geom_tile(aes(fill = J_VOY_FREQ))
> ggp
> ggp+scale_fill_gradient(low = "yellow", high = "red")


