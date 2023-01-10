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
#https://stats.stackexchange.com/questions/187996/interaction-term-in-a-linear-mixed-effect-model-in-r
library(lmerTest)

model_lmerTest= lmerTest::lmer('periCueBlueAuc ~ trialType * sesSpecialLabel + (1|subject)', data=df)


model_anova_lmerTest<- anova(model)


#%% Run Follow-up post-hoc tests

# em <- emmeans(aucstage1to4_model,specs= ~ as.factor(led) *as.factor(day) *sex)


(lsm <- ls_means(model_lmerTest))
# ls_means(fm, which = "Product", pairwise = TRUE)

ls_means(model, which = "sesSpecialLabel", pairwise = TRUE)
plot(lsm, which=c("sesSpecialLabel", "Information"))

(lsm <- ls_means(model_lmerTest))
ls_means(model, which = "sesSpecialLabel", pairwise = TRUE)
plot(lsm, which=c("sesSpecialLabel", "Information"))



#emmeans or lmertest (ls_means)? 

#- Signifcant interaction term, want to follow-up and estimate main effects

#emmeans package useful for post-hoc
library(emmeans)

# contrast(model) #error

# Viz interaction
emmip(model_lmerTest, trialType ~ sesSpecialLabel)

# pairwise comparisons with emmeans
emm<- emmeans(model_lmerTest, pairwise ~ trialType : sesSpecialLabel)

pw= pairs(emm)

plot(pw)

# emm = emmeans(Depth1, ~ Burn_Con * Aspect)
# pairs(emm)
# 
# 
# contrast(m.emm, 'tukey') %>%
#   broom::tidy() %>%
#   head(6)

#%%- Save outputs #### 

#use sink to write console output to text file
sink("fig2B_lmer.txt")
print(summary(model_lmerTest))
sink()  # returns output to the console


#use sink to write console output to text file
sink("fig2B_lmer_anova.txt")
print(model_anova_lmerTest)
sink()  # returns output to the console


#use sink to write console output to text file
sink("fig2B_pairwise.txt")
print(summary(pw))
sink()  # returns output to the console



  