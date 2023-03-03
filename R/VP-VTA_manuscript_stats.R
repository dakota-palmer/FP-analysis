######################################################
## script for importing .pkls from Python
##
## 2021-10-11
####################################################

###### enter python env ####
Sys.setenv(RETICULATE_PYTHON = "C:/Users/Dakota/anaconda3/envs/spyder-env-seaborn-update")

pd <- import("pandas")


#%%-- Import dependencies ####
# library(lme4)
library(reticulate)
library(lmerTest)
library(emmeans)

#%% -- Set Paths ####

#- NOTE: manually change working directory in RStudio to source file location! (up top session -> set working directory -> to source file location)
# https://statisticsglobe.com/set-working-directory-to-source-file-location-automatically-in-rstudio

#-Note: To read .pickles, pandas version in R environment has to match pandas version of .pkl created!

pathWorking= getwd()

pathOutput= paste(pathWorking,'/_output', sep="")
#get rid of space introduced by paste()
gsub(" ", "", pathOutput)



#%% --- FIGURE 2B STATS -------------------------------------------- #### 

#%% Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig2b.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class) 

#%% Figure 2B Stats A -- Compare DS vs NS AUC on special sessions with NS (stage >5)--####

#%%-- Subset data ## 
#Remove missing/invalid observations 
#-can only do stat comparison for DS vs NS in stages/sessions where NS auc is present
#so subset to stages >=5

#would need to convert to int and back to categorical for math comparison <5, so just exclude =='1'
df_Sub_A= df[df$stage!="1",]


#%%-- Run LME ##

library(lmerTest)

model= lmerTest::lmer('periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)', data=df_Sub_A)


model_anova<- anova(model)


#%%-- Run Follow-up post-hoc tests ####

#- Signifcant interaction term, want to follow-up and estimate main effects

#emmeans package useful for post-hoc
library(emmeans)


#-- Pairwise comparisons (t test) between TrialType for each sesSpecialLabel 
#workaround for sidak correction with only 2 groups:

#- Viz interaction plot & save
figName= "vp-vta_fig2B_stats_A_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model, trialType ~ sesSpecialLabel)

dev.off()
setwd(pathWorking)


#- Pairwise T- tests
EMM <- emmeans(model, ~ trialType | sesSpecialLabel)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now


#%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#naming scheme : figure_stats_{count/identifier of stats goal}_{count/identifier of stats chronology}_{descriptor of stats test}
# trying to make names for good alphanumeric sorting / legibility later

fig2B_stats_A_0_description= "DS vs NS AUC on special Sessions with NS"
fig2B_stats_A_1_model= model
fig2B_stats_A_2_model_anova= model_anova
fig2B_stats_A_3_model_post_hoc_pairwise= tPairwise 

#%% Figure 2B Stats B-- Compare DS vs Null/0 AUC on first session (no NS) --####

#-- subset data ####
# subset stage 1
df_Sub_B= df[df$stage==1,]

# subset DS trials only
df_Sub_B= df_Sub_B[df_Sub_B$trialType== 'aucDSblue',]

#--One sample T test DS vs null(0) for the first session
t= t.test(df_Sub_B$periCueBlueAuc)

#%%-- Save output to variables between tests  ####
fig2B_stats_B_0_description= "DS AUC vs 0 on first training day (no NS)"
fig2B_stats_B_1_t= t 


#%% Figure 2B Stats 2 -- 'Learning' across sesssions; Compare DS AUC across all special sessions --####

#-- subset DS trials for 'learning' across sessions
df_Sub_C= df[df$trialType =="aucDSblue",]

#-- LME
model= lmerTest::lmer('periCueBlueAuc ~ sesSpecialLabel + (1|subject)', data=df_Sub_C)

summary(model)


#-- ANOVA of LME 
model_anova<- anova(model)

#--Posthoc pairwise comparisons (t test)

#- Viz interaction plot & save
figName= "vp-vta_fig2b_stats_C_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model, ~ sesSpecialLabel)

dev.off()
setwd(pathWorking)

EMM <- emmeans(model, ~ sesSpecialLabel)   # where treat has 2 levels

tPairwise= pairs(EMM, adjust= "sidak")

#%%-- Save output to variables between tests  ####
fig2B_stats_C_0_description= "DS AUC vs 0 on first training day (no NS)"
fig2B_stats_C_1_model= model
fig2B_stats_C_2_model_anova= model_anova
fig2B_stats_C_3_model_post_hoc_pairwise= tPairwise 


#%%- Save output to File #### 

setwd(pathOutput)

# use sink to write console output to text file
# write everything to one file #removing print() calls doesn't seem to clean up anyway

# Fig2B_A
sink("vp-vta_fig2B_stats_A_DSvsNS.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig2B_stats_A_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig2B_stats_A_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig2B_stats_A_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:')
print(fig2B_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


# Fig2B_B
sink("vp-vta_fig2B_stats_B_firstSes_DSvs0.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig2B_stats_B_0_description)
'------------------------------------------------------------------------------'
print('1)---- One sample T-Test:')
print(fig2B_stats_B_1_t)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


# Fig2B_C
sink("vp-vta_fig2B_stats_C_Learning_DS.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig2B_stats_C_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig2B_stats_C_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig2B_stats_C_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:')
print(fig2B_stats_C_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console

setwd(pathWorking)


## ---- FIGURE 2D --------------------------------------------------------####

#%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig2d.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class) 

#%% Figure 2D Stats A -- Compare PE vs no PE AUC DS 

#%%-- Subset data ## 
#Remove missing/invalid observations 
df_Sub_A= df

#%%-- Run LME ##

model= lmerTest::lmer('periCueBlueAuc ~ trialOutcome + (1|subject)', data=df_Sub_A)


model_anova<- anova(model)


#%%-- Run Follow-up post-hoc tests ####

#- Signifcant interaction term, want to follow-up and estimate main effects


#-- Pairwise comparisons (t test) between TrialOutcome


#- Pairwise T- tests
EMM <- emmeans(model, ~ trialOutcome)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now


#%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests
fig2D_stats_A_0_description= "Figure 2D: PE vs no PE AUC , stage 7"
fig2D_stats_A_1_model= model
fig2D_stats_A_2_model_anova= model_anova
fig2D_stats_A_3_model_post_hoc_pairwise= tPairwise 


#%%-- Save output to File ####
# Fig2D_A
setwd(pathOutput)


sink("vp-vta_fig2D_stats_A_PEvsNoPE_DS.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig2D_stats_A_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig2D_stats_A_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig2D_stats_A_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:')
print(fig2D_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console

setwd(pathWorking)

## ----- FIGURE 1D ---------------------------------------------------------####

#%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig1d.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class) 

#%% Figure 1D Stats A -- Compare DS vs NS PE Ratio--####

#%%-- Subset data ## 
#Remove missing/invalid observations 
#only include the late trainPhase (when NS is present)

df_Sub_A= df[df$trainPhase=='late',]

#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_A$trainDayThisPhase)
# droplevels(df_Sub_A$trainPhase)


#%%-- Run LME ##

model= lmerTest::lmer('trialTypePEProb10s  ~ trialType * trainDayThisPhase + (1|subject)', data=df_Sub_A)


model_anova<- anova(model)


#%%-- Run Follow-up post-hoc tests ####

#-- Pairwise comparisons (t test) between TrialOutcome
#- Viz interaction plot & save
figName= "vp-vta_fig1D_stats_A_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model, trialType ~ trainDayThisPhase)

dev.off()
setwd(pathWorking)

#- Pairwise T- tests
EMM <- emmeans(model, ~ trialType | trainDayThisPhase)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now


#%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests
fig1D_stats_A_0_description= "Figure 1D: Late Training DS vs NS PE Ratio"
fig1D_stats_A_1_model= model
fig1D_stats_A_2_model_anova= model_anova
fig1D_stats_A_3_model_post_hoc_pairwise= tPairwise 



#%% Figure 1D Stats B -- Learning DS PE Ratio--####

#%%-- Subset data ## 
#Remove missing/invalid observations 
#include only DS PE Ratios, across both phases
df_Sub_B= df[df$trialType=='DStime',]

#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_A$trainDayThisPhase)
# droplevels(df_Sub_A$trainPhase)


#%%-- Run LME ##
 #-- This isn't good because trainDayThisPhase==0 in both early and late. ----$$$$
model= lmerTest::lmer('trialTypePEProb10s  ~ trainDayThisPhase + (1|subject)', data=df_Sub_B)


model_anova<- anova(model)


#%%-- Run Follow-up post-hoc tests ####

# #-- Pairwise comparisons (t test) between TrialOutcome
# #- Viz interaction plot & save
# figName= "vp-vta_fig1D_stats_B_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model, trialType ~ trainDayThisPhase)
# 
# dev.off()
# setwd(pathWorking)

#- Pairwise T- tests
EMM <- emmeans(model, ~  trainDayThisPhase)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now


#%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests
fig1D_stats_B_0_description= "Figure 1D:  Learning- DS PE Ratio early & late"
fig1D_stats_B_1_model= model
fig1D_stats_B_2_model_anova= model_anova
fig1D_stats_B_3_model_post_hoc_pairwise= tPairwise 


#%%-- Save output to File ####
# B
setwd(pathOutput)


sink("vp-vta_fig1D_stats_B_Learning_DS_PE_Ratio.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig1D_stats_B_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig1D_stats_B_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig1D_stats_B_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:')
print(fig1D_stats_B_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console

setwd(pathWorking)



## ----- FIGURE 4 CD --------------------------------------------------------####

#%- Fig 4CD Stats B-- No Laser Sessions ####

#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig4cd.pkl"

df <- pd$read_pickle(pathData)



###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class) 

#%%-- Subset data ## 
#Remove missing/invalid observations 
# df_Sub_A= df

#- Can only include laserTrial for StimLength >0
df_Sub_B= df[df$StimLength == 0,]


df_Sub_B_VTA= df_Sub_B[df_Sub_B$Projection=='VTA',]

# df_Sub_VTA_DS= df_Sub_VTA[df_Sub_VTA$CueID=='DS',]

df_Sub_B_mdThal= df_Sub_B[df_Sub_B$Projection=='mdThal',]



#2%%-- Run LME ####

#- Pooled
model= lmerTest::lmer('ResponseProb ~ Projection * CueID  + (1|Subject)', data=df_Sub_B)

modelLatency= lmerTest::lmer('RelLatency ~ Projection * CueID  + (1|Subject)', data=df_Sub_B)
 
# emmip(model,  Projection ~ CueID )
# emmip(modelLatency,  Projection ~ CueID )

model_pooled= model
modelLatency_pooled=modelLatency
model_anova_pooled<- anova(model)
modelLatency_anova_pooled<- anova(modelLatency)

#- VTA
model= lmerTest::lmer('ResponseProb ~  CueID  + (1|Subject)', data=df_Sub_B_VTA)

modelLatency= lmerTest::lmer('RelLatency ~  CueID  + (1|Subject)', data=df_Sub_B_VTA)

model_VTA<- model
modelLatency_VTA<- modelLatency
model_anova_VTA<- anova(model)
modelLatency_anova_VTA<- anova(modelLatency)

#- mdThal
model= lmerTest::lmer('ResponseProb ~  CueID  + (1|Subject)', data=df_Sub_B_mdThal)

modelLatency= lmerTest::lmer('RelLatency ~  CueID  + (1|Subject)', data=df_Sub_B_mdThal)

model_mdThal<- model
modelLatency_mdThal<- modelLatency
model_anova_mdThal<- anova(model)
modelLatency_anova_mdThal<- anova(modelLatency)

# #- print visually compare quickly
# model_anova_pooled
# model_anova_VTA
# model_anova_mdThal
# 
# summary(model_pooled)
# summary(model_VTA)
# summary(model_mdThal)

#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests
fig4C_stats_B_Pooled_0_description= "Figure 4C: DS Task opto, No Laser Sessions, PE prob, pooled projections"
fig4C_stats_B_Pooled_1_model= model_pooled
fig4C_stats_B_Pooled_2_model_anova= model_anova_pooled

fig4D_stats_B_Pooled_0_description= "Figure 4D: DS Task opto, No Laser Sessions, PE Latency, pooled projections"
fig4D_stats_B_Pooled_1_model= modelLatency_pooled
fig4D_stats_B_Pooled_2_model_anova= modelLatency_anova_pooled

fig4C_stats_B_VTA_0_description= "Figure 4C: DS Task opto, No Laser Sessions, PE prob, VTA"
fig4C_stats_B_VTA_1_model= model_VTA
fig4C_stats_B_VTA_2_model_anova= model_anova_VTA

fig4C_stats_B_mdThal_0_description= "Figure 4C: DS Task opto, No Laser Sessions, PE prob, mdThal"
fig4C_stats_B_mdThal_1_model= model_mdThal
fig4C_stats_B_mdThal_2_model_anova= model_anova_mdThal

fig4D_stats_B_VTA_0_description= "Figure 4D: DS Task opto, No Laser Sessions, PE Latency, VTA"
fig4D_stats_B_VTA_1_model= modelLatency_VTA
fig4D_stats_B_VTA_2_model_anova= modelLatency_anova_VTA

fig4D_stats_B_mdThal_0_description= "Figure 4D: DS Task opto, No Laser Sessions, PE Latency, mdThal"
fig4D_stats_B_mdThal_1_model= modelLatency_mdThal
fig4D_stats_B_mdThal_2_model_anova= modelLatency_anova_mdThal


#5%%-- Save output to File ####
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig4C_stats_B_NoLaserSessions_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4C_stats_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4C_stats_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4C_stats_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig4D_stats_B_NoLaserSessions_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4D_stats_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4D_stats_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4D_stats_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig4C_stats_B_NoLaserSessions_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4C_stats_B_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4C_stats_B_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4C_stats_B_VTA_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
print(summary(fig4C_stats_B_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))

'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig4D_stats_B_NoLaserSessions_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4D_stats_B_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4D_stats_B_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4D_stats_B_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(summary(fig4D_stats_B_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))

'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig4C_stats_B_NoLaserSessions_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4C_stats_B_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4C_stats_B_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4C_stats_B_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig4D_stats_B_NoLaserSessions_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4D_stats_B_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4D_stats_B_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4D_stats_B_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)

#%- Fig 4CD Stats A-  DS Task Laser Sessions ####

##

#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig4cd.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class)

#%% Figure 4D Stats A -- Laser Sessions

#%%-- Subset data ##
#Remove missing/invalid observations

#- Can only include laserTrial for StimLength >0
df_Sub_A= df[df$StimLength != 0,]

df_Sub_A_VTA= df_Sub_A[df_Sub_A$Projection=='VTA',]

# df_Sub_VTA_DS= df_Sub_VTA[df_Sub_VTA$CueID=='DS',]

df_Sub_A_mdThal= df_Sub_A[df_Sub_A$Projection=='mdThal',]


#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_A$trainDayThisPhase)
# droplevels(df_Sub_A$trainPhase)


#2%%-- Run LME ####

#-- Pooled
model= lmerTest::lmer('ResponseProb ~ Projection * CueID * LaserTrial * StimLength + (1|Subject)', data=df_Sub_A)
modelLatency= lmerTest::lmer('RelLatency ~ Projection * CueID * LaserTrial * StimLength + (1|Subject)', data=df_Sub_A)


model_pooled= model
model_anova_pooled<- anova(model)
modelLatency_pooled= modelLatency
modelLatency_anova_pooled= anova(modelLatency)

#-- VTA
  #VTA projection
    #-Probability
model_VTA= lmerTest::lmer('ResponseProb ~ CueID * LaserTrial * StimLength + (1|Subject)', data=df_Sub_A_VTA)
model_anova_VTA<- anova(model_VTA)
    #-Latency
modelLatency_VTA= lmerTest::lmer('RelLatency ~ CueID * LaserTrial * StimLength + (1|Subject)', data=df_Sub_A_VTA)
modelLatency_anova_VTA<- anova(modelLatency_VTA)

#-- mdThal
 #mdThal projection
    #-Probability
model_mdThal= lmerTest::lmer('ResponseProb ~ CueID * LaserTrial * StimLength + (1|Subject)', data=df_Sub_A_mdThal)
model_anova_mdThal<- anova(model_mdThal)
    #-Latency
modelLatency_mdThal= lmerTest::lmer('RelLatency ~ CueID * LaserTrial * StimLength + (1|Subject)', data=df_Sub_A_mdThal)
modelLatency_anova_mdThal<- anova(modelLatency_mdThal)



# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig4C_stats_A_Probability_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model_pooled, LaserTrial ~ StimLength | CueID | Projection )

dev.off()
setwd(pathWorking)

#pooled latency interaction plot
figName= "vp-vta_fig4D_stats_A_Latency_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(modelLatency_pooled, LaserTrial ~ StimLength | CueID | Projection )

dev.off()
setwd(pathWorking)


#2023-02-21
#4C) PE Prob results 
  # mdThal: Only significant effect = CueID
  # VTA: significant cueID*laserTrial*stimLength interaction ---> Followup test below
#4D) PE Latency results
  #mdThal: Only significant effect= CueID
  #VTA: Only significant effect= CueID... close (0.052) CueID*LaserTrial*StimLength interaction


#3%%-- Run Follow-up post-hoc tests ####

# #-- Pairwise comparisons (t test) between TrialOutcome
# #- Viz interaction plot & save
# - interaction plots should be same as above

# figName= "vp-vta_fig4CD_stats_B_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model_VTA, LaserTrial ~ StimLength | CueID )
# 
# dev.off()
# setwd(pathWorking)

#- Pairwise T- tests

#-- Pooled
EMM <- emmeans(model_pooled, ~ LaserTrial | StimLength | CueID | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_prob_Pooled= tPairwise

EMM <- emmeans(modelLatency_pooled, ~ LaserTrial | StimLength | CueID | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_latency_Pooled= tPairwise


#-- VTA
EMM <- emmeans(model_VTA, ~ LaserTrial | StimLength | CueID)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_prob_VTA= tPairwise

# #-- 2
# # CueID:LaserTrial:StimLength 0.1292  0.1292     1 85.28   4.4146 0.03858 *  
# 
# EMM <- emmeans(model_VTA, ~ CueID | LaserTrial | StimLength)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_prob_VTA2= tPairwise  
# 
# #--2


EMM <- emmeans(modelLatency_VTA, ~ LaserTrial | StimLength | CueID)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_latency_VTA= tPairwise

#-- mdThal

EMM <- emmeans(model_mdThal, ~ LaserTrial | StimLength | CueID)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_prob_mdThal= tPairwise

EMM <- emmeans(modelLatency_mdThal, ~ LaserTrial | StimLength | CueID)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_latency_mdThal= tPairwise

# 2023-02-21 posthoc comparison results: No significant contrasts. 

# 
# 
# #-- Makes sense to examine effects of laser duration separately for cue type?
# df_Sub_VTA_DS= df_Sub_VTA[df_Sub_VTA$CueID=='DS',]
# df_Sub_VTA_NS= df_Sub_VTA[df_Sub_VTA$CueID=='NS',]
# 
# 
# figName= "vp-vta_fig4CD_stats_B_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model_VTA, CueID ~ LaserTrial * StimLength )
# 
# dev.off()
# setwd(pathWorking)



#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

fig4C_stats_A_Pooled_0_description= "Figure 4C: DS Task opto, Laser Sessions, PE prob, pooled projections"
fig4C_stats_A_Pooled_1_model= model_pooled
fig4C_stats_A_Pooled_2_model_anova= model_anova_pooled
fig4C_stats_A_Pooled_3_model_post_hoc_pairwise= tPairwise_prob_Pooled

fig4D_stats_A_Pooled_0_description= "Figure 4D: DS Task opto, Laser Sessions, PE Latency, pooled projections"
fig4D_stats_A_Pooled_1_model= modelLatency_pooled
fig4D_stats_A_Pooled_2_model_anova= modelLatency_anova_pooled
fig4D_stats_A_Pooled_3_model_post_hoc_pairwise= tPairwise_latency_Pooled


fig4C_stats_A_VTA_0_description= "Figure 4C: DS Task opto, Laser Sessions, PE prob, VTA"
fig4C_stats_A_VTA_1_model= model_VTA
fig4C_stats_A_VTA_2_model_anova= model_anova_VTA
fig4C_stats_A_VTA_3_model_post_hoc_pairwise= tPairwise_prob_VTA


fig4C_stats_A_mdThal_0_description= "Figure 4C: DS Task opto, Laser Sessions, PE prob, mdThal"
fig4C_stats_A_mdThal_1_model= model_mdThal
fig4C_stats_A_mdThal_2_model_anova= model_anova_mdThal
fig4C_stats_A_mdThal_3_model_post_hoc_pairwise= tPairwise_prob_mdThal


fig4D_stats_A_VTA_0_description= "Figure 4D: DS Task opto, Laser Sessions, PE Latency, VTA"
fig4D_stats_A_VTA_1_model= modelLatency_VTA
fig4D_stats_A_VTA_2_model_anova= modelLatency_anova_VTA
fig4D_stats_A_VTA_3_model_post_hoc_pairwise= tPairwise_latency_VTA


fig4D_stats_A_mdThal_0_description= "Figure 4D: DS Task opto, Laser Sessions, PE Latency, mdThal"
fig4D_stats_A_mdThal_1_model= modelLatency_mdThal
fig4D_stats_A_mdThal_2_model_anova= modelLatency_anova_mdThal
fig4D_stats_A_mdThal_3_model_post_hoc_pairwise= tPairwise_latency_mdThal

# 
# #--- Followup: specifically examine DS trials 
# df_Sub_C_VTA= df_Sub_A_VTA[df_Sub_A_VTA$CueID=='DS',]
# #VTA projection
# #-Probability
# model_VTA= lmerTest::lmer('ResponseProb ~ LaserTrial * StimLength + (1|Subject)', data=df_Sub_C_VTA)
# model_anova_VTA<- anova(model_VTA)
# #-Latency
# modelLatency_VTA= lmerTest::lmer('RelLatency ~ LaserTrial * StimLength + (1|Subject)', data=df_Sub_C_VTA)
# modelLatency_anova_VTA<- anova(modelLatency_VTA)
# 
# # pairwise
# emmip(model_VTA, LaserTrial ~ StimLength)
# 
# EMM <- emmeans(model_VTA, ~ LaserTrial | StimLength)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_VTA= tPairwise



#5%% -- Figure 4CD Save output ####

# fig1D_stats_A_0_description= "Figure 1D: Late Training DS vs NS PE Ratio"
# fig1D_stats_A_1_model= model
# fig1D_stats_A_2_model_anova= model_anova
# fig1D_stats_A_3_model_post_hoc_pairwise= tPairwise


#------Pooled

sink("vp-vta_fig4C_stats_A_LaserSessions_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4C_stats_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4C_stats_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4C_stats_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig4D_stats_A_LaserSessions_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4D_stats_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4D_stats_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4D_stats_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig4C_stats_A_LaserSessions_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4C_stats_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4C_stats_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4C_stats_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
print(summary(fig4C_stats_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))

'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig4D_stats_A_LaserSessions_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4D_stats_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4D_stats_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4D_stats_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(summary(fig4D_stats_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))

'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig4C_stats_A_LaserSessions_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4C_stats_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4C_stats_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4C_stats_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig4D_stats_A_LaserSessions_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig4D_stats_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig4D_stats_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig4D_stats_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)





## ----- FIGURE XX ---------------------------------------------------------####



## ----- Notes on Stats  / Packages-----------------------------------------####

#-Don't use dynamic formula names for lmes. It won't show in the .summary()!

#-lmerTest may give more information when anova is called on lme (vs lmer4)

#-good resources about post-hoc testing: 
# https://stats.stackexchange.com/questions/187996/interaction-term-in-a-linear-mixed-effect-model-in-r
# https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html
# https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html

#- workaround if emms posthoc testing ignoring pvalue correction 'adjust':
# https://cran.r-project.org/web/packages/emmeans/vignettes/FAQs.html#noadjust



