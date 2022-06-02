# -*- coding: utf-8 -*-
"""
Created on Wed May  4 15:12:11 2022

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

import pandas as pd
import glob
import os
import numpy as np
import shelve
import seaborn as sns



#%% Load previously saved dfTidy (and other vars) from pickle
dataPath= r'./_output/' #'r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python\\'

dfTidy= pd.read_pickle(dataPath+'dfTidyAnalyzed.pkl')

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

savePath= r'./_output/fpBehaviorPlots/'

#%% Establish behavioral criteria for training stage advancement

#DS PE probability (above this)
criteriaDS= 0.6

# NS PE probability (below this)
criteriaNS= 0.5




#%% Exclude subjects

subjectsToExclude= [17]#[10, 17]

subjectsControl= []#[16, 20]

dfTidy= dfTidy[~dfTidy.subject.isin(subjectsToExclude)]

dfTidy= dfTidy[~dfTidy.subject.isin(subjectsControl)]
    
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
    
#%% -------PLOTS training across stages

#%% Probability of 10s PE (by trialType)

# #subset with customFunction
# stagesToPlot= [5]#[1,2,3,4,5,6,7]#dfTidy.stage.unique()
stagesToPlot= [1,2,3,4,5,6,7]#dfTidy.stage.unique()

trialTypesToPlot= ['DStime', 'NStime']
eventsToPlot= dfTidy.eventType.unique()

dfPlot= subsetData(dfTidy, stagesToPlot, trialTypesToPlot, eventsToPlot).copy()

#subset one observation per trial
#subset to 1 obs per trial for counting
dfPlot= subsetLevelObs(dfPlot, groupHierarchyTrialType)#.copy()

f, ax = plt.subplots(1, 1)

g= sns.lineplot(data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)

g= sns.lineplot(data= dfPlot, ax=ax, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)

plt.axhline(y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#facet by stage

g= sns.FacetGrid(data=dfPlot, row='trialType', col='stage')

# g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='subject', palette='tab20')

g.add_legend()

g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#individual subjects

for subj in dfPlot.subject.unique():
    
    dfPlot2= dfPlot.loc[dfPlot.subject==subj]
    
    g= sns.FacetGrid(data=dfPlot2, row='stage')

    g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
    g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#%% DP Manuscript Figure peProb 10s + mean Latency subplot



#%% -----------------------Import and Plot Raw MPC-calculated PE Ratios -----------------


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
# experimentType= 'photometry'

#Examples: 

# #DP VP-VTA-STGTACR DS Task
# experimentType= 'Opto'
# datapath= r'C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\\' 
# colToImport= 'A:W'  #dp opto 
# metaPathSubj= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_subj_metadata.xlsx" 
# metaPathSes= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_session_metadata.xlsx"

        
# #DP GAD-VP-OPTO DS Task
# experimentType= 'Opto'
# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\\' #dp gad-vp-opto DS task
# colToImport= 'A:W'  #dp opto 
# metaPathSubj= r'C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\subj_metadata.xlsx' #gad-vp-opto
# metaPathSes= r"C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\ses_metadata.xlsx" #gad-vp-opto DS task


#DP GAD-VP-OPTO Instrumental Transfer
# experimentType= 'OptoInstrumentalTransfer'
# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\\'
# metaPathSes= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\_metadata\GAD-VP-Opto-transfer-session-metadata.xlsx'#gad-vp-opto instrumental transfer


# #DP VP-VTA-FP DS Task 
experimentType= 'photometry'
datapath= r'K:\vp-vta-fp_behavior\MPC\_mpc_to_excel\\' #dp vp-vta-fp
colToImport= 'A:Q' #dakota vp-vta-fp
metaPathSubj= r"K:\vp-vta-fp_behavior\excel\_metadata\subj_metadata.xlsx" #dakota vp-vta-fp
metaPathSes= r"K:\vp-vta-fp_behavior\excel\_metadata\ses_metadata.xlsx" #dakota vp-vta-fp


#Ally DREADD DS Task
# experimentType= 'DREADD'
# datapath= r'C:\Users\Dakota\Desktop\_example_gaddreadd\MED-PC Files July-TBD 2021\All\\' #ally dreadd
# colToImport= 'A:Q' #ally dreadd


#%% ID and import raw data .xlsx
# your path to folder containing excel files 
# datapath = r'C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_dataRaw\\'#dp vp-vta-stgtacr opto

# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\\' #dp gad-vp-opto DS task
# datapath= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\\'
# datapath= r'J:\vp-vta-fp_behavior\MPC\_mpc_to_excel\\' #dp vp-vta-fp
# datapath= r'C:\Users\Dakota\Desktop\_example_gaddreadd\MED-PC Files July-TBD 2021\All\\' #ally dreadd

# set all .xls files in your folder to list
allfiles = glob.glob(datapath + "*.xls*")

#initialize list to store data from each file
dfRaw = pd.DataFrame()

#define columns in your .xlsx for specific variables you want (e.g. A:Z for all)
# colToImport= 'A:W'# 'F:S,U:X' #dp opto 
# colToImport= 'A:Z'# gad-vp-opto instrumental transfer 
# colToImport= 'A:Q' #dakota vp-vta-fp
# colToImport= 'A:Q' #ally dreadd


#for loop to aquire all excel files in folder
for excelfiles in allfiles:
    #read all sheets by specifying sheet_name = None
    #Remove any variables you don't want now before appending!
    #there was an issue with (W)trialState so leaving that out (col T)
    #Also leaving out first few columns
    raw_excel = pd.read_excel(excelfiles, sheet_name= None, usecols=colToImport)
    
    dfRaw = dfRaw.append(raw_excel, ignore_index=True)
    
    

    
#dfRaw is now nested df, each column is a subject and each row is a session

#eliminate data from 'MSNs' sheets for now, not informative currently
#TODO: this could be nice to get, but requires changing the mpc2excel scripts
dfRaw.drop('MSNs',axis=1,inplace=True)

#%% unnest & combine data from all files into tidy df
#loop through nested df and append data. Now we have all data in one df
df= pd.DataFrame()

for subject in dfRaw.columns:
    print('loading'+subject)
    for file in range(len(dfRaw)):
        # print(allfiles[file]+subject)
        try:
            #add file label to each nested raw_excel before appending
            #assume fileName is yyyymmdd.xlsx (total of 13 characters at end of path. 5 are '.xlsx')
            dfRaw.loc[file,subject]['file']=allfiles[file][-13:]
            
            #add date too
            dfRaw.loc[file,subject]['date']= allfiles[file][-13:-5]
            
            
            #- save specific cells from MPC arrays as new column 2022-05-11
            # -save DS and NS PE Ratio for DS task
            indFile= file,subject
            
            thisFile= dfRaw.loc[indFile].copy()
            
            colInd= thisFile.columns[np.where(thisFile.columns.str.contains('workingVars'))]

            #b(23)
            thisFile.loc[:, "mpcDSpeRatio"]= thisFile.loc[23, colInd][0]
            #b(24)
            thisFile.loc[:, "mpcNSpeRatio"]= thisFile.loc[24, colInd][0]
            
            # #% ## TODO: 
            # #get stage programmatically ~~ 20220512
            # best solution may be to get the MSN ran, will likely require hcanges to the MPC2excel code

            # # should be able to find out which stage this is of DS training using ITIs & stageParams (don't need to rely on metadata)
            # colInd= thisFile.columns[np.where(thisFile.columns.str.contains('ITI'))]
            
            # #
            
            # ITIs=  pd.DataFrame()
            
                                    
            
            # #1 col for each stage with ITIs to compare against
            # ITIs.loc[:,'1']= [20, 30, 40, 50, 60, 20, 30, 40, 50, 60 ]
            # ITIs.loc[:,'2']= [50, 60, 70, 80, 90,50, 60, 70, 80, 90 ]
            # ITIs.loc[:,'3']= [60, 70, 80, 90, 100, 60, 70, 80, 90, 100]
            # ITIs.loc[:,'4']= [70, 80, 90, 100, 110, 70, 80, 90, 100, 110]
            
            # ITIs.loc[:,'5up']= [10, 20, 30, 40, 50, 10, 20, 30, 40, 50]
            
            # # determine stage based on ITI
            
            # ITIsThisFile= thisFile.loc[0:9, colInd]
            
            # ITIsThisFile= ITIsThisFile.astype('int64')
    
            # for col in ITIs.columns:
            #    if ITIsThisFile.iloc[:,0].equals(ITIs.loc[:,col]):
            #       thisFile['stage']= col
               
            # #% ## TODO: - further define stages 5 and up based on other vars - not sure if possible very quickly wihtout some intermediate calculations...
            # if thisFile.loc[0,'stage']== '5up'
                
            #     # #pumpDur (a(3)) may define but I think it was manually defined in code, not variable
            #     # pumpDur= pd.DataFrame()
            #     # pumpDur.loc
                



            #save stage label before appending

            #add subject label before appending
            thisFile.loc[:,'subject']=subject
            
            df= df.append(thisFile)
            
            
            # #assign df with updated values back to dfRaw
            # dfRaw.loc[indFile]= thisFile

            # # #b(23)
            # # dfRaw.loc[indFile].loc[file, "mpcDSpeRatio"]= dfRaw.loc[indFile].loc[23, colInd]
            # # #b(24)
            # # dfRaw.loc[indFile].loc[file, "mpcNSpeRatio"]= dfRaw.loc[indFile].loc[24, colInd]
            
            
            # #add subject label before appending
            # dfRaw.loc[file,subject]['subject']=subject
            
            # df= df.append(dfRaw.loc[file,subject])
            
            
            #in progress
            # --save specific cells from MPC arrays added 2022-05-11
            # -save DS and NS PE Ratio for DS task
            # thisFile= dfRaw.loc[file,subject]
            
            # colInd= thisFile.columns.str.contains('workingVars')
            
            # #b(23) 
            # dfMPC.loc[file, "DSpeRatio"]= thisFile.loc[23, colInd]
            # #b(24)
            # dfMPC.loc[file, "NSpeRatio"]= thisFile.loc[24, colInd]
            
            # #save metadata for this file
            # #add date too
            # dfRaw.loc[file,subject]['date']= allfiles[file][-13:-5]
            # dfRaw.loc[file,subject]['file']=allfiles[file][-13:]

            
            # fileInd= fileInd+1
            
        except: 
            print(allfiles[file]+'_'+subject+' has no data')

#%% ID and import metadata .xlsx
#TODO: for now assuming separate excel files for these data

#convert subject and date variables to string datatype to ensure easy matching (excel number formatting can be weird)
df.subject= df.subject.astype('str')
df.date= df.date.astype('str')

# Match and insert subject metadata based on subject
# metaPathSubj= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_subj_metadata.xlsx" #dp vp-vta-stgtacr opto
# metaPathSubj= r'C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\subj_metadata.xlsx' #gad-vp-opto
# metaPathSubj= r"J:\vp-vta-fp_behavior\excel\_metadata\subj_metadata.xlsx" #dakota vp-vta-fp

dfRaw= pd.read_excel(metaPathSubj).astype('str') 

df= df.merge(dfRaw.astype('str'), how='left', on=['subject'])

# Match and insert session metadata based on date and subject

# metaPathSes= r"C:\Users\Dakota\Desktop\Opto DS Task Test- Laser Manipulation\_metadata\vp-vta-stgtacr_session_metadata.xlsx" #dp vp-vta-stgtacr opto
# metaPathSes= r"C:\Users\Dakota\Desktop\gad-vp-opto\_metadata\ses_metadata.xlsx" #gad-vp-opto DS task
# metaPathSes= r'C:\Users\Dakota\Desktop\gad-vp-opto\_instrumental-transfer\_metadata\GAD-VP-Opto-transfer-session-metadata.xlsx'#gad-vp-opto instrumental transfer
# metaPathSes= r"J:\vp-vta-fp_behavior\excel\_metadata\ses_metadata.xlsx" #dakota vp-vta-fp

#ensure that date is read as string
dfRaw= pd.read_excel(metaPathSes, converters={'date': str, 'subject': str})#.astype('str') 

# df= df.merge(dfRaw.astype('str'), how='left', on=['subject','date'])

df= df.merge(dfRaw, how='left', on=['subject','date'])


# %% Exclude data

excludeDate= ['20210604']

# Exclude specific date(s)
df= df[~df.date.isin(excludeDate)]

# %% Remove parentheses from variable names 

import re
#use regex to replace text between () with empty string
#loop through each column name, remove characters between () and collect into list 'labels'
labels= []
for col in df.columns:
    labels.append(re.sub(r" ?\([^)]+\)", "", col))
#rename columns to labels
df.columns= labels

#%% Add unique fileID for each session (subject & date)

#sort by date and subject
df= df.sort_values(['date','subject'])

df.loc[:,'fileID'] = df.groupby(['date', 'subject']).ngroup()



# %% Add other variables if necessary before tidying

# # calculate port exit time estimate using PEtime and peDur, save this as a new variable
df = df.assign(PExEst=df.PEtime + df.PEdur)

# save cue duration (in DS task this is A(2))
#TODO: may be better to put this in session metadata.xlsx? just to keep things parallel with photometry TDT data analysis (assume we won't import MPC as well)

#group by fileID then retrieve the 2nd value in stageParams 
grouped= df.groupby('fileID')

df.loc[:,'cueDur']= grouped.stageParams.transform('nth',2)

grouped.stageParams.nth(2)

#convert 'date' to datetime format
df.date= pd.to_datetime(df.date)



#% Calculate trainDay 

#May be missing some synapse tanks, use cumcount of trainDay within subjects (dont trust metadata sheet)

# Add trainDay variable (cumulative count of sessions within each subject)
dfGroup= df.loc[df.groupby(['subject','fileID']).cumcount()==0]
# test= dfGroup.groupby(['subject','fileID']).transform('cumcount')
df.loc[:,'trainDay']= dfGroup.groupby(['subject'])['fileID'].transform('cumcount')
df.loc[:,'trainDay']= df.groupby(['subject','fileID']).fillna(method='ffill')


#Add cumulative count of training day within-stage (so we can normalize between subjects appropriately)
##very important consideration!! Different subjects can run different programs on same day, which can throw plots/analysis off when aggregating data by date.
dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
df['trainDayThisStage']=  dfGroup.groupby(['subject', 'stage']).transform('cumcount')
df.trainDayThisStage= df.groupby(['fileID'])['trainDayThisStage'].fillna(method='ffill').copy()



#%% ---- Replace invalid NS pe Ratios for stages <5

#MPC records a 0 but should be nan for plotting & analyses
df.loc[df.stage<5, 'mpcNSpeRatio']= None


#%% -REMOVE NAN STAGE DATA (To be fixed when metadata xlsx fixed or stage is pulled from MPC)

# at least if done here should be visible gap in trainDay

# df= df.loc[df.stage.notnull()]


#%% - Mark stages which pass behavioral criteria (for DS task, DS and NS PE Ratio)

# df['criteriaSes']= None

#stages 1-4= DS only 
dfTemp= df.loc[df.stage< 5].copy()


ind= dfTemp.mpcDSpeRatio >= criteriaDS 

ind= dfTemp.loc[ind].index

df.loc[ind, 'criteriaSes']= 1

#stage >5 includes NS also

dfTemp= df.loc[df.stage>= 5]

ind= ((dfTemp.mpcDSpeRatio >= criteriaDS ) & (dfTemp.mpcNSpeRatio <= criteriaNS))

ind=dfTemp.loc[ind].index

df.loc[ind,'criteriaSes']= 1

#%% - Mark Early vs. Late training data for comparison
# n first days vs. n final days (prior to meeting criteria)


#number of sessions to include as 'early' and 'late' (n+ 1 for the 0th session so n=4 would be 5 sessions)
nSes= 4


#stage at which to start reverse labelling of 'late' from last day of stage (not currently based on criteria label)
endStage= 7

#%% Add trainPhase label for early vs. late training days within-subject

# #
# # dfTemp= df.copy()

# # ind= dfTemp.loc[dfTemp.criteriaSes==1 & (dfTemp.stage == endStage)]

# #mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
# #this way can find easily and get last n sessions
# dfTemp= df.copy()

# dfGroup= dfTemp.loc[dfTemp.groupby('fileID').transform('cumcount')==0,:].copy() #one per session

# test= dfGroup.groupby(['subject','fileID','criteriaSes'], as_index=False)['trainDay'].count()



#- mark the absolute criteria point, set criteriaSes=2 (first session in endStage where criteria was met)
#this way can find easily and get last n sessionsdfTemp= df.copy()
dfTemp= df.copy()

#instead of limiting to criteria days, simply start last n day count from final day of endStage
# dfTemp= dfTemp.loc[dfTemp.criteriaSes==1]

dfTemp= dfTemp.loc[dfTemp.stage==endStage]

#first fileIDs for each subject which meet criteria in the endStage
# dfTemp= dfTemp.groupby(['subject']).first()#.index

#just get last fileID for each subj in endStage
dfTemp= dfTemp.groupby(['subject']).last()#.index

ind= dfTemp.fileID


df.loc[df.fileID.isin(ind),'criteriaSes']= 2

#- now mark last n sessions preceding final criteria day as "late"

#subset data up to absolute criteria session

#get trainDay corresponding to absolute criteria day for each subject, then get n prior sessions and mark as late
dfTemp2= df.copy()

# dfTemp2=dfTemp2.set_index(['subject'])
#explicitly saving and setting on original index to prevent mismatching (idk why this was happening but it was, possibly something related to dfTemp having index on subject)
dfTemp2=dfTemp2.reset_index(drop=False).set_index(['subject'])


#-- something wrong here with lastTrainDay assignment
dfTemp2['lastTrainDay']= dfTemp.trainDay.copy()

dfTemp2= dfTemp2.reset_index().set_index('index')

#get dates within nSes prior to final day 
ind= ((dfTemp2.trainDay>=dfTemp2.lastTrainDay-nSes) & (dfTemp2.trainDay<=dfTemp2.lastTrainDay))


#label trainPhase as late
dfTemp2.loc[ind,'trainPhase']= 'late'

df['trainPhase']= dfTemp2['trainPhase'].copy()

#add reverse count of training days within late phase (countdown to final day =0)
dfTemp2.loc[ind,'trainDayThisPhase']= dfTemp2.trainDay-dfTemp2.lastTrainDay

df['trainDayThisPhase']= dfTemp2['trainDayThisPhase'].copy()

#- Now do early trainPhase for first nSes
#just simply get first nSes starting with 0
ind= df.trainDay <= nSes

df.loc[ind,'trainPhase']= 'early'


#TODO- in progress (indexing match up)
# add forward cumcount of training day within early phase 
#only save into early phase subset
ind= df.trainPhase=='early'

dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
df.loc[ind,'trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount') #add 1 for intuitive count
df.trainDayThisPhase= df.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()

#old; add corresponding days for each phase for plot x axes- old; simple cumcount
# dfGroup= df.loc[df.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
# df['trainDayThisPhase']=  dfGroup.groupby(['subject', 'trainPhase']).transform('cumcount')
# df.trainDayThisPhase= df.groupby(['fileID'])['trainDayThisPhase'].fillna(method='ffill').copy()



#%% ----  melt() 2 columns of PE probability into one by trialType
idVars= ['fileID','subject','stage','date', 'trainDay', 'trainDayThisStage', 'trainPhase', 'trainDayThisPhase']
df= df.melt(id_vars= idVars, value_vars=['mpcDSpeRatio','mpcNSpeRatio'], var_name='trialType', value_name='mpcPEratio')

trialOrder2=['mpcDSpeRatio','mpcNSpeRatio']

#%% ---- change dtypes
df.subject= df.subject.astype('string')
df.trialType= df.trialType.astype('category')
df.stage= df.stage.astype('int64')
df.trainDay= df.trainDay.astype('int64')
df.trainPhase= df.trainPhase.astype('category')

# convert subj to number (otherwise getting plot errors)
#just strip ID from end (last 2 in string)
subjects= df.subject.unique()

for subj in subjects:
    
    df.loc[df.subject==subj, 'subject']=  subj[-2:]
    
df.subject= df.subject.astype('int64')



#%%---- Exclude subjects

# subjectsToExclude= [10, 17]

# subjectsControl= [16, 20]

df= df[~df.subject.isin(subjectsToExclude)]

# df= df[~df.subject.isin(subjectsControl)]
    

#%% -----Plot MPC calculated values


#%% Probability of 10s PE (by trialType)

# subset to one observation per trialType per file
ind= df.groupby(['fileID', 'trialType']).cumcount()==0

dfPlot= df.loc[ind]

# subset stages
# stagesToPlot= [1,2,3,4,5,6,7]
dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)]


f, ax = plt.subplots(1, 1)

g= sns.lineplot(data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDay', y='mpcPEratio', hue='trialType', hue_order=trialOrder2, alpha=0.3)

g= sns.lineplot(data= dfPlot, ax=ax, x= 'trainDay', y='mpcPEratio', hue='trialType', hue_order=trialOrder2)

plt.axhline(y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#facet by stage

g= sns.FacetGrid(data=dfPlot, row='trialType', col='stage')

# g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='mpcPEratio', hue='subject', palette='tab20')

g.add_legend()

g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#individual subjects

for subj in dfPlot.subject.unique():
    
    dfPlot2= dfPlot.loc[dfPlot.subject==subj]
    
    g= sns.FacetGrid(data=dfPlot2, row='stage')

    g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='mpcPEratio', hue='trialType', hue_order=trialOrder2, alpha=0.3)
    g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#%% Final draft here - stage 5 only, normalized by trainDayThisStage

# subset to one observation per trialType per file
ind= df.groupby(['fileID', 'trialType']).cumcount()==1

dfPlot= df.loc[ind]

# subset stages
# stagesToPlot= [1,2,3,4,5,6,7]
dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)]


f, ax = plt.subplots(1, 1)

g= sns.lineplot(data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDayThisStage', y='mpcPEratio', hue='trialType', hue_order=trialOrder2, alpha=0.3)

g= sns.lineplot(data= dfPlot, ax=ax, x= 'trainDayThisStage', y='mpcPEratio', hue='trialType', hue_order=trialOrder2)

plt.axhline(y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

# compare to recalculated values


#Add cumulative count of training day within-stage (so we can normalize between subjects appropriately)
##very important consideration!! Different subjects can run different programs on same day, which can throw plots/analysis off when aggregating data by date.
dfGroup= dfTidy.loc[dfTidy.groupby('fileID').transform('cumcount')==0,:].copy() #one per session
dfTidy['trainDayThisStage']=  dfGroup.groupby(['subject', 'stage']).transform('cumcount')
dfTidy.trainDayThisStage= dfTidy.groupby(['fileID'])['trainDayThisStage'].fillna(method='ffill').copy()


dfPlot= subsetData(dfTidy, stagesToPlot, trialTypesToPlot, eventsToPlot).copy()

#subset one observation per trial
#subset to 1 obs per trial for counting
dfPlot= subsetLevelObs(dfPlot, groupHierarchyTrialType)#.copy()


f, ax = plt.subplots(1, 1)

g= sns.lineplot(data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDayThisStage', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)

g= sns.lineplot(data= dfPlot, ax=ax, x= 'trainDayThisStage', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder)

plt.axhline(y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)


#%% Plot by trainPhase (early vs late)

# subset to one observation per trialType per file
ind= df.groupby(['fileID', 'trialType']).cumcount()==0

dfPlot= df.loc[ind]

# subset stages
# stagesToPlot= [1,2,3,4,5,6,7]
# dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)]


g= sns.FacetGrid(data=dfPlot, col='trainPhase', sharex=False)

g.map_dataframe(sns.lineplot,data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDayThisPhase', y='mpcPEratio', hue='trialType', hue_order=trialOrder2, alpha=0.3)
g.map_dataframe(sns.lineplot,data= dfPlot, ax=ax, x= 'trainDayThisPhase', y='mpcPEratio', hue='trialType', hue_order=trialOrder2)

g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

g.add_legend()

saveFigCustom(g, 'allSubjects-Figure1_trainData_trainPhase_mpcPEProb', savePath)


# g= sns.FacetGrid(data=dfPlot, row='subject', col='trainPhase', sharex=False)

# g.map_dataframe(sns.lineplot,data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDayThisPhase', y='mpcPEratio',style='subject', hue='trialType', hue_order=trialOrder2, alpha=0.3)


#- Compare to recalculated 10s PE prob

dfPlot= subsetData(dfTidy, stagesToPlot, trialTypesToPlot, eventsToPlot).copy()

#subset one observation per trial
#subset to 1 obs per trial for counting
dfPlot= subsetLevelObs(dfPlot, groupHierarchyTrialType)#.copy()


g= sns.FacetGrid(data=dfPlot, col='trainPhase')

g.map_dataframe(sns.lineplot,data= dfPlot, units='subject', estimator=None, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder, alpha=0.3)
g.map_dataframe(sns.lineplot,data= dfPlot, x= 'trainDayThisPhase', y='trialTypePEProb10s', hue='trialType', hue_order=trialOrder)

g.map(plt.axhline,y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

g.add_legend()

saveFigCustom(g, 'allSubjects-Figure1_trainData_trainPhase_PEProb10s', savePath)

