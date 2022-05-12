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

#DS PE probability criteria (for visualization)
criteriaDS= 0.6

#%% Exclude subjects

subjectsToExclude= [10, 17]

subjectsControl= [16, 20]

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
test= df.sort_values(['date','subject'])

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


#%% -----Plot MPC calculated values


#%% Probability of 10s PE (by trialType)

# subset to one observation per file
ind= df.groupby(['fileID']).cumcount()==1

dfPlot= df.loc[ind]

# subset stages
stagesToPlot= [1,2,3,4,5,6,7]

dfPlot= dfPlot.loc[dfPlot.stage.isin(stagesToPlot)]


# melt() 2 columns of PE probability into one by trialType
idVars= ['fileID','subject','stage','trainDay']
dfPlot= dfPlot.melt(id_vars= idVars, value_vars=['mpcDSpeRatio','mpcNSpeRatio'], var_name='trialType', value_name='mpcPEratio')

trialOrder=['mpcDSpeRatio','mpcNSpeRatio']

# change dtypes
dfPlot.subject= dfPlot.subject.astype('string')
dfPlot.trialType= dfPlot.trialType.astype('category')
dfPlot.stage= dfPlot.stage.astype('category')
dfPlot.trainDay= dfPlot.trainDay.astype('int64')

# convert subj to number (otherwise getting plot errors)
#just strip ID from end (last 2 in string)
subjects= dfPlot.subject.unique()

# subjectsID= subjects.copy()

for subj in subjects:
    # subjectsID[subjectsID==subj]= subj[-2:]
    
    dfPlot.loc[dfPlot.subject==subj, 'subject']=  subj[-2:]
    
dfPlot.subject= dfPlot.subject.astype('int64')

f, ax = plt.subplots(1, 1)

g= sns.lineplot(data= dfPlot, ax=ax, units='subject', estimator=None, x= 'trainDay', y='mpcPEratio', hue='trialType', hue_order=trialOrder, alpha=0.3)

g= sns.lineplot(data= dfPlot, ax=ax, x= 'trainDay', y='mpcPEratio', hue='trialType', hue_order=trialOrder, alpha=0.3)

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

    g.map_dataframe(sns.lineplot, units='subject', estimator=None, x= 'trainDay', y='mpcPEratio', hue='trialType', hue_order=trialOrder, alpha=0.3)
    g.map(plt.axhline, y=criteriaDS, color=".2", linewidth=3, dashes=(3,1), zorder=0)

