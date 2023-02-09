# -*- coding: utf-8 -*-
"""
Created on Tue Aug 31 16:09:42 2021

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

dfTidy= pd.read_pickle(dataPath+'dfTidyFP.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% Plot settings
savePath= r'./_output/fpBehaviorAnalysis/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 


sns.set_style("darkgrid")
sns.set_context('notebook')

#fixed order of trialType to plot (so consistent between figures)
#for comparison of trial types (e.g. laser on vs laser off, good to have these in paired order for paired color palettes)
trialOrder= ['DStime','NStime','Pre-Cue', 'ITI']

#DS PE probability criteria (for visualization)
criteriaDS= 0.6

if experimentType.__contains__('Opto'):
    # trialOrder= ['laserDStrial_0', 'laserDStrial_1', 'laserNStrial_0', 'laserNStrial_1', 'Pre-Cue', 'ITI']
    # trialOrder= [trialOrder, 'laserDStrial_0', 'laserDStrial_1', 'laserNStrial_0', 'laserNStrial_1']
    trialOrder= (['DStime', 'DStime_laser', 'NStime', 'NStime_laser', 'Pre-Cue','ITI'])


# %% Exclude data

# #hitting memory cap, going to subset specific stages to reduce data 
stagesToInclude= [5.0, 6.0, 7.0]#, 8., 11.0, 12.0]

dfTidy= dfTidy.loc[dfTidy.stage.isin(stagesToInclude)]

# %% Exclude data- restrict to single/few files for quick debugging
# dfTidy=dfTidy[(dfTidy.fileID==58)] #fixed unclassified licks here


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

#%%-- Preliminary data analyses

# Add trainDay variable (cumulative count of sessions within each subject)
dfGroup= dfTidy.loc[dfTidy.groupby(['subject','fileID']).cumcount()==0]
# test= dfGroup.groupby(['subject','fileID']).transform('cumcount')
dfTidy.loc[:,'trainDay']= dfGroup.groupby(['subject'])['fileID'].transform('cumcount')
dfTidy.loc[:,'trainDay']= dfTidy.groupby(['subject','fileID']).fillna(method='ffill')

#Add cumulative count of training day within-stage (so we can normalize between subjects appropriately)
##very important consideration!! Different subjects can run different programs on same day, which can throw plots/analysis off when aggregating data by date.
dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
dfTidy['trainDayThisStage']=  dfGroup.groupby(['subject', 'stage']).transform('cumcount')
dfTidy.trainDayThisStage= dfTidy.groupby(['fileID'])['trainDayThisStage'].fillna(method='ffill').copy()


#%-- Add cumulative count of trials within- and between-stage (could be useful for viz of raw training data e.g. latency including every trial)

#subset to 1 obs per trial for counting
dfTemp= subsetLevelObs(dfTidy, groupHierarchyTrialID).copy()

#cumulative between-stage trialCount
dfTemp.loc[:,'trialCountThisSubj']= dfTemp.groupby(['subject']).transform('cumcount').copy()

#within-stage trialCount
dfTemp.loc[:,'trialCountThisStage']= dfTemp.groupby(['subject','stage']).transform('cumcount').copy()
            
#merge to save as new column in dfTidy
dfTemp= dfTemp.loc[:,groupHierarchyTrialID+['trialCountThisSubj']+['trialCountThisStage']]

dfTidy = dfTidy.merge(dfTemp, how='left', on=groupHierarchyTrialID).copy()

#%% - Mark Early vs. Late training data for comparison
# n first days vs. n final days (prior to meeting criteria)


#number of sessions to include as 'early' and 'late' (n+ 1 for the 0th session so n=4 would be 5 sessions)
nSes= 4


#stage at which to start reverse labelling of 'late' from last day of stage (not currently based on criteria label)
endStage= 7
# endStage= 5

#  %% ID, mark, and vizualize sessions with abnormal event counts
  
 
# #Unstack() the groupby output for a dataframe we can profile
# dfPlot= dfTidy.copy()
# dfPlot= dfPlot.groupby(['stage', 'subject', 'fileID', 'eventType'], observed=True)['eventTime'].count().unstack()
# #add trialType counts
# # dfPlot= dfPlot.merge(dfTidy.loc[(dfTidy.eventType=='NStime') | (dfTidy.eventType=='DStime')].groupby(['subject','date','trialType'])['eventTime'].count().unstack(),left_index=True,right_index=True)


# # dfPlot.boxplot()

# dfPlot= dfPlot.stack().reset_index(name='count')

# # dfPlot.plot(kind='scatter', x='fileID', y='count', c='eventType', colormap='tab10')
# # # dfPlot.plot.scatter()
 

# # #ind subj distros

# # def fixed_boxplot(*args, label=None, **kwargs):
# #     sns.boxplot(*args, **kwargs, labels=[label])

# for subj in dfPlot.subject.unique():
    
#     dfPlot2= dfPlot.loc[dfPlot.subject==subj]
    
#     # g= sns.FacetGrid(data=dfPlot2, col='eventType', sharex=True, sharey=False, hue='eventType')
    
#     # g.map_dataframe(fixed_boxplot, y='count')
    
#     # g.map_dataframe(sns.stripplot, y='count')
    
#     # line facet
#     #- want to see for each subject, counts over time across ses

    
        

    
#     #use stats to find outliers based on z score
#     from scipy import stats
    
#     #really need to compute z score for each file for each eventType
#     dfGroup= dfPlot2.groupby(['subject','eventType'])
#     z= dfGroup.apply(lambda x: (np.abs(stats.zscore(x['count']))))
#     # ^ returns one z score per eventType (same across files)
    
#     #instead try pivot() eventType and running z score by columns?
#     dfPlot2= dfPlot2.set_index(['fileID'])
#     dfTemp= dfPlot2.pivot(columns='eventType')['count'].copy()
    
#     #for zscore fxn, axis should = 0. Note if no variance will return nan even with nan_policy='omit'
#     z= np.abs(stats.zscore(dfTemp,axis=0, nan_policy='omit'))
    
#     # ind= z > zThresh

    
#     #melt()
#     #reset_index so fileID can be kept in melt
#     z= z.reset_index()
#     z2 = z.melt(id_vars= 'fileID', value_vars=z.columns, var_name='eventType', value_name='count').copy()

#     z2= z2.rename(columns= {'count':'zScore'})


#     #merge z score back into df
#     #merge on fileID, eventType
    
#     z2= z2.set_index(['fileID','eventType'])
#     dfPlot2= dfPlot2.reset_index().set_index(['fileID','eventType'])
    
#     dfPlot2['zScore']= z2.zScore

#     #mark 'outliers' exceeding zThreshold

#     zThresh=2

#     ind= dfPlot2.zScore > zThresh   

#     dfPlot2.loc[:,'outlier']= 0

#     dfPlot2.loc[ind,'outlier']= 1
    
#     dfPlot2.reset_index(inplace=True)
    
    
#     # make event count plots with facet of outlier status
#     # g= sns.FacetGrid(data=dfPlot2, col='eventType', hue='outlier', sharey=False)#, sharex=False, sharey=False)
#     g= sns.FacetGrid(data=dfPlot2, row='eventType', sharey=False)#, sharex=False, sharey=False)

#     g.map_dataframe(sns.scatterplot, x='fileID', y='count', hue='outlier', style='outlier')
#     g.map_dataframe(sns.lineplot, x='fileID', y='count', color='blue', alpha=0.3)


#     title= 'subject-'+str(subj)+'-eventCount-by-session'
#     g.fig.suptitle(title)
#     g.add_legend()
    
#     # saveFigCustom(g.fig, title, savePath)
    
#     # #==----==-=
    
#     # # dfPlot2.set_index(['subject','eventType'], inplace=True)
    
#     # # ind= (np.abs(stats.zscore(dfPlot2)) < 3).all(axis=1)]
    
#     # ##using groupby.apply()
    
#     # dfGroup= dfPlot2.groupby(['subject','eventType'])
#     # # dfGroup.apply(lambda x: stats.zscore(x['count']))


#     # #apply the zscore fxn to each group and check if exceeding threshold (3)    
#     # zThresh= 3
        
#     # ind= dfGroup.apply(lambda x: (np.abs(stats.zscore(x['count'])) > zThresh))
    
#     # dfPlot2.set_index(['subject','eventType'],drop=False, inplace=True)
    
#     # ind= ind.reset_index()
    
#     # # THESE are outliers for this subject.  
#     # ind2= ind[ind['count']==True]
    
    
    
#     # dfPlot2.loc[ind,'outlier']= 1
#     # # dfTemp.loc[ind,'outlier']= 1


    
#     # # this isn't grouping by eventType
#     # ind= (np.abs(stats.zscore(dfPlot2['count'])) < 3)#.all(axis=1)]
    
#     # dfPlot2.loc[ind, 'outlier']= 1
    
#     # # dfPlot2[(np.abs(stats.zscore(dfPlot2[0])) < 3), 'outlier']= 1

#     # g= sns.FacetGrid(data=dfPlot2, col='eventType', hue='eventType', sharey=False)#, sharex=False, sharey=False)

#     # g.map_dataframe(sns.scatterplot, x='fileID', y='count')

    
# # # subj facet
# # g= sns.FacetGrid(data=dfPlot, col='subject', col_wrap=4, hue='eventType')

# # g.map_dataframe(fixed_boxplot, x='eventType', y='count')

# # g.map_dataframe(sns.stripplot, x='eventType', y='count')

# # # #all subj
# # g= sns.FacetGrid(data=dfPlot, row='stage', col='eventType', hue='eventType', sharex=False, sharey=False)

# # g.map_dataframe(fixed_boxplot, x='eventType', y='count')

# # g.map_dataframe(sns.stripplot, x='eventType', y='count')



# # # #with fileID (to actually pinpoint outliers)
# # g= sns.FacetGrid(data=dfPlot, row='stage', col='eventType', hue='eventType')#, sharex=False, sharey=False)

# # g.map_dataframe(sns.lineplot, x='fileID', y='count')
# # g.map_dataframe(sns.scatterplot, x='fileID', y='count')



# # #STAGE FACET 
# # g= sns.FacetGrid(data=dfPlot, row='stage', hue='eventType')#, sharex=False, sharey=False)

# # g.map_dataframe(fixed_boxplot, x='eventType', y='count')

# # g.map_dataframe(sns.stripplot, x='eventType', y='count')


# # #line stage facet
# # g= sns.FacetGrid(data=dfPlot, row='stage', col='eventType', hue='eventType')#, sharex=False, sharey=False)

# # g.map_dataframe(sns.lineplot, x='fileID', y='count')


#  %% view distro of eventType counts per fileID for session outliers
  
# dfPlot= dfTidy.groupby(['subject', 'fileID', 'eventType'])['eventTime'].count().reset_index()


# g= sns.displot(data=dfPlot, col='eventType', x='eventTime', kind='hist', hue='eventType', multiple='dodge')
#                 # facet_kws={'sharey': False, 'sharex': True})
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('Total event count across sessions by type- check for outliers')

# %% View specific outliers

# outlierFiles= [82, 53, 157, 163, 387, 388, 424, 294]

# dfTemp= dfTidy.loc[dfTidy.fileID.isin(outlierFiles)]

# dfTemp= dfTemp[dfTemp.groupby(['fileID']).cumcount()==0]

# dfTemp= dfPlot.loc[dfPlot.fileID.isin(outlierFiles)]



#%% Add trainPhase label for early vs. late training days within-subject

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
dfTemp2=dfTemp2.reset_index(drop=False).set_index(['subject'])


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

#old; add corresponding days for each phase for plot x axes- old; simple cumcount
# dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# dfTidy['trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount')
# dfTidy.trainDayThisPhase= dfTidy.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()



#%% Event latency, count, and behavioral outcome for each TRIALID
# want to count all events within a trial (between this cue onset and next cue onset -1 timestamp)

dfTemp= dfTidy.copy()

#have trial start now, subtract trialStart from eventTime to get latency per trial
#no need for -trialID exception
dfTemp.loc[:,'eventLatency']= ((dfTemp.eventTime)-(dfTemp.trialStart)).copy()

#TODO: exception needs to be made for first ITI; for now fill w nan
dfTemp.loc[dfTemp.trialID== -999, 'eventLatency']= np.nan

#Count events in each trial 
#use cumcount() of event times within file & trial 

#converting to float for some reason
dfTemp['trialPE'] = dfTemp.loc[(dfTemp.eventType == 'PEtime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()


dfTemp['trialLick'] = dfTemp.loc[(dfTemp.eventType == 'lickTime')].groupby([
    'fileID', 'trialID']).cumcount().copy()

dfTemp['trialUS'] = dfTemp.loc[(dfTemp.eventType == 'UStime')].groupby([
    'fileID', 'trialID']).cumcount().copy()


dfTemp['trialLickUS'] = dfTemp.loc[(dfTemp.eventType == 'lickUS')].groupby([
    'fileID', 'trialID']).cumcount().copy()

#assign back to df
dfTidy= dfTemp.copy()


#%% DP 2022-11-18 define inPort trials 

# #2023-09-02 Flaw: assumes there's both a PE and out event. If there's no PEtime or out within 10s then there's n
# # first() returns nan and this inPort trial is missed - even when UStime is present.

# # ID trials where animal was inPort already at cue onset
# # In early versions of DS training code, reinforcement occurred if inPort at cue onset
# # so may want to exclude these trials


# #handled timestamps==cue onsets in fpImportDataTidy by sorting by trialID prior to assigning

# #may also consider out<PEtime && UStime present

# #now just need to check if inPort by seeing if port exit precedes port entry (is the closest timestamp a port entry or exit)
# # ~~alternatively could probably go based off UStime but want to mirror matlab 
# # so compare


# ## get the first eventTime for each eventType for each trial
# ## unstack and
# ## compare PEtime and out, if out occurs first, mark as inPort

# test= dfTidy.groupby(['fileID','trialID','eventType'])['eventTime'].first()

# # hitting an error here because of big dataframe in debug mode, pandas version specific...https://github.com/pandas-dev/pandas/issues/47069
# test2= test.unstack()

# ind= []
# ind= test2.out < test2.PEtime

# #a
# # ind= ind.values

# # test3= test2.reset_index();

# # test4= test3.loc[ind,:]

# # # #have the trials, now merge back into dfTidy

# # # test5= test4.set_index(['fileID','trialID'])

# # # dfTemp= dfTidy.set_index(['fileID','trialID'])

# # # dfTemp= dfTemp.merge(test5)

# #b- good
# #try with simply indexing 'fileID','trialID'
# #since this is the index of the groupby results, we can set index on these in dfTidy and assign variable accordingly

# ind= []
# ind= test2.out < test2.PEtime

# # dfTemp= dfTidy.set_index(['fileID','trialID'])

# # dfTemp.loc[ind,'inPort']= 1

# # dfTemp.reset_index(inplace=True)

# dfTidy.set_index(['fileID','trialID'], inplace=True)

# dfTidy.loc[ind,'inPort']= 1

# dfTidy.reset_index(inplace=True)



# # test= dfTidy.columns

# # #id events that happen before or at trial start
# # test= dfTidy.loc[dfTidy.eventTime-dfTidy.trialStart<=0]

# # test2= test.loc[test.fileID==test.fileID.min()]

# # sns.relplot(data=test2, x='eventTime', y='trialID', hue='eventType')


# # test2= test.copy()
# # sns.relplot(data=test2, x='eventTime', y='fileID', hue='eventType')


# #finding lots of UStime, some PEtime, some lickTime

# # #latency is not exactly 0 for some reason there are very small differences
# # test= dfTidy.loc[dfTidy.eventLatency==0]

# # test= dfTidy.loc[dfTidy.eventLatency.round()==0]

# # test2= test.loc[test.fileID==test.fileID.min()]


# # sns.relplot(data=test2, x='eventTime', y='trialID', hue='eventType')


# #they're included in the cumcount() of events
# #eg trialUS, trialPE, trialLick

# #TODO: lick cleaning mirroring matlab

#%% TODO: Lick cleaning

# # exclude licks on a trial-by-trial basis if animal is not 'inPort' when licks

# #- subset trials where not 'inPort'

# dfTemp= dfTidy.loc[dfTidy.inPort!=1].copy()

# #- get first PE time for each trial, compare lick times against this
# test= dfTidy.groupby(['fileID','trialID','eventType'])['eventTime'].first()


# # If not an InPort trial, Delete licks with latency < PE

# # test= dfTidy.groupby(['fileID','trialID','eventType'])['eventTime'].first()

# # test2= test.unstack()

# # ind= []
# # ind= test2.lox < test2.PEtime

# # %if this IS an inPort trial, keep the raw pre-PE licks (since they may still be valid)

# # ind= []
# # ind= dfTidy.inPort==1

# # test= dfTidy[ind & dfTidy.eventType=='lickTime']


#%% Count events within 10s of cue onset (cue duration in final stage)  
#this is mainly for comparing progression/learning between stages since cueDuration varies by stage

dfTemp=  dfTidy.loc[((dfTidy.eventLatency<= 10) & (dfTidy.eventLatency>0))].copy()

dfTidy['trialPE10s'] = dfTemp.loc[(dfTemp.eventType == 'PEtime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

dfTidy['trialLick10s'] = dfTemp.loc[(dfTemp.eventType == 'lickTime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

#%% Define behavioral (pe,lick) outcome for each trial within first 10s of each trial

## TODO: consider limiting this to cueDur instead of 10s since stages vary and may want to examine ~~~~~~~~

outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialPE10s'].nunique()

#naming "trialOutcomeBeh" for now to distinguish between behavioral outcome and reward outcome if needed later
#10s = within 10s of epoch start
trialOutcomeBeh= outcome.copy()

trialOutcomeBeh.loc[outcome>0]='PE'
trialOutcomeBeh.loc[outcome==0]='noPE'

#now do the same for licks
outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialLick10s'].nunique()

#add lick outcome + PE outcome for clarity #if it doesn't say '+lick', then none was counted
trialOutcomeBeh.loc[outcome>0]=trialOutcomeBeh.loc[outcome>0]+ '+' + 'lick'

#set index to file,trial and
#fill in matching file,trial with trialOutcomeBeh
#TODO: I think there is a more efficient way to do this assignment, doens't take too long tho

# dfTidy= dfTidy.reset_index().set_index(['fileID','trialID'])

dfTidy= dfTidy.set_index(['fileID','trialID'])


dfTidy.loc[trialOutcomeBeh.index,'trialOutcomeBeh10s']= trialOutcomeBeh

# reset index to eventID
dfTidy= dfTidy.reset_index().set_index(['eventID'])
# dfTidy.reset_index(inplace=True)

# dp comment out 2023-02-09
# # overwrite inPort outcomes (determined in section above)
# ind= dfTidy.inPort==1

# # dfTidy.loc[ind,'trialOutcomeBeh']= 'inPort'+dfTidy.trialOutcomeBeh
# dfTidy.loc[ind,'trialOutcomeBeh10s']= 'inPort+'+dfTidy.trialOutcomeBeh10s

# # #drop inPort column (redundant now)
# dfTidy= dfTidy.drop(['inPort'], axis=1)


#%% Calculate probability of behavioral outcome within first 10s of trial 

# #duplicated below after trialID revision, so getting rid of this?

# #This is normalized so is more informative than simple count of trials. 

# #calculate Proportion of trials with PE out of all trials for each trial type
# #can use nunique() to get count of unique trialIDs with specific PE outcome per file
# #given this, can calculate Probortion as #PE/#PE+#noPE
   
# #subset data and save as intermediate variable dfGroup
# #get only one entry per trial
# dfGroup= dfTidy.loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0].copy()

# #for Lick+laser sessions, retain only trials with PE+lick for comparison (OPTO specific)
# # dfGroup.loc[dfGroup.laserDur=='Lick',:]= dfGroup.loc[(dfGroup.laserDur=='Lick') & (dfGroup.trialOutcomeBeh=='PE+lick')].copy()
   
# dfPlot= dfGroup.copy() 

# #for each unique behavioral outcome, loop through and get count of trials in file
# #fill null counts with 0
# dfTemp=dfPlot.groupby(
#         ['fileID','trialType','trialOutcomeBeh10s'],dropna=False)['trialID'].nunique(dropna=False).unstack(fill_value=0)


# ##calculate proportion for each trial type: num trials with outcome/total num trials of this type

# trialCount= dfTemp.sum(axis=1)


# outcomeProb= dfTemp.divide(dfTemp.sum(axis=1),axis=0)

# #melt() into single column w label
# dfTemp= outcomeProb.reset_index().melt(id_vars=['fileID','trialType'],var_name='trialOutcomeBeh10s',value_name='outcomeProbFile10s')

# #assign back to df by merging
# #TODO: can probably be optimized. if this section is run more than once will get errors due to assignment back to dfTidy
# dfTidy.reset_index(inplace=True) #reset index so eventID index is kept

# dfTidy= dfTidy.merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh10s'])#.copy()


# # dfTidy= dfTidy.reset_index().merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh10s']).copy()




#%%-- ADD EPOCS prior to revising trialID

#----- dp 2023-02-08 TODO: this is based on eventTime and for FP should be based on cutTime since eventTimes mostly nan but FP signal occurs continuously!!  

#add epoch column
#for now could be as simple as reversing trialID transformations for ITI+Pre-Cue, will make current ITIs fall within same trialID
dfTidy.loc[:,'epoch']= dfTidy.loc[:,'trialType'].copy()
  #%% Add Cue Post-Cue (post-PE) epoch (within cue duration, was there a PE)

#specifying as Cue-PE (since this is limiting to PEs during cue epoch)

#post-cue epoc = post-PE

#-- set epoch at pump on times, then fillna() within certain time window surrounding epoch

refEvent= 'PEtime' #reference event surrounding which we'll define epochs

epocName= 'cue-postPE'

dfTidy.epoch.cat.add_categories([epocName], inplace=True)


#prefill with na so we can just use ffill() method to fill nulls in time window
dfTemp= dfTidy.copy()
dfTemp.loc[:,'epoch']= pd.NA


#Assign Post-Cue epoch between PE timestamp and Pre-Cue -1

#in sum, want epoch between PE DURING CUE (rewarded PE) and PreCue for next trial
# TODO: could specify postPErewarded; postPEunrewarded but not necessary

#starting with these epochs: DStime (cue onset:cue onset+cueDur), ITI (trialEnd:nextTrialStart-10), Pre-Cue (nextTrialStart-10)
# UStime (UStime:UStime+postEventTime)

# go in,subset data within trial (no Pre-Cue, only PEs during cue) 

#assign PE timestamp as postPE epoc start
#then we can groupby() trialID and ffill nans as post-PE

#subset- dont include first trial
# dfTemp= dfTemp.loc[dfTemp.trialID!=999]

#dont include pre-cue time
# dfTemp = dfTemp.loc[dfTemp.trialType!='Pre-Cue']


# dfTemp.loc[dfTemp.eventType==refEvent,'epoch']= epocName

#simply restrict to actual trials
dfTemp= dfTemp.loc[dfTemp.trialID>=0]

#replace PE times during cue with new epoc name
dfTemp.loc[dfTemp.eventType==refEvent, 'epoch']= epocName

# dfTemp.loc[dfTemp.trialType!='Pre-Cue', 'epoch']= epocName



fs= 40 #40hz = sampling frequency
preEventTime= 0*fs #x seconds before refEvent; don't count any before refEvent
# postEventTime= 2*fs # x seconds after refEvent  

#ffill will only fill null values!
# restricting to trialID 
dfTemp.epoch= dfTemp.groupby(['fileID', 'trialID'])['epoch'].ffill().copy()

# test= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.min()].copy()
# test.loc[dfTemp.epoch.notnull(),'epoch']= dfTemp.epoch.copy()

#assign back to df
dfTemp= dfTemp.loc[dfTemp.epoch.notnull()]

dfTidy.loc[dfTemp.index,'epoch']= dfTemp.epoch.copy()

del dfTemp

# #Specify ITIs corresponding to this trial now as post-PE ITIs
# dfTemp= dfTidy.copy()

# #find trials with post-PE epoch, get corresponding ITI trialID, change this epoch 
# # trials= dfTemp.loc[dfTemp.epoch==epocName, 'trialID'].unique()

# # trials= dfTemp.groupby(['fileID','trialID'])['epoch'].any(dfTemp.epoch==epocName)

# # trials= dfTemp.groupby(['fileID','trialID']).apply(lambda x: (x['epoch']==epocName))

# # lambda fxn here is quick way to check with groupby()
# trials= dfTemp.groupby(['fileID','trialID']).apply(lambda x: (x.epoch==epocName).any())
 

#   df.groupby('Group')
#     .apply(lambda x: (x['Value1'].eq(7).any() 

# for group, name in dfTemp.groupby(['fileID']):
#     trials= group.loc[group.epoch==epocName]


# trials= dfTemp.groupby(['fileID','trialID'])['epoch'].any(epocName)

# trials= 

# dfTidy.loc[dfTidy]

#%% viz epocs
dfPlot= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()].copy()

#signal with epochs + vertical lines at event times
# g= sns.relplot(data= dfPlot, x= 'eventTime', y='reblue', hue='epoch')

fig, ax= plt.subplots()
# sns.lineplot(axes= ax, data= dfPlot, x= 'eventTime', y='reblue', hue='epoch', dropna=False) #retain gaps (dropna=False)
# sns.scatterplot(axes= ax, data= dfPlot, x= 'eventTime', y='reblue', hue='epoch')


ax.vlines(x=dfPlot.loc[dfPlot.eventType=='UStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='UStime', color='g')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='DStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='DStime', color='b')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='NStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='NStime', color='k')

# ax.vlines(x=dfPlot.loc[dfPlot.eventType=='PEtime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='PEtime', color='gray')

ax.legend()


#%% ---------------------------------------- TRIALID REVISION -------------

#%%-- Revise TrialID and Epocs

#convert trials trials to be all time from cue onset: next cue start, with 'Cue','Reward','ITI','Pre-Cue' epocs? 

# #for now as simple as reversing trialID transformations for ITI+Pre-Cue, will make current ITIs fall within same trialID

#make ITI trialIDs positive again, make Pre-Cues corresponding integers
dfTidy.loc[dfTidy.trialType=='ITI','trialID']= dfTidy.trialID*-1
dfTidy.loc[dfTidy.trialType=='Pre-Cue','trialID']= (dfTidy.trialID+0.5)*-1

#overwrite old ITI & Pre-Cue trialTypes with first of this trial
dfTidy.trialType= dfTidy.copy().groupby(['fileID','trialID'])['trialType'].transform('first')

# dfTidy.trialType= dfTidy.groupby(['fileID','trialID'])['trialType'].cumcount()==0

#%% Specify ITIs with/without postPE if appropriate

#TODO: could make more specific/efficient probably based on trialOutcomeBeh col

#Specify ITIs corresponding to this trial now as post-PE ITIs
#find trials with epoc we're searching for
epocName= 'cue-postPE'

# dfTidy.epoch.cat.add_categories(['ITI-'+epocName], inplace=True)

dfTidy.epoch= dfTidy.epoch.astype(str)
dfTemp= dfTidy.copy()

#skip first ITI
dfTemp= dfTemp.loc[dfTemp.trialID!=999]


trials= dfTemp.groupby(['fileID','trialID'])['epoch'].transform(lambda x: (x==epocName).any())

trials= trials.loc[trials==True]

ind= ((trials) & (dfTemp.epoch=='ITI'))

dfTemp.loc[ind, 'epoch']= dfTemp.epoch+'-'+'postPE'


#label remaining ITIs as noPE    
# dfTidy.epoch.cat.add_categories(['ITI-noPE'], inplace=True)

dfTemp.loc[dfTemp.epoch=='ITI', 'epoch']= dfTemp.epoch+'-noPE'

#merge back into df
dfTidy.loc[dfTemp.index,'epoch'] = dfTemp.epoch.copy()

dfTidy.epoch= dfTidy.epoch.astype('category')


#%% Add reward epochs & refine postPE vs post-US

#convert everything between UStime epoch and pre-cue epoch as post-US

#currently have gaps of cue-postPE between UStime and ITI-postPE
#want to convert all of these and post-PE-ITIs to 'post-US' e.g. to count licks here as reward licks 

#should operate solely on actual US timestamp (don't trust that epochs are correct)
dfTidy.epoch= dfTidy.epoch.astype(str)
dfTemp= dfTidy.copy()
dfTemp= dfTemp.loc[dfTemp.trialID!=999]

refEvent= 'UStime'


#find UStime for each trial (if exists), then do simple timestamp check if prior or after UStime
#returns boolean
# dfTemp['UStime']=  dfTemp.groupby(['fileID','trialID']).transform(lambda x: (x.loc[x.eventType==refEvent,'eventTime']))
dfTemp['UStime']=  dfTemp.groupby(['fileID','trialID'])['eventType'].transform(lambda x: x==refEvent)

#convert to timestamp and ffill() within trial
dfTemp['UStime']= dfTemp.loc[dfTemp.UStime, 'eventTime']

dfTemp['UStime']= dfTemp.groupby(['fileID','trialID'])['UStime'].ffill()

#check if ts is after UStime within-trial. If so, update epoch
##don't replace immediate UStime timestamps for now
## dfTemp= dfTemp.loc[dfTemp.epoch != 'UStime']

ind= (dfTemp.eventTime>=dfTemp.UStime)

dfTemp.loc[ind, 'epoch']= dfTemp.epoch+'-'+'postUS'

#--also specify actual reward pump on window

preEventTime= 0 #x seconds before refEvent; don't count any before refEvent
postEventTime= 2# x seconds after refEvent (pump is on for 2s) 

#ffill will only fill null values!
ind= ((dfTemp.eventTime>=dfTemp.UStime)&(dfTemp.eventTime<=dfTemp.UStime+postEventTime))

dfTemp.loc[ind,'epoch']= 'UStime'



#assign back to df
dfTidy.loc[dfTemp.index, 'epoch']= dfTemp.epoch.copy()
dfTidy.epoch= dfTidy.epoch.astype('category')


#%% viz epocs
dfPlot= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()].copy()

#signal with epochs + vertical lines at event times
# g= sns.relplot(data= dfPlot, x= 'eventTime', y='reblue', hue='epoch')

fig, ax= plt.subplots()
# sns.lineplot(axes= ax, data= dfPlot, x= 'eventTime', y='reblue', hue='epoch', dropna=False) #retain gaps (dropna=False)
# sns.scatterplot(axes= ax, data= dfPlot, x= 'eventTime', y='reblue', hue='epoch')


ax.vlines(x=dfPlot.loc[dfPlot.eventType=='UStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='UStime', color='g')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='DStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='DStime', color='b')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='NStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='NStime', color='k')

# ax.vlines(x=dfPlot.loc[dfPlot.eventType=='PEtime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='PEtime', color='gray')

ax.legend()


#%% viz epocs

dfPlot= dfTidy.loc[dfTidy.fileID==16].copy()
# dfPlot= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()].copy()

fig, ax= plt.subplots()
# sns.scatterplot(axes= ax, data= dfPlot, x= 'eventTime', y='reblue', hue='epoch')


ax.vlines(x=dfPlot.loc[dfPlot.eventType=='UStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='UStime', color='g')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='DStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='DStime', color='b')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='NStime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='NStime', color='k')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickPreUS', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickPreUS', color='pink')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickPostUS', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickPostUS', color='maroon')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickUS', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickUS', color='gold')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickTime', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickTime', color='gray')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='PEcue', 'eventTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='PEcue', color='red')


ax.legend()


#%%-- Conduct trial-based analyses AFTER  revising trialID

#%% DP 2022-12-1 define inPort trials post trial revision

# ID trials where animal was inPort already at cue onset
# In early versions of DS training code, reinforcement occurred if inPort at cue onset
# so may want to exclude these trials


#handled timestamps==cue onsets in fpImportDataTidy by sorting by trialID prior to assigning

#may also consider out<PEtime && UStime present

#now just need to check if inPort by seeing if port exit precedes port entry (is the closest timestamp a port entry or exit)
# ~~alternatively could probably go based off UStime but want to mirror matlab 
# so compare

#- also instead of going by eventTime could use eventLatency and then compare against cueDur to help determine outcome too

## get the first eventTime for each eventType for each trial
## unstack and
## compare PEtime and out, if out occurs first, mark as inPort

dfTidy['inPort']= None


dfTemp= dfTidy.groupby(['fileID','trialID','eventType'])['eventTime'].first()

dfTemp2= dfTemp.unstack()

# A few cases to mark here:
# marking with distinct numbers for clearer debugging later
    
#-- note that currently this is based on eventTime (NOT LATENCY DEPENDENT)

# 1- if Out is recorded before PE. But assumes both timestamps are present
#but it misses cases where for example no PE is recorded
ind= []
ind= dfTemp2.out < dfTemp2.PEtime

dfTemp3= dfTemp2.iloc[np.where(ind)]

#- set index of dfTidy on fileID, trialID to mark trials matching index 
dfTidy.set_index(['fileID','trialID'], inplace=True)

dfTidy.loc[ind,'inPort']= 1

# 2- If out is recorded but PE isn't... 
# had like 66 trials like this prior 2023-02-09
ind=[]
ind= (dfTemp2.out.notnull()) & (dfTemp2.PEtime.isnull())

dfTemp3= dfTemp2.iloc[np.where(ind)]

dfTidy.loc[ind,'inPort']= 2

# 3 here is redundant with first 2
# 3- UStime is recorded but PE isn't ? this is too specific to older DS task code... should really base things on US outcome and then do more nuanced latency-based definitions
# this will only apply to DS trials too
ind= []
ind= (dfTemp2.UStime.notnull()) & (dfTemp2.PEtime.isnull())

dfTemp3= dfTemp2.iloc[np.where(ind)]

#- is this redundant vs the prior 1/2?
ind1= dfTemp2.out < dfTemp2.PEtime
ind2= (dfTemp2.out.notnull()) & (dfTemp2.PEtime.isnull())
ind3= (dfTemp2.UStime.notnull()) & (dfTemp2.PEtime.isnull())

# get the True values (file,trial) meeting condition 3, see if they're also true in 1 and 2
indTest= ind3.index[ind3==True]


# check if each of these #3 trials are in either of the prior 2. Remaining False are not.
test= ((ind1[indTest]) | (ind2[indTest]))

indNew= indTest[np.where(test==False)]

#these are the trials unique to case 3 (UStime but no PE. some also have no Out)
dfTemp4= dfTemp2.loc[indNew]

# Mark only these explicitly as 3
ind= []
ind= indNew
dfTidy.loc[ind,'inPort']= 3


#- Reset index after assignment
dfTidy.reset_index(inplace=True)



# # #todo- reviewing trials
# # test4= dfTidy.loc[ind,:]


# #a
# # ind= ind.values

# # test3= test2.reset_index();

# # test4= test3.loc[ind,:]

# # # #have the trials, now merge back into dfTidy

# # # test5= test4.set_index(['fileID','trialID'])

# # # dfTemp= dfTidy.set_index(['fileID','trialID'])

# # # dfTemp= dfTemp.merge(test5)

# #b- good
# #try with simply indexing 'fileID','trialID'
# #since this is the index of the groupby results, we can set index on these in dfTidy and assign variable accordingly

# ind= []
# ind= test2.out < test2.PEtime

# # dfTemp= dfTidy.set_index(['fileID','trialID'])

# # dfTemp.loc[ind,'inPort']= 1

# # dfTemp.reset_index(inplace=True)

# # dfTidy.set_index(['fileID','trialID'], inplace=True)

# # dfTidy['inPort']= None

# # dfTidy.loc[ind,'inPort']= 1

# dfTidy.reset_index(inplace=True)


#%% Count events within 10s of cue onset (cue duration in final stage)  
#this is mainly for comparing progression/learning between stages since cueDuration varies by stage


#TODO: dp 2022-05-06 consider changing to latency >= 0 since PEs in early DS training resulted in reinforcement and should count?
     #problem is more complex tho bc if they were in the port at all they would be reinforced. 
dfTemp=  dfTidy.loc[((dfTidy.eventLatency<= 10) & (dfTidy.eventLatency>0))].copy()

dfTidy['trialPE10s'] = dfTemp.loc[(dfTemp.eventType == 'PEtime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

dfTidy['trialLick10s'] = dfTemp.loc[(dfTemp.eventType == 'lickTime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

#%% Define behavioral (pe,lick) outcome for each trial  within first 10s of each trial
outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialPE10s'].nunique()

#naming "trialOutcomeBeh" for now to distinguish between behavioral outcome and reward outcome if needed later
#10s = within 10s of epoch start
trialOutcomeBeh= outcome.copy()

trialOutcomeBeh.loc[outcome>0]='PE'
trialOutcomeBeh.loc[outcome==0]='noPE'

#now do the same for licks
outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialLick10s'].nunique()

#add lick outcome + PE outcome for clarity #if it doesn't say '+lick', then none was counted
trialOutcomeBeh.loc[outcome>0]=trialOutcomeBeh.loc[outcome>0]+ '+' + 'lick'

#set index to file,trial and
#fill in matching file,trial with trialOutcomeBeh
#TODO: I think there is a more efficient way to do this assignment, doens't take too long tho

dfTidy= dfTidy.reset_index().set_index(['fileID','trialID'])

dfTidy.loc[trialOutcomeBeh.index,'trialOutcomeBeh10s']= trialOutcomeBeh

#reset index to eventID
# dfTidy= dfTidy.reset_index().set_index(['eventID'])

dfTidy.reset_index(inplace=True)
# dfTidy.set_index(['eventID'], inplace=True)

#dp 2023-02-08 review specific example
test2= dfTidy.loc[(dfTidy.fileID==58) & (dfTidy.trialID==21)]

#2022-12-1
# overwrite inPort outcomes (determined in section above)
ind= dfTidy.inPort.notnull()

# dfTidy.loc[ind,'trialOutcomeBeh']= 'inPort'+dfTidy.trialOutcomeBeh
dfTidy.loc[ind,'trialOutcomeBeh10s']= 'inPort+'+dfTidy.trialOutcomeBeh10s

# #drop inPort column (redundant now)
dfTidy= dfTidy.drop(['inPort'], axis=1)

# debugging event classification on these trials
test= dfTidy[((dfTidy.trialOutcomeBeh10s.str.contains('inPort') )& (dfTidy.trialType=='DStime'))]
test= test[test.eventTime.notnull()]

#%%--- VIZ events in trials by outcome - DS only... reviewing prior to encoding model
dfPlot= dfTidy[dfTidy.trialType=='DStime']

dfPlot= dfPlot[dfPlot.eventTime.notnull()]

#cumcount of trialIDs between subj
trialIDpooled= dfPlot.groupby(['fileID', 'trialID'])['trialID'].cumcount()
# dfTemp = dfTemp.loc[dfTemp.groupby(['fileID','trialID']).cumcount() == 0].copy()

ind= dfPlot.groupby(['fileID','trialID']).cumcount() == 0

dfTemp= dfPlot.loc[ind]

#make 1 and then use cumsum() to cumulatively count series (cumcount seems limited to groupbys)
dfTemp.loc[ind,'trialIDpooled']= 1; 

dfTemp['trialIDpooled']= dfTemp.trialIDpooled.cumsum()

dfPlot.loc[ind, 'trialIDpooled'] = dfTemp.trialIDpooled

# dfTidy.loc[:, 'trialIDpooled'] = dfTemp['trialID'].transform('cumcount') #dfTidy.groupby(['fileID','trialID']).transform('cumcount')

dfPlot.loc[:, 'trialIDpooled'] = dfPlot.groupby(['fileID','trialID'])['trialIDpooled'].fillna(method='ffill')


# --combine/flatten 'lick' eventTypes that were redefined as valid, prior to cumcount
dfPlot.eventType= dfPlot.eventType.astype('str')

dfPlot.loc[dfPlot.eventType.isin(['lickPreUS','lickUS']), 'eventType']= 'lickValid'

#subset to 1 observation per eventType per trial
dfPlot= dfPlot[dfPlot.groupby(['trialIDpooled','eventType']).cumcount()==0]

# remove unusued categories for faceting
# dfPlot.eventType= dfPlot.eventType.cat.remove_unused_categories()

# sns.relplot(data= dfPlot, col= 'trialOutcomeBeh10s', kind='scatter', x='eventLatency', y='trialIDpooled', hue='eventType' )
# sns.displot(data= dfPlot, col= 'trialOutcomeBeh10s', kind='hist', x='eventLatency', hue='eventType' )
#pretty good
sns.displot(data= dfPlot, col= 'eventType', kind='hist', x='eventLatency', hue='trialOutcomeBeh10s' )

#want clear view of count of event types by outcome (to make sure i can filter by outcome for encoding model)
# sns.catplot(data= dfPlot, col= 'trialOutcomeBeh10s', kind='count', x='eventType', hue='eventType' )
# sns.catplot(data= dfPlot, kind='count', x='eventType', hue='trialOutcomeBeh10s' )
sns.catplot(data= dfPlot, kind='count', x='trialOutcomeBeh10s', hue='eventType' )




# sns.catplot(data= dfPlot, kind='count', x='trialOutcomeBeh10s', hue='eventType' )


#- TODO: Include trials with at least 1 of each event



#%% Calculate Probability of behavioral outcome for each trial type. 
#This is normalized so is more informative than simple count of trials. 

#calculate Proportion of trials with PE out of all trials for each trial type
#can use nunique() to get count of unique trialIDs with specific PE outcome per file
#given this, can calculate Probortion as #PE/#PE+#noPE
   
#subset data and save as intermediate variable dfGroup
#get only one entry per trial
ind= dfTidy.groupby(['fileID','trialID']).cumcount()==0

dfGroup= dfTidy.loc[ind].copy()

# dfGroup= dfTidy.loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0].copy()

#for Lick+laser sessions, retain only trials with PE+lick for comparison (OPTO specific)
# dfGroup.loc[dfGroup.laserDur=='Lick',:]= dfGroup.loc[(dfGroup.laserDur=='Lick') & (dfGroup.trialOutcomeBeh=='PE+lick')].copy()
   
dfPlot= dfGroup.copy() 

#for each unique behavioral outcome, loop through and get count of trials in file
#fill null counts with 0
dfTemp=dfPlot.groupby(
        ['fileID','trialType','trialOutcomeBeh10s'],dropna=False)['trialID'].nunique(dropna=False).unstack(fill_value=0)


##calculate proportion for each trial type: num trials with outcome/total num trials of this type

trialCount= dfTemp.sum(axis=1)


outcomeProb= dfTemp.divide(dfTemp.sum(axis=1),axis=0)

#melt() into single column w label
dfTemp= outcomeProb.reset_index().melt(id_vars=['fileID','trialType'],var_name='trialOutcomeBeh10s',value_name='outcomeProbFile10s')

#assign back to df by merging
#TODO: can probably be optimized. if this section is run more than once will get errors due to assignment back to dfTidy

# dfTidy= dfTidy.reset_index().merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh10s']).copy()

dfTidy.reset_index(inplace=True) #reset index so eventID index is kept

dfTidy= dfTidy.merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh10s'])#.copy()


# dfTidy.set_index(['eventID'], inplace=True)



#%% dp 2022-05-04 10s PE probablility 


#% Calculate PE probability for each trialType
#(combines all outcomes with PE vs all outcomes with no PE)

dfTemp= dfTidy.copy()


# declare hierarchical grouping variables (how should the observations be separated)
groupHierarchy = groupHierarchyTrialType


# here want percentage of each behavioral outcome per trialType per above groupers
colToCalc = 'trialOutcomeBeh10s'

dfTemp= percentPortEntryCalc(dfTemp, groupHierarchy, colToCalc)

dfTemp= dfTemp.reset_index()

dfTemp= dfTemp.rename(columns= {'PE':'trialTypePEProb10s'})

dfTidy= dfTidy.merge(dfTemp, how='left', on=groupHierarchy)


#%%-- Refine eventTypes after trial analyses


#%% Refine Lick eventTypes: Separate anticipatory/non-reward from reward/consumption licks

# #isolate licks occuring during 'reward' epoch, redefine as new eventType

# basic assumption here is that reward is consumed by the next trial
# this should leave lickTimes during pre-cue I think as unspecified

# reset/overwrite with unclassified for debugging
dfTidy.loc[dfTidy.eventType.str.contains('lick')==True, 'eventType']= 'lickTime'


dfTidy.eventType= dfTidy.eventType.astype(str)

dfTemp= dfTidy.loc[dfTidy.eventType.str.contains('lick')==True].copy()


#TODO: NS licks should have another name?
#there won't be an actual UStime in these trials to have equivalent epochs but could add estimate above and go that way?
dfTemp.loc[((dfTemp.trialType=='NStime') & ((dfTemp.epoch=='NStime') | (dfTemp.epoch=='cue-postPE'))), 'eventType']= 'lickNS'


#some flexibiilty for preUS licks
# dfTemp.loc[((dfTemp.epoch=='DStime')|(dfTemp.epoch=='NStime') | (dfTemp.epoch=='cue-postPE')), 'eventType']= 'lickPreUS'
dfTemp.loc[((dfTemp.trialType=='DStime') & ((dfTemp.epoch=='DStime')| (dfTemp.epoch=='cue-postPE'))), 'eventType']= 'lickPreUS'

# dp 2023-02-07 ITI postPE licks aren't being counted properly as lickPreUS using above... given late PE at like 9.2s, lick at 10.1s, UStime at 10.2s . kept as "lickTime" undefined but should be lickPreUS
# add a quick exception for these remaining unclassified licks- if in ITI-postPE epoch and trialOutcome is PE, count as lickPreUS

# #viz some examples
# test= dfTemp.loc[((dfTemp.trialType=='DStime') & (dfTemp.epoch=='ITI-postPE'))]
# test2= dfTidy.loc[(dfTidy.fileID==58) & (dfTidy.trialID==21)]

dfTemp.loc[((dfTemp.trialType=='DStime') & ((dfTemp.trialOutcomeBeh10s=='PE') | (dfTemp.trialOutcomeBeh10s=='PE+lick')) & (dfTemp.epoch=='ITI-postPE')), 'eventType']= 'lickPreUS'

#  What about inPort trials?

#some flexibility for postUS licks
#just defining these as lickUS also so should be guranteeed to capture first reward licks (that is the most important)
# dfTemp.loc[dfTemp.epoch.str.contains('postUS'), 'eventType']= 'lickPostUS'

dfTemp.loc[dfTemp.epoch.str.contains('postUS'), 'eventType']= 'lickUS'


dfTemp.loc[(dfTemp.epoch=='UStime'), 'eventType']= 'lickUS'

# currently leaves very late licks (in precue period for next trial) unclassified as simply 'lickTime'

#--TODO: Clean licks prior to PE 
# exclude licks on a trial-by-trial basis if animal is not 'inPort' when licks

#review possible epochs / outcomes
test= dfTemp.epoch.cat.categories
test2= dfTemp.trialOutcomeBeh10s.unique()

#review remaining unclassified licks (on DS trials only; NS trials are still not well defined)
test3= dfTemp.loc[(dfTemp.eventType=='lickTime') &( dfTemp.trialType=='DStime')]
#expect remaining on noPE trials, so check for others
test4= test3.loc[(test3.trialOutcomeBeh10s!='noPE')]


#review specific trials with issue
# test4= dfTidy.loc[(dfTidy.fileID==58) & (dfTidy.trialID==21)] #fixed
test4= dfTidy.loc[(dfTidy.fileID==294) & (dfTidy.trialID==48)]


# licks shouldn't be counted if in

# ?? is lickPreUS equivalent to matlab cleaned licks? no

#- subset trials where not 'inPort'



#distinguish between PEs that occur within cue epoch (should be rewarded if DS trial) and those that occur after?


#merge back into df
dfTidy.loc[dfTemp.index, 'eventType']= dfTemp.eventType.copy()

dfTidy.eventType= dfTidy.eventType.astype('category')

#review specific trials with issue post eventType reclassification
# test5= dfTidy.loc[(dfTidy.fileID==58) & (dfTidy.trialID==21)]

#%% Refine PE eventType to PEcue
dfTidy.eventType= dfTidy.eventType.astype(str)

dfTemp= dfTidy.loc[dfTidy.eventType.str.contains('PE')].copy()

#note will be guranteed cue-postPE epoch since defined by first PE in cue
# dfTemp.loc[((dfTemp.epoch=='DStime')|(dfTemp.epoch=='NStime')| (dfTemp.epoch=='cue-postPE')), 'eventType']= 'PEcue'

#updated 2022-03-18 dp
dfTemp.loc[dfTemp.eventLatency<dfTemp.cueDur, 'eventType']= 'PEcue'



#merge back into df
dfTidy.loc[dfTemp.index, 'eventType']= dfTemp.eventType.copy()

dfTidy.eventType= dfTidy.eventType.astype('category')


#%% Save dfTidy so it can be loaded quickly for subesequent analysis

dfTidyAnalyzed= dfTidy.copy()

savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

print('saving dfTidyAnalyzed to file')

#Save as pickel
dfTidyAnalyzed.to_pickle(savePath+'dfTidyAnalyzed.pkl')


# Save as .CSV
# dfTidyAnalyzed.to_csv('dfTidyAnalyzed.csv')


#update metadata and save 

eventVars= dfTidy.eventType.unique()

saveVars= ['idVars', 'contVars', 'eventVars', 'trialVars', 'experimentType']

#use shelve module to save variables as dict keys
my_shelf= shelve.open(savePath+'dfTidyMeta', 'n') #start new file

for key in saveVars:
    try:
        my_shelf[key]= globals()[key] 
    except TypeError:
        #
        # __builtins__, my_shelf, and imported modules can not be shelved.
        #
        print('ERROR shelving: {0}'.format(key))
my_shelf.close()




#%% --PLOTS:
    
# #%% Plot event counts across sessions (check for outlier sessions/event counts)
# sns.set_palette('tab20')  #good for plotting by many subj


# #I know that lick count was absurdly high (>9000) due to liquid shorting lickometer on at least 1 session
# #visualize event counts by session to ID outliers
# #not interested in some events (e.g. # cues is fixed), remove those
# dfPlot= dfTidy.loc[(dfTidy.eventType!='NStime') & (dfTidy.eventType!='DStime') & (dfTidy.eventType!='PExEst') & (dfTidy.eventType!='laserOffTime')].copy()

# #count of each event type by date and subj
# dfPlot= dfPlot.groupby(['subject','trainDay', 'eventType'])['eventTime'].count().reset_index()

# g= sns.relplot(data=dfPlot, col='eventType', x='trainDay', y='eventTime', hue='subject', kind='line', style='subject', markers=True, dashes=False,
#                 facet_kws={'sharey': False, 'sharex': True})
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('Total event count across sessions by type- check for outliers')
# g.set_ylabels('# of events')
# g.set_xlabels('session')

# saveFigCustom(g, 'individual_eventCounts_line')

 #view boxplot of eventType counts per fileID for session outliers
# dfPlot= dfTidy.groupby(['subject', 'fileID', 'eventType'])['eventTime'].count().reset_index()

# g= sns.catplot(data=dfPlot, x='eventType', y='eventTime', kind='box', hue='subject',
#                 facet_kws={'sharey': False, 'sharex': True})
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('Total event count across sessions by type- check for outliers')
# g.set_ylabels('# of events')
# g.set_xlabels('session')

#  #view distro of eventType counts per fileID for session outliers
# dfPlot= dfTidy.groupby(['subject', 'fileID', 'eventType'])['eventTime'].count().reset_index()

# g= sns.displot(data=dfPlot, col='eventType', x='eventTime', kind='hist', hue='eventType', multiple='dodge')
#                 # facet_kws={'sharey': False, 'sharex': True})
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('Total event count across sessions by type- check for outliers')


# #%% Plot PE probability by trialType (within 10s of trial start)
# sns.set_palette('Paired') #default  #tab10
# #subset data and save as intermediate variable dfGroup
# dfGroup= dfTidy.copy()
 

# #moving higher in code
# # #cumulative count of training day within-stage (so we can normalize between subjects appropriately)
# # dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# # dfTidy['trainDayThisStage']=  dfGroup.groupby(['subject', 'stage']).transform('cumcount')
# # dfTidy.trainDayThisStage= dfTidy.groupby(['fileID'])['trainDayThisStage'].fillna(method='ffill').copy()




# #select data
# #all trialTypes excluding ITI     
# # dfPlot = dfGroup[(dfGroup.trialType != 'ITI')].copy()

# #all trialTypes excluding ITI     
# # dfPlot = dfGroup[(dfGroup.trialType != 'ITI') & (dfGroup.trialType !='Pre-Cue')].copy()
# # trialOrderPlot= ['DStime','DStime_laser','NStime','NStime_laser']

# #Only DS & NS trialTypes
# dfGroup= dfTidy.copy()
# dfPlot = dfGroup[(dfGroup.trialType == 'DStime') | (dfGroup.trialType =='NStime')].copy()
# trialOrderPlot= ['DStime','NStime']

#%% Training plot for manuscript...

# #dp 1/15/22 error for fp data
# # #define stages for 'early' and 'late' subplotting
# # #TODO: consider groupby() stage and counting day within each stage to get the first x sessions of stage 5 compared to last?
# # earlyStages= ['Stage 1','Stage 2','Stage 3','Stage 4', 'continuous reinforcement', 'RI 15s',' RI 30s']
# # lateStages= ['Stage 5', 'Stage 5+tether', 'RI 60s']
# # # earlyStages= ['Stage 4']
# # # lateStages= ['Stage 5+tether']
# # testStages= ['Cue Manipulation', 'test']
# # dfPlot['stageType']= pd.NA #dfPlot.stage.astype('str').copy()

# # dfPlot.loc[dfPlot.stage.isin(earlyStages), 'stageType']= 'early'
# # dfPlot.loc[dfPlot.stage.isin(lateStages), 'stageType']= 'late'
# # dfPlot.loc[dfPlot.stage.isin(testStages), 'stageType']= 'test'

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
 
# dfPlot['probPE']= dfPlot.groupby(['fileID','trialType'])['outcomeProbFile10s'].sum().copy()

# #get an aggregated x axis for files per subject
# fileAgg= dfPlot.reset_index().groupby(['subject','fileID','trialType']).cumcount().copy()==0
 
# #since grouping PE and PE+lick, we still have redundant observations
# #retain only 1 per trial type per file
# dfPlot= dfPlot.reset_index().loc[fileAgg]

# #subjects may run different session types on same day (e.g. different laserDur), so shouldn't plot simply by trainDayThisStage across subjects
# #individual plots by trainDayThisStage is ok
# # sns.set_palette('Paired')

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
#                , facet_kws={'sharey': True, 'sharex': False}, palette= 'tab10')
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# saveFigCustom(g, 'training_peProb_10s_early_vs_late_trainDay')


# #training across stages
# #%% define specific stages to plot!
# stagesToPlot= pd.Series(dfTidy.loc[dfTidy.stage.notnull(),'stage'].unique())
# stagesToPlot= stagesToPlot.loc[((stagesToPlot.str.contains('5')) | (stagesToPlot.str.contains('Manipulation')))]

# dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)].copy()
# dfPlot.stage= dfPlot.stage.cat.remove_unused_categories()


# # #define specific trialTypes to plot!
# # trialTypesToPlot= pd.Series(dfTidy.loc[dfTidy.trialType.notnull(),'trialType'].unique())
# # trialTypesToPlot= trialTypesToPlot.loc[((trialTypesToPlot.str.contains('DS')) | (trialTypesToPlot.str.contains('NS')))]

# # dfPlot= dfPlot.loc[dfPlot.trialType.isin(trialTypesToPlot)]
# # dfPlot.trialType= dfTidy.trialType.cat.remove_unused_categories()

# #late stages only
# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# g.fig.suptitle('Evolution of the probPE in subjects by trialType')
# saveFigCustom(g, 'training_peProb_10s_lateStages_individual')

# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# g.fig.suptitle('Evolution of the probPE in subjects by trialType')
# saveFigCustom(g, 'training_peProb_10s_lateStages_individual_trainDay')


# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', row='stage', col='virus', hue='trialType', hue_order=trialOrder, kind='line', style='virus', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# saveFigCustom(g, 'training_peProb_10s_lateStages_virus')


# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', row='stage', col='virus', hue='trialType', hue_order=trialOrder, kind='line', style='virus', markers=True, dashes=True)
# g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# saveFigCustom(g, 'training_peProb_10s_lateStages_virus_trainDay')

# # g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', row='trialType', hue='virus', kind='line', style='virus', markers=True, dashes=False)
# # g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

# #individual subj lines
# # g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='probPE', row='trialType', units='subject', estimator=None, hue='virus', kind='line', style='stage', markers=True, dashes=False, palette='tab10')
# # g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)
# # g.fig.suptitle('Evolution of the probPE in subjects by trialType')


# #% TODO: ECDF of behavioral outcome (PE) would be nice to view compared to latency ECDFs?

# #%% Plot PE latency by trialType
            
# #select data corresponding to first PE from valid trials, excluding ITI
# dfPlot = dfTidy[(dfTidy.trialType!='ITI') & (dfTidy.trialPE10s == 0)].copy()

# # PE latency: virus
# g = sns.displot(data=dfPlot, x='eventLatency', hue='trialType',
#                 row='virus', kind='ecdf', hue_order= trialOrder)
# g.fig.suptitle('First PE latency by trial type')
# g.set_ylabels('First PE latency from epoch start (s)')
# saveFigCustom(g, 'virus_peLatency_10s_ecdf')

#   #PE latency:  individual subj 
# g=sns.displot(data=dfPlot, col='subject', col_wrap=4, x='eventLatency',hue='trialType', kind='ecdf', hue_order=trialOrder)
# g.fig.suptitle('First PE latency by trial type (within 10s)')
# g.set_ylabels('Probability: first PE latency from epoch start')
# saveFigCustom(g, 'individual_peLatency_10s_ecdf')


#  #training across stages
# dfPlot.eventLatency= dfPlot.eventLatency.astype('float') #TODO: correct dtypes early in code

# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='eventLatency', col='subject', col_wrap=4, hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.fig.suptitle('Evolution of first PE latency by trialType')
# saveFigCustom(g, 'training_peLatency_10s_individual')


# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='eventLatency', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.fig.suptitle('Evolution of first PE latency by trialType')
# saveFigCustom(g, 'training_peLatency_10s_virus+sex')


# # late stages plots
# dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)]

# g = sns.displot(data=dfPlot, x='eventLatency', hue='trialType',
#                 row='virus', col='stage', kind='ecdf', hue_order= trialOrder)
# g.fig.suptitle('First PE latency by trial type, late stages')
# g.set_ylabels('Probability: first PE latency from epoch start')
# saveFigCustom(g, 'dist_peLatency_10s_lateStages_virus_ecdf')


# g= sns.relplot(data=dfPlot, x='trainDayThisStage', y='eventLatency', row='virus', hue='trialType', hue_order=trialOrder, kind='line', style='stage', markers=True, dashes=True)
# g.fig.suptitle('Evolution of first PE latency by trialType, late stages')
# saveFigCustom(g, 'training_peLatency_10s_lateStages_virus')




# #%% TODO: Custom Ridge Plot to show changes in distribution over time

# # # Initialize the FacetGrid object
# # pal = sns.cubehelix_palette(10, rot=-.25, light=.7)
# # # g = sns.FacetGrid(dfPlot, row="trainDayThisStage", hue="trainDayThisStage", col='subject', aspect=15, height=10, palette=pal)
# # g = sns.FacetGrid(dfPlot, row="trainDayThisStage", hue="trainDayThisStage", col='subject')#, aspect=15, height=10, palette=pal)


# # # Draw the densities in a few steps
# # g.map(sns.kdeplot, "eventLatency",
# #       bw_adjust=.5, clip_on=False,
# #       fill=True, alpha=1, linewidth=1.5)
# # # g.map(sns.kdeplot, "eventLatency", clip_on=False, color="w", lw=2, bw_adjust=.5)

# # # passing color=None to refline() uses the hue mapping
# # # g.refline(y=0, linewidth=2, linestyle="-", color=None, clip_on=False)


# # # Define and use a simple function to label the plot in axes coordinates
# # def label(x, color, label):
# #     ax = plt.gca()
# #     ax.text(0, .2, label, fontweight="bold", color=color,
# #             ha="left", va="center", transform=ax.transAxes)


# # g.map(label, "eventLatency")

# # # Set the subplots to overlap
# # # g.figure.subplots_adjust(hspace=-.25)

# # # Remove axes details that don't play well with overlap
# # g.set_titles("")
# # g.set(yticks=[], ylabel="")
# # g.despine(bottom=True, left=True)


# #%% Plot First lick latencies (time from cue or trialEnd if ITI events) by trialType (within 10s)
# # should represent "baseline" behavior  without laser
      
# #trial-based, ignoring ITI
# dfPlot = dfTidy[(dfTidy.trialType !='ITI')].copy()
# #trial-based, including ITI
# # dfPlot= dfTidy.copy()

# #All subj distribution of ILI (inter-lick interval)
# #only include first trialLick ==0
# dfPlot = dfPlot[dfPlot.trialLick10s==0].copy()

# #box- all subj
# g= sns.catplot(data=dfPlot, y='eventLatency', x='trialType',  kind='box', order=trialOrder)
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('First Lick latencies by trial type; all subj')
# g.set_ylabels('lick latency from epoch start (s)')
# saveFigCustom(g, 'all_lickLatency_10s_box')



# #ecdf- all subj'[]
# g= sns.displot(data=dfPlot, x='eventLatency', hue='trialType',  kind='ecdf', hue_order=trialOrder)
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('First Lick latencies by trial type; all subj')
# g.set_xlabels('lick latency from epoch start (s)')
# saveFigCustom(g, 'all_lickLatency_10s_ecdf')



# #Individual distribution of ILI (inter-lick interval)
# #only include trialLick~=nan 
# #bar- individual subj
# g= sns.catplot(data=dfPlot, y='eventLatency', x='subject', hue='trialType',  kind='bar', hue_order=trialOrder)
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('First Lick latencies by trial type; individual subj')
# g.set_ylabels('lick latency from epoch start (s)')
# saveFigCustom(g, 'individual_lickLatency_10s_bar')


    
# # %% Plot inter-lick interval (ILI) by trialType (within 10s)

# #trial-based, ignoring ITI
# dfPlot = dfTidy[(dfTidy.trialType!= 'ITI')].copy()
# #trial-based, including ITI
# # dfPlot = dfTidy.copy()

# #All subj distribution of ILI (inter-lick interval)
# #only include trialLick~=nan (lick timestamps within trials)
# dfPlot = dfPlot[dfPlot.trialLick10s.notnull()].copy()

# #calculate ILI by taking diff() of latencies
# ili= dfPlot.groupby(['fileID','trialID','trialType'])['eventLatency'].diff()

# #ecdf- all subj
# g= sns.displot(data=dfPlot, x=ili, hue='trialType',  kind='ecdf', hue_order=trialOrder)
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('ILI by trial type; all subj')
# g.set_xlabels('ILI (s)')
# g.set(xlim=(0,1))
# saveFigCustom(g, 'all_ILI_ecdf')



# #Individual distribution of ILI (inter-lick interval)
# #only include trialLick~=nan
# dfPlot = dfPlot[dfPlot.trialLick10s.notnull()].copy()
# #calculate ILI by taking diff() of latencies
# ili= dfPlot.groupby(['fileID','trialID','trialType'])['eventLatency'].diff()
# #bar- individual subj
# g= sns.catplot(data=dfPlot, y=ili, x='subject', hue='trialType',  kind='bar', hue_order=trialOrder)
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('ILI by trial type; individual subj')
# g.set_ylabels('ILI (s)')
# g.set(ylim=(0,1))
# saveFigCustom(g, 'individual_ILI_10s_bar')


# #%% trying stuff with data hierarchy grouping

#   # by_many<- group_by(py_data, virus, sex, stage, laserDur, subject, fileID, trialType, trialOutcomeBeh10s)

# groupers= ['virus','sex','stage','laserDur', 'subject', 'trainDayThisStage', 'trialType']

# #hierarchy should be something like groupVars -> stageVars -> subjVars-> sessionVars -> trainDayThisStage -> fileID -> trialType/trialVars -> trialID -> eventVars

# #seems that the grouping here is using all possible combos (e.g. creating entries for F Sex even for subjects that are M)
# dfGroup= dfTidy.copy().groupby(['virus','sex','stage','laserDur', 'subject', 'trainDayThisStage', 'trialType'])

# #observed=True parameter only includes observed categories
# # dfGroup= dfTidy.copy().groupby(['virus','sex','stage','laserDur', 'subject', 'trainDayThisStage', 'trialType'], observed=True)


# dfGroupComp= pd.DataFrame()
# dfGroupComp['trialCount']= dfGroup['trialID'].nunique()
# dfGroupComp.reset_index(inplace=True)

# # dfGroupComp2= dfTidy.copy()
# # dfGroupComp2['trialCount']= dfGroup['trialID'].transform('nunique')


# sns.catplot(data= dfGroupComp, row='virus', col='sex', x='stage', y='trialCount', hue='trialType', hue_order=trialOrder, kind='bar')


# #^this was just example, now do something more relevant to behavior analysis

# dfGroup= dfTidy.copy().groupby(['virus','sex','stage','laserDur', 'subject', 'trainDayThisStage', 'trialType'])

# dfGroupComp= pd.DataFrame()
# # dfGroupComp['outcomeBehCount']= dfGroup['trialOutcomeBeh10s'].value_counts()
# # dfGroupComp['outcomeBehCount']= dfGroup['trialOutcomeBeh10s'].transform(pd.Series.mode)
# # dfGroupComp['outcomeBehCount']= dfGroup['trialOutcomeBeh10s'].transform(dfTidy.trialOutcomeBeh10s.mode)


# # dfGroupComp.reset_index(inplace=True)


# # sns.catplot(data= dfGroupComp, row='virus', col='sex', x='trialOutcomeBeh10s', y='outcomeBehCount', hue='trialType', hue_order=trialOrder, kind='bar')


# #^ can calculate proportion more efficiently?
# # dfGroup= dfTidy.copy().groupby(['virus','sex','stage','laserDur', 'subject', 'trainDayThisStage', 'trialType'])

# #subset to one event per trial, then groupby()
# dfGroup= dfTidy.copy().loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0].groupby(groupers)

# dfGroupComp= pd.DataFrame()
# dfGroupComp['trialCount']= dfGroup['trialID'].nunique()
# dfGroupComp= dfGroupComp.reset_index(drop=False).set_index(groupers)



# dfGroupComp2= pd.DataFrame()
# dfGroupComp2['outcomeBehCount']= dfGroup['trialOutcomeBeh10s'].value_counts()
# dfGroupComp2= dfGroupComp2.reset_index(drop=False).set_index(groupers)

# #issue now would be dividing appropriately with non-unique index
# #could try using transform() operation?
# # dfGroupComp2['outcomeProb']= dfGroupComp2.outcomeBehCount/dfGroupComp.trialCount

# #do division while indexed by groupers, then reset index for reassignment of result
# outcomeProb= dfGroupComp2.outcomeBehCount/dfGroupComp.trialCount



# #can imagine doing peri-event analyses like so
# dfGroup= dfTidy.copy().groupby(['virus','sex','stage','laserDur', 'subject', 'trainDayThisStage', 'trialType', 'eventType'])

# dfGroupComp= pd.DataFrame()
# dfGroupComp['eventOnsets']= dfGroup['eventTime'].value_counts()


# # # %% 12/9/21 trying proportion fxn with groupby- not worth it probably, just use crosstabs below
# # # df['sales'] / df.groupby('state')['sales'].transform('sum')

# # groupers= ['virus','sex','stage','laserDur', 'subject', 'trainDayThisStage', 'trialType']#, 'eventType']

# # #subset to one event per trial per file
# # dfTemp= dfTidy.copy().loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0]

# # #now groupby
# # dfGroup= dfTemp.groupby(groupers)
# # # dfGroup= dfTemp.groupby(groupers, as_index=False)

# # test= dfGroup['trialID'].count().reset_index(name ='countThisTrialType')
# # # 
# # # dfTemp['countThisTrialType']= dfGroup['trialID'].transform('count')

# # # def groupPercentCalc(dfGrouped, columnToCalc)
    


# #%%  12/8/21 working on proportion fxn

# #example1 might work for binary coded outcomes but not ideal
# # df_overdue = df.groupby(['org']).apply(lambda dft: pd.Series({'is_overdue': dft.is_overdue.sum(), 'not_overdue': (~dft.is_overdue).sum()}))
# # df_overdue['proportion_overdue'] = df_overdue['is_overdue'] / (df_overdue['not_overdue'] + df_overdue['is_overdue'])

# # # print(df_overdue)
# # df_overdue = dfTidy.groupby(groupers).apply(lambda dft: pd.Series({'thisOutcome': dft.trialOutcomeBeh10s.sum()}))

# # # df_overdue = dfTidy.groupby(groupers).apply(lambda dft: pd.Series({'thisOutcome': dft.trialOutcomeBeh10s.sum(), 'notThisOutcome': (~dft.trialOutcomeBeh10s).sum()}))
# # df_overdue['proportion_overdue'] = df_overdue['is_overdue'] / (df_overdue['not_overdue'] + df_overdue['is_overdue'])

# # print(df_overdue)

# # example2 with crosstab
# # d = {
# #   'id': [1, 2, 3, 4, 5], 
# #   'is_overdue': [True, False, True, True, False],
# #   'org': ['A81001', 'A81002', 'A81001', 'A81002', 'A81003']
# # }
# # df = pd.DataFrame(data=d)

# # result = pd.crosstab(index=df['org'], columns=df['is_overdue'], margins=True)
# # result = result.rename(columns={True:'is_overdue', False:'not overdue'})
# # result['proportion'] = result['is_overdue']/result['All']*100
# # print(result)
# # result = pd.crosstab(index=dfTidy[groupers], columns=dfTidy['trialOutcomeBeh10s'], margins=True)
# # result = pd.crosstab(index=groupers, columns=dfTidy['trialOutcomeBeh10s'], margins=True)


# #First we need to subset only one outcome per trial
# dfGroup= dfTidy.loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0].copy()

# #declare hierarchical grouping variables
# groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'trainDayThisStage', 'trialType']

# #let's make a variable to remember our hierarchical index for crosstabs, just because this works a bit differently than other methods
# #array of columns
# #TODO: could automate this by looping through groupers and adding to list
# xTabInd= []
# for grouper in groupers:
#     # xTabInd2= np.append(xTabInd2, pd.Series([dfGroup[grouper]])) 
#     # xTabInd2= 
#     # xTabInd2.append(pd.Series([dfGroup[grouper]])) 
#     xTabInd.append(dfGroup[grouper]) 


# # xTabInd= [dfGroup['virus'],dfGroup['sex'],dfGroup['stage'],dfGroup['laserDur'],
# # dfGroup['subject'],dfGroup['trainDayThisStage'], dfGroup['trialType']]

# # result= pd.crosstab(index=xTabInd, columns=dfTidy['trialOutcomeBeh10s'], margins=True)

# # result = result.rename(columns={True:'is_overdue', False:'not overdue'})
# # result['proportion'] = result['is_overdue']/result['All']*100
# # print(result)


# #%% ex3- Works pretty well!
# # pd.crosstab(df['Approved'],df['Gender']).apply(lambda r: r/r.sum(), axis=1)
# # set margins=False so that a summed "All" column/row aren't created
# result= pd.crosstab(index=xTabInd, columns=dfGroup['trialOutcomeBeh10s'], margins=False)

# result2= result.apply(lambda r: r/r.sum(), axis=1)

# #above method should be identical to results if we crosstab with Normalize across rows
# #so the lambda function in this case isn't actually necessary
# result0= pd.crosstab(index=xTabInd, columns=dfGroup['trialOutcomeBeh10s'], margins=False, normalize='index')

# print(all(result2==result0))

# #now we've calculated proportion appropriately based on hierarchical structure,
# #could go even further and group/aggregate based on groupers?

# #between subjects (remove groupby subj)
# #could calculate a between subjects mean using groupby .mean()
# groupersNoSubj= ['virus', 'sex', 'stage', 'laserDur', 'trainDayThisStage', 'trialType']
# #including only observed groups here
# result3= result0.groupby(groupers, observed=True).mean()

# result4= result3.reset_index()

# g= sns.relplot(data=result4, x='trainDayThisStage', y='PE', hue='trialType', hue_order=trialOrder, kind='line', row='stage')
# g.fig.suptitle('testing crosstab aggregation')

# #next step could be to merge back into dataframe?
# dfTidy2= dfTidy.merge(result0, on=groupers).copy()

# #combine the PE outcomes
# dfTidy2['PEsum']=dfTidy2['PE']+dfTidy2['PE+lick']

# #subsample for specific plotting/analysis
# dfPlot= dfTidy2.loc[dfTidy2.stage=='Cue Manipulation'].copy()
# dfPlot= dfPlot.loc[dfPlot.trialType!='ITI']

# #again we need to isolate observations since this is a single measure aggregated per trialType per file
# dfPlot= dfPlot.loc[dfPlot.groupby(['fileID','trialType']).cumcount()==0]

# # g= sns.relplot(data=dfPlot, units='subject', estimator=None, x='trainDayThisStage', y='PEsum', row='virus', hue='trialType', hue_order=trialOrder, kind='line') 
# g= sns.relplot(data=dfPlot, x= 'trainDayThisStage', y='PEsum', row='virus', hue='trialType', hue_order=trialOrder, kind='line')
# g.fig.suptitle('testing merged crosstab results')

# #now let's look aggregated across all laserDur
# g= sns.catplot(data=dfPlot, x= 'laserDur', y='PEsum', row='virus', hue='trialType', hue_order=trialOrder, kind='point')
# g.fig.suptitle('testing merged crosstab results')

# # dfGroup['trialOutcomeBeh10s'].transform('count')

# # dfGroupComp.reset_index(inplace=True, drop=False)
# # outcomeProb= outcomeProb.reset_index().copy()

# # dfGroupComp['outcomeProb']= outcomeProb.copy()

# #%% 12/9/21 Turn above into function
# #seems to be a good template for building more custom functions later on

# def groupPercentCalc(df, levelOfAnalysis, groupHierarchy, colToCalc):
#     #First we need to subset only one observation per level of analysis
#     dfSubset= df.loc[df.groupby(levelOfAnalysis).cumcount()==0].copy()
      
#     #build a list of groupers to be used as hierarchical index for crosstabs, just because this works a bit differently than other methods
#     xTabInd= []
#     for grouper in groupHierarchy:
#         xTabInd.append(dfSubset[grouper]) 
    
#     result= pd.crosstab(index=xTabInd, columns=dfSubset[colToCalc], margins=False, normalize='index')
#     return result


# #Example:
# #behavioralOutcome/trialType: out of all vtrials of this trialType, how many had this observed behavioral outcome?

# #First we need to subset only one outcome per trial
# dfGroup= dfTidy.loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0].copy()

# #declare hierarchical level of analysis for the analysis we are doing (here there is one outcome per trial per file)
# level= ['fileID','trialID']

# #declare hierarchical grouping variables (how should the observations be separated)
# groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'trainDayThisStage', 'trialType']

# #here want percentage of each behavioral outcome per trialType per above groupers
# observation= 'trialOutcomeBeh10s'


# test= groupPercentCalc(dfTidy, level, groupers, observation)

# #%% 12/9/21 custom fxn for calculating probability of Port entry 


# def percentPortEntryCalc(df, groupHierarchy, colToCalc):
#     #First we need to subset only one observation per level of analysis
#     dfSubset= df.loc[df.groupby(['fileID','trialID']).cumcount()==0].copy()
      
#     #build a list of groupers to be used as hierarchical index for crosstabs, just because this works a bit differently than other methods
#     xTabInd= []
#     for grouper in groupHierarchy:
#         xTabInd.append(dfSubset[grouper]) 
    
#     #combine all outcomes with PE before making crosstab and running calculation
#     dfSubset.loc[((dfSubset[colToCalc]=='PE') | (dfSubset[colToCalc]=='PE+lick')),colToCalc]= 'PE'
#     dfSubset.loc[((dfSubset[colToCalc]=='noPE') | (dfSubset[colToCalc]=='noPE+lick')),colToCalc]= 'noPE'

    
#     result= pd.crosstab(index=xTabInd, columns=dfSubset[colToCalc], margins=False, normalize='index')
        
#     return result

# #Example:

# #declare hierarchical grouping variables (how should observations be separated)
# # groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'trainDayThisStage', 'trialType'] #Opto
# groupers= ['virus', 'sex', 'stage', 'subject', 'trainDayThisStage', 'trialType'] #Photometry


# #here want percentage of each behavioral outcome per trialType per above groupers
# observation= 'trialOutcomeBeh10s'

# test= percentPortEntryCalc(dfTidy, groupers, observation)

# #test visualization
# dfPlot= test.reset_index().copy()
# g= sns.relplot(data=dfPlot, x= 'trainDayThisStage', y='PE', row='stage', hue='trialType', hue_order=trialOrder, kind='line')
# g.fig.suptitle('PE probability: testing function results')


# #%% Illustration of groupby() calculations based on date vs trainDayThisStage vs normalized trainDay hierarchies

# # #declare hierarchical grouping variables (how should observations be separated)
# # # groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'date', 'trialType'] #Opto
# # groupers= ['virus', 'sex', 'stage', 'subject', 'date', 'trialType'] #photometry


# # #here want percentage of each behavioral outcome per trialType per above groupers
# # observation= 'trialOutcomeBeh10s'

# # test= percentPortEntryCalc(dfTidy, groupers, observation)

# # #test visualization
# # dfPlot= test.reset_index().copy()
# # g= sns.relplot(data=dfPlot, x= 'date', y='PE', row='stage', hue='trialType', hue_order=trialOrder, kind='line')
# # g.fig.suptitle('PE probability: computed by date')


# # #declare hierarchical grouping variables (how should observations be separated)
# # # groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'trainDay', 'trialType'] #Opto
# # groupers= ['virus', 'sex', 'stage', 'subject', 'trainDay', 'trialType'] #photometry


# # #here want percentage of each behavioral outcome per trialType per above groupers
# # observation= 'trialOutcomeBeh10s'

# # test= percentPortEntryCalc(dfTidy, groupers, observation)

# # #test visualization
# # dfPlot= test.reset_index().copy()
# # g= sns.relplot(data=dfPlot, x= 'trainDay', y='PE', row='stage', hue='trialType', hue_order=trialOrder, kind='line')
# # g.fig.suptitle('PE probability: computed by raw trainDay')


# # #declare hierarchical grouping variables (how should observations be separated)
# # # groupers= ['virus', 'sex', 'stage', 'laserDur', 'subject', 'trainDayThisStage', 'trialType'] #Opto
# # groupers= ['virus', 'sex', 'stage', 'subject', 'trainDayThisStage', 'trialType'] #photometry


# # #here want percentage of each behavioral outcome per trialType per above groupers
# # observation= 'trialOutcomeBeh10s'

# # test= percentPortEntryCalc(dfTidy, groupers, observation)

# # #test visualization
# # dfPlot= test.reset_index().copy()
# # g= sns.relplot(data=dfPlot, x= 'trainDayThisStage', y='PE', row='stage', hue='trialType', hue_order=trialOrder, kind='line')
# # g.fig.suptitle('PE probability: computed by normalized trainDayThisStage')


# #%% Save dfTidy so it can be loaded quickly for subesequent analysis

# dfTidyAnalyzed= dfTidy.copy()

# savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

# print('saving dfTidyAnalyzed to file')

# #Save as pickel
# dfTidyAnalyzed.to_pickle(savePath+'dfTidyAnalyzed.pkl')


# # Save as .CSV
# # dfTidyAnalyzed.to_csv('dfTidyAnalyzed.csv')


#%% Use pandas profiling on event counts
##This might be a decent way to quickly view behavior session results/outliers if automated
## note- if you are getting errors with ProfileReport() and you installed using conda, remove and reinstall using pip install

# from pandas_profiling import ProfileReport

# #Unstack() the groupby output for a dataframe we can profile
# dfPlot= dfTidy.copy()
# dfPlot= dfPlot.groupby(['stage', 'subject', 'fileID','eventType'], observed=True)['eventTime'].count().unstack()
# #add trialType counts
# # dfPlot= dfPlot.merge(dfTidy.loc[(dfTidy.eventType=='NStime') | (dfTidy.eventType=='DStime')].groupby(['subject','date','trialType'])['eventTime'].count().unstack(),left_index=True,right_index=True)


# profile = ProfileReport(dfPlot, title='Event Count by Session Pandas Profiling Report', explorative = True)

# # save profile report as html
# profile.to_file('pandasProfile-EventCounts.html')

# # #%% all done
# print('all done')


#  #%% ID, mark, and vizualize sessions with abnormal event counts
  
 
# #Unstack() the groupby output for a dataframe we can profile
# dfPlot= dfTidy.copy()
# dfPlot= dfPlot.groupby(['stage', 'subject', 'fileID','eventType'], observed=True)['eventTime'].count().unstack()
# #add trialType counts
# # dfPlot= dfPlot.merge(dfTidy.loc[(dfTidy.eventType=='NStime') | (dfTidy.eventType=='DStime')].groupby(['subject','date','trialType'])['eventTime'].count().unstack(),left_index=True,right_index=True)


# dfPlot.boxplot()

# dfPlot= dfPlot.stack().reset_index(name='count')

# dfPlot.plot(kind='scatter', x='fileID', y='count', c='eventType', colormap='tab10')
# # dfPlot.plot.scatter()
 

# #ind subj distros

# def fixed_boxplot(*args, label=None, **kwargs):
#     sns.boxplot(*args, **kwargs, labels=[label])

# # for subj in dfPlot.subject.unique():
    
# #     dfPlot2= dfPlot.loc[dfPlot.subject==subj]
    
# #     g= sns.FacetGrid(data=dfPlot2, col='eventType', sharex=True, sharey=False, hue='eventType')
    
# #     g.map_dataframe(fixed_boxplot, y='count')
    
# #     g.map_dataframe(sns.stripplot, y='count')
    
# #     #line facet
# #     # g= sns.FacetGrid(data=dfPlot, col='eventType', hue='eventType')#, sharex=False, sharey=False)

# #     # g.map_dataframe(sns.scatterplot, x='fileID', y='count')


    
# # # subj facet
# # g= sns.FacetGrid(data=dfPlot, col='subject', col_wrap=4, hue='eventType')

# # g.map_dataframe(fixed_boxplot, x='eventType', y='count')

# # g.map_dataframe(sns.stripplot, x='eventType', y='count')

# # #all subj
# g= sns.FacetGrid(data=dfPlot, row='stage', col='eventType', hue='eventType', sharex=False, sharey=False)

# g.map_dataframe(fixed_boxplot, x='eventType', y='count')

# g.map_dataframe(sns.stripplot, x='eventType', y='count')



# # #with fileID (to actually pinpoint outliers)
# g= sns.FacetGrid(data=dfPlot, row='stage', col='eventType', hue='eventType')#, sharex=False, sharey=False)

# g.map_dataframe(sns.lineplot, x='fileID', y='count')
# g.map_dataframe(sns.scatterplot, x='fileID', y='count')



# # #STAGE FACET 
# # g= sns.FacetGrid(data=dfPlot, row='stage', hue='eventType')#, sharex=False, sharey=False)

# # g.map_dataframe(fixed_boxplot, x='eventType', y='count')

# # g.map_dataframe(sns.stripplot, x='eventType', y='count')


# # #line stage facet
# # g= sns.FacetGrid(data=dfPlot, row='stage', col='eventType', hue='eventType')#, sharex=False, sharey=False)

# # g.map_dataframe(sns.lineplot, x='fileID', y='count')


#  #%% view distro of eventType counts per fileID for session outliers
  
# dfPlot= dfTidy.groupby(['subject', 'fileID', 'eventType'])['eventTime'].count().reset_index()


# g= sns.displot(data=dfPlot, col='eventType', x='eventTime', kind='hist', hue='eventType', multiple='dodge')
#                 # facet_kws={'sharey': False, 'sharex': True})
# g.fig.subplots_adjust(top=0.9)  # adjust the figure for title
# g.fig.suptitle('Total event count across sessions by type- check for outliers')



#%%--- in progress / todo stuff

#%% TODO: Calculate pump onset times (UStimes) manually

# started this but not really necessary. fixed in matlab and just pulling from there.

# #revising from MATLAB code (bug found in matlab 2022-02-27 which can cause trials to be misclassified and UStimes to be incorrect)

# #manually account for error with variable pump on delays for specific pumps
# # currentSubj(session).trainStage>=8 %error was on on stage 8 code (I'm using >= 8 here temporarily because I am using some numbers greater than 8 as excel metadata labels for some stage 8 sessions) 
# # %if pump1 trial, DS ttl delay was 10 miliseconds, %if pump2 trial, DS ttl delay was 20 miliseconds, %if pump3 trial, DS ttl delay was 20 milisecond

# #still interpolating before importing to python so unclear impact... need to do everything raw

# #approach here will be to find the first PE within cueDur of each trial, then manaully calculate pump onset based on known delay

# dfTemp= dfTidy.copy()

# #TODO: consider calculating an 'estimated' NS pump on / expected pump on for direct comparison between DS and NS trials
# #will just do this actually
# # dfTemp= dfTemp.loc[dfTemp.trialType=='DStime'] 
# dfTemp= dfTemp.loc[(dfTemp.trialType.str.contains('NStime')|(dfTemp.trialType.str.contains('DStime')))] 


# # #get time of the first PE of each trial (have this from groupby cumcount() earlier)
# ind= dfTemp.trialPE==0

# dfTemp['firstPEtime']= dfTemp.loc[ind, 'eventTime']

# #fill na throughout trial
# dfTemp['firstPEtime']= dfTemp.groupby(['fileID','trialID'])['firstPEtime'].transform('fillna', method='ffill')


# #manual delay adjustment
# dfTemp['USdelay']= None


# #add delay; varies by stage
# stages= [1,2,3,4,5,6,7,8,9,10,11,12]
# delay= [0,0,0,0,0,0.5,1,1,1,1,1,1]

# #add additional delay for stages 8+; varies per trial by pumpID (caused by bug, used sequential conditional MPC statements so delay compounded)
# pumps[1,2,3]
# delay2= [0.1, 0.2, 0.3]

# for thisStage in range(len(stages)):
#     dfTemp.loc[dfTemp.stage==stages[thisStage],'delay']= delay[thisStage]
#     for thisPump in range(len(pumps)):
#         dfTemp.loc[dfTemp.pumpID==pumps[thisPump],'delay']= delay[thisStage]+delay2[thisPump]


# dfTemp.loc['USdelay']

# dfTemp['USTimeEstimate']= None

# #example lambda transforms
# # trials= dfTemp.groupby(['fileID','trialID'])['epoch'].transform(lambda x: (x==epocName).any())
# # dfTemp['UStime']=  dfTemp.groupby(['fileID','trialID'])['eventType'].transform(lambda x: x==refEvent)
# #attempt
# # dfTemp['UStimeEst']=  dfTemp[ind].groupby(['fileID','trialID'])['eventTime'].transform(lambda x: x==refEvent)

#%%  TODO: Either have specific epocs for different circumstances (by trialType)
#or should have shared epocs between trialTypes (e.g. DS, post-reward vs Cue, postPE(rewarded or unrewarded based on trialType) )

#specific seems better at face, though occludes direct comparisons between trialTypes


#%% TODO: Refine postPE epoc
#based on outcome (e.g. pump, NS vs DS)
 
#can do using trialType column

#%% TODO: Refine Cue epoch (time between cue onset and cue duration OR US)
# #we want cue epoc limited to cueDur. and Post-Cue epoc between cue end (or reward end) and next Pre-Trial
# dfTemp= dfTidy.copy()


# #if epoc is not UStime
# dfTemp= dfTemp.loc[dfTemp.epoch!='UStime'].copy()


# #if timestamp is between trial start and trial end, label as Cue epoch
# dfTemp.loc[((dfTemp.eventTime>=dfTemp.trialStart) & (dfTemp.eventTime<=dfTemp.trialEnd)), 'epoch']= 'cue'



# # dfTemp.groupby(groupHierarchyTrialID)


#%% TODO: Add post-Cue epoch (time between cue end and next pre-cue?)

#not necessary (remaining DStime & NStime should be this?)

# dfTemp= dfTidy.copy()

# #if event between trialEnd and preTrialStart, 

# # #prefill with na so we can just use ffill() method to fill nulls in time window
# # dfTemp.loc[:,'epoch']= pd.NA


# # dfTemp.loc[dfTemp.eventType==refEvent,'epoch']= refEvent


# dfTemp.epoch= dfTemp.groupby(['fileID'])['epoch'].ffill(limit=postEventTime).copy()