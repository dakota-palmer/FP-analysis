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

import statsmodels.api as sm
import statsmodels.formula.api as smf

#%% PREPARING INPUT FOR PARKER ENCODING MODEL
# want - 
# x_basic= 148829 x 1803... # timestamps entire session x (# time shifts in peri-Trial window * num events). binary coded
# gcamp_y = 148829 x 1 ; entire session signal predicted by regression . z scored photometry signal currently nan during ITI & only valid values during peri-DS

    
 #%% define a function to save and close figures
def saveFigCustom(figure, figName):
    plt.gcf().set_size_inches((20,10), forward=False) # ~monitor size
    plt.legend(bbox_to_anchor=(1.01, 1), borderaxespad=0) #creates legend ~right of the last subplot
    
    plt.gcf().tight_layout()
    plt.savefig(r'./_output/_behaviorAnalysis/'+figName+'.png', bbox_inches='tight')
    plt.close()
    
#%% Run DS or NS?
modeCue= 'DS'
# modeCue= 'NS'


#%% Run 465nm or 405nm?
modeSignal= 'reblue' 
# modeSignal= 'repurple'


#%% Load regression input.pkl
dataPath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

if modeCue=='DS':
    dfTemp= pd.read_pickle(dataPath+'dfRegressionInputDSonly.pkl')
elif modeCue=='NS':
    dfTemp= pd.read_pickle(dataPath+'dfRegressionInputNSonly.pkl')


#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfRegressionInputMeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


# # contVars should be loaded from shelf
# contVars= list(dfTemp.columns[(dfTemp.columns.str.contains('reblue') | dfTemp.columns.str.contains('repurple'))])
# fs= 40


#% Define peri-event z scoring parameters
# fs= 40 #sampling frequency= 40hz

# preEventTime= 10 *fs # seconds x fs
# postEventTime= 10 *fs

# baselineTime= 10*fs


#%% Exclude data from opposite cue type (DS/NS) and photometry signal (465/405)
#ASSUMES that columns will contain mode string defined above: e.g. 'DS','NS' and 'reblue','repurple'

# mode= 'DS'

if modeCue=='DS':
    # # dfTemp= dfTemp.drop(['timeLock-z-periNS','repurple-z-periNS','reblue-z-periNS'],axis=1)
    # col= ~dfTemp.columns.str.contains('NS')
    # dfTemp= dfTemp.loc[:,col]
    exclude='NS'
if modeCue=='NS':
    # # dfTemp= dfTemp.drop(['timeLock-z-periDS','repurple-z-periDS','reblue-z-periDS','DStime'],axis=1)
    # col= ~dfTemp.columns.str.contains('DS')
    # dfTemp= dfTemp.loc[:,col]
    exclude='DS'
    
dfTemp= dfTemp.loc[:,~dfTemp.columns.str.contains(exclude)]

eventVars= eventVars[eventVars!=exclude+'time']


#TODO: automate fp signal dropping here, this is manually defined
if modeSignal=='reblue':
    dfTemp= dfTemp.drop(['repurple-z-periDS'],axis=1)
elif modeSignal=='repurple':
    dfTemp= dfTemp.drop(['reblue-z-periDS'],axis=1)



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
    
    #--Remove invalid observations 
#pd.shift() timeshift introduced nans at beginning and end of session 
#(since there were no observations to fill with); Exclude these timestamps
#regression inputs should not have any nan & should be finite; else  will throw error
#--shouldn't happen now since fill_values=0
# dfTemp= dfTemp.loc[~dfTemp.isin([np.nan, np.inf, -np.inf]).any(1),:]
    
subjects= dfTemp.subject.unique()
for subj in subjects:
    group= dfTemp.loc[dfTemp.subject==subj]
    #define predictor and response variables
    #regressors/predictors will be all remaining columns that are not idVars or contVars
    col= ~group.columns.isin(idVars+contVars+['trainDayThisStage','trialID','timeLock-z-periDS','timeLock-z-periNS'])
    
    # #visualizing test here
    # test= dfTemp.loc[dfTemp.fileID==dfTemp.fileID.min()]
    # test= test.iloc[:,col]
    
    # X = group.loc[:,col]
    
    #--Remove invalid observations 
    #pd.shift() timeshift introduced nans at beginning and end of session 
    #(since there were no observations to fill with); Exclude these timestamps
    #regression inputs should not have any nan & should be finite; else  will throw error
    #--shouldn't happen now since fill_values=0
    # dfTemp= dfTemp.loc[~dfTemp.isin([np.nan, np.inf, -np.inf]).any(1),:]
    
    # X = group.loc[:,col]
    
    #use index instead of copying data (save memory)
    X= col
    
    #TODO: Make sure variables are correct (e.g. i think timeLock is included with this definition)
    
    # #examining input data
    # np.any(np.isnan(X))
    # np.all(np.isfinite(X))
    
    
    #regressand/response variable is fp signal
    # y = group["reblue"]
    y= 'reblue-z-periDS'
    
    
    #define cross-validation method to evaluate model
    #TODO: adjust params, Parker code used 5 fold CV with all matlab default 
    #matlab default Alpha=1, lambda= automatic range, NumLambda=100, cv=5
    #sklearn default alphas= automatic range, n_alphas=100, cv=5, n_jobs uses all processors
    
    #also see https://www.statsmodels.org/dev/generated/statsmodels.regression.linear_model.OLS.fit_regularized.html 
    
    #3 fold validation, different combos with data split into 5 samples
    # random_state simply sets a seed to the random generator, so that your train-test splits are always deterministic. If you don't set a seed, it is different each time.
    # if a fixed value is assigned like random_state = 0 or 1 or 42 or any other integer then no matter how many times you execute your code the result would be the same .i.e, same values in train and test datasets.
    # cv = RepeatedKFold(n_splits=5, n_repeats=3, random_state=1)
    
    #unclear how the parker code partitions the dataset? 'cv' 5.
    #guessing matlab cv 5= 5 partitions (folds) with 5 rounds http://mccormickml.com/2013/08/01/k-fold-cross-validation-with-matlab-code/
    cv = RepeatedKFold(n_repeats=5, random_state=1)

    
    #define model
    model = LassoCV(alphas=np.arange(0, 1, 0.01), cv=cv, n_jobs=-1)
    
    #fit model
    #Time: profiler said this took ~24min for one group
    model.fit(group.loc[:,X], group.loc[:,y])
    
    #display lambda that produced the lowest test MSE
    print(model.alpha_)
    
    
    #skitlearn mainly used for machine learning, For a more classic statistical approach, take a look at statsmodels:
    #--statsmodels
    #caveat i think is statsmodels won't directly implement cross validation
    
    #endogenous= response/dependent variable, exogenous= regressors/predictors
    model2= sm.OLS()
    
    testModel= sm.OLS(group.loc[:,y], group.loc[:,X])
    
    #L1_wt=1 for LASSO 
    fit= testModel.fit_regularized(L1_wt=1)

    print(fit.summary())
    
    #create wrapper so that we can use sklearn cross validation on statsmodels model
    #https://stackoverflow.com/questions/41045752/using-statsmodel-estimations-with-scikit-learn-cross-validation-is-it-possible/48949667

    
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

        
        
            
    # #Plot
    # # sns.FacetGrid(eventCol,1)
    # # sns.relplot(data= kernels.iloc[:,eventCol], kind='line')
    # g=sns.relplot(data=kernels, x='timeShift', y='beta', hue='eventType', kind='line')
    # g.set(title=('subj-'+str(subj)+'-kernels-'+modeCue+'-trials-'+modeSignal))
    # g.set_ylabels('beta coef.')
    # g.set_xlabels('timeShift from event onset (s)')
    
    # # place a text box in upper left in axes coords with more model info
    # # these are matplotlib.patch.Patch properties
    # props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
    # textstr= 'alpha with lowest MSE='+str(model.alpha_)
    # g.ax.text(0.05, 0.95, textstr, transform=g.ax.transAxes, fontsize=14, verticalalignment='top', bbox=props)
    # textstr= 'intercept='+str(model.intercept_)
    # g.ax.text(0.05, 0.90, textstr, transform=g.ax.transAxes, fontsize=14, verticalalignment='top', bbox=props)
    
    #%% TODO: plot of predicted vs actual FP signal in addition to kernels
    #prediction? maybe use actual timeshift=0 values?
    #need equal number of columns so probably a different session or trial subset
    predicted= model.predict(group.loc[:,X])
    
    # dfTemp.loc[group.index,'predicted']= model.predict(group.loc[:,X])
    
    # g= sns.relplot(data=dfTemp.loc[group.index,:],y=predicted, x='timeLock-z-periDS', kind='line', color='blue')
    # sns.lineplot(ax=g.ax, data=dfTemp.loc[group.index,:], x='timeLock-z-periDS', y=y, color='black')
    # g.ax.legend(['predicted','actual'])
    # g.set(title=('subj-'+str(subj)+'-modelPrediction-'+modeCue+'-trials-'+modeSignal))
    # g.set_ylabels('Z-score FP signal')
    # g.set_xlabels('time from cue onset')

    # #error here bc single columns i think:
    # # #get actual event timings (shift+0) since string starts with + need to 'escape' with r\
    # # col= group.columns.str.contains(r'\+0')
    # # group['predicted']= model.predict(group.loc[:,col])
    
    #COMBINE above into single Figure, save

    f, ax = plt.subplots(2, 1)
    
    g= sns.lineplot(ax=ax[0,], data=kernels, x='timeShift',y='beta',hue='eventType')
    g.set(title=('subj-'+str(subj)+'-kernels-'+modeCue+'-trials-'+modeSignal))
    g.set(xlabel='timeShift from event onset (s)', ylabel='beta coef.')
    # place a text box in bottom left in axes coords with more model info
    # these are matplotlib.patch.Patch properties
    props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
    textstr= 'alpha with lowest MSE='+str(model.alpha_)+'(0=no penalty, OLS)'
    g.text(0.05, .1, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
    textstr= 'intercept='+str(model.intercept_)
    g.text(0.05, 0.2, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)
    textstr= 'R2='+str(model.score(group.loc[:,X],group.loc[:,y], sample_weight=None))
    g.text(0.05, 0.3, textstr, transform=g.transAxes, fontsize=14, verticalalignment='top', bbox=props)


    g= sns.lineplot(ax=ax[1,],data=dfTemp.loc[group.index,:],y=predicted, x='timeLock-z-periDS', color='blue')
    g= sns.lineplot(ax=ax[1,], data=dfTemp.loc[group.index,:], x='timeLock-z-periDS', y=y, color='black')
    g.legend(['predicted??','actual'])
    g.set(title=('subj-'+str(subj)+'-periCueModelPrediction-'+modeCue+'-trials-'+modeSignal))
    g.set(xlabel='time from cue onset', ylabel='Z-score FP signal')
    
    saveFigCustom(f, 'subj-'+str(subj)+'-regressionOutput-'+modeCue+'-trials-'+modeSignal)
    
    
    #%% TODO: should apply kernels on trial-by-trial basis like in matlab code after calculating? or maybe the model prediction accomplishes fine
    
    #%% TODO: getting regression convergence warning
    # ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 408597.86992538127, tolerance: 101.5919394459587
    
    #%% validation?
#     # mse_path_ndarray of shape (n_alphas, n_folds)
#     # Mean square error for the test set on each fold, varying alpha
#     for i in range(0,model_mse_path_.shape)
#     g= sns.lineplot(y=model.mse_path_, x=model.alphas)
    
    
# #     Return the coefficient of determination, R2, of the prediction.
#     model.score(group.loc[:,X],group.loc[:,y], sample_weight=None)

#%% TODO: 
#check this out
# https://scikit-learn.org/stable/auto_examples/linear_model/plot_lasso_lars_ic.html#sphx-glr-auto-examples-linear-model-plot-lasso-lars-ic-py
# https://scikit-learn.org/stable/auto_examples/linear_model/plot_lasso_model_selection.html#sphx-glr-auto-examples-linear-model-plot-lasso-model-selection-py




#%% 

#Establish hierarchical grouping for analysis
#want to be able to aggregate data appropriately for similar conditions, so make sure group operations are done correctly
groupers= ['subject', 'trainDayThisStage', 'fileID']