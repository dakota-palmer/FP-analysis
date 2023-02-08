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

from customFunctions import saveFigCustom


#%% PREPARING INPUT FOR PARKER ENCODING MODEL
# want - 
# x_basic= 148829 x 1803... # timestamps entire session x (# time shifts in peri-Trial window * num events). binary coded
# gcamp_y = 148829 x 1 ; entire session signal predicted by regression . z scored photometry signal currently nan during ITI & only valid values during peri-DS



#%% Plot & output settings

sns.set_style("darkgrid")
sns.set_context('notebook')


#create and viz custom palette
# heatPalette= sns.diverging_palette(270, 190, n=200)

# heatPalette= sns.diverging_palette(180, 220, n=200)

heatPalette= sns.diverging_palette(20, 220, n=200)


g= sns.palplot(heatPalette)


savePath= r'./_output/fpEncodingModelPrep/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 


#%% Load dfTidy.pkl


# #%% Load previously saved dfTidyAnalyzed (and other vars) from pickle
dataPath= r'./_output/' #'r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python\\'

dfTidy= pd.read_pickle(dataPath+'dfTidyAnalyzed.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()

#%% TODO: load contvars & eventvars

contVars= ['reblue','repurple']

# contVars= ['reblue', 'repurple', 'reblueOG','repurpleOG']

# eventVars= dfTidy.eventType.unique()

# #%% CORRELATION redo- try correlation without pivot first for better plot faceting 

# dfTemp=dfTidy.copy()


# #get unique trialID cumcount pooled across all sessions for plotting 
# dfTidy['trialIDpooled']= None

# # dfTemp = dfTemp.loc[dfTemp.groupby(['fileID','trialID']).cumcount() == 0].copy()

# ind= dfTemp.groupby(['fileID','trialID']).cumcount() == 0

# dfTemp= dfTemp.loc[ind]

# #make 1 and then use cumsum() to cumulatively count series (cumcount seems limited to groupbys)
# dfTemp.loc[ind,'trialIDpooled']= 1; 

# dfTemp['trialIDpooled']= dfTemp.trialIDpooled.cumsum()

# dfTidy.loc[ind, 'trialIDpooled'] = dfTemp.trialIDpooled

# # dfTidy.loc[:, 'trialIDpooled'] = dfTemp['trialID'].transform('cumcount') #dfTidy.groupby(['fileID','trialID']).transform('cumcount')

# dfTidy.loc[:, 'trialIDpooled'] = dfTidy.groupby(['fileID','trialID'])['trialIDpooled'].fillna(method='ffill')

# dfTemp= dfTidy.copy()

# #TODO: maybe cumcount of trialID within stage should be used in all groupers. Could be useful to reveal temporal changes/patterns
# groupHierarchyTrialType= ['stage','trainDayThisStage', 'subject','trialType']
# # groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialID']
# # groupHierarchyEventType= ['stage','trainDayThisStage', 'subject','trialType', 'trialID', 'eventType']

# #include unique cumulative trialCount for plotting
# groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialIDpooled', 'trialID']
# groupHierarchyEventType= ['stage','trainDayThisStage', 'subject','trialType', 'trialIDpooled', 'trialID', 'eventType']



# #--DS trials correlation

# #define events to correlate (e.g. drop the NStimes since they're a separate trialType)
# corrEvents= eventVars[eventVars!='NStime']
# corrEvents= corrEvents[corrEvents!='nan']

# #get the relative latency from trialStart for each eventType for each trial
# corrInput= dfTemp.groupby(groupHierarchyEventType, observed=True, as_index=False)['eventLatency'].first()    

# #subset DS trials
# corrInput= corrInput.loc[corrInput.trialType=='DStime']

# #drop unwanted eventTypes
# corrInput= corrInput.loc[corrInput.eventType.isin(corrEvents)]

# # corrInput= corrInput.dropna(axis=1, how='all')
# # corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]

# # corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()


# #pivot() eventVars prior to corr()
# #pivot eventType into columns, append, drop old col
# # dfTemp2= corrInput.pivot(columns='eventType')['eventLatency'].copy()

# #set index prior to pivot
# corrInputPivot= corrInput.set_index(groupHierarchyTrialID)

# corrInputPivot= corrInputPivot.pivot(columns='eventType')['eventLatency'].copy()

# #subset only eventVars
# corrInputPivot= corrInputPivot[corrEvents]

# #reset_index() if needed prior to corr
# corrInputPivot= corrInputPivot.reset_index()

# #run corr()
# corr= corrInputPivot[corrEvents].corr()

# #viz corr matrix- should work in jupyter notebook, otherwise will use sns heatmap
# corr.style.background_gradient(cmap="Blues")


# # #index matches so simple join
# # dfTemp= dfTidy.join(dfTemp.loc[:,corrEvents]).copy()
# # dfTemp= dfTemp.drop(['eventType'], axis=1)


# # corr= corrInput.groupby(groupHierarchyEventType).corr()


# # g= sns.pairplot(data=corr)
# # g.fig.suptitle('DS trial event correlations')


# # corr= corrInput.groupby(['stage','subject','trialType'])[corrEvents].corr()

# # g= sns.pairplot(data=corr)
# # g.fig.suptitle('DS trial event correlations')

# # #pairplot of just time(not coef)
# # dfPlot= corrInput[corrEvents]
# # g= sns.pairplot(data=dfPlot)
# # g.fig.suptitle('DS trial event timings scatter')


# # #pairplot of just time(not coef)
# # g= sns.lmplot(data=dfPlot)

# #--Jointplot is nice for showing distro of event timings prior to correlation

# dfPlot= corrInput.copy()

# # g= sns.jointplot(data=dfPlot, x='eventLatency', y='trialIDpooled', hue='eventType')

# g= sns.jointplot(data=dfPlot, x='eventLatency', y='trialID', hue='eventType')



# #PairGrid of pivoted data for flexibility?
# dfPlot= corrInputPivot[corrEvents]
# g= sns.PairGrid(data= dfPlot)

# g.map(sns.scatterplot)


# g= sns.pairplot(data=dfPlot)

# #heatmap correlation coefs

# g= sns.heatmap(corr, annot=True, cmap='Greens');


# #palette 


# g = sns.heatmap(
#     corr, 
#     annot=True,
#     vmin=0, vmax=1, center=0,
#     cmap= heatPalette,
#     square=True
# )



# # g= sns.jointplot(data=dfPlot, col='subject', col_wrap= 4, x='eventLatency', y='trialIDpooled', hue='eventType')


# #may be able to add regression line to jointplot here


#%% EXCLUDE TRIALS based on behavior
# exclude inPort trials

ind= []
ind= dfTidy.trialOutcomeBeh10s.str.contains('inPort')


#just make the signal nan
dfTidy.loc[ind,'reblue']= None
dfTidy.loc[ind, 'repurple']= None


#%% FP preprocessing- df/f

from customFunctions import execute_controlFit_dff
    
isosbesticControl=True
filterWindow= 40    


# # run dff for each file individually
# groups= dfTidy.groupby('fileID')
    
# for name, group in groups:
    
#     norm_data= []
#     control_fit= []
    
#     norm_data, control_fit= execute_controlFit_dff(dfTidy.loc[group.index,'repurple'], dfTidy.loc[group.index,'reblue'], isosbesticControl, filterWindow)

    
#     dfTidy.loc[group.index, 'norm_data']= norm_data
#     dfTidy.loc[group.index, 'control_fit']= control_fit



# # #--test subset file
# test= dfTidy.loc[dfTidy.fileID== dfTidy.fileID.min()]

# dfTidy=test.copy()

# norm_data, control_fit= execute_controlFit_dff(test.repurple, test.reblue, isosbesticControl, filterWindow)

# test['norm_data'], test['control_fit']= execute_controlFit_dff(test.repurple, test.reblue, isosbesticControl, filterWindow)

# # viz raw and dff fp signals
# plt.subplot(2,1,1)
# plt.plot(test.reblue, color= 'blue')
# plt.plot(test.control_fit, color='purple')
# # plt.plot(test.repurple)
# plt.subplot(2,1,2)
# plt.plot(test.norm_data, color='green')

# #-- viz dff from random sample subset file
# ind= dfTidy.fileID==dfTidy.fileID.sample().iloc[0]

# # dfPlot= dfTidy[ind]#.loc[ind]

# plt.subplot(2,1,1)
# plt.plot(dfTidy.loc[ind,'reblue'], color='blue')
# plt.plot(dfTidy.loc[ind,'control_fit'], color='purple')
# plt.subplot(2,1,2)
# plt.plot(dfTidy.loc[ind,'norm_data'], color='green')




#%% TODO: integrate peri-event plotting & session viewing beforehand to make sure we're getting good sessions


#%% Define whether to run on dF/F oraw signal!

# modeSignalNorm= 'raw'
# 
# modeSignalNorm= 'dff' 

# modeSignalNorm= 'dffMatlab'

modeSignalNorm= 'airPLS' #simply for filenames
0
## Define whether to z-score peri-event dF/F or keep as dF/F

modePeriEventNorm= 'z'

# modePeriEventNorm= 'raw'



#todo: save the OG signal here to compare against post-python preprocessing ? memory intensive
    
#for now just test specific fileID of interest
# dfTidy= dfTidy.loc[dfTidy.fileID==180]


## keeping OG signals memory intensive so dont unless debugging
# dfTidy.loc[:,'reblueOG']= dfTidy.reblue.copy()
# dfTidy.loc[:,'repurpleOG']= dfTidy.repurple.copy()

#for now simply overwrite the signal with normalized dff
if modeSignalNorm== 'dff':
    dfTidy.reblue= dfTidy.norm_data.copy()
    dfTidy.repurple= dfTidy.control_fit.copy()



#%% Define which specific stages / events / sessions to include!

#% #TODO: collect all events, save, and move event exclusion to regression script

stagesToInclude= [7]

#number of sessions to include, 0 includes final session of this stage+n
nSessionsToInclude= 0#2

# #no exclusion (except null/nan)
# eventsToInclude= list((dfTidy.eventType.unique()[dfTidy.eventType.unique().notnull()]).astype(str))


# #define which eventTypes to include!
#for correlation should keep all
eventVars= dfTidy.eventType.unique()

# eventsToInclude= ['DStime','NStime','PEtime','lickPreUS','lickUS']

eventsToInclude= ['DStime','PEcue','lickUS']

# DP 2023-02-07 COMBINE ALL LICK EVENTS FOR SIMPLE MODEL
# OVERWRITING all lick events with undefined type

dfTidy.loc[dfTidy.eventType.str.contains('lick'), 'eventType']= 'lickTime'

eventsToInclude= ['DStime','PEcue','lickTime']






# dfTidy.loc[~dfTidy.eventType.isin(eventsToInclude),'eventType']= pd.NA
#

# eventVars= eventVars[eventVars.isin(eventsToInclude)]


# eventVars=eventsToInclude


#exclude stages

dfTidy= dfTidy.loc[dfTidy.stage.isin(stagesToInclude),:]




#exclude sessions within-stage
dfTidy['maxSesThisStage']= dfTidy.groupby(['stage','subject'])['trainDayThisStage'].transform('max').copy()

dfTidy= dfTidy.loc[dfTidy.trainDayThisStage>= dfTidy.maxSesThisStage-nSessionsToInclude]

dfTidy= dfTidy.drop('maxSesThisStage', axis=1)

#%% Exclude trials based on PE outcome

test= dfTidy.columns

# test= dfTidy.trialOutcomeBeh10s.unique()

# test= dfTidy.groupby(['fileID']).cumcount()==0


#%% Define peri-event z scoring parameters
fs= 40

preEventTime= 5 *fs # seconds x fs
postEventTime= 10 *fs

#time window to normalize against
baselineTime= 10*fs


#%% CORRELATION of event timings based on subset data

dfTemp=dfTidy.copy()


#get unique trialID cumcount pooled across all sessions for plotting 
dfTidy['trialIDpooled']= None

# dfTemp = dfTemp.loc[dfTemp.groupby(['fileID','trialID']).cumcount() == 0].copy()

ind= dfTemp.groupby(['fileID','trialID']).cumcount() == 0

dfTemp= dfTemp.loc[ind]

#make 1 and then use cumsum() to cumulatively count series (cumcount seems limited to groupbys)
dfTemp.loc[ind,'trialIDpooled']= 1; 

dfTemp['trialIDpooled']= dfTemp.trialIDpooled.cumsum()

dfTidy.loc[ind, 'trialIDpooled'] = dfTemp.trialIDpooled

# dfTidy.loc[:, 'trialIDpooled'] = dfTemp['trialID'].transform('cumcount') #dfTidy.groupby(['fileID','trialID']).transform('cumcount')

dfTidy.loc[:, 'trialIDpooled'] = dfTidy.groupby(['fileID','trialID'])['trialIDpooled'].fillna(method='ffill')

dfTemp= dfTidy.copy()

#TODO: maybe cumcount of trialID within stage should be used in all groupers. Could be useful to reveal temporal changes/patterns
groupHierarchyTrialType= ['stage','trainDayThisStage', 'subject','trialType', 'epoch']
# groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialID']
# groupHierarchyEventType= ['stage','trainDayThisStage', 'subject','trialType', 'trialID', 'eventType']

#include unique cumulative trialCount for plotting
groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialIDpooled', 'trialID']
groupHierarchyEventType= ['stage','trainDayThisStage', 'subject','trialType', 'trialIDpooled', 'trialID', 'eventType']



#--DS trials correlation

#define events to correlate (e.g. drop the NStimes since they're a separate trialType)
corrEvents= eventVars[eventVars!='NStime']
corrEvents= corrEvents[corrEvents!='lickNS'] 
corrEvents= corrEvents[corrEvents!='nan']

#get the relative latency from trialStart for each eventType for each trial
corrInput= dfTemp.groupby(groupHierarchyEventType, observed=True, as_index=False)['eventLatency'].first()    

#subset DS trials
corrInput= corrInput.loc[corrInput.trialType=='DStime']

#drop unwanted eventTypes
corrInput= corrInput.loc[corrInput.eventType.isin(corrEvents)]

# corrInput= corrInput.dropna(axis=1, how='all')
# corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]

# corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()


#pivot() eventVars prior to corr()
#pivot eventType into columns, append, drop old col
# dfTemp2= corrInput.pivot(columns='eventType')['eventLatency'].copy()

#set index prior to pivot
corrInputPivot= corrInput.set_index(groupHierarchyTrialID)

corrInputPivot= corrInputPivot.pivot(columns='eventType')['eventLatency'].copy()

#subset only eventVars
corrInputPivot= corrInputPivot[corrEvents]

#reset_index() if needed prior to corr
corrInputPivot= corrInputPivot.reset_index()

#run corr()
corr= corrInputPivot.corr()

#viz corr matrix- should work in jupyter notebook, otherwise will use sns heatmap
corr.style.background_gradient(cmap="Blues")


# #index matches so simple joinc
# dfTemp= dfTidy.join(dfTemp.loc[:,corrEvents]).copy()
# dfTemp= dfTemp.drop(['eventType'], axis=1)


# corr= corrInput.groupby(groupHierarchyEventType).corr()


# g= sns.pairplot(data=corr)
# g.fig.suptitle('DS trial event correlations')


# corr= corrInput.groupby(['stage','subject','trialType'])[corrEvents].corr()

# g= sns.pairplot(data=corr)
# g.fig.suptitle('DS trial event correlations')

# #pairplot of just time(not coef)
# dfPlot= corrInput[corrEvents]
# g= sns.pairplot(data=dfPlot)
# g.fig.suptitle('DS trial event timings scatter')


# #pairplot of just time(not coef)
# g= sns.lmplot(data=dfPlot)

#--Jointplot is nice for showing distro of event timings prior to correlation

dfPlot= corrInput.copy()

# g= sns.jointplot(data=dfPlot, x='eventLatency', y='trialIDpooled', hue='eventType')

g= sns.jointplot(data=dfPlot, x='eventLatency', y='trialID', hue='eventType')

 #PairGrid of pivoted data for flexibility?
dfPlot= corrInputPivot[corrEvents]
g= sns.PairGrid(data= dfPlot)

g.map(sns.scatterplot)


g= sns.pairplot(data=dfPlot)

#-- Plot of event timings going into regression (just double checking reasonable times)
dfPlot= corrInput.copy()

dfPlot= dfPlot.loc[dfPlot.eventType.isin(eventsToInclude)].copy()

#remove all unused categories from vars (so sns doesn't plot empty labels)
ind= dfPlot.dtypes=='category'
ind= dfPlot.columns[ind]

for col in ind:
    dfPlot[col]= dfPlot[col].cat.remove_unused_categories()


g= sns.catplot(data=dfPlot, y='eventType', x='eventLatency')
g.map(plt.axvline, x=10, linestyle='--', color='black', linewidth=2)


# g= sns.catplot(data=dfPlot, row='epoch', y='eventType', x='eventLatency')
# g.map(plt.axvline, x=10, linestyle='--', color='black', linewidth=2)


# -----heatplots

#--heatmap correlation coefs

dfPlot= corr[corrEvents]

f, ax = plt.subplots(1, 1)

g = sns.heatmap(ax= ax,
    data= dfPlot, 
    annot=True,
    vmin=0, vmax=1, center=0,
    cmap= heatPalette,
    square=True
)


g.set(title=('allSubj'+'-eventCorrelation-'))

saveFigCustom(f, 'allSubj-'+'-eventCorrelation-heatmap', savePath)


#Run correlation and plot for individual subjects

for subj in corrInput.subject.unique():
    
    corrInputPivot2= corrInputPivot.loc[corrInputPivot.subject==subj].copy()
    
    #subset only eventVars
    corrInputPivot2= corrInputPivot2[corrEvents]
    
    #reset_index() if needed prior to corr
   
    corrInputPivot2= corrInputPivot2.reset_index()
    
    #drop nans prior to running
    # corrInputPivot2= corrInputPivot2.dropna()
    
    #run corr()
    corr2= corrInputPivot2.corr()
    
        
    dfPlot= corr2.copy()
    
    dfPlot= dfPlot[corrEvents]
    
    
    f, ax = plt.subplots(1, 1)
    
    g = sns.heatmap(ax= ax,
        data= dfPlot, 
        annot=True,
        vmin=-.5, vmax=1, center=0,
        cmap= heatPalette,
        square=True
    )
    
    
    g.set(title=('subj-'+str(subj)+'-eventCorrelation-heatmap'))

    saveFigCustom(f, 'subj-'+str(subj)+'-eventCorrelation-heatmap', savePath)
    
   # subject Plot of event timings going into regression (just double checking reasonable times)
    dfPlot= corrInput.loc[corrInput.subject==subj].copy()
    
    dfPlot= dfPlot.loc[dfPlot.eventType.isin(eventsToInclude)].copy()
    
    #remove all unused categories from vars (so sns doesn't plot empty labels)
    ind= dfPlot.dtypes=='category'
    ind= dfPlot.columns[ind]
    
    for col in ind:
        dfPlot[col]= dfPlot[col].cat.remove_unused_categories()
    
    
    g= sns.catplot(data=dfPlot, y='eventType', x='eventLatency')
    g.map(plt.axvline, x=10, linestyle='--', color='black', linewidth=2)
    g.set(title=('subj-'+str(subj)+'-encodingInput-eventLatencies'))
    saveFigCustom(f, 'subj-'+str(subj)+'-encodingInput-eventLatencies', savePath)






# # REPEAT CORR BUT REPLACE NANS WITH HIGH LATENCY VALUES

# for thisEvent in corrEvents:
#     corrInputPivot.loc[corrInputPivot[thisEvent].isnull(), thisEvent]= 999
    
# corr= corrInputPivot.corr()

    
#     #between-subj mean
# dfPlot= corr[corrEvents]

# f, ax = plt.subplots(1, 1)

# g = sns.heatmap(ax= ax,
#     data= dfPlot, 
#     annot=True,
#     vmin=0, vmax=1, center=0,
#     cmap= heatPalette,
#     square=True
#     )


# g.set(title=('allSubj'+'-eventCorrelation-'))

# saveFigCustom(f, 'allSubj-'+'-eventCorrelation-heatmap', savePath)

# #Run correlation and plot for individual subjects

# for subj in corrInput.subject.unique():
    
#     corrInputPivot2= corrInputPivot.loc[corrInputPivot.subject==subj].copy()
    
#     #subset only eventVars
#     corrInputPivot2= corrInputPivot2[corrEvents]
    
#     #reset_index() if needed prior to corr
#     corrInputPivot2= corrInputPivot2.reset_index()
    
#     #run corr()
#     corr2= corrInputPivot2.corr()
        
#     dfPlot= corr2.copy()
    
#     dfPlot= dfPlot[corrEvents]
    
    
#     f, ax = plt.subplots(1, 1)
    
#     g = sns.heatmap(ax= ax,
#         data= dfPlot, 
#         annot=True,
#         vmin=-.5, vmax=1, center=0,
#         cmap= heatPalette,
#         square=True
#     )
    
    
#     g.set(title=('subj-'+str(subj)+'-eventCorrelation-heatmap-Nan timestamps=999'))

#     saveFigCustom(f, 'subj-'+str(subj)+'-eventCorrelation-heatmap-NaNs-to-longLatency', savePath)



# # g= sns.jointplot(data=dfPlot, col='subject', col_wrap= 4, x='eventLatency', y='trialIDpooled', hue='eventType')


# #may be able to add regression line to jointplot here


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
    
    rawResult= np.empty(df.shape[0])
    rawResult= pd.Series(rawResult, dtype='float64')
    rawResult.loc[:]= None
    rawResult.index= df.index
    
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
        
        #TODO: INDEXING HERE RELIES ON fs TIME BINNING! Should really base on raw timestamp range to prevent incorrect binning... could potentially set_index() on cutTime?
            preInd= dfTemp.index[0]- preEventTime
            postInd=dfTemp.index[0] +postEventTime
            
            raw= df.loc[preInd:postInd, signalCol].copy()
            baseline= df.loc[preIndBaseline[event]:postIndBaseline[event], signalCol].copy()
            
            #may need raw.COPY() here for proper assignment into zResult. otherwise equivalent to raw
            z= (raw.copy()-baseline.mean())/(baseline.std())
            
            # #dp debugging manual calculation check- looks good
            # test0= raw.copy()
            # test1= (test0-baseline.mean())
            # test2= (baseline.std())
            # test3= test1/test2
            
            # all(test3==z)
                
            zResult.loc[preInd:postInd]= z.copy() #assignment not working?
            
            # zResult.loc[preInd:postInd]= z.values #assignment not working?

            
            rawResult.loc[preInd:postInd]= raw.copy()
            
            timeLock.loc[preInd:postInd]= np.linspace(-preEventTime/fs,postEventTime/fs, z.size)
    

        #TODO: these would work if wanted to translate to single col, but overwriting between event timelock types within file
            zEventBaseline.loc[preInd:postInd]= eventColBaseline
            
            zEvent.loc[preInd:postInd]= eventCol
            
            trialIDtimeLock.loc[preInd:postInd]= event
            
            #debugging- indexing assignment issue??
            #zResult is same as raw. z is indeed different but not assigning correctly
            test1= z
            test2= zResult.loc[preInd:postInd]
            test3= raw
            test4= rawResult.loc[preInd:postInd]
              
            # #-- dp examining specific trial
            # f, ax= plt.subplots(1,2, sharex=True, sharey=False) 
            
            # g= sns.lineplot(ax= ax[0], x=timeLock, y=zResult, color='black', linewidth=1.5)
            
            # g= sns.lineplot(ax= ax[1], x=timeLock, y=raw, color='black', linewidth=1.5)
        
            # g.fig.suptitle('event#'+event)

    
        except:
            continue
        
        #round timeLock so that we have exact shared X values for stats and viz!
        timeLock= np.round(timeLock, decimals=3)
      
        #debugging
        
        # #z score Result and raw Result are equivalent. why
        # test1=(zResult[zResult.notnull()])
        # test2=(rawResult[rawResult.notnull()])
        
        # all(test1==test2)
        
        # #individually they are different
        

    
        
    return zResult, timeLock, zEventBaseline, zEvent, trialIDtimeLock, rawResult
        


#%% old Define custom Z score function
# FOR TIDY DATA, SINGLE eventType COLUMN

# #assume input eventCol is binary coded event timestamp, with corresponding cutTime value
# def zscoreCustom(df, signalCol, eventCol, preEventTime, postEventTime, eventColBaseline, baselineTime):
    
#     #want to groupby trial but can't strictly since want pre-cue data as baseline
#     #rearrange logical strucutre here a bit, go through and find all of the baseline events
#     #then find the get the first event in this trial. TODO: For now assuming 1 baseline event= 1 trial (e.g. 60 cues, 1 per trialID) 
#     preIndBaseline= df.index[df.eventType==eventColBaseline]-preEventTime
#     #end baseline at timestamp prior to baseline event onset
#     postIndBaseline= df.index[df.eventType==eventColBaseline]-1


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
#         dfTemp= dfTemp.loc[dfTemp.eventType==eventCol]
        
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
        

#%% Eliminate uneeded columns prior to shifting events
#for encoding model only need event times + photometry signal + metadata
colToInclude= idVars+contVars+['trainDayThisStage','trialID','trialType','eventType']


colToInclude= colToInclude+ eventsToInclude


# Hitting memory errors when time shifting events; so subsetting or processing in chunks should help


#%% Peri-event analysis: photometry signal (and normalization) timelocked to events

#TODO: may want to add some random trialStart time 'jitter' to add variation to cue onset times for regression (will currently always be t=0)

#Going to 
#1) Z-score normalize fp signal trial-by-trial relative to pre-cue baseline
#2) Exclude data and restrict analysis to only DS or NS trial-by-trial (instead of whole FP signal)

#-- Get Z-scored photometry signal

#Iterate through files using groupby() and conduct peri event Z scoring
#iterating through fileID to gurantee no contamination between sessions
 
groups= dfTidy.groupby('fileID')

#currently fxn will go through and z score surrounding ALL events?? 2022-03-02 is this true?. Need to restrict to FIRST event per trial 
    
for name, group in groups:
    for signal in contVars: #loop through each signal (465 & 405)
        #-- peri-DS 
        z, timeLock, zEventBaseline, zEvent, trialIDtimeLock, raw=  zscoreCustom(group, signal, 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
        dfTidy.loc[group.index,signal+'-z-periDS']= z
        dfTidy.loc[group.index,'timeLock-z-periDS-DStime']= timeLock
        dfTidy.loc[group.index, ['trialIDtimeLock-z-periDS']]= trialIDtimeLock



        #-- dp examining specific file raw vs z
        # f, ax= plt.subplots(1,2, sharex=True, sharey=False) 
        
        # g= sns.lineplot(ax= ax[0], x=timeLock, y=z, color='black', linewidth=1.5)
        # g= sns.lineplot(ax= ax[0], x=timeLock, y=z, color='black', estimator= None, units= trialIDtimeLock, linewidth=.5, alpha=0.5)
        
        # g.set(title=('subj-'+str(subj)+'peri DS z score '))

        
        # g= sns.lineplot(ax= ax[1], x=timeLock, y=raw, color='black', linewidth=1.5)
        # g= sns.lineplot(ax= ax[1], x=timeLock, y=raw, color='black', estimator= None, units= trialIDtimeLock, linewidth=.5, alpha=0.5)

        # g.set(title=('subj-'+str(subj)+'peri DS raw '))
        
        #dp hue facet by trialID for closer look
        subj= group.subject.iloc[0] 
        
        
        f, ax= plt.subplots(1,2, sharex=True, sharey=False) 
        
        
        g= sns.lineplot(ax= ax[0], x=timeLock, y=z, color='black', linewidth=2.5)
        g= sns.lineplot(ax= ax[0], x=timeLock, y=z, hue=trialIDtimeLock, palette='tab20', estimator= None, units= trialIDtimeLock, linewidth=1, alpha=.5)
        
        g.set(title=('subj-'+str(subj)+'-'+modeSignalNorm+'-'+modePeriEventNorm+'-'+signal+'-peri DS Z SCORE all trials'))

        
        g= sns.lineplot(ax= ax[1], x=timeLock, y=raw, color='black', linewidth=2.5)
        g= sns.lineplot(ax= ax[1], x=timeLock, y=raw, hue=trialIDtimeLock, palette='tab20', estimator= None, units= trialIDtimeLock, linewidth=1, alpha=.5)

        g.set(title=('subj-'+str(subj)+'-'+modeSignalNorm+'-'+modePeriEventNorm+'-'+signal+'-peri DS RAW all trials'))
        
        
        titleFig= ('subj-'+str(subj)+'-'+modeSignalNorm+'-'+modePeriEventNorm+'-'+signal+'-peri DS all trials')
        f.suptitle(titleFig)
        
        saveFigCustom(f, titleFig, savePath)

        
        # RAW vs Z score normalized peri-event signal plot
        
        
        # # dp doing above but OG raw signals
        # z, timeLock, zEventBaseline, zEvent, trialIDtimeLock, raw=  zscoreCustom(dfTidy, 'reblueOG', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
      
        # f, ax= plt.subplots(1,2, sharex=True, sharey=True) 
        
        # g= sns.lineplot(ax= ax[0], x=timeLock, y=z, color='black', linewidth=1.5)
        # g= sns.lineplot(ax= ax[0], x=timeLock, y=z, color='black', estimator= None, units= trialIDtimeLock, linewidth=.5, alpha=0.5)
        
        # g.set(title=('subj-'+str(subj)+'peri DS OG z score '))
           
        
        # g= sns.lineplot(ax= ax[1], x=timeLock, y=raw, color='black', linewidth=1.5)
        # g= sns.lineplot(ax= ax[1], x=timeLock, y=raw, color='black', estimator= None, units= trialIDtimeLock, linewidth=.5, alpha=0.5)
           
        # g.set(title=('subj-'+str(subj)+'peri OG DS raw '))


        
        #-- peri-NS 
        z, timeLock, zEventBaseline, zEvent, trialIDtimeLock,raw=  zscoreCustom(group, signal, 'NStime', preEventTime, postEventTime,'NStime', baselineTime)
        dfTidy.loc[group.index,signal+'-z-periNS']= z
        dfTidy.loc[group.index,'timeLock-z-periNS-NStime']= timeLock
        
        dfTidy.loc[group.index, ['trialIDtimeLock-z-periNS']]= trialIDtimeLock
        
                   

    
test= dfTidy.loc[dfTidy.fileID==dfTidy.fileID.min()]

# #%% DP 2022-09-14 comment all out below for quick comparison


#%% --quick fix overwrite z-score dff with raw if desired

if (modeSignalNorm=='dff') & (modePeriEventNorm== 'raw'):

        ind= []
        ind= dfTidy['reblue-z-periDS'].notna()

        dfTidy.loc[ind, 'reblue-z-periDS']= dfTidy.reblue
        dfTidy.loc[ind, 'repurple-z-periDS']= dfTidy.repurple

        ind= []
        ind= dfTidy['reblue-z-periNS'].notna()
      
        dfTidy.loc[ind, 'reblue-z-periNS']= dfTidy.reblue
        dfTidy.loc[ind, 'repurple-z-periNS']= dfTidy.repurple
    
#%% Peri-event z-scoring 
# #Iterate through files using groupby() and conduct peri event Z scoring
# #iterating through fileID to gurantee no contamination between sessions
 
# groups= dfTidy.groupby('fileID')

# #currently fxn will go through and z score surrounding ALL events. Need to restrict to FIRST event per trial 
    
# for name, group in groups:
#     #-- peri-DS
#     z, timeLock=  zscoreCustom(group, 'reblue', 'DStime', preEventTime, postEventTime,'DStime', baselineTime)
#     dfTidy.loc[group.index,'blue-z-periDS-DStime']= z
#     dfTidy.loc[group.index,'timeLock-z-periDS-DStime']= timeLock

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

# dfTemp= dfTidy.copy()

# # dfTemp= dfTemp.pivot(columns='eventType')['cutTime'].copy()

    
# # test= dfTemp.groupby(['fileID','trialID','eventType'], as_index=False)['eventType'].cumcount()

# # test= dfTemp.groupby(['fileID','trialID','eventType']).cumcount()

# # # ind= dfTemp.groupby(['fileID','trialID','eventType'], observed=True).cumcount()==0

# # # test= dfTemp.loc[ind]

# # #get ind of all events after First for each trial, then replace times w nan

# ind= dfTemp.groupby(['fileID','trialID','eventType'], observed=True).cumcount()!=0

# count= dfTemp.groupby(['fileID','trialID','eventType'], observed=True).cumcount()

# #%TODO ----------------------Replace these with clearer eventType instead of erasing

# # dfTemp.loc[ind, 'eventType']= dfTemp.eventType+'notFirst'


# #simply make eventType nan
# dfTemp.loc[ind, 'eventType']= None

# # #Or- this works:
# # #label cumcount?
# # #eventType= eventType + cumcount
# # dfTemp.eventType= dfTemp.eventType.astype(str)
# # dfTemp.loc[ind, 'eventType']= dfTemp.eventType + count.astype(str)

# # dfTemp.eventType= dfTemp.eventType.astype('category')


    
# dfTidy.eventType= dfTemp.eventType.copy()



# #%% CORRELATION between eventTypes

# #TODO: should move to just before model is run, so each individual dataset has correlation saved
# #That would be a ton of shifted columns tho which is probs not what we want?
# #or at minimum should run on data guranteed to be in model. 

# # should run on periEventTimeLock (time relative to trialStart)

# # how correlated are events going into our model?
# #should run on eventTime before converting to binary coded?

# dfTemp= dfTidy.pivot(columns='eventType')['cutTime'].copy()


# #need to groupby or set index to get each time per trial

# #subset DS trials
# dfTemp= dfTidy.loc[dfTidy.trialType=='DStime']

# #try corr with set ind ?

# # dfTemp= dfTidy.copy()

# # dfTemp= dfTemp.set_index(['stage','subject','fileID','trialType','trialID'])

# # dfTemp2= dfTemp.pivot(columns='eventType')['cutTime'].copy()

# # #doesn't seem to matter if set_index()

# #-----Timelock-sensitive (relative timestamp correlation- good):

#     #--DS

# #pivot eventType into columns, append, drop old col
# dfTemp= dfTidy.pivot(columns='eventType')['timeLock-z-periDS-DStime'].copy()
# #index matches so simple join
# dfTemp= dfTidy.join(dfTemp.loc[:,eventVars]).copy()
# dfTemp= dfTemp.drop(['eventType'], axis=1)

# #get all of the first events for each trial, grouped by trialType

# #will need to isolate eventTypes by trialType for this to work (na observations for events that don't occur)
# #limited to trials where all events are recorded


# #TODO: could be embedded in a groupby trialType.groups loop

# # groupers= ['stage','subject','fileID','trialType','trialID']

# groupHierarchyTrialType= ['stage','trainDayThisStage', 'subject','trialType']
# groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialID']

# #--DS trials correlation
# corrInput= dfTemp.groupby(groupHierarchyTrialID, observed=True, as_index=False)[eventVars].first()    

# #subset DS trials and drop events that don't occur (NStime)
# corrInput= corrInput.loc[corrInput.DStime.notnull()]
# corrInput= corrInput.dropna(axis=1, how='all')
# corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]

# corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()
# g= sns.pairplot(data=corr)
# g.fig.suptitle('DS trial event correlations')


# corr= corrInput.groupby(['stage','subject','trialType'])[corrEvents].corr()

# g= sns.pairplot(data=corr)
# g.fig.suptitle('DS trial event correlations')

# #pairplot of just time(not coef)
# dfPlot= corrInput[corrEvents]
# g= sns.pairplot(data=dfPlot)
# g.fig.suptitle('DS trial event timings scatter')


# #pairplot of just time(not coef)
# dfPlot= corrInput[corrEvents]
# g= sns.lmplot(data=dfPlot)



# #jointplot is very nice to show distribution
# g= sns.jointplot(data=dfPlot)

# g= sns.jointplot(data= corrInput[corrEvents])

# #want to viz better, reorganize
# dfPlot= corr.reset_index().melt(id_vars= ['stage','subject','trialType'], value_vars= corrEvents, value_name= 'eventType')

# corr= corrInput.groupby(['stage','subject','trialType'])[corrEvents].corr()


# # #------Timelock-agnostic (absolute timestamp correlation version) :
# # #try groupby
# # #pivot eventType into columns, append, drop old col
# # dfTemp= dfTidy.pivot(columns='eventType')['cutTime'].copy()
# # #index matches so simple join
# # dfTemp= dfTidy.join(dfTemp.loc[:,eventVars]).copy()
# # dfTemp= dfTemp.drop(['eventType'], axis=1)


# # #get all of the first events for each trial, grouped by trialType

# # #will need to isolate eventTypes by trialType for this to work (na observations for events that don't occur)
# # #limited to trials where all events are recorded


# # #TODO: could be embedded in a groupby trialType.groups loop

# # # groupers= ['stage','subject','fileID','trialType','trialID']

# # groupHierarchyTrialType= ['stage','trainDayThisStage', 'subject','trialType']
# # groupHierarchyTrialID= ['stage','trainDayThisStage', 'subject','trialType', 'trialID']

# # #--DS trials correlation
# # corrInput= dfTemp.groupby(groupHierarchyTrialID, observed=True, as_index=False)[eventVars].first()    

# # #subset DS trials and drop events that don't occur (NStime)
# # corrInput= corrInput.loc[corrInput.DStime.notnull()]
# # corrInput= corrInput.dropna(axis=1, how='all')
# # corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]

# # #drop trials without all events? corr should handle this
# # # corrInput= corrInput.dropna(axis=0, how='any')

# # corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()

# # # corr= corr.reset_index()

# # # dfPlot= corr[corrEvents+'subject']

# # # sns.pairplot(data= corr, hue='subject')

# # g= sns.pairplot(data=corr)
# # g.fig.suptitle('DS trial event correlations')
# # g.set(ylim= [0,1.1])

# # #-- NS trials correlation

# # corrInput= dfTemp.groupby(groupHierarchyTrialID, observed=True, as_index=False)[eventVars].first()    

# # #subset NS trials and drop events that don't occur (NStime)
# # corrInput= corrInput.loc[corrInput.NStime.notnull()]
# # corrInput= corrInput.dropna(axis=1, how='all')
# # corrEvents=  corrInput.columns[corrInput.columns.isin(eventVars)]


# # corr= corrInput.groupby(groupHierarchyTrialType)[corrEvents].corr()

# # g= sns.pairplot(data=corr)
# # g.fig.suptitle('NS trial event correlations')


#%% Reverse melt() of eventTypes by pivot() into separate columns

#memory intensive! should probably either 1) do at end or 2) subset before pivot

dfTidy= dfTidy.copy() 

# test= dfTidy.loc[dfTidy.fileID==8]
# dfTidy= test.copy()


# #update eventVars
eventVars= dfTidy.eventType.unique()

# #remove nan eventType
# eventVars= eventVars[pd.notnull(eventVars)]

# eventVars= eventVars[eventVars!='nan']


#exclude eventTypes if needed
# eventsToExclude= ['out']

# eventVars= eventVars[~eventVars.isin(eventsToExclude)]

eventVars= eventVars[eventVars.isin(eventsToInclude)]

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

# #if you wanted different peri-event timelocking and timeShifting for encoding you could change params here.

# #keep same time shift parameters as periEvent
# fs=  fs

# preEventTime= preEventTime
# postEventTime= postEventTime

#%% Define "time of influence" for events

#Cue-related activity should happen at short latency within fixed window of time.

#for example, we may want to limit the timeShifts applied (influence in model) to within +2s after cue onset


cueTimeOfInfluence= 2*fs



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
for eventCol in eventVars: #.categories:
    
    #limit time shifting to within window of influence for cue eventTypes
    
    if ((eventCol== 'DStime' )|( eventCol=='NStime')):
        postEventShift= cueTimeOfInfluence
    else:
        postEventShift= postEventTime
    
    for shiftNum in np.arange(-preEventTime,postEventShift):
        # a= pd.Series(np.zeros(len(dfTemp), int))
        # a= np.zeros(len(dfTemp), int))

        #2) assign sparse dtype, for some reason filling with SparseArray causes conversion to float
        # dfTemp.loc[:, (eventCol+'+'+(str(shiftNum)))]= a.astype(pd.SparseDtype("int", 0))
        # dfTemp[(eventCol+'+'+(str(shiftNum)))]= a.astype(pd.SparseDtype("int", 0))

        #1) again, assignment to df here is causing conversion to float. very frustrating
        # dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= pd.Series(pd.arrays.SparseArray(a, fill_value=0), dtype='int')
        #3) works? only assingning as dense then changing dtype to sparse after assignment seems to preserve int?
        a= np.zeros(len(dfTemp), int)
        dfTemp[(eventCol+'+'+(str(shiftNum)))]= a #a.copy() #PerformanceWarning: DataFrame is highly fragmented.  This is usually the result of calling `frame.insert` many times, which has poor performance.  Consider joining all columns at once using pd.concat(axis=1) instead.
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
for eventCol in eventVars: #.categories:
    
    if ((eventCol== 'DStime' )|( eventCol=='NStime')):
        postEventShift= cueTimeOfInfluence
    else:
        postEventShift= postEventTime

    for shiftNum in np.arange(-preEventTime,postEventShift):
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
# for shiftNum in np.arange(-preEventTime,postEventShift):
#     startTime = time.time()
    
#     #####your python script#####
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= groups.shift(shiftNum,fill_value=0)[eventVars]


#     executionTime = (time.time() - startTime)
#     print('Execution time in seconds: ' + str(executionTime))
    


#and try scipy matrix. would probably be a lot faster?

#Now that i'm using sparse data maybe I can speed up using older methods below
#~7.5-8s/iteration
#failed, hit mem error col 3014?
# for shiftNum in np.arange(-preEventTime,postEventShift):
#     startTime = time.time()
    
#     #####your python script#####
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= groups[eventVars.categories].shift(shiftNum, fill_value=0)

#     executionTime = (time.time() - startTime)
#     print('Execution time in seconds: ' + str(executionTime))
    
    

#attempt 1
#loop through fileIDs (need this grouping to prevent contamination) and apply shift
#hitting memory errors this way
# for name, group in groups:
    # for shiftNum in np.arange(-preEventTime,postEventShift):
    #     # dfTemp.loc[group.index,(eventVars.categories+'+'+(str(shiftNum)))]= group.loc[:,eventVars].shift(shiftNum)
    #     dfTemp.loc[group.index,(eventVars.categories+'+'+(str(shiftNum)))]= group.loc[:,eventVars].shift(shiftNum)

#attempt 2- making it pretty far, to +329... still doesn't work with sparse
# for shiftNum in np.arange(-preEventTime,postEventShift):
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= groups[eventVars.categories].shift(shiftNum)

#attempt 3
#still hitting memory errors, try looping through eventVars separately?
#this seems a ton slower but i think memory cap is hit later
#idk why it's fine outside of the loop but breaks during. need to preallocate? 
#probs bc invoking dfTemp.groupby and it's changing size?

# for eventCol in eventVars.categories:
#     for shiftNum in np.arange(-preEventTime,postEventShift):
#         dfTemp.loc[:,(eventCol+'+'+(str(shiftNum)))]= groups[eventCol].shift(shiftNum)

#For the shifted event timestamps type of data, just save into np.array. 
#No need for dataframe at this point I guess and should be much more efficient.
#Index should match dataframe anyway so should be able to recover anything needed

#preallocate array
#why is this 90gb now?? df above was saying 21gb at some point?
# x_basic= np.zeros([(len(eventVars)*(len(np.arange(-preEventTime,postEventShift)))),len(dfTemp)])
# for shiftNum in np.arange(-preEventTime,postEventShift):
#     dfTemp.loc[:,(eventVars.categories+'+'+(str(shiftNum)))]= pd.NA

#TODO: May want scipy sparse matrix instead, more efficient than pandas?

#%% Drop original, unshifted event times (we should now have duplicate col for timeshift=0 now)

dfTemp= dfTemp.drop(eventVars,axis=1)


#%% Exclude artifacts

#initialize 
dfTemp['exclude']= None



#threshold absolute value z score beyond which entire trial should be excluded (replace w nan)
thresholdArtifact= 15


#only run if z score and ** raw** non-dff 

#dp 2022-09-12 dff conditional here means prior airPLS results had extreme 'artifacts' removed

# if (modeSignalNorm!= 'dff') & (modePeriEventNorm=='z'):
if (modeSignalNorm!= 'raw') & (modePeriEventNorm=='z'):

    
    
    #--DS
    groupHierarchyTimeLockTrialID= ['fileID','trialIDtimeLock-z-periDS']
    
    y= dfTemp.columns[dfTemp.columns.str.contains('repurple-z-periDS')]
    
    #find trials exceeding threshold
    
    dfTemp2= pd.DataFrame()
    
    #get max, min for each trial then compare absolute value of these extremes against threshold 
    dfTemp2['maxZ']= dfTemp.groupby(groupHierarchyTimeLockTrialID)[y].transform('max').copy()
    
    dfTemp2['minZ']= dfTemp.groupby(groupHierarchyTimeLockTrialID)[y].transform('min').copy()
    
    dfTemp2['tresholdArtifact']= thresholdArtifact
    
    dfTemp2= dfTemp2.abs()
    
    
    ind= ((dfTemp2.minZ>=thresholdArtifact) | (dfTemp2.maxZ>= thresholdArtifact))
    
    #mark index as artifact if exceed threshold
    dfTemp2.loc[ind,'artifact']= 1
    
    
    #mark for exclusion in main df
    dfTemp.loc[ind, 'exclude']= 1
    
    
    #--NS
    groupHierarchyTimeLockTrialID= ['fileID','trialIDtimeLock-z-periNS']
    
    y= dfTemp.columns[dfTemp.columns.str.contains('repurple-z-periNS')]
    
    #find trials exceeding threshold
    dfTemp2= pd.DataFrame()
    
    #get max, min for each trial then compare absolute value of these extremes against threshold 
    dfTemp2['maxZ']= dfTemp.groupby(groupHierarchyTimeLockTrialID)[y].transform('max').copy()
    
    dfTemp2['minZ']= dfTemp.groupby(groupHierarchyTimeLockTrialID)[y].transform('min').copy()
    
    dfTemp2['tresholdArtifact']= thresholdArtifact
    
    dfTemp2= dfTemp2.abs()
    
    
    ind= ((dfTemp2.minZ>=thresholdArtifact) | (dfTemp2.maxZ>= thresholdArtifact))
    
    #mark index as artifact if exceed threshold
    dfTemp2.loc[ind,'artifact']= 1
    
    
    #mark for exclusion in main df
    dfTemp.loc[ind, 'exclude']= 1

#%% Convert trialIDtimeLock to true unique trialID for timeLock epochs (not shared between files)


#-DS
groupHierarchyTimeLockTrialID= ['fileID','trialIDtimeLock-z-periDS']

dfTemp2= pd.DataFrame()


# simple setting and reset_index for unique count
dfTemp2['trialIDshared']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periDS'].first()

#this index now has count we want. could merge back
dfTemp2['trialIDunique']= dfTemp2.reset_index(drop=False).index

dfTemp= dfTemp.set_index(groupHierarchyTimeLockTrialID, drop=False)

# dfTemp= dfTemp.merge(dfTemp2, how='left', left_index=True, right_index=True)

dfTemp['trialIDtimeLock-z-periDS']= dfTemp2['trialIDunique']

dfTemp= dfTemp.reset_index(drop=True)

#- NS
groupHierarchyTimeLockTrialID= ['fileID','trialIDtimeLock-z-periNS']

dfTemp2= pd.DataFrame()


# simple setting and reset_index for unique count
dfTemp2['trialIDshared']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periNS'].first()

#this index now has count we want. could merge back
dfTemp2['trialIDunique']= dfTemp2.reset_index(drop=False).index

dfTemp= dfTemp.set_index(groupHierarchyTimeLockTrialID, drop=False)

# dfTemp= dfTemp.merge(dfTemp2, how='left', left_index=True, right_index=True)

dfTemp['trialIDtimeLock-z-periNS']= dfTemp2['trialIDunique']

dfTemp= dfTemp.reset_index(drop=True)



# #try setting index before reseting to do without merging
# #try simple reset_index
# # dfTemp2= dfTemp.set_index(groupHierarchyTimeLockTrialID).copy()

# # dfTemp2['trialIDunique']= dfTemp2.reset_index().index

# # #this index now has count we want. could merge back
# # dfTemp2= dfTemp2.reset_index(drop=False)

# #try groupby stuff

# dfTemp2['trialIDshared']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periDS'].transform('first')

# # dfTemp2['trialIDunique']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periDS'].transform('cumcount')


# # dfTemp2['trialIDshared']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periDS'].first()

# #indices corresponding to first value in each unique trialIDtimeLock, cumcount() of these between files and replace these values
# dfTemp2['cumCount']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periDS'].cumcount()

# ind= dfTemp2.cumCount==0


# # dfTemp2['trialIDunique']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periDS'].cumsum()

# # dfTemp2['trialIDunique']= dfTemp.groupby(groupHierarchyTimeLockTrialID)['trialIDtimeLock-z-periDS'].cumcount()



#%% Viz artifact trials

dfPlot= dfTemp.loc[dfTemp.exclude==1].copy()

fig, ax= plt.subplots(2,1)

g= sns.lineplot(ax= ax[0], data=dfPlot, units='trialIDtimeLock-z-periDS', estimator=None, x='timeLock-z-periDS-DStime', y='reblue-z-periDS', hue='trialIDtimeLock-z-periDS')

plt.axhline(y=thresholdArtifact, color='black', dashes=(3,1), linewidth=2)

g= sns.lineplot(ax= ax[1], data=dfPlot, units='trialIDtimeLock-z-periDS', estimator=None, x='timeLock-z-periDS-DStime', y='repurple-z-periDS', hue='trialIDtimeLock-z-periDS')

plt.axhline(y=thresholdArtifact, color='black', dashes=(3,1), linewidth=2)



#%% -- Plot fp input of model (with artifact trials)

#peri-DS and periNS traces subplot for each subj (465 & 405)

for subj in dfTemp.subject.unique():
    
    f, ax= plt.subplots(1,2, sharex=True, sharey=True) 
    
    dfPlot= dfTemp.loc[dfTemp.subject==subj,:].copy()
    
    y= 'reblue-z-periDS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periDS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periDS')))][0]
    
    g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='green', linewidth=1.5)
    
    g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='green', units= units,estimator=None, alpha=0.5, linewidth=0.5)


    y= 'repurple-z-periDS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periDS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periDS')))][0]
    
    g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='purple', linewidth=1.5)
    
    g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='purple', units= units,estimator=None, alpha=0.5, linewidth=0.5)
    
    g.set(title=('subj-'+str(subj)+'peri-DS encoding model input')+'')

    
    #- NS
    
    y= 'reblue-z-periNS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periNS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periNS')))][0]
    
    
    g= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='green', units= units,estimator=None, alpha=0.5, linewidth=0.5)


    y= 'repurple-z-periNS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periNS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periNS')))][0]
    
    g= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='purple', linewidth=1.5)
    
    g= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='purple', units= units,estimator=None, alpha=0.5, linewidth=0.5)
    
    g.set(title=('subj-'+str(subj)+'peri-NS encoding model input')+'')
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g.set(ylim=(-4,10))
    
    saveFigCustom(f, 'subj-'+str(subj)+'modelInput-periCue-withArtifact'+'-'+modeSignalNorm+'-'+modePeriEventNorm,savePath)

#%% 2022-10-20 try heatmaps of peri-event data

# for subj in dfTemp.subject.unique():
    
#     f, ax= plt.subplots(1,2, sharex=False, sharey=False) 
    
#     dfPlot= dfTemp.loc[dfTemp.subject==subj,:].copy()
    
#     y= 'reblue-z-periDS'
#     x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periDS')) & (~dfPlot.columns.str.contains('trialID')))][0]
#     units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periDS')))][0]
    

#     #exclude nans
#     dfPlot= dfPlot.loc[dfPlot[y].notna(),:]
    
#     # g= sns.heatmap(ax=ax[0], data=dfPlot, x=x, y=units)

#     #for some reason heatmap doesn't seem to like categoricals and other dtypes
#     #so subset only col of interest or convert these beforehand?
    
#     dfPlot2= dfPlot[[x,y,units]].copy()
    

    
#     # sns.heatmap seems to specifically like pivot table
#     #pivot (y,x,z)
#     dfPlot2 = dfPlot2.pivot(units, x, y)
    
#     #-try matplotlib-- below works?
#     plt.subplot()
#     plt.imshow(dfPlot2)
    
#     #overlay PE latency
#     #recall dfPlot.trialPE is cumcount of events in trial, so want ==0 for first
#     ind=[]
#     ind= dfPlot.trialPE10s==0
    
#     dfPlot3= dfPlot[ind].copy()
        
    
#     # https://www.python-graph-gallery.com/heatmap-for-timeseries-matplotlib
    
#     # plt.pcolormesh(dfPlot[x], dfPlot[units], dfPlot[y])
#     plt.subplot()
    
#     h= plt.pcolormesh(dfPlot2)
        
#     #overlay PE latency
#     #recall dfPlot.trialPE is cumcount of events in trial, so want ==0 for first
#     ind=[]
#     ind= dfPlot.trialPE10s==0
    
#     dfPlot3= dfPlot[ind].copy()
        
    
#     g= sns.scatterplot(data=dfPlot3,x=x, y=units, color='red', alpha=0.5)


    
#     # g= sns.heatmap(ax= ax[0],data=dfPlot2, cmap='viridis')

#     #- for some reason x values are not lining up right between scatter and heat
#     # the axes starts at 0 instead of -5...
#     #what seems to be happening is the x labels on heatmap are 'str'bc pivoted columns. so can just convert data plotted to str too

#     # https://stackoverflow.com/questions/60958223/how-to-line-plot-timeseries-data-on-a-bar-plot/60958889#60958889
#     # https://stackoverflow.com/questions/60614007/problem-in-combining-bar-plot-and-line-plot-python
    
#     # this needs to be mapped onto the timeLock somehow.
#     g= sns.heatmap(ax= ax[0],data=dfPlot2, cmap='viridis', xticklabels=True)

 
#     #see axes are str
#     g.set_xticklabels(g.get_xticklabels(), rotation=45)
#     test= g.get_xticklabels()


#     # what if 2d hist instead of heatmap https://seaborn.pydata.org/examples/layered_bivariate_plot.html
#     #wont work, should be heatmap
#     # g= sns.histplot(data=dfPlot, x=x, y=units, hue=y) #cmap='viridis')

#     #convert relevant data to str prior to plotting over heatplot
#     dfPlot[x]= dfPlot[x].astype('string')

#     #scatter overlays    
#     # overlay cue onset 
#     # need to match up with categorical x
#     ax[0].axvline(x=0, linestyle='--', color='black', linewidth=2) 


    
#     #overlay PE latency
#     #recall dfPlot.trialPE is cumcount of events in trial, so want ==0 for first
#     ind=[]
#     ind= dfPlot.trialPE10s==0
    
#     dfPlot3= dfPlot[ind].copy()
        
#     # g= sns.scatterplot(ax= ax[0],data=dfPlot3, x='eventLatency', y=units, color='red', alpha=0.5)
#     g2= sns.scatterplot(ax= ax[0],data=dfPlot3, x=x, y=units, color='red', alpha=0.5)




#     g2= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='green', linewidth=1.5)
    
#     plt.axvline(x=0, linestyle='--', color='black', linewidth=2)



    
# #    %dp 2022-10-21 in progress

#     # g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='green', units= units,estimator=None, alpha=0.5, linewidth=0.5)


#     # y= 'repurple-z-periDS'
#     # x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periDS')) & (~dfPlot.columns.str.contains('trialID')))][0]
#     # units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periDS')))][0]
    
#     # g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='purple', linewidth=1.5)
    
#     # g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='purple', units= units,estimator=None, alpha=0.5, linewidth=0.5)
    
#     # g.set(title=('subj-'+str(subj)+'peri-DS encoding model input')+'')



    #%% ====================2022-09-14 comment out saving below for to save time


#%%--- Remove excluded trials (artifacts)

#Remove artifacts: replace continuous signals with nan

#update list of contVars to include normalized fp signals
contVars= list(dfTemp.columns[(dfTemp.columns.str.contains('reblue') | dfTemp.columns.str.contains('repurple'))])
dfTemp.loc[dfTemp.exclude==1,contVars]= None


#%% -- Plot fp input of model (without artifact trials)

#peri-DS and periNS traces subplot for each subj (465 & 405)

for subj in dfTemp.subject.unique():
    
    f, ax= plt.subplots(1,2, sharex=True, sharey=True) 
    
    dfPlot= dfTemp.loc[dfTemp.subject==subj,:].copy()
    
    y= 'reblue-z-periDS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periDS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periDS')))][0]
    
    g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='green', linewidth=1.5)
    
    # g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='green', units= units,estimator=None, alpha=0.5, linewidth=0.5)


    y= 'repurple-z-periDS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periDS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periDS')))][0]
    
    g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='purple', linewidth=1.5)
    
    # g= sns.lineplot(ax= ax[0], data= dfPlot, x=x, y=y, color='purple', units= units,estimator=None, alpha=0.5, linewidth=0.5)
    
    
    #- NS
    
    y= 'reblue-z-periNS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periNS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periNS')))][0]
    
    g= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='green', linewidth=1.5)
    
    # g= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='green', units= units,estimator=None, alpha=0.5, linewidth=0.5)


    y= 'repurple-z-periNS'
    x= dfPlot.columns[((dfPlot.columns.str.contains('timeLock-z-periNS')) & (~dfPlot.columns.str.contains('trialID')))][0]
    units= dfPlot.columns[((dfPlot.columns.str.contains('trialIDtimeLock-z-periNS')))][0]
    
    g= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='purple', linewidth=1.5)
    
    # g= sns.lineplot(ax= ax[1], data= dfPlot, x=x, y=y, color='purple', units= units,estimator=None, alpha=0.5, linewidth=0.5)
    
    g.set(title=('subj-'+str(subj)+'peri-Cue encoding model input'))
    g.set(xlabel='time from event (s)', ylabel='z-scored FP signal')
    
    g.set(ylim=(-4,10))
    
    saveFigCustom(f, 'subj-'+str(subj)+'modelInput-periCue-noArtifact'+'-'+modeSignalNorm+'-'+modePeriEventNorm,savePath)




#%% Isolate DS & NS data, SAVE as separate datasets
#Restrict analysis to specific trialType

#just get index of each and save as separate datasets. this way can load quickly and analyze separately


print('saving regression input dfTemp to file')

#save DS and NS trial datasets 
    #DS
titleStr= modeSignalNorm+'-'+modePeriEventNorm+'-'+'RegressionInput'+'-''DSonly'

ind= dfTemp['timeLock-z-periDS-DStime'].notnull()
dfTemp.loc[ind].to_pickle(savePath+titleStr+'.pkl')

    #NS
titleStr= modeSignalNorm+'-'+modePeriEventNorm+'-'+'RegressionInput'+'-''NSonly'

ind= dfTemp['timeLock-z-periNS-NStime'].notnull()
dfTemp.loc[ind].to_pickle(savePath+titleStr+'.pkl')

#update list of contVars to include normalized fp signals
contVars= list(dfTemp.columns[(dfTemp.columns.str.contains('reblue') | dfTemp.columns.str.contains('repurple'))])

#also save other variables e.g. variables actually included in regression Input dataset (since we may have excluded specific eventTypes)
saveVars= ['idVars', 'eventVars', 'contVars', 'trialVars', 'experimentType', 'stagesToInclude', 'nSessionsToInclude', 'preEventTime','postEventShift', 'fs', 'cueTimeOfInfluence', 'modeSignalNorm', 'modePeriEventNorm']


#use shelve module to save variables as dict keys
titleStr=  modeSignalNorm+'-'+modePeriEventNorm+'-'+'RegressionInputMeta'

my_shelf= shelve.open(savePath+titleStr, 'n') #start new file

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
# saveVars= ['idVars', 'eventVars', 'trialVars', 'experimentType', 'stagesToInclude', 'nSessionsToInclude', 'preEventTime','postEventShift', 'fs']


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
#         ind= np.arange(0,(eventCol+1)*len(np.arange(-preEventTime,postEventShift)))
#     else:
#         ind= np.arange((eventCol)*len(np.arange(-preEventTime,postEventShift)),((eventCol+1)*len(np.arange(-preEventTime,postEventShift)-1)))
   
#     kernels[(eventVars[eventCol]+'-coef')]= b[ind]


# #%% 

# #Establish hierarchical grouping for analysis
# #want to be able to aggregate data appropriately for similar conditions, so make sure group operations are done correctly
# groupers= ['subject', 'trainDayThisStage', 'fileID']