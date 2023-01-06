# -*- coding: utf-8 -*-
"""
Created on Fri Jan  6 13:46:56 2023

@author: Dakota
"""

import pandas as pd
import numpy as np

import matplotlib
import seaborn as sns

import statsmodels.api as sm
import statsmodels.formula.api as smf
#%% Import data tables (generated in matlab Figure code) and run stats here in python so can do more complex stats than matlab

#using statsmodels package
#note that statsmodels documentation frequently mentions using patsy to create design matrices. 

#formulaic seems better long term successor to patsy
# https://github.com/matthewwardrop/formulaic

#but formulaic support for mixed effects unclear as of late 2022 https://github.com/matthewwardrop/formulaic/pull/34

#here am just going to just use pandas dataframes and prep the data myself, best for mixed effects


#%% Really nice notes on categorical data / dummy & contrast coding
# https://www.statsmodels.org/stable/examples/notebooks/generated/contrasts.html

# The dummy coding is not wrong per se. It captures all of the coefficients, but it complicates matters when the model assumes independence of the coefficients such as in ANOVA.
#Linear regression models do not assume independence of the coefficients and thus dummy coding is often the only coding that is taught in this context.


#% Example LME- examining how variables are coded 
#% https://www.statsmodels.org/dev/examples/notebooks/generated/mixed_lm_example.html
# data = sm.datasets.get_rdataset("dietox", "geepack").data
# md = smf.mixedlm("Weight ~ Time", data, groups=data["Pig"])
# mdf = md.fit(method=["lbfgs"])
# print(mdf.summary())


#%% ---- FIGURE 2B STATS ---------------------------------------
#Figure 2B- compare AUC of DS vs NS
    
#%%--Load the data
datapath= r"C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\vp-vta-fp_stats_fig2bTable.parquet"

dfFig2B= pd.read_parquet(datapath)


df= dfFig2B.copy()


#Defining model variables here to help automate data prep (thinking want dummy coding of categorical fixed effects but not random effects)
yVar= ['periCueBlueAUC']

fixedEffectVars= ['trialType','sesSpecialLabel']

randomEffectVars= ['subject']


#%%-- Isolate only data you want
#to save time/memory, pare down dataset to vars we are interested in?

y= 'periCueBlueAuc'

varsToInclude= ['subject','trialType','stage','sesSpecialLabel']

varsToInclude.append(y)

df= df[varsToInclude]

#%%--Prepare data for stats


#--remove missing/invalid observations

#-can only do stat comparison for DS vs NS in stages/sessions where NS auc is present
#so subset to stages >=5
ind= []
ind= df.stage>=5

df= df.loc[ind,:]

#-- Fix dtypes - explicitly assign categorical type to categorical vars

catVars= ['subject','trialType','stage','sesSpecialLabel']

df[catVars]= df[catVars].astype('category')



#%% Dummy Coding

#-- Categorical predictor variables should be converted into dummy variables before modeling
# https://www.statology.org/pandas-get-dummies/

#if columns= None, will automatically make dummies of Object and Categorical type columns
# df= pd.get_dummies(df, columns=None , drop_first=True)

dfDummy= df.copy()

dfDummy= pd.get_dummies(dfDummy, columns=catVars , drop_first=True).copy()


# search auto-generated dummy columns for variable names we want to include in model. Iterate through and collect into new series
fixedEffectsDum= pd.Series()

# for var in fixedEffectVars:
#     fixedEffectsDum= fixedEffectsDum.append(dfDummy.columns[dfDummy.columns.str.contains(pat = var)].to_series())

# #- Create dummy variables for categoricals, replacing original columns
# for var in fixedEffectVars:
    
#     test= pd.get_dummies(dfDummy , drop_first=True).copy()    


# for var in fixedEffectVars:
#     dfDummy= df[var].copy()
    
#     test= pd.get_dummies(dfDummy , drop_first=True).copy()    
    
    
    
# search auto-generated dummy columns for variable names we want to include in model. Iterate through and collect into new series
# fixedEffectsDum= pd.Series()
fixedEffectsDum=[]

for var in fixedEffectVars:
    # dfDummy= df[var].copy()
    
    # dfDummy= pd.get_dummies(dfDummy , drop_first=True).copy()    
    
    #collect new dummy columns belonging to each fixed effect
    fixedEffectsDum.append(dfDummy.columns[dfDummy.columns.str.contains(pat = var)])

    # fixedEffectsDum= fixedEffectsDum.append(dfDummy.columns[dfDummy.columns.str.contains(pat = var)].to_series())
    # fixedEffectsDum= fixedEffectsDum.concat(dfDummy.columns[dfDummy.columns.str.contains(pat = var)].to_series())

    
    
#Patsy data prep:

# #Using Patsy to make data matrices, automatically makes dummy coded columns
# from patsy import dmatrices

# y, X = dmatrices('periCueBlueAuc ~ trialType * sesSpecialLabel ', data=df, return_type='dataframe')


#subset as needed
# df= df.loc[df.subject.notnull()]

#datetime needs to be converted as well?
# df.date= pd.datetime(df.date)


# catVars= ['virus', 'sex', 'subject','stage', 'laserDur', 'trialType']
# df= pd.get_dummies(df, columns=catVars , drop_first=True)


# #if columns= None, will automatically make dummies of Object and Categorical type columns
# df= pd.get_dummies(df, columns=None , drop_first=True)


# # search auto-generated dummy columns for variable names we want to include in model. Iterate through and collect into new series
# fixedEffects= ['virus','sex', 'stage', 'trialType', 'laserDur']
# fixedEffectsDum= pd.Series()

# for var in fixedEffects:
#     fixedEffectsDum= fixedEffectsDum.append(df.columns[df.columns.str.contains(pat = var)].to_series())
    

# y= ['probPE']


#%% SIMPLY USE C() for categoricals? 

# use C() to manually declare categorical & automatic dummy coding (should be inferred automatically)
# this works. easy.
groups= 'subject'

formula= 'periCueBlueAuc ~ C(trialType) * C(sesSpecialLabel)'

model= = smf.mixedlm(data=df, formula= formula, groups= df[groups])

modelFit= model.fit()

print(model.summary())

# for readability, could numerically code using cat.codes but would need to ensure C() is added in formula so that used appropriately.

# #convert categorical var strings to int codes?
# df['subjCode'] = df.subject.cat.codes.copy()
# df['trialTypeCode'] = df.trialType.cat.codes.copy()
# df['sesSpecialLabelCode'] = df.sesSpecialLabel.cat.codes.copy()




#%% MODEL


#groups for random intercept
groups= 'subject'

formula= 'periCueBlueAuc ~ trialType * sesSpecialLabel'

testMixed2 = smf.mixedlm(data=df, formula= formula, groups= df[groups])

# testMixed = smf.mixedlm(data=df, formula= 'periCueBlueAuc ~ trialType * sesSpecialLabel', groups= df['subject'])


testMixedFit2= testMixed2.fit()


write_path = './_output.csv'
with open(write_path, 'w') as f:
    f.write(testMixedFit2.summary().as_csv())

# testPredict= testModel.predict(df.loc[:,fixedEffectsDum])


#%% How to handle categorical variables?

# https://stats.stackexchange.com/questions/323098/encoding-of-categorical-variables-dummy-vs-effects-coding-in-mixed-models

# https://patsy.readthedocs.io/en/latest/categorical-coding.html

#%% StatsModels Notes

# https://www.statsmodels.org/stable/endog_exog.html

#%% try setting up design matrices instead of dataframe

import formulaic
# Formulaic module is successor to Patsy which is no longer in development
# y, X = model_matrix("y ~ a + b + a:b", df)
# This is short-hand for:
# y, X = formulaic.Formula('y ~ a + b + a:b').get_model_matrix(df)
# y, X = formulaic.Formula('probPE ~ virus + sex + virus:sex').get_model_matrix(df)

# a * b is equivalent to a + b + a:b
y, X = formulaic.Formula('periCueBlueAuc ~  * trialType * sesSpecialLabel | subject').get_model_matrix(df)


# Fitting a model in statsmodels typically involves 3 easy steps:

#1) Use the model class to describe the model
#e.g. mod = sm.OLS(y, X)    # Describe model


#2) Fit the model using a class method
# e.g. res = mod.fit()       # Fit model


#3) Inspect the results using a summary method
# e.g. print(res.summary())   # Summarize model


# # statsmodels also provides graphics functions. For example, we can draw a plot of partial regression for a set of regressors by:
# # : sm.graphics.plot_partregress('Lottery', 'Wealth', ['Region', 'Literacy'],
# #    ....:                              data=df, obs_labels=False)
# mod= sm.OLS(y,X) # Describe model
# res = mod.fit()       # Fit model

# print(res.summary())   # Summarize model
# #%-- MIXED EFFECTS LM
# # df= dfFig2B.copy()
# #removing empty placeholders
# # df= df.loc[df.subject.notnull()]


# df.subject= df.subject.astype('category')

#convert categorical var strings to int codes?
df['subjCode'] = df.subject.cat.codes.copy()
df['trialTypeCode'] = df.trialType.cat.codes.copy()
df['sesSpecialLabelCode'] = df.sesSpecialLabel.cat.codes.copy()


mixedEffects= ['subjCode']

# Run an LME with fixed effects for trialType, sesSpecialLabel + interactions + 
#random intercept for subject

#coded version
#groups for random intercept
mixedEffect= 'subjCode'

formula= 'periCueBlueAuc ~ trialTypeCode * sesSpecialLabelCode'

testMixed = smf.mixedlm(data=df, formula= formula, groups= df['subjCode'])

# testMixed = smf.mixedlm(data=df, formula= 'periCueBlueAuc ~ trialTypeCode * sesSpecialLabelCode', groups= df['subjCode'])

testMixedFit= testMixed.fit()


#groups for random intercept
mixedEffect= 'subject'

formula= 'periCueBlueAuc ~ trialType * sesSpecialLabel'

testMixed2 = smf.mixedlm(data=df, formula= formula, groups= df[mixedEffect])

# testMixed = smf.mixedlm(data=df, formula= 'periCueBlueAuc ~ trialType * sesSpecialLabel', groups= df['subject'])


testMixedFit2= testMixed2.fit()


write_path = './_output.csv'
with open(write_path, 'w') as f:
    f.write(testMixedFit2.summary().as_csv())

# Since the random effects structure is not specified, the default random effects structure (a random intercept for each group) is automatically used.
# 
# testMixed = smf.mixedlm(data=df, formula= 'probPE ~virus + sex + laserDurCode + trialTypeCode', groups= df['subjCode'])
# testMixed = smf.mixedlm(data=df, formula= 'probPE ~virus + sex + laserDur + trialType', groups= df['subjCode'])

#why would i get error for fitting trialType but not laserDur?

testMixedFit= testMixed.fit() #(method=['lbfgs'])

print(testMixedFit.summary())
print(testMixedFit2.summary())



#%-- Save output of stats test
result= testMixedFit




#%- Followup tests
# https://www.statsmodels.org/dev/generated/statsmodels.regression.mixed_linear_model.MixedLMResults.html#statsmodels.regression.mixed_linear_model.MixedLMResults

# Next we fit a model with two random effects for each animal: a random intercept, and a random slope (with respect to time). This means that each pig may have a different baseline weight, as well as growing at a different rate. 
# 

#%% formulaic stuff


# To fit most of the models covered by statsmodels, you will need to create two design matrices. The first is a matrix of endogenous variable(s) (i.e. dependent, response, regressand, etc.). The second is a matrix of exogenous variable(s) (i.e. independent, predictor, regressor, etc.). The OLS coefficient estimates are calculated as usual

 # Typically, the raw input data for a model is stored in a dataframe, but the actual implementations of various statistical methodologies (e.g. linear regression solvers) act on two-dimensional numerical matrices that go by several names depending on the prevailing nomenclature of your field, including "model matrices", "design matrices" and "regressor matrices" (within Formulaic, we refer to them as "model matrices"). A formula provides the necessary information required to automate much of the translation of a dataframe into a model matrix suitable for ingestion into a statistical model.
# set()                                                       
# We use patsy’s dmatrices function to create design matrices:
# y, X = dmatrices('Lottery ~ Literacy + Wealth + Region', data=df, return_type='dataframe')

# y, X= dmatrices('probPE ~ virus + sex + stage + laserDur + subject +  trialType', data=df, return_type='dataframe')

# Formulaic module is successor to Patsy which is no longer in development
# y, X = model_matrix("y ~ a + b + a:b", df)
# This is short-hand for:
# y, X = formulaic.Formula('y ~ a + b + a:b').get_model_matrix(df)
# y, X = formulaic.Formula('probPE ~ virus + sex + virus:sex').get_model_matrix(df)

# a * b is equivalent to a + b + a:b
import formulaic
y, X = formulaic.Formula(formula).get_model_matrix(df)
