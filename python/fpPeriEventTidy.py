# -*- coding: utf-8 -*-
"""
Created on Tue Jan 11 10:44:37 2022

@author: Dakota
"""


import numpy as np
import scipy.io as sio
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

 
import plotly.express as px #plotly is good for interactive plots (& can export as nice interactive html)
import plotly.io as pio

#unfortunately doesn't seem plotly has built in easy support for stats things like SEM
#you can plot it all, but requires separate calculation and more code

#May be able to combine with ggplot?

import shelve

from customFunctions import saveFigCustom
from customFunctions import subsetData

#FOR TIDY DATA (SINGLE eventType COLUMN)

#%% Load dfTidy.pkl


# #%% Load previously saved dfTidyAnalyzed (and other vars) from pickle
dataPath= r'./_output/' #'r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python\\'

dfTidy= pd.read_pickle(dataPath+'dfTidyAnalyzed.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% Plot settings

savePath= r'./_output/_fpPeriEvent/'

#render plotly figs in browser so they are interactive (jupyter notebook supports interactive plots tho)
pio.renderers.default='browser'

trialOrder= 'DStime', 'NStime'

#%% Define events to include in peri-event analyses

# eventsToInclude= list((dfTidy.eventType.unique()[dfTidy.eventType.unique().notnull()]).astype(str))

# eventVars=eventsToInclude

# eventsToInclude= ['DStime','NStime','PEtime','lickPreUS','lickUS']

eventsToInclude= ['DStime','NStime','PEcue','lickPreUS','lickUS']


#define trial vars to use as baseline (cues)
#todo: save and recall trialVars for this
baselineEvents= ['DStime', 'NStime']


#%% Reverse melt() of eventTypes by pivot() into separate columns

#memory intensive! should probably either 1) do at end or 2) subset before pivot

# dfTemp= dfTidy.copy() 

# # test= dfTidy.loc[dfTidy.fileID==8]
# # dfTemp= test.copy()

# del dfTidy


# #update eventVars
# eventVars= dfTemp.eventType.unique()
# #remove nan eventType
# eventVars= eventVars[pd.notnull(eventVars)]

# #pivot()
# dfTemp= dfTemp.pivot(columns='eventType')['eventTime'].copy()

# #replace timestamps with binary coding
# for eventCol in eventVars:
#     dfTemp.loc[dfTemp[eventCol].notnull(),eventCol]= 1
#     dfTemp.loc[dfTemp[eventCol].isnull(),eventCol]= 0

# # test= dfTemp.loc[dfTemp.fileID==8]

#%% Define rolling Z score function
#example fxn, using as template for custom
# def zscore(x, window):
#     r = x.rolling(window=window)
    
#     #this is a rolling calculation but we want static baseline&std instead
#     m = r.mean().shift(1)
#     s = r.std(ddof=0).shift(1)
#     z = (x-m)/s
#     return z

# fs= 40 #sampling frequency= 40hz
# periEventWindow= 10*fs # seconds x fs

# #%% Define custom Z score function
# # FOR BINARY CODED EVENT COLUMNS

# #assume input eventCol is binary coded event timestamp, with corresponding cutTime value
# def zscoreCustom(df, signalCol, eventCol, preEventTime, postEventTime, eventColBaseline, baselineTime):
    
#     #want to groupby trial but can't strictly since want pre-cue data as baseline
#     #rearrange logical strucutre here a bit, go through and find all of the baseline events
#     #then find the get the first event in this trial. TODO: For now assuming 1 baseline event= 1 trial (e.g. 60 cues, 1 per trialID) 
#     preIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-preEventTime
#     #end baseline at timestamp prior to baseline event onset
#     postIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-1


#     ##initialize resulting series, which will be a column that aligns with original df index
#     zResult= np.empty(df.shape[0])
#     zResult= pd.Series(zResult, dtype='float64')
#     zResult.loc[:]= None
#     zResult.index= df.index
    
#     timeLock= np.empty(df.shape[0])
#     timeLock= pd.Series(timeLock, dtype='float64')
#     timeLock.loc[:]= None
#     timeLock.index= df.index
    
#     #looping through each baseline event eventCol==1 here... but would like to avoid (probs more efficient ways to do this)
#     #RESTRICTING to 1st event in trial
#     for event in range(preIndBaseline.size):
#         #assumes 1 unique trialID per baseline event!!!
#         trial= df.loc[postIndBaseline[event]+1,'trialID']
        
#         dfTemp= df.loc[df.trialID==trial].copy()
        
#         #get events in this trial
#         dfTemp= dfTemp.loc[dfTemp.loc[:,eventCol]==1]
        
#         #get index of only first event in this trial
#         try: #embed in try: in case there are no events
#             preInd= dfTemp.index[0]- preEventTime
#             postInd=dfTemp.index[0] +postEventTime
            
#             raw= df.loc[preInd:postInd, signalCol]
#             baseline= df.loc[preIndBaseline[event]:postIndBaseline[event], signalCol]
            
#             z= (raw-baseline.mean())/(baseline.std())
                
#             zResult.loc[preInd:postInd]= z
            
#             timeLock.loc[preInd:postInd]= np.linspace(-preEventTime/fs,postEventTime/fs, z.size)
    
#         except:
#             continue
        
#     return zResult, timeLock
        
#%% Define custom Z score function
# FOR TIDY DATA, SINGLE eventType COLUMN

#assume input eventCol is binary coded event timestamp, with corresponding cutTime value
def zscoreCustom(df, signalCol, eventCol, preEventTime, postEventTime, eventColBaseline, baselineTime):
    
    #want to groupby trial but can't strictly since want pre-cue data as baseline
    #rearrange logical strucutre here a bit, go through and find all of the baseline events
    #then find the get the first event in this trial. TODO: For now assuming 1 baseline event= 1 trial (e.g. 60 cues, 1 per trialID) 
    preIndBaseline= df.index[df.eventType==eventColBaseline]-preEventTime
    #end baseline at timestamp prior to baseline event onset
    postIndBaseline= df.index[df.eventType==eventColBaseline]-1


    ##initialize resulting series, which will be a column that aligns with original df index
    zResult= np.empty(df.shape[0])
    zResult= pd.Series(zResult, dtype='float64')
    zResult.loc[:]= None
    zResult.index= df.index
    
    timeLock= np.empty(df.shape[0])
    timeLock= pd.Series(timeLock, dtype='float64')
    timeLock.loc[:]= None
    timeLock.index= df.index
    
    #save label cols for easy faceting
    zEventBaseline= np.empty(df.shape[0])
    zEventBaseline= pd.Series(zEventBaseline, dtype='string')
    zEventBaseline.loc[:]= None
    zEventBaseline.index= df.index
    
    zEvent= np.empty(df.shape[0])
    zEvent= pd.Series(zEvent, dtype='string')
    zEvent.loc[:]= None
    zEvent.index= df.index

    #new trialID based on timeLock (since it will bleed through trials)
    trialIDtimeLock= np.empty(df.shape[0])
    trialIDtimeLock= pd.Series(zEventBaseline, dtype='float64')
    trialIDtimeLock.loc[:]= None
    trialIDtimeLock.index= df.index
    
    #looping through each baseline event eventCol==1 here... but would like to avoid (probs more efficient ways to do this)
    #RESTRICTING to 1st event in trial
    for event in range(preIndBaseline.size):
        #assumes 1 unique trialID per baseline event!!!
        trial= df.loc[postIndBaseline[event]+1,'trialID']
        
        dfTemp= df.loc[df.trialID==trial].copy()
        
        #get events in this trial
        dfTemp= dfTemp.loc[dfTemp.eventType==eventCol]
        
        #get index of only first event in this trial
        try: #embed in try: in case there are no events
            preInd= dfTemp.index[0]- preEventTime
            postInd=dfTemp.index[0] +postEventTime
            
            raw= df.loc[preInd:postInd, signalCol]
            baseline= df.loc[preIndBaseline[event]:postIndBaseline[event], signalCol]
            
            z= (raw-baseline.mean())/(baseline.std())
                
            zResult.loc[preInd:postInd]= z
            
            timeLock.loc[preInd:postInd]= np.linspace(-preEventTime/fs,postEventTime/fs, z.size)
    
            zEventBaseline[preInd:postInd]= eventColBaseline
            
            zEvent[preInd:postInd]= eventCol
            
            trialIDtimeLock[preInd:postInd]= event
    
        except:
            continue
        
    return zResult, timeLock, zEventBaseline, zEvent, trialIDtimeLock
        

#%% Define peri-event z scoring parameters
fs= 40 #sampling frequency= 40hz

preEventTime= 5 *fs # seconds x fs
postEventTime= 15 *fs

baselineTime= 10*fs



# #%% Peri-event z-scoring 
# #Iterate through files using groupby() and conduct peri event Z scoring
# #iterating through fileID to gurantee no contamination between sessions
 
# groups= dfTidy.groupby('fileID')

# #currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial 
    
# for name, group in groups:
    
#     #TODO: write fxn or loop for all eventtypes
#     # for eventType in dfTidy.eventType.unique()
    
    
#     #-- peri-DS
#     z, timeLock=  zscoreCustom(group, 'reblue', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-DStime']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-DStime']= timeLock

#     #-- peri-DS Port Entry
#     z, timeLock=  zscoreCustom(group, 'reblue', 'PEtime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-PEtime']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-PEtime']= timeLock
    
#     #-- peri-US
#     z, timeLock=  zscoreCustom(group, 'reblue', 'UStime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-UStime']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-UStime']= timeLock
    
#     #-- peri-DS lick
#     z, timeLock=  zscoreCustom(group, 'reblue', 'lickTime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-lickTime']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-lickTime']= timeLock
    
#     #-- peri-DS lickUS (reward lick)
#     z, timeLock=  zscoreCustom(group, 'reblue', 'lickUS', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-lickUS']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-lickUS']= timeLock

# #--NS
#     #-- peri-NS
#     z, timeLock=  zscoreCustom(group, 'reblue', 'NStime', preEventTime, postEventTime,'NStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periNS']= z
#     dfTidy.loc[group.index,'timeLock-z-periNS-NStime']= timeLock

#     #-- peri-NS Port Entry
#     z, timeLock=  zscoreCustom(group, 'reblue', 'PEtime', preEventTime, postEventTime,'NStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periNS-PEtime']= z
#     dfTidy.loc[group.index,'timeLock-z-periNS-PEtime']= timeLock
    
#     #-- peri-US
#     z, timeLock=  zscoreCustom(group, 'reblue', 'UStime', preEventTime, postEventTime,'NStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periNS-UStime']= z
#     dfTidy.loc[group.index,'timeLock-z-periNS-UStime']= timeLock
    
#     #-- peri-NS lick
#     z, timeLock=  zscoreCustom(group, 'reblue', 'lickTime', preEventTime, postEventTime,'NStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periNS-lickTime']= z
#     dfTidy.loc[group.index,'timeLock-z-periNS-lickTime']= timeLock


#%% Peri-event z-scoring ; programatic loop through eventsToInclude
#Iterate through files using groupby() and conduct peri event Z scoring
#iterating through fileID to gurantee no contamination between sessions
 
groups= dfTidy.groupby('fileID')

#currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial? 

for name, group in groups:

    for thisBaselineEventType in baselineEvents:
                
        for thisEventType in eventsToInclude:
                          
                #conditional to skip different cue types
                if (('DS' in thisBaselineEventType) & ('NS' in thisEventType)):
                    continue
                    
                if (('NS' in thisBaselineEventType) & ('DS' in thisEventType)):
                    continue
                    
            
                #TODO: name here is temp bandaid to match rest of code, simply getting rid of last 4 chars '-time' after DS/NS
                
                colName= ['blue-z-peri'+thisBaselineEventType[0:-4]+'-'+thisEventType]
                colName2= ['timeLock-z-peri'+thisBaselineEventType[0:-4]+'-'+thisEventType]
    
                
                z, timeLock, zEventBaseline, zEvent, trialIDtimeLock =  zscoreCustom(group, 'reblue', thisEventType, preEventTime, postEventTime, thisBaselineEventType, baselineTime)
                dfTidy.loc[group.index,colName]= z
                dfTidy.loc[group.index, colName2]= timeLock
                
                
                #TODO: having event and baselineEvent cols should eliminate need for programmatic col names, should be able to subset & groupby these
                dfTidy.loc[group.index, 'zEventBaseline']= zEventBaseline
                dfTidy.loc[group.index, 'zEvent']= zEvent
                dfTidy.loc[group.index, 'trialIDtimeLock']= trialIDtimeLock

                
        
#%% TODO: I think periEvent / trial by trial data warrants a new dataframe where
#one single column is timeLock. would probs eliminate a lot of unnecessary data? 

#perhaps 'trialID', 'timeLock', 'baselineEvent','timeLockEvent', 'signalType', 'signal'

#%% Specific examination of subj 17 st 7; trying to id cause of weird SEM lines

# stagesToPlot= [7] #dfTidy.stage.unique()

# dfPlot = dfTidy.loc[dfTidy.subject==17].copy()

# dfPlot2= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)].copy()


x= 'timeLock-z-periDS-PEcue'
y= 'blue-z-periDS-PEcue'

# g= sns.relplot(data= dfPlot2, x=x, y=y, hue='fileID', kind='line', legend='full', palette='tab20')


# #3 specific files examining
# dfPlot3= dfPlot2.loc[((dfPlot2.fileID==308) | (dfPlot2.fileID==309 )|  (dfPlot2.fileID==315))].copy()

# g= sns.relplot(data= dfPlot3, x=x, y=y, row='fileID', kind='line', units='trialID', estimator=None, hue='trialID', legend='full')

# g= sns.relplot(data= dfPlot3, x=x, y=y, row='fileID', kind='line')


# #309 is def weird
# dfPlot3= dfPlot2.loc[dfPlot2.fileID==309].copy()

# g= sns.relplot(data= dfPlot3, x=x, y=y, kind='line')

# #plot signal
# dfPlot3= dfPlot3.loc[dfPlot3.trialID<999]

# g= sns.relplot(data=dfPlot3, x=x, y='reblue', kind= 'line', units='trialID', estimator=None, hue='trialID')

# g= sns.relplot(data=dfPlot3, x=x, y=y, kind= 'line', units='trialID', estimator=None, hue='trialID')

# g= sns.relplot(data=dfPlot3, row='trialID', x=x, y='reblue', kind= 'line', units='trialID', estimator=None, hue='trialID')


# #gaps in signal- critical to remember bleedthrough across trials due to timeLock so cant really facet accurately with original trialID


# #narrowing in on specific trials
# trialsToPlot= np.arange(0.,20,1)

# dfPlot4= dfPlot3.loc[dfPlot3.trialID.isin(trialsToPlot)].copy()
                     
# g= sns.relplot(data=dfPlot4, row='trialID', x=x, y='reblue', kind= 'line', hue='trialID')

#specific Culprits:
    #faceting by trialID these have sem patch even tho 1 trial somehow
trialsToPlot= [1,45]


# dfPlot4= dfPlot3.loc[dfPlot3.trialID.isin(trialsToPlot)].copy()

dfPlot4= dfTidy.loc[((dfTidy.fileID==309) & (dfTidy.trialID.isin(trialsToPlot)))].copy()

                     
g= sns.relplot(data=dfPlot4, row='trialID', x=x, y='reblue', kind= 'line', hue='trialID')

g= sns.relplot(data=dfPlot4,  x=x, y='reblue', kind= 'line', units='trialID', estimator=None, hue='trialID')

#scatter reveals multiple observations...how
g= sns.relplot(data=dfPlot4, row='trialID', x=x, y='reblue', kind= 'scatter', hue='trialID')

#multiple values / timelocked events for single trial (1)... during ITI I think? looks like ~101s cutTime but trialStart is 60.2 and nextTrialStart is 105.4

#I guess this could be a fxn of timelock bleedthrough? early relative timestamps in ITI could overlap with early relative timestamps at actual trialStart if trialID is the same


#%% Plot Between Subjects ALL event timelocks from specific stage
# stagesToPlot= [5,7,8,12] #dfTidy.stage.unique()
stagesToPlot= [7] #dfTidy.stage.unique()


dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()
    
dfPlot2= dfPlot.copy()

for thisStage in dfPlot2.stage.unique():
    
    for thisBaselineEventType in baselineEvents:


        dfPlot3= dfPlot2.loc[dfPlot.stage==thisStage,:].copy()
        
        f, ax = plt.subplots(1,len(eventsToInclude), sharey=True, sharex=True)
        
        for thisEventType in eventsToInclude:
                
             #conditional to skip different cue types
            if (('DS' in thisBaselineEventType) & ('NS' in thisEventType)):
                continue
                
            if (('NS' in thisBaselineEventType) & ('DS' in thisEventType)):
                continue
            
            x= 'timeLock-z-peri'+thisBaselineEventType[0:-4]+'-'+thisEventType

            y= 'blue-z-peri'+thisBaselineEventType[0:-4]+'-'+thisEventType
            
            axes= eventsToInclude.index(thisEventType)
        
            g= sns.lineplot(ax= ax[axes],  data=dfPlot3, x=x,y=y, hue='subject', legend='full')
            
            # g= sns.lineplot(ax= ax[axes],  data=dfPlot3, units='trainDayThisStage', estimator=None, x=x,y=y, hue='subject')

            
            ax[axes].axvline(x=0, linestyle='--', color='black', linewidth=2)
            
            ax[axes].set(xlabel= 'time from event (s)')
            ax[axes].set(ylabel= 'GCaMP Z-score (based on pre-cue baseline')
            ax[axes].set(title= thisEventType)

            
            # plt.xlabel('time from event (s)')
            # plt.ylabel('GCaMP Z-score (based on pre-cue baseline')
            # plt.title(thisEventType)
            
            f.suptitle('allSubj-'+'-stage-'+str(thisStage)+'-periEventAll-'+thisBaselineEventType+'trials')
        
        saveFigCustom(f, 'allSubj-'+'-stage-'+str(thisStage)+'-periEventAll-'+thisBaselineEventType+'trials', savePath)


#%% Plot ALL event timelocks from ALL SESSIONS specific stage-- VERY slow

stagesToPlot= [5,7,8,12] #dfTidy.stage.unique()

dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()

    #between subj plot only
    

for subject in dfPlot.subject.unique():

    dfPlot2= dfPlot.loc[dfPlot.subject==subject,:].copy()


    for thisStage in dfPlot2.stage.unique():
        
        for thisBaselineEventType in baselineEvents:

    
            dfPlot3= dfPlot2.loc[dfPlot.stage==thisStage,:].copy()
            
            f, ax = plt.subplots(1,len(eventsToInclude), sharey=True, sharex=True)
            
            for thisEventType in eventsToInclude:
                    
                 #conditional to skip different cue types
                if (('DS' in thisBaselineEventType) & ('NS' in thisEventType)):
                    continue
                    
                if (('NS' in thisBaselineEventType) & ('DS' in thisEventType)):
                    continue
                
                x= 'timeLock-z-peri'+thisBaselineEventType[0:-4]+'-'+thisEventType
    
                y= 'blue-z-peri'+thisBaselineEventType[0:-4]+'-'+thisEventType
                
                axes= eventsToInclude.index(thisEventType)
            
                g= sns.lineplot(ax= ax[axes],  data=dfPlot3, x=x,y=y, hue='trainDayThisStage')
                
                ax[axes].axvline(x=0, linestyle='--', color='black', linewidth=2)
                
                ax[axes].set(xlabel= 'time from event (s)')
                ax[axes].set(ylabel= 'GCaMP Z-score (based on pre-cue baseline')
                ax[axes].set(title= thisEventType)

                
                # plt.xlabel('time from event (s)')
                # plt.ylabel('GCaMP Z-score (based on pre-cue baseline')
                # plt.title(thisEventType)
                
                f.suptitle( 'subject-'+str(subject)+'-stage-'+str(thisStage)+'-periEventAll-'+thisBaselineEventType+'trials')
            
            saveFigCustom(f, 'subject-'+str(subject)+'-stage-'+str(thisStage)+'-periEventAll-'+thisBaselineEventType+'trials', savePath)

#%% TODO: Above but add row facet based on trialOutcomeBeh?

#%% Plot some fp signals!

#subset encoding model input

stagesToPlot= [7]

#number of sessions to include, 0 includes final session of this stage+n
nSessionsToInclude= 0 

#exclude stages
dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()

#exclude sessions within-stage
dfPlot['maxSesThisStage']= dfPlot.groupby(['stage','subject'])['trainDayThisStage'].transform('max')

dfPlot= dfPlot.loc[dfPlot.trainDayThisStage>= dfPlot.maxSesThisStage-nSessionsToInclude]

dfPlot= dfPlot.drop('maxSesThisStage', axis=1)


#all peri-event into single Figure, save

subjPalette= 'tab20' #define a palette to use for individual subj hues

f, ax = plt.subplots(5, 1)

g= sns.lineplot(ax=ax[0,], data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime',hue='subject', palette=subjPalette, legend='full', linewidth=1, alpha=0.5) #Full legend here labels all subjects even if continuous numbers
g= sns.lineplot(ax=ax[0,], data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', linewidth=2.5, color='black')
g.set(title=('peri-DS'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

g= sns.lineplot(ax=ax[1,], data=dfPlot, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime',hue='subject', palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
g= sns.lineplot(ax=ax[1,], data=dfPlot, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime', linewidth=2.5, color='black')
g.set(title=('peri-DS-PE'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

# g= sns.lineplot(ax=ax[2,], data=dfPlot, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',hue='subject',palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
# g= sns.lineplot(ax=ax[2,], data=dfPlot, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',linewidth=2.5, color='black')
# g.set(title=('peri-DS-lick'))
# g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

g= sns.lineplot(ax=ax[2,], data=dfPlot, x='timeLock-z-periDS-lickPreUS',y='blue-z-periDS-lickPreUS',hue='subject',palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
g= sns.lineplot(ax=ax[2,], data=dfPlot, x='timeLock-z-periDS-lickPreUS',y='blue-z-periDS-lickPreUS',linewidth=2.5, color='black')
g.set(title=('peri-DS-lickPreUS'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')


# g= sns.lineplot(ax=ax[3,], data=dfPlot, x='timeLock-z-periDS-UStime',y='blue-z-periDS-UStime',hue='subject',palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
# g= sns.lineplot(ax=ax[3,], data=dfPlot, x='timeLock-z-periDS-UStime',y='blue-z-periDS-UStime',linewidth=2.5, color='black')
# g.set(title=('peri-DS-PumpOn'))
# g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

g= sns.lineplot(ax=ax[4,], data=dfPlot, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS',hue='subject',palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
g= sns.lineplot(ax=ax[4,], data=dfPlot, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS',linewidth=2.5, color='black')
g.set(title=('peri-DS-lickReward'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

saveFigCustom(f, 'allSubj-'+'-periEvent',savePath)

# #test
# indPlot= dfTidy.stage==7.0

# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-DStime', col='stage', col_wrap=4, y='blue-z-periDS-DStime', hue='trainDayThisStage', kind='line')
# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-pox', col='stage', col_wrap=4, y='blue-z-periDS-pox', hue='trainDayThisStage', kind='line')


# # # # subset data

# # # dfPlot= dfTidy.loc[dfTidy.stage>=5].copy()

# # # dfPlot= dfPlot.loc[0:10000]

# #subset data for plotting using index instead of making copy of array (less memory used)
# indPlot= dfTidy.stage==7.0

# ## looks good!
# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-DStime', col='stage', col_wrap=4, y='blue-z-periDS-DStime', hue='trainDayThisStage', kind='line')


#%% Plot ALL sessions from stage

#subset 

stagesToPlot= [7]

dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()

sns.set_palette('Blues')

for subject in dfPlot.subject.unique():
    
    dfPlot2= dfPlot.loc[dfPlot.subject==subject,:]
    
    f, ax = plt.subplots(5, 1)
    
    g= sns.lineplot(ax=ax[0,], data=dfPlot2, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime',hue='trainDayThisStage', legend='full', linewidth=1, alpha=0.5) #Full legend here labels all subjects even if continuous numbers
    g= sns.lineplot(ax=ax[0,], data=dfPlot2, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', linewidth=2.5, color='black')
    g.set(title=('peri-DS'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g= sns.lineplot(ax=ax[1,], data=dfPlot2, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime',hue='trainDayThisStage', legend='full', linewidth=1, alpha=0.5)
    g= sns.lineplot(ax=ax[1,], data=dfPlot2, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime', linewidth=2.5, color='black')
    g.set(title=('peri-DS-PE'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    # g= sns.lineplot(ax=ax[2,], data=dfPlot2, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',hue='trainDayThisStage', legend='full', linewidth=1, alpha=0.5)
    # g= sns.lineplot(ax=ax[2,], data=dfPlot2, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',linewidth=2.5, color='black')
    # g.set(title=('peri-DS-lick'))
    # g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g= sns.lineplot(ax=ax[2,], data=dfPlot2, x='timeLock-z-periDS-lickPreUS',y='blue-z-periDS-lickPreUS',hue='trainDayThisStage', legend='full', linewidth=1, alpha=0.5)
    g= sns.lineplot(ax=ax[2,], data=dfPlot2, x='timeLock-z-periDS-lickPreUS',y='blue-z-periDS-lickPreUS',linewidth=2.5, color='black')
    g.set(title=('peri-DS-lickPreUS'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g= sns.lineplot(ax=ax[3,], data=dfPlot2, x='timeLock-z-periDS-UStime',y='blue-z-periDS-UStime',hue='trainDayThisStage', linewidth=1, alpha=0.5)
    g= sns.lineplot(ax=ax[3,], data=dfPlot2, x='timeLock-z-periDS-UStime',y='blue-z-periDS-UStime',linewidth=2.5, color='black')
    g.set(title=('peri-DS-PumpOn'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g= sns.lineplot(ax=ax[4,], data=dfPlot2, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS',hue='trainDayThisStage',palette=subjPalette, linewidth=1, alpha=0.5)
    g= sns.lineplot(ax=ax[4,], data=dfPlot2, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS',linewidth=2.5, color='black')
    g.set(title=('peri-DS-lickReward'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
        
    g.set(ylim=(-4,10))
    
    f.suptitle('subject-'+str(subject)+'-stage-'+str(stagesToPlot)+'-periEvent')
    saveFigCustom(g, 'subject-'+str(subject)+'-stage-'+str(stagesToPlot)+'-periEvent',savePath)

#%% Presentation 2022-02-21: periDS vs periNS by stage

#exclude variable reward and extinction
# stagesToPlot=  [1,2,3,4,5,6,7]
stagesToPlot=  [1,2,3,4,5]


#subset with customFunction
stagesToPlot= dfTidy.stage.unique()
trialTypesToPlot= ['DStime', 'NStime']
eventsToPlot= dfTidy.eventType.unique()

dfPlot= subsetData(dfTidy, stagesToPlot, trialTypesToPlot, eventsToPlot).copy()

    
#all between-subj plot
g= sns.FacetGrid(col='stage', col_wrap=4, data=dfPlot)

g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', hue='subject', palette='crest', linewidth=1, alpha=0.5)

# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', hue='trialType', hue_order=trialOrder, linewidth=1, alpha=0.5)

# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periNS-NStime',y='blue-z-periNS', hue='trialType', hue_order=trialOrder, linewidth=1, alpha=0.5)


# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', hue='subject', linewidth=1, alpha=0.5)
# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', linewidth=2.5, color='black')
# g.set(title=('peri-DS'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
 
g.set(ylim=(-4,10))

g.add_legend()

g.fig.suptitle('allSubjects'+'allStages'+'-periCue')
saveFigCustom(g, 'allSubjects'+'allStages'+'-periCue',savePath)

#%% Presentation 2022-02-21: peri first rewarded lick (LickUS) vs unspecified lick
stagesToPlot=  [1,2,3,4,5,6,7]

dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()

#all between-subj plot
g= sns.FacetGrid(col='stage', col_wrap=4, data=dfPlot)

g.map_dataframe(sns.lineplot, units='subject', estimator=None, data=dfPlot, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS', hue='trialType', hue_order=trialOrder, linewidth=1, alpha=0.5)

g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')    

g.set(title=('peri-DS-lickReward'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')


#%% TODO: ALL sessions peri-DS (looking for bad sessions to exclude)
stagesToPlot= dfTidy.stage.unique()

dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()

    
#all between-subj plot
g= sns.FacetGrid(col='stage', col_wrap=4, data=dfPlot)
g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', hue='subject', linewidth=1, alpha=0.5)
g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', linewidth=2.5, color='black')
# g.set(title=('peri-DS'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
 
g.set(ylim=(-4,10))

g.add_legend()

g.fig.suptitle('allSubjects'+'allStages'+'-periDS')
saveFigCustom(g, 'allSubjects'+'allStages'+'-periDS',savePath)


#individual subj plots
for subject in dfPlot.subject.unique():
    
    dfPlot2= dfPlot.loc[dfPlot.subject==subject,:]
    
    g= sns.FacetGrid(col='stage', col_wrap=4, data=dfPlot2)
    g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime',hue='trainDayThisStage', palette='Blues', linewidth=1, alpha=0.5)
    # g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', linewidth=2.5, color='black')
    # g.set(title=('peri-DS'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
 
    g.set(ylim=(-4,10))
    
    g.add_legend()
    
    g.fig.suptitle('subject-'+str(subject)+'allStages'+'-periDS')
    saveFigCustom(g, 'subject-'+str(subject)+'allStages'+'-periDS',savePath)

    
#%% IDEA: Exclude trials by: 

    ## 1) compute cumulative trialID
    ## 2) plot all trials
    ## 3) exclude outliers
    
    #using this approach should be very easy to select and exclude specific trials

    #viz all trials
    stagesToPlot= dfTidy.stage.unique()
        
    
    dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()
    
    for subject in dfPlot.subject.unique():
    
        dfPlot2= dfPlot.loc[dfPlot.subject==subject,:]
        
        g= sns.FacetGrid(col='stage', col_wrap=4, data=dfPlot2)
        g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime',hue='trialCountThisStage', palette='Blues', linewidth=1, alpha=0.5)
        # g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS-DStime',y='blue-z-periDS-DStime', linewidth=2.5, color='black')
        # g.set(title=('peri-DS'))
        g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
     
        g.set(ylim=(-4,10))
        
        g.add_legend()
        
        g.fig.suptitle('subject-'+str(subject)+'allStagesAllTrials'+'-periEvent')
        saveFigCustom(g, 'subject-'+str(subject)+'allStagesAllTrials'+'-periEvent',savePath)
        

#%% Plot ALL SESSIONS from all stages
#Plotly package for interactivity + seborn for stats

# df = px.data.gapminder().query("continent=='Oceania'")
# fig = px.line(df, x="year", y="lifeExp", color='country')
# fig.show()


# for subject in dfPlot.subject.unique():
    
#     dfPlot2= dfPlot.loc[dfPlot.subject==subject,:]
        
#     # fig = px.line(dfPlot2, x="timeLock-z-periDS", y="blue-z-periDS", color= 'trainDayThisStage')

#     groupHierarchy= ['stage','subject','trainDayThisStage', 'timeLock-z-periDS-DStime']
    
#     y= 'blue-z-periDS-DStime'
    
#     dfPlot2.loc[:,'yMean']= dfPlot2.groupby(groupHierarchy)[y].transform('mean').copy()
    
    
#     yMean= dfPlot2.groupby(groupHierarchy)[y].mean()

#     ySEM= dfPlot2.groupby(groupHierarchy)[y].sem()

#     fig= px.line(dfPlot2, x= 'timeLock-z-periDS-DStime', y='yMean', color='trainDayThisStage')

#     fig.show() 
#     #export as interactive html
#     figName= 'subject-'+str(subject)+'-stage-'+str(stagesToPlot)+'-periEvent' 
#     fig.write_html(savePath+figName+'.html')

for subject in dfPlot.subject.unique():

    dfPlot2= dfPlot.loc[dfPlot.subject==subject,:].copy()

    for thisStage in dfPlot2.stage.unique():
    
        dfPlot3= dfPlot2.loc[dfPlot.stage==thisStage,:].copy()
            
        # fig = px.line(dfPlot2, x="timeLock-z-periDS", y="blue-z-periDS", color= 'trainDayThisStage')
    
        groupHierarchy= ['stage','subject','trainDayThisStage', 'timeLock-z-periDS-DStime']
        
        y= 'blue-z-periDS-DStime'
        
        dfPlot3.loc[:,'yMean']= dfPlot3.groupby(groupHierarchy)[y].transform('mean').copy()
        
        
        yMean= dfPlot3.groupby(groupHierarchy)[y].mean().copy()
    
        ySEM= dfPlot3.groupby(groupHierarchy)[y].sem().copy()
    
        fig= px.line(dfPlot3, x= 'timeLock-z-periDS-DStime', y='yMean', color='trainDayThisStage')
    
        # fig.show() 
        #plotly export as interactive html
        figName= 'subject-'+str(subject)+'-stage-'+str(thisStage)+'-periEvent' 
        fig.write_html(savePath+figName+'.html')
        
        
        #seaborn for stats
        g= sns.relplot(data=dfPlot3, x='timeLock-z-periDS-DStime',y=y, kind='line', hue='trainDayThisStage')
        saveFigCustom(g,  'subject-'+str(subject)+'-stage-'+str(thisStage)+'-periEvent', savePath)


#%% Plot some fp signals!

# #test
# indPlot= dfTidy.stage==7.0

# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-DStime', col='stage', col_wrap=4, y='blue-z-periDS-DStime', hue='trainDayThisStage', kind='line')
# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-PEtime', col='stage', col_wrap=4, y='blue-z-periDS-PEtime', hue='trainDayThisStage', kind='line')


# # # # # subset data

# # # # dfPlot= dfTidy.loc[dfTidy.stage>=5].copy()

# # # # dfPlot= dfPlot.loc[0:10000]

# # #subset data for plotting using index instead of making copy of array (less memory used)
# # indPlot= dfTidy.stage==7.0

# # ## looks good!
# # sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-DStime', col='stage', col_wrap=4, y='blue-z-periDS-DStime', hue='trainDayThisStage', kind='line')

