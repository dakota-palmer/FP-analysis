
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



## -------FIGUre 6 ----------------------------------------------###


## ----- FIGURE 6 --------------------------------------------------------####

#%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig6.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class) 


#%%-- Subset data ## 
#Remove missing/invalid observations 
# df_Sub_A= df
# 
# #- Can only include laserTrial for StimLength >0
# df_Sub_A= df[df$StimLength != 0,]


## %%-- Run LME ##

model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df)


model_anova<- anova(model)

#2023-02-21 all grouped together, projection * cueID interaction


#%%-- Run Follow-up post-hoc tests ####

#- Signifcant interaction term, want to follow-up and estimate main effects

# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig46_stats_A_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model, typeNP ~ Session | trainPhase | Projection)

dev.off()
setwd(pathWorking)

#- Pairwise T- tests
EMM <- emmeans(model, ~ LaserTrial | StimLength | CueID | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now


# Pairwise results- no significant contrasts


#- Pairwise T- tests
EMM <- emmeans(model, ~ trialOutcome)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now


#%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests
fig4C_stats_A_0_description= "Figure 4C: DS opto all"
fig4C_stats_A_1_model= model
fig4C_stats_A_2_model_anova= model_anova
fig4C_stats_A_3_model_post_hoc_pairwise= tPairwise 


#%%-- Save output to File ####
# Fig2D_A
setwd(pathOutput)


sink("vp-vta_fig4C_stats_A_PEvsNoPE_DS.txt")
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
print(fig4C_stats_A_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console

setwd(pathWorking)





#%- Fig 6 Stats A-- OG Side, Acquisition Phase ####


#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig6.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class)

#%% Figure 4D Stats A -- Laser Sessions

#%%-- Subset data ##
#Remove missing/invalid observations
#- eliminate duplicate proportion values 
# currently active proportion is session level but df has 2 per session (1 per npType)
# so just remove from one trialType. This way can use same df for multiple models easily
df[df$typeNP=='InactiveNP','npActiveProportion']= NaN



# #- Subset by session type 
df_Sub_A= df[df$trainPhase == 'ICSS-OG-active-side',]


df_Sub_A_VTA= df_Sub_A[df_Sub_A$Projection=='VTA',]

# df_Sub_VTA_DS= df_Sub_VTA[df_Sub_VTA$CueID=='DS',]

df_Sub_A_mdThal= df_Sub_A[df_Sub_A$Projection=='mdThal',]


#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_A$trainDayThisPhase)
# droplevels(df_Sub_A$trainPhase)


#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_A)
model= lmerTest::lmer('countNP ~ Projection * typeNP * Session + (1|Subject)', data=df_Sub_A)

modelProportion= lmerTest::lmer('npActiveProportion ~ Projection * Session + (1|Subject)', data=df_Sub_A)


model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)

#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countNP ~ typeNP * Session  + (1|Subject)', data=df_Sub_A_VTA)
model_anova_VTA<- anova(model_VTA)
#-Proportion
modelProportion_VTA= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_A_VTA)
modelProportion_anova_VTA<- anova(modelProportion_VTA)

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
figName= "vp-vta_fig6_stats_A_npCount_Session_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model_pooled, Session ~ typeNP | Projection )

# emmip(model_pooled, Projection ~ typeNP | Session )


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








#%- Fig 6 Stats B-- Licks Per Reward ####






#%- Fig 6 Stats C-- Active Lever Proportion ####




