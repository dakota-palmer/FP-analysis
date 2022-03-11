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


#%% Preliminary data analyses

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

#%% TODO: Calculate pump onset times (UStimes) manually

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

# dfTemp['firstPEtime']= dfTemp.loc[ind, 'cutTime']

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
# # dfTemp['UStimeEst']=  dfTemp[ind].groupby(['fileID','trialID'])['cutTime'].transform(lambda x: x==refEvent)


#%% Conduct trial-based analyses prior to revising trialID?

#no  we'll want UStimes etc during entire 'trial' (not just limited to cueDur) so will want to revise this after

#%% DP 1/18/22 
# Event latency, count, and behavioral outcome for each TRIALID
#old section below could be converted to 'epoc' or something if want relative comparison between pre-cue/ITI/cue

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


#%% OLD Preliminary data analyses (for tidy data)
# # Event latency, count, and behavioral outcome for each TRIALID

# #TODO: Lick 'cleaning' to eliminate invalid licks (are they in port, is ILI within reasonable range)


# #Calculate latency to each event in trial (from cue onset). based on trialEnd to keep it simple
#   # trialEnd is = cue onset + cueDur. So just subtract cueDur for cue onset time  
# dfTidy.loc[dfTidy.trialID>=0, 'eventLatency'] = (
#     (dfTidy.eventTime)-(dfTidy.trialEnd-dfTidy.cueDur)).copy()

# #have trial start now, subtract trialStart from eventTime to get latency per trial
# #no need for -trialID exception
# dfTidy.loc[:,'eventLatency']= ((dfTidy.eventTime)-(dfTidy.trialStart)).copy()
# # 
# # dfTidy.loc[dfTidy.trialID>=0,'eventLatency']= ((dfTidy.eventTime)-(dfTidy.trialStart))

# # dfTidy.loc[dfTidy.trialID<0, 'eventLatency'] = ((dfTidy.eventTime)-(dfTidy.trialStart)).copy()

# #TODO: exception needs to be made for first ITI; for now fill w nan
# dfTidy.loc[dfTidy.trialID== -999, 'eventLatency']= np.nan

# #Count events in each trial 
# #use cumcount() of event times within file & trial 

# #converting to float for some reason
# dfTidy['trialPE'] = dfTidy.loc[(dfTidy.eventType == 'PEtime')].groupby([
# 'fileID', 'trialID'])['eventTime'].cumcount().copy()

# # #try transform
# # dfTidy.loc[:,'trialPE'] = dfTidy.loc[(dfTidy.eventType == 'PEtime')].groupby([
# # 'fileID', 'trialID'])['eventTime'].transform('cumcount').copy()


# dfTidy['trialLick'] = dfTidy.loc[(dfTidy.eventType == 'lickTime')].groupby([
#     'fileID', 'trialID']).cumcount().copy()

# # Add trainDay variable (cumulative count of sessions within each subject)
# dfGroup= dfTidy.loc[dfTidy.groupby(['subject','fileID']).cumcount()==0]
# # test= dfGroup.groupby(['subject','fileID']).transform('cumcount')
# dfTidy.loc[:,'trainDay']= dfGroup.groupby(['subject'])['fileID'].transform('cumcount')
# dfTidy.loc[:,'trainDay']= dfTidy.groupby(['subject','fileID']).fillna(method='ffill')

# #Add cumulative count of training day within-stage (so we can normalize between subjects appropriately)
# ##very important consideration!! Different subjects can run different programs on same day, which can throw plots/analysis off when aggregating data by date.
# dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# dfTidy['trainDayThisStage']=  dfGroup.groupby(['subject', 'stage']).transform('cumcount')
# dfTidy.trainDayThisStage= dfTidy.groupby(['fileID'])['trainDayThisStage'].fillna(method='ffill').copy()
# # #QC visualizations
# # g= sns.relplot(data=dfTidy, col='subject', col_wrap=4, x='date', y='trainDayThisStage', hue='stage', kind='scatter')
# # g= sns.relplot(data=dfTidy, col='subject', col_wrap=4, x='date', y='trainDay', hue='stage', kind='scatter')
# # g= sns.relplot(data=dfTidy, col='subject', col_wrap=4, x='date', y='date', hue='stage', kind='scatter')

#%% TODO: count events within 10s of cue onset (cue duration in final stage)  
#this is mainly for comparing progression/learning between stages since cueDuration varies by stage

dfTemp=  dfTidy.loc[((dfTidy.eventLatency<= 10) & (dfTidy.eventLatency>0))].copy()

dfTidy['trialPE10s'] = dfTemp.loc[(dfTemp.eventType == 'PEtime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

dfTidy['trialLick10s'] = dfTemp.loc[(dfTemp.eventType == 'lickTime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

#%% Define behavioral (pe,lick) outcome for each trial. For my lick+laser sessions I need 
# #to isolate trials with both a PE+lick to measure effect of laser

# #For each trial (trialID >=0),
# #count the number of PEs per trial. if >0, they entered the port and earned sucrose. If=0, they did not.
# #since groupby counting methods don't work well with nans, using nunique() 
# # peOutcome= dfTidy.loc[dfTidy.trialID>=0].groupby(['fileID','trialID'],dropna=False)['trialPE'].nunique()
# #do for all trials
# outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialPE'].nunique()

# #naming "trialOutcomeBeh" for now to distinguish between behavioral outcome and reward outcome if needed later
# trialOutcomeBeh= outcome.copy()

# trialOutcomeBeh.loc[outcome>0]='PE'
# trialOutcomeBeh.loc[outcome==0]='noPE'

# #now do the same for licks
# outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialLick'].nunique()

# #add lick outcome + PE outcome for clarity #if it doesn't say '+lick', then none was counted
# trialOutcomeBeh.loc[outcome>0]=trialOutcomeBeh.loc[outcome>0]+ '+' + 'lick'

# #set index to file,trial and
# #fill in matching file,trial with trialOutcomeBeh
# #TODO: I think there is a more efficient way to do this assignment, doens't take too long tho

# dfTidy= dfTidy.reset_index().set_index(['fileID','trialID'])

# dfTidy.loc[trialOutcomeBeh.index,'trialOutcomeBeh']= trialOutcomeBeh

# #reset index to eventID
# dfTidy= dfTidy.reset_index().set_index(['eventID'])

#%% same as above but behavioral outcome within first 10s of each trial
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
dfTidy= dfTidy.reset_index().set_index(['eventID'])

#%% Calculate Probability of behavioral outcome for each trial type. 
#This is normalized so is more informative than simple count of trials. 

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
#         ['fileID','trialType','trialOutcomeBeh'],dropna=False)['trialID'].nunique(dropna=False).unstack(fill_value=0)


# ##calculate proportion for each trial type: num trials with outcome/total num trials of this type

# trialCount= dfTemp.sum(axis=1)


# outcomeProb= dfTemp.divide(dfTemp.sum(axis=1),axis=0)

# #melt() into single column w label
# dfTemp= outcomeProb.reset_index().melt(id_vars=['fileID','trialType'],var_name='trialOutcomeBeh',value_name='outcomeProbFile')

# #assign back to df by merging
# #TODO: can probably be optimized. if this section is run more than once will get errors due to assignment back to dfTidy
# # dfTidy.reset_index(inplace=True) #reset index so eventID index is kept

# dfTidy= dfTidy.reset_index().merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh']).copy()

#%% Same as above but probability of behavioral outcome within first 10s of trial 
#This is normalized so is more informative than simple count of trials. 

#calculate Proportion of trials with PE out of all trials for each trial type
#can use nunique() to get count of unique trialIDs with specific PE outcome per file
#given this, can calculate Probortion as #PE/#PE+#noPE
   
#subset data and save as intermediate variable dfGroup
#get only one entry per trial
dfGroup= dfTidy.loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0].copy()

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
# dfTidy.reset_index(inplace=True) #reset index so eventID index is kept

dfTidy= dfTidy.reset_index().merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh10s']).copy()




#%% ADD EPOCS prior to revising trialID

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
# g= sns.relplot(data= dfPlot, x= 'cutTime', y='reblue', hue='epoch')

fig, ax= plt.subplots()
# sns.lineplot(axes= ax, data= dfPlot, x= 'cutTime', y='reblue', hue='epoch', dropna=False) #retain gaps (dropna=False)
sns.scatterplot(axes= ax, data= dfPlot, x= 'cutTime', y='reblue', hue='epoch')


ax.vlines(x=dfPlot.loc[dfPlot.eventType=='UStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='UStime', color='g')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='DStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='DStime', color='b')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='NStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='NStime', color='k')

# ax.vlines(x=dfPlot.loc[dfPlot.eventType=='PEtime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='PEtime', color='gray')

ax.legend()

#%%  TODO: Either have specific epocs for different circumstances (by trialType)
#or should have shared epocs between trialTypes (e.g. DS, post-reward vs Cue, postPE(rewarded or unrewarded based on trialType) )

#specific seems better at face, though occludes direct comparisons between trialTypes


#%% TODO: Refine postPE epoc
#based on outcome (e.g. pump, NS vs DS)
 
#can do using trialType column

#%% REVISE TRIALID 

#so for now treating these epochs somewhat independently from trialID. 
#not sure how to best deal w this. Perhaps 'trials' should be all time 
#from cue onset: next cue start, with 'Cue','Reward','ITI','Pre-Cue' epocs? 

#example of the core issue: rat makes PE at cue+9s, so there are licks technically in 'ITI' based on 
#current trial ID definitions. 

#I think the big issue here 

#--Solution: Revise TrialID to contain entire thisCue:nextCue period. Add Epocs of further within-trial times.

# #for now could be as simple as reversing trialID transformations for ITI+Pre-Cue, will make current ITIs fall within same trialID
# dfTidy.loc[:,'epoch']= dfTidy.loc[:,'trialType'].copy()

#make ITI trialIDs positive again, make Pre-Cues corresponding integers
dfTidy.loc[dfTidy.trialType=='ITI','trialID']= dfTidy.trialID*-1
dfTidy.loc[dfTidy.trialType=='Pre-Cue','trialID']= (dfTidy.trialID+0.5)*-1

#overwrite old ITI & Pre-Cue trialTypes with first of this trial
dfTidy.trialType= dfTidy.copy().groupby(['fileID','trialID'])['trialType'].transform('first')

# dfTidy.trialType= dfTidy.groupby(['fileID','trialID'])['trialType'].cumcount()==0

#%% Specify ITIs with/without postPE if appropriate

#TODO: could make more specific/efficient probably based on trialOutcomeBeh col

# #make distinct noPE ITIs (did they seek or not), were they rewarded or not)

# dfTemp= dfTidy.copy()

# dfTemp.epoch= dfTemp.groupby(['fileID', 'trialID']).ffill()

#Specify ITIs corresponding to this trial now as post-PE ITIs
#find trials with epoc we're searching for
epocName= 'cue-postPE'

# dfTidy.epoch.cat.add_categories(['ITI-'+epocName], inplace=True)

dfTidy.epoch= dfTidy.epoch.astype(str)
dfTemp= dfTidy.copy()

#skip first ITI
dfTemp= dfTemp.loc[dfTemp.trialID!=999]


# # lambda fxn here is quick way to check with groupby(); kinda slow
# #returns multiindexed boolean representing each group
# trials= dfTemp.groupby(['fileID','trialID']).apply(lambda x: (x['epoch']==epocName).any())

# # dfTemp= dfTemp.set_index(['fileID','trialID']) 

# ind= [((trials) & (dfTemp.epoch=='ITI'))]

# dfTemp.loc[ind, 'epoch']= dfTemp.epoch+'-'+epocName


#transform() to make indexing faster?
# trials= dfTemp.groupby(['fileID','trialID']).transform(lambda x: (x['epoch']==epocName).any())

# trials2= dfTemp.groupby(['fileID','trialID'])['epoch'].transform(lambda x: (x==epocName))

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

#%% add reward epochs

# #add reward epoch (for now some time between pump onset and next pre-cue period?)
# #within some window of time e.g. a few seconds after pump on, could be based on actual lick distribution

# # !! not restricting to within trialID since a late PE could lead to bleed into next ITI
# #so for now treating these epochs somewhat independently from trialID. 

# #-- set epoch at pump on times, then fillna() within certain time window surrounding epoch

# refEvent= 'UStime' #reference event surrounding which we'll define epochs

# dfTidy.epoch.cat.add_categories([refEvent], inplace=True)
# dfTemp= dfTidy.copy()

# #prefill with na so we can just use ffill() method to fill nulls in time window
# dfTemp.loc[:,'epoch']= pd.NA

# dfTemp.loc[dfTemp.eventType==refEvent,'epoch']= refEvent


# fs= 40 #40hz = sampling frequency
# preEventTime= 0*fs #x seconds before refEvent; don't count any before refEvent
# postEventTime= 2*fs # x seconds after refEvent  

# #ffill will only fill null values!
# # !! not restricting to within trialID since a late PE could lead to bleed into next ITI
# #so for now treating these epochs somewhat independently from trialID. 
# dfTemp.epoch= dfTemp.groupby(['fileID'])['epoch'].ffill(limit=postEventTime).copy()

# #assign back to df
# dfTidy.loc[dfTemp.epoch.notnull(),'epoch']= dfTemp.epoch.copy()

# del dfTemp

#%% Add reward epochs & refine postPE vs post-US

#convert everything between UStime epoch and pre-cue epoch as post-US

#currently have gaps of cue-postPE between UStime and ITI-postPE
#want to convert all of these and post-PE-ITIs to 'post-US' e.g. to count licks here as reward licks 

# #strat A
# dfTidy.epoch= dfTidy.epoch.astype(str)
# dfTemp= dfTidy.copy()

# #-- set epoch at pump on times, then fillna() until next trial

# refEvent= 'UStime' #reference event surrounding which we'll define epochs

# epocName= 'postUS' #name to add

# dfTemp= dfTidy.copy()

# #prefill with na so we can just use ffill() method to fill nulls in time window
# dfTemp.loc[:,'epoch']= pd.NA

# dfTemp.loc[dfTemp.eventType==refEvent,'epoch']= dfTidy.epoch+'-'+epocName


# fs= 40 #40hz = sampling frequency
# preEventTime= 0*fs #x seconds before refEvent; don't count any before refEvent
# postEventTime= 2*fs # x seconds after refEvent  

# #ffill will only fill null values!
# # !! not restricting to within trialID since a late PE could lead to bleed into next ITI
# #so for now treating these epochs somewhat independently from trialID. 
# dfTemp.epoch= dfTemp.groupby(['fileID'])['epoch'].ffill(limit=postEventTime).copy()

# #assign back to df
# dfTidy.loc[dfTemp.epoch.notnull(),'epoch']= dfTemp.epoch.copy()

# del dfTemp

#-- strat c-- should operate solely on actual US timestamp (don't trust that epochs are correct)
dfTidy.epoch= dfTidy.epoch.astype(str)
dfTemp= dfTidy.copy()
dfTemp= dfTemp.loc[dfTemp.trialID!=999]

refEvent= 'UStime'

# dfTemp2= dfTemp.loc[dfTemp.eventType==refEvent]

# dfTemp2['UStime']= dfTemp2.groupby(['fileID','trialID'])['cutTime'].transform

#find UStime for each trial (if exists), then do simple timestamp check if prior or after UStime
#returns boolean
# dfTemp['UStime']=  dfTemp.groupby(['fileID','trialID']).transform(lambda x: (x.loc[x.eventType==refEvent,'cutTime']))
dfTemp['UStime']=  dfTemp.groupby(['fileID','trialID'])['eventType'].transform(lambda x: x==refEvent)

#convert to timestamp and ffill() within trial
dfTemp['UStime']= dfTemp.loc[dfTemp.UStime, 'cutTime']

dfTemp['UStime']= dfTemp.groupby(['fileID','trialID'])['UStime'].ffill()

#check if ts is after UStime within-trial. If so, update epoch
##don't replace immediate UStime timestamps for now
## dfTemp= dfTemp.loc[dfTemp.epoch != 'UStime']

ind= (dfTemp.cutTime>=dfTemp.UStime)

dfTemp.loc[ind, 'epoch']= dfTemp.epoch+'-'+'postUS'

#--also specify actual reward pump on window

preEventTime= 0 #x seconds before refEvent; don't count any before refEvent
postEventTime= 2# x seconds after refEvent (pump is on for 2s) 

#ffill will only fill null values!
# !! not restricting to within trialID since a late PE could lead to bleed into next ITI
#so for now treating these epochs somewhat independently from trialID. 
ind= ((dfTemp.cutTime>=dfTemp.UStime)&(dfTemp.cutTime<=dfTemp.UStime+postEventTime))

dfTemp.loc[ind,'epoch']= 'UStime'



#assign back to df
dfTidy.loc[dfTemp.index, 'epoch']= dfTemp.epoch.copy()
dfTidy.epoch= dfTidy.epoch.astype('category')

#find trials containing US epoch, rename post-US epochs accordingly
# trials= dfTemp.groupby(['fileID','trialID'])['epoch'].transform(lambda x: (x==refEpoc).any())



# #strat b
# #skip first ITI
# dfTemp= dfTidy.copy()
# dfTemp= dfTemp.loc[dfTemp.trialID!=999]

# refEpoc= 'UStime'

# #find trials containing US epoch, rename post-US epochs accordingly
# trials= dfTemp.groupby(['fileID','trialID'])['epoch'].transform(lambda x: (x==refEpoc).any())

# trials= trials.loc[trials==True]

# #manually redefine 

# #--anything that should come after UStime
# ind= (trials & (dfTemp.epoch.str.contains('ITI'))

# dfTemp.loc[ind, 'epoch']= )= 'ITI'+'postUS'


# #label remaining ITIs as noPE    
# # dfTidy.epoch.cat.add_categories(['ITI-noPE'], inplace=True)

# dfTemp.loc[dfTemp.epoch=='ITI', 'epoch']= dfTemp.epoch+'-noPE'

# #merge back into df
# dfTidy.epoch = dfTemp.epoch

# dfTidy.epoch= dfTidy.epoch.astype('category')


#%% viz epocs
dfPlot= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()].copy()

#signal with epochs + vertical lines at event times
# g= sns.relplot(data= dfPlot, x= 'cutTime', y='reblue', hue='epoch')

fig, ax= plt.subplots()
# sns.lineplot(axes= ax, data= dfPlot, x= 'cutTime', y='reblue', hue='epoch', dropna=False) #retain gaps (dropna=False)
sns.scatterplot(axes= ax, data= dfPlot, x= 'cutTime', y='reblue', hue='epoch')


ax.vlines(x=dfPlot.loc[dfPlot.eventType=='UStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='UStime', color='g')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='DStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='DStime', color='b')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='NStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='NStime', color='k')

# ax.vlines(x=dfPlot.loc[dfPlot.eventType=='PEtime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='PEtime', color='gray')

ax.legend()

#%% Add Post-Cue (post-PE) epoch

# #post-cue epoc = post-PE

# #-- set epoch at pump on times, then fillna() within certain time window surrounding epoch

# refEvent= 'PEtime' #reference event surrounding which we'll define epochs

# epocName= 'postPE'

# dfTidy.epoch.cat.add_categories([epocName], inplace=True)


# #prefill with na so we can just use ffill() method to fill nulls in time window
# dfTemp= dfTidy.copy()
# dfTemp.loc[:,'epoch']= pd.NA


# #Assign Post-Cue epoch between PE timestamp and Pre-Cue -1

# #in sum, want epoch between PE DURING CUE (rewarded PE) and PreCue for next trial
# # TODO: could specify postPErewarded; postPEunrewarded but not necessary

# #starting with these epochs: DStime (cue onset:cue onset+cueDur), ITI (trialEnd:nextTrialStart-10), Pre-Cue (nextTrialStart-10)
# # UStime (UStime:UStime+postEventTime)

# # go in,subset data within trial (no Pre-Cue, only PEs during cue) 

# #assign PE timestamp as postPE epoc start
# #then we can groupby() trialID and ffill nans as post-PE

# #subset- dont include first trial
# # dfTemp= dfTemp.loc[dfTemp.trialID!=999]

# #dont include pre-cue time
# dfTemp = dfTemp.loc[dfTemp.trialType!='Pre-Cue']


# dfTemp.loc[dfTemp.eventType==refEvent,'epoch']= epocName


# # dfTemp.loc[dfTemp.trialType!='Pre-Cue', 'epoch']= epocName



# fs= 40 #40hz = sampling frequency
# preEventTime= 0*fs #x seconds before refEvent; don't count any before refEvent
# # postEventTime= 2*fs # x seconds after refEvent  

# #ffill will only fill null values!
# # restricting to trialID 
# dfTemp.epoch= dfTemp.groupby(['fileID', 'trialID'])['epoch'].ffill().copy()

# test= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()].copy()
# test.loc[dfTemp.epoch.notnull(),'epoch']= dfTemp.epoch.copy()

# #assign back to df
# dfTidy.loc[dfTemp.epoch.notnull(),'epoch']= dfTemp.epoch.copy()

# del dfTemp


#%% TODO: Refine Cue epoch (time between cue onset and cue duration OR US)
# #we want cue epoc limited to cueDur. and Post-Cue epoc between cue end (or reward end) and next Pre-Trial
# dfTemp= dfTidy.copy()


# #if epoc is not UStime
# dfTemp= dfTemp.loc[dfTemp.epoch!='UStime'].copy()


# #if timestamp is between trial start and trial end, label as Cue epoch
# dfTemp.loc[((dfTemp.cutTime>=dfTemp.trialStart) & (dfTemp.cutTime<=dfTemp.trialEnd)), 'epoch']= 'cue'



# # dfTemp.groupby(groupHierarchyTrialID)


#%% TODO: Add post-Cue epoch (time between cue end and next pre-cue?)

#not necessary (remaining DStime & NStime should be this?)

# dfTemp= dfTidy.copy()

# #if event between trialEnd and preTrialStart, 

# # #prefill with na so we can just use ffill() method to fill nulls in time window
# # dfTemp.loc[:,'epoch']= pd.NA


# # dfTemp.loc[dfTemp.eventType==refEvent,'epoch']= refEvent


# dfTemp.epoch= dfTemp.groupby(['fileID'])['epoch'].ffill(limit=postEventTime).copy()



#%% Refine eventTypes: Separate anticipatory/non-reward from reward/consumption licks

# #isolate licks occuring during 'reward' epoch, redefine as new eventType
# dfTidy.eventType.cat.add_categories(['lickUS'], inplace=True)

# dfTidy.loc[((dfTidy.eventType=='lickTime')&(dfTidy.epoch=='UStime')),'eventType']= 'lickUS'


# #isolate licks occuring before reward epoch
# dfTidy.eventType.cat.add_categories(['lickPreUS'], inplace=True)


# #keep simple- just get licks between trialStart and trialEnd (that are not in reward epoch)
# dfTemp= dfTidy.loc[dfTidy.eventType=='lickTime'].copy()

# dfTemp= dfTemp.loc[dfTemp.epoch!= 'UStime'].copy()


# ind= ((dfTemp.cutTime>= dfTemp.trialStart) & (dfTemp.cutTime<=dfTemp.trialEnd)).index

# #redefine as pre-reward lick
# # dfTemp.loc[ind, 'eventType']= 'lickPreUS'

# dfTidy.loc[ind, 'eventType']= 'lickPreUS'


#--Above works but have epochs now so could use these?
# basic assumption here is that reward is consumed by the next trial
# this should leave lickTimes during pre-cue I think as unspecified

dfTidy.eventType= dfTidy.eventType.astype(str)

dfTemp= dfTidy.loc[dfTidy.eventType=='lickTime'].copy()

#some flexibiilty for preUS licks
dfTemp.loc[((dfTemp.epoch=='DStime')|(dfTemp.epoch=='NStime') | (dfTemp.epoch=='cue-postPE')), 'eventType']= 'lickPreUS'

#some flexibility for postUS licks
dfTemp.loc[dfTemp.epoch.str.contains('postUS'), 'eventType']= 'lickPostUS'

dfTemp.loc[(dfTemp.epoch=='UStime'), 'eventType']= 'lickUS'



#distinguish between PEs that occur within cue epoch (should be rewarded if DS trial) and those that occur after?


#merge back into df
dfTidy.loc[dfTemp.index, 'eventType']= dfTemp.eventType.copy()

dfTidy.eventType= dfTidy.eventType.astype('category')


#viz
# test= dfTidy.loc[(dfTidy.fileID==dfTidy.fileID.min())].copy()

#testing assignment
# ~~~~~~~ noticing ITI-postPE lickTimes (should be labelled lickPostUS so must be missing UStimes?)~~~~~~
#pump times are currently defined in matlab code based on variable stage delays, possible mistake was make there (these aren't actually raw pump times)
test= dfTidy.copy()
test= test.loc[((test.epoch=='ITI-postPE') & (test.eventType=='lickTime'))]

#yes, e.g. python says PE outcome for some fileID 25 trialID 43
#lots of stage 4 file 247 trial 8
#! even stage 7- fileiD 58/59 trials 21,42/44...could impact encoding model

#examine further
test2= dfTidy.copy()
test2= test2.loc[dfTidy.fileID.isin([247,58,59])]

#247, 21 is a fluke. ITI postPE is happening RIGHT before UStime but we still have a UStime 

#Found a missing UStime? file 247 trial 8. PE but no UStime, so no US epoch
test3= test2.loc[test2.fileID==247]
test3= test3.loc[test3.trialID==8]

test3.eventType.unique()


#%% viz epocs

# dfPlot= dfTidy.loc[dfTidy.fileID==16].copy()
dfPlot= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()].copy()

#signal with epochs + vertical lines at event times
# g= sns.relplot(data= dfPlot, x= 'cutTime', y='reblue', hue='epoch')

fig, ax= plt.subplots()
# sns.lineplot(axes= ax, data= dfPlot, x= 'cutTime', y='reblue', hue='epoch', dropna=False) #retain gaps (dropna=False)
sns.scatterplot(axes= ax, data= dfPlot, x= 'cutTime', y='reblue', hue='epoch')


ax.vlines(x=dfPlot.loc[dfPlot.eventType=='UStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='UStime', color='g')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='DStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='DStime', color='b')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='NStime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='NStime', color='k')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickPreUS', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickPreUS', color='pink')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickPostUS', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickPostUS', color='maroon')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickUS', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickUS', color='gold')

ax.vlines(x=dfPlot.loc[dfPlot.eventType=='lickTime', 'cutTime'], ymin=ax.get_ylim()[0], ymax= ax.get_ylim()[1], label='lickTime', color='gray')


ax.legend()



#%% Want to separate anticipatory/non-reward from reward/consumption licks

# #To do so, let's simply calculate a latency from each lick and the nearest UStime
# #set a threshold within which we'll count them as 'reward' licks (e.g. within a few seconds of pump on, could be based on distribution of licks during trials/ITI)

# #TODO: could be useful to write function here for defining new event types conditionally 
# #really just need to search within time window surrounding each UStime
# #writing somewhat generalizable so can make fxn later

# fs= 40 #40hz = sampling frequency

# refEvent= 'UStime' #reference event surrounding which we'll search

# preEventTime= 0 #don't count any before refEvent

# postEventTime= 2*fs #count x seconds after refEvent

# eventToChange= 'lickTime' #events to search for/redefine

# newEvent= 'lickUS' #events to search for/redefine

# #will need to groupby() fileID to prevent contamination between files

# groups= dfTidy.groupby('fileID')


# #loop here is too slow, need to try another method..
# #alternate method could be to have reward 'epoch' in new column and then filter by that?

# #currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial 
# #looping here is probably inefficient but works    

# for name, group in groups:
#     #get index of time window surrounding refEvents
#     preInd= group.index[group.eventType==refEvent]-preEventTime
#     postInd= group.index[group.eventType==refEvent]+postEventTime

#     for event in range(preInd.size):
#         #update eventsToChange within this window  
#         dfTemp= group.loc[preInd[event]:postInd[event]].copy()              
        
#         dfTidy.loc[dfTemp.index[dfTemp.eventType==eventToChange],'eventType']= newEvent

#%% Visualize count of eventTypes by epoch
# # #wondering when consumption licks are actually occurring
# dfPlot= dfTidy.loc[((dfTidy.trialType=='DStime') | (dfTidy.trialType=='NStime'))].copy()
# dfPlot= dfPlot.groupby(['stage','subject', 'trainDayThisStage', 'fileID','trialType', 'epoch', 'eventType'])['eventType'].count().reset_index(name='count')

# # sns.catplot(data=dfPlot,x='eventType', y='count', hue='trialType', kind='bar')
# sns.relplot(data=dfPlot, col='trialType', row='eventType', x='trainDayThisStage', y='count', hue='epoch', kind='line', facet_kws={'sharey':False})

# dfPlot= dfTidy.copy()
# dfPlot.loc[dfPlot.eventType=='lickUS']

# sns.displot(data=dfPlot, x='eventLatency', col='stage', hue='subject')


#%% Conduct trial-based analyses AFTER  revising trialID?

#yeah  we'll want UStimes etc during entire 'trial' (not just limited to cueDur) so will want to revise this after

#%% DP 1/18/22 
# Event latency, count, and behavioral outcome for each TRIALID
#old section below could be converted to 'epoc' or something if want relative comparison between pre-cue/ITI/cue

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


#%% OLD Preliminary data analyses (for tidy data)
# # Event latency, count, and behavioral outcome for each TRIALID

# #TODO: Lick 'cleaning' to eliminate invalid licks (are they in port, is ILI within reasonable range)


# #Calculate latency to each event in trial (from cue onset). based on trialEnd to keep it simple
#   # trialEnd is = cue onset + cueDur. So just subtract cueDur for cue onset time  
# dfTidy.loc[dfTidy.trialID>=0, 'eventLatency'] = (
#     (dfTidy.eventTime)-(dfTidy.trialEnd-dfTidy.cueDur)).copy()

# #have trial start now, subtract trialStart from eventTime to get latency per trial
# #no need for -trialID exception
# dfTidy.loc[:,'eventLatency']= ((dfTidy.eventTime)-(dfTidy.trialStart)).copy()
# # 
# # dfTidy.loc[dfTidy.trialID>=0,'eventLatency']= ((dfTidy.eventTime)-(dfTidy.trialStart))

# # dfTidy.loc[dfTidy.trialID<0, 'eventLatency'] = ((dfTidy.eventTime)-(dfTidy.trialStart)).copy()

# #TODO: exception needs to be made for first ITI; for now fill w nan
# dfTidy.loc[dfTidy.trialID== -999, 'eventLatency']= np.nan

# #Count events in each trial 
# #use cumcount() of event times within file & trial 

# #converting to float for some reason
# dfTidy['trialPE'] = dfTidy.loc[(dfTidy.eventType == 'PEtime')].groupby([
# 'fileID', 'trialID'])['eventTime'].cumcount().copy()

# # #try transform
# # dfTidy.loc[:,'trialPE'] = dfTidy.loc[(dfTidy.eventType == 'PEtime')].groupby([
# # 'fileID', 'trialID'])['eventTime'].transform('cumcount').copy()


# dfTidy['trialLick'] = dfTidy.loc[(dfTidy.eventType == 'lickTime')].groupby([
#     'fileID', 'trialID']).cumcount().copy()

# # Add trainDay variable (cumulative count of sessions within each subject)
# dfGroup= dfTidy.loc[dfTidy.groupby(['subject','fileID']).cumcount()==0]
# # test= dfGroup.groupby(['subject','fileID']).transform('cumcount')
# dfTidy.loc[:,'trainDay']= dfGroup.groupby(['subject'])['fileID'].transform('cumcount')
# dfTidy.loc[:,'trainDay']= dfTidy.groupby(['subject','fileID']).fillna(method='ffill')

# #Add cumulative count of training day within-stage (so we can normalize between subjects appropriately)
# ##very important consideration!! Different subjects can run different programs on same day, which can throw plots/analysis off when aggregating data by date.
# dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# dfTidy['trainDayThisStage']=  dfGroup.groupby(['subject', 'stage']).transform('cumcount')
# dfTidy.trainDayThisStage= dfTidy.groupby(['fileID'])['trainDayThisStage'].fillna(method='ffill').copy()
# # #QC visualizations
# # g= sns.relplot(data=dfTidy, col='subject', col_wrap=4, x='date', y='trainDayThisStage', hue='stage', kind='scatter')
# # g= sns.relplot(data=dfTidy, col='subject', col_wrap=4, x='date', y='trainDay', hue='stage', kind='scatter')
# # g= sns.relplot(data=dfTidy, col='subject', col_wrap=4, x='date', y='date', hue='stage', kind='scatter')

#%% TODO: count events within 10s of cue onset (cue duration in final stage)  
#this is mainly for comparing progression/learning between stages since cueDuration varies by stage

dfTemp=  dfTidy.loc[((dfTidy.eventLatency<= 10) & (dfTidy.eventLatency>0))].copy()

dfTidy['trialPE10s'] = dfTemp.loc[(dfTemp.eventType == 'PEtime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

dfTidy['trialLick10s'] = dfTemp.loc[(dfTemp.eventType == 'lickTime')].groupby([
'fileID', 'trialID'])['eventTime'].cumcount().copy()

#%% Define behavioral (pe,lick) outcome for each trial. For my lick+laser sessions I need 
# #to isolate trials with both a PE+lick to measure effect of laser

# #For each trial (trialID >=0),
# #count the number of PEs per trial. if >0, they entered the port and earned sucrose. If=0, they did not.
# #since groupby counting methods don't work well with nans, using nunique() 
# # peOutcome= dfTidy.loc[dfTidy.trialID>=0].groupby(['fileID','trialID'],dropna=False)['trialPE'].nunique()
# #do for all trials
# outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialPE'].nunique()

# #naming "trialOutcomeBeh" for now to distinguish between behavioral outcome and reward outcome if needed later
# trialOutcomeBeh= outcome.copy()

# trialOutcomeBeh.loc[outcome>0]='PE'
# trialOutcomeBeh.loc[outcome==0]='noPE'

# #now do the same for licks
# outcome= dfTidy.groupby(['fileID','trialID'],dropna=False)['trialLick'].nunique()

# #add lick outcome + PE outcome for clarity #if it doesn't say '+lick', then none was counted
# trialOutcomeBeh.loc[outcome>0]=trialOutcomeBeh.loc[outcome>0]+ '+' + 'lick'

# #set index to file,trial and
# #fill in matching file,trial with trialOutcomeBeh
# #TODO: I think there is a more efficient way to do this assignment, doens't take too long tho

# dfTidy= dfTidy.reset_index().set_index(['fileID','trialID'])

# dfTidy.loc[trialOutcomeBeh.index,'trialOutcomeBeh']= trialOutcomeBeh

# #reset index to eventID
# dfTidy= dfTidy.reset_index().set_index(['eventID'])

#%% same as above but behavioral outcome within first 10s of each trial
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
dfTidy= dfTidy.reset_index().set_index(['eventID'])

#%% Calculate Probability of behavioral outcome for each trial type. 
#This is normalized so is more informative than simple count of trials. 

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
#         ['fileID','trialType','trialOutcomeBeh'],dropna=False)['trialID'].nunique(dropna=False).unstack(fill_value=0)


# ##calculate proportion for each trial type: num trials with outcome/total num trials of this type

# trialCount= dfTemp.sum(axis=1)


# outcomeProb= dfTemp.divide(dfTemp.sum(axis=1),axis=0)

# #melt() into single column w label
# dfTemp= outcomeProb.reset_index().melt(id_vars=['fileID','trialType'],var_name='trialOutcomeBeh',value_name='outcomeProbFile')

# #assign back to df by merging
# #TODO: can probably be optimized. if this section is run more than once will get errors due to assignment back to dfTidy
# # dfTidy.reset_index(inplace=True) #reset index so eventID index is kept

# dfTidy= dfTidy.reset_index().merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh']).copy()

#%% Same as above but probability of behavioral outcome within first 10s of trial 
#This is normalized so is more informative than simple count of trials. 

#calculate Proportion of trials with PE out of all trials for each trial type
#can use nunique() to get count of unique trialIDs with specific PE outcome per file
#given this, can calculate Probortion as #PE/#PE+#noPE
   
#subset data and save as intermediate variable dfGroup
#get only one entry per trial
dfGroup= dfTidy.loc[dfTidy.groupby(['fileID','trialID']).cumcount()==0].copy()

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
# dfTidy.reset_index(inplace=True) #reset index so eventID index is kept

dfTidy= dfTidy.reset_index().merge(dfTemp,'left', on=['fileID','trialType','trialOutcomeBeh10s']).copy()




#%% 
dfPlot= dfTidy.copy()
sns.displot(data=dfPlot, x='eventLatency', col='eventType', hue='trialType')


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

saveVars= ['idVars', 'eventVars', 'trialVars', 'experimentType']

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




#%% PLOTS:
    
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
# g.set_ylabels('session')

# saveFigCustom(g, 'individual_eventCounts_line')

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


# #%% Use pandas profiling on event counts
# ##This might be a decent way to quickly view behavior session results/outliers if automated
# ## note- if you are getting errors with ProfileReport() and you installed using conda, remove and reinstall using pip install

# # from pandas_profiling import ProfileReport

# # #Unstack() the groupby output for a dataframe we can profile
# # dfPlot= dfTidy.copy()
# # dfPlot= dfPlot.groupby(['subject','date','eventType'])['eventTime'].count().unstack()
# # #add trialType counts
# # dfPlot= dfPlot.merge(dfTidy.loc[(dfTidy.eventType=='NStime') | (dfTidy.eventType=='DStime')].groupby(['subject','date','trialType'])['eventTime'].count().unstack(),left_index=True,right_index=True)


# # profile = ProfileReport(dfPlot, title='Event Count by Session Pandas Profiling Report', explorative = True)

# # # save profile report as html
# # profile.to_file('pandasProfileEventCounts.html')

# #%% all done
print('all done')