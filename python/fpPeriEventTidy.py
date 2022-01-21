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
 
import shelve

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


#%% data prep for encoding model
# want - 
# x_basic= 148829 x 1803... # timestamps entire session x (# peri-Trial window * num events). binary coded
# gcamp_y = 148829 x 1 ; entire session signal predicted by regression . z scored photometry signal currently nan during ITI & only valid values during peri-DS

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
#     dfResult= np.empty(df.shape[0])
#     dfResult= pd.Series(dfResult, dtype='float64')
#     dfResult.loc[:]= None
#     dfResult.index= df.index
    
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
                
#             dfResult.loc[preInd:postInd]= z
            
#             timeLock.loc[preInd:postInd]= np.linspace(-preEventTime/fs,postEventTime/fs, z.size)
    
#         except:
#             continue
        
#     return dfResult, timeLock
        
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
    dfResult= np.empty(df.shape[0])
    dfResult= pd.Series(dfResult, dtype='float64')
    dfResult.loc[:]= None
    dfResult.index= df.index
    
    timeLock= np.empty(df.shape[0])
    timeLock= pd.Series(timeLock, dtype='float64')
    timeLock.loc[:]= None
    timeLock.index= df.index
    
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
                
            dfResult.loc[preInd:postInd]= z
            
            timeLock.loc[preInd:postInd]= np.linspace(-preEventTime/fs,postEventTime/fs, z.size)
    
        except:
            continue
        
    return dfResult, timeLock
        

#%% Define peri-event z scoring parameters
fs= 40 #sampling frequency= 40hz

preEventTime= 10 *fs # seconds x fs
postEventTime= 10 *fs

baselineTime= 10*fs

#%% Peri-event z-scoring 
#Iterate through files using groupby() and conduct peri event Z scoring
#iterating through fileID to gurantee no contamination between sessions
 
groups= dfTidy.groupby('fileID')

#currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial 
    
for name, group in groups:
    #-- peri-DS
    z, timeLock=  zscoreCustom(group, 'reblue', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS']= z
    dfTidy.loc[group.index,'timeLock-z-periDS']= timeLock

    #-- peri-DS Port Entry
    z, timeLock=  zscoreCustom(group, 'reblue', 'PEtime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS-PEtime']= z
    dfTidy.loc[group.index,'timeLock-z-periDS-PEtime']= timeLock
    
        #-- peri-DS lick
    z, timeLock=  zscoreCustom(group, 'reblue', 'lickTime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS-lickTime']= z
    dfTidy.loc[group.index,'timeLock-z-periDS-lickTime']= timeLock
    
            #-- peri-DS lickUS (reward lick)
    z, timeLock=  zscoreCustom(group, 'reblue', 'lickUS', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS-lickUS']= z
    dfTidy.loc[group.index,'timeLock-z-periDS-lickUS']= timeLock




#%% Plot some fp signals!

# #test
# indPlot= dfTidy.stage==7.0

# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS', col='stage', col_wrap=4, y='blue-z-periDS', hue='trainDayThisStage', kind='line')
# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-PEtime', col='stage', col_wrap=4, y='blue-z-periDS-PEtime', hue='trainDayThisStage', kind='line')


# # # # # subset data

# # # # dfPlot= dfTidy.loc[dfTidy.stage>=5].copy()

# # # # dfPlot= dfPlot.loc[0:10000]

# # #subset data for plotting using index instead of making copy of array (less memory used)
# # indPlot= dfTidy.stage==7.0

# # ## looks good!
# # sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS', col='stage', col_wrap=4, y='blue-z-periDS', hue='trainDayThisStage', kind='line')

