
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

# 
# ## -------FIGUre 6 ----------------------------------------------###
# 
# 
# ## ----- FIGURE 6 --------------------------------------------------------####
# 
# #%%-- Load data from .pkl ####
# 
# pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig6.pkl"
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
# #%%-- Subset data ## 
# #Remove missing/invalid observations 
# # df_Sub_A= df
# # 
# # #- Can only include laserTrial for StimLength >0
# # df_Sub_A= df[df$StimLength != 0,]
# 
# 
# ## %%-- Run LME ##
# 
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df)
# 
# 
# model_anova<- anova(model)
# 
# #2023-02-21 all grouped together, projection * cueID interaction
# 
# 
# #%%-- Run Follow-up post-hoc tests ####
# 
# #- Signifcant interaction term, want to follow-up and estimate main effects
# 
# # -- Interaction plot
# #- Viz interaction plot & save
# figName= "vp-vta_fig46_stats_C_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model, typeNP ~ Session | trainPhase | Projection)
# 
# dev.off()
# setwd(pathWorking)
# 
# #- Pairwise T- tests
# EMM <- emmeans(model, ~ LaserTrial | StimLength | CueID | Projection)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# 
# # Pairwise results- no significant contrasts
# 
# 
# #- Pairwise T- tests
# EMM <- emmeans(model, ~ trialOutcome)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# 
# #%%-- Save output to variables between tests  ####
# # trying to keep code mostly generalizable and just save custom names at end
# # all the results into descriptive variables between tests
# fig4C_stats_C_0_description= "Figure 4C: DS opto all"
# fig4C_stats_C_1_model= model
# fig4C_stats_C_2_model_anova= model_anova
# fig4C_stats_C_3_model_post_hoc_pairwise= tPairwise 
# 
# 
# #%%-- Save output to File ####
# # Fig2D_A
# setwd(pathOutput)
# 
# 
# sink("vp-vta_fig4C_stats_C_PEvsNoPE_DS.txt")
# '------------------------------------------------------------------------------'
# '0)---- Description --: '
# print(fig2D_stats_C_0_description)
# '------------------------------------------------------------------------------'
# print('1)---- LME:')
# print(summary(fig2D_stats_C_1_model))
# '------------------------------------------------------------------------------'
# print('2)---- ANOVA of LME:')
# print(fig2D_stats_C_2_model_anova)
# '------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:')
# print(fig4C_stats_C_3_model_post_hoc_pairwise)
# '---- END ---------------------------------------------------------------------'
# sink()  # returns output to the console
# 
# setwd(pathWorking)
# 


# __________________________________________________ ####


#%- Fig 6 Stats A/B-- OG Side, Acquisition Phase ####

#0%%-- Clear vars between tests ####
# #clear workspace (R environment) # Except paths, Python packages (pandas)
rm(list = setdiff(ls(), c("pathWorking", "pathOutput", "pd")))


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
model_mdThal= lmerTest::lmer('countNP ~ typeNP * Session  + (1|Subject)', data=df_Sub_A_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
modelProportion_mdThal= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_A_mdThal)
modelProportion_anova_mdThal<- anova(modelProportion_mdThal)



# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig6_stats_A_npCount_Session_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model_pooled, Session ~ typeNP | Projection )

# emmip(model_pooled, Projection ~ typeNP | Session )


dev.off()
setwd(pathWorking)

#pooled proportion interaction plot
figName= "vp-vta_fig6_stats_B_proportion_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(modelProportion_pooled, Session ~ Projection )

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

# Pairwise comparisons between Sessions

#-- LIMIT COMPARISONS TO ONLY FINAL SESSION SHOWN

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeNP | Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

  #pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

EMM <- emmeans(modelProportion_pooled, ~ Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_Pooled= test(EMM, null=0.5, adjust='sidak')




#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeNP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise
  
#-npActiveProportion
EMM <- emmeans(modelProportion_VTA, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_VTA= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_VTA= test(EMM, null=0.5, adjust='sidak')



#vta followup tests reveal significant differences in npCount by npType only in Sessions 4, 5
# also sig difference only between ses 1-5, 1-3

# for active proportion, check if each level significantly different from 0.5 (chance)
test2= test(EMM, null=0.5, adjust='sidak')

#example test() with emmeans here- https://cran.r-project.org/web/packages/emmeans/vignettes/confidence-intervals.html
# example of how to do 1 sample t test at each level with emmmeans 

test2= test(EMM, null=0.5, adjust='sidak')


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeNP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_mdThal, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_mdThal= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_mdThal= test(EMM, null=0.5, adjust='sidak')



  #followup tests for mdThal reveal no sig diffs by session


#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig6_stats_Acquisition_A_Pooled_0_description= "Figure 6: ICSS, OG Active Side, Active vs Inactive NP Count, pooled projections"
fig6_stats_Acquisition_A_Pooled_1_model= model_pooled
fig6_stats_Acquisition_A_Pooled_2_model_anova= model_anova_pooled
fig6_stats_Acquisition_A_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig6_stats_Acquisition_B_Pooled_0_description= "Figure 6: ICSS, OG Active Side, Active NP Proportion, pooled projections"
fig6_stats_Acquisition_B_Pooled_1_model= modelProportion_pooled
fig6_stats_Acquisition_B_Pooled_2_model_anova= modelProportion_anova_pooled
fig6_stats_Acquisition_B_Pooled_3_model_post_hoc_t= t_Proportion_Pooled

#-VTA
fig6_stats_Acquisition_A_VTA_0_description= "Figure 6: ICSS, OG Active Side, Active vs Inactive NP Count, VTA projections"
fig6_stats_Acquisition_A_VTA_1_model= model_VTA
fig6_stats_Acquisition_A_VTA_2_model_anova= model_anova_VTA
fig6_stats_Acquisition_A_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig6_stats_Acquisition_B_VTA_0_description= "Figure 6: ICSS, OG Active Side, Active NP Proportion, VTA projections"
fig6_stats_Acquisition_B_VTA_1_model= modelProportion_VTA
fig6_stats_Acquisition_B_VTA_2_model_anova= modelProportion_anova_VTA
fig6_stats_Acquisition_B_VTA_3_model_post_hoc_t= t_Proportion_VTA

#-mdThal
fig6_stats_Acquisition_A_mdThal_0_description= "Figure 6: ICSS, OG Active Side, Active vs Inactive NP Count, mdThal projections"
fig6_stats_Acquisition_A_mdThal_1_model= model_mdThal
fig6_stats_Acquisition_A_mdThal_2_model_anova= model_anova_mdThal
fig6_stats_Acquisition_A_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig6_stats_Acquisition_B_mdThal_0_description= "Figure 6: ICSS, OG Active Side, Active NP Proportion, mdThal projections"
fig6_stats_Acquisition_B_mdThal_1_model= modelProportion_mdThal
fig6_stats_Acquisition_B_mdThal_2_model_anova= modelProportion_anova_mdThal
fig6_stats_Acquisition_B_mdThal_3_model_post_hoc_t= t_Proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig6_stats_Acquisition_A_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig6C_stats_C_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Acquisition_B_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(summary(fig6C_stats_C_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig6_stats_Acquisition_A_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(summary(fig6_stats_Acquisition_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Acquisition_B_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_B_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_B_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_B_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig6_stats_Acquisition_A_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_A_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Acquisition_B_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_B_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_B_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_B_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_B_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)






# __________________________________________________ ####


#%- Fig 6 Stats A/B-- Final Session, OG Side, Acquisition Phase ####


#0%%-- Clear vars between tests ####
# #clear workspace (R environment) # Except paths, Python packages (pandas)
rm(list = setdiff(ls(), c("pathWorking", "pathOutput", "pd")))


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

# -- Subset to final session ONLY
df_Sub_A_finalSes= df_Sub_A[df_Sub_A$Session==5,]


df_Sub_A_finalSes_VTA= df_Sub_A_finalSes[df_Sub_A_finalSes$Projection=='VTA',]

df_Sub_A_finalSes_mdThal= df_Sub_A_finalSes[df_Sub_A_finalSes$Projection=='mdThal',]




#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_A_finalSes$trainDayThisPhase)
# droplevels(df_Sub_A_finalSes$trainPhase)


#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_A_finalSes)
model= lmerTest::lmer('countNP ~ Projection * typeNP  + (1|Subject)', data=df_Sub_A_finalSes)

# # for proportion only 1 observation per subj so cant be mixed effect, and cant run lmerTest lmer() without mixed effects so just lm
# modelProportion= lmerTest::lmer('npActiveProportion ~ Projection + (1|Subject)', data=df_Sub_A_finalSes)
# really just need 1 sample t test here
modelProportion= lm('npActiveProportion ~ Projection', data=df_Sub_A_finalSes)

model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)


#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countNP ~ typeNP  + (1|Subject)', data=df_Sub_A_finalSes_VTA)
model_anova_VTA<- anova(model_VTA)
#-Proportion
# modelProportion_VTA= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_A_finalSes_VTA)
modelProportion_VTA= lm('npActiveProportion ~ Subject', data=df_Sub_A_finalSes_VTA)
modelProportion_anova_VTA<- anova(modelProportion_VTA)

#-- mdThal
#mdThal projection
#-Probability
model_mdThal= lmerTest::lmer('countNP ~ typeNP  + (1|Subject)', data=df_Sub_A_finalSes_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
# modelProportion_mdThal= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_A_finalSes_mdThal)
modelProportion_mdThal= lm('npActiveProportion ~ Subject', data=df_Sub_A_finalSes_mdThal)

modelProportion_anova_mdThal<- anova(modelProportion_mdThal)



# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig6_stats_A_npCount_finalSes_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model_pooled, ~ typeNP | Projection )

# emmip(model_pooled, Projection ~ typeNP | Session )


dev.off()
setwd(pathWorking)

#pooled proportion interaction plot
figName= "vp-vta_fig6_stats_B_proportion_finalSes_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(modelProportion_pooled, ~ Projection )

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

# Pairwise comparisons between Sessions

#-- LIMIT COMPARISONS TO ONLY FINAL SESSION SHOWN

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeNP | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

#pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

EMM <- emmeans(modelProportion_pooled, ~ Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_Pooled= test(EMM, null=0.5, adjust='sidak')

#- compare between projections
EMM <- emmeans(model_pooled, ~ Projection| typeNP)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwiseProjection_Pooled= tPairwise



#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeNP )   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise

# #-npActiveProportion
# EMM <- emmeans(modelProportion_VTA, ~ Subject)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_proportion_VTA= tPairwise
# 
# # for active proportion, check if each level significantly different from 0.5 (chance)
# t_Proportion_VTA= test(EMM, null=0.5, adjust='sidak')

# #-npActiveProportion
# just need 1 sample t test
t_Proportion_VTA= t.test(df_Sub_A_finalSes_VTA$npActiveProportion, mu=0.5)


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeNP)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise
# 
# #-npActiveProportion
# EMM <- emmeans(modelProportion_mdThal,)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_proportion_mdThal= tPairwise
# 
# # for active proportion, check if each level significantly different from 0.5 (chance)
# t_Proportion_mdThal= test(EMM, null=0.5, adjust='sidak')

# #-npActiveProportion
# just need 1 sample t test
t_Proportion_mdThal= t.test(df_Sub_A_finalSes_mdThal$npActiveProportion, mu=0.5)



#followup tests for mdThal reveal no sig diffs by session


#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig6_stats_Acquisition_finalSes_A_Pooled_0_description= "Figure 6: ICSS, OG Active Side, Active vs Inactive NP Count, pooled projections"
fig6_stats_Acquisition_finalSes_A_Pooled_1_model= model_pooled
fig6_stats_Acquisition_finalSes_A_Pooled_2_model_anova= model_anova_pooled
fig6_stats_Acquisition_finalSes_A_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig6_stats_Acquisition_finalSes_B_Pooled_0_description= "Figure 6: ICSS, OG Active Side, Active NP Proportion, pooled projections"
fig6_stats_Acquisition_finalSes_B_Pooled_1_model= modelProportion_pooled
fig6_stats_Acquisition_finalSes_B_Pooled_2_model_anova= modelProportion_anova_pooled
fig6_stats_Acquisition_finalSes_B_Pooled_3_model_post_hoc_t= t_Proportion_Pooled

#-VTA
fig6_stats_Acquisition_finalSes_A_VTA_0_description= "Figure 6: ICSS, OG Active Side, Active vs Inactive NP Count, VTA projections"
fig6_stats_Acquisition_finalSes_A_VTA_1_model= model_VTA
fig6_stats_Acquisition_finalSes_A_VTA_2_model_anova= model_anova_VTA
fig6_stats_Acquisition_finalSes_A_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig6_stats_Acquisition_finalSes_B_VTA_0_description= "Figure 6: ICSS, OG Active Side, Active NP Proportion, VTA projections"
fig6_stats_Acquisition_finalSes_B_VTA_1_model= modelProportion_VTA
fig6_stats_Acquisition_finalSes_B_VTA_2_model_anova= modelProportion_anova_VTA
fig6_stats_Acquisition_finalSes_B_VTA_3_model_post_hoc_t= t_Proportion_VTA 

#-mdThal
fig6_stats_Acquisition_finalSes_A_mdThal_0_description= "Figure 6: ICSS, OG Active Side, Active vs Inactive NP Count, mdThal projections"
fig6_stats_Acquisition_finalSes_A_mdThal_1_model= model_mdThal
fig6_stats_Acquisition_finalSes_A_mdThal_2_model_anova= model_anova_mdThal
fig6_stats_Acquisition_finalSes_A_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig6_stats_Acquisition_finalSes_B_mdThal_0_description= "Figure 6: ICSS, OG Active Side, Active NP Proportion, mdThal projections"
fig6_stats_Acquisition_finalSes_B_mdThal_1_model= modelProportion_mdThal
fig6_stats_Acquisition_finalSes_B_mdThal_2_model_anova= modelProportion_anova_mdThal
fig6_stats_Acquisition_finalSes_B_mdThal_3_model_post_hoc_t= t_Proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig6_stats_Acquisition_finalSes_A_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_finalSes_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_finalSes_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_finalSes_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_finalSes_A_Pooled_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Acquisition_finalSes_B_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_finalSes_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_finalSes_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_finalSes_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_finalSes_B_Pooled_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig6_stats_Acquisition_finalSes_A_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_finalSes_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_finalSes_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_finalSes_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(summary(fig6_stats_Acquisition_finalSes_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Acquisition_finalSes_B_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_finalSes_B_VTA_0_description)
'------------------------------------------------------------------------------'
# print('1)---- LME:')
# print(summary(fig6_stats_Acquisition_finalSes_B_VTA_1_model))
# '------------------------------------------------------------------------------'
# print('2)---- ANOVA of LME:')
# print(fig6_stats_Acquisition_finalSes_B_VTA_2_model_anova)
# '------------------------------------------------------------------------------'
print('3)---- t test:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_finalSes_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig6_stats_Acquisition_finalSes_A_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_finalSes_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Acquisition_finalSes_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Acquisition_finalSes_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_finalSes_A_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Acquisition_finalSes_B_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Acquisition_finalSes_B_mdThal_0_description)
'------------------------------------------------------------------------------'
# print('1)---- LME:')
# print(summary(fig6_stats_Acquisition_finalSes_B_mdThal_1_model))
# '------------------------------------------------------------------------------'
# print('2)---- ANOVA of LME:')
# print(fig6_stats_Acquisition_finalSes_B_mdThal_2_model_anova)
# '------------------------------------------------------------------------------'
print('3)---- t test:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Acquisition_finalSes_B_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)






# __________________________________________________ ####

#%- Fig 6 Stats C/D-- Reversal ####


#0%%-- Clear vars between tests ####
# #clear workspace (R environment) # Except paths, Python packages (pandas)
rm(list = setdiff(ls(), c("pathWorking", "pathOutput", "pd")))


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
df_Sub_B= df[df$trainPhase == 'ICSS-Reversed-active-side',]


df_Sub_B_VTA= df_Sub_B[df_Sub_B$Projection=='VTA',]

df_Sub_B_mdThal= df_Sub_B[df_Sub_B$Projection=='mdThal',]


#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_B$trainDayThisPhase)
# droplevels(df_Sub_B$trainPhase)


#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_B)
model= lmerTest::lmer('countNP ~ Projection * typeNP * Session + (1|Subject)', data=df_Sub_B)

modelProportion= lmerTest::lmer('npActiveProportion ~ Projection * Session + (1|Subject)', data=df_Sub_B)

model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)


#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countNP ~ typeNP * Session  + (1|Subject)', data=df_Sub_B_VTA)
model_anova_VTA<- anova(model_VTA)
#-Proportion
modelProportion_VTA= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_B_VTA)
modelProportion_anova_VTA<- anova(modelProportion_VTA)

#-- mdThal
#mdThal projection
#-Probability
model_mdThal= lmerTest::lmer('countNP ~ typeNP * Session  + (1|Subject)', data=df_Sub_B_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
modelProportion_mdThal= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_B_mdThal)
modelProportion_anova_mdThal<- anova(modelProportion_mdThal)



# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig6_stats_C_npCount_Session_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model_pooled, Session ~ typeNP | Projection )

# emmip(model_pooled, Projection ~ typeNP | Session )


dev.off()
setwd(pathWorking)

#pooled proportion interaction plot
figName= "vp-vta_fig6_stats_C_proportion_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(modelProportion_pooled, Session ~ Projection )

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

# Pairwise comparisons between Sessions

# #-- Pairwise comparisons (t test) between TrialOutcome
# #- Viz interaction plot & save
# - interaction plots should be same as above

# figName= "vp-vta_fig4CD_stats_D_interactionPlot.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model_VTA, LaserTrial ~ StimLength | CueID )
# 
# dev.off()
# setwd(pathWorking)

#- Pairwise T- tests

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeNP | Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

#pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

EMM <- emmeans(modelProportion_pooled, ~ Session | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_Pooled= test(EMM, null=0.5, adjust='sidak')


#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeNP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_VTA, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_VTA= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_VTA= test(EMM, null=0.5, adjust='sidak')



#vta followup tests reveal significant differences in npCount by npType only in Sessions 4, 5
# also sig difference only between ses 1-5, 1-3

# for active proportion, check if each level significantly different from 0.5 (chance)
test2= test(EMM, null=0.5, adjust='sidak')

#example test() with emmeans here- https://cran.r-project.org/web/packages/emmeans/vignettes/confidence-intervals.html
# example of how to do 1 sample t test at each level with emmmeans 

test2= test(EMM, null=0.5, adjust='sidak')


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeNP | Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise

#-npActiveProportion
EMM <- emmeans(modelProportion_mdThal, ~ Session)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_mdThal= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_mdThal= test(EMM, null=0.5, adjust='sidak')



#followup tests for mdThal reveal no sig diffs by session


#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig6_stats_Reversal_C_Pooled_0_description= "Figure 6: ICSS, Reversal Active Side, Active vs Inactive NP Count, pooled projections"
fig6_stats_Reversal_C_Pooled_1_model= model_pooled
fig6_stats_Reversal_C_Pooled_2_model_anova= model_anova_pooled
fig6_stats_Reversal_C_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig6_stats_Reversal_D_Pooled_0_description= "Figure 6: ICSS, Reversal Active Side, Active NP Proportion, pooled projections"
fig6_stats_Reversal_D_Pooled_1_model= modelProportion_pooled
fig6_stats_Reversal_D_Pooled_2_model_anova= modelProportion_anova_pooled
fig6_stats_Reversal_D_Pooled_3_model_post_hoc_t= t_Proportion_Pooled

#-VTA
fig6_stats_Reversal_C_VTA_0_description= "Figure 6: ICSS, Reversal Active Side, Active vs Inactive NP Count, VTA projections"
fig6_stats_Reversal_C_VTA_1_model= model_VTA
fig6_stats_Reversal_C_VTA_2_model_anova= model_anova_VTA
fig6_stats_Reversal_C_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig6_stats_Reversal_D_VTA_0_description= "Figure 6: ICSS, Reversal Active Side, Active NP Proportion, VTA projections"
fig6_stats_Reversal_D_VTA_1_model= modelProportion_VTA
fig6_stats_Reversal_D_VTA_2_model_anova= modelProportion_anova_VTA
fig6_stats_Reversal_D_VTA_3_model_post_hoc_t= t_Proportion_VTA

#-mdThal
fig6_stats_Reversal_C_mdThal_0_description= "Figure 6: ICSS, Reversal Active Side, Active vs Inactive NP Count, mdThal projections"
fig6_stats_Reversal_C_mdThal_1_model= model_mdThal
fig6_stats_Reversal_C_mdThal_2_model_anova= model_anova_mdThal
fig6_stats_Reversal_C_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig6_stats_Reversal_D_mdThal_0_description= "Figure 6: ICSS, Reversal Active Side, Active NP Proportion, mdThal projections"
fig6_stats_Reversal_D_mdThal_1_model= modelProportion_mdThal
fig6_stats_Reversal_D_mdThal_2_model_anova= modelProportion_anova_mdThal
fig6_stats_Reversal_D_mdThal_3_model_post_hoc_t= t_Proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig6_stats_Reversal_C_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_C_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_C_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_C_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(fig6C_stats_C_3_model_post_hoc_pairwise)
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Reversal_D_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_D_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_D_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_D_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
# print(summary(fig6C_stats_C_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig6_stats_Reversal_C_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_C_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_C_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_C_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(summary(fig6_stats_Reversal_C_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Reversal_D_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_D_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_D_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_D_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_D_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig6_stats_Reversal_C_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_C_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_C_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_C_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_C_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Reversal_D_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_D_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_D_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_D_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t tests:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_D_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)



# __________________________________________________ ####

#%- Fig 6 Stats C/D-- Final Session, Reversed Side, Reversal Phase ####

#0%%-- Clear vars between tests ####
# #clear workspace (R environment) # Except paths, Python packages (pandas)
rm(list = setdiff(ls(), c("pathWorking", "pathOutput", "pd")))

#1%%-- Load data from .pkl ####

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig6.pkl"

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
df[df$typeNP=='InactiveNP','npActiveProportion']= NaN


# #- Subset by session type 
df_Sub_B= df[df$trainPhase == 'ICSS-Reversed-active-side',]

# -- Subset to final session ONLY
df_Sub_B_finalSes= df_Sub_B[df_Sub_B$Session==8,]


df_Sub_B_finalSes_VTA= df_Sub_B_finalSes[df_Sub_B_finalSes$Projection=='VTA',]

df_Sub_B_finalSes_mdThal= df_Sub_B_finalSes[df_Sub_B_finalSes$Projection=='mdThal',]

#-- Report mean+/- SEM active lever presses 

#define standard error of mean function
std.error <- function(x) sd(x)/sqrt(length(x))

test_VTA= df_Sub_B_finalSes_VTA[(df_Sub_B_finalSes_VTA$typeNP== 'ActiveNP'),'countNP']

mean(test_VTA)
std.error(test_VTA)

test_mdThal=df_Sub_B_finalSes_mdThal[(df_Sub_B_finalSes_mdThal$typeNP== 'ActiveNP'),'countNP']

mean(test_mdThal)
std.error(test_mdThal)


#since we've dropped levels(categories) from the factor(categorical) variable trainDayThisPhase, drop accordingly for stats to work out
# droplevels(df_Sub_B_finalSes$trainDayThisPhase)
# droplevels(df_Sub_B_finalSes$trainPhase)


#2%%-- Run LME ####

#-- Pooled
# model= lmerTest::lmer('countNP ~ Projection * typeNP * Session *  trainPhase + (1|Subject)', data=df_Sub_B_finalSes)
model= lmerTest::lmer('countNP ~ Projection * typeNP  + (1|Subject)', data=df_Sub_B_finalSes)

# # for proportion only 1 observation per subj so cant be mixed effect, and cant run lmerTest lmer() without mixed effects so just lm
# modelProportion= lmerTest::lmer('npActiveProportion ~ Projection + (1|Subject)', data=df_Sub_B_finalSes)
# really just need 1 sample t test here
modelProportion= lm('npActiveProportion ~ Projection', data=df_Sub_B_finalSes)

model_pooled= model
model_anova_pooled<- anova(model)
modelProportion_pooled= modelProportion
modelProportion_anova_pooled= anova(modelProportion)


#-- VTA
#VTA projection
#-Count
model_VTA= lmerTest::lmer('countNP ~ typeNP  + (1|Subject)', data=df_Sub_B_finalSes_VTA)
model_anova_VTA<- anova(model_VTA)
#-Proportion
# modelProportion_VTA= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_B_finalSes_VTA)
modelProportion_VTA= lm('npActiveProportion ~ Subject', data=df_Sub_B_finalSes_VTA)
modelProportion_anova_VTA<- anova(modelProportion_VTA)

#-- mdThal
#mdThal projection
#-Probability
model_mdThal= lmerTest::lmer('countNP ~ typeNP  + (1|Subject)', data=df_Sub_B_finalSes_mdThal)
model_anova_mdThal<- anova(model_mdThal)
#-Proportion
# modelProportion_mdThal= lmerTest::lmer('npActiveProportion ~ Session + (1|Subject)', data=df_Sub_B_finalSes_mdThal)
modelProportion_mdThal= lm('npActiveProportion ~ Subject', data=df_Sub_B_finalSes_mdThal)

modelProportion_anova_mdThal<- anova(modelProportion_mdThal)



# -- Interaction plot
#- Viz interaction plot & save
figName= "vp-vta_fig6_stats_A_npCount_finalSes_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model_pooled, ~ typeNP | Projection )

# emmip(model_pooled, Projection ~ typeNP | Session )


dev.off()
setwd(pathWorking)

#pooled proportion interaction plot
figName= "vp-vta_fig6_stats_B_proportion_finalSes_pooled_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(modelProportion_pooled, ~ Projection )

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

# Pairwise comparisons between Sessions

#-- LIMIT COMPARISONS TO ONLY FINAL SESSION SHOWN

#-- Pooled
EMM <- emmeans(model_pooled, ~ typeNP | Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_Pooled= tPairwise

#pooled followup tests reveal significant differences in npCount by npType in VTA session 3,4,5

EMM <- emmeans(modelProportion_pooled, ~ Projection)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_proportion_Pooled= tPairwise

# for active proportion, check if each level significantly different from 0.5 (chance)
t_Proportion_Pooled= test(EMM, null=0.5, adjust='sidak')

#- compare between projections
EMM <- emmeans(model_pooled, ~ Projection| typeNP)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwiseProjection_Pooled= tPairwise



#-- VTA
#-npCount
EMM <- emmeans(model_VTA, ~ typeNP )   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_VTA= tPairwise

# #-npActiveProportion
# EMM <- emmeans(modelProportion_VTA, ~ Subject)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_proportion_VTA= tPairwise
# 
# # for active proportion, check if each level significantly different from 0.5 (chance)
# t_Proportion_VTA= test(EMM, null=0.5, adjust='sidak')

# #-npActiveProportion
# just need 1 sample t test
t_Proportion_VTA= t.test(df_Sub_B_finalSes_VTA$npActiveProportion, mu=0.5)


#-- mdThal

#-npCount
EMM <- emmeans(model_mdThal, ~ typeNP)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now

tPairwise_mdThal= tPairwise
# 
# #-npActiveProportion
# EMM <- emmeans(modelProportion_mdThal,)   # where treat has 2 levels
# tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now
# 
# tPairwise_proportion_mdThal= tPairwise
# 
# # for active proportion, check if each level significantly different from 0.5 (chance)
# t_Proportion_mdThal= test(EMM, null=0.5, adjust='sidak')

# #-npActiveProportion
# just need 1 sample t test
t_Proportion_mdThal= t.test(df_Sub_B_finalSes_mdThal$npActiveProportion, mu=0.5)



#followup tests for mdThal reveal no sig diffs by session


#4%%-- Save output to variables between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#-pooled
fig6_stats_Reversal_finalSes_A_Pooled_0_description= "Figure 6: ICSS, Reversal Final Session, Active vs Inactive NP Count, pooled projections"
fig6_stats_Reversal_finalSes_A_Pooled_1_model= model_pooled
fig6_stats_Reversal_finalSes_A_Pooled_2_model_anova= model_anova_pooled
fig6_stats_Reversal_finalSes_A_Pooled_3_model_post_hoc_pairwise= tPairwise_Pooled

fig6_stats_Reversal_finalSes_B_Pooled_0_description= "Figure 6: ICSS, Reversal Final Session, Active NP Proportion, pooled projections"
fig6_stats_Reversal_finalSes_B_Pooled_1_model= modelProportion_pooled
fig6_stats_Reversal_finalSes_B_Pooled_2_model_anova= modelProportion_anova_pooled
fig6_stats_Reversal_finalSes_B_Pooled_3_model_post_hoc_t= t_Proportion_Pooled

#-VTA
fig6_stats_Reversal_finalSes_A_VTA_0_description= "Figure 6: ICSS, Reversal Final Session, Active vs Inactive NP Count, VTA projections"
fig6_stats_Reversal_finalSes_A_VTA_1_model= model_VTA
fig6_stats_Reversal_finalSes_A_VTA_2_model_anova= model_anova_VTA
fig6_stats_Reversal_finalSes_A_VTA_3_model_post_hoc_pairwise= tPairwise_VTA

fig6_stats_Reversal_finalSes_B_VTA_0_description= "Figure 6: ICSS, Reversal Final Session, Active NP Proportion, VTA projections"
fig6_stats_Reversal_finalSes_B_VTA_1_model= modelProportion_VTA
fig6_stats_Reversal_finalSes_B_VTA_2_model_anova= modelProportion_anova_VTA
fig6_stats_Reversal_finalSes_B_VTA_3_model_post_hoc_t= t_Proportion_VTA 

#-mdThal
fig6_stats_Reversal_finalSes_A_mdThal_0_description= "Figure 6: ICSS, Reversal Final Session, Active vs Inactive NP Count, mdThal projections"
fig6_stats_Reversal_finalSes_A_mdThal_1_model= model_mdThal
fig6_stats_Reversal_finalSes_A_mdThal_2_model_anova= model_anova_mdThal
fig6_stats_Reversal_finalSes_A_mdThal_3_model_post_hoc_pairwise= tPairwise_mdThal

fig6_stats_Reversal_finalSes_B_mdThal_0_description= "Figure 6: ICSS, Reversal Final Session, Active NP Proportion, mdThal projections"
fig6_stats_Reversal_finalSes_B_mdThal_1_model= modelProportion_mdThal
fig6_stats_Reversal_finalSes_B_mdThal_2_model_anova= modelProportion_anova_mdThal
fig6_stats_Reversal_finalSes_B_mdThal_3_model_post_hoc_t= t_Proportion_mdThal



#5%% -- Figure 6 Save output ####

#- move to output directory prior to saving
setwd(pathOutput)

#------Pooled

sink("vp-vta_fig6_stats_Reversal_finalSes_A_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_finalSes_A_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_finalSes_A_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_finalSes_A_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
# print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_finalSes_A_Pooled_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Reversal_finalSes_B_Pooled.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_finalSes_B_Pooled_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_finalSes_B_Pooled_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_finalSes_B_Pooled_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc t test:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_finalSes_B_Pooled_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ VTA

sink("vp-vta_fig6_stats_Reversal_finalSes_A_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_finalSes_A_VTA_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_finalSes_A_VTA_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_finalSes_A_VTA_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(summary(fig6_stats_Reversal_finalSes_A_VTA_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak"))
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Reversal_finalSes_B_VTA.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_finalSes_B_VTA_0_description)
'------------------------------------------------------------------------------'
# print('1)---- LME:')
# print(summary(fig6_stats_Reversal_finalSes_B_VTA_1_model))
# '------------------------------------------------------------------------------'
# print('2)---- ANOVA of LME:')
# print(fig6_stats_Reversal_finalSes_B_VTA_2_model_anova)
# '------------------------------------------------------------------------------'
print('3)----  t test:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_finalSes_B_VTA_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#------ mdThal

sink("vp-vta_fig6_stats_Reversal_finalSes_A_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_finalSes_A_mdThal_0_description)
'------------------------------------------------------------------------------'
print('1)---- LME:')
print(summary(fig6_stats_Reversal_finalSes_A_mdThal_1_model))
'------------------------------------------------------------------------------'
print('2)---- ANOVA of LME:')
print(fig6_stats_Reversal_finalSes_A_mdThal_2_model_anova)
'------------------------------------------------------------------------------'
print('3)---- Posthoc pairwise:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_finalSes_A_mdThal_3_model_post_hoc_pairwise, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


sink("vp-vta_fig6_stats_Reversal_finalSes_B_mdThal.txt")
'------------------------------------------------------------------------------'
'0)---- Description --: '
print(fig6_stats_Reversal_finalSes_B_mdThal_0_description)
'------------------------------------------------------------------------------'
# print('1)---- LME:')
# print(summary(fig6_stats_Reversal_finalSes_B_mdThal_1_model))
# '------------------------------------------------------------------------------'
# print('2)---- ANOVA of LME:')
# print(fig6_stats_Reversal_finalSes_B_mdThal_2_model_anova)
# '------------------------------------------------------------------------------'
print('3)---- t test:') # Make sure for posthocs the summary is printed with pval correction
print(fig6_stats_Reversal_finalSes_B_mdThal_3_model_post_hoc_t, by = NULL, adjust = "sidak")
'---- END ---------------------------------------------------------------------'
sink()  # returns output to the console


#- return to working directory after saving
setwd(pathWorking)






# __________________________________________________ ####




