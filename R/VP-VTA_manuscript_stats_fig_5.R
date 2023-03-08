
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

#%- fig 5 Stats-- Phase 1- Free Choice ####


#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig5.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class)



#%%-- Subset data ##
#Remove missing/invalid observations
#- eliminate duplicate proportion values 
# currently active proportion is session level but df has 2 per session (1 per npTy1pe)
# so just remove from one trialType. This way can use same df for multiple models easily
df[df$typeLP=='ActiveLeverPress','probActiveLP']= NaN
df[df$typeLP=='ActiveLeverPress','LicksPerReward']= NaN



# #- Subset by session type 
df_Sub_A= df[df$trainPhaseLabel == '1-FreeChoice',]

# df_Sub_A= df[df$trainPhaseLabel == '2-FreeChoice-Reversal',]
# df_Sub_C= df[df$trainPhaseLabel == '3-ForcedChoice',]
# df_Sub_D= df[df$trainPhaseLabel == '4-FreeChoice-Test',]





df_Sub_A_VTA= df_Sub_A[df_Sub_A$Projection=='VTA',]

df_Sub_A_mdThal= df_Sub_A[df_Sub_A$Projection=='mdThal',]


#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_A$trainDayThisPhase)
# droplevels(df_Sub_A$trainPhase)


#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_A)
model= lmerTest::lmer('countLP ~ Projection * typeLP * Session + (1|Subject)', data=df_Sub_A)

modelProportion= lmerTest::lmer('probActiveLP ~ Projection * Session + (1|Subject)', data=df_Sub_A)

# modelLicks=  lmerTest::lmer('LicksPerReward ~ Projection * Session + (1|Subject)', data=df_Sub_A)
# modelLicks=  lmerTest::lmer('rewardLicks ~ Projection * Session + (1|Subject)', data=df_Sub_A)
modelLicks=  lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Projection * Session + (1|Subject)', data=df_Sub_A)



model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)
modelLicks_pooled= model
modelLicks_anova_pooled= anova(modelLicks)


#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countLP ~ typeLP * Session + (1|Subject)', data=df_Sub_A_VTA)
model_anova_VTA<- anova(model_VTA)
#-Proportion
modelProportion_VTA= lmerTest::lmer('probActiveLP ~ Session + (1|Subject)', data=df_Sub_A_VTA)
modelProportion_anova_VTA<- anova(modelProportion_VTA)

#-licks/reward
# modelLicks_VTA= lmerTest::lmer('LicksPerReward ~ Session + (1|Subject)', data=df_Sub_A_VTA)
# modelLicks_anova_VTA<- anova(modelProportion_VTA)
modelLicks_VTA= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Session + (1|Subject)', data=df_Sub_A_VTA)
modelLicks_anova_VTA<- anova(modelLicks_VTA)


#-- mdThal
#mdThal projection
#-Probability
model_mdThal= lmerTest::lmer('countLP ~ typeLP * Session + (1|Subject)', data=df_Sub_A_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
modelProportion_mdThal= lmerTest::lmer('probActiveLP ~ Session + (1|Subject)', data=df_Sub_A_mdThal)
modelProportion_anova_mdThal<- anova(modelProportion_mdThal)
#-licks/reward
# modelLicks_mdThal= lmerTest::lmer('LicksPerReward ~ Session + (1|Subject)', data=df_Sub_A_mdThal)
# modelLicks_anova_mdThal<- anova(modelProportion_mdThal)
modelLicks_mdThal= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP * Session + (1|Subject)', data=df_Sub_A_mdThal)
modelLicks_anova_mdThal<- anova(modelLicks_mdThal)


# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig5_stats_A_npCount_Session_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model_pooled, Session ~ typeLP | Projection )

# emmip(model_pooled, Projection ~ typeNP | Session )


dev.off()
setwd(pathWorking)

#pooled proportion interaction plot
figName= "vp-vta_fig5_stats_B_proportion_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(modelProportion_pooled, Session ~ Projection )

dev.off()
setwd(pathWorking)


#- Pairwise T- tests

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeLP | Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

  #pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

EMM <- emmeans(modelProportion_pooled, ~ Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_Pooled= test(EMM, null=0.5, adjust='sidak')


#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeLP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise
  
#-npActiveProportion
EMM <- emmeans(modelProportion_VTA, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_VTA= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_VTA= test(EMM, null=0.5, adjust='sidak')


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeLP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_mdThal, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_mdThal= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_mdThal= test(EMM, null=0.5, adjust='sidak')


#%% 2.5 -- Final Day specific tests? ####
# Alternatively, you could just do pairwise comparisons at the start and end of each phase (so sessions 1 and 6 here), since we aren't really concerned about the specific day a difference emerged, and whether one emerged by the end of training that wasn't there on day 1.
# just ignore the pariwise bc no sig interactions unless a priori



#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig5_stats_Phase1_FreeChoice_A_Pooled_0_description= "Figure 5: Lever Choice, Phase 1- Free Choice, Active vs Inactive NP Count, pooled projections"
fig5_stats_Phase1_FreeChoice_A_Pooled_1_model= model_pooled
fig5_stats_Phase1_FreeChoice_A_Pooled_2_model_anova= model_anova_pooled
fig5_stats_Phase1_FreeChoice_A_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig5_stats_Phase1_FreeChoice_B_Pooled_0_description= "Figure 5: Lever Choice, Phase 1- Free Choice, Active NP Proportion, pooled projections"
fig5_stats_Phase1_FreeChoice_B_Pooled_1_model= modelProportion_pooled
fig5_stats_Phase1_FreeChoice_B_Pooled_2_model_anova= modelProportion_anova_pooled
fig5_stats_Phase1_FreeChoice_B_Pooled_3_model_post_hoc_t= t_proportion_Pooled

#-VTA
fig5_stats_Phase1_FreeChoice_A_VTA_0_description= "Figure 5: Lever Choice, Phase 1- Free Choice, Active vs Inactive NP Count, VTA projections"
fig5_stats_Phase1_FreeChoice_A_VTA_1_model= model_VTA
fig5_stats_Phase1_FreeChoice_A_VTA_2_model_anova= model_anova_VTA
fig5_stats_Phase1_FreeChoice_A_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig5_stats_Phase1_FreeChoice_B_VTA_0_description= "Figure 5: Lever Choice, Phase 1- Free Choice, Active NP Proportion, VTA projections"
fig5_stats_Phase1_FreeChoice_B_VTA_1_model= modelProportion_VTA
fig5_stats_Phase1_FreeChoice_B_VTA_2_model_anova= modelProportion_anova_VTA
fig5_stats_Phase1_FreeChoice_B_VTA_3_model_post_hoc_t= t_proportion_VTA

#-mdThal
fig5_stats_Phase1_FreeChoice_A_mdThal_0_description= "Figure 5: Lever Choice, Phase 1- Free Choice, Active vs Inactive NP Count, mdThal projections"
fig5_stats_Phase1_FreeChoice_A_mdThal_1_model= model_mdThal
fig5_stats_Phase1_FreeChoice_A_mdThal_2_model_anova= model_anova_mdThal
fig5_stats_Phase1_FreeChoice_A_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig5_stats_Phase1_FreeChoice_B_mdThal_0_description= "Figure 5: Lever Choice, Phase 1- Free Choice, Active NP Proportion, mdThal projections"
fig5_stats_Phase1_FreeChoice_B_mdThal_1_model= modelProportion_mdThal
fig5_stats_Phase1_FreeChoice_B_mdThal_2_model_anova= modelProportion_anova_mdThal
fig5_stats_Phase1_FreeChoice_B_mdThal_3_model_post_hoc_t= t_proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig5_stats_Phase1_FreeChoice_A_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase1_FreeChoice_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase1_FreeChoice_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase1_FreeChoice_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig5C_stats_C_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase1_FreeChoice_B_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase1_FreeChoice_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase1_FreeChoice_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase1_FreeChoice_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(summary(fig5C_stats_C_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig5_stats_Phase1_FreeChoice_A_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase1_FreeChoice_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase1_FreeChoice_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase1_FreeChoice_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase1_FreeChoice_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase1_FreeChoice_B_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase1_FreeChoice_B_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase1_FreeChoice_B_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase1_FreeChoice_B_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase1_FreeChoice_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig5_stats_Phase1_FreeChoice_A_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase1_FreeChoice_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase1_FreeChoice_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase1_FreeChoice_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase1_FreeChoice_A_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console



# __________________________________________________ ####


#%- fig 5 Stats-- _Phase 2-Reversal ####


#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig5.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class)



#%%-- Subset data ##
#Remove missing/invalid observations
#- eliminate duplicate proportion values 
# currently active proportion is session level but df has 2 per session (1 per npType)
# so just remove from one trialType. This way can use same df for multiple models easily
df[df$typeLP=='ActiveLeverPress','probActiveLP']= NaN
df[df$typeLP=='ActiveLeverPress','LicksPerReward']= NaN




# df_Sub_A= df[df$trainPhaseLabel == '1-FreeChoice',]
df_Sub_B= df[df$trainPhaseLabel == '2-FreeChoice-Reversal',]
# df_Sub_C= df[df$trainPhaseLabel == '3-ForcedChoice',]
# df_Sub_D= df[df$trainPhaseLabel == '4-FreeChoice-Test',]


df_Sub_B_VTA= df_Sub_B[df_Sub_B$Projection=='VTA',]

df_Sub_B_mdThal= df_Sub_B[df_Sub_B$Projection=='mdThal',]


#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_B$trainDayThisPhase)
# droplevels(df_Sub_B$trainPhase)


#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_B)
model= lmerTest::lmer('countLP ~ Projection * typeLP * Session + (1|Subject)', data=df_Sub_B)

modelProportion= lmerTest::lmer('probActiveLP ~ Projection * Session + (1|Subject)', data=df_Sub_B)

# modelLicks=  lmerTest::lmer('LicksPerReward ~ Projection * Session + (1|Subject)', data=df_Sub_B)
modelLicks=  lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Projection * Session + (1|Subject)', data=df_Sub_B)



model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)
modelLicks_pooled= model
modelLicks_anova_pooled= anova(modelLicks)


#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countLP ~ typeLP * Session + (1|Subject)', data=df_Sub_B_VTA)
model_anova_VTA<- anova(model_VTA)
#-Proportion
modelProportion_VTA= lmerTest::lmer('probActiveLP ~ Session + (1|Subject)', data=df_Sub_B_VTA)
modelProportion_anova_VTA<- anova(modelProportion_VTA)

#-licks/reward
# modelLicks_VTA= lmerTest::lmer('LicksPerReward ~ Session + (1|Subject)', data=df_Sub_B_VTA)
modelLicks_VTA= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Session + (1|Subject)', data=df_Sub_B_VTA)

modelLicks_anova_VTA<- anova(modelLicks_VTA)

#-- mdThal
#mdThal projection
#-Probability
model_mdThal= lmerTest::lmer('countLP ~ typeLP * Session + (1|Subject)', data=df_Sub_B_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
modelProportion_mdThal= lmerTest::lmer('probActiveLP ~ Session + (1|Subject)', data=df_Sub_B_mdThal)
modelProportion_anova_mdThal<- anova(modelProportion_mdThal)
#-licks/reward
# modelLicks_mdThal= lmerTest::lmer
modelLicks_mdThal= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Session + (1|Subject)', data=df_Sub_B_mdThal)

modelLicks_anova_mdThal<- anova(modelLicks_mdThal)


# # -- Interaction plot
# #- Viz interaction plot & save
# figName= "vp-vta_fig5_stats_A_npCount_Session_pooled_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model_pooled, Session ~ typeLP | Projection )
# 
# # emmip(model_pooled, Projection ~ typeNP | Session )
# 
# 
# dev.off()
# setwd(pathWorking)
# 
# #pooled proportion interaction plot
# figName= "vp-vta_fig5_stats_B_proportion_pooled_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(modelProportion_pooled, Session ~ Projection )
# 
# dev.off()
# setwd(pathWorking)


#- Pairwise T- tests

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeLP | Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

#pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

EMM <- emmeans(modelProportion_pooled, ~ Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_Pooled= test(EMM, null=0.5, adjust='sidak')


#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeLP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_VTA, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_VTA= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_VTA= test(EMM, null=0.5, adjust='sidak')


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeLP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_mdThal, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_mdThal= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_mdThal= test(EMM, null=0.5, adjust='sidak')



#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig5_stats_Phase_2_Reversal_A_Pooled_0_description= "Figure 5: Lever Choice, _Phase 2- Reversal, Active vs Inactive NP Count, pooled projections"
fig5_stats_Phase_2_Reversal_A_Pooled_1_model= model_pooled
fig5_stats_Phase_2_Reversal_A_Pooled_2_model_anova= model_anova_pooled
fig5_stats_Phase_2_Reversal_A_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig5_stats_Phase_2_Reversal_B_Pooled_0_description= "Figure 5: Lever Choice, _Phase 2- Reversal, Active NP Proportion, pooled projections"
fig5_stats_Phase_2_Reversal_B_Pooled_1_model= modelProportion_pooled
fig5_stats_Phase_2_Reversal_B_Pooled_2_model_anova= modelProportion_anova_pooled
fig5_stats_Phase_2_Reversal_B_Pooled_3_model_post_hoc_t= t_proportion_Pooled

#-VTA
fig5_stats_Phase_2_Reversal_A_VTA_0_description= "Figure 5: Lever Choice, _Phase 2- Reversal, Active vs Inactive NP Count, VTA projections"
fig5_stats_Phase_2_Reversal_A_VTA_1_model= model_VTA
fig5_stats_Phase_2_Reversal_A_VTA_2_model_anova= model_anova_VTA
fig5_stats_Phase_2_Reversal_A_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig5_stats_Phase_2_Reversal_B_VTA_0_description= "Figure 5: Lever Choice, _Phase 2- Reversal, Active NP Proportion, VTA projections"
fig5_stats_Phase_2_Reversal_B_VTA_1_model= modelProportion_VTA
fig5_stats_Phase_2_Reversal_B_VTA_2_model_anova= modelProportion_anova_VTA
fig5_stats_Phase_2_Reversal_B_VTA_3_model_post_hoc_t= t_proportion_VTA

#-mdThal
fig5_stats_Phase_2_Reversal_A_mdThal_0_description= "Figure 5: Lever Choice, _Phase 2- Reversal, Active vs Inactive NP Count, mdThal projections"
fig5_stats_Phase_2_Reversal_A_mdThal_1_model= model_mdThal
fig5_stats_Phase_2_Reversal_A_mdThal_2_model_anova= model_anova_mdThal
fig5_stats_Phase_2_Reversal_A_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig5_stats_Phase_2_Reversal_B_mdThal_0_description= "Figure 5: Lever Choice, _Phase 2- Reversal, Active NP Proportion, mdThal projections"
fig5_stats_Phase_2_Reversal_B_mdThal_1_model= modelProportion_mdThal
fig5_stats_Phase_2_Reversal_B_mdThal_2_model_anova= modelProportion_anova_mdThal
fig5_stats_Phase_2_Reversal_B_mdThal_3_model_post_hoc_t= t_proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig5_stats_Phase_2_Reversal_A_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_2_Reversal_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_2_Reversal_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_2_Reversal_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig5C_stats_C_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_2_Reversal_B_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_2_Reversal_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_2_Reversal_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_2_Reversal_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(summary(fig5C_stats_C_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig5_stats_Phase_2_Reversal_A_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_2_Reversal_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_2_Reversal_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_2_Reversal_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_2_Reversal_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_2_Reversal_B_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_2_Reversal_B_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_2_Reversal_B_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_2_Reversal_B_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_2_Reversal_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig5_stats_Phase_2_Reversal_A_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_2_Reversal_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_2_Reversal_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_2_Reversal_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_2_Reversal_A_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_2_Reversal_B_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_2_Reversal_B_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_2_Reversal_B_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_2_Reversal_B_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_2_Reversal_B_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)






# __________________________________________________ ####



#%- fig 5 Stats-- _Phase 3-ForcedChoice ####


#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig5.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class)



#%%-- Subset data ##
#Remove missing/invalid observations
#- eliminate duplicate proportion values 
# currently active proportion is session level but df has 2 per session (1 per npType)
# so just remove from one trialType. This way can use same df for multiple models easily
df[df$typeLP=='ActiveLeverPress','probActiveLP']= NaN
df[df$typeLP=='ActiveLeverPress','LicksPerReward']= NaN



# #- Subset by session type 
# df_Sub_A= df[df$trainPhaseLabel == '1-FreeChoice',]
# df_Sub_B= df[df$trainPhaseLabel == '2-FreeChoice-Reversal',]
df_Sub_C= df[df$trainPhaseLabel == '3-ForcedChoice',]
# df_Sub_D= df[df$trainPhaseLabel == '4-FreeChoice-Test',]





df_Sub_C_VTA= df_Sub_C[df_Sub_C$Projection=='VTA',]

df_Sub_C_mdThal= df_Sub_C[df_Sub_C$Projection=='mdThal',]


#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_C$trainDayThisPhase)
# droplevels(df_Sub_C$trainPhase)


#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_C)
model= lmerTest::lmer('countLP ~ Projection * typeLP * Session + (1|Subject)', data=df_Sub_C)

modelProportion= lmerTest::lmer('probActiveLP ~ Projection * Session + (1|Subject)', data=df_Sub_C)

# modelLicks=  lmerTest::lmer('LicksPerReward ~ Projection * Session + (1|Subject)', data=df_Sub_C)
modelLicks=  lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Projection * Session + (1|Subject)', data=df_Sub_C)

model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)
modelLicks_pooled= model
modelLicks_anova_pooled= anova(modelLicks)


#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countLP ~ typeLP * Session + (1|Subject)', data=df_Sub_C_VTA)
model_anova_VTA<- anova(model_VTA)
#-Proportion
modelProportion_VTA= lmerTest::lmer('probActiveLP ~ Session + (1|Subject)', data=df_Sub_C_VTA)
modelProportion_anova_VTA<- anova(modelProportion_VTA)

#-licks/reward
# modelLicks_VTA= lmerTest::lmer('LicksPerReward ~ Session + (1|Subject)', data=df_Sub_C_VTA)
modelLicks_VTA= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Session + (1|Subject)', data=df_Sub_C_VTA)

modelLicks_anova_VTA<- anova(modelLicks_VTA)

#-- mdThal
#mdThal projection
#-Probability
model_mdThal= lmerTest::lmer('countLP ~ typeLP * Session + (1|Subject)', data=df_Sub_C_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
modelProportion_mdThal= lmerTest::lmer('probActiveLP ~ Session + (1|Subject)', data=df_Sub_C_mdThal)
modelProportion_anova_mdThal<- anova(modelProportion_mdThal)
#-licks/reward
# modelLicks_mdThal= lmerTest::lmer('LicksPerReward ~ Session + (1|Subject)', data=df_Sub_C_mdThal)
modelLicks_mdThal= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Session + (1|Subject)', data=df_Sub_C_mdThal)

modelLicks_anova_mdThal<- anova(modelLicks_mdThal)


# # -- Interaction plot
# #- Viz interaction plot & save
# figName= "vp-vta_fig5_stats_A_npCount_Session_pooled_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model_pooled, Session ~ typeLP | Projection )
# 
# # emmip(model_pooled, Projection ~ typeNP | Session )
# 
# 
# dev.off()
# setwd(pathWorking)
# 
# #pooled proportion interaction plot
# figName= "vp-vta_fig5_stats_B_proportion_pooled_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(modelProportion_pooled, Session ~ Projection )
# 
# dev.off()
# setwd(pathWorking)


#- Pairwise T- tests

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeLP | Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

#pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

EMM <- emmeans(modelProportion_pooled, ~ Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_Pooled= test(EMM, null=0.5, adjust='sidak')


#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeLP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_VTA, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_VTA= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_VTA= test(EMM, null=0.5, adjust='sidak')


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeLP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_mdThal, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_mdThal= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_proportion_mdThal= test(EMM, null=0.5, adjust='sidak')



#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig5_stats_Phase_3_ForcedChoice_A_Pooled_0_description= "Figure 5: Lever Choice, _Phase 3-ForcedChoice, Active vs Inactive NP Count, pooled projections"
fig5_stats_Phase_3_ForcedChoice_A_Pooled_1_model= model_pooled
fig5_stats_Phase_3_ForcedChoice_A_Pooled_2_model_anova= model_anova_pooled
fig5_stats_Phase_3_ForcedChoice_A_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig5_stats_Phase_3_ForcedChoice_B_Pooled_0_description= "Figure 5: Lever Choice, _Phase 3-ForcedChoice, Active NP Proportion, pooled projections"
fig5_stats_Phase_3_ForcedChoice_B_Pooled_1_model= modelProportion_pooled
fig5_stats_Phase_3_ForcedChoice_B_Pooled_2_model_anova= modelProportion_anova_pooled
fig5_stats_Phase_3_ForcedChoice_B_Pooled_3_model_post_hoc_t= t_proportion_Pooled

#-VTA
fig5_stats_Phase_3_ForcedChoice_A_VTA_0_description= "Figure 5: Lever Choice, _Phase 3-ForcedChoice, Active vs Inactive NP Count, VTA projections"
fig5_stats_Phase_3_ForcedChoice_A_VTA_1_model= model_VTA
fig5_stats_Phase_3_ForcedChoice_A_VTA_2_model_anova= model_anova_VTA
fig5_stats_Phase_3_ForcedChoice_A_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig5_stats_Phase_3_ForcedChoice_B_VTA_0_description= "Figure 5: Lever Choice, _Phase 3-ForcedChoice, Active NP Proportion, VTA projections"
fig5_stats_Phase_3_ForcedChoice_B_VTA_1_model= modelProportion_VTA
fig5_stats_Phase_3_ForcedChoice_B_VTA_2_model_anova= modelProportion_anova_VTA
fig5_stats_Phase_3_ForcedChoice_B_VTA_3_model_post_hoc_t= t_proportion_VTA

#-mdThal
fig5_stats_Phase_3_ForcedChoice_A_mdThal_0_description= "Figure 5: Lever Choice, _Phase 3-ForcedChoice, Active vs Inactive NP Count, mdThal projections"
fig5_stats_Phase_3_ForcedChoice_A_mdThal_1_model= model_mdThal
fig5_stats_Phase_3_ForcedChoice_A_mdThal_2_model_anova= model_anova_mdThal
fig5_stats_Phase_3_ForcedChoice_A_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig5_stats_Phase_3_ForcedChoice_B_mdThal_0_description= "Figure 5: Lever Choice, _Phase 3-ForcedChoice, Active NP Proportion, mdThal projections"
fig5_stats_Phase_3_ForcedChoice_B_mdThal_1_model= modelProportion_mdThal
fig5_stats_Phase_3_ForcedChoice_B_mdThal_2_model_anova= modelProportion_anova_mdThal
fig5_stats_Phase_3_ForcedChoice_B_mdThal_3_model_post_hoc_t= t_proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig5_stats_Phase_3_ForcedChoice_A_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_3_ForcedChoice_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_3_ForcedChoice_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_3_ForcedChoice_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig5C_stats_C_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_3_ForcedChoice_B_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_3_ForcedChoice_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_3_ForcedChoice_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_3_ForcedChoice_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(summary(fig5C_stats_C_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig5_stats_Phase_3_ForcedChoice_A_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_3_ForcedChoice_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_3_ForcedChoice_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_3_ForcedChoice_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_3_ForcedChoice_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_3_ForcedChoice_B_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_3_ForcedChoice_B_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_3_ForcedChoice_B_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_3_ForcedChoice_B_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_3_ForcedChoice_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig5_stats_Phase_3_ForcedChoice_A_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_3_ForcedChoice_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_3_ForcedChoice_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_3_ForcedChoice_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_3_ForcedChoice_A_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_3_ForcedChoice_B_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_3_ForcedChoice_B_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_3_ForcedChoice_B_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_3_ForcedChoice_B_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_3_ForcedChoice_B_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)



# __________________________________________________ ####



#%- fig 5 Stats-- _Phase 4- TestFreeChoice ####


#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig5.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class)



#%%-- Subset data ##
#Remove missing/invalid observations
#- eliminate duplicate proportion values 
# currently active proportion is session level but df has 2 per session (1 per npType)
# so just remove from one trialType. This way can use same df for multiple models easily
df[df$typeLP=='ActiveLeverPress','probActiveLP']= NaN
df[df$typeLP=='ActiveLeverPress','LicksPerReward']= NaN



# #- Subset by session type 
# df_Sub_A= df[df$trainPhaseLabel == '1-FreeChoice',]
# # df_Sub_B= df[df$trainPhaseLabel == '2-FreeChoice-Reversal',]
# df_Sub_D= df[df$trainPhaseLabel == '3-ForcedChoice',]
df_Sub_D= df[df$trainPhaseLabel == '4-FreeChoice-Test',]


df_Sub_D_VTA= df_Sub_D[df_Sub_D$Projection=='VTA',]

df_Sub_D_mdThal= df_Sub_D[df_Sub_D$Projection=='mdThal',]


# if we've dropped levels(categories) from the factor(categorical) variable drop accordingly for stats to work out
df_Sub_D$Subject= droplevels(df_Sub_D$Subject)
df_Sub_D_VTA$Subject= droplevels(df_Sub_D_VTA$Subject)
df_Sub_D_mdThal$Subject= droplevels(df_Sub_D_mdThal$Subject)



#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_D)

model= lmerTest::lmer('countLP ~ Projection * typeLP  + (1|Subject)', data=df_Sub_D)

model_anova_pooled<- anova(model)



# getting some warnings here with random intercept so using fixed effect for subject 
# boundary (singular) fit: see ?isSingular
#wont run without mixed effects. just run anova + t tests? or lm()?
# specifically 1 observation of active proportion per subject in this case

# essentially 1 observation per subject == can't use as predictor
# 
# modelProportion= lmerTest::lmer('probActiveLP ~ Projection + (1|Subject)', data=df_Sub_D)
# 
# 
# modelProportion= lmerTest::lmer('probActiveLP ~ Projection * Subject', data=df_Sub_D)
# 
# test= lm('probActiveLP ~ Projection * Subject', data=df_Sub_D)
# anova(test)

modelProportion= lm('probActiveLP ~ Projection', data=df_Sub_D)


# modelLicks=  lmerTest::lmer('LicksPerReward ~ Projection * Session + (1|Subject)', data=df_Sub_D)
modelLicks=  lmerTest::lmer('licksPerRewardTypeLP ~ typeLP* Projection * Session + (1|Subject)', data=df_Sub_D)


model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)
modelLicks_pooled= model
modelLicks_anova_pooled= anova(modelLicks)


#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countLP ~ typeLP  + (1|Subject)', data=df_Sub_D_VTA)
model_anova_VTA<- anova(model_VTA)

#-Proportion
# modelProportion_VTA= lmerTest::lmer('probActiveLP ~ (1|Subject)', data=df_Sub_D_VTA)
# really just need 1 sample t test here
modelProportion_VTA= lm('probActiveLP ~  Subject', data=df_Sub_D_VTA)

# modelProportion_anova_VTA<- anova(modelProportion_VTA)

#-licks/reward
# modelLicks_VTA= lmerTest::lmer('LicksPerReward ~ + (1|Subject)', data=df_Sub_D_VTA)
modelLicks_VTA= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP + (1|Subject)', data=df_Sub_D_VTA)
modelLicks_anova_VTA<- anova(modelLicks_VTA)

#-- mdThal
#mdThal projection
#-Probability
model_mdThal= lmerTest::lmer('countLP ~ typeLP + (1|Subject)', data=df_Sub_D_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
# modelProportion_mdThal= lmerTest::lmer('probActiveLP ~ + (1|Subject)', data=df_Sub_D_mdThal)
modelProportion_mdThal= lm('probActiveLP ~ Subject', data=df_Sub_D_mdThal)

modelProportion_anova_mdThal<- anova(modelProportion_mdThal)
#-licks/reward
# modelLicks_mdThal= lmerTest::lmer('LicksPerReward ~ + (1|Subject)', data=df_Sub_D_mdThal)
modelLicks_mdThal= lmerTest::lmer('licksPerRewardTypeLP ~ typeLP + (1|Subject)', data=df_Sub_D_mdThal)

modelLicks_anova_mdThal<- anova(modelLicks_mdThal)


# # -- Interaction plot
# #- Viz interaction plot & save
# figName= "vp-vta_fig5_stats_A_npCount_Session_pooled_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model_pooled, Session ~ typeLP | Projection )
# 
# # emmip(model_pooled, Projection ~ typeNP | Session )
# 
# 
# dev.off()
# setwd(pathWorking)
# 
# #pooled proportion interaction plot
# figName= "vp-vta_fig5_stats_B_proportion_pooled_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(modelProportion_pooled, Session ~ Projection )
# 
# dev.off()
# setwd(pathWorking)


#- Pairwise T- tests

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeLP | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

#pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

# EMM <- emmeans(modelProportion_pooled, ~ Session | Projection)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
EMM <- emmeans(modelProportion_pooled, ~  Projection) 
t_proportion_Pooled= test(EMM, null=0.5, adjust='sidak')


#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeLP)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise

#-npActiveProportion
# EMM <- emmeans(modelProportion_VTA, ~ Session)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

# tPairwise_proportion_VTA= tPairwise

# # for active proportion, check if each level significantly different from 0.5 (chance)
# EMM <- emmeans(modelProportion_VTA, ~ Session)   # where treat has 2 levels
# t_proportion_VTA= test(EMM, null=0.5, adjust='sidak')


# simple 1 sample t test
# t_proportion_VTA= t.test(df_Sub_D_VTA$probActiveLP, null=0.5, adjust='sidak')

t_proportion_VTA= t.test(df_Sub_D_VTA$probActiveLP, mu=0.5)


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeLP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise

#-npActiveProportion
# EMM <- emmeans(modelProportion_mdThal, ~ Session)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_proportion_mdThal= tPairwise
# 
# # for active proportion, check if each level significantly different from 0.5 (chance)
# t_proportion_mdThal= test(EMM, null=0.5, adjust='sidak')

t_proportion_mdThal= t.test(df_Sub_D_mdThal$probActiveLP, mu=0.5)



#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig5_stats_Phase_4_TestFreeChoice_A_Pooled_0_description= "Figure 5: Lever Choice, _Phase 4- TestFreeChoice, Active vs Inactive NP Count, pooled projections"
fig5_stats_Phase_4_TestFreeChoice_A_Pooled_1_model= model_pooled
fig5_stats_Phase_4_TestFreeChoice_A_Pooled_2_model_anova= model_anova_pooled
fig5_stats_Phase_4_TestFreeChoice_A_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig5_stats_Phase_4_TestFreeChoice_B_Pooled_0_description= "Figure 5: Lever Choice, _Phase 4- TestFreeChoice, Active NP Proportion, pooled projections"
fig5_stats_Phase_4_TestFreeChoice_B_Pooled_1_model= modelProportion_pooled
fig5_stats_Phase_4_TestFreeChoice_B_Pooled_2_model_anova= modelProportion_anova_pooled
fig5_stats_Phase_4_TestFreeChoice_B_Pooled_3_model_post_hoc_t= t_proportion_Pooled

#-VTA
fig5_stats_Phase_4_TestFreeChoice_A_VTA_0_description= "Figure 5: Lever Choice, _Phase 4- TestFreeChoice, Active vs Inactive NP Count, VTA projections"
fig5_stats_Phase_4_TestFreeChoice_A_VTA_1_model= model_VTA
fig5_stats_Phase_4_TestFreeChoice_A_VTA_2_model_anova= model_anova_VTA
fig5_stats_Phase_4_TestFreeChoice_A_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig5_stats_Phase_4_TestFreeChoice_B_VTA_0_description= "Figure 5: Lever Choice, _Phase 4- TestFreeChoice, Active NP Proportion, VTA projections"
fig5_stats_Phase_4_TestFreeChoice_B_VTA_1_model= modelProportion_VTA
fig5_stats_Phase_4_TestFreeChoice_B_VTA_2_model_anova= modelProportion_anova_VTA
fig5_stats_Phase_4_TestFreeChoice_B_VTA_3_model_post_hoc_t= t_proportion_VTA

#-mdThal
fig5_stats_Phase_4_TestFreeChoice_A_mdThal_0_description= "Figure 5: Lever Choice, _Phase 4- TestFreeChoice, Active vs Inactive NP Count, mdThal projections"
fig5_stats_Phase_4_TestFreeChoice_A_mdThal_1_model= model_mdThal
fig5_stats_Phase_4_TestFreeChoice_A_mdThal_2_model_anova= model_anova_mdThal
fig5_stats_Phase_4_TestFreeChoice_A_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig5_stats_Phase_4_TestFreeChoice_B_mdThal_0_description= "Figure 5: Lever Choice, _Phase 4- TestFreeChoice, Active NP Proportion, mdThal projections"
fig5_stats_Phase_4_TestFreeChoice_B_mdThal_1_model= modelProportion_mdThal
fig5_stats_Phase_4_TestFreeChoice_B_mdThal_2_model_anova= modelProportion_anova_mdThal
fig5_stats_Phase_4_TestFreeChoice_B_mdThal_3_model_post_hoc_t= t_proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig5_stats_Phase_4_TestFreeChoice_A_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_4_TestFreeChoice_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_4_TestFreeChoice_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_4_TestFreeChoice_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig5C_stats_C_3_model_post_hoc_pairwise)
print(fig5_stats_Phase_4_TestFreeChoice_A_Pooled_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_4_TestFreeChoice_B_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_4_TestFreeChoice_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_4_TestFreeChoice_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_4_TestFreeChoice_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_4_TestFreeChoice_B_Pooled_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig5_stats_Phase_4_TestFreeChoice_A_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_4_TestFreeChoice_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_4_TestFreeChoice_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_4_TestFreeChoice_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_4_TestFreeChoice_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_4_TestFreeChoice_B_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_4_TestFreeChoice_B_VTA_0_description)
'------------------------------------------------------------------------------'
# print('1)---- LME:')
# print(summary(fig5_stats_Phase_4_TestFreeChoice_B_VTA_1_model))
# '------------------------------------------------------------------------------'
# print('2)---- ANOVA of LME:')
# print(fig5_stats_Phase_4_TestFreeChoice_B_VTA_2_model_anova)
# '------------------------------------------------------------------------------'
# print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
# print(fig5_stats_Phase_4_TestFreeChoice_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
print('3)---- One Sample t test:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_4_TestFreeChoice_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")

'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig5_stats_Phase_4_TestFreeChoice_A_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig5_stats_Phase_4_TestFreeChoice_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig5_stats_Phase_4_TestFreeChoice_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig5_stats_Phase_4_TestFreeChoice_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_4_TestFreeChoice_A_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig5_stats_Phase_4_TestFreeChoice_B_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
# print(fig5_stats_Phase_4_TestFreeChoice_B_mdThal_0_description)
# '------------------------------------------------------------------------------'
# print('1)---- LME:')
# print(summary(fig5_stats_Phase_4_TestFreeChoice_B_mdThal_1_model))
# '------------------------------------------------------------------------------'
# print('2)---- ANOVA of LME:')
# print(fig5_stats_Phase_4_TestFreeChoice_B_mdThal_2_model_anova)
# '------------------------------------------------------------------------------'
# print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
# print(fig5_stats_Phase_4_TestFreeChoice_B_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
print('3)---- One Sample T Test:') # Make sure for posthocs the summary is printed with pval correction
print(fig5_stats_Phase_4_TestFreeChoice_B_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)




# __________________________________________________ ####

#%% END ####




