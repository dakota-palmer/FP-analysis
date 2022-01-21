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


from sklearn.linear_model import LassoCV
from sklearn.model_selection import RepeatedKFold

#%% PREPARING INPUT FOR PARKER ENCODING MODEL
# want - 
# x_basic= 148829 x 1803... # timestamps entire session x (# time shifts in peri-Trial window * num events). binary coded
# gcamp_y = 148829 x 1 ; entire session signal predicted by regression . z scored photometry signal currently nan during ITI & only valid values during peri-DS

#%% Load dfTidy.pkl


# #%% Load previously saved dfTidyAnalyzed (and other vars) from pickle
dataPath= r'./_output/' #'r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python\\'

dfTidy= pd.read_pickle(dataPath+'dfTidyAnalyzed.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()

#%% Subset data
#for encoding model only need event times + photometry signal + metadata
colToInclude= idVars+contVars+['trainDayThisStage','eventType']

dfTidy= dfTidy.loc[:,colToInclude]

# Hitting memory errors when time shifting events; so subsetting or processing in chunks should help

#%% Define which specific stages / sessions to include!

stagesToInclude= [7]

#number of sessions to include, includes final session of this stage-n
nSessionsToInclude= 2 

#define which eventTypes to include!
eventsToInclude= ['DStime','NStime','UStime','PEtime','lickTime','lickTimeUS']
dfTidy.loc[~dfTidy.eventType.isin(eventsToInclude),'eventType']= pd.NA

#exclude stages
dfTidy= dfTidy.loc[dfTidy.stage.isin(stagesToInclude),:]

#exclude sessions within-stage
dfTidy['maxSesThisStage']= dfTidy.groupby(['stage','subject'])['trainDayThisStage'].transform('max')

dfTidy= dfTidy.loc[dfTidy.trainDayThisStage>= dfTidy.maxSesThisStage-nSessionsToInclude]

dfTidy= dfTidy.drop('maxSesThisStage', axis=1)


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
        

#%% Define peri-event z scoring / time shifting parameters
fs= 40 #sampling frequency= 40hz

preEventTime= 10 *fs # seconds x fs
postEventTime= 10 *fs

baselineTime= 10*fs

#%% Peri-event z-scoring 
# #Iterate through files using groupby() and conduct peri event Z scoring
# #iterating through fileID to gurantee no contamination between sessions
 
# groups= dfTidy.groupby('fileID')

# #currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial 
    
# for name, group in groups:
#     #-- peri-DS
#     z, timeLock=  zscoreCustom(group, 'reblue', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS']= timeLock

#     #-- peri-DS Port Entry
#     z, timeLock=  zscoreCustom(group, 'reblue', 'PEtime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-PEtime']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-PEtime']= timeLock
    
#         #-- peri-DS lick
#     z, timeLock=  zscoreCustom(group, 'reblue', 'lickTime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-lickTime']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-lickTime']= timeLock
    
#             #-- peri-DS lickUS (reward lick)
#     z, timeLock=  zscoreCustom(group, 'reblue', 'lickUS', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-lickUS']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-lickUS']= timeLock

#%% Reverse melt() of eventTypes by pivot() into separate columns

#memory intensive! should probably either 1) do at end or 2) subset before pivot

dfTidy= dfTidy.copy() 

# test= dfTidy.loc[dfTidy.fileID==8]
# dfTidy= test.copy()


#update eventVars
eventVars= dfTidy.eventType.unique()
#remove nan eventType
eventVars= eventVars[pd.notnull(eventVars)]

#pivot()
# dfTemp= dfTidy.pivot(columns='eventType')['cutTime'].copy()
dfTemp= dfTidy.pivot(columns='eventType')['cutTime'].copy()


#replace timestamps with binary coding; convert to Sparse arrays (saves mem)
for eventCol in eventVars:
    dfTemp.loc[dfTemp[eventCol].notnull(),eventCol]= 1
    dfTemp.loc[dfTemp[eventCol].isnull(),eventCol]= 0
    
    
    #change dtype to int (more efficient mem); make sparse
    dfTemp[eventCol]= dfTemp[eventCol].astype('int')
    # print(dfTemp[eventCol].unique())
    test1= dfTemp.loc[:,eventCol]
    #good here
    
    #try using sparse dtype instead of assigning sparse array specifically
    dfTemp[eventCol]= dfTemp[eventCol].astype(pd.SparseDtype("int", 0))
    test4= dfTemp[eventCol]
    
    #why is it doing float64 instead of int32 oof
    #where are nans possibly coming from??
    #good on the right side of this, but assignment into dfTemp converts to float?
    #some zeros are being converted to nan (for example some at the end)
    #guessing that the Sparse array may not store values past last event (==1) so maybe assignment to df is filling in "missing" rows with nan 
    test3= pd.Series(pd.arrays.SparseArray(dfTemp.loc[:,eventCol], fill_value=0, dtype='int'))

    #really not sure why but this assignment very specifically is causing conversion to float64
    # dfTemp.loc[:,eventCol]= pd.Series(pd.arrays.SparseArray(dfTemp.loc[:,eventCol], fill_value=0, dtype='int'))
    test2= dfTemp.loc[:,eventCol]
    

#% merge back into df
#index matches so simple join
dfTidy= dfTidy.join(dfTemp.loc[:,eventVars])
dfTidy= dfTidy.drop(['eventType'], axis=1)

# #exclude eventTypes if needed
# eventVars[eventVars.isin(eventsToExclude)]

del dfTemp

#%% Define peri-event time shift parameters
fs= 40
preEventTime= 5 *fs # seconds x fs
postEventTime= 10 *fs

#%% Shift event timestamps for encoding model

#matlab code:
    # elseif strcmp(type1,'time_shift')==1
    #         x_con=[];
    #         shift_back=fs*time_back;   %how many points to shift forward and backwards in Hz
    #         shift_forward=fs*time_forward;
    #         %             gcamp_temp=gcamp_y(shift_forward+1:end-shift_back);
    #         gcamp_temp=gcamp_y;
            
    #         %             for shifts = 1:shift_back+shift_forward+1
    #         %                 x_con=horzcat(x_con,con_binned(shift_back+shift_forward+2-shifts:end-shifts+1)')
    #         for shifts = -shift_back:shift_forward
    #             x_con=horzcat(x_con,circshift(con_binned,[0,shifts])');% create a column for each shift of event indication vectors
    #         end
            
    #         x_basic=horzcat(x_basic,x_con);% create matrix of x_con
    #         con_iden=[con_iden ones(1,size(x_con,2))*con];% create vector for idetifing event that is denoted by "1" in x_basic
    #     end
    
dfTemp= dfTidy.copy()
del dfTidy

#preallocate column for each 'shift'
#hitting memory error here? making it pretty far, to +329 
# for shiftNum in np.arange(-preEventTime,postEventTime):
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= pd.NA
    

#preallocate, try making event timings Sparse- this works!
for eventCol in eventVars.categories:
    for shiftNum in np.arange(-preEventTime,postEventTime):
        # a= pd.Series(np.zeros(len(dfTemp), int))
        # a= np.zeros(len(dfTemp), int))

        #2) assign sparse dtype, for some reason filling with SparseArray causes conversion to float
        # dfTemp.loc[:, (eventCol+'+'+(str(shiftNum)))]= a.astype(pd.SparseDtype("int", 0))
        # dfTemp[(eventCol+'+'+(str(shiftNum)))]= a.astype(pd.SparseDtype("int", 0))

        #1) again, assignment to df here is causing conversion to float. very frustrating
        # dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= pd.Series(pd.arrays.SparseArray(a, fill_value=0), dtype='int')
        #3) works? only assingning as dense then changing dtype to sparse after assignment seems to preserve int?
        a= np.zeros(len(dfTemp), int)
        dfTemp[(eventCol+'+'+(str(shiftNum)))]= a
        dfTemp[(eventCol+'+'+(str(shiftNum)))]=  dfTemp[(eventCol+'+'+(str(shiftNum)))].astype(pd.SparseDtype("int", 0))
        #this suggests to me that any reassignment of the Series after setting sparse dtype will convert to float?
        #so how could I make changes afterward and retain int() dtype?
        #for now perhaps should just avoid preallocation & presetting dtype, only make sparse after filling each col 
        

groups= dfTemp.copy().groupby(['fileID'])

import time

#attempt 5-- WORKED! (very slow, idk how long)
#~2s/ iteration so ~10s/shift
for eventCol in eventVars.categories:
    for shiftNum in np.arange(-preEventTime,postEventTime):
        #note fill_value=0 here will fill the beginning and end of session with 0 instead of nan (e.g. spots where there are no valid timestamps to shift())
        dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= groups[eventCol].shift(shiftNum,fill_value=0)
        startTime = time.time()
        
        #####your python script#####
        dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= groups[eventCol].shift(shiftNum,fill_value=0)
    
    
        executionTime = (time.time() - startTime)
        print('Execution time in seconds: ' + str(executionTime))
        

#TOTO: try shift entire df then assign to col? also try unsorted groupby?
#and try scipy matrix. would probably be a lot faster?

#Now that i'm using sparse data maybe I can speed up using older methods below
#~7.5-8s/iteration
#failed, hit mem error col 3014?
# for shiftNum in np.arange(-preEventTime,postEventTime):
#     startTime = time.time()
    
#     #####your python script#####
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= groups[eventVars.categories].shift(shiftNum, fill_value=0)

#     executionTime = (time.time() - startTime)
#     print('Execution time in seconds: ' + str(executionTime))
    
    

#attempt 1
#loop through fileIDs (need this grouping to prevent contamination) and apply shift
#hitting memory errors this way
# for name, group in groups:
    # for shiftNum in np.arange(-preEventTime,postEventTime):
    #     # dfTemp.loc[group.index,(eventVars.categories+'+'+(str(shiftNum)))]= group.loc[:,eventVars].shift(shiftNum)
    #     dfTemp.loc[group.index,(eventVars.categories+'+'+(str(shiftNum)))]= group.loc[:,eventVars].shift(shiftNum)

#attempt 2- making it pretty far, to +329... still doesn't work with sparse
# for shiftNum in np.arange(-preEventTime,postEventTime):
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= groups[eventVars.categories].shift(shiftNum)

#attempt 3
#still hitting memory errors, try looping through eventVars separately?
#this seems a ton slower but i think memory cap is hit later
#idk why it's fine outside of the loop but breaks during. need to preallocate? 
#probs bc invoking dfTemp.groupby and it's changing size?

# for eventCol in eventVars.categories:
#     for shiftNum in np.arange(-preEventTime,postEventTime):
#         dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= groups[eventCol].shift(shiftNum)

#For the shifted event timestamps type of data, just save into np.array. 
#No need for dataframe at this point I guess and should be much more efficient.
#Index should match dataframe anyway so should be able to recover anything needed

#preallocate array
#why is this 90gb now?? df above was saying 21gb at some point?
# x_basic= np.zeros([(len(eventVars)*(len(np.arange(-preEventTime,postEventTime)))),len(dfTemp)])
# for shiftNum in np.arange(-preEventTime,postEventTime):
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= pd.NA

#TODO: May want scipy sparse matrix instead, more efficient than pandas?

#%% Drop original, unshifted event times (we should now have duplicate col for timeshift=0 now)

dfTemp= dfTemp.drop(eventVars,axis=1)

#%% SAVE the data
#should save time if there's a crash or something later

savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

print('saving regression input dfTemp to file')

#Save as pickel
dfTemp.to_pickle(savePath+'dfRegressionInput.pkl')


#also save other variables e.g. variables actually included in regression Input dataset (since we may have excluded specific eventTypes)
saveVars= ['idVars', 'eventVars', 'trialVars', 'experimentType', 'stagesToInclude', 'nSessionsToInclude', 'preEventTime','postEventTime']


#use shelve module to save variables as dict keys
my_shelf= shelve.open(savePath+'dfRegressionInputMeta', 'n') #start new file

for key in saveVars:
    try:
        my_shelf[key]= globals()[key] 
    except TypeError:
        #
        # __builtins__, my_shelf, and imported modules can not be shelved.
        #
        print('ERROR shelving: {0}'.format(key))
my_shelf.close()

#%% NORMALIZE photometry signal
#TODO

#%% IF needed load 
dataPath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

dfTemp= pd.read_pickle(dataPath+'dfRegressionInput.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% RUN REGRESSION?
#TODO: How to handle different subjects? should run separately in loop or use as predictor?
#unlike matlab version of code this is one big table with everything

#TESTING with subset
# dfTemp= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.min()]

# test= dfTemp.iloc[:,20]
# test2= test.unique()

#Run separately on each subject
#finding now that groupby with sparse dtypes may be very slow...
groups= dfTemp.groupby(['subject'])

for name, group in groups:
    #define predictor and response variables
    #predictors will be all remaining columns that are not idVars or contVars
    col= ~group.columns.isin(idVars+contVars)
    X = group.loc[:,col]
    
    #--Remove invalid observations 
    #pd.shift() timeshift introduced nans at beginning and end of session 
    #(since there were no observations to fill with); Exclude these timestamps
    #regression inputs should not have any nan & should be finite; else  will throw error
    #--shouldn't happen now since fill_values=0
    # dfTemp= dfTemp.loc[~X.isin([np.nan, np.inf, -np.inf]).any(1),:]
    
    X = group.loc[:,col]
    
    # #examining input data
    # np.any(np.isnan(X))
    # np.all(np.isfinite(X))
    
    
    #regressor is fp signal
    y = group["reblue"]
    
    #define cross-validation method to evaluate model
    cv = RepeatedKFold(n_splits=5, n_repeats=3, random_state=1)
    
    #define model
    model = LassoCV(alphas=np.arange(0, 1, 0.01), cv=cv, n_jobs=-1)
    
    #fit model
    model.fit(X, y)
    
    #display lambda that produced the lowest test MSE
    print(model.alpha_)


#%% Visualize kernels

#coefficients: 1 col for each shifted version of event timestamps in the range of timeShifts. events ordered sequentially

kernels= pd.DataFrame()

b= model.coef_

for eventCol in range(len(eventVars)):
    if eventCol==0:
        ind= np.arange(0,(eventCol+1)*len(np.arange(-preEventTime,postEventTime)))
    else:
        ind= np.arange((eventCol)*len(np.arange(-preEventTime,postEventTime)),((eventCol+1)*len(np.arange(-preEventTime,postEventTime)-1)))
   
    kernels[(eventVars[eventCol]+'-coef')]= b[ind]


#%% 

#Establish hierarchical grouping for analysis
#want to be able to aggregate data appropriately for similar conditions, so make sure group operations are done correctly
groupers= ['subject', 'trainDayThisStage', 'fileID']