
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

# __________________________________________________ ####

#%- fig 3 Stats-- Encoding Model Kernel AUCs ####


#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig3_encodingModel.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class)


#- Subset to one kernel auc value per eventType per subject
# df= df(df$timeLock==0)
df= df[df$timeShift== 0.025,]


#2%%-- Run model ####

model= lmerTest::lmer('betaAUCpostEvent ~ eventType + (1|subject)', data=df)
model_anova<- anova(model)


# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig3_encoding_stats_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model, ~ eventType)


# 3%%-- Posthoc tests ####

# -- T Test compare AUCs vs null of 0 
#%% -- Stat comparison of AUC Kernels vs. null of 0 and comparison between two

EMM <- emmeans(model, ~ eventType)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t= test(EMM, null=0, adjust='sidak')


#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests


fig3_stats_encodingModel_A_postEventKernel_0_description= "Figure 3: Encoding model, Post-Event Kernel AUCs"
fig3_stats_encodingModel_A_postEventKernel_1_model= model
fig3_stats_encodingModel_A_postEventKernel_2_model_anova= model_anova
fig3_stats_encodingModel_A_postEventKernel_3_model_post_hoc_pairwise= tPairwise
fig3_stats_encodingModel_A_postEventKernel_3_model_post_hoc_t= t


#5%%-- Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig3_stats_encodingModel_A_postEventKernel.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig3_stats_encodingModel_postEventKernel_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig3_stats_encodingModel_A_postEventKernel_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig3_stats_encodingModel_A_postEventKernel_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc :') # Make sure for posthocs the summary is printed with pval correction
print(fig3_stats_encodingModel_A_postEventKernel_3_model_post_hoc_t, by = NULL, adjust = "sidak")


'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console




# __________________________________________________ ####



## %- fig 3 Stats-- Encoding Model Kernel Time series ####
# 
# #- hitting some warnings with emmeans due to df size so commenting out unless necessary
# 
# #1%%-- Load data from .pkl ####
# 
# pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig3_encodingModel.pkl"
# 
# df <- pd$read_pickle(pathData)
# 
# 
# ###### summarize data
# summary(df)
# 
# #verify dtypes imported properly
# sapply(df, class)
# 
# 
# #- Subset to one kernel auc value per eventType per subject
# # df= df(df$timeLock==0)
# 
# 
# #2%%-- Run model ####
# 
# model= lmerTest::lmer('beta ~ eventType * timeShift + (1|subject)', data=df)
# model_anova<- anova(model)
# 
# 
# # -- Interaction plot
# 
# # 3%%-- Posthoc tests ####
# 
# # -- T Test compare AUCs vs null of 0 
# #%% -- Stat comparison of AUC Kernels vs. null of 0 and comparison between two
# 
# EMM <- emmeans(model, ~  eventType | timeShift)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise= tPairwise
# 
# # for active proportion, check if each level significantly different from 0.5 (chance)
# t= test(EMM, null=0, adjust='sidak')

