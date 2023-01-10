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

#%% Run LME ####

# formula= 'periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)'
# Don't use dyanmic formula name here. It won't show in the .summary()!
# 
# model= lmer(formula, data=df)

model= lmer('periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)', data=df)

print(model)

print(summary(model))



#AS example - used lmerTest too

model_anova<- anova(model)


#lmerTest may give more information when anova is called on lme (vs lmer4)
library(lmerTest)

model_lmerTest= lmerTest::lmer('periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)', data=df)


model_anova_lmerTest<- anova(model)


#%% Run Follow-up post-hoc tests
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
pwNone= pairs(emms, adjust='none')
pwSidak= pairs(emms, adjust='sidak')
pwBonf= pairs(emms, adjust='bonf')

# assignment issue?
summary(pairs(emms, adjust='bonf'))




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
print('1)---- LME: -----')
print(summary(model_lmerTest))
print('2)---- ANOVA of LME: -----')
print(model_anova_lmerTest)
print('3)---- Posthoc pairwise: -----')
print(summary(t))

sink()  # returns output to the console




setwd(pathWorking)

## ---- FIGURE XX -----------
  