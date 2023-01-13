######################################################
## script for importing .pkls from Python
##
## 2021-10-11
####################################################

###### enter python env ####
Sys.setenv(RETICULATE_PYTHON = "C:/Users/Dakota/anaconda3/envs/spyder-env-seaborn-update")

#%%-- Import dependencies ####
library(lme4)
library(reticulate)

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

library(lmerTest)

model= lmerTest::lmer('periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)', data=df_Sub_1)


model_anova<- anova(model)


#%%-- Run Follow-up post-hoc tests ####

#- Signifcant interaction term, want to follow-up and estimate main effects

#emmeans package useful for post-hoc
library(emmeans)


#-- Pairwise comparisons (t test) between TrialType for each sesSpecialLabel 
#workaround for sidak correction with only 2 groups:
#- Viz interaction plot & 
figName= "fig2b_stats_1_interactionPlot.pdf"
setwd(pathOutput)
pdf(file=figName)

emmip(model, trialType ~ sesSpecialLabel)

dev.off()
setwd(pathWorking)


#- Pairwise T- tests
EMM <- emmeans(model, ~ trialType | sesSpecialLabel)   # where treat has 2 levels
tPairwise= pairs(EMM, adjust = "sidak")   # adjustment is ignored - only 1 test per group
summary(tPairwise, by = NULL, adjust = "sidak")   # all are in one group now



# replacing below posthoc with separate LME
#-- Pairwise comparisons (t test) between sesSpecialLabel for each TrialType
#workaround for sidak correction with only 2 groups:

# #- Viz interaction and save plot
# figName= "fig2b_stats_1_interactionPlot2.pdf"
# setwd(pathOutput)
# pdf(file=figName)
# 
# emmip(model,  sesSpecialLabel ~ trialType)
# 
# dev.off()
# setwd(pathWorking)
# 
# #- Pairwise T- tests
# EMM2 <- emmeans(model, ~ sesSpecialLabel | trialType)   # where treat has 2 levels
# pairs(EMM2, adjust = "sidak")   # adjustment is ignored - only 1 test per group
# summary(pairs(EMM2), by = NULL, adjust = "sidak")   # all are in one group now
# 
# 
# 


#%%-- Save output between tests  ####
# trying to keep code mostly generalizable and just save custom names at end
# all the results into descriptive variables between tests

#naming scheme : figure_stats_{count/identifier of stats goal}_{count/identifier of stats chronology}_{descriptor of stats test}
# trying to make names for good alphanumeric sorting / legibility later

fig2B_stats_1_0_description= "DS vs NS AUC"
fig2B_stats_1_1_model= model
fig2B_stats_1_2_model_anova= model_anova
fig2B_stats_1_3_model_post_hoc= tPairwise 


#nest in df better?
#If we want to start with a NULL object, use a list, then at the end, convert it to data.frame or data.table. In that way
#https://stackoverflow.com/questions/64164612/error-in-data-framex-name-value-replacement-has-1-row-data-has-0
# fig2B_stats_1= list()
# fig2B_stats_1$model= model
# fig2B_stats_1$model_anova= model_anova
# 
# fig2B_stats_1= data.frame(fig2B_stats_1)
# 
# 
# fig2B_stats_1= data.frame()
# fig2B_stats_1$model= model
# 
# fig2B_stats_1= data.table()
# fig2B_stats_1$model= model


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
# fig2Bstats.lme= model
# fig2Bstats.lme_anova= model_anova
# fig2Bstats.posthoc_pairwise= emms


#%%- Save outputs #### 

setwd(pathOutput)

#use sink to write console output to text file
sink("vp-vta_fig2B_lmer.txt")
print(summary(model))
sink()  # returns output to the console


#use sink to write console output to text file
sink("vp-vta_fig2B_lmer_anova.txt")
print(model_anova)
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
print(summary(model))
print('2)---- ANOVA of LME:')
print(model_anova)
print('3)---- Posthoc pairwise:')
print(summary(t))

sink()  # returns output to the console


setwd(pathWorking)

# TODO: T-Test for Figure 2B first day ... Compare mean auc against 0

## ---- FIGURE XX -----------
  



## ----- Notes on Stats  / Packages-------- ####

#-Don't use dynamic formula names for lmes. It won't show in the .summary()!

#-lmerTest may give more information when anova is called on lme (vs lmer4)

#-good resources about post-hoc testing: 
# https://stats.stackexchange.com/questions/187996/interaction-term-in-a-linear-mixed-effect-model-in-r
# https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html
# https://cran.r-project.org/web/packages/emmeans/vignettes/interactions.html

#- workaround if emms posthoc testing ignoring pvalue correction 'adjust':
# https://cran.r-project.org/web/packages/emmeans/vignettes/FAQs.html#noadjust



