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

#%% Load dfTidy.pkl


# #%% Load previously saved dfTidyAnalyzed (and other vars) from pickle
dataPath= r'./_output/' #'r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python\\'

dfTidy= pd.read_pickle(dataPath+'dfTidyFP.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% Define rolling Z score function
def zscore(x, window):
    r = x.rolling(window=window)
    
    #this is a rolling calculation but we want static baseline&std instead
    m = r.mean().shift(1)
    s = r.std(ddof=0).shift(1)
    z = (x-m)/s
    return z

fs= 40 #sampling frequency= 40hz
periEventWindow= 10*fs # seconds x fs

#%% Define custom Z score function

#assume input eventCol is binary coded event timestamp, with corresponding cutTime value
def zscoreCustom(df, signalCol, eventCol, preEventTime, postEventTime, eventColBaseline, baselineTime):
    preInd= df.index[df.loc[:,eventCol]==1]-preEventTime
    postInd= df.index[df.loc[:,eventCol]==1]+postEventTime
    
    preIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-preEventTime
    #end baseline at timestamp prior to baseline event onset
    postIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-1
    
    
    #initialize resulting series, which will be a column that aligns with original df index
    dfResult= np.empty([df.size])
    dfResult= pd.Series(dfResult)
    dfResult.loc[:]= pd.NA
    
    #looping through each baseline event eventCol==1 here... but would like to avoid (probs more efficient ways to do this)
    #could cause some issues if # events doesn't match # baseline events (e.g. no PEs but have cue)
    #so should base looping on baseline event instead of peri-event
    for event in range(preIndBaseline.size):
        raw= df.loc[preInd[event]:postInd[event], signalCol]
        baseline= df.loc[preIndBaseline[event]:postIndBaseline[event], signalCol]
        
        z= (raw-baseline.mean())/(baseline.std())
            
        dfResult.loc[preInd[event]:postInd[event]]= z
    
    return dfResult

#%% 
fs= 40 #sampling frequency= 40hz

preEventTime= 10 *fs # seconds x fs
postEventTime= 10 *fs

baselineTime= 10*fs

#%% testing custom fxn
#need to make sure no contamination between files, maybe
#groupby()apply on fileID would be appropriate?

#instead of rolling mean and baseline, use static mean and baseline from pre-cue
#so x will be the fp signal at each ts within the window but z score z will be based on pre-cue mean m and std s

df=dfTidy.copy()

df.loc[:,'blue-periDSz']=zscoreCustom(df, 'reblue', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)


#%% example fxn in action
eventCol= 'DStime'
signalCol= 'reblue'
eventColBaseline= 'DStime'

preInd= df.index[df.loc[:,eventCol]==1]-preEventTime
postInd= df.index[df.loc[:,eventCol]==1]+postEventTime

preIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-preEventTime
#end baseline at timestamp prior to baseline event onset
postIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-1

#initialize resulting series
dfZ= np.empty([preInd.size*postInd.size, preIndBaseline.size])

dfZ= pd.DataFrame(dfZ)

dfZ.loc[:]= pd.NA


#initialize resulting series, which will be a column that aligns with original df index
dfResult= np.empty([df.size])
dfResult= pd.Series(dfResult)
dfResult.loc[:]= pd.NA

#looping through each baseline event eventCol==1 here... but would like to avoid (probs more efficient ways to do this)
#could cause some issues if # events doesn't match # baseline events (e.g. no PEs but have cue)
#so should base looping on baseline event instead of peri-event
for event in range(preIndBaseline.size):
    raw= df.loc[preInd[event]:postInd[event], signalCol]
    baseline= df.loc[preIndBaseline[event]:postIndBaseline[event], signalCol]

    z= (raw-baseline.mean())/(baseline.std())

    dfZ.loc[:,event]=z
    
    dfResult.loc[preInd[event]:postInd[event]]= z


#%%
test= df.groupby(['fileID']).apply(zscoreCustom(df, signalCol, eventCol, preEventTime, postEventTime, eventColBaseline, baselineTime))


#%% Peri-trial Z score 

dfTemp= dfTidy.copy()

#only include valid trials?
# dfTemp= dfTemp.loc[dfTemp.trialID>=0]

#one per trialStart
ind= dfTemp.loc[dfTemp.groupby(['fileID','trialID']).cumcount()==0].index
dfTemp= dfTemp.loc[ind]

#use this 

test= zscore(dfTemp.reblue,periEventWindow)

#%% Plot some fp signals!

# # subset data

# dfPlot= dfTidy.loc[dfTidy.stage>=5].copy()


# sns.relplot(data=dfPlot, x=dfPlot.cutTime, y=dfPlot.reblue, col=dfPlot.stage, hue=dfPlot.subject, kind='line')
