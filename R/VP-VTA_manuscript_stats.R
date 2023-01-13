######################################################
## script for importing .pkls from Python
##
## 2021-10-11
####################################################

###### enter python env
# Sys.setenv(RETICULATE_PYTHON = "C:/Users/Dakota/anaconda3/envs/r-env")
Sys.setenv(RETICULATE_PYTHON = "C:/Users/Dakota/anaconda3/envs/spyder-env-seaborn-update")
# Sys.setenv(RETICULATE_PYTHON = "C:/Users/Dakota/anaconda3/envs/r-env-from-spyder-env")

#%%-- Import dependencies ####
library(lme4)
library(reticulate)

#%% -- Set Paths ####

# make working directory to source file location! (up top session -> set working directory -> to source file location)
# https://statisticsglobe.com/set-working-directory-to-source-file-location-automatically-in-rstudio


pathWorking= getwd()

pathOutput= paste(pathWorking,'/_output', sep="")
#get rid of space introduced by paste()
gsub(" ", "", pathOutput)




#-Note: To read .pickles, pandas version in R environment has to match pandas version of .pkl created!

#%% --- FIGURE 2B STATS -------------------------------------------- #### 

#%% Load data from .pkl ####

pd <- import("pandas")

pathData <- "C:\\Users\\Dakota\\Documents\\GitHub\\FP-analysis\\python\\_output\\fig2b.pkl"

df <- pd$read_pickle(pathData)


###### summarize data
summary(df)

#verify dtypes imported properly
sapply(df, class) 

#%% Figure 2B Stats 1 -- Compare DS vs NS AUC on special sessions with NS (stage >5)--####

#%%-- Subset data ## 
#Remove missing/invalid observations 
#-can only do stat comparison for DS vs NS in stages/sessions where NS auc is present
#so subset to stages >=5

#would need to convert to int and back to categorical for math comparison <5, so just exclude =='1'
df_Sub_1= df[df$stage!="1",]


#%%-- Run LME ##

# formula= 'periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)'
# Don't use dyanmic formula name here. It won't show in the .summary()!
# 
# model= lmer(formula, data=df)

model= lmer('periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)', data=df_Sub_1)

print(model)

print(summary(model))



#AS example - used lmerTest too

model_anova<- anova(model)


#lmerTest may give more information when anova is called on lme (vs lmer4)
library(lmerTest)

model_lmerTest= lmerTest::lmer('periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)', data=df_Sub_1)


model_anova_lmerTest<- anova(model)


#%%-- Run Follow-up post-hoc tests
# https://stats.stackexchange.com/questions/187996/interaction-term-in-a-linear-mixed-effect-model-in-r
# https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html
# https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html

#- Signifcant interaction term, want to follow-up and estimate main effects

#emmeans package useful for post-hoc
library(emmeans)

# contrast(model) #error

#- Viz interaction plot
emmip(model_lmerTest, trialType ~ sesSpecialLabel)


#test contrast?
# con= contrast(emms, interaction = "pairwise")


#simple posthoc comparison: Comparison of trialType separately for each sesSpecialLabel
t= emmeans(model_lmerTest, pairwise ~ trialType | sesSpecialLabel)

summary(t)

# pairwise comparisons with emmeans
# emms<- emmeans(model_lmerTest, pairwise ~ trialType : sesSpecialLabel) #this was all interaction combos, should use |

emms<- emmeans(model_lmerTest, pairwise ~ trialType | sesSpecialLabel) 

#what's the difference between calling emms and calling pairs(emms) ?
#- summary(emms) gives emmeans for each, which I think I want. Along with the pairwise contrast pvalues

# PAIRS here is giving same result as emms$contrasts

# https://cran.r-project.org/web/packages/emmeans/vignettes/FAQs.html#noadjust
# emmeans() completely ignores my P-value adjustments
# This happens when there are only two means (or only two in each by group). Thus there is only one comparison. When there is only one thing to test, there is no multiplicity issue, and hence no multiplicity adjustment to the P values.

pw= pairs(emms, adjust= 'sidak')

# no difference here at all
pwDefault= pairs(emms)
# pwNone= pairs(emms, adjust='none')
# pwSidak= pairs(emms, adjust='sidak')
# pwBonf= pairs(emms, adjust='bonf')
# 
# # assignment issue?
# summary(pairs(emms, adjust='bonf'))
# 
#workaround for sidak correction with only 2 groups:
EMM <- emmeans(model_lmerTest, ~ trialType | sesSpecialLabel)   # where treat has 2 levels
pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(pairs(EMM), by = NULL, adjust = "sidak")   # all are in one group now


# #stage 1 
# EMM <- emmeans(model_lmerTest, ~ trialType | sesSpecialLabel)   # where treat has 2 levels
# pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(pairs(EMM), by = NULL, adjust = "sidak")   # all are in one group now

EMM2 <- emmeans(model_lmerTest, ~ sesSpecialLabel | trialType)   # where treat has 2 levels
pairs(EMM2, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(pairs(EMM2), by = NULL, adjust = "sidak")   # all are in one group now


#- Viz interaction plot
emmip(model_lmerTest, sesSpecialLabel ~ trialType)



#%% Figure 2B Stats 1 continued -- Compare DS vs Null/0 AUC on first session (no NS) --####

#-- subset data ####
# subset stage 1
df_sub_1_1= df[df$stage==1,]

# subset DS trials only
df_sub_1_1= df_sub_1_1[df_sub_1_1$trialType== 'aucDSblue',]

#--One sample T test DS vs null(0) for the first session
t_1_1= t.test(df_sub_1_1$periCueBlueAuc)


#%% Figure 2B Stats 2 -- 'Learning' across sesssions; Compare DS AUC across all special sessions --####


#-- subset DS trials for 'learning' across sessions
df_Sub_2= df[df$trialType =="aucDSblue",]
model_learn= lmerTest::lmer('periCueBlueAuc ~ sesSpecialLabel + (1|subject)', data=df_Sub_2)

summary(model_learn)

model_anova_learn<- anova(model_learn)



EMM2 <- emmeans(model_learn, ~ sesSpecialLabel)   # where treat has 2 levels
pairs(EMM2, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(pairs(EMM2), by = NULL, adjust = "sidak")   # all are in one group now



#don't use tukey's post-hok adjustment, use sidak.

# pw= summary(pw, adjust= 'sidak')

# plot(pw)


# # Use single consistent naming structure for this fig's data?
# #best to just keep generic & change filenames I think
# fig2Bstats.lme= model_lmerTest
# fig2Bstats.lme_anova= model_anova_lmerTest
# fig2Bstats.posthoc_pairwise= emms


#%%- Save outputs #### 

setwd(pathOutput)

#use sink to write console output to text file
sink("vp-vta_fig2B_lmer.txt")
print(summary(model_lmerTest))
sink()  # returns output to the console


#use sink to write console output to text file
sink("vp-vta_fig2B_lmer_anova.txt")
print(model_anova_lmerTest)
sink()  # returns output to the console


#use sink to write console output to text file
sink("vp-vta_fig2B_posthoc_pairwise.txt")
print(summary(pw)) 
sink()  # returns output to the console

#use sink to write console output to text file
sink("vp-vta_fig2B_posthoc_simple_pairwise.txt")
print(summary(t))
sink()  # returns output to the console


# use sink to write console output to text file
# write everything to one file #removing print() calls doesn't seem to clean up anyway

sink("vp-vta_fig2B_stats.txt")
print('1)---- LME:')
print(summary(model_lmerTest))
print('2)---- ANOVA of LME:')
print(model_anova_lmerTest)
print('3)---- Posthoc pairwise:')
print(summary(t))

sink()  # returns output to the console


setwd(pathWorking)

# TODO: T-Test for Figure 2B first day ... Compare mean auc against 0

## ---- FIGURE XX -----------
  