# -*- coding: utf-8 -*-
"""
Created on Thu Dec 16 11:55:32 2021

@author: Dakota
"""

from customFunctions import subsetData
from customFunctions import subsetLevelObs


import shelve
import seaborn as sns
import pandas as pd
import numpy as np

import matplotlib.pyplot as plt

import matplotlib.colors

# #%% Load previously saved dfTidyAnalyzed (and other vars) from pickle
dataPath= r'./_output/' #'r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python\\'

dfTidy= pd.read_pickle(dataPath+'dfTidyAnalyzed.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()

#%% Set plot options
sns.set_style("darkgrid")
sns.set_context('notebook')
sns.set_palette('tab10')


#- create custom palette blue/gray for cueType (mirroring MATLAB)

# Create an array with the colors you want to use
#get the RGB colors from MATLAB, save as list and loop thru converting to HEX
colors=     [[0.1725,    0.4824,    0.7137],
    [0.6706,    0.8510,    0.9137],
    [0.9000,    0.9000,      0.9000],
    [0.7294,    0.7294,    0.7294],
    [0.2510,    0.2510,    0.2510]]

#convert RBG colors to HEX
for color in range(len(colors)):
    colors[color]= matplotlib.colors.to_hex(colors[color])


#reordering for proper cycling in seaborn
colors= [colors[0],colors[4], colors[1], colors[3], colors[2]]


#viz palette
sns.palplot(colors)

# save custom color palette for easy use
cmapCustomBlueGray= (sns.color_palette(colors))

#- set context for final manuscript Figures
# sns.set_style('white')
sns.set_style('ticks')


#default line sizes etc
linewidthGrand= 2
linewidthSubj= 1
linewidthRef= 3

alphaSubj= 0.3

# - STATS options;  by default old seaborn does 95% bootstrapped CI
# https://seaborn.pydata.org/tutorial/error_bars.html?highlight=standard+error
errorBars= 'se' #SEM


# sns.palplot(sns.light_palette("purple"))
# sns.palplot(sns.diverging_palette(150, 275, s=80, l=55, n=9))

#fixed order of trialType to plot (so consistent between figures)
#for comparison of trial types (e.g. laser on vs laser off, good to have these in paired order for paired color palettes)
trialOrder= ['DStime','NStime','Pre-Cue', 'ITI']

#DS PE probability criteria (for visualization)
criteriaDS= 0.6


#%% Exclude data if necessary
dfTemp= dfTidy.copy()

#exclude subjects from training plots
# subjectsToExclude= ['VP-VTA-FP10', 'VP-VTA-FP16', 'VP-VTA-FP20', 'VP-VTA-FP220', 'VP-VTA-FP']

# EXCLUDING 17 for not discriminating ; 10/16 for no signal ; 20 for GFP
subjectsToExclude= [10, 16, 17, 20]

dfTemp= dfTemp.loc[dfTemp.subject.isin(subjectsToExclude)==False]


dfTidy= dfTemp.copy()

#%% 
# #select data
#all trialTypes excluding ITI     
# dfPlot = dfGroup[(dfGroup.trialType != 'ITI')].copy()

#all trialTypes excluding ITI     
# dfPlot = dfGroup[(dfGroup.trialType != 'ITI') & (dfGroup.trialType !='Pre-Cue')].copy()
# trialOrderPlot= ['DStime','DStime_laser','NStime','NStime_laser']

# #Only DS & NS trialTypes
# dfGroup= dfTidy.copy()
# dfPlot = dfGroup[(dfGroup.trialType == 'DStime') | (dfGroup.trialType =='NStime')].copy()
trialOrderPlot= ['DStime','NStime']

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
    


#%% Figure 1 code copied from fpBehaviorPlots (newer)

#% Plot by trainPhase (early vs late)
#recalculated 10s PE prob

#set palette
sns.set_palette(cmapCustomBlueGray)

#subset data
stagesToPlot= [1,2,3,4,5,6,7]#dfTidy.stage.unique()

trialTypesToPlot= ['DStime', 'NStime']
eventsToPlot= dfTidy.eventType.unique()

dfPlot= subsetData(dfTidy, stagesToPlot, trialTypesToPlot, eventsToPlot).copy()

#subset one observation per trial
#subset to 1 obs per trial for counting
dfPlot= subsetLevelObs(dfPlot, groupHierarchyTrialType)#.copy()


g= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)

g.map_dataframe(sns.lineplot,data= dfPlot, units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=alphaSubj)
# g.map_dataframe(sns.lineplot,data= dfPlot, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder) #old seaborn, forces ci (no errorbar parameter)
g.map_dataframe(sns.lineplot,data= dfPlot, x= 'trainDayThisPhase', y='trialTypePEProb10s', errorbar=errorBars, hue='trialType', hue_order=trialOrder)


g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

g.add_legend()


#-- Appropriately size & position figure for final layout
# g.figure.set_size_inches(figWidth,figHeight)

#mockup figure
# For JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)

#convert pixels to inches
px = 1/plt.rcParams['figure.dpi']  # pixel in inches

figWidth= 650*px
figHeight= 600*px

# #define Figure subplots

# # fig, ax = plt.subplots(1, 2, gridspec_kw={'width_ratios': [3, 1]})

# #4 subplots (2x2), equal length/width?
# fig, ax = plt.subplots(2, 2) #gridspec_kw={'width_ratios': [3, 1]})

# fig.set_size_inches(figWidth,figHeight)

# fig.tight_layout()


#%% FINAL Figure1 mockup figure with subFigures and blank spaces for others
#Instead of using Figure-level FacetGrid, explicitly do subplots


#--adjust seaborn context 
#adjust font size, need to call set() first or all in one (otherwise defaults reset)
sns.set(font_scale=0.8, font='arial')

sns.set_style('ticks')

#set palette
sns.set_palette(cmapCustomBlueGray)


#--make the figure with sub-figures
fig = plt.figure(constrained_layout=True, figsize=(figWidth, figHeight))

subFigs = fig.subfigures(2, 2, wspace=0.0, hspace= 0.0) #minimal padding between subFigs

#leaving some varying gray in the other subfigure blanks for visible divisions
subFigs[0][0].set_facecolor('0.90')
subFigs[0][1].set_facecolor('0.85')
subFigs[1][0].set_facecolor('0.75')
subFigs[1][1].set_facecolor('1')

# add suptitles for each subfig
subFigs[0,0].suptitle('A')
subFigs[0,1].suptitle('B')
subFigs[1,0].suptitle('C')
subFigs[1,1].suptitle('D')


# Manually subset and plot trainPhases
# -Exclude null trainPhase (for this only include early/late)

ind=[]
ind= ~dfPlot.trainPhase.isnull()
dfPlot= dfPlot.loc[ind]


#within sub-figure[1,1] , create 2 subplots (1 for each trainPhase plot)
fig1D = subFigs[1,1].subplots(1, 2, sharey=True, sharex=False)

#loop through to keep code concise
phasesToPlot= dfPlot.trainPhase.unique()

for thisPhase in range(len(phasesToPlot)):
    ind= dfPlot.trainPhase==phasesToPlot[thisPhase]
    dfPlot2= dfPlot.loc[ind,:].copy()
    
    g= sns.lineplot(data= dfPlot2, ax= fig1D[thisPhase], units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=alphaSubj, legend=False)
    g= sns.lineplot(data= dfPlot2, ax= fig1D[thisPhase], x= 'trainDayThisPhase', y='trialTypePEProb10s', errorbar=errorBars, hue='trialType', hue_order=trialOrder, legend=False)
    fig1D[thisPhase].axhline(y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

    # g.set(title=('Reward-seeking in '+phasesToPlot[thisPhase] + ' training'))
    g.set(title=(phasesToPlot[thisPhase] + ' training'))


    # g.set(xlabel='Days from training start')

#adjust axes labels
fig1D[0].set(xlabel='Days from training start')
fig1D[1].set(xlabel='Days from training end')

fig1D[0].set(ylabel='Probability of port entry within 10s')


# g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

# g.add_legend()





#%%a Try SubFigures to combine FacetGrid- not worth it
# # https://matplotlib.org/stable/gallery/subplots_axes_and_figures/subfigures.html#sphx-glr-gallery-subplots-axes-and-figures-subfigures-py
# fig = plt.figure(constrained_layout=True, figsize=(figWidth, figHeight))
# subFigs = fig.subfigures(2, 2, wspace=0.07)

# subFigs[0][0].set_facecolor('0.75')
# subFigs[0][1].set_facecolor('0.66')
# subFigs[1][0].set_facecolor('0.44')
# subFigs[1][1].set_facecolor('0.22')


# # # axsLeft = subFigs[0].subplots(1, 2, sharey=True)

# # #nope 
# # # subFigs[0]= g
# # # subFigs[0][0]= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)

# # #reverse approach: make the seaborn facetgrid figure, then add subfig to this?
# # # doesn't seem to work.
# # g= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)
# # g.map_dataframe(sns.lineplot,data= dfPlot, units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=alphaSubj)

# # gridspec= g.fig.axes[0].get_subplotspec().get_gridspec()

# # # # clear the left column for the subfigure:
# # # for a in g.axes[:, 0]:
# # #     a.remove()
    
# # subfig = g.fig.add_subfigure(gridspec[1, 0])

# # subfig.set_facecolor('0.75')


# # # sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)




#%%a Try to combine above layout with FacetGrid
#Try add facet grid to axes
g= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)

g.map_dataframe(sns.lineplot,data= dfPlot, units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=alphaSubj)
# g.map_dataframe(sns.lineplot,data= dfPlot, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder) #old seaborn, forces ci (no errorbar parameter)
g.map_dataframe(sns.lineplot,data= dfPlot, x= 'trainDayThisPhase', y='trialTypePEProb10s', errorbar=errorBars, hue='trialType', hue_order=trialOrder)


g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

g.add_legend()


# #define data
# x = [1, 2, 3]
# y = [7, 13, 24]

# #create subplots
# ax[0].plot(x, y, color='red')
# ax[1].plot(x, y, color='blue')



#% Save Figure as SVG
# figName= 'allSubjects-Figure1_trainData_trainPhase_PEProb10s'

# sns.set_theme(style="whitegrid")

# plt.gcf().tight_layout()
# plt.savefig(savePath+figName+'.svg', bbox_inches='tight')

# saveFigCustom(g, figName, savePath)


# #-- Review individual data
# # #individual subjects

# for subj in dfPlot.subject.unique():
    
#     dfPlot2= dfPlot.loc[dfPlot.subject==subj]
    
#     g= sns.FacetGrid(data=dfPlot2, row='stage')

#     g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
#     g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
    
#     g.fig.suptitle(subj)



#%% OLD CODE Figure 1, training plot of PE ratio early vs late PE

# OLDER CODE: seems better plots are in fpBehaviorPlots.py

#adapting from fpBehaviorAnalysis.py

#2022-01-03 note these are python calculated PE ratio values as opposed to MPC calculated values in fpBehaviorPlots.py... prior script

#subset data
dfPlot= dfTidy.copy()

#dp 1/15/22 error for fp data
# #define stages for 'early' and 'late' subplotting
# #TODO: consider groupby() stage and counting day within each stage to get the first x sessions of stage 5 compared to last?

#-- GAD-VP-OPTO
#strings? 
# earlyStages= ['Stage 1','Stage 2','Stage 3','Stage 4', 'continuous reinforcement', 'RI 15s',' RI 30s']
# lateStages= ['Stage 5', 'Stage 5+tether', 'RI 60s']
# # earlyStages= ['Stage 4']
# # lateStages= ['Stage 5+tether']
# testStages= ['Cue Manipulation', 'test']
# dfPlot['stageType']= pd.NA #dfPlot.stage.astype('str').copy()

#-- VP-VTA-FP 
#- floats
earlyStages= [1,2,3,4]
lateStages= [5,6,7]
# earlyStages= ['Stage 4']
# lateStages= ['Stage 5+tether']
testStages= ['Cue Manipulation', 'test']
dfPlot['stageType']= pd.NA #dfPlot.stage.astype('str').copy()


dfPlot.loc[dfPlot.stage.isin(earlyStages), 'stageType']= 'early'
dfPlot.loc[dfPlot.stage.isin(lateStages), 'stageType']= 'late'
dfPlot.loc[dfPlot.stage.isin(testStages), 'stageType']= 'test'

dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
test= dfGroup.groupby(['subject', 'stage']).transform('cumcount')

# dfPlot.stageType= dfPlot.stageType.astype('category')

#exclude test sessions
# dfPlot= dfPlot.loc[dfPlot.stageType != 'test',:].copy()


 
#get only PE outcomes
# dfPlot.reset_index(inplace=True)
dfPlot= dfPlot.loc[(dfPlot.trialOutcomeBeh10s=='PE') | (dfPlot.trialOutcomeBeh10s=='PE+lick')].copy()
 
#since we calculated aggregated proportion across all trials in session,
#take only first index. Otherwise repeated observations are redundant
dfPlot= dfPlot.groupby(['fileID','trialType','trialOutcomeBeh10s']).first().copy()
 
#sum together both PE and PE+lick for total overall PE prob
# dfPlot['outcomeProbFile']= dfPlot.groupby(['fileID'])['outcomeProbFile'].sum().copy()

# # 2022-01-02 dp duplicate outcomeProbFile10s, debugging
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='outcomeProbFile10s_x', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='outcomeProbFile10s_y', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)

# TODO: should fix this in the fpBehaviorAnalysis.py. probably due to melting() twice?

dfPlot['probPE']= dfPlot.groupby(['fileID','trialType'])['outcomeProbFile10s'].sum().copy()

#get an aggregated x axis for files per subject
fileAgg= dfPlot.reset_index().groupby(['subject','fileID','trialType']).cumcount().copy()==0
 
#since grouping PE and PE+lick, we still have redundant observations
#retain only 1 per trial type per file
dfPlot= dfPlot.reset_index().loc[fileAgg]

#subjects may run different session types on same day (e.g. different laserDur), so shouldn't plot simply by trainDayThisStage across subjects
#individual plots by trainDayThisStage is ok
# sns.set_palette('Paired')

#facet early v late stages #for iris like christelle's opto plot
g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='stageType', hue='trialType', hue_order=trialOrderPlot, kind='line', markers=True, dashes=True
                , facet_kws={'sharey': True, 'sharex': False}, palette= 'tab10', linewidth= linewidthGrand)

g.map(sns.lineplot, data=dfPlot, x='trainDayThisStage', y='probPE', units='subject', hue='trialType', hue_order=trialOrder, estimator=None, alpha= alphaSubj, linewidth=linewidthSubj)

g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

#%% 

#a few examples of options here
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='subject', markers=True, dashes=False)
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', size='stage')
# g= sns.relplot(data= dfPlot, x='trainDayThisStage', y='probPE', hue='subject', kind='line', style='trialType', markers=True)

# g= sns.relplot(data= dfPlot, x='trainDayThisStage', y='probPE', hue='subject', kind='line', style='trialType', markers=True, row='stage')
# g.set_titles('{row_name}')
g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
g.fig.suptitle('Evolution of the probPE in subjects by trialType')
saveFigCustom(g, 'training_peProb_10s_individual')


#virus , sex facet 
#only DS and NS
g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='sex', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
saveFigCustom(g, 'training_peProb_10s_virus+sex')

g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='sex', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
saveFigCustom(g, 'training_peProb_10s_virus+sex_trainDay')

g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
saveFigCustom(g, 'training_peProb_10s_virus')

#facet early v late stages #for iris like christelle's opto plot
g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='stageType', hue='trialType', hue_order=trialOrderPlot, kind='line', style='sex', markers=True, dashes=True
                , facet_kws={'sharey': True, 'sharex': False}, palette= 'tab10')
g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
saveFigCustom(g, 'training_peProb_10s_early_vs_late_trainDay')



#%% ===== OLD code below, prior to 2023-01-02



#%% Exclude data if necessary
dfTemp= dfTidy.copy()

#subset subjects to plot (for training should we just show the n=9 or all?)
subjectsToExclude= ['VP-VTA-FP10', 'VP-VTA-FP16', 'VP-VTA-FP20', 'VP-VTA-FP220', 'VP-VTA-FP']
dfTemp= dfTemp.loc[dfTemp.subject.isin(subjectsToExclude)==False]

#%% Calculate PE probability
#Probability of PE within 10s of cue 
criteriaDS= 0.6

# declare hierarchical grouping variables (how should observations be separated)
# groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'trainDayThisStage', 'trialType'] #Opto
# groupers= ['virus', 'sex', 'stage', 'subject', 'trainDayThisStage', 'trialType'] #Photometry
groupers= ['subject', 'trainDayThisStage', 'trialType'] #Photometry


#here want percentage of each behavioral outcome per trialType per above groupers
observation= 'trialOutcomeBeh10s'

#Now calculate PE Probability using fxn:    
test= customFunctions.percentPortEntryCalc(dfTemp, groupers, observation)

test= test.reset_index()

#merge back into dataframe
dfTemp= dfTemp.merge(test, how='left', on=groupers).copy()

#then resample only valid observations (for this it's one PE probability per trialType per fileID)
dfPlot= dfTemp.loc[dfTemp.groupby(['fileID','trialType']).cumcount()==0].copy()

#%% Figure of Training Data, all individual subjects, all stages

#subset specific trialTypes to include!
trialTypesToPlot= pd.Series(dfPlot.loc[dfPlot.trialType.notnull(),'trialType'].unique())
trialTypesToPlot= trialTypesToPlot.loc[((trialTypesToPlot.str.contains('Pre-Cue')|(trialTypesToPlot.str.contains('DS')) | (trialTypesToPlot.str.contains('NS'))))]
dfPlot= dfPlot.loc[dfPlot.trialType.isin(trialTypesToPlot)]
dfPlot.trialType= dfPlot.trialType.cat.remove_unused_categories()

trialOrder= ['DStime','NStime', 'Pre-Cue']


#% THIS is probably the most informative individual subject training visualization
g= sns.relplot(data=dfPlot, x= 'trainDay', y='PE', col='subject', col_wrap=3, style='stage', hue='trialType', hue_order=trialOrder, kind='line', markers=True)
g.fig.suptitle('VP-VTA-FP DS Task Training Data')
g.set_ylabels('Probability of port entry within 10s cue onset')
    # criteria line overlaid
g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

customFunctions.saveFigCustom(g, 'vp-vta-fp_individual_PEprob', close=False)

#%% Figure of Training data, group average, specific stage subset
#Probability of PE within 10s of cue 

#then resample only valid observations (for this it's one PE probability per trialType per fileID)
dfPlot= dfTemp.loc[dfTemp.groupby(['fileID','trialType']).cumcount()==0].copy()

#subset only stages 1-5
# stagesToPlot= ['1.0','2.0','3.0','4.0','5.0']
stagesToPlot= ['4.0', '5.0', '6.0', '7.0']

dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)].copy()
dfPlot.stage= dfPlot.stage.cat.remove_unused_categories()

#subset specific trialTypes to plot!
trialTypesToPlot= pd.Series(dfPlot.loc[dfPlot.trialType.notnull(),'trialType'].unique())
trialTypesToPlot= trialTypesToPlot.loc[((trialTypesToPlot.str.contains('DS')) | (trialTypesToPlot.str.contains('NS')))]
dfPlot= dfPlot.loc[dfPlot.trialType.isin(trialTypesToPlot)]
dfPlot.trialType= dfPlot.trialType.cat.remove_unused_categories()

trialOrder= ['DStime','NStime']
 

# #group mean with individual subjects overlaid
# g = sns.FacetGrid(data=dfPlot, row='stage')
# g.fig.suptitle('Probability of port entry within 10s cue onset')
# g.map_dataframe(sns.lineplot, x= 'trainDayThisStage', y='PE', hue='trialType', hue_order=trialOrder)
# g.map_dataframe(sns.lineplot,x='trainDayThisStage', y='PE', units='subject', estimator=None, palette=('muted'), hue='trialType', hue_order=trialOrder, style='subject', markers=True, dashes=True, linewidth=1, markersize=5)
# g.set_ylabels('Probability of PE within 10s cue onset') 
# g.set_xlabels('trainDayThisStage')
# g.legend
#    # criteria line overlaid
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

#THIS seems like best way to compare across stages for whole group
#Facet stage, trialType. group mean with individual subjects overlaid
g = sns.FacetGrid(data=dfPlot, col='stage', row='trialType')
g.fig.suptitle('Probability of port entry within 10s cue onset')
g.map_dataframe(sns.lineplot, x= 'trainDayThisStage', y='PE', hue='trialType', hue_order=trialOrder, linewidth=2, zorder=0)
g.map_dataframe(sns.lineplot,x='trainDayThisStage', y='PE', units='subject', estimator=None, palette=('muted'), hue='trialType', hue_order=trialOrder, style='subject', markers=True, dashes=True, linewidth=1, markersize=5)

g.set_ylabels('Probability of PE within 10s cue onset') 
g.set_xlabels('trainDayThisStage')
g.legend
   # criteria line overlaid
g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

customFunctions.saveFigCustom(g, 'vp-vta-fp_group_PEprob', close=False)

#%% TODO: Facet by Cue Identity- does siren vs. white noise differ?
