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

savePath= r'./_output/_dp_manuscript_figs/'

# sns.set_style("darkgrid")
# sns.set_context('notebook')
# sns.set_palette('tab10')


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
criteriaNS= 0.4

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
    


#%% RECALCULATRING / DEFINING ENDSTAGE


#%% - Mark criteriaSes; sessions which pass behavioral criteria (for DS task, DS and NS PE Ratio)

#- clear previously calclulated values
dfTidy.trainPhase= None
dfTidy.trainDayThisPhase= None
# dfTidy.criteriaSes= None


# #-----TODO: do reverse-criteria for the mpc values first (less complicated than this)

# #stages 1-4= DS only 
#     #melt() probPE trialtype 



# dfTemp= dfTidy.loc[dfTidy.stage< 5].copy()

# ind= dfTemp.mpcDSpeRatio >= criteriaDS 

# ind= dfTemp.loc[ind].index

# dfTidy.loc[ind, 'criteriaSes']= 1

# #stage >5 includes NS also

# dfTemp= df.loc[df.stage>= 5]

# ind= ((dfTemp.mpcDSpeRatio >= criteriaDS ) & (dfTemp.mpcNSpeRatio <= criteriaNS))

# ind=dfTemp.loc[ind].index

# df.loc[ind,'criteriaSes']= 1



#% - Mark Early vs. Late training data for comparison
# n first days vs. n final days (prior to meeting criteria)


#number of sessions to include as 'early' and 'late' (n+ 1 for the 0th session so n=4 would be 5 sessions)
nSes= 5#4


#stage at which to start reverse labelling of 'late' from last day of stage (not currently based on criteria label)
endStage= 7
# endStage= 5


#% Add trainPhase label for early vs. late training days within-subject

# #
# # dfTemp= dfTidy.copy()

# # ind= dfTemp.loc[dfTemp.criteriaSes==1 & (dfTemp.stage == endStage)]

# #mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
# #this way can find easily and get last n sessions
# dfTemp= dfTidy.copy()

# dfGroup= dfTemp.loc[dfTemp.groupby('fileID').transform('cumcount')==0,:].copy() #one per session

# test= dfGroup.groupby(['subject','fileID','criteriaSes'], as_index=False)['trainDay'].count()



#- mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
#this way can find easily and get last n sessionsdfTemp= df.copy()
dfTemp= dfTidy.copy()

#instead of limiting to criteria days, simply start last n day count from final day of endStage
# dfTemp= dfTemp.loc[dfTemp.criteriaSes==1]

dfTemp= dfTemp.loc[dfTemp.stage==endStage]

#first fileIDs for each subject which meet criteria in the endStage
# dfTemp= dfTemp.groupby(['subject']).first()#.index

#just get last fileID for each subj in endStage
dfTemp= dfTemp.groupby(['subject']).last()#.index

ind= dfTemp.fileID


dfTidy.loc[dfTidy.fileID.isin(ind),'criteriaSes']= 2

#- now mark last n sessions preceding final criteria day as "late"

#subset data up to absolute criteria session

#get trainDay corresponding to absolute criteria day for each subject, then get n prior sessions and mark as late
dfTemp2= dfTidy.copy()

# dfTemp2=dfTemp2.set_index(['subject'])
#explicitly saving and setting on original index to prevent mismatching (idk why this was happening but it was, possibly something related to dfTemp having index on subject)
dfTemp2=dfTemp2.reset_index(drop=True).set_index(['subject'])


#-- something wrong here with lastTrainDay assignment
dfTemp2['lastTrainDay']= dfTemp.trainDay.copy()

dfTemp2= dfTemp2.reset_index().set_index('index')

#get dates within nSes prior to final day 
ind= ((dfTemp2.trainDay>=dfTemp2.lastTrainDay-nSes) & (dfTemp2.trainDay<=dfTemp2.lastTrainDay))


#label trainPhase as late
dfTemp2.loc[ind,'trainPhase']= 'late'

dfTidy['trainPhase']= dfTemp2['trainPhase'].copy()

#add reverse count of training days within late phase (countdown to final day =0)
dfTemp2.loc[ind,'trainDayThisPhase']= dfTemp2.trainDay-dfTemp2.lastTrainDay

dfTidy['trainDayThisPhase']= dfTemp2['trainDayThisPhase'].copy()

#- Now do early trainPhase for first nSes
#just simply get first nSes starting with 0
ind= dfTidy.trainDay <= nSes

dfTidy.loc[ind,'trainPhase']= 'early'


#TODO- in progress (indexing match up)
# add forward cumcount of training day within early phase 
#only save into early phase subset
ind= dfTidy.trainPhase=='early'

dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
dfTidy.loc[ind,'trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount') #add 1 for intuitive count
dfTidy.trainDayThisPhase= dfTidy.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()



#% 
# viz by day
test= subsetLevelObs(dfTidy,['fileID'])
test= test.loc[:,['fileID','subject','stage','trainPhase','trainDayThisPhase', 'criteriaSes']]#,'mpcDSpeRatio','mpcNSpeRatio']]



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


# #-- Appropriately size & position figure for final layout
# # g.figure.set_size_inches(figWidth,figHeight)

#mockup figure
# For JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)

#convert pixels to inches
px = 1/plt.rcParams['figure.dpi']  # pixel in inches

figWidth= 650*px
figHeight= 600*px

# # #define Figure subplots

# # # fig, ax = plt.subplots(1, 2, gridspec_kw={'width_ratios': [3, 1]})

# # #4 subplots (2x2), equal length/width?
# # fig, ax = plt.subplots(2, 2) #gridspec_kw={'width_ratios': [3, 1]})

# # fig.set_size_inches(figWidth,figHeight)

# # fig.tight_layout()


#%% FINAL Figure1 mockup figure with subFigures and blank spaces for others
#Instead of using Figure-level FacetGrid, explicitly do subplots


#--adjust seaborn context 
#adjust font size, need to call set() first or all in one (otherwise defaults reset)
sns.set(font_scale=0.8, font='arial')

sns.set_style('ticks')

#set palette
sns.set_palette(cmapCustomBlueGray)



#adjust to make text save as editable- might prevent live drawing in spyder?
# https://stackoverflow.com/questions/5956182/cannot-edit-text-in-chart-exported-by-matplotlib-and-opened-in-illustrator
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42


#--make the figure with sub-figures
fig = plt.figure(constrained_layout=True, figsize=(figWidth, figHeight))

# subFigs = fig.subfigures(2, 2, wspace=0.0, hspace= 0.0) #minimal padding between subFigs

#-2023-01-05 make D wider with width_ratios

#todo this, make nested second row and use width_ratios
# subFigs = fig.subfigures(2, 2, wspace=0.0, hspace= 0.0, width_ratios=[1, 1, 1, 3]) #minimal padding between subFigs
subFigs = fig.subfigures(2, 1, wspace=0.0, hspace= 0.0) #minimal padding between subFigs

# make 2 subfigs in top row subfig
subFigsTop= subFigs[0].subfigures(1,2, width_ratios=[1,1], wspace=0.0, hspace= 0.0)

#make 2 subfigs in bottom row subfig
subFigsNest = subFigs[1].subfigures(1, 2, width_ratios=[1, 1.66], wspace=0.0, hspace= 0.0)


#leaving some varying gray in the other subfigure blanks for visible divisions
subFigsTop[0].set_facecolor('0.90')
subFigsTop[1].set_facecolor('0.85')
subFigsNest[0].set_facecolor('0.75')
subFigsNest[1].set_facecolor('1')

# add suptitles for each subfig
subFigsTop[0].suptitle('A')
subFigsTop[1].suptitle('B')
subFigsNest[0].suptitle('C')
subFigsNest[1].suptitle('D')


# Manually subset and plot trainPhases
# -Exclude null trainPhase (for this only include early/late)

ind=[]
ind= ~dfPlot.trainPhase.isnull()
dfPlot= dfPlot.loc[ind]


#within sub-figure[1,1] , create 2 subplots (1 for each trainPhase plot)
#within sub-figure D, create 2 subplots  (1 for each trainPhase plot)
fig1D = subFigsNest[1].subplots(1, 2, sharey=True, sharex=False)



#-make plots
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

    #-Adjust axes ticks- 1 per x value
    fig1D[thisPhase].set(xticks= np.arange(dfPlot2.trainDayThisPhase.min(),dfPlot2.trainDayThisPhase.max()+1,1))


    # g.set(xlabel='Days from training start')

#-Adjust axes labels
fig1D[0].set(xlabel='Days from training start')
fig1D[1].set(xlabel='Days from training end')

fig1D[0].set(ylabel='Probability of port entry within 10s')


#- Save the figure
figName= 'Figure1D_Mockup'

plt.savefig(savePath+figName+'.pdf')


# plt.savefig(savePath+figName+'.svg')
# plt.savefig(savePath+figName+'.eps')


# g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

# g.add_legend()


#%% Prepare data for stats and export .pickle for stats in R
# save to pickle
#- pandas version needs to match R environment version to load the pickle!
# # activate R environment for pickling (to make env management/consistency easier)
# conda activate r-env 

df= dfPlot.copy()

#%%-- Isolate only data you want
#to save time/memory, pare down dataset to vars we are interested in

y= 'trialTypePEProb10s'

varsToInclude= ['subject','fileID', 'stage', 'trainDayThisPhase', 'trainPhase', 'trialType', 'trainDay' ]

varsToInclude.append(y)

df= df[varsToInclude]

#%%--Prepare data for stats

# #--remove missing/invalid observations


#-- Fix dtypes - explicitly assign categorical type to categorical vars
# note can use C() in statsmodels formula to treat as categorical tho good practice to change in df 

catVars= ['subject','fileID', 'stage', 'trainPhase', 'trainDayThisPhase', 'trialType']

df[catVars]= df[catVars].astype('category')

#-- make trainDayThisPhase dtype int
# df['trainDayThisPhase']= df['trainDayThisPhase'].astype('int')


savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

print('saving fig1d df to file')

#Save as pickel
df.to_pickle(savePath+'fig1d.pkl')


#%% TODO: Stat comparison of PE Latency as well? 


# %%-- old unnested of above


# #--adjust seaborn context 
# #adjust font size, need to call set() first or all in one (otherwise defaults reset)
# sns.set(font_scale=0.8, font='arial')

# sns.set_style('ticks')

# #set palette
# sns.set_palette(cmapCustomBlueGray)



# #adjust to make text save as editable 
# # https://stackoverflow.com/questions/5956182/cannot-edit-text-in-chart-exported-by-matplotlib-and-opened-in-illustrator
# matplotlib.rcParams['pdf.fonttype'] = 42
# matplotlib.rcParams['ps.fonttype'] = 42


# #--make the figure with sub-figures
# fig = plt.figure(constrained_layout=True, figsize=(figWidth, figHeight))

# subFigs = fig.subfigures(2, 2, wspace=0.0, hspace= 0.0) #minimal padding between subFigs

# #leaving some varying gray in the other subfigure blanks for visible divisions
# subFigs[0][0].set_facecolor('0.90')
# subFigs[0][1].set_facecolor('0.85')
# subFigs[1][0].set_facecolor('0.75')
# subFigs[1][1].set_facecolor('1')

# # add suptitles for each subfig
# subFigs[0,0].suptitle('A')
# subFigs[0,1].suptitle('B')
# subFigs[1,0].suptitle('C')
# subFigs[1,1].suptitle('D')


# # Manually subset and plot trainPhases
# # -Exclude null trainPhase (for this only include early/late)

# ind=[]
# ind= ~dfPlot.trainPhase.isnull()
# dfPlot= dfPlot.loc[ind]


# #within sub-figure[1,1] , create 2 subplots (1 for each trainPhase plot)
# fig1D = subFigs[1,1].subplots(1, 2, sharey=True, sharex=False)

# #-make plots
# #loop through to keep code concise
# phasesToPlot= dfPlot.trainPhase.unique()

# for thisPhase in range(len(phasesToPlot)):
#     ind= dfPlot.trainPhase==phasesToPlot[thisPhase]
#     dfPlot2= dfPlot.loc[ind,:].copy()
    
#     g= sns.lineplot(data= dfPlot2, ax= fig1D[thisPhase], units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=alphaSubj, legend=False)
#     g= sns.lineplot(data= dfPlot2, ax= fig1D[thisPhase], x= 'trainDayThisPhase', y='trialTypePEProb10s', errorbar=errorBars, hue='trialType', hue_order=trialOrder, legend=False)
#     fig1D[thisPhase].axhline(y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

#     # g.set(title=('Reward-seeking in '+phasesToPlot[thisPhase] + ' training'))
#     g.set(title=(phasesToPlot[thisPhase] + ' training'))


#     # g.set(xlabel='Days from training start')

# #-Adjust axes labels
# fig1D[0].set(xlabel='Days from training start')
# fig1D[1].set(xlabel='Days from training end')

# fig1D[0].set(ylabel='Probability of port entry within 10s')


# #- Save the figure
# figName= 'Figure1D_Mockup'

# plt.savefig(savePath+figName+'.pdf')

# # plt.savefig(savePath+figName+'.svg')
# # plt.savefig(savePath+figName+'.eps')


# # g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

# # g.add_legend()



#%% Calculations

#-- Minimum # of training days at stage 1-4 vs stage 5

#individual stage counts
test= dfTidy.groupby(['subject','stage'])['trainDayThisStage'].max()

test2= test.groupby(['stage']).min()

test3= test2+1

# test4=  dfTidy.groupby(['stage'])['trainDayThisStage'].max()


#grouped counts
#count minimum num of sessions grouped stage 1-4 vs 5

#subset to 1 observation per file

dfTemp= subsetLevelObs(dfTidy, groupHierarchyFileID).copy()

early= [1,2,3,4]
late= [6,7]

ind=[]
ind= dfTemp.stage.isin(early)


dfTemp.loc[ind,'countPhase']= 0

ind=[]
ind= dfTidy.stage.isin(late)


dfTemp.loc[ind,'countPhase']= 1


# test= dfTemp.groupby(['subject','countPhase'])['fileID'].nunique()
# test= dfTemp.groupby(['subject','countPhase']).cumcount()a minimu

test= dfTemp.groupby(['subject','countPhase'])['fileID'].count()

test2= test.groupby(['countPhase']).min()

# test3= test= dfTemp.groupby(['subject','countPhase'])['fileID']


# test= dfTemp.set_index(['subject','countPhase']).copy()

# #%%a Try SubFigures to combine FacetGrid- not worth it
# # # https://matplotlib.org/stable/gallery/subplots_axes_and_figures/subfigures.html#sphx-glr-gallery-subplots-axes-and-figures-subfigures-py
# # fig = plt.figure(constrained_layout=True, figsize=(figWidth, figHeight))
# # subFigs = fig.subfigures(2, 2, wspace=0.07)

# # subFigs[0][0].set_facecolor('0.75')
# # subFigs[0][1].set_facecolor('0.66')
# # subFigs[1][0].set_facecolor('0.44')
# # subFigs[1][1].set_facecolor('0.22')


# # # # axsLeft = subFigs[0].subplots(1, 2, sharey=True)

# # # #nope 
# # # # subFigs[0]= g
# # # # subFigs[0][0]= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)

# # # #reverse approach: make the seaborn facetgrid figure, then add subfig to this?
# # # # doesn't seem to work.
# # # g= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)
# # # g.map_dataframe(sns.lineplot,data= dfPlot, units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=alphaSubj)

# # # gridspec= g.fig.axes[0].get_subplotspec().get_gridspec()

# # # # # clear the left column for the subfigure:
# # # # for a in g.axes[:, 0]:
# # # #     a.remove()
    
# # # subfig = g.fig.add_subfigure(gridspec[1, 0])

# # # subfig.set_facecolor('0.75')


# # # # sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)




# #%%a Try to combine above layout with FacetGrid
# #Try add facet grid to axes
# g= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)

# g.map_dataframe(sns.lineplot,data= dfPlot, units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=alphaSubj)
# # g.map_dataframe(sns.lineplot,data= dfPlot, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder) #old seaborn, forces ci (no errorbar parameter)
# g.map_dataframe(sns.lineplot,data= dfPlot, x= 'trainDayThisPhase', y='trialTypePEProb10s', errorbar=errorBars, hue='trialType', hue_order=trialOrder)


# g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

# g.add_legend()


# # #define data
# # x = [1, 2, 3]
# # y = [7, 13, 24]

# # #create subplots
# # ax[0].plot(x, y, color='red')
# # ax[1].plot(x, y, color='blue')



# #% Save Figure as SVG
# # figName= 'allSubjects-Figure1_trainData_trainPhase_PEProb10s'

# # sns.set_theme(style="whitegrid")

# # plt.gcf().tight_layout()
# # plt.savefig(savePath+figName+'.svg', bbox_inches='tight')

# # saveFigCustom(g, figName, savePath)


# # #-- Review individual data
# # # #individual subjects

# # for subj in dfPlot.subject.unique():
    
# #     dfPlot2= dfPlot.loc[dfPlot.subject==subj]
    
# #     g= sns.FacetGrid(data=dfPlot2, row='stage')

# #     g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
# #     g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
    
# #     g.fig.suptitle(subj)



# #%% OLD CODE Figure 1, training plot of PE ratio early vs late PE

# # OLDER CODE: seems better plots are in fpBehaviorPlots.py

# #adapting from fpBehaviorAnalysis.py

# #2022-01-03 note these are python calculated PE ratio values as opposed to MPC calculated values in fpBehaviorPlots.py... prior script

# #subset data
# dfPlot= dfTidy.copy()

# #dp 1/15/22 error for fp data
# # #define stages for 'early' and 'late' subplotting
# # #TODO: consider groupby() stage and counting day within each stage to get the first x sessions of stage 5 compared to last?

# #-- GAD-VP-OPTO
# #strings? 
# # earlyStages= ['Stage 1','Stage 2','Stage 3','Stage 4', 'continuous reinforcement', 'RI 15s',' RI 30s']
# # lateStages= ['Stage 5', 'Stage 5+tether', 'RI 60s']
# # # earlyStages= ['Stage 4']
# # # lateStages= ['Stage 5+tether']
# # testStages= ['Cue Manipulation', 'test']
# # dfPlot['stageType']= pd.NA #dfPlot.stage.astype('str').copy()

# #-- VP-VTA-FP 
# #- floats
# earlyStages= [1,2,3,4]
# lateStages= [5,6,7]
# # earlyStages= ['Stage 4']
# # lateStages= ['Stage 5+tether']
# testStages= ['Cue Manipulation', 'test']
# dfPlot['stageType']= pd.NA #dfPlot.stage.astype('str').copy()


# dfPlot.loc[dfPlot.stage.isin(earlyStages), 'stageType']= 'early'
# dfPlot.loc[dfPlot.stage.isin(lateStages), 'stageType']= 'late'
# dfPlot.loc[dfPlot.stage.isin(testStages), 'stageType']= 'test'

# dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# test= dfGroup.groupby(['subject', 'stage']).transform('cumcount')

# # dfPlot.stageType= dfPlot.stageType.astype('category')

# #exclude test sessions
# # dfPlot= dfPlot.loc[dfPlot.stageType != 'test',:].copy()


 
# #get only PE outcomes
# # dfPlot.reset_index(inplace=True)
# dfPlot= dfPlot.loc[(dfPlot.trialOutcomeBeh10s=='PE') | (dfPlot.trialOutcomeBeh10s=='PE+lick')].copy()
 
# #since we calculated aggregated proportion across all trials in session,
# #take only first index. Otherwise repeated observations are redundant
# dfPlot= dfPlot.groupby(['fileID','trialType','trialOutcomeBeh10s']).first().copy()
 
# #sum together both PE and PE+lick for total overall PE prob
# # dfPlot['outcomeProbFile']= dfPlot.groupby(['fileID'])['outcomeProbFile'].sum().copy()

# # # 2022-01-02 dp duplicate outcomeProbFile10s, debugging
# # g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='outcomeProbFile10s_x', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# # g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='outcomeProbFile10s_y', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)

# # TODO: should fix this in the fpBehaviorAnalysis.py. probably due to melting() twice?

# dfPlot['probPE']= dfPlot.groupby(['fileID','trialType'])['outcomeProbFile10s'].sum().copy()

# #get an aggregated x axis for files per subject
# fileAgg= dfPlot.reset_index().groupby(['subject','fileID','trialType']).cumcount().copy()==0
 
# #since grouping PE and PE+lick, we still have redundant observations
# #retain only 1 per trial type per file
# dfPlot= dfPlot.reset_index().loc[fileAgg]

# #subjects may run different session types on same day (e.g. different laserDur), so shouldn't plot simply by trainDayThisStage across subjects
# #individual plots by trainDayThisStage is ok
# # sns.set_palette('Paired')

# #facet early v late stages #for iris like christelle's opto plot
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='stageType', hue='trialType', hue_order=trialOrderPlot, kind='line', markers=True, dashes=True
#                 , facet_kws={'sharey': True, 'sharex': False}, palette= 'tab10', linewidth= linewidthGrand)

# g.map(sns.lineplot, data=dfPlot, x='trainDayThisStage', y='probPE', units='subject', hue='trialType', hue_order=trialOrder, estimator=None, alpha= alphaSubj, linewidth=linewidthSubj)

# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

# #%% 

# #a few examples of options here
# # g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='subject', markers=True, dashes=False)
# # g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', size='stage')
# # g= sns.relplot(data= dfPlot, x='trainDayThisStage', y='probPE', hue='subject', kind='line', style='trialType', markers=True)

# # g= sns.relplot(data= dfPlot, x='trainDayThisStage', y='probPE', hue='subject', kind='line', style='trialType', markers=True, row='stage')
# # g.set_titles('{row_name}')
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# g.fig.suptitle('Evolution of the probPE in subjects by trialType')
# saveFigCustom(g, 'training_peProb_10s_individual')


# #virus , sex facet 
# #only DS and NS
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='sex', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# saveFigCustom(g, 'training_peProb_10s_virus+sex')

# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='sex', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# saveFigCustom(g, 'training_peProb_10s_virus+sex_trainDay')

# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# saveFigCustom(g, 'training_peProb_10s_virus')

# #facet early v late stages #for iris like christelle's opto plot
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='stageType', hue='trialType', hue_order=trialOrderPlot, kind='line', style='sex', markers=True, dashes=True
#                 , facet_kws={'sharey': True, 'sharex': False}, palette= 'tab10')
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# saveFigCustom(g, 'training_peProb_10s_early_vs_late_trainDay')



# #%% ===== OLD code below, prior to 2023-01-02



# #%% Exclude data if necessary
# dfTemp= dfTidy.copy()

# #subset subjects to plot (for training should we just show the n=9 or all?)
# subjectsToExclude= ['VP-VTA-FP10', 'VP-VTA-FP16', 'VP-VTA-FP20', 'VP-VTA-FP220', 'VP-VTA-FP']
# dfTemp= dfTemp.loc[dfTemp.subject.isin(subjectsToExclude)==False]

# #%% Calculate PE probability
# #Probability of PE within 10s of cue 
# criteriaDS= 0.6

# # declare hierarchical grouping variables (how should observations be separated)
# # groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'trainDayThisStage', 'trialType'] #Opto
# # groupers= ['virus', 'sex', 'stage', 'subject', 'trainDayThisStage', 'trialType'] #Photometry
# groupers= ['subject', 'trainDayThisStage', 'trialType'] #Photometry


# #here want percentage of each behavioral outcome per trialType per above groupers
# observation= 'trialOutcomeBeh10s'

# #Now calculate PE Probability using fxn:    
# test= customFunctions.percentPortEntryCalc(dfTemp, groupers, observation)

# test= test.reset_index()

# #merge back into dataframe
# dfTemp= dfTemp.merge(test, how='left', on=groupers).copy()

# #then resample only valid observations (for this it's one PE probability per trialType per fileID)
# dfPlot= dfTemp.loc[dfTemp.groupby(['fileID','trialType']).cumcount()==0].copy()

# #%% Figure of Training Data, all individual subjects, all stages

# #subset specific trialTypes to include!
# trialTypesToPlot= pd.Series(dfPlot.loc[dfPlot.trialType.notnull(),'trialType'].unique())
# trialTypesToPlot= trialTypesToPlot.loc[((trialTypesToPlot.str.contains('Pre-Cue')|(trialTypesToPlot.str.contains('DS')) | (trialTypesToPlot.str.contains('NS'))))]
# dfPlot= dfPlot.loc[dfPlot.trialType.isin(trialTypesToPlot)]
# dfPlot.trialType= dfPlot.trialType.cat.remove_unused_categories()

# trialOrder= ['DStime','NStime', 'Pre-Cue']


# #% THIS is probably the most informative individual subject training visualization
# g= sns.relplot(data=dfPlot, x= 'trainDay', y='PE', col='subject', col_wrap=3, style='stage', hue='trialType', hue_order=trialOrder, kind='line', markers=True)
# g.fig.suptitle('VP-VTA-FP DS Task Training Data')
# g.set_ylabels('Probability of port entry within 10s cue onset')
#     # criteria line overlaid
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

# customFunctions.saveFigCustom(g, 'vp-vta-fp_individual_PEprob', close=False)

# #%% Figure of Training data, group average, specific stage subset
# #Probability of PE within 10s of cue 

# #then resample only valid observations (for this it's one PE probability per trialType per fileID)
# dfPlot= dfTemp.loc[dfTemp.groupby(['fileID','trialType']).cumcount()==0].copy()

# #subset only stages 1-5
# # stagesToPlot= ['1.0','2.0','3.0','4.0','5.0']
# stagesToPlot= ['4.0', '5.0', '6.0', '7.0']

# dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)].copy()
# dfPlot.stage= dfPlot.stage.cat.remove_unused_categories()

# #subset specific trialTypes to plot!
# trialTypesToPlot= pd.Series(dfPlot.loc[dfPlot.trialType.notnull(),'trialType'].unique())
# trialTypesToPlot= trialTypesToPlot.loc[((trialTypesToPlot.str.contains('DS')) | (trialTypesToPlot.str.contains('NS')))]
# dfPlot= dfPlot.loc[dfPlot.trialType.isin(trialTypesToPlot)]
# dfPlot.trialType= dfPlot.trialType.cat.remove_unused_categories()

# trialOrder= ['DStime','NStime']
 

# # #group mean with individual subjects overlaid
# # g = sns.FacetGrid(data=dfPlot, row='stage')
# # g.fig.suptitle('Probability of port entry within 10s cue onset')
# # g.map_dataframe(sns.lineplot, x= 'trainDayThisStage', y='PE', hue='trialType', hue_order=trialOrder)
# # g.map_dataframe(sns.lineplot,x='trainDayThisStage', y='PE', units='subject', estimator=None, palette=('muted'), hue='trialType', hue_order=trialOrder, style='subject', markers=True, dashes=True, linewidth=1, markersize=5)
# # g.set_ylabels('Probability of PE within 10s cue onset') 
# # g.set_xlabels('trainDayThisStage')
# # g.legend
# #    # criteria line overlaid
# # g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

# #THIS seems like best way to compare across stages for whole group
# #Facet stage, trialType. group mean with individual subjects overlaid
# g = sns.FacetGrid(data=dfPlot, col='stage', row='trialType')
# g.fig.suptitle('Probability of port entry within 10s cue onset')
# g.map_dataframe(sns.lineplot, x= 'trainDayThisStage', y='PE', hue='trialType', hue_order=trialOrder, linewidth=2, zorder=0)
# g.map_dataframe(sns.lineplot,x='trainDayThisStage', y='PE', units='subject', estimator=None, palette=('muted'), hue='trialType', hue_order=trialOrder, style='subject', markers=True, dashes=True, linewidth=1, markersize=5)

# g.set_ylabels('Probability of PE within 10s cue onset') 
# g.set_xlabels('trainDayThisStage')
# g.legend
#    # criteria line overlaid
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

# customFunctions.saveFigCustom(g, 'vp-vta-fp_group_PEprob', close=False)

# #%% TODO: Facet by Cue Identity- does siren vs. white noise differ?

#%%% MPC VALUES PLOTTING RAW



#%% -----------------------Import and Plot Raw MPC-calculated PE Ratios -----------------


#%% Things to manually change based on your data:
    
#datapath= path to your folder containing excel files

#colToImport= columns in your excel sheets to include (manually defined this so that I could exclude a specific variable that was huge)
#TODO: this might need to change based on stage/MPC code (perhaps variables are introduced in different .MPCs that mess with the order of things)

#metapath= paths to 1) subject metadata spreadsheet (e.g. virus type, sex) and 2) session metadata spreadsheet (e.g. laser parameters, DREADD manipulations)
#excludeDate= specific date you might want to exclude

#eventVars= event type labels for recorded timestamps
#idVars=  subject & session metadata labels for recorded timestamps 

#TODO: may consider adding subjVars and sessionVars depending on your experiment 

#experimentType= just a gate now for opto-specific code. = 'Opto' for opto specific code
#TODO: could maybe add this as metadata column in spreadsheet?
# experimentType= 'Opto'
# experimentType= 'OptoInstrumentalTransfer'
# experimentType= 'photometry'

#Examples: 

# #DP VP-VTA-STGTACR DS Task
# experimentType= 'Opto'
# datapath= r'C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\\' 
# colToImport= 'A:W'  #dp opto 
# metaPathSubj= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_subj_metadata.xlsx" 
# metaPathSes= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_session_metadata.xlsx"

        
# #DP GAD-VP-OPTO DS Task
# experimentType= 'Opto'
# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\\' #dp gad-vp-opto DS task
# colToImport= 'A:W'  #dp opto 
# metaPathSubj= r'C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\subj_metadata.xlsx' #gad-vp-opto
# metaPathSes= r"C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\ses_metadata.xlsx" #gad-vp-opto DS task


#DP GAD-VP-OPTO Instrumental Transfer
# experimentType= 'OptoInstrumentalTransfer'
# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\\'
# metaPathSes= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\_metadata\GAD-VP-Opto-transfer-session-metadata.xlsx'#gad-vp-opto instrumental transfer


# #DP VP-VTA-FP DS Task 
experimentType= 'photometry'
datapath= r'K:\vp-vta-fp_behavior\MPC\_mpc_to_excel\\' #dp vp-vta-fp
colToImport= 'A:Q' #dakota vp-vta-fp
metaPathSubj= r"K:\vp-vta-fp_behavior\excel\_metadata\subj_metadata.xlsx" #dakota vp-vta-fp
metaPathSes= r"K:\vp-vta-fp_behavior\excel\_metadata\ses_metadata.xlsx" #dakota vp-vta-fp


#Ally DREADD DS Task
# experimentType= 'DREADD'
# datapath= r'C:\Users\Dakota\Desktop\_example_gaddreadd\MED-PC Files July-TBD 2021\All\\' #ally dreadd
# colToImport= 'A:Q' #ally dreadd


#%% ID and import raw data .xlsx
# your path to folder containing excel files 
# datapath = r'C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_dataRaw\\'#dp vp-vta-stgtacr opto

# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\\' #dp gad-vp-opto DS task
# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\\'
# datapath= r'J:\vp-vta-fp_behavior\MPC\_mpc_to_excel\\' #dp vp-vta-fp
# datapath= r'C:\Users\Dakota\Desktop\_example_gaddreadd\MED-PC Files July-TBD 2021\All\\' #ally dreadd
import glob

# set all .xls files in your folder to list
allfiles = glob.glob(datapath + "*.xls*")

#initialize list to store data from each file
dfRaw = pd.DataFrame()

#define columns in your .xlsx for specific variables you want (e.g. A:Z for all)
# colToImport= 'A:W'# 'F:S,U:X' #dp opto 
# colToImport= 'A:Z'# gad-vp-opto instrumental transfer 
# colToImport= 'A:Q' #dakota vp-vta-fp
# colToImport= 'A:Q' #ally dreadd


#for loop to aquire all excel files in folder
for excelfiles in allfiles:
    #read all sheets by specifying sheet_name = None
    #Remove any variables you don't want now before appending!
    #there was an issue with (W)trialState so leaving that out (col T)
    #Also leaving out first few columns
    raw_excel = pd.read_excel(excelfiles, sheet_name= None, usecols=colToImport)
    
    dfRaw = dfRaw.append(raw_excel, ignore_index=True)
    
    

    
#dfRaw is now nested df, each column is a subject and each row is a session

#eliminate data from 'MSNs' sheets for now, not informative currently
#TODO: this could be nice to get, but requires changing the mpc2excel scripts
dfRaw.drop('MSNs',axis=1,inplace=True)

#%% unnest & combine data from all files into tidy df
#loop through nested df and append data. Now we have all data in one df
df= pd.DataFrame()

for subject in dfRaw.columns:
    print('loading'+subject)
    for file in range(len(dfRaw)):
        # print(allfiles[file]+subject)
        try:
            #add file label to each nested raw_excel before appending
            #assume fileName is yyyymmdd.xlsx (total of 13 characters at end of path. 5 are '.xlsx')
            dfRaw.loc[file,subject]['file']=allfiles[file][-13:]
            
            #add date too
            dfRaw.loc[file,subject]['date']= allfiles[file][-13:-5]
            
            
            #- save specific cells from MPC arrays as new column 2022-05-11
            # -save DS and NS PE Ratio for DS task
            indFile= file,subject
            
            thisFile= dfRaw.loc[indFile].copy()
            
            colInd= thisFile.columns[np.where(thisFile.columns.str.contains('workingVars'))]

            #b(23)
            thisFile.loc[:, "mpcDSpeRatio"]= thisFile.loc[23, colInd][0]
            #b(24)
            thisFile.loc[:, "mpcNSpeRatio"]= thisFile.loc[24, colInd][0]
            
            # #% ## TODO: 
            # #get stage programmatically ~~ 20220512
            # best solution may be to get the MSN ran, will likely require hcanges to the MPC2excel code

            # # should be able to find out which stage this is of DS training using ITIs & stageParams (don't need to rely on metadata)
            # colInd= thisFile.columns[np.where(thisFile.columns.str.contains('ITI'))]
            
            # #
            
            # ITIs=  pd.DataFrame()
            
                                    
            
            # #1 col for each stage with ITIs to compare against
            # ITIs.loc[:,'1']= [20, 30, 40, 50, 60, 20, 30, 40, 50, 60 ]
            # ITIs.loc[:,'2']= [50, 60, 70, 80, 90,50, 60, 70, 80, 90 ]
            # ITIs.loc[:,'3']= [60, 70, 80, 90, 100, 60, 70, 80, 90, 100]
            # ITIs.loc[:,'4']= [70, 80, 90, 100, 110, 70, 80, 90, 100, 110]
            
            # ITIs.loc[:,'5up']= [10, 20, 30, 40, 50, 10, 20, 30, 40, 50]
            
            # # determine stage based on ITI
            
            # ITIsThisFile= thisFile.loc[0:9, colInd]
            
            # ITIsThisFile= ITIsThisFile.astype('int64')
    
            # for col in ITIs.columns:
            #    if ITIsThisFile.iloc[:,0].equals(ITIs.loc[:,col]):
            #       thisFile['stage']= col
               
            # #% ## TODO: - further define stages 5 and up based on other vars - not sure if possible very quickly wihtout some intermediate calculations...
            # if thisFile.loc[0,'stage']== '5up'
                
            #     # #pumpDur (a(3)) may define but I think it was manually defined in code, not variable
            #     # pumpDur= pd.DataFrame()
            #     # pumpDur.loc
                



            #save stage label before appending

            #add subject label before appending
            thisFile.loc[:,'subject']=subject
            
            df= df.append(thisFile)
            
            
            # #assign df with updated values back to dfRaw
            # dfRaw.loc[indFile]= thisFile

            # # #b(23)
            # # dfRaw.loc[indFile].loc[file, "mpcDSpeRatio"]= dfRaw.loc[indFile].loc[23, colInd]
            # # #b(24)
            # # dfRaw.loc[indFile].loc[file, "mpcNSpeRatio"]= dfRaw.loc[indFile].loc[24, colInd]
            
            
            # #add subject label before appending
            # dfRaw.loc[file,subject]['subject']=subject
            
            # df= df.append(dfRaw.loc[file,subject])
            
            
            #in progress
            # --save specific cells from MPC arrays added 2022-05-11
            # -save DS and NS PE Ratio for DS task
            # thisFile= dfRaw.loc[file,subject]
            
            # colInd= thisFile.columns.str.contains('workingVars')
            
            # #b(23) 
            # dfMPC.loc[file, "DSpeRatio"]= thisFile.loc[23, colInd]
            # #b(24)
            # dfMPC.loc[file, "NSpeRatio"]= thisFile.loc[24, colInd]
            
            # #save metadata for this file
            # #add date too
            # dfRaw.loc[file,subject]['date']= allfiles[file][-13:-5]
            # dfRaw.loc[file,subject]['file']=allfiles[file][-13:]

            
            # fileInd= fileInd+1
            
        except: 
            print(allfiles[file]+'_'+subject+' has no data')

#%% ID and import metadata .xlsx
#TODO: for now assuming separate excel files for these data

#convert subject and date variables to string datatype to ensure easy matching (excel number formatting can be weird)
df.subject= df.subject.astype('str')
df.date= df.date.astype('str')

# Match and insert subject metadata based on subject
# metaPathSubj= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_subj_metadata.xlsx" #dp vp-vta-stgtacr opto
# metaPathSubj= r'C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\subj_metadata.xlsx' #gad-vp-opto
# metaPathSubj= r"J:\vp-vta-fp_behavior\excel\_metadata\subj_metadata.xlsx" #dakota vp-vta-fp

dfRaw= pd.read_excel(metaPathSubj).astype('str') 

df= df.merge(dfRaw.astype('str'), how='left', on=['subject'])

# Match and insert session metadata based on date and subject

# metaPathSes= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_session_metadata.xlsx" #dp vp-vta-stgtacr opto
# metaPathSes= r"C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\ses_metadata.xlsx" #gad-vp-opto DS task
# metaPathSes= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\_metadata\GAD-VP-Opto-transfer-session-metadata.xlsx'#gad-vp-opto instrumental transfer
# metaPathSes= r"J:\vp-vta-fp_behavior\excel\_metadata\ses_metadata.xlsx" #dakota vp-vta-fp

#ensure that date is read as string
dfRaw= pd.read_excel(metaPathSes, converters={'date': str, 'subject': str})#.astype('str') 

# df= df.merge(dfRaw.astype('str'), how='left', on=['subject','date'])

df= df.merge(dfRaw, how='left', on=['subject','date'])


# %% Exclude data

excludeDate= ['20210604']

# Exclude specific date(s)
df= df[~df.date.isin(excludeDate)]

# %% Remove parentheses from variable names 

import re
#use regex to replace text between () with empty string
#loop through each column name, remove characters between () and collect into list 'labels'
labels= []
for col in df.columns:
    labels.append(re.sub(r" ?\([^)]+\)", "", col))
#rename columns to labels
df.columns= labels

#%% Add unique fileID for each session (subject & date)

#sort by date and subject
df= df.sort_values(['date','subject'])

df.loc[:,'fileID'] = df.groupby(['date', 'subject']).ngroup()



# %% Add other variables if necessary before tidying

# # calculate port exit time estimate using PEtime and peDur, save this as a new variable
df = df.assign(PExEst=df.PEtime + df.PEdur)

# save cue duration (in DS task this is A(2))
#TODO: may be better to put this in session metadata.xlsx? just to keep things parallel with photometry TDT data analysis (assume we won't import MPC as well)

#group by fileID then retrieve the 2nd value in stageParams 
grouped= df.groupby('fileID')

df.loc[:,'cueDur']= grouped.stageParams.transform('nth',2)

grouped.stageParams.nth(2)

#convert 'date' to datetime format
df.date= pd.to_datetime(df.date)



#% Calculate trainDay 

#May be missing some synapse tanks, use cumcount of trainDay within subjects (dont trust metadata sheet)

# Add trainDay variable (cumulative count of sessions within each subject)
dfGroup= df.loc[df.groupby(['subject','fileID']).cumcount()==0]
# test= dfGroup.groupby(['subject','fileID']).transform('cumcount')
df.loc[:,'trainDay']= dfGroup.groupby(['subject'])['fileID'].transform('cumcount')
df.loc[:,'trainDay']= df.groupby(['subject','fileID']).fillna(method='ffill')


#Add cumulative count of training day within-stage (so we can normalize between subjects appropriately)
##very important consideration!! Different subjects can run different programs on same day, which can throw plots/analysis off when aggregating data by date.
dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
df['trainDayThisStage']=  dfGroup.groupby(['subject', 'stage']).transform('cumcount')
df.trainDayThisStage= df.groupby(['fileID'])['trainDayThisStage'].fillna(method='ffill').copy()



#%% ---- Replace invalid NS pe Ratios for stages <5

#MPC records a 0 but should be nan for plotting & analyses
df.loc[df.stage<5, 'mpcNSpeRatio']= None


#%% -REMOVE NAN STAGE DATA (To be fixed when metadata xlsx fixed or stage is pulled from MPC)

# at least if done here should be visible gap in trainDay

# df= df.loc[df.stage.notnull()]


#%% - Mark criteriaSes; sessions which pass behavioral criteria (for DS task, DS and NS PE Ratio)

# df['criteriaSes']= None

#stages 1-4= DS only 
dfTemp= df.loc[df.stage< 5].copy()


ind= dfTemp.mpcDSpeRatio >= criteriaDS 

ind= dfTemp.loc[ind].index

df.loc[ind, 'criteriaSes']= 1

#stage >5 includes NS also

dfTemp= df.loc[df.stage>= 5]

ind= ((dfTemp.mpcDSpeRatio >= criteriaDS ) & (dfTemp.mpcNSpeRatio <= criteriaNS))

ind=dfTemp.loc[ind].index

df.loc[ind,'criteriaSes']= 1

#%% - Mark Early vs. Late training data for comparison
# n first days vs. n final days (prior to meeting criteria)

#copy above params
# #number of sessions to include as 'early' and 'late' (n+ 1 for the 0th session so n=4 would be 5 sessions)
# nSes= 4


# #stage at which to start reverse labelling of 'late' from last day of stage (not currently based on criteria label)
# # endStage= 7
# endStage= 5

#%% - TrainPhase label based on behavioral criteria!

#% Add trainPhase label for early vs. late training days within-subject

# #
# # dfTemp= df.copy()

# # ind= dfTemp.loc[dfTemp.criteriaSes==1 & (dfTemp.stage == endStage)]

## TODO: Limit "late" training sessions as prior to meeting criteria (not just the last stage) 
    
# #mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
# #this way can find easily and get last n sessions
# dfTemp= df.copy()

# dfGroup= dfTemp.loc[dfTemp.groupby('fileID').transform('cumcount')==0,:].copy() #one per session

# test= dfGroup.groupby(['subject','fileID','criteriaSes'], as_index=False)['trainDay'].count()



#- mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
#this way can find easily and get last n sessionsdfTemp= df.copy()
dfTemp= df.copy()

#instead of limiting to criteria days, simply start last n day count from final day of endStage
dfTemp= dfTemp.loc[dfTemp.criteriaSes==1]

# dfTemp= dfTemp.loc[dfTemp.stage==endStage]

#first fileIDs for each subject which meet criteria in the endStage
dfTemp= dfTemp.groupby(['subject']).first()#.index

#just get last fileID for each subj in endStage
# dfTemp= dfTemp.groupby(['subject']).last()#.index

ind= dfTemp.fileID


df.loc[df.fileID.isin(ind),'criteriaSes']= 2

#- now mark last n sessions preceding final criteria day as "late"

#subset data up to absolute criteria session

#get trainDay corresponding to absolute criteria day for each subject, then get n prior sessions and mark as late
dfTemp2= df.copy()

# dfTemp2=dfTemp2.set_index(['subject'])
#explicitly saving and setting on original index to prevent mismatching (idk why this was happening but it was, possibly something related to dfTemp having index on subject)
dfTemp2=dfTemp2.reset_index(drop=False).set_index(['subject'])


#-- something wrong here with lastTrainDay assignment
dfTemp2['lastTrainDay']= dfTemp.trainDay.copy()

dfTemp2= dfTemp2.reset_index().set_index('index')

#get dates within nSes prior to final day 
ind= ((dfTemp2.trainDay>=dfTemp2.lastTrainDay-nSes) & (dfTemp2.trainDay<=dfTemp2.lastTrainDay))


#label trainPhase as late
dfTemp2.loc[ind,'trainPhase']= 'late'

df['trainPhase']= dfTemp2['trainPhase'].copy()

#add reverse count of training days within late phase (countdown to final day =0)
dfTemp2.loc[ind,'trainDayThisPhase']= dfTemp2.trainDay-dfTemp2.lastTrainDay

df['trainDayThisPhase']= dfTemp2['trainDayThisPhase'].copy()

#- Now do early trainPhase for first nSes
#just simply get first nSes starting with 0
ind= df.trainDay <= nSes

df.loc[ind,'trainPhase']= 'early'


#TODO- in progress (indexing match up)
# add forward cumcount of training day within early phase 
#only save into early phase subset
ind= df.trainPhase=='early'

dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
df.loc[ind,'trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount') #add 1 for intuitive count
df.trainDayThisPhase= df.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()

#old; add corresponding days for each phase for plot x axes- old; simple cumcount
# dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# df['trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount')
# df.trainDayThisPhase= df.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()



#% 
# viz by day
test= subsetLevelObs(df,['fileID'])
test= test.loc[:,['fileID','subject','stage','trainPhase','trainDayThisPhase', 'criteriaSes']]#,'mpcDSpeRatio','mpcNSpeRatio']]




#%% ===== TrainPhase label based on last day of late 
# #%% Add trainPhase label for early vs. late training days within-subject

# # #
# # # dfTemp= df.copy()

# # # ind= dfTemp.loc[dfTemp.criteriaSes==1 & (dfTemp.stage == endStage)]

# ## TODO: Limit "late" training sessions as prior to meeting criteria (not just the last stage) 
    
# # #mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
# # #this way can find easily and get last n sessions
# # dfTemp= df.copy()

# # dfGroup= dfTemp.loc[dfTemp.groupby('fileID').transform('cumcount')==0,:].copy() #one per session

# # test= dfGroup.groupby(['subject','fileID','criteriaSes'], as_index=False)['trainDay'].count()



# #- mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
# #this way can find easily and get last n sessionsdfTemp= df.copy()
# dfTemp= df.copy()

# #instead of limiting to criteria days, simply start last n day count from final day of endStage
# # dfTemp= dfTemp.loc[dfTemp.criteriaSes==1]

# dfTemp= dfTemp.loc[dfTemp.stage==endStage]

# #first fileIDs for each subject which meet criteria in the endStage
# # dfTemp= dfTemp.groupby(['subject']).first()#.index

# #just get last fileID for each subj in endStage
# dfTemp= dfTemp.groupby(['subject']).last()#.index

# ind= dfTemp.fileID


# df.loc[df.fileID.isin(ind),'criteriaSes']= 2

# #- now mark last n sessions preceding final criteria day as "late"

# #subset data up to absolute criteria session

# #get trainDay corresponding to absolute criteria day for each subject, then get n prior sessions and mark as late
# dfTemp2= df.copy()

# # dfTemp2=dfTemp2.set_index(['subject'])
# #explicitly saving and setting on original index to prevent mismatching (idk why this was happening but it was, possibly something related to dfTemp having index on subject)
# dfTemp2=dfTemp2.reset_index(drop=False).set_index(['subject'])


# #-- something wrong here with lastTrainDay assignment
# dfTemp2['lastTrainDay']= dfTemp.trainDay.copy()

# dfTemp2= dfTemp2.reset_index().set_index('index')

# #get dates within nSes prior to final day 
# ind= ((dfTemp2.trainDay>=dfTemp2.lastTrainDay-nSes) & (dfTemp2.trainDay<=dfTemp2.lastTrainDay))


# #label trainPhase as late
# dfTemp2.loc[ind,'trainPhase']= 'late'

# df['trainPhase']= dfTemp2['trainPhase'].copy()

# #add reverse count of training days within late phase (countdown to final day =0)
# dfTemp2.loc[ind,'trainDayThisPhase']= dfTemp2.trainDay-dfTemp2.lastTrainDay

# df['trainDayThisPhase']= dfTemp2['trainDayThisPhase'].copy()

# #- Now do early trainPhase for first nSes
# #just simply get first nSes starting with 0
# ind= df.trainDay <= nSes

# df.loc[ind,'trainPhase']= 'early'


# #TODO- in progress (indexing match up)
# # add forward cumcount of training day within early phase 
# #only save into early phase subset
# ind= df.trainPhase=='early'

# dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# df.loc[ind,'trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount') #add 1 for intuitive count
# df.trainDayThisPhase= df.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()

# #old; add corresponding days for each phase for plot x axes- old; simple cumcount
# # dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# # df['trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount')
# # df.trainDayThisPhase= df.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()



# #% 
# # viz by day
# test= subsetLevelObs(df,['fileID'])
# test= test.loc[:,['fileID','subject','stage','trainPhase','trainDayThisPhase', 'criteriaSes','mpcDSpeRatio','mpcNSpeRatio']]


#%% ----  melt() 2 columns of PE probability into one by trialType
idVars= ['fileID','subject','stage','date', 'trainDay', 'trainDayThisStage', 'trainPhase', 'trainDayThisPhase']
df= df.melt(id_vars= idVars, value_vars=['mpcDSpeRatio','mpcNSpeRatio'], var_name='trialType', value_name='mpcPEratio')

trialOrder2=['mpcDSpeRatio','mpcNSpeRatio']

#%% ---- change dtypes
df.subject= df.subject.astype('string')
df.trialType= df.trialType.astype('category')
df.stage= df.stage.astype('int64')
df.trainDay= df.trainDay.astype('int64')
df.trainPhase= df.trainPhase.astype('category')

# convert subj to number (otherwise getting plot errors)
#just strip ID from end (last 2 in string)
subjects= df.subject.unique()

for subj in subjects:
    
    df.loc[df.subject==subj, 'subject']=  subj[-2:]
    
df.subject= df.subject.astype('int64')



#%%---- Exclude subjects

# subjectsToExclude= [10, 17]

# subjectsControl= [16, 20]

df= df[~df.subject.isin(subjectsToExclude)]

# df= df[~df.subject.isin(subjectsControl)]
    

#%% -----Plot MPC calculated values



#%% FINAL Figure1 MPC RAW mockup figure with subFigures and blank spaces for others
#Instead of using Figure-level FacetGrid, explicitly do subplots


# subset to one observation per trialType per file
ind= df.groupby(['fileID', 'trialType']).cumcount()==0

dfPlot= df.loc[ind]

# subset stages
# stagesToPlot= [1,2,3,4,5,6,7]
# dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)]


#--adjust seaborn context 
#adjust font size, need to call set() first or all in one (otherwise defaults reset)
sns.set(font_scale=0.8, font='arial')

sns.set_style('ticks')

#set palette
sns.set_palette(cmapCustomBlueGray)

trialOrder= ['mpcDSpeRatio', 'mpcNSpeRatio']


#adjust to make text save as editable- might prevent live drawing in spyder?
# https://stackoverflow.com/questions/5956182/cannot-edit-text-in-chart-exported-by-matplotlib-and-opened-in-illustrator
# matplotlib.rcParams['pdf.fonttype'] = 42
# matplotlib.rcParams['ps.fonttype'] = 42


#--make the figure with sub-figures
fig = plt.figure(constrained_layout=True, figsize=(figWidth, figHeight))

# subFigs = fig.subfigures(2, 2, wspace=0.0, hspace= 0.0) #minimal padding between subFigs

#-2023-01-05 make D wider with width_ratios

#todo this, make nested second row and use width_ratios
# subFigs = fig.subfigures(2, 2, wspace=0.0, hspace= 0.0, width_ratios=[1, 1, 1, 3]) #minimal padding between subFigs
subFigs = fig.subfigures(2, 1, wspace=0.0, hspace= 0.0) #minimal padding between subFigs

# make 2 subfigs in top row subfig
subFigsTop= subFigs[0].subfigures(1,2, width_ratios=[1,1])

#make 2 subfigs in bottom row subfig
subFigsNest = subFigs[1].subfigures(1, 2, width_ratios=[1, 3])


#leaving some varying gray in the other subfigure blanks for visible divisions
subFigsTop[0].set_facecolor('0.90')
subFigsTop[1].set_facecolor('0.85')
subFigsNest[0].set_facecolor('0.75')
subFigsNest[1].set_facecolor('1')

# add suptitles for each subfig
subFigsTop[0].suptitle('A')
subFigsTop[1].suptitle('B')
subFigsNest[0].suptitle('C')
subFigsNest[1].suptitle('D')


# Manually subset and plot trainPhases
# -Exclude null trainPhase (for this only include early/late)

ind=[]
ind= ~dfPlot.trainPhase.isnull()
dfPlot= dfPlot.loc[ind]


#within sub-figure[1,1] , create 2 subplots (1 for each trainPhase plot)
#within sub-figure D, create 2 subplots  (1 for each trainPhase plot)
fig1D = subFigsNest[1].subplots(1, 2, sharey=True, sharex=False)



#-make plots
#loop through to keep code concise
phasesToPlot= dfPlot.trainPhase.unique()

for thisPhase in range(len(phasesToPlot)):
    ind= dfPlot.trainPhase==phasesToPlot[thisPhase]
    dfPlot2= dfPlot.loc[ind,:].copy()
    
    g= sns.lineplot(data= dfPlot2, ax= fig1D[thisPhase], units='subject', estimator=None, x= 'trainDayThisPhase', y='mpcPEratio', hue='trialType', hue_order=trialOrder, alpha=alphaSubj, legend=False)
    g= sns.lineplot(data= dfPlot2, ax= fig1D[thisPhase], x= 'trainDayThisPhase', y='mpcPEratio', errorbar=errorBars, hue='trialType', hue_order=trialOrder, legend=False)
    fig1D[thisPhase].axhline(y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

    # g.set(title=('Reward-seeking in '+phasesToPlot[thisPhase] + ' training'))
    g.set(title=(phasesToPlot[thisPhase] + ' training'))


    # g.set(xlabel='Days from training start')

#-Adjust axes labels
fig1D[0].set(xlabel='Days from training start')
fig1D[1].set(xlabel='Days from training end')

fig1D[0].set(ylabel='Probability of port entry within 10s')


#- Save the figure
figName= 'Figure1D_Mockup_MPC_PEprob'

plt.savefig(savePath+figName+'.pdf')

# plt.savefig(savePath+figName+'.svg')
# plt.savefig(savePath+figName+'.eps')


# g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=linewidthRef, dashes=(3,1), zorder=0)

# g.add_legend()