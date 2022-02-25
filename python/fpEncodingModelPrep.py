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

import time


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
colToInclude= idVars+contVars+['trainDayThisStage','trialID','trialType','eventType']

dfTidy= dfTidy.loc[:,colToInclude]

# Hitting memory errors when time shifting events; so subsetting or processing in chunks should help

#%% Define which specific stages / events / sessions to include!

#% #TODO: collect all events, save, and move event exclusion to regression script

stagesToInclude= [7]

#number of sessions to include, 0 includes final session of this stage+n
nSessionsToInclude= 0 

#no exclusion (except null/nan)
eventsToInclude= list((dfTidy.eventType.unique()[dfTidy.eventType.unique().notnull()]).astype(str))


# #define which eventTypes to include!
# eventsToInclude= ['DStime','NStime','UStime','PEtime','lickTime','lickUS']
# dfTidy.loc[~dfTidy.eventType.isin(eventsToInclude),'eventType']= pd.NA

#REPLICATE matlab
# eventsToInclude= ['DStime','NStime','PEtime','lickTime']
# dfTidy.loc[~dfTidy.eventType.isin(eventsToInclude),'eventType']= pd.NA


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
        

#%% Define peri-event z scoring parameters
fs= 40

preEventTime= 5 *fs # seconds x fs
postEventTime= 10 *fs

#time window to normalize against
baselineTime= 10*fs

#%% NORMALIZE photometry signal

#TODO: may want to add some random trialStart time 'jitter' to add variation to cue onset times for regression (will currently always be t=0)

#Going to 
#1) Z-score normalize fp signal trial-by-trial relative to pre-cue baseline
#2) Exclude data and restrict analysis to only DS or NS trial-by-trial (instead of whole FP signal)

#-- Get Z-scored photometry signal

#Iterate through files using groupby() and conduct peri event Z scoring
#iterating through fileID to gurantee no contamination between sessions
 
groups= dfTidy.groupby('fileID')

#currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial 
    
for name, group in groups:
    for signal in contVars: #loop through each signal (465 & 405)
        #-- peri-DS 
        z, timeLock=  zscoreCustom(group, signal, 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
        dfTidy.loc[group.index,signal+'-z-periDS']= z
        dfTidy.loc[group.index,'timeLock-z-periDS']= timeLock

        
        #-- peri-NS 
        z, timeLock=  zscoreCustom(group, signal, 'NStime', preEventTime, postEventTime,'NStime', baselineTime)
        dfTidy.loc[group.index,signal+'-z-periNS']= z
        dfTidy.loc[group.index,'timeLock-z-periNS']= timeLock
    
test= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()]

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


#%% Retain only First event per trial ??
#Exclude all others (make nan)... TODO: consider renaming column so we know difference  name + 'First'

dfTemp= dfTidy.copy()

# dfTemp= dfTemp.pivot(columns='eventType')['cutTime'].copy()

    
# test= dfTemp.groupby(['fileID','trialID','eventType'], as_index=False)['eventType'].cumcount()

# test= dfTemp.groupby(['fileID','trialID','eventType']).cumcount()

# # ind= dfTemp.groupby(['fileID','trialID','eventType'], observed=True).cumcount()==0

# # test= dfTemp.loc[ind]

# #get ind of all events after First for each trial, then replace times w nan

ind= dfTemp.groupby(['fileID','trialID','eventType'], observed=True).cumcount()!=0

count= dfTemp.groupby(['fileID','trialID','eventType'], observed=True).cumcount()

#%TODO ----------------------Replace these with clearer eventType instead of erasing

# dfTemp.loc[ind, 'eventType']= dfTemp.eventType+'notFirst'


#simply make eventType nan
dfTemp.loc[ind, 'eventType']= None

# #Or- this works:
# #label cumcount?
# #eventType= eventType + cumcount
# dfTemp.eventType= dfTemp.eventType.astype(str)
# dfTemp.loc[ind, 'eventType']= dfTemp.eventType + count.astype(str)

# dfTemp.eventType= dfTemp.eventType.astype('category')


    
dfTidy.eventType= dfTemp.eventType.copy()
#%% CORRELATION between eventTypes

# should run on periEventTimeLock (time relative to trialStart)

# how correlated are events going into our model?
#should run on eventTime before converting to binary coded?

dfTemp= dfTidy.pivot(columns='eventType')['cutTime'].copy()

dfTemp= dfTemp[eventVars]

#need to groupby or set index to get each time per trial

#subset DS trials
dfTemp= dfTidy.loc[dfTidy.trialType=='DStime']

#try corr with set ind ?

# dfTemp= dfTidy.copy()

# dfTemp= dfTemp.set_index(['stage','subject','fileID','trialType','trialID'])

# dfTemp2= dfTemp.pivot(columns='eventType')['cutTime'].copy()

# #doesn't seem to matter if set_index()

#-----Timelock-sensitive (relative timestamp correlation- good):

    #--DS

#pivot eventType into columns, append, drop old col
dfTemp= dfTidy.pivot(columns='eventType')['timeLock-z-periDS'].copy()
#index matches so simple join
dfTemp= dfTidy.join(dfTemp.loc[:,eventVars]).copy()
dfTemp= dfTemp.drop(['eventType'], axis=1)

#get all of the first events for each trial, grouped by trialType

#will need to isolate eventTypes by trialType for this to work (na observations for events that don't occur)
#limited to trials where all events are recorded


#TODO: could be embedded in a groupby trialType.groups loop

# groupers= ['stage','subject','fileID','trialType','trialID']

groupHierarchyTrialType= ['stage','trainDayThisStage', 'subject','trialType']
groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialID']

#--DS trials correlation
corrInput= dfTemp.groupby(groupHierarchyTrialID, observed=True, as_index=False)[eventVars].first()    

#subset DS trials and drop events that don't occur (NStime)
corrInput= corrInput.loc[corrInput.DStime.notnull()]
corrInput= corrInput.dropna(axis=1, how='all')
corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]

corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()
g= sns.pairplot(data=corr)
g.fig.suptitle('DS trial event correlations')


corr= corrInput.groupby(['stage','subject','trialType'])[corrEvents].corr()

g= sns.pairplot(data=corr)
g.fig.suptitle('DS trial event correlations')

#pairplot of just time(not coef)
dfPlot= corrInput[corrEvents]
g= sns.pairplot(data=dfPlot)

#pairplot of just time(not coef)
dfPlot= corrInput[corrEvents]
g= sns.lmplot(data=dfPlot)

#want to viz better, reorganize
dfPlot= corr.reset_index().melt(id_vars= groupHierarchyTrialType, value_vars= corrEvents, value_name= 'eventType')

corr= corrInput.groupby(['stage','subject','trialType'])[corrEvents].corr()


#------Timelock-agnostic (absolute timestamp correlation version) :
#try groupby
#pivot eventType into columns, append, drop old col
dfTemp= dfTidy.pivot(columns='eventType')['cutTime'].copy()
#index matches so simple join
dfTemp= dfTidy.join(dfTemp.loc[:,eventVars]).copy()
dfTemp= dfTemp.drop(['eventType'], axis=1)


#get all of the first events for each trial, grouped by trialType

#will need to isolate eventTypes by trialType for this to work (na observations for events that don't occur)
#limited to trials where all events are recorded


#TODO: could be embedded in a groupby trialType.groups loop

# groupers= ['stage','subject','fileID','trialType','trialID']

groupHierarchyTrialType= ['stage','trainDayThisStage', 'subject','trialType']
groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialID']

#--DS trials correlation
corrInput= dfTemp.groupby(groupHierarchyTrialID, observed=True, as_index=False)[eventVars].first()    

#subset DS trials and drop events that don't occur (NStime)
corrInput= corrInput.loc[corrInput.DStime.notnull()]
corrInput= corrInput.dropna(axis=1, how='all')
corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]

#drop trials without all events? corr should handle this
# corrInput= corrInput.dropna(axis=0, how='any')

corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()

# corr= corr.reset_index()

# dfPlot= corr[corrEvents+'subject']

# sns.pairplot(data= corr, hue='subject')

g= sns.pairplot(data=corr)
g.fig.suptitle('DS trial event correlations')
g.set(ylim= [0,1.1])

#-- NS trials correlation

corrInput= dfTemp.groupby(groupHierarchyTrialID, observed=True, as_index=False)[eventVars].first()    

#subset NS trials and drop events that don't occur (NStime)
corrInput= corrInput.loc[corrInput.NStime.notnull()]
corrInput= corrInput.dropna(axis=1, how='all')
corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]


corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()

sns.pairplot(data=corr)
sns.suptitle('NS trial event correlations')


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

#keep same time shift parameters as periEvent
fs=  fs

preEventTime= preEventTime
postEventTime= postEventTime


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
        

#I think groupby operations on sparse df  may be inefficient 
# groups= dfTemp.copy().groupby(['fileID']) #was working
#restricting columns here may save time
col= eventsToInclude+['fileID']
groups= dfTemp[col].copy().groupby(['fileID'])



# #attempt 5-- WORKED! (very slow, idk how long)
# #~2s/ iteration so ~10s/shift with 5 events
for eventCol in eventVars.categories:
    for shiftNum in np.arange(-preEventTime,postEventTime):
        #note fill_value=0 here will fill the beginning and end of session with 0 instead of nan (e.g. spots where there are no valid timestamps to shift())
        dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= groups[eventCol].shift(shiftNum,fill_value=0)
        # startTime = time.time()
        
        #####your python script#####
        dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= groups[eventCol].shift(shiftNum,fill_value=0)
    
    
        # executionTime = (time.time() - startTime)
        # print('Execution time in seconds: ' + str(executionTime))
        

#TODO: try shift entire df then assign to col? also try unsorted groupby?

# #attempt 6- failed, MEMORY ERROR @ col 3622
# #without sparse df preallocation ~9.5s/ 
# #~9s with sparse preallocation
# for shiftNum in np.arange(-preEventTime,postEventTime):
#     startTime = time.time()
    
#     #####your python script#####
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= groups.shift(shiftNum,fill_value=0)[eventVars]


#     executionTime = (time.time() - startTime)
#     print('Execution time in seconds: ' + str(executionTime))
    


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

#%% Isolate DS & NS data, SAVE as separate datasets
#Restrict analysis to specific trialType

#just get index of each and save as separate datasets. this way can load quickly and analyze separately

savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

print('saving regression input dfTemp to file')

ind= dfTemp['timeLock-z-periDS'].notnull()
dfTemp.loc[ind].to_pickle(savePath+'dfRegressionInputDSonly.pkl')


ind= dfTemp['timeLock-z-periNS'].notnull()
dfTemp.loc[ind].to_pickle(savePath+'dfRegressionInputNSonly.pkl')

#update list of contVars to include normalized fp signals
contVars= list(dfTemp.columns[(dfTemp.columns.str.contains('reblue') | dfTemp.columns.str.contains('repurple'))])

#also save other variables e.g. variables actually included in regression Input dataset (since we may have excluded specific eventTypes)
saveVars= ['idVars', 'eventVars', 'contVars', 'trialVars', 'experimentType', 'stagesToInclude', 'nSessionsToInclude', 'preEventTime','postEventTime', 'fs']


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

#%% SAVE the data
# #should save time if there's a crash or something later

# savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

# print('saving regression input dfTemp to file')

# #Save as pickel
# dfTemp.to_pickle(savePath+'dfRegressionInput.pkl')


# #also save other variables e.g. variables actually included in regression Input dataset (since we may have excluded specific eventTypes)
# saveVars= ['idVars', 'eventVars', 'trialVars', 'experimentType', 'stagesToInclude', 'nSessionsToInclude', 'preEventTime','postEventTime', 'fs']


# #use shelve module to save variables as dict keys
# my_shelf= shelve.open(savePath+'dfRegressionInputMeta', 'n') #start new file

# for key in saveVars:
#     try:
#         my_shelf[key]= globals()[key] 
#     except TypeError:
#         #
#         # __builtins__, my_shelf, and imported modules can not be shelved.
#         #
#         print('ERROR shelving: {0}'.format(key))
# my_shelf.close()

    

# #%% IF needed load 
# dataPath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

# dfTemp= pd.read_pickle(dataPath+'dfRegressionInput.pkl')

# #load any other variables saved during the import process ('dfTidymeta' shelf)
# my_shelf = shelve.open(dataPath+'dfTidymeta')
# for key in my_shelf:
#     globals()[key]=my_shelf[key]
# my_shelf.close()


# # #%% RUN REGRESSION?
# # #TODO: How to handle different subjects? should run separately in loop or use as predictor?
# #unlike matlab version of code this is one big table with everything

# #TESTING with subset
# # dfTemp= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.min()]

# # test= dfTemp.iloc[:,20]
# # test2= test.unique()

# #Run separately on each subject
# #finding now that groupby with sparse dtypes may be very slow...
# groups= dfTemp.groupby(['subject'])

# for name, group in groups:
#     #define predictor and response variables
#     #predictors will be all remaining columns that are not idVars or contVars
#     col= ~group.columns.isin(idVars+contVars)
#     X = group.loc[:,col]
    
#     #--Remove invalid observations 
#     #pd.shift() timeshift introduced nans at beginning and end of session 
#     #(since there were no observations to fill with); Exclude these timestamps
#     #regression inputs should not have any nan & should be finite; else  will throw error
#     #--shouldn't happen now since fill_values=0
#     # dfTemp= dfTemp.loc[~X.isin([np.nan, np.inf, -np.inf]).any(1),:]
    
#     X = group.loc[:,col]
    
#     # #examining input data
#     # np.any(np.isnan(X))
#     # np.all(np.isfinite(X))
    
    
#     #regressor is fp signal
#     y = group["reblue"]
    
#     #define cross-validation method to evaluate model
#     cv = RepeatedKFold(n_splits=5, n_repeats=3, random_state=1)
    
#     #define model
#     model = LassoCV(alphas=np.arange(0, 1, 0.01), cv=cv, n_jobs=-1)
    
#     #fit model
#     model.fit(X, y)
    
#     #display lambda that produced the lowest test MSE
#     print(model.alpha_)


# #%% Visualize kernels

# #coefficients: 1 col for each shifted version of event timestamps in the range of timeShifts. events ordered sequentially

# kernels= pd.DataFrame()

# b= model.coef_

# for eventCol in range(len(eventVars)):
#     if eventCol==0:
#         ind= np.arange(0,(eventCol+1)*len(np.arange(-preEventTime,postEventTime)))
#     else:
#         ind= np.arange((eventCol)*len(np.arange(-preEventTime,postEventTime)),((eventCol+1)*len(np.arange(-preEventTime,postEventTime)-1)))
   
#     kernels[(eventVars[eventCol]+'-coef')]= b[ind]


# #%% 

# #Establish hierarchical grouping for analysis
# #want to be able to aggregate data appropriately for similar conditions, so make sure group operations are done correctly
# groupers= ['subject', 'trainDayThisStage', 'fileID']