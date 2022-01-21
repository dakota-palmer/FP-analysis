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

#%% Load regression input.pkl
dataPath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

dfTemp= pd.read_pickle(dataPath+'dfRegressionInput.pkl')

#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfTidymeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% Run regression model & save output
#TODO: How to handle different subjects? should run separately in loop or use as predictor?
#unlike matlab version of code this is one big table with everything

#TESTING with subset
# dfTemp= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.min()]

# test= dfTemp.iloc[:,20]
# test2= test.unique()

#Run separately on each subject. Finding groupby() of sparse is way too slow
# groups= dfTemp.copy().groupby(['subject'])

# for name, group in groups:
    
subjects= dfTemp.subject.unique()
for subj in subjects:
    group= dfTemp.loc[dfTemp.subject==subj]
    #define predictor and response variables
    #regressors/predictors will be all remaining columns that are not idVars or contVars
    col= ~group.columns.isin(idVars+contVars+['trainDayThisStage'])
    # X = group.loc[:,col]
    
    #--Remove invalid observations 
    #pd.shift() timeshift introduced nans at beginning and end of session 
    #(since there were no observations to fill with); Exclude these timestamps
    #regression inputs should not have any nan & should be finite; else  will throw error
    #--shouldn't happen now since fill_values=0
    # dfTemp= dfTemp.loc[~X.isin([np.nan, np.inf, -np.inf]).any(1),:]
    
    # X = group.loc[:,col]
    
    #use index instead of copying data (save memory)
    X= col
    
    # #examining input data
    # np.any(np.isnan(X))
    # np.all(np.isfinite(X))
    
    
    #regressand/response variable is fp signal
    # y = group["reblue"]
    y= 'reblue'
    
    #define cross-validation method to evaluate model
    cv = RepeatedKFold(n_splits=5, n_repeats=3, random_state=1)
    
    #define model
    model = LassoCV(alphas=np.arange(0, 1, 0.01), cv=cv, n_jobs=-1)
    
    #fit model
    model.fit(group.loc[:,X], group.loc[:,y])
    
    #display lambda that produced the lowest test MSE
    print(model.alpha_)
    
    #save model output?
    savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

    print('saving model to file')
    
    #Save as pickel
    pd.to_pickle(model, (savePath+'subj'+str(subj)+'regressionModel.pkl'))
        


    #%-- Visualize kernels
    
    #coefficients: 1 col for each shifted version of event timestamps in the range of timeShifts. events ordered sequentially
    
    b= model.coef_

    kernels= pd.DataFrame()
    kernels['beta']= np.empty(len(b))
    kernels['eventType']= np.empty(len(b))
    kernels['timeShift']= np.empty(len(b))

    
    
    for eventCol in range(len(eventVars)):
        if eventCol==0:
            ind= np.arange(0,(eventCol+1)*len(np.arange(-preEventTime,postEventTime)))
        else:
            ind= np.arange((eventCol)*len(np.arange(-preEventTime,postEventTime)),((eventCol+1)*len(np.arange(-preEventTime,postEventTime)-1)))
       
        # kernels[(eventVars[eventCol]+'-coef')]= b[ind]
        kernels.loc[ind,'beta']= b[ind]
        kernels.loc[ind,'eventType']= eventVars[eventCol]
        kernels.loc[ind, 'timeShift']= np.arange(-preEventTime,postEventTime)/fs

        
        
            
    #Plot
    # sns.FacetGrid(eventCol,1)
    # sns.relplot(data= kernels.iloc[:,eventCol], kind='line')
    sns.relplot(data=kernels, x='timeShift', y='beta', hue='eventType', kind='line')
        

#%% 

#Establish hierarchical grouping for analysis
#want to be able to aggregate data appropriately for similar conditions, so make sure group operations are done correctly
groupers= ['subject', 'trainDayThisStage', 'fileID']