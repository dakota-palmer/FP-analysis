# -*- coding: utf-8 -*-
"""
Created on Fri Mar 18 10:00:35 2022

@author: Dakota
"""

#% script to load model output and make plots without running regression again

#%% import dependencies

import numpy as np
import scipy.io as sio
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
 
import shelve


from sklearn.linear_model import LassoCV
from sklearn.model_selection import RepeatedKFold
from sklearn.model_selection import cross_val_score

import statsmodels.api as sm
import statsmodels.formula.api as smf


from customFunctions import saveFigCustom

from plot_lasso_model_selection import plot_lasso_model_selection


import time

import os

from sklearn.metrics import r2_score


    
#%% Plot settings
sns.set_style("darkgrid")
sns.set_context('notebook')

savePath= r'./_output/fpEncodingModelPlots/'


#%% Declare data to exclude from plots

subjectsToExclude= [17]

print(subjectsToExclude)

#%% TODO: Load other variables

# preEventTime, postEventTime, fs, cueTimeOfInfluence

fs= 40

preEventTime= 5 *fs
postEventTime= 10 *fs

cueTimeOfInfluence= 2*fs
#%% Get all .pkl files in encoding model output folder (1 per subj)
    
dataPath= r'./_output/fpEncodingModelStats/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 



files= []
# return all files as a list
for file in os.listdir(dataPath):
     # check the files which are end with specific extension
    if file.endswith(".pkl"):
        # print path name of selected files
        print(os.path.join(dataPath), file)
        
        files.append(file)
        
        
#%% Combine individual subj data into single dataframe for all subj


dfEncoding= np.empty([len(files),0])
dfEncoding= pd.DataFrame(dfEncoding) 


for file in range(len(files)):
    dfTemp= pd.read_pickle(dataPath+files[file])
    
    dfEncoding.loc[file,'file']= files[file]
    dfEncoding.loc[file,'model_lasso']= dfTemp.loc[0,'model_lasso']
    dfEncoding.loc[file,'subject']= dfTemp.loc[0, 'subject']
    dfEncoding.loc[file,'modelName']= dfTemp.loc[0, 'modelName']
    dfEncoding.loc[file,'modelStage']= dfTemp.loc[0, 'modelStage']
    dfEncoding.loc[file,'nSessions']= dfTemp.loc[0, 'nSessions']
    
    dfEncoding.loc[file,'modeCue']= dfTemp.loc[0,'modeCue']
    dfEncoding.loc[file,'modeSignal']= dfTemp.loc[0,'modeSignal']
    
    dfEncoding.loc[file,'modelInput']= [dfTemp.loc[0, 'modelInput']]
    
    #error in X between 2 files for some reason. first works fine. seem identical in dfTemp
    # dfEncoding.loc[file,'X']= dfTemp.loc[0, 'X']  
    dfEncoding.loc[file,'X']= [[dfTemp.loc[0, 'X']]]

    
    dfEncoding.loc[file,'y']= dfTemp.loc[0, 'y']
    dfEncoding.loc[file,'eventVars']= [[dfTemp.loc[0, 'eventVars']]] #[[pd.Series(dfTemp.loc[0, 'eventVars'])]]
    
    
    # dfEncoding.iloc[file,:]= dfTemp.iloc[file,:]
    
#%% Exclude subjectsToExclude

dfEncoding= dfEncoding.loc[~dfEncoding.subject.isin(subjectsToExclude)]

dfEncoding= dfEncoding.reset_index()

#%% Set fixed order of eventVars for consistent hue/color faceting


#- Manual; DS events specifically

eventOrder= ['DStime','PEcue','lickPreUS','lickUS']

# - TODO: default should be pd categorical order if categorical dtype

#%% Save model metadata to string for informative output filenames 

# TODO: maybe grab all .pkls then use a 'modelType' or something to denote stage/nSessions/signal type/cue type
# to do group analyses / subset 

# ** For now, assume all .pkl in the dataPath should be in aggregated analysis

dfTemp= dfEncoding.copy()

dfTemp.modelStage= dfTemp.modelStage.astype(int)
dfTemp.nSessions= dfTemp.nSessions.astype(int)

dfTemp.nSessions= dfTemp.nSessions+1

dfTemp= dfTemp.astype('str').copy()

modelStr= 'stage-'+dfTemp.loc[0,'modelStage']+'-'+ dfTemp.loc[0,'nSessions']+ '-sessions-'+ dfTemp.loc[0,'modeCue']+ '-'+ dfTemp.loc[0,'modeSignal']



#add some manual adjustments to modelStr based on newer options
# currently assume all same parameters per file in dfEncoding
#todo: these should be included in saving of dfEncoding and added to modelStr above

##search model name string for paramters and change accordingly
# if 'dff-raw' in dfEncoding.modelName[0]:
#     modelStr= modelStr+'-dff-raw-'

# elif 'dff-z' in dfEncoding.modelName[0]:
#     modelStr= modelStr+'dff-z-'
    
# elif ('-z' in dfEncoding.modelName[0]) & ('dff' not in dfEncoding.modelName[0]):
#     modelStr= modelStr+ '-z-'

#%% Plot entire cross validation (CV) path (MSE + coefficients)

## commenting out for now due to error with sparse format 

# #initialize dfs to collect data between subjs
# msePathAll= pd.DataFrame()
# modelPathAll= pd.DataFrame()

# alphaAll= []

# for subj in dfEncoding.subject.unique():

    
#     #get data for this subj from df
#     ind= np.where(dfEncoding.subject==subj)
    
#     dfTemp= dfEncoding.loc[ind].reset_index().copy() #reset index so can just retrieve values with [0]
    
#     # model= dfEncoding.loc[ind, 'model_lasso'][0]
    
#     # group= dfEncoding.loc[ind, 'modelInput'][0]
    
#     # X= dfEncoding.loc[ind, 'X']
    
#     model= dfTemp['model_lasso'][0] 
    
    
#     group= dfTemp['modelInput'][0][0]
     
#     X= dfTemp['X'][0][0][0]
#     y= dfTemp['y']
    
#     eventVars= dfTemp['eventVars']
#     eventVars= eventVars[0]

#     eventVars= eventVars[0]
    

    
#     #collect data from path for this subj, combin single dataset
    
#     #doesn't seem to be giving the full path across all cv's just a mean I guess?
#     #these two give identical results:
            
#             #error happens when calling model.path
#         #getting sparse error for X? idk why exact same code runs fine in stats script
#     #TODO: fix this?~~~~~~ dense is wasting time ~~~~ this seems VERY slow with dense data
#     #idk why the data look identical between 2 kernels
#     #subj 11 was dtype int32 i think...      
#     #specifically hitting errro with subj 12, 11 was fine (also first)
   
#     #could it be due to saving/loading as pkl?
    
#     # group.loc[:,X]= group.loc[:,X].sparse.to_dense()
            
            
#     pathAlphas, pathCoefs, pathDualGaps = model.path(group.loc[:,X],group.loc[:,y])
#     # pathAlphas, pathCoefs, pathDualGaps= model.path(group.loc[:,X],group.loc[:,y], cv=cv)
    
#     #ConvergenceWarning:
#   #   C:\Users\Dakota\anaconda3\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:625: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 7.928517767191806, tolerance: 4.217718462234285
#   # model = cd_fast.enet_coordinate_descent_multi_task(
    
#     #nested for some reason in this script?? not an issue in stats script...
#     pathCoefs= pathCoefs[0] 
    
#     msePath= pd.DataFrame(model.mse_path_)
#     msePath= msePath.reset_index().melt(id_vars= 'index', value_vars=msePath.columns, var_name='cvIteration', value_name='MSE')
#     msePath= msePath.rename(columns={"index": "alphaCount"})
    
#     msePath['alpha']= np.nan
    
#     msePath['alpha']= model.alphas_[msePath.alphaCount]
    
    
#     #initialize df to store path
#     modelPath= pd.DataFrame()
#     modelPath['alpha']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
#     modelPath['coef']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
#     modelPath['dualGap']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
#     modelPath['modelCount']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
#     modelPath['predictor']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
#     modelPath['eventType']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
#     modelPath[:]= np.nan
    
       
#     #fill df with data from each iteration along the path
#     ind= np.arange(0,(pathCoefs.shape[0]))
#     for thisModel in range(0,len(pathAlphas)):
    
#         pathAlphas_lasso = np.empty(pathCoefs.shape[0]) #repeat array so each coef has corresponding alpha
#         pathAlphas_lasso[:]= pathAlphas[thisModel]
    
#         pathDualGaps_lasso = np.empty(pathCoefs.shape[0]) #repeat array so each coef has corresponding alpha
#         pathDualGaps_lasso[:]= pathDualGaps[thisModel]
        
#         modelCount_lasso = np.empty(pathCoefs.shape[0]) #repeat array so each coef has corresponding alpha
#         modelCount_lasso[:]= thisModel
        
#         predictor_lasso= group.columns[X] #np.arange(0,len(pathCoefs[:,thisModel]))
        
    
#         pathCoefs_lasso= pathCoefs[:,thisModel]
        
    
#         modelPath.loc[ind,'alpha']= pathAlphas_lasso
#         modelPath.loc[ind,'coef']= pathCoefs_lasso
#         modelPath.loc[ind,'dualGap']= pathDualGaps_lasso
#         modelPath.loc[ind, 'modelCount']= modelCount_lasso
#         modelPath.loc[ind, 'predictor']= predictor_lasso
        
#         #go through more specifically and label eventType of each predictor
#         eventType_lasso= np.empty(pathCoefs.shape[0])
#         eventType_lasso= pd.Series(eventType_lasso)#,index=predictor_lasso)
    
    
#         for eventCol in range(len(eventVars)):
#             indEvent= group.columns[X].str.contains(eventVars[eventCol])
            
#             # indEvent= group[X].columns.str.contains(eventVars[eventCol])

    
#             eventType_lasso[indEvent]= eventVars[eventCol]
    
#             #assigning .values since i made this a series and index doesn't align
#         modelPath.loc[ind, 'eventType']= eventType_lasso.values
    
#         ind= ind+(pathCoefs.shape[0])
    
    
#     #save data from this subj into single df using concat()
    
#     msePath['subject']= subj
    
#     msePathAll= pd.concat([msePathAll, msePath], axis=0)
    
#     modelPath['subject']= subj
    
#     modelPathAll= pd.concat([modelPathAll, modelPath], axis=0)
    
#     alphaAll.append(model.alpha_)
    
#     #reset index for unique
#     msePathAll= msePathAll.reset_index()
#     modelPathAll= modelPathAll.reset_index()
    
    
# #%% --plot after combining data between subjs

#  # #-MSE path + coefficient path
# f, ax = plt.subplots(2,1)

# #mse
# g=sns.scatterplot(ax=ax[0], data=msePathAll, x='alpha', y='MSE', hue='cvIteration', palette='Blues')
# g=sns.lineplot(ax=ax[0], data=msePathAll, x='alpha', y='MSE', hue='subject') #subj mean

# # g=sns.lineplot(ax=ax[0], data=msePathAll, x='alpha', y='MSE', color='black')
# # plt.axvline(model.alpha_, color='black', linestyle="--", linewidth=3, alpha=0.5)

# # plt.axvline(alphaAll, color='black', linestyle="--", linewidth=3, alpha=0.5) # TODO: chosen alpha line for each subj

# ax[0].set_xscale('log')
# ax[0].set_xlabel('log alpha')


# g.set_xlabel('alpha')
# g.set_ylabel('MSE')
# # g.set(title=('subj-'+str(subj)+'-LASSO MSE across CV folds-'+modeCue+'-trials-'+modeSignal))
# g.set(xlabel='alpha', ylabel='MSE')

# #coef path
# # g=sns.lineplot(ax= ax[1], data=modelPathAll, estimator=None, units='predictor', x='alpha', y='coef', hue= 'eventType', hue_order=eventOrder, alpha=0.05)
# # g=sns.lineplot(ax= ax[1], data=modelPathAll,  x='alpha', y='coef', hue= 'eventType', hue_order=eventOrder, palette='dark')
# # g=sns.lineplot(ax= ax[1], data=modelPathAll, estimator=None, units='predictor', x='alpha', y='coef', style='subject', hue= 'eventType', hue_order=eventOrder, alpha=0.05)

# g=sns.lineplot(ax= ax[1], data=modelPathAll,  x='alpha', y='coef', hue= 'eventType', hue_order=eventOrder, style='subject') #, palette='dark')


# # plt.axvline(model.alpha_, color='black', linestyle="--", linewidth=3, alpha=0.5)
# ax[1].set_xscale('log')
# ax[1].set_xlabel('log alpha')

# # g.set(title=('allSubj-'+'-LASSO Coef. Path-'+modeCue+'-trials-'+modeSignal))
# g.set(ylabel='coef')
# # ax.set_xscale('log') #log scale if wanted

# saveFigCustom(f, 'allSubj-'+'-lassoValidation-',savePath)#+modeCue+'-trials-'+modeSignal, savePath)

# #%% - Side by side plot of coefficient path by event type 

# #TODO: add a timeShift for coefficients? unclear if early vs late effects

# #%% Side by side plot of kernels

# # g= sns.FacetGrid(data= modelPathAll, row= 'eventType', row_order=eventOrder, hue= 'eventType', hue_order=eventOrder)

# # g.map_dataframe(sns.lineplot, x='alpha', y='coef', style='subject', alpha=0.5)    

# # g.map_dataframe(sns.lineplot, x='alpha', y='coef', linewidth=2)            

# # g.axes[0][0].legend(kernelsAll.subject.unique())

# # g.add_legend()


#%%-- Retrieve Kernels 
kernelsAll= pd.DataFrame()

for subj in dfEncoding.subject.unique():

    
#-get data for this subj from df
    ind= np.where(dfEncoding.subject==subj)
    
    dfTemp= dfEncoding.loc[ind].reset_index().copy() #reset index so can just retrieve values with [0]
    
    # model= dfEncoding.loc[ind, 'model_lasso'][0]
    
    # group= dfEncoding.loc[ind, 'modelInput'][0]
    
    # X= dfEncoding.loc[ind, 'X']
    
    model= dfTemp['model_lasso'][0] 
    
    
    group= dfTemp['modelInput'][0][0]
     
    X= dfTemp['X'][0][0][0]
    y= dfTemp['y']
    
    eventVars= dfTemp['eventVars']
    eventVars= eventVars[0][0]
    
    # X= dfEncoding.loc[ind, 'X']
    
    # X= group.columns[X]

    # y= dfEncoding.loc[ind, 'y'][0]
    # eventVars= dfEncoding.loc[ind,'eventVars'][0]
    eventVars= eventVars[0]
    #coefficients: 1 col for each shifted version of event timestamps in the range of timeShifts. events ordered sequentially
     
    #alt method of lining up coef with feature names:
        # for eventCol in range(len(eventVars)):
        #     indEvent= group.columns[X].str.contains(eventVars[eventCol])

        #     eventType_lasso[indEvent]= eventVars[eventCol]
    
    b= model.coef_


#-now actually get kernels
    kernels= pd.DataFrame()
    kernels['beta']= np.empty(len(b))
    kernels['predictor']= np.empty(len(b))
    kernels['eventType']= np.empty(len(b))
    kernels['timeShift']= np.empty(len(b))
    
    #adding statsmodels output
    # kernels['betaStatsModels']= np.empty(len(b))
     
    kernels.loc[:,'beta']= b
    kernels.loc[:,'predictor']= group.columns[X]
            
    #assign eventType specific info
    for eventCol in range(len(eventVars)):
        indEvent= group.columns[X].str.contains(eventVars[eventCol])
        
        if ((eventVars[eventCol]== 'DStime' )|(eventVars[eventCol]=='NStime')):
            postEventShift= cueTimeOfInfluence
        else:
            postEventShift= postEventTime
        
        # postEventShift= postEventTime

        kernels.loc[indEvent,'eventType']= eventVars[eventCol]
        kernels.loc[indEvent, 'timeShift']= np.arange(-preEventTime,postEventShift)/fs
            
        #-- calculate kernel AUC for this event 
        #AUC of beta coefficient
        
        # not most appropriate- #using sklearn.metrics.auc() function
        # from sklearn import metrics
        # kernels.loc[indEvent,'betaAUC']= metrics.auc(kernels.loc[indEvent,'timeShift'],kernels.loc[indEvent, 'beta'])
        
        #using numpy.trapz function
        # kernels.loc[indEvent,'betaAUC']= np.trapz(kernels.loc[indEvent,'timeShift'],kernels.loc[indEvent, 'beta'])
        # kernels.loc[indEvent,'betaAUC']= np.trapz(kernels.loc[indEvent, 'beta'])

        
        #using scipy.integrate function (trapezoidal method)
        from scipy import integrate
        
        # test= integrate.trapezoid(kernels.loc[indEvent,'beta'])
        # test2= integrate.cumulative_trapezoid(kernels.loc[indEvent,'beta'])

        #compute AUC separately Pre- and Post- Event
        
        #define time in s to include in AUC (want equivalent time for pre & post comparison)
        aucTime= 2  
        
        # #define sampling rate of AUC
        # aucDx= 1/fs
        
        # # #testing scipy.integrate parameters
        # # giving time range x gives more interpretable values (distro is same)
        # # test=  integrate.trapezoid(kernels.loc[ind,'beta'])
        
        # # #below 3 yield equivalent result.
        # # test1=  integrate.trapezoid(kernels.loc[ind,'beta'], x= kernels.loc[ind,'timeShift'])
        # # test2=  integrate.trapezoid(kernels.loc[ind,'beta'], dx= aucDx)
        # # test3=  integrate.trapezoid(kernels.loc[ind,'beta'], x= kernels.loc[ind,'timeShift'], dx= aucDx)

        
        
        ind= []
        ind= (indEvent) & (kernels.timeShift<0) & (kernels.timeShift>= -aucTime) #pre-event
        
        # kernels.loc[ind,'betaAUCpreEvent']= integrate.trapezoid(kernels.loc[ind,'beta'])
        kernels.loc[ind,'betaAUCpreEvent']= integrate.trapezoid(kernels.loc[ind,'beta'], kernels.loc[ind,'timeShift'])

        
        
        ind= []
        ind= (indEvent) & (kernels.timeShift>0) & (kernels.timeShift <=aucTime) #post-event
        
        kernels.loc[ind,'betaAUCpostEvent']= integrate.trapezoid(kernels.loc[ind,'beta'], kernels.loc[ind,'timeShift'])
        

    
    #add data to from this subject to larger df, kernelsAll
    kernels['subject']= subj
        
    kernelsAll= pd.concat([kernelsAll, kernels], axis=0)

#reset index after combining
kernelsAll= kernelsAll.reset_index()
    
    # for eventCol in range(len(eventVars)):
    #     if eventCol==0:
    #         ind= np.arange(0,(eventCol+1)*len(np.arange(-preEventTime,postEventShift)))
    #     else:
    #         ind= np.arange((eventCol)*len(np.arange(-preEventTime,postEventShift)),((eventCol+1)*len(np.arange(-preEventTime,postEventShift)-1)))
       
    #     # kernels[(eventVars[eventCol]+'-coef')]= b[ind]
    #     kernels.loc[ind,'beta']= b[ind]
    #     kernels.loc[ind,'eventType']= eventVars[eventCol]
    #     kernels.loc[ind, 'timeShift']= np.arange(-preEventTime,postEventShift)/fs
    #     # kernels.loc[ind,'betaStatsModels']= fit.params[ind].values
        
        
    # #compare scikitlearn vs statsmodels output
    # f, ax = plt.subplots(2, 1)
    # g= sns.lineplot(ax=ax[0,], data=kernels, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder)
    # g.set(title=('subj-'+str(subj)+'-kernels-'+modeCue+'-trials-'+modeSignal))
    # g.set(xlabel='timeShift from event onset (s)', ylabel='beta coef. statsModels')
    # g= sns.lineplot(ax=ax[1,], data=kernels, x='timeShift',y='betaStatsModels',hue= 'eventType', hue_order=eventOrder)
    # g.set(title=('subj-'+str(subj)+'-StatsModels-kernels-'+modeCue+'-trials-'+modeSignal))


#%%-- Compute Predicted y values based on regression output

#prediction? maybe use actual timeshift=0 values?
# #need equal number of columns so probably a different session or trial subset
dfPredictedAll= pd.DataFrame();

for subj in dfEncoding.subject.unique():
    #get data for this subj from df
    ind= np.where(dfEncoding.subject==subj)
    
    dfTemp= dfEncoding.loc[ind].reset_index().copy() #reset index so can just retrieve values with [0]
    
    # model= dfEncoding.loc[ind, 'model_lasso'][0]
    
    # group= dfEncoding.loc[ind, 'modelInput'][0]
    
    # X= dfEncoding.loc[ind, 'X']
    
    model= dfTemp['model_lasso'][0] 
    
    
    group= dfTemp['modelInput'][0][0]
     
    X= dfTemp['X'][0][0][0]
    y= dfTemp['y']
    
    eventVars= dfTemp['eventVars']
    eventVars= eventVars[0]


    dfPredicted= pd.DataFrame()
    #get prediction by calling sklearn's model.predict()
    yPredicted= pd.Series(model.predict(group.loc[:,X]))
    
    #compute r2 
    # r2_score= r2_score(y_test, y_pred_lasso)
    r2= r2_score(group[y], yPredicted)


    
    group= group.reset_index(drop=True)
    #get columns with actual event times?
    #error here
    # col= group.columns.str.contains(r'\+0')
    # yPredicted= model.predict(group.loc[:,col])

    
#output of dfPredicted here is 18030... 30 trials x each timestamp?
#so one predicted value per trial (not 1 per file like previously thought)

    dfPredicted['yPredicted']= yPredicted
    
    dfPredicted['y']= group.loc[:,y]

    dfPredicted['timeLock']= group.loc[:,((group.columns.str.contains('timeLock') & (~group.columns.str.contains('trialID'))))]
    
    dfPredicted['intercept']= model.intercept_
    
    dfPredicted['trialIDtimeLock']= group.loc[:,group.columns.str.contains('trialIDtimeLock')]
    
    #get r2 as well (model.score())
    #TODO: double check r2 calc
    # dfPredicted['r2']= model.score(group.loc[:,X],group.loc[:,y], sample_weight=None)
    dfPredicted['r2']= r2


    dfPredicted['subject']= subj

    #model.fit() is resulting in 
    #30 similar, many equivalent predictions for y per timestamp per trial
    #TODO: should this dataset be dividing trials or something? currently every timestamp has equivalent predictive power?
    
    # # Try with only actual timestamps @ timeShift 0?
    
    # #set all timeShift columns except the actual even onset column to all 0  
    
    # #no- doesn't really make sense. This is using n predictors but eliminating relevant info
    # xActual= group.copy()
    
    # col= group.columns.str.contains(r'\+0')

    # xActual.loc[:,~col]= 0
    
    # yPredicted= model.predict(xActual.loc[:,X])
    
    # dfPredicted['yPredicted2']= yPredicted



    #TODO: Get prediction based on ACTUAL event timestamps at timeShift=0 ?
    #or
    #TODO: Simply sum Kernels as prediction (like in the Parker code?)
    # betaSum= kernelsAll.groupby(['subject','timeShift'])['beta'].sum().reset_index()
    # dfPredicted['betaSum']= sumCoef
    
    #or
    #TODO: get another session/subset of trials?

    
    #combine into 1 df by concat()
    dfPredictedAll= pd.concat([dfPredictedAll, dfPredicted], axis=0)
    

#reset index for unique
dfPredictedAll= dfPredictedAll.reset_index()



#%%  TODO: linear sum of kernels at time=0

# # TODO: sum Kernels as prediction (like in the Parker 2016 paper)

# #kernels need to be shifted to time=0 of each event onset prior to summation.

# kernelsShiftedAll= pd.DataFrame()

# for subj in dfEncoding.subject.unique():

    
#     #get data for this subj from df
#     ind= np.where(dfEncoding.subject==subj)
    
#     dfTemp= dfEncoding.loc[ind].reset_index().copy() #reset index so can just retrieve values with [0]

    
#     model= dfTemp['model_lasso'][0] 
    
    
#     group= dfTemp['modelInput'][0]
     
#     X= dfTemp['X'][0][0]
#     y= dfTemp['y']
    
#     eventVars= dfTemp['eventVars']
#     eventVars= eventVars[0]
    
   
#     eventVars= eventVars[0]

    
#     b= model.coef_

#     # kernelsShifted= pd.DataFrame()
#     # kernels['beta']= np.empty(len(b))
#     # kernels['predictor']= np.empty(len(b))
#     # kernels['eventType']= np.empty(len(b))
#     # kernels['timeShift']= np.empty(len(b))
    
#     #adding statsmodels output
#     # # kernels['betaStatsModels']= np.empty(len(b))
     
#     # kernels.loc[:,'beta']= b
#     # kernels.loc[:,'predictor']= group.columns[X]
    
#     #copy input data but set all=0 except timeShift=0
#     xActual= group.copy()

#     col= group.columns.str.contains(r'\+0')

#     xActual.loc[:,~col]= 0
    
#     #just subset these cols? (probs will want metadata tho for plotting)
#     # xActual= xActual.loc[:,col]
    
#     #for each eventType insert corresponding kernel centered on onsets (1) at t=0         
    
    
#     #assign eventType specific info
#     for eventCol in range(len(eventVars)):
#         indEvent= xActual.columns.str.contains(eventVars[eventCol])
        
#         indOnset= np.where(xActual.loc[:,((indEvent) & (col))]==1)
        
#         # kernels.loc[indEvent,'eventType']= eventVars[eventCol]
#         # kernels.loc[indEvent, 'timeShift']= np.arange(-preEventTime,postEventShift)/fs
            

    
#     kernels['subject']= subj
        
#     kernelsAll= pd.concat([kernelsAll, kernels], axis=0)

# #reset index after combining
# kernelsAll= kernelsAll.reset_index()

# # #set all eventtimes
# # xActual= group.copy()

# # col= group.columns.str.contains(r'\+0')

# # xActual.loc[:,~col]= 0

# # yPredicted= model.predict(xActual.loc[:,X])

# # dfPredicted['yPredicted2']= yPredicted

# #sum
# betaSum= kernelsAll.groupby(['subject','timeShift'])['beta'].sum().reset_index()


#%%% Side by side plot of predicted values.

f, ax = plt.subplots(1, 4)


#actual periDS
g= sns.lineplot(ax=ax[0], data=dfPredictedAll, x='timeLock',y='y',hue='subject', alpha=0.3)
g= sns.lineplot(ax=ax[0], data=dfPredictedAll, x='timeLock',y='y', color='black')
g.set(title=('actual peri-DS signal'))


#linear sum of coefficients
g= sns.lineplot(ax=ax[1], data=kernelsAll, x='timeShift',y='beta',hue='subject', alpha=0.3)
g= sns.lineplot(ax=ax[1], data=kernelsAll, x='timeShift',y='beta', color='black')
g.set(title=('Prediction= linear sum of coef kernels'))

ax[1].sharey= ax[0]

# model.predict() of raw input data
g= sns.lineplot(ax=ax[2], data=dfPredictedAll, x='timeLock',y='yPredicted',hue='subject', alpha=0.3)
g= sns.lineplot(ax=ax[2], data=dfPredictedAll, x='timeLock',y='yPredicted', color='black')
g.set(title=('Prediction= model.predict(raw input)'))

ax[2].sharey= ax[0]


# #model.predict() of all 0 except timeShift=0 column
# g= sns.lineplot(ax=ax[2], data=dfPredictedAll, x='timeLock',y='yPredicted2',hue='subject', alpha=0.3)
# g= sns.lineplot(ax=ax[2], data=dfPredictedAll, x='timeLock',y='yPredicted2', color='black')
# g.set(title=('Prediction= predict(all 0 except shift=0)'))
#useless right? not all info

# f.set(suptitle=('Comparison of predicted vs. actual peri-DS signal'))

#-- R2 plot
g= sns.barplot(ax=ax[3],data= dfPredictedAll, y='r2')
g= sns.barplot(ax=ax[3],data= dfPredictedAll, x='subject', y='r2', hue='subject', palette='flare')



#%% Side by side plot of kernels

g= sns.FacetGrid(data= kernelsAll, row= 'eventType', row_order=eventOrder, hue= 'eventType', hue_order=eventOrder)

g.map_dataframe(sns.lineplot, x='timeShift', y='beta', style='subject', alpha=0.5)    

g.map_dataframe(sns.lineplot, x='timeShift', y='beta', linewidth=2)            

g.axes[0][0].legend(kernelsAll.subject.unique())

g.add_legend()

saveFigCustom(f, modelStr+'allSubj-'+'kernels', savePath)

            
#%% Plot kernels & predicted data

 
f, ax = plt.subplots(3, 1)

g= sns.lineplot(ax=ax[0,], data=kernelsAll, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, style='subject', alpha=0.3)

g= sns.lineplot(ax=ax[0,], data=kernelsAll, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, linewidth=2, palette='dark') #mean


g.set(title=('allSubj-kernels-'))#+modeCue+'-trials-'+modeSignal))
g.set(xlabel='timeShift from event onset (s)', ylabel='beta coef.')
# place a text box in bottom left in axes coords with more model info
# these are matplotlib.patch.Patch properties
# props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
# textstr= 'alpha with lowest MSE='+str(model.alpha_)+'(0=no penalty, OLS)'
# g.text(0.05, .1, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# textstr= 'intercept='+str(model.intercept_)
# g.text(0.05, 0.2, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# textstr= 'R2='+str(model.score(group.loc[:,X],group.loc[:,y], sample_weight=None))
# g.text(0.05, 0.3, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)


g= sns.lineplot(ax=ax[1,],data= dfPredictedAll, x='timeLock', y='yPredicted', color='black')
g= sns.lineplot(ax=ax[1,],data= dfPredictedAll, x='timeLock', y='yPredicted', style='subject', color='black', alpha=0.3)

g= sns.lineplot(ax=ax[2,], data=dfPredictedAll, x='timeLock', y='y', color='blue')
g= sns.lineplot(ax=ax[2,],data= dfPredictedAll, x='timeLock', y='y', style='subject', color='blue', alpha=0.3)


g.legend(['predicted (model.fit())','actual'])
g.set(title=('allSubj-'+'-periCueModelPrediction-'))#+modeCue+'-trials-'+modeSignal))
g.set(xlabel='time from cue onset', ylabel='Z-score FP signal')

saveFigCustom(f, modelStr+'allSubj-'+'model-prediction', savePath)

# saveFigCustom(f, 'subj-'+str(subj)+'-regressionOutput-'+modeCue+'-trials-'+modeSignal, savePath)

#-- R2 plot
f, ax = plt.subplots(1,1)

g= sns.barplot(ax=ax,data= dfPredictedAll,  y='r2')
g= sns.barplot(ax=ax,data= dfPredictedAll, x='subject',  y='r2', hue='subject')

saveFigCustom(f, modelStr+'allSubj-'+'r2-', savePath)


#%%-- Kernels with AUC plot 
f, ax = plt.subplots(1, 3)


#kernels
g= sns.lineplot(ax=ax[0], data=kernelsAll, units='subject', estimator=None, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, alpha= 0.3) #, style='subject', alpha=0.3)


g= sns.lineplot(ax=ax[0], data=kernelsAll, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, linewidth=2)#, palette='dark') #mean

g.legend().remove()

#AUC pre-event
g= sns.barplot(ax= ax[1], data= kernelsAll, dodge=False, x='eventType', y='betaAUCpreEvent', hue='eventType', hue_order=eventOrder)

g= sns.scatterplot(ax= ax[1], data= kernelsAll, x='eventType', y='betaAUCpreEvent', hue='eventType', hue_order=eventOrder, style='subject', alpha=0.3)

g= sns.lineplot(ax= ax[1], data=kernelsAll, units='subject', estimator=None, x='eventType', y='betaAUCpreEvent', color='gray', alpha=0.3)

g.legend().remove()


#AUC post-event
g= sns.barplot(ax= ax[2], data= kernelsAll, dodge=False, x='eventType', y='betaAUCpostEvent', hue='eventType', hue_order=eventOrder)

g= sns.scatterplot(ax= ax[2], data= kernelsAll, x='eventType', y='betaAUCpostEvent', hue='eventType', hue_order=eventOrder, style='subject', alpha=0.3)

g= sns.lineplot(ax= ax[2], data=kernelsAll, units='subject', estimator=None, x='eventType', y='betaAUCpostEvent', color='gray', alpha=0.3)

g.legend().remove()

#share AUC axes
ax[2].get_shared_y_axes().join(ax[1], ax[2])


# g.legend()

saveFigCustom(f, modelStr+'allSubj-'+'kernelsAUC', savePath)


#%% 

# #dp new plots 2022-05-02

# # Figure with subplot of 1) kernels, 2) modeled v predicted fp signal
# f, ax = plt.subplots(2, 1)

# g= sns.lineplot(ax=ax[0,], data=kernelsAll, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, style='subject', alpha=0.3)

# g= sns.lineplot(ax=ax[0,], data=kernelsAll, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, linewidth=2, palette='dark') #mean


# g.set(title=('allSubj-kernels-'))#+modeCue+'-trials-'+modeSignal))
# g.set(xlabel='timeShift from event onset (s)', ylabel='beta coef.')
# # place a text box in bottom left in axes coords with more model info
# # these are matplotlib.patch.Patch properties
# # props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
# # textstr= 'alpha with lowest MSE='+str(model.alpha_)+'(0=no penalty, OLS)'
# # g.text(0.05, .1, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# # textstr= 'intercept='+str(model.intercept_)
# # g.text(0.05, 0.2, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# # textstr= 'R2='+str(model.score(group.loc[:,X],group.loc[:,y], sample_weight=None))
# # g.text(0.05, 0.3, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)

# # currently this df has 1 observation per timestamp per trial
# g= sns.lineplot(ax=ax[1,], data= dfPredictedAll, x='timeLock', y='yPredicted', color='black')
# # g= sns.lineplot(ax=ax[1,], data= dfPredictedAll, units= 'subject', estimator=None, x='timeLock', y='yPredicted', style='subject', color='black', alpha=0.3)
# g= sns.lineplot(ax=ax[1,], data= dfPredictedAll, units= 'trialIDtimeLock', estimator=None, x='timeLock', y='yPredicted', style='subject', color='black', alpha=0.3)



# # g= sns.lineplot(ax=ax[1,], data=dfPredictedAll, x='timeLock', y='y', color='blue')
# # g= sns.lineplot(ax=ax[1,], data= dfPredictedAll, units= 'subject', estimator=None, x='timeLock', y='y', style='subject', color='blue', alpha=0.3)


# g.legend(['predicted (model.fit())','actual'])
# g.set(title=('allSubj-'+'-periCueModelPrediction-'))#+modeCue+'-trials-'+modeSignal))
# g.set(xlabel='time from cue onset', ylabel='Z-score FP signal')



#%% correcting above by using mean() across all trials for each subj

# Figure with subplot of 1) kernels, 2) modeled v predicted fp signal
f, ax = plt.subplots(2, 1)

g= sns.lineplot(ax=ax[0,], data=kernelsAll, units='subject', estimator=None, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, alpha=0.3)

g= sns.lineplot(ax=ax[0,], data=kernelsAll, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder, linewidth=2)#, palette='dark') #mean


g.set(title=('allSubj-kernels-'))#+modeCue+'-trials-'+modeSignal))
g.set(xlabel='timeShift from event onset (s)', ylabel='beta coef.')

# currently dfPredictedAll has 1 observation per timestamp per trial
# reduce to mean across all trials per subj

dfPlot= dfPredictedAll.groupby(['subject','timeLock'], as_index=False).mean()

g= sns.lineplot(ax=ax[1,], data= dfPlot, x='timeLock', y='yPredicted', color='black')
g= sns.lineplot(ax=ax[1,], data= dfPlot, units= 'subject', estimator=None, x='timeLock', y='yPredicted', color='black', alpha=0.3)

g= sns.lineplot(ax=ax[1,], data= dfPlot, x='timeLock', y='y', color='blue')
g= sns.lineplot(ax=ax[1,], data= dfPlot, units= 'subject', estimator=None, x='timeLock', y='y', color='blue', alpha=0.3)


g.legend(['predicted (model.fit())','actual'])
g.set(title=('allSubj-'+'-periCueModelPrediction-'))#+modeCue+'-trials-'+modeSignal))
g.set(xlabel='time from cue onset', ylabel='Z-score FP signal')

saveFigCustom(f, modelStr+'-allSubj-'+'model-prediction', savePath)

#%% TODO: Retrieve other peri-event data 


#%%  old

#swarmplot here seems very slow
# g= sns.swarmplot(ax=ax[2,],data= dfPredictedAll, y='r2', hue='subject')


# #single subj
# f, ax = plt.subplots(2, 1)

# g= sns.lineplot(ax=ax[0,], data=kernels, x='timeShift',y='beta',hue= 'eventType', hue_order=eventOrder)
# g.set(title=('subj-'+str(subj)+'-kernels-'+modeCue+'-trials-'+modeSignal))
# g.set(xlabel='timeShift from event onset (s)', ylabel='beta coef.')
# # place a text box in bottom left in axes coords with more model info
# # these are matplotlib.patch.Patch properties
# props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
# textstr= 'alpha with lowest MSE='+str(model.alpha_)+'(0=no penalty, OLS)'
# g.text(0.05, .1, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# textstr= 'intercept='+str(model.intercept_)
# g.text(0.05, 0.2, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# textstr= 'R2='+str(model.score(group.loc[:,X],group.loc[:,y], sample_weight=None))
# g.text(0.05, 0.3, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)


# g= sns.lineplot(ax=ax[1,],data=dfTemp.loc[group.index,:], x='timeLock-z-periDS-DStime', y=predicted, color='black')
# g= sns.lineplot(ax=ax[1,], data=dfTemp.loc[group.index,:], x='timeLock-z-periDS-DStime', y=y, color='blue')
# g.legend(['predicted??','actual'])
# g.set(title=('subj-'+str(subj)+'-periCueModelPrediction-'+modeCue+'-trials-'+modeSignal))
# g.set(xlabel='time from cue onset', ylabel='Z-score FP signal')

# saveFigCustom(f, 'subj-'+str(subj)+'-regressionOutput-'+modeCue+'-trials-'+modeSignal, savePath)



## Old -
# # sns.FacetGrid(eventCol,1)
# # sns.relplot(data= kernels.iloc[:,eventCol], kind='line')

# g=sns.relplot(data=kernels, x='timeShift', y='beta', hue= 'eventType', hue_order=eventOrder, style= 'subject', kind='line')
# g.set(title=('allSubj-kernels')#+modeCue+'-trials-'+modeSignal))
# g.set_ylabels('beta coef.')
# g.set_xlabels('timeShift from event onset (s)')

# # place a text box in upper left in axes coords with more model info
# # these are matplotlib.patch.Patch properties
# # props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
# # textstr= 'alpha with lowest MSE='+str(model.alpha_)
# # g.ax.text(0.05, 0.95, textstr, transform=g.ax.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# # textstr= 'intercept='+str(model.intercept_)
# # g.ax.text(0.05, 0.90, textstr, transform=g.ax.transAxes, fontsize=14, verticalalignment='top', bbox=props)




# ## single subj: 
# # g=sns.relplot(data=kernels, x='timeShift', y='beta', hue= 'eventType', hue_order=eventOrder, kind='line')
# # g.set(title=('subj-'+str(subj)+'-kernels-'+modeCue+'-trials-'+modeSignal))
# # g.set_ylabels('beta coef.')
# # g.set_xlabels('timeShift from event onset (s)')

# # # place a text box in upper left in axes coords with more model info
# # # these are matplotlib.patch.Patch properties
# # props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
# # textstr= 'alpha with lowest MSE='+str(model.alpha_)
# # g.ax.text(0.05, 0.95, textstr, transform=g.ax.transAxes, fontsize=14, verticalalignment='top', bbox=props)
# # textstr= 'intercept='+str(model.intercept_)
# # g.ax.text(0.05, 0.90, textstr, transform=g.ax.transAxes, fontsize=14, verticalalignment='top', bbox=props)





