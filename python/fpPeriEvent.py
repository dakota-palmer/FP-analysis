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

#%% Define custom Z score function

#assume input eventCol is binary coded event timestamp, with corresponding cutTime value
def zscoreCustom(df, signalCol, eventCol, preEventTime, postEventTime, eventColBaseline, baselineTime):
    preInd= df.index[df.loc[:,eventCol]==1]-preEventTime
    postInd= df.index[df.loc[:,eventCol]==1]+postEventTime
    
    preIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-preEventTime
    #end baseline at timestamp prior to baseline event onset
    postIndBaseline= df.index[df.loc[:,eventColBaseline]==1]-1
    
    
    ##initialize resulting series, which will be a column that aligns with original df index
    dfResult= np.empty(df.shape[0])
    dfResult= pd.Series(dfResult, dtype='float64')
    dfResult.loc[:]= None
    dfResult.index= df.index
    
    timeLock= np.empty(df.shape[0])
    timeLock= pd.Series(dfResult, dtype='float64')
    timeLock.loc[:]= None
    timeLock.index= df.index
    
        
    #looping through each baseline event eventCol==1 here... but would like to avoid (probs more efficient ways to do this)
    #could cause some issues if # events doesn't match # baseline events (e.g. no PEs but have cue)
    #so should base looping on baseline event instead of peri-event
    for event in range(preIndBaseline.size):
        raw= df.loc[preInd[event]:postInd[event], signalCol]
        baseline= df.loc[preIndBaseline[event]:postIndBaseline[event], signalCol]
        
        z= (raw-baseline.mean())/(baseline.std())
            
        dfResult.loc[preInd[event]:postInd[event]]= z
        
        timeLock.loc[preInd[event]:postInd[event]]= np.linspace(-preEventTime/fs,postEventTime/fs, z.size)

    return z, timeLock

#%% Define peri-event z scoring parameters
fs= 40 #sampling frequency= 40hz

preEventTime= 10 *fs # seconds x fs
postEventTime= 10 *fs

baselineTime= 10*fs

#%% Peri-event z-scoring 
#Iterate through files using groupby() and conduct peri event Z scoring
#iterating through fileID to gurantee no contamination between sessions
 
groups= dfTidy.groupby('fileID')
    
for name, group in groups:
    #-- peri-DS
    z, timeLock=  zscoreCustom(group, 'reblue', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS']= z
    dfTidy.loc[group.index,'timeLock-z-periDS']= timeLock



#%% Plot some fp signals!

# # # # subset data

# # # dfPlot= dfTidy.loc[dfTidy.stage>=5].copy()

# # # dfPlot= dfPlot.loc[0:10000]

# #subset data for plotting using index instead of making copy of array (less memory used)
# indPlot= dfTidy.stage==7.0

# ## looks good!
# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS', col='stage', col_wrap=4, y='blue-z-periDS', hue='trainDayThisStage', kind='line')
