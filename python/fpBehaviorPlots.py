# -*- coding: utf-8 -*-
"""
Created on Wed May  4 15:12:11 2022

@author: Dakota
"""


#%% Load dependencies
import pandas as pd
import shelve
import os

import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# script ('module') containing custom fxns
from customFunctions import saveFigCustom
from customFunctions import subsetData
from customFunctions import subsetLevelObs
from customFunctions import percentPortEntryCalc
from customFunctions import groupPercentCalc

#%$ Things to change manually for your data:
    
#plot settings in section below



#%% Load previously saved dfTidy (and other vars) from pickle
dataPath= r'./_output/' #'r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python\\'

dfTidy= pd.read_pickle(dataPath+'dfTidyAnalyzed.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% Plot settings
sns.set_style("darkgrid")
sns.set_context('notebook')

#fixed order of trialType to plot (so consistent between figures)
#for comparison of trial types (e.g. laser on vs laser off, good to have these in paired order for paired color palettes)
trialOrder= ['DStime','NStime','Pre-Cue', 'ITI']

#DS PE probability criteria (for visualization)
criteriaDS= 0.6

#%% Exclude subjects

subjectsToExclude= [10, 17]

subjectsControl= [16, 20]

dfTidy= dfTidy[~dfTidy.subject.isin(subjectsToExclude)]

dfTidy= dfTidy[~dfTidy.subject.isin(subjectsControl)]
    
# %% Declare hierarchical grouping variables for analysis
# e.g. for aggregated measures, how should things be calculated and grouped?

# examples of different measures @ different levels:
# consider within-file (e.g. total PEs per session)
# within-trialType (e.g. Probability of PEs during all DS vs. all NS)
# within-trialID measures (e.g. Latency to enter port all individual trials)
# within virus, cue identity, subject, stage, etc.

groupHierarchySubject = ['stage',
                          'subject']
 
groupHierarchyFileID = ['stage',
                        'subject', 'trainDayThisStage', 'fileID']

groupHierarchyTrialType = ['stage',
                           'subject', 'trainDayThisStage', 'fileID', 'trialType']

groupHierarchyTrialID = ['stage',
                         'subject', 'trainDayThisStage', 'trialType', 'fileID', 'trialID']

groupHierarchyEventType = ['stage',
                           'subject', 'trainDayThisStage', 'trialType', 'fileID', 'trialID', 'eventType']
    
#%% -------PLOTS training across stages

#%% Probability of 10s PE (by trialType)

# #subset with customFunction
stagesToPlot= [1,2,3,4,5,6,7]#dfTidy.stage.unique()
trialTypesToPlot= ['DStime', 'NStime']
eventsToPlot= dfTidy.eventType.unique()

dfPlot= subsetData(dfTidy, stagesToPlot, trialTypesToPlot, eventsToPlot).copy()

#subset one observation per trial
#subset to 1 obs per trial for counting
dfPlot= subsetLevelObs(dfPlot, groupHierarchyTrialType)#.copy()

f, ax = plt.subplots(1, 1)

g= sns.lineplot(data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)

g= sns.lineplot(data= dfPlot, ax=ax, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)

plt.axhline(y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#facet by stage

g= sns.FacetGrid(data=dfPlot, row='trialType', col='stage')

# g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='subject', palette='tab20')

g.add_legend()

g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#individual subjects

for subj in dfPlot.subject.unique():
    
    dfPlot2= dfPlot.loc[dfPlot.subject==subj]
    
    g= sns.FacetGrid(data=dfPlot2, row='stage')

    g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
    g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#%% DP Manuscript Figure peProb 10s + mean Latency subplot

