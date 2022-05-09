# -*- coding: utf-8 -*-
"""
Created on Thu Jan  6 21:34:31 2022

@author: Dakota
"""

#%% import dependencies
import pandas as pd
import glob
import os
import numpy as np
import shelve
import seaborn as sns

# import dask.dataframe as dd

#%% About:

#this script imports data table from matlab for tidying and analysis in python


#ALT version of import script that tidies eventVars

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
experimentType= 'photometry'

# # datapath= r"C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\vp-vta-fp-07-Jan-2022.parquet"
# datapath= r"C:\Users\Dakota\Documents\GitHub\FP-analysis\python\_input\vp-vta-fp-03-Mar-2022.parquet"

# #noartifact 
# datapath= r"C:\Users\Dakota\Documents\GitHub\FP-analysis\python\_input\noartifact-vp-vta-fp-05-Apr-2022.parquet"

datapath= r"C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\vp-vta-fp-20-Apr-2022.parquet"

#%% ID and import Parquet file 
df= pd.read_parquet(datapath)

#% todo: consider using Dask instead of Pandas
#good for very large memory data (e.g. photometry time series)
# df= dd.read_parquet(datapath)

# %% Exclude data

excludeDate= [] # ['20210604']

# Exclude specific date(s)
df= df[~df.date.isin(excludeDate)]

# #hitting memory cap, going to subset specific stages to reduce data (shouldn't really need anything below stage 3)
stagesToInclude= [1.,2.,3., 4., 5.0]#, 6.0, 7.0, 8., 11.0, 12.0]
# 
# stagesToInclude= [5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0]
# stagesToInclude= df.stage.unique()
df= df.loc[df.stage.isin(stagesToInclude)]

#still hitting, so going to subset even further for debugging
# df= df.iloc[0:1000000]

# %% Remove parentheses from variable names 

import re
#use regex to replace text between () with empty string
#loop through each column name, remove characters between () and collect into list 'labels'
labels= []
for col in df.columns:
    labels.append(re.sub(r" ?\([^)]+\)", "", col))
#rename columns to labels
df.columns= labels

# %% Add other variables if necessary before tidying

#add cue duration variable by stage (using dict here)
stages= [4,5,7]
cueDur= [10,10,10]
# stages= [1,2,3,4,5]
# cueDur= [60,30,20,10,10]
# stages= [1,2,3,4,5,6,7,8,9,10,11,12]
# cueDur= [60,30,20,10,10,10,10,10,10,10,10,10]


fs= 40 #fp 40hz

for thisStage in range(len(stages)):
    df.loc[df.stage==stages[thisStage],'cueDur']= cueDur[thisStage]



#convert 'date' to datetime format
# df.date= pd.to_datetime(df.date)


#removing trainDay since we'll calculate it below
df= df.drop('trainDay',axis=1)

#also renaming DS and NS columns to match DS training code so everything works straightforward
df= df.rename(columns={'DS':'DStime', 'NS':'NStime'})

#rename events to match other code as well
df= df.rename(columns={'pox':'PEtime', 'lox':'lickTime', 'pumpTime':'UStime'})

#%% examine memory usage and dtypes

df.memory_usage(deep=True)  # memory usage in bytes 
df.dtypes

#change dtypes if needed
# df.cutTime=df.cutTime.astype('float64')
df.fileID= df.fileID.astype('int')

#%% Define Event variables for your experiment 
#make a list of all of the Event Types so that we can melt them together into one variable
#instead of one column for each event's timestamps, will get one single column for timestamps and another single column for the eventType label

#these should match the labels in your .MPC file

## e.g. for DS task with no Opto  
# eventVars= ['PEtime',  'PExEst', 'lickTime', 'DStime', 'NStime', 'UStime']

# #e.g. for DS task with Opto
# if experimentType.__contains__('Opto'):
#     eventVars.extend(['laserTime'])
#     #eventVars= ['PEtime', 'PExEst', 'lickTime', 'laserTime', 'DStime', 'NStime', 'UStime']#,'laserOffTime']

# #ICSS
# if experimentType== 'ICSS':
#     eventVars= ['activeNP', 'inactiveNP', 'laserTime']
    
# #instrumental transfer + opto
# if experimentType== 'OptoInstrumentalTransfer':
#     # eventVars= ['activelp','inactivelp','rewardtimestamps','PortEntry', 
#     #             'PEtime', 'PExEst', 'lickTime', 'DStime', 'NStime', 'UStime',
#     #             'laserTime', 'laserOffTime']
#     eventVars.extend(['activeLPtime','inactiveLPtime','rewardTime', 'laserOffTime'])

eventVars= ['PEtime',  'lickTime', 'out', 'DStime', 'NStime', 'UStime']


#%% Define ID variables for your sessions
#these are identifying variables per sessions that should be matched up with the corresponding event variables and timestamps
#they should variables in your session and subject metadata spreadsheets

## e.g. for DS task with no Opto
# idVars= ['fileID','subject', 'virus', 'sex', 'date', 'stage', 'cueDur', 'note']

#working with what I have now from matlab table:
    # TODO: add additional idvars in matlab for simplicity? or could use metadata sheet like DStraining code
idVars= ['fileID','subject', 'date', 'stage', 'cutTime', 'cueDur']


#%% Define continuous variables for your sessions
# continuously sampling multiple variables
# e.g. for photometry, calcium-dependent and isosbestic signals could be faceted/grouped/analyzed more dynamically
# guessing things that would also fit here include things like continuously sampled kinematics or ephys data 

#could melt them but probably not worthwhile since # timestamps would double, just treat as separate vars 

contVars= ['reblue','repurple']



#%% Define Trial variables for your experiment
# If you have variables corresponding to each individual trial 
#e.g. different trial types in addition to DS vs NS (e.g. laser ON vs laser OFF trials; TODO: variable reward outcome)
#TODO: consider making cueType it's own trialVar... then can use for stats easy later on

trialVars= []

#e.g. for Opto:
if  experimentType.__contains__('Opto'):
    trialVars= ['laserDStrial','laserNStrial']
    #the laserDStrial and laserNS trial variables will later be melted() into a new variable called 'laserState' with their values


#%% Change dtypes of variables if necessary (might help with grouping & calculations later on)

#binary coded 0/1 laser variables were being imported as floats, converting them to pandas dtype Int64 which supports NA values
if experimentType.__contains__('Opto'):
    df.loc[:,(trialVars)]= df.loc[:,(trialVars)].astype('Int64')
    
#change stage to str dtype
#this is memory intensive I think so skipping
# df.stage= df.stage.astype('str')azsx


#%% Tidying: All events in single column, add trialID and trialType that matches trial 1-60 through each session.

#% consolidate event vars into single column

#basically would want to 1 row per ts (because of continuous fp signal), with additional row per actual event (event==1 only)
#column would be composed of identifier of event corresponding to timestamp

#subsetting for debugging

#!!!!!TODO: update here for non binary timestamps


#--strategy: melt(), drop 0 values (no event), then remerge back on full df cutTime

dfTemp = df.melt(id_vars=idVars, value_vars=eventVars, var_name='eventType', value_name='eventTime').copy()

dfTemp = dfTemp[dfTemp.eventTime != 0]

dfTemp= dfTemp.loc[:,['fileID','cutTime','eventType', 'eventTime']]

#add new cutTime values corresponding to eventTime prior to merge
# dfTemp.cutTime= dfTemp.eventTime
 
#instead of matching values exactly, find the *closest* time bin in cutTime. Keep the RAW eventTime but place it in this bin
# dfTemp.cutTime= dfTemp.groupby(['fileID'])

#sharing index with cutTime would save on memory...could just have non matching index but would like alignment)


#wayy too slow
# dfTemp= dfTemp.set_index('fileID')

# for ts in dfTemp.eventTime.unique():
#     result_index = dfTemp['cutTime'].sub(ts).abs().idxmin()

    
# result_index = dfTemp['cutTime'].sub(dfTemp.eventTime.unique()).abs().idxmin()

# params = df.iloc[(df['cutTime']-dfTemp.eventTime.unique()).abs().argsort()[:1]]


#try combining the two columns- this gets everything into one col at least
# dfTemp= dfTemp.set_index('fileID')

# test= pd.concat([dfTemp.cutTime,dfTemp.eventTime])

# dfTemp['time2']= pd.concat([dfTemp.cutTime,dfTemp.eventTime]) #memory error

#could try merging(), labelling as cuttime or eventTime, then groubpy and diff() to find nearest bin?
#memory error
# dfTemp= dfTemp.melt(id_vars='fileID', value_vars=['cutTime','eventTime'], value_name='time2')
 
#could try simply filling eventTime with cutTime, then sorting, then getting diff? real event times will have non-null eventTypes
# dfTemp.loc[:,'eventTime']= dfTemp.groupby(['fileID'])['']

# #try setting index on both and merging? #memory error
# dfTemp2= dfTemp.set_index('cutTime')
# dfTemp3= dfTemp.set_index('eventTime')
# dfTemp4= dfTemp2.merge(dfTemp3, how='outer')


# #drop the old binary coded vars prior to merge (save memory)
df.drop(eventVars,axis=1, inplace=True)

#try merge_asof to merge on closest timestamp https://towardsdatascience.com/how-to-merge-not-matching-time-series-with-pandas-7993fcbce063

#overwrite melted() cutTime with eventTime (we'll use this to merge)
dfTemp.cutTime= dfTemp.eventTime

dfTemp= dfTemp.sort_values(['fileID','cutTime'])

# test= pd.merge_asof(dfTemp.cutTime, dfTemp.eventTime) #, tolerance= 1/fs) #dont use tolerance, might remove eventTimes and shouldn't be a big deal
# test= pd.merge_asof(df, dfTemp, on=['fileID','cutTime'], direction='nearest') #, tolerance= 1/fs) #dont use tolerance, might remove eventTimes and shouldn't be a big deal


test= df.loc[df.fileID.isin([1,2])]
test2= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.isin([1,2])]

#sort prior to merge
test= test.sort_values(['fileID','cutTime'])
test2= test2.sort_values(['fileID','cutTime'])


# #try multiindex?
# df_merged = pd.merge_asof(test, test2,
#                      left_on=['cutTime'], right_on=['cutTime'],by='fileID',
#                      suffixes=('', '_2')
#                      )

# df_merged = pd.merge_asof(left=df1.reset_index(), right=df2.reset_index(),
#                      left_on=['timestamps_df1'], right_on=['timestamps_df2'],by='some_keys',
#                      suffixes=('', '_2')
#                      )


# #remove null eventTimes prior to merge
test2= test2.loc[test2.eventTime.notnull()]

# test3= pd.merge_asof(test, test2, on=['cutTime'], direction='backward') #, tolerance= 1/fs) #dont use tolerance, might remove eventTimes and shouldn't be a big deal

# #getting weird errors.... try on groups?
# for name, group in df.groupby(['fileID']):
#     test= group
#     test2= dfTemp.loc[name]


#works?? #why creating duplicate events though?????
test4= pd.merge_asof(test.sort_values(['cutTime']),test2.sort_values(['cutTime']),on=['cutTime'], by=['fileID'], direction='nearest')


test5= pd.merge_asof(test2.sort_values(['cutTime']),test.sort_values(['cutTime']),on=['cutTime'], by=['fileID'], direction='nearest')

# #nope?? https://stackoverflow.com/questions/57919854/pandas-merge-asof-giving-duplicate-matches
# # The actual output is the expected behavior: merge_asof(left, right) finds for every row in left the nearest row in right (within the tolerance limits). What you want is slightly different: you want to find the one row in left that is nearest to right. I'm afraid there's no built-in function for this in pandas.

# #so try 
# x = pd.merge_asof(test, test2.reset_index(), left_on='cutTime', right_on='cutTime',by=['fileID']
#               direction='nearest')

# x= pd.merge_asof(test.sort_values(['cutTime']),test2.reset_index().sort_values(['cutTime']),on=['cutTime'], by=['fileID'], direction='nearest')

#this seems to work!!!
x= pd.merge_asof(test2.sort_values(['cutTime']),test.reset_index().sort_values(['cutTime']),on=['cutTime'], by=['fileID'], direction='nearest')


merged_df=  test.merge(x[['index','eventType','eventTime']], how='left', left_index=True, right_on='index').set_index('index')

# merged_df = df1.merge(x[['df2_col','index']], how='left', left_index=True, right_on='index').set_index('index')


# test3= pd.merge_asof(test, test2, on=['cutTime'], by=['fileID'])

# test= test.dropna()
# test2= test2.dropna()
# test3= pd.merge_asof(test, test2, on=['cutTime'], by=['fileID'])



# #got result but want to merge on fileID too so set index
# test= test.set_index(['fileID','cutTime'])
# test2= test2.set_index(['fileID','cutTime'])


# # test3= pd.merge_asof(test, test2, left_index=True, right_on=['fileID','cutTime'], direction='backward') #, tolerance= 1/fs) #dont use tolerance, might remove eventTimes and shouldn't be a big deal
# # test3= pd.merge_asof(test, test2, left_on=['fileID','cutTime'], right_index=True, direction='backward') #, tolerance= 1/fs) #dont use tolerance, might remove eventTimes and shouldn't be a big deal
# # test3= pd.merge_asof(test2, test, left_on=['fileID','cutTime'], right_index=True, direction='backward') #, tolerance= 1/fs) #dont use tolerance, might remove eventTimes and shouldn't be a big deal

# test3= pd.merge_asof(test, test2, on=['cutTime'], by=['fileID'])

# # test= pd.merge_asof(df, dfTemp, on=['cutTime'], direction='backward') #, tolerance= 1/fs) #dont use tolerance, might remove eventTimes and shouldn't be a big deal

# #merge ordered?
# # https://pandas.pydata.org/docs/reference/api/pandas.merge_ordered.html#pandas.merge_ordered

# test= df.loc[df.fileID==df.fileID.min()]
# test2= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.min()]
# # test3= pd.merge_ordered(test, test2, on='cutTime', left_by=['fileID'])
# test3= pd.merge_ordered(test, test2, on=['fileID','cutTime'])




# #inspecting
# test= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.min()]


# test2= df.merge(test, on=['fileID','cutTime'], how='outer')

# test3= test2.loc[test2.fileID==test2.fileID.min()]

#merge back into df on cutTime, but outer join since some eventTimes won't be in cutTime?
#seems ok but probably would be best to minimize new rows
# df= df.merge(dfTemp, on=['fileID','cutTime'], how='left')
# df= df.merge(dfTemp, on=['fileID','cutTime'], how='outer')

#MERGE- find the nearest matching index for each eventTime and merge back on this
 # https://stackoverflow.com/questions/57919854/pandas-merge-asof-giving-duplicate-matches
# # The actual output is the expected behavior: merge_asof(left, right) finds for every row in left the nearest row in right (within the tolerance limits). What you want is slightly different: you want to find the one row in left that is nearest to right. I'm afraid there's no built-in function for this in pandas.

#so try 
#merge_asof needs 1) no nans, 2) sorted
dfTemp= dfTemp.loc[dfTemp.eventTime.notnull()]

dfTemp= pd.merge_asof(dfTemp.sort_values(['cutTime']),df.reset_index().sort_values(['cutTime']),on=['cutTime'], by=['fileID'], direction='nearest')

df=  df.merge(dfTemp[['index','eventType','eventTime']], how='left', left_index=True, right_on='index').set_index('index')

#reset index now (there are duplicates if events happened at same cutTime, so make unique index
df= df.reset_index(drop=True) 

del dfTemp

# # #after merging, drop the old binary coded vars
# df.drop(eventVars,axis=1, inplace=True)

#inspecting
test= df.loc[df.fileID==df.fileID.min()]


# df= df.merge(dfTemp, on=['fileID'], how='left')



#examining

test= df.loc[df.fileID==df.fileID.min()]

#instead of merging, simple reassignment
# df = df.melt(id_vars=idVars, value_vars=eventVars, var_name='eventType', value_name='eventTime').copy()



#create eventTime column (redundant with cutTime, but should allow DStrain code to work easily)
# df.loc[df.eventType.notnull(),'eventTime']= df.
# df.loc[df.eventType.notnull(),'eventTime']= df.cutTime





#copy eventTimes to cutTime (event timestamps that aren't already in cutTime)
# df.loc[df.cutTime.isnull(), 'cutTime']= df.eventTime


# #Remove all rows with NaN eventTimes (these are just placeholders, not valid observations) 
# #shouldn't do with photometry since have continuous variables 1 value per timestamp
# # df= df[df.eventTime.notna()]

# # remove invalid/placeholder 0s
# # TODO: seem to be removing legitimate port exits with peDur==0, not sure how to deal with this so just excluding
# df = df[df.eventTime != 0]

# add trialID column by cumulative counting each DS or NS within each file
# now we have ID for trials 0-59 matching DS or NS within each session, nan for other events
df['trialID'] = df[(df.eventType == 'DStime') | (
    df.eventType == 'NStime')].groupby('fileID').cumcount()

#add trialType label using eventType (which will be DS or NS for valid trialIDs)
# df['trialType']= df[df.trialID.notna()].eventType

#dp 1/11/21 seems to be more efficient way of indexing
# df['trialType']= df.loc[df.trialID.notna(),'eventType']

#3/4/22
#duplicates in index?
# test= df.loc[df.index.duplicated()]

df.loc[df.trialID.notna(),'trialType']= df.eventType



#%% Assign more specific trialTypes based on trialVars (OPTO ONLY specific for now)
if experimentType.__contains__('Opto'):
    # melt() trialVars, get trialID for each trial and use this to merge label back to df 
    dfTrial = df.melt(id_vars= idVars, value_vars=trialVars, var_name='laserType', value_name='laserState')#, ignore_index=False)
    #remove nan placeholders
    dfTrial= dfTrial[dfTrial.laserState.notna()]
    
    #get trialID
    dfTrial['trialID'] = dfTrial.groupby('fileID').cumcount() 
    
    #merge trialType data back into df on matching fileID & trialID
    df= df.merge(dfTrial[['trialID', 'fileID', 'laserType', 'laserState']], on=[
        'fileID', 'trialID'], how='left')#.drop('trialID', axis=1)
    
    #combine laserState and laserType into one variable for labelling each trial: trialType
    #Exclude the Lick-paired laser sessions. We will label those using a different method below  
    # df.loc[((df.laserDur!='Lick')&(df.laserDur.notnull()&(df.trialID.notnull()))), 'trialType'] = df.trialType.copy() + \
    #     '_'+df.laserState.astype(str).copy()
    # dfTemp= df.loc[((df.laserDur!='Lick')&(df.laserDur.notnull())&(df.trialID.notnull()))] .copy()
    
    dfTemp= df.loc[((df.laserDur!='Lick')&(df.laserState.notnull())&(df.trialID.notnull()))].copy()
    
    # df.loc[((df.laserDur!='Lick')&(df.laserState.notnull()&(df.trialID.notnull()))), 'trialType'] = dfTemp.trialType.copy() + \
    #     '_'+dfTemp.laserState.astype(str).copy()
    df.loc[((df.laserDur!='Lick') & (df.laserState==1) & (df.trialID.notnull())), 'trialType'] = dfTemp.trialType.copy() + \
        '_'+'laser'#dfTemp.laserState.astype(str).copy()
    
    #now drop redundant columns
    # df= df.drop(['laserType','laserState'], axis=1)
     
    
#%% Change dtypes for categorical vars (saves memory & good for plotting & analysis later)
df.trialType= df.trialType.astype('category')
df.trialType.cat.add_categories(['Pre-Cue','ITI'], inplace=True)

df.stage= df.stage.astype('category')
# df.eventType= df.eventType.astype('category')


if experimentType== 'Opto':
    df.laserDur= df.laserDur.astype('category')


#%% Melt() continuous variables?
# # # greatly increses mem usage so need to do something else here?
# ## doubles timestamps so not actually worth doing

# # test= df.loc[1:1000].copy()

# # test= test.melt(id_vars=idVars+['eventTime']+['eventType']+['trialID']+['trialType'], value_vars=contVars, var_name='signalType', value_name='fpSignal')


# # df= df.melt(id_vars=idVars+['eventTime']+['eventType']+['trialID']+['trialType'], value_vars=contVars, var_name='signalType', value_name='fpSignal')


#%% Exclude false cue times due to MPC code bugs
#need to get rid of false first cue onsets
#DS training code error caused final cue time to overwrite first cue time (dim of array needed to be +1)
#TODO: I think we do have the US times so could still do analyses of those

# test= df.loc[0:1000,:].copy()

# test= test.loc[test.groupby(['fileID'])['trialID'].cumcount()==0].eventTime.copy()


# test= df.loc[df.groupby(['fileID'])['trialID'].cumcount()==0].eventTime.copy()

# #simply exclude very high first cue values
idx= df.copy().loc[((df.trialID==0) & (df.eventTime>=2500))].index


#dp 1/11/2022 trying more memory efficient
#does not appear that this bug was present in photometry sessions so skipping
df.loc[(df.trialID==0) & (df.eventTime>=2500), 'eventTime']= pd.NA

print('False first DS cue removed, fileIDs:'+ (np.array2string(df.loc[idx].fileID.sort_values().unique())))

#cannot use eventTime to do this for time series! #could use cuttime?

df.loc[idx,'cutTime']=pd.NA 
df= df.loc[df.cutTime.notnull()]

# Fix separate bug before 11/5/2021 in the 'siren control' state set. 
#The bug could cause the last NS timestamp to be logged as an extra DS. 

# Ideal solution would be to check if last DS and NS for each file are equal (diff==0)
# something like-
# dfTemp= df.loc[((df.eventType=='NStime')|(df.eventType=='DStime'))].copy()

# # test= dfTemp.groupby(['fileID','eventType'])['eventTime'].transform('diff')


#Instead, as bandaid can just check if we've got an extra DS cue and remove it
maxTrials= 29 #30 trials, so max of 29 if starting count @ 0
dfTemp= df.loc[df.eventType=='DStime'].copy()

idx= dfTemp.copy().groupby(['fileID']).eventTime.transform('cumcount')>maxTrials

idx= idx.loc[idx==True].index

# #testing a specific session with known issue
# dfTemp= dfTemp.loc[dfTemp.date=='2021-10-06T00:00:00.000000000'].copy()
# # test= dfTemp.groupby(['fileID']).eventTime.cumcount()

# test= dfTemp.groupby(['fileID']).eventTime.transform('cumcount')

# idx= dfTemp.groupby(['fileID']).eventTime.transform('cumcount')>=maxTrials

# dfTemp.loc[idx,:]= [[pd.NA]]

#simply drop these false cue entries
print('False final DS cue removed, fileIDs:'+ (np.array2string(dfTemp.loc[idx].fileID.sort_values().unique())))
df= df.drop(idx).copy()

#reset the index since values are now missing
df.reset_index(drop=True, inplace=True)

#%% Sort by eventType (to ensure correct trialID ffill)

# df= df.sort_values(['fileID','cutTime','eventType'])

#sort by time, trialID within file making sure that the Trial events (cues) are first

df= df.sort_values(['fileID','cutTime','trialID'])


#% dp 3/7/22 finding UStime with same timestamp as DStime being assigned to ITI instead of trial (must be from inport trial)

# #by chance the UStime is simply ordered in the index prior to the cue so ffill doesn't work... it's just falling into ITI
# test= df.loc[df.fileID==df.fileID.min()]

# #for these cases, subset equivalent timestamps and manually assign trialID & trialStart
# dfTemp= df.copy()

#-==--dp 3/7/22
#check if any nextTrialStart are equal to this timestamp, if so, trialID should updated to that trial.
# dfTemp2= dfTemp.loc[dfTemp.eventTime==dfTemp.nextTrialStart]


#%% dp 1/17/22
#Try new direct timestamp trialID & trialType approach. works w no issues



dfTemp= df.loc[(df.eventType=='DStime')|(df.eventType=='NStime')].copy()

#+1 to trialID so it doesn't start at 0 (could cause issues with negative trialID)
dfTemp.loc[:,'trialID']= dfTemp.groupby(['fileID']).cumcount()+1
dfTemp.loc[(df.eventType=='DStime'),'trialType']= 'DStime'
dfTemp.loc[(df.eventType=='NStime'),'trialType']= 'NStime'


df.loc[:,'trialID']= dfTemp.trialID
df.loc[:,'trialType']= dfTemp.trialType

df.loc[:,'trialStart']= dfTemp.cutTime

#assume entire cue duration here
df.loc[:,'trialEnd']= dfTemp.cutTime+dfTemp.cueDur

#use 10s as pre-cue time
preCueDur= 10;

df.loc[:,'preTrialStart']= dfTemp.cutTime-preCueDur


# dfTemp.loc[:,'nextTrialStart']= dfTemp.groupby(['fileID','trialID'])['trialStart'].shift(-1).copy()


#make manual exception for ts before first trialStart
dfTemp=df.copy()

dfTemp.loc[:,'firstTrial']= dfTemp.groupby('fileID')['trialStart'].transform('first')


dfTemp.loc[dfTemp.cutTime<dfTemp.firstTrial, 'trialID']= 999
dfTemp.loc[dfTemp.cutTime<dfTemp.firstTrial, 'trialStart']= 0

#TODO: make first trialEnd= first preCue start

df= dfTemp.copy()

#--Now that we have timings for each trial, define events within epochs
#first should be able to ffill(), then can use that to groupby() and relabel for pre-cue?

dfTemp= df.copy()

dfTemp.trialID= dfTemp.groupby(['fileID'])['trialID'].fillna(method='ffill')
dfTemp.trialStart= dfTemp.groupby(['fileID'])['trialStart'].fillna(method='ffill')
dfTemp.trialEnd= dfTemp.groupby(['fileID'])['trialEnd'].fillna(method='ffill')
dfTemp.preTrialStart= dfTemp.groupby(['fileID'])['preTrialStart'].fillna(method='ffill')

dfTemp.trialType= dfTemp.groupby(['fileID'])['trialType'].fillna(method='ffill')

df= dfTemp.copy()

#--save nextTrialStart for convenience
dfTemp=df.copy()

# dfTemp.loc[:,'nextTrialStart']= dfTemp.groupby('fileID')['trialStart'].transform('first')
 
# trialIDs repeat, so just restrict to first one
trialAgg= dfTemp.groupby(['fileID','trialID'])['trialID'].cumcount()==0

dfTemp= dfTemp.loc[trialAgg]


#index by file, trial. keep original index as column by calling reset_index() first
dfTemp= dfTemp.reset_index().set_index(['fileID','trialID'])

# dfTemp.set_index(['fileID','trialID'], inplace=True, drop=False)

#shift data within file (level=0)
dfTemp.loc[:,'nextTrialStart']= dfTemp.groupby(level=0)['trialStart'].shift(-1).copy()

dfTemp= dfTemp.reset_index().set_index('index')

#assign back to df and ffill() within file, trial
df.loc[:,'nextTrialStart']= dfTemp.nextTrialStart
df.nextTrialStart= df.groupby(['fileID','trialID'])['nextTrialStart'].fillna(method='ffill')


#% dp 3/7/22 finding UStime with same timestamp as DStime being assigned to ITI instead of trial (must be from inport trial)

# #by chance the UStime is simply ordered in the index prior to the cue so ffill doesn't work... it's just falling into ITI
# test= df.loc[df.fileID==df.fileID.min()]

# #for these cases, subset equivalent timestamps and manually assign trialID & trialStart
# dfTemp= df.copy()

#-==--dp 3/7/22
#check if any nextTrialStart are equal to this timestamp, if so, trialID should updated to that trial.
# dfTemp2= dfTemp.loc[dfTemp.eventTime==dfTemp.nextTrialStart]


#-- Assign ts to ITI & Pre-Cue epochs
dfTemp= df.copy()

#if this ts occurs after trialEnd and before nextTrialStart, it is ITI
ind= ((dfTemp.cutTime<dfTemp.nextTrialStart) & (dfTemp.cutTime>dfTemp.trialEnd))

test= dfTemp.loc[ind]

dfTemp.loc[ind, 'trialType']= 'ITI'

#manual exception for ts before first trial
ind= dfTemp.cutTime<dfTemp.firstTrial
dfTemp.loc[ind,'trialType']= 'ITI'

#if this ts occurs within preCueDur of nextTrialStart, it is Pre-Cue
ind= ((dfTemp.nextTrialStart-dfTemp.cutTime)<preCueDur)
dfTemp.loc[ind, 'trialType']= 'Pre-Cue'


#-- Recode trialIDs for ITI and Pre-Cue , consistent with DStraining python analysis code

#Pre-cue = intervals of .5
dfTemp.loc[dfTemp.trialType=='Pre-Cue', 'trialID']= dfTemp.trialID+0.5

#make ITI and Pre-Cue trialIDs negative
dfTemp.loc[((dfTemp.trialType=='ITI')|(dfTemp.trialType=='Pre-Cue')), 'trialID']= dfTemp.trialID*-1

#assign back to df
df= dfTemp.copy()


#%% 



dfTidy= df.copy()
# del df


# #%% Sort events by chronological order within-file, correct trialID, and save as dfTidy
# #for photometry/time series data sort by time axis, not eventTime

# dfTidy = df.sort_values(by=['fileID', 'cutTime'])

# # #more efficient
# # # df.sort_values(by=['fileID', 'eventTime'], inplace=True)

# # #delete to save memory
# # del df

#For FP this isn't actually needed, but keeping so consistent with DStrain code
#drop old, unsorted eventID
dfTidy= dfTidy.reset_index(drop=True)
dfTidy.index.name= 'eventID'

#reset_index so we have new, sorted eventID in a column
dfTidy.reset_index(inplace=True)

# # #recompute trialID now that everything is sorted chronologically
# dfTidy.trialID= dfTidy[dfTidy.trialID.notna()].groupby('fileID').cumcount()


#%% Add trialID & trialType labels to other events (events during trials and ITIs) 
# # fill in intermediate trialID values... We have absolute trialIDs now for each Cue but other events have trialID=nan
# # we can't tell for certain if events happened during a trial or ITI at this point but we do have all of the timestamps
# # and we know the cue duration, so we can calculate and assign events to a trial using this.

# # To start, fill in these values between each trialID as -trialID (could also use decimal like trial 1.5) between each actual Cue
# # Get the values and index of nan trialIDs
# # this returns a series of each nan trialID along with its index.
# indNan = dfTidy.trialID[dfTidy.trialID.isnull()].copy()


# #Need to group by file, otherwise the ffill method here will contaminate between files (events before trial 0 in fileB are filled as 59 from fileA)
# # pandas has a function for this- groupby().ffill or .backfill or .fillna
# # this fills nan trialID
# dfTidy.trialID= dfTidy.groupby('fileID')['trialID'].fillna(method='ffill').copy()

# #Add 1 to each trialID to avoid trialID==0. 
# #Don't allow trialIDs=0, so we can avoid issues with -0 trialIDs later (-0 will equate to 0 and we don't want to mix them up)
# dfTidy.trialID= dfTidy.trialID+1

# # do the same for trialType
# dfTidy.trialType= dfTidy.groupby('fileID')['trialType'].fillna(method='ffill').copy()

# # now multiply previously nan trialIDs by -1 so we can set them apart from the valid trialIDs
# dfTidy.loc[indNan.index, 'trialID'] = dfTidy.trialID[indNan.index].copy()*-1

# #Fill nan trialIDs (first ITI) with a placeholder. Do this because groupby of trialID with nan will result in contamination between sessions
# #don't know why this is, but I'm guessing if any index value==nan then the entire index likely collapses to nan
# dfTidy.loc[dfTidy.trialID.isnull(),'trialID']= -999#-0.5

# #dp 1/17/22 debugging good


# # Can get a trial end time based on cue onset, then just check
# # event times against this

# # dfTidy = dfTidy.sort_values(by=['fileID', 'eventTime']).copy()

# #more efficient?
# #dont need to sort by eventTime
# # dfTidy = dfTidy.sort_values(by=['fileID', 'eventTime'], inplace=True)


# # dfTidy.loc[:, 'trialStart'] = dfTidy.eventTime[dfTidy.trialID >= 0].copy()
    
# # dfTidy.loc[:, 'trialStart'] = dfTidy.fillna(method='ffill').copy()

# dfTidy.loc[:, 'trialEnd'] = dfTidy.eventTime[dfTidy.trialID >= 0].copy() + \
#     dfTidy.cueDur
    
# dfTidy.loc[:, 'trialEnd'] = dfTidy.trialEnd.fillna(method='ffill').copy()


# #also get start of next trial (by indexing by file,trial and then shifting by 1)
# #will be used to define preCue trialTypes
# dfGroup= dfTidy.loc[dfTidy.trialID>=0].copy()
# #index by file, trial
# dfGroup.set_index(['fileID','trialID'], inplace=True)
# #get time of next trial start by shifting by 1 trial #shift data within file (level=0)
# dfGroup.loc[:, 'nextTrialStart'] = dfGroup.groupby(level=0)['eventTime'].shift(-1).copy()
# dfGroup.reset_index(inplace=True) #reset index so eventID index is kept
# dfGroup.set_index('eventID', inplace=True)
# #merge back on eventID
# dfTidy.set_index('eventID',inplace=True,drop=False)
# dfTidy= dfTidy.merge(dfGroup, 'left').copy()

# #ffill for negative trialIDs
# dfTidy.nextTrialStart= dfTidy.nextTrialStart.fillna(method='ffill').copy()

# #SIMPLE GROUPBY INDEXING!
# #for last trial set next trial start to nan
# idx = (dfTidy.groupby(['fileID'])['trialID'].transform(max).copy() == dfTidy['trialID'].copy()) | (-dfTidy.groupby(['fileID'])['trialID'].transform(max).copy() == dfTidy['trialID'].copy())
# dfTidy.loc[idx,'nextTrialStart']= pd.NA
# dfTest= dfTidy.loc[idx]

# dfTidy.trialID.max() #good here

# # Add trialType for pre-cue period 
# #this is a useful epoch to have identified; can be a good control time period vs. cue presentation epoch
# preCueDur= 10 
# dfTest= dfTidy.copy()
# dfTest2= dfTest.loc[(dfTidy.nextTrialStart-dfTidy.eventTime <= preCueDur)]

# dfTidy.loc[(dfTidy.nextTrialStart-dfTidy.eventTime <= preCueDur),'trialType'] = 'Pre-Cue'#'Pre-'+dfTidy.trialType.copy()

# #make pre-cue trialIDs intervals of .5
# dfTidy.loc[(dfTidy.nextTrialStart-dfTidy.eventTime <= preCueDur),'trialID'] = dfTidy.trialID.copy()-0.5
# dfTest= dfTidy.loc[dfTidy.trialID==-31]

# dfTidy.trialID.max() #good here

# #Special exceptions for events before first trial starts, need to be manually assigned (bc ffill method above won't work)
# #get the time of the first event in the first trial (equivalent to trial start time)
# dfTidy.loc[dfTidy.trialID== -999, 'nextTrialStart'] = dfTidy.loc[dfTidy.trialID==1].eventTime.iloc[0] 
# #make trialEnd for the first ITI the start of the recording, keeping with scheme of other ITIs which reflect "end" of last cue
# dfTidy.loc[dfTidy.trialID== -999, 'trialEnd'] = 0

# ##ID events in the first preCue period
# dfTidy.set_index('fileID', drop=False)

# dfTidy.loc[((dfTidy.trialID== -999) & (dfTidy.nextTrialStart-dfTidy.eventTime <= preCueDur)),'trialType']= 'Pre-Cue'#+ dfTidy.loc[(dfTidy.trialID==1) | (dfTidy.trialID==-0.5)].trialType.fillna(method='bfill').copy()

# dfTest= dfTidy.copy()
# dfTest2= dfTest.loc[((dfTest.trialID== -999) & (dfTest.nextTrialStart-dfTidy.eventTime <= preCueDur))]

# ##TODO: for first ILI, make trial end the first cue onset
# # dfTidy.loc[dfTidy.trialID== -0.5,'trialEnd']= dfTidy.loc[dfTidy.loc[dfTidy.trialID==1].groupby(['fileID','trialID'])['eventTime'].cumcount()==0]

# # find events that occur after cue start but before cue duration end.
# # remaining events with negative trialIDs must have occurred somewhere in that ITI (or 'pre/post cue')

# #dp issue here somewhere?? all -1 before this switch

# dfTidy.loc[(dfTidy.trialEnd-dfTidy.eventTime >= 0) & ((dfTidy.trialEnd -
#                                                       dfTidy.eventTime).apply(np.round) < dfTidy.cueDur), 'trialID'] = dfTidy.trialID.copy()*-1

# #dp after this ^ there's 20 -1 timestamps between +1  

# dfTest= dfTidy.loc[dfTidy.trialID==-999].copy()

# # remove trialType labels from events outside of cueDur (- trial ID or nan trialID)

# #add 'ITI' trialType label for remaining events in ITI. This gets the first ITI
# dfTidy.loc[(((dfTidy.trialID < 0) & (dfTidy.trialType.isnull()))), 'trialType'] = 'ITI'
# # keep trialIDs in between integers (preCue period) by checking for nonzero modulo of 1
# #for now labelling with "ITI"
# dfTidy.loc[((dfTidy.trialID < 0) & (dfTidy.trialID % 1 == 0)), 'trialType'] = 'ITI'

# #bad by now, -1 where shouldnt

#%% add "dummy" placeholder entries for any  missing trialIDs 

#dp 1/17/22 shouldn't be necessary for time series, skipping

# #since ITI/pre-cue trial definitions are contingent on behavioral events, if no events occur during a particular ITI 
# #then that epoch won't be included in calculations later on (e.g. probability calculations based on total count of each trialType)

# #find the max integer trialID (the highest numbered trial in session)
# trialsToAdd= dfTidy.loc[(dfTidy.trialID % 1 == 0)].groupby('fileID').trialID.max().reset_index().copy()

# #there should be 1 pre-Cue trialID (- intervals of .5) and 1 ITI (- integers) per trial
# #plus an additional ITI for time after the final cue
# #so total number is = #trials * 3 + 1

# # trialsToAdd= np.array(trialsToAdd.values)

# # trialIDs = np.empty([round(trialsToAdd.trialID.max()*3), trialsToAdd.shape[0]], dtype=object)    
# # trialIDs[:]= np.nan
# # 
# # trialIDs = np.empty([round(trialsToAdd.shape[0]),2], dtype=object)
# # trialIDs= pd.DataFrame(dtype=object)    
# # trialIDs.trialID= []

# #initialize list for trialIDs and trialTypes for each file, will iteratively add to it
# trialRange= []
# trialID= []
# fileID= []

# #dp 1/11/22 indexing error here?, switching back to range()
# # for file in trialsToAdd.fileID:#range(0,trialsToAdd.shape[0]):
# for file in range(0,trialsToAdd.shape[0]):

    
#     trialRange= np.arange(-trialsToAdd.loc[file].trialID,trialsToAdd.loc[file].trialID,0.5)   
    
#     #eliminate trialIDs with + non integers
#     trialRange[(trialRange>=0) & (trialRange %1 !=0)] = np.nan
    
#     #eliminate 0 trialIDs
#     trialRange= trialRange[trialRange !=0]
    
#     #remove nans
#     trialRange= trialRange[pd.notnull(trialRange)]
    
#     #add placeholder trialID for first ITI
#     trialRange= np.append(-999,trialRange)
     
#     # trialIDs[0:trialRange.shape[0],file]= trialRange
#     # trialIDs.loc[file:,'fileID']= file
#     # trialIDs.loc[file,'trialID']= trialRange
#     # # trialIDs.loc[file,'fileID']=file
#     # trialIDs.trialID= trialIDs.trialID.append(trialRange)

#     # trialID.append(trialRange)
#     # fileID.append([file]*len(trialRange))
    
#     trialID= np.append(trialID,trialRange, axis=0)
#     fileID= np.append(fileID,[file]*len(trialRange))



    
# #save in dataframe format, add trialType labels for the ITIs and Pre-Cue periods
# dfTemp= pd.DataFrame()
# dfTemp.loc[:,'trialID']= trialID
# dfTemp.loc[:,'fileID']= fileID
# dfTemp.loc[(dfTemp.trialID<=0),'trialType']= 'ITI'
# dfTemp.loc[((dfTemp.trialID<=0)&(dfTemp.trialID %1 !=0)),'trialType']= 'Pre-Cue'

# #remove duplicate trialIDs that are already present in dfTidy (only add placeholders for epochs without events already)
# #maybe a right merge would work
# # dfTest= dfTidy.set_index(['fileID','trialID']).copy()
# # dfTemp= dfTemp#.set_index(['fileID','trialID'])
# # dfMerged= dfTest.merge(dfTemp,'right', on=['fileID','trialID'])

# dfTest=dfTidy.set_index('fileID').copy()
# # dfTemp= dfTemp.set_index('fileID')

# test1= dfTemp.groupby('fileID').trialID.unique().explode()
# test2= dfTidy.groupby('fileID').trialID.unique().explode()

# test3= dfTemp.groupby('fileID').trialID.unique().isin(dfTidy.groupby('fileID').trialID.unique())

# test4= dfTemp.groupby('fileID').trialID.unique().explode().isin(dfTidy.groupby('fileID').trialID.unique().explode())

# test6= dfTidy.groupby('fileID').trialID.unique().explode().isin(dfTemp.groupby('fileID').trialID.unique().explode())

# test8= dfTemp.groupby('fileID').trialID.unique().explode().reset_index().isin(dfTidy.groupby('fileID').trialID.unique().explode().reset_index())

# test9= test1.any()==test2

# test10= test1.reset_index().set_index(['fileID','trialID'])
# test11= test2.reset_index().set_index(['fileID','trialID'])

# test12= test10.index.isin(test11.index)

# #how is .isin actually working
# #maybe unique() is sorting or something causing index could be off?
# # test7= dfTemp.loc[test4==False]

# dfTemp= dfTemp.loc[test12==False]

# dfTemp= dfTemp.set_index('fileID')

# dfTest= dfTidy.set_index('fileID').copy()

# dfCat= pd.concat([dfTest, dfTemp], axis=0)
# test5= dfCat.groupby('fileID').trialID.unique().explode().copy()

# # dfTidy= dfCat.reset_index(drop=False).copy()

# #% visualize trialIDs now- there should be same amount per session (depending on stage)
# dfCat= dfCat.reset_index(drop=False) 
# dfTemp=dfCat.groupby(
#         ['fileID','trialType'],dropna=False,as_index=False)['trialID'].nunique(dropna=False)#.unstack(fill_value=0)
# # dfTemp=dfPlot.groupby(
# #         ['fileID','trialType','trialOutcomeBeh'],dropna=False)['trialID'].unique().unstack(fill_value=0)
# # dfTemp=dfPlot.groupby(
# #         ['fileID','trialType','trialOutcomeBeh'],dropna=False)['trialID'].groups
# # dfTemp=dfPlot.groupby(
# #         ['fileID','trialType','trialOutcomeBeh'],dropna=False)['trialID'].unique().nth(0).unstack(fill_value=0)


# ##calculate proportion for each trial type: num trials with outcome/total num trials of this type

# #%TODO: for pre- cue trialTypes, can't curently just divide by count since their current definition is contingent on behavior.
# # should divide by # of total trials of the corresponding cue...or create dummy pre-cue entries for every trial
# #I guess this theoretically applies to ITIs as well, if there's no event in the ITI it won't be included in the count
# # #trialCount= dfTemp.sum(axis=1)


# # outcomeProb= dfTemp.divide(dfTemp.sum(axis=1),axis=0)
# # dfTemp.loc[:,'outcomeProb']= dfTemp.trialID.divide(dfTemp.trialID.sum(),axis=0)

# # trialOrder= ['DStime','NStime','ITI','Pre-Cue']

# test= dfCat.groupby('fileID')['trialID'].nunique()


# dfTidy= dfCat.copy()

# #%works?
# # # #concat back into dfTidy
# # dfTidy.set_index('fileID',inplace=True)
# # dfTemp.set_index('fileID', inplace=True)
# # # test= test.merge(dfTemp, 'left').copy(
# # dfTidy= pd.concat([dfTidy, dfTemp], axis=0)

# # dfTidy.reset_index(inplace=True,drop=False)
# # # test= dfTidy.merge(dfTemp,'left',on='fileID') 

# test= dfTidy.groupby('fileID')['trialID'].unique().explode()

#%% Add  trialStart time (this is helpful when calculating latencies later on)

# #dp 1/17/22 already have this column from above trialID section, skipping

# # dfGroup= dfTidy.groupby(['fileID','trialID']).transform('cumcount')==0

# dfGroup= dfTidy.groupby(['fileID','trialID']).cumcount().copy()
# #index of first event in each trial
# dfGroup= dfTidy.loc[dfGroup==0].copy()

# #ITIs
# dfTemp= dfGroup.loc[dfGroup.trialType=='ITI'].copy()
# dfGroup.loc[dfGroup.trialType=='ITI','trialStart']= dfTemp.trialEnd.copy()

# #pre-cue
# dfTemp= dfGroup.loc[dfGroup.trialType=='Pre-Cue'].copy()
# dfGroup.loc[dfGroup.trialType=='Pre-Cue','trialStart']= (dfTemp.nextTrialStart-preCueDur).copy()

# #real + trials
# dfTemp= dfGroup.loc[dfGroup.trialID>0].copy()
# dfGroup.loc[dfGroup.trialID>0,'trialStart']= dfTemp.eventTime.copy()

# #first ITI
# dfGroup.loc[dfGroup.trialID==-999,'trialStart']= 0

# # #merge back into dfTidy
# # dfGroup.reset_index(inplace=True) #reset index so eventID index is kept
# # dfGroup.set_index('eventID', inplace=True)
# # #merge back on eventID
# # dfTidy.set_index('eventID',inplace=True,drop=False)


# dfTidy= dfTidy.merge(dfGroup[['fileID','trialID','trialStart']],'left',on=['fileID','trialID'])

# # #index of actual +trial starts
# # dfTemp= dfGroup.loc[dfGroup.trialID>=0]


# # dfGroup.loc[dfGroup.trialID>=0,'trialStart']= dfTemp.eventTime.copy()

# # dfGroup.loc[dfGroup.trialType=='ITI','trialStart']= dfTemp.eventTime+dfGroup.cueDur.copy()

# # dfGroup.loc[dfGroup.trialID==-999,'trialStart']= 0

# # # dfGroup.loc[dfGroup.trialID>=0,'trialStart']= dfGroup.loc[dfGroup.trialID>=0,'eventTime']

# # dfGroup.loc[:,'trialStart']= dfGroup.loc[:,'eventTime']



# # dfGroup= dfGroup.loc[dfGroup.trialID>=0]

# # dfTidy.loc[dfGroup,'trialStart']= dfTidy.loc[dfGroup,'eventTime']



#%% for lick-paired laser sessions, classify trials as laser on vs. laser off
#since laser delivery in these sessions is contingent on lick behavior
#use actual laser on & off times to define trials where laser delivered
   
if experimentType== 'Opto': 
    #cumcount each laser onsets per trial
    dfTidy['trialLaser'] = dfTidy[(dfTidy.laserDur=='Lick') & (dfTidy.eventType == 'laserTime')].groupby([
        'fileID', 'trialID']).cumcount().copy()
    
    #relabel trialType based on presence or absence of laser onset
    laserCount= dfTidy[dfTidy.laserDur=='Lick'].groupby(['fileID','trialID'],dropna=False)['trialLaser'].nunique()
    
    #make 0 or 1 to match trialType labels of Cue laser sessions
    laserCount.loc[laserCount>0]='1' 
    laserCount.loc[laserCount==0]='0'
    
    #so  we have a laser state for each trial, but dfTidy has many entries for each trial.
    #get the first value, then we'll use ffill to fill in other entries later
    #using  reset_index() then set_index() keeps the original named index as a column
    
    laserCount= laserCount.loc[laserCount.index.get_level_values(1)>=0]
    
    ## index by file, trial and get total count of lasers onsets per trial
    #we will use this to match up values with the original dfTidy
    dfLaser= dfTidy[((dfTidy.laserDur=='Lick') & ((dfTidy.eventType=='DStime') | (dfTidy.eventType=='NStime')))].reset_index().set_index(['fileID','trialID'])
    
    # combine laserState and laserType into one variable for labelling each trial: trialType
    # #only include the laser sessions
    dfLaser.trialType= dfLaser.laserType + '_' + laserCount.astype(str).copy()
    
    #set index to eventID before assignment
    # dfLaser= dfLaser.reset_index().set_index('eventID')
    # dfLaser= dfLaser.set_index('fileID','trialID')s
    
    #index by fileID, trialID and overwrite previous trialType labels
    dfTidy.set_index(['fileID','trialID'],inplace=True)
    
    dfTidy.loc[dfLaser.index, 'trialType']= dfLaser.trialType
    
    dfTidy.reset_index(inplace=True)    

    #insert trialTypes using eventID as index
    
    #ffill trialType for each trial
    #already filled nan so fillna wont work
    # dfTidy.loc[dfTidy.trialID>=0,'trialType']= dfTidy[dfTidy.trialID>=0].groupby('fileID')['trialType'].fillna(method='ffill').copy()
    

#%% ffill idVars for empty trials

#dp 1/17/22 not necessary

# # dfTidy.loc[:,idVars]= dfTidy.groupby('fileID')['trialType'][idVars].fillna(method='ffill').copy()
# # test= dfTidy.copy()
# dfTidy.loc[:,idVars]= dfTidy.groupby(['fileID'], as_index=False)[idVars].fillna(method='ffill').copy()
# # test2= dfTidy.copy()
# # test2[idVars]= dfTidy.groupby(['fileID'], as_index=False)[idVars].transform('fillna',method='ffill').copy()

# # test3= dfTidy.set_index(['fileID'],drop=False).copy()
# # test3.loc[:,idVars] = test3[idVars].fillna(method='ffill').copy()

#remove invalid observations
#(above code may have introduced some empty values e.g. if files were excluded)
# dfTidy= dfTidy.loc[dfTidy.cutTime.notnull()]

#%% redefine eventID now that we have empty placeholder 'events' 

##dont need to do this if initially sorted by cuttime?

#make sure sorted by timestamp within fileID
# dfTidy = dfTidy.sort_values(by=['fileID', 'eventTime'])

#more efficient?
# dfTidy.sort_values(by=['fileID', 'eventTime'], inplace=True)


# #drop old eventID and replace with new sorted index
# dfTidy.drop(columns=['eventID'])
# dfTidy.eventID= dfTidy.index.copy()


# #%% TODO: add column for 'epoch' this timestamp is in
# # this would include inPort, DS on, NS on, laser on, maybe 'licking' based on bout calculations...
# dfTidy['epoch']= pd.NA
# dfTidy['epochCue']=pd.NA
# dfTidy['epochLaser']= pd.NA

# #add cue epoch
# #TODO: consider whether cue terminates early (e.g. due to PE)
# # dfTidy.loc[((dfTidy.eventType=='DStime') | (dfTidy.eventType=='NStime')), 'epochCue']= 'cue on'
# dfTidy.loc[(dfTidy.eventType=='DStime'), 'epochCue']= 'DS on'
# dfTidy.loc[(dfTidy.eventType=='NStime'), 'epochCue']= 'NS on'


# dfTidy.loc[(dfTidy.trialType=='ITI'), 'epochCue']= 'ITI'
# dfTidy.loc[(dfTidy.trialType=='Pre-Cue'), 'epochCue']= 'Pre-Cue'


# dfTidy.epochCue= dfTidy.groupby('fileID')['epochCue'].fillna(method='ffill')

# #for now limiting to laser on vs off
# if experimentType.__contains__('Opto'):
#     dfTidy.loc[dfTidy.eventType=='laserTime', 'epochLaser']= 'laser on'
#     dfTidy.loc[dfTidy.eventType=='laserOffTime', 'epochLaser']= 'laser off'
#     dfTidy.epochLaser= dfTidy.groupby('fileID')['epochLaser'].fillna(method='ffill')
    
# dfTidy.epoch= dfTidy.epochCue + '-' + dfTidy.epochLaser
    
#%%  drop any redundant columns remaining
if experimentType.__contains__('Opto'):
    #cat together dur and freq of laser
    dfTidy.laserDur= dfTidy.loc[dfTidy.laserDur!='nan'].laserDur.astype(str)+' @ '+dfTidy.laserFreq.astype(str)

    dfTidy = dfTidy.drop(columns=['laserType', 'laserState', 'laserFreq']).copy()


#%% Preliminary data anlyses

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


#%%TODO:  isolate pre-reward delivery and post reward-delivery licks


#%% examine memory usage and dtypes

# dfTidy.memory_usage(deep=True)  # memory usage in bytes 
# dfTidy.dtypes

#change dtypes if needed
#TODO: do this earlier, idk where the object dtypes are coming from
dfTidy.cutTime=dfTidy.cutTime.astype('float64')
dfTidy.eventTime= dfTidy.eventTime.astype('float64')
dfTidy.eventType= dfTidy.eventType.astype('category')

#drop
dfTidy= dfTidy.drop('firstTrial',axis=1)


#%% Save dfTidy so it can be loaded quickly for subesequent analysis

savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

print('saving dfTidy to file')

#Save as pickel
dfTidy.to_pickle(savePath+'dfTidyFP.pkl')

#also save other variables e.g. eventVars, idVars, trialVars for later recall (without needing to run this script again)
# pickle.dump([idVars, eventVars, trialVars], savePath+'dfTidyMeta.pkl')

saveVars= ['idVars', 'eventVars', 'trialVars', 'experimentType', 'contVars']

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


#Could save as .csv, but should also save dtypes because they should be manually defined when imported
# dfTidy.to_csv('dfTidy.csv')




#%% Custom method of groupby subsetting, manipulations, and reassignment to df
#TODO: in progress...
#May be interchangable with groupby.transform() Call function producing a like-indexed DataFrame on each group and return a DataFrame having the same indexes as the original object filled with the transformed values
def groupbyCustom(df, grouper):
    #df= dataframe ; grouper= list of columns to groupby (e.g.) grouper= ['subject','date'] 
    
    grouped= df.groupby(grouper)
    
    #get the unique groups
    groups= grouped.groups
    
        
    #Each group in groups contains index of items belonging to said group
    #so we can loop through each group, use that as a key for the groups dict to get index
    #then retrieve or alter values as needed by group with this index using df.iloc  
    # dfGroup= pd.DataFrame()
    #initialize dfGroup as all nan copy of original df. Then we'll get values by group
    dfGroup= df.copy()
    dfGroup[:]= pd.NA #np.nan
    
    #collection using loop takes too long. would be nice to vectorize (need to find a way to use the dict int64 ind as index in df I think)
    for group in groups:
        #index corresponding to this group in the df
        groupInd= groups[group]
        
        #extract values from df
        dfGroup.loc[groupInd,:]= df.loc[groupInd,:]
        
        #add label for this group
        # dfGroup.loc[groupInd,'groupID']= [group]
        dfGroup.loc[groupInd,'groupID']= str(group)
        
    # for group in groups:
    #     #use key and get_group
    #     #this approach isolates values but loses original index
    #     dfGroup= grouped.get_group(group)

        #here you could run a function on dfGroup
        return dfGroup
