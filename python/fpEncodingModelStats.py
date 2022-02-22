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
from sklearn.model_selection import cross_val_score

import statsmodels.api as sm
import statsmodels.formula.api as smf


from customFunctions import saveFigCustom

from plot_lasso_model_selection import plot_lasso_model_selection

#%% PREPARING INPUT FOR PARKER ENCODING MODEL
# want - 
# x_basic= 148829 x 1803... # timestamps entire session x (# time shifts in peri-Trial window * num events). binary coded
# gcamp_y = 148829 x 1 ; entire session signal predicted by regression . z scored photometry signal currently nan during ITI & only valid values during peri-DS

    
    
#%% Plot settings
sns.set_style("darkgrid")
sns.set_context('notebook')

savePath= r'./_output/fpEncodingModelStats/'

    
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
# --shouldn't happen now since fill_values=0
# dfTemp= dfTemp.loc[~dfTemp.isin([np.nan, np.inf, -np.inf]).any(1),:]
    
#define predictor and response variables:
    
#will save X and y as index instead of copying data to save mem
    
#regressors/predictors will be all remaining columns that are not idVars or contVars
# col= ~dfTemp.columns.isin(idVars+contVars+['trainDayThisStage','trialID','timeLock-z-periDS','timeLock-z-periNS'])

#regressand/response variable is fp signal
y= 'reblue-z-periDS'


# Remove invalid observations (nan, inf) in these columns
# shouldn't be any. at this point not sure where they come from?
# dfTemp= dfTemp.loc[~dfTemp.loc[:,col].isin([np.nan, np.inf, -np.inf]).any(1),:]


subjects= dfTemp.subject.unique()

#run only specific subjects
# subjects= [14,15,17,19]

for subj in subjects:
    group= dfTemp.loc[dfTemp.subject==subj]
       
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
    

    #define which eventTypes to include!
    eventsToInclude= ['DStime','NStime','UStime','PEtime','lickTime','lickUS']
    # dfTemp.loc[~dfTemp.eventType.isin(eventsToInclude),'eventType']= pd.NA
    
    #only keep cols that match events
    #col will be used as boolean index for columns, start False then switch to True if event is in name
    #regressors/predictors will be all remaining columns
    col= np.array(range(len(group.columns)), dtype= bool)
    col[:]= False
    
    for eventCol in range(len(eventsToInclude)):
        indEvent= group.columns.str.contains(eventsToInclude[eventCol])
        
        col[indEvent]= True

    
    #use index instead of copying data (save memory)
    X= col
    
    #TODO: Make sure variables are correct (e.g. i think timeLock is included with this definition)
    
    # #examining input data
    # np.any(np.isnan(X))
    # np.all(np.isfinite(X))
    
    
    #regressand/response variable is fp signal
    # y = group["reblue"]
    y= 'reblue-z-periDS'
    
    
    #TODO: #withhold some data for Testing model?

    
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
    #testing range of alphas between 0=OLS, elastic net, and 1=lasso? 
    # 'alpha' = 'lambda' ?
    #-manually define alphas- gives convergence warning
    # alphas=np.arange(0, 1, 0.01)
    # model = LassoCV(alphas=alphas, cv=cv, n_jobs=-1)
    #-automatically define alphas
    # auto selection of alphas doesn't give convergence warning?
    #did get convergence warning with more predictors: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 2.8917507487130933, tolerance: 2.4854334923226147
    # model = LassoCV(cv=cv, n_jobs=-1)
    
    #try with more iterations or greater tol? (for convergencewarning)
    model = LassoCV(cv=cv, n_jobs=-1, max_iter=20000)

# https://stats.stackexchange.com/questions/445831/how-is-tol-used-in-scikit-learns-lasso-and-elasticnethttps://stats.stackexchange.com/questions/445831/how-is-tol-used-in-scikit-learns-lasso-and-elasticnet

    
    #fit model
    #Time: profiler said this took ~24min for one group with range of alphas
    model.fit(group.loc[:,X], group.loc[:,y])
    
    #display alpha that produced the lowest test MSE
    print('best alpha model='+str(model.alpha_))
    
        
    #TODO: Feature selection /test specific combos of eventTypes
    #starting with 'full model' of all eventTypes, pare down successively based on criteria e.g. forward/backward selection:
#Backward elimination begins with the model having the largest number of predictors and eliminates variables one-by-one until we are satisfied that all remaining variables are important to the model. Forward selection starts with no variables included in the model, then it adds in variables according to their importance until no other important variables are found. Notice that, for both methods, we have always chosen to retain the model with the largest adjusted R2
# It is highly advised that before you begin the model selection process, you decide what a “meaningful” difference in adjusted R2 is for the context of your data. Maybe this difference is 1% or maybe it is 5%. This “threshold” is what you will then use to decide if one model is “better” than another model. 
        # https://scikit-learn.org/stable/modules/feature_selection.html -- fxns here could be used
    
    # from sklearn.feature_selection import SelectFromModel

    # model2= SelectFromModel(model)
    
    #Seems LassoCV is using ~coordinate descent~ as the criteria to select the optimal alpha 
    #(minimizes mean MSE across all CV folds) https://scikit-learn.org/stable/auto_examples/linear_model/plot_lasso_model_selection.html#sphx-glr-auto-examples-linear-model-plot-lasso-model-selection-py
    
    #I think lassoCV is probably appropriate - 'for high dimensional datasets with many colinear features'. event timestamps will be colinear
    #also consider- LassoLarsCV has the advantage of exploring more relevant values of alpha parameter, and if the number of samples is very small compared to the number of features, it is often faster than LassoCV.
    #and- the estimator LassoLarsIC proposes to use the Akaike information criterion (AIC) and the Bayes Information criterion (BIC).
    
    #wondering now how to assess model, recover MSE
    #Model.MSE_path_? 25 col like matlab but 100 rows. Plotting
    msePath= pd.DataFrame(model.mse_path_)
    msePath= msePath.reset_index().melt(id_vars= 'index', value_vars=msePath.columns, var_name='cvIteration', value_name='MSE')
    msePath= msePath.rename(columns={"index": "alphaCount"})
    
    msePath['alpha']= np.nan
    
    msePath['alpha']= model.alphas_[msePath.alphaCount]
    
    # fig, ax = plt.subplots()
    # sns.scatterplot(ax=ax, data=msePath, x='alpha', y='MSE', hue='cvIteration', palette='Blues')
    # sns.lineplot(ax=ax, data=msePath, x='alpha', y='MSE', color='black')
    
    # ax.set_xlabel('alpha')
    # ax.set_ylabel('MSE')
    # ax.set_title('MSE across CV folds')
   
    # #Show coefficients as fxn of alpha regularization
    #hitting error
    # from sklearn.linear_model import Lasso
    # alphas = alphas#np.linspace(0.01,500,100)
    
    # lasso = Lasso(max_iter=100)
    # coefs = []
    # X_train= group.loc[:,X]
    # y_train= group.loc[:,y]
    # for a in alphas:
    #     lasso.set_params(alpha=a)
    #     lasso.fit(X_train, y_train)
    #     coefs.append(lasso.coef_)
    
    #     ax = plt.gca()
        
    #     ax.plot(alphas, coefs)
    #     ax.set_xscale('log')
    #     plt.axis('tight')
    #     plt.xlabel('alpha')
    #     plt.ylabel('Standardized Coefficients')
    #     plt.title('Lasso coefficients as a function of alpha');
    
    #try function
    # plot_lasso_path_crossval()
    
    # #-- visualize regularization: lasso path
    # eps = 1e-2 # the smaller it is the longer is the path
    # # models = lasso_path(boston.data, boston.target, eps=eps)
    # #Running LassoCV gives optimal output but want to see full path?
    # modelFit= model.fit(group.loc[:,X], group.loc[:,y])
    # modelsFit= modelFit.path(group.loc[:,X],group.loc[:,y])
    
    #model.path() returns tuple...not consistent with documentation
    #but seems that [0]= alphas, [1]=coefs, [2]=dualgaps ?
    #saving these into df
    # models= model.path(group.loc[:,X],group.loc[:,y])

    # pathAlphas, pathCoefs, pathDualGaps = model.path(group.loc[:,X],group.loc[:,y], alphas=alphas)
    
    #doesn't seem to be giving the full path across all cv's just a mean I guess?
    #these two give identical results:
    pathAlphas, pathCoefs, pathDualGaps = model.path(group.loc[:,X],group.loc[:,y])
    # pathAlphas, pathCoefs, pathDualGaps= model.path(group.loc[:,X],group.loc[:,y], cv=cv)
    
    #???? Why are alphas in this 'path' so different than the model.alphas?
    #try manually choosing same as model alphas. #convergencewarning
    #this basically makes everything zero except very small alpha. maybe a sign to look specifically at smaller alphas?
    # pathAlphas, pathCoefs, pathDualGaps = model.path(group.loc[:,X],group.loc[:,y], alphas= model.alphas_)

    
    #initialize df to store path
    modelPath= pd.DataFrame()
    modelPath['alpha']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
    modelPath['coef']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
    modelPath['dualGap']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
    modelPath['modelCount']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
    modelPath['predictor']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
    modelPath['eventType']= np.empty(pathCoefs.shape[1]*(pathCoefs.shape[0]))
    modelPath[:]= np.nan
    
   
    #fill df with data from each iteration along the path
    ind= np.arange(0,(pathCoefs.shape[0]))
    for thisModel in range(0,len(pathAlphas)):
    
        pathAlphas_lasso = np.empty(pathCoefs.shape[0]) #repeat array so each coef has corresponding alpha
        pathAlphas_lasso[:]= pathAlphas[thisModel]
    
        pathDualGaps_lasso = np.empty(pathCoefs.shape[0]) #repeat array so each coef has corresponding alpha
        pathDualGaps_lasso[:]= pathDualGaps[thisModel]
        
        modelCount_lasso = np.empty(pathCoefs.shape[0]) #repeat array so each coef has corresponding alpha
        modelCount_lasso[:]= thisModel
        
        predictor_lasso= group.columns[X] #np.arange(0,len(pathCoefs[:,thisModel]))
        
    
        pathCoefs_lasso= pathCoefs[:,thisModel]
        

        modelPath.loc[ind,'alpha']= pathAlphas_lasso
        modelPath.loc[ind,'coef']= pathCoefs_lasso
        modelPath.loc[ind,'dualGap']= pathDualGaps_lasso
        modelPath.loc[ind, 'modelCount']= modelCount_lasso
        modelPath.loc[ind, 'predictor']= predictor_lasso
        
        #go through more specifically and label eventType of each predictor
        eventType_lasso= np.empty(pathCoefs.shape[0])
        eventType_lasso= pd.Series(eventType_lasso)#,index=predictor_lasso)


        for eventCol in range(len(eventVars)):
            indEvent= group.columns[X].str.contains(eventVars[eventCol])

            eventType_lasso[indEvent]= eventVars[eventCol]

            #assigning .values since i made this a series and index doesn't align
        modelPath.loc[ind, 'eventType']= eventType_lasso.values

        ind= ind+(pathCoefs.shape[0])

         

    #   # viz path
    # fig, ax = plt.subplots()
    # sns.lineplot(ax= ax, data=modelPath, x='alpha', y='coef', hue='eventType')
    # ax.set_title('regularization path: coefficients for each alpha')
    # ax.set_xlabel('alpha')
    
    # fig, ax = plt.subplots()
    # sns.lineplot(ax= ax, data=modelPath, x='alpha', y='coef', hue='eventType')
    # ax.set_title('regularization path: coefficients for each log alpha')
    # ax.set_xscale('log')
    # ax.set_xlabel('log alpha')
    
    
    # fig, ax = plt.subplots()
    # sns.lineplot(ax= ax, data=modelPath, estimator=None, units='predictor', x='alpha', y='coef', hue='eventType')
    # ax.set_title('regularization path: coefficients for each alpha')
    # ax.set_xlabel('alpha')

    # fig, ax = plt.subplots()
    # sns.lineplot(ax= ax, data=modelPath, estimator=None, units='predictor', x='alpha', y='coef', hue='eventType')
    # ax.set_title('regularization path: coefficients for each log alpha')
    # ax.set_xscale('log')
    # ax.set_xlabel('log alpha')


    #COMBINE above into single figure for model validation
    #MSE path + coefficient path
    f, ax = plt.subplots(2,1)
    
    #mse
    g=sns.scatterplot(ax=ax[0], data=msePath, x='alpha', y='MSE', hue='cvIteration', palette='Blues')
    g=sns.lineplot(ax=ax[0], data=msePath, x='alpha', y='MSE', color='black')
    plt.axvline(model.alpha_, color='black', linestyle="--", linewidth=3, alpha=0.5)
    ax[0].set_xscale('log')
    ax[0].set_xlabel('log alpha')
    
    
    g.set_xlabel('alpha')
    g.set_ylabel('MSE')
    g.set(title=('subj-'+str(subj)+'-LASSO MSE across CV folds-'+modeCue+'-trials-'+modeSignal))
    g.set(xlabel='alpha', ylabel='MSE')
    
    #coef path
    g=sns.lineplot(ax= ax[1], data=modelPath, estimator=None, units='predictor', x='alpha', y='coef', hue='eventType', alpha=0.05)
    g=sns.lineplot(ax= ax[1], data=modelPath,  x='alpha', y='coef', hue='eventType', palette='dark')
    plt.axvline(model.alpha_, color='black', linestyle="--", linewidth=3, alpha=0.5)
    ax[1].set_xscale('log')
    ax[1].set_xlabel('log alpha')
    
    g.set(title=('subj-'+str(subj)+'-LASSO Coef. Path-'+modeCue+'-trials-'+modeSignal))
    g.set(ylabel='coef')
    # ax.set_xscale('log') #log scale if wanted
    
    saveFigCustom(f, 'subj-'+str(subj)+'-lassoValidation-'+modeCue+'-trials-'+modeSignal, savePath)

  
    
    #--COMPARE regularization methods: AIC/BIC vs CV-coordinate descent vs CV-LARS
    modelName= 'subj-'+str(subj)+'-'+modeCue+'-trials-'+modeSignal
    
    plot_lasso_model_selection(group.loc[:,X].copy(), group.loc[:,y].copy(), cv, modelName, r'./_output/fpEncodingModelStats/regularizationComparison/')
    
    
    #TODO: https://scikit-learn.org/stable/auto_examples/exercises/plot_cv_diabetes.html
    
    #matlab gives stats.fitInfo.MSE: 1 val per each 100 iterations (lambda reg coefs)
    #finds the betas corresponding to lambda with lowest MSE
    # plus additional step ? to prevent all zero betas. 
    #Seems that if betas are all zero changes indexMinMSE to the *latest* iteration with nonzero betas
    #  sum_betas=max(stats.beta(:,stats.p.IndexMinMSE));    %Selects betas that minimize MSE
    # if sum_betas==0; stats.p.IndexMinMSE=max(find(max(stats.beta)>0.0001)); end  %Makes sure there are no all zero betas
    # b=[stats.p.Intercept(stats.p.IndexMinMSE) ; stats.beta(:,stats.p.IndexMinMSE)];  %selects betas based on lambda
    
    # #cv score (R2?) -- surprisingly slow
    # score can be changed to ROC AUC-- https://scikit-learn.org/stable/modules/model_evaluation.html#scoring-parameter
    # scores= cross_val_score(model, group.loc[:,X], group.loc[:,y], cv=cv)
    # print("%0.2f accuracy with a standard deviation of %0.2f" % (scores.mean(), scores.std()))
    #result is 25 values-maybe 1 per fold per split (5x5)?
    
    
    # #skitlearn mainly used for machine learning, For a more classic statistical approach, take a look at statsmodels:
    # #--statsmodels
    # #caveat i think is statsmodels won't directly implement cross validation
    
    # #endogenous= response/dependent variable, exogenous= regressors/predictors
    # model2= sm.OLS()
    
    # testModel= sm.OLS(group.loc[:,y], group.loc[:,X])
    
    # #L1_wt=1 for LASSO %Very slow
    # fit= testModel.fit_regularized(L1_wt=1)

    # # print(fit.summary()) #not implemented?
    # # https://github.com/statsmodels/statsmodels/issues/7937
    
    # #create wrapper so that we can use sklearn cross validation on statsmodels model
    # #https://stackoverflow.com/questions/41045752/using-statsmodel-estimations-with-scikit-learn-cross-validation-is-it-possible/48949667

    
    #save model output?
    # savePath= r'./_output/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

    print('saving model to file')
    
    #Save as pickel
    pd.to_pickle(model, (savePath+'subj'+str(subj)+'regressionModel.pkl'))
        


    #%-- Visualize kernels
    
    #coefficients: 1 col for each shifted version of event timestamps in the range of timeShifts. events ordered sequentially
     
    #alt method of lining up coef with feature names:
        # for eventCol in range(len(eventVars)):
        #     indEvent= group.columns[X].str.contains(eventVars[eventCol])

        #     eventType_lasso[indEvent]= eventVars[eventCol]
    
    b= model.coef_

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
        
        kernels.loc[indEvent,'eventType']= eventVars[eventCol]
        kernels.loc[indEvent, 'timeShift']= np.arange(-preEventTime,postEventTime)/fs
            
    
    # for eventCol in range(len(eventVars)):
    #     if eventCol==0:
    #         ind= np.arange(0,(eventCol+1)*len(np.arange(-preEventTime,postEventTime)))
    #     else:
    #         ind= np.arange((eventCol)*len(np.arange(-preEventTime,postEventTime)),((eventCol+1)*len(np.arange(-preEventTime,postEventTime)-1)))
       
    #     # kernels[(eventVars[eventCol]+'-coef')]= b[ind]
    #     kernels.loc[ind,'beta']= b[ind]
    #     kernels.loc[ind,'eventType']= eventVars[eventCol]
    #     kernels.loc[ind, 'timeShift']= np.arange(-preEventTime,postEventTime)/fs
    #     # kernels.loc[ind,'betaStatsModels']= fit.params[ind].values
        
        
    # #compare scikitlearn vs statsmodels output
    # f, ax = plt.subplots(2, 1)
    # g= sns.lineplot(ax=ax[0,], data=kernels, x='timeShift',y='beta',hue='eventType')
    # g.set(title=('subj-'+str(subj)+'-kernels-'+modeCue+'-trials-'+modeSignal))
    # g.set(xlabel='timeShift from event onset (s)', ylabel='beta coef. statsModels')
    # g= sns.lineplot(ax=ax[1,], data=kernels, x='timeShift',y='betaStatsModels',hue='eventType')
    # g.set(title=('subj-'+str(subj)+'-StatsModels-kernels-'+modeCue+'-trials-'+modeSignal))


        
        
            
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


    g= sns.lineplot(ax=ax[1,],data=dfTemp.loc[group.index,:], x='timeLock-z-periDS', y=predicted, color='black')
    g= sns.lineplot(ax=ax[1,], data=dfTemp.loc[group.index,:], x='timeLock-z-periDS', y=y, color='blue')
    g.legend(['predicted??','actual'])
    g.set(title=('subj-'+str(subj)+'-periCueModelPrediction-'+modeCue+'-trials-'+modeSignal))
    g.set(xlabel='time from cue onset', ylabel='Z-score FP signal')
    
    saveFigCustom(f, 'subj-'+str(subj)+'-regressionOutput-'+modeCue+'-trials-'+modeSignal, savePath)
    
    
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