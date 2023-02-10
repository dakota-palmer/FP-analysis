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



## ----- FIGURE 4 C --------------------------------------------------------####

#%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig4cd.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class) 

#%% Figure 4CD Stats A -- Compare PE Ratio by Cue+Laser

#%%-- Subset data ## 
#Remove missing/invalid observations 
df_Sub_A= df

#%%-- Run LME ##

model= lmerTest::lmer('ResponseProb ~ CueID * LaserTrial * StimLength + (1|Subject)', data=df_Sub_A)


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
fig2D_stats_A_0_description= "Figure 4CD: DS opto all"
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



