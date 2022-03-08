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
    
    #save label col for easy faceting
    dfLabel= np.empty(df.shape[0])
    dfResult.loc[:]= None

    
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
    
            dfLabel[preInd:postInd]= eventCol
    
        except:
            continue
        
    return dfResult, timeLock
        

#%% Define peri-event z scoring parameters
fs= 40 #sampling frequency= 40hz

preEventTime= 5 *fs # seconds x fs
postEventTime= 15 *fs

baselineTime= 10*fs

#%% Peri-event z-scoring 
#Iterate through files using groupby() and conduct peri event Z scoring
#iterating through fileID to gurantee no contamination between sessions
 
groups= dfTidy.groupby('fileID')

#currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial 
    
for name, group in groups:
    
    #TODO: write fxn or loop for all eventtypes
    # for eventType in dfTidy.eventType.unique()
    
    
    #-- peri-DS
    z, timeLock=  zscoreCustom(group, 'reblue', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS']= z
    dfTidy.loc[group.index,'timeLock-z-periDS']= timeLock

    #-- peri-DS Port Entry
    z, timeLock=  zscoreCustom(group, 'reblue', 'PEtime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS-PEtime']= z
    dfTidy.loc[group.index,'timeLock-z-periDS-PEtime']= timeLock
    
    #-- peri-US
    z, timeLock=  zscoreCustom(group, 'reblue', 'UStime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS-UStime']= z
    dfTidy.loc[group.index,'timeLock-z-periDS-UStime']= timeLock
    
    #-- peri-DS lick
    z, timeLock=  zscoreCustom(group, 'reblue', 'lickTime', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS-lickTime']= z
    dfTidy.loc[group.index,'timeLock-z-periDS-lickTime']= timeLock
    
    #-- peri-DS lickUS (reward lick)
    z, timeLock=  zscoreCustom(group, 'reblue', 'lickUS', preEventTime, postEventTime,'DStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periDS-lickUS']= z
    dfTidy.loc[group.index,'timeLock-z-periDS-lickUS']= timeLock

#--NS
    #-- peri-NS
    z, timeLock=  zscoreCustom(group, 'reblue', 'NStime', preEventTime, postEventTime,'NStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periNS']= z
    dfTidy.loc[group.index,'timeLock-z-periNS']= timeLock

    #-- peri-NS Port Entry
    z, timeLock=  zscoreCustom(group, 'reblue', 'PEtime', preEventTime, postEventTime,'NStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periNS-PEtime']= z
    dfTidy.loc[group.index,'timeLock-z-periNS-PEtime']= timeLock
    
    #-- peri-US
    z, timeLock=  zscoreCustom(group, 'reblue', 'UStime', preEventTime, postEventTime,'NStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periNS-UStime']= z
    dfTidy.loc[group.index,'timeLock-z-periNS-UStime']= timeLock
    
    #-- peri-NS lick
    z, timeLock=  zscoreCustom(group, 'reblue', 'lickTime', preEventTime, postEventTime,'NStime', baselineTime)
    dfTidy.loc[group.index,'blue-z-periNS-lickTime']= z
    dfTidy.loc[group.index,'timeLock-z-periNS-lickTime']= timeLock




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

g= sns.lineplot(ax=ax[0,], data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS',hue='subject', palette=subjPalette, legend='full', linewidth=1, alpha=0.5) #Full legend here labels all subjects even if continuous numbers
g= sns.lineplot(ax=ax[0,], data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS', linewidth=2.5, color='black')
g.set(title=('peri-DS'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

g= sns.lineplot(ax=ax[1,], data=dfPlot, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime',hue='subject', palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
g= sns.lineplot(ax=ax[1,], data=dfPlot, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime', linewidth=2.5, color='black')
g.set(title=('peri-DS-PE'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

g= sns.lineplot(ax=ax[2,], data=dfPlot, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',hue='subject',palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
g= sns.lineplot(ax=ax[2,], data=dfPlot, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',linewidth=2.5, color='black')
g.set(title=('peri-DS-lick'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

g= sns.lineplot(ax=ax[3,], data=dfPlot, x='timeLock-z-periDS-UStime',y='blue-z-periDS-UStime',hue='subject',palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
g= sns.lineplot(ax=ax[3,], data=dfPlot, x='timeLock-z-periDS-UStime',y='blue-z-periDS-UStime',linewidth=2.5, color='black')
g.set(title=('peri-DS-PumpOn'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

g= sns.lineplot(ax=ax[4,], data=dfPlot, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS',hue='subject',palette=subjPalette, legend='full', linewidth=1, alpha=0.5)
g= sns.lineplot(ax=ax[4,], data=dfPlot, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS',linewidth=2.5, color='black')
g.set(title=('peri-DS-lickReward'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')

saveFigCustom(f, 'allSubj-'+'-periEvent',savePath)

# #test
# indPlot= dfTidy.stage==7.0

# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS', col='stage', col_wrap=4, y='blue-z-periDS', hue='trainDayThisStage', kind='line')
# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS-pox', col='stage', col_wrap=4, y='blue-z-periDS-pox', hue='trainDayThisStage', kind='line')


# # # # subset data

# # # dfPlot= dfTidy.loc[dfTidy.stage>=5].copy()

# # # dfPlot= dfPlot.loc[0:10000]

# #subset data for plotting using index instead of making copy of array (less memory used)
# indPlot= dfTidy.stage==7.0

# ## looks good!
# sns.relplot(data=dfTidy.loc[indPlot,:], x='timeLock-z-periDS', col='stage', col_wrap=4, y='blue-z-periDS', hue='trainDayThisStage', kind='line')


#%% Plot ALL sessions from stage

#subset 

stagesToPlot= [7]

dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()

sns.set_palette('Blues')

for subject in dfPlot.subject.unique():
    
    dfPlot2= dfPlot.loc[dfPlot.subject==subject,:]
    
    f, ax = plt.subplots(5, 1)
    
    g= sns.lineplot(ax=ax[0,], data=dfPlot2, x='timeLock-z-periDS',y='blue-z-periDS',hue='trainDayThisStage', legend='full', linewidth=1, alpha=0.5) #Full legend here labels all subjects even if continuous numbers
    g= sns.lineplot(ax=ax[0,], data=dfPlot2, x='timeLock-z-periDS',y='blue-z-periDS', linewidth=2.5, color='black')
    g.set(title=('peri-DS'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g= sns.lineplot(ax=ax[1,], data=dfPlot2, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime',hue='trainDayThisStage', legend='full', linewidth=1, alpha=0.5)
    g= sns.lineplot(ax=ax[1,], data=dfPlot2, x='timeLock-z-periDS-PEtime',y='blue-z-periDS-PEtime', linewidth=2.5, color='black')
    g.set(title=('peri-DS-PE'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g= sns.lineplot(ax=ax[2,], data=dfPlot2, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',hue='trainDayThisStage', legend='full', linewidth=1, alpha=0.5)
    g= sns.lineplot(ax=ax[2,], data=dfPlot2, x='timeLock-z-periDS-lickTime',y='blue-z-periDS-lickTime',linewidth=2.5, color='black')
    g.set(title=('peri-DS-lick'))
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

g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS', hue='subject', palette='crest', linewidth=1, alpha=0.5)

# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS', hue='trialType', hue_order=trialOrder, linewidth=1, alpha=0.5)

# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periNS',y='blue-z-periNS', hue='trialType', hue_order=trialOrder, linewidth=1, alpha=0.5)


# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS', hue='subject', linewidth=1, alpha=0.5)
# g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS', linewidth=2.5, color='black')
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

g.map_dataframe(sns.lineplot, units='subject', data=dfPlot, x='timeLock-z-periDS-lickUS',y='blue-z-periDS-lickUS', hue='trialType', hue_order=trialOrder, linewidth=1, alpha=0.5)

g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')    

g.set(title=('peri-DS-lickReward'))
g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')


#%% TODO: ALL sessions peri-DS (looking for bad sessions to exclude)
stagesToPlot= dfTidy.stage.unique()

dfPlot= dfTidy.loc[dfTidy.stage.isin(stagesToPlot),:].copy()

    
#all between-subj plot
g= sns.FacetGrid(col='stage', col_wrap=4, data=dfPlot)
g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS', hue='subject', linewidth=1, alpha=0.5)
g.map_dataframe(sns.lineplot, data=dfPlot, x='timeLock-z-periDS',y='blue-z-periDS', linewidth=2.5, color='black')
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
    g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS',y='blue-z-periDS',hue='trainDayThisStage', palette='Blues', linewidth=1, alpha=0.5)
    # g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS',y='blue-z-periDS', linewidth=2.5, color='black')
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
        g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS',y='blue-z-periDS',hue='trialCountThisStage', palette='Blues', linewidth=1, alpha=0.5)
        # g.map_dataframe(sns.lineplot, data=dfPlot2, x='timeLock-z-periDS',y='blue-z-periDS', linewidth=2.5, color='black')
        # g.set(title=('peri-DS'))
        g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
     
        g.set(ylim=(-4,10))
        
        g.add_legend()
        
        g.fig.suptitle('subject-'+str(subject)+'allStagesAllTrials'+'-periEvent')
        saveFigCustom(g, 'subject-'+str(subject)+'allStagesAllTrials'+'-periEvent',savePath)
        

#%% Plotly package

# df = px.data.gapminder().query("continent=='Oceania'")
# fig = px.line(df, x="year", y="lifeExp", color='country')
# fig.show()


for subject in dfPlot.subject.unique():
    
    dfPlot2= dfPlot.loc[dfPlot.subject==subject,:]
        
    # fig = px.line(dfPlot2, x="timeLock-z-periDS", y="blue-z-periDS", color= 'trainDayThisStage')

    groupHierarchy= ['stage','subject','trainDayThisStage', 'timeLock-z-periDS']
    
    y= 'blue-z-periDS'
    
    dfPlot2.loc[:,'yMean']= dfPlot2.groupby(groupHierarchy)[y].transform('mean').copy()
    
    
    yMean= dfPlot2.groupby(groupHierarchy)[y].mean()

    ySEM= dfPlot2.groupby(groupHierarchy)[y].sem()

    fig= px.line(dfPlot2, x= 'timeLock-z-periDS', y='yMean', color='trainDayThisStage')

    fig.show() 
    #export as interactive html
    figName= 'subject-'+str(subject)+'-stage-'+str(stagesToPlot)+'-periEvent' 
    fig.write_html(savePath+figName+'.html')


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

