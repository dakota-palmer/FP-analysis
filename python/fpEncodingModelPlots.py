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


    
#%% Plot settings
sns.set_style("darkgrid")
sns.set_context('notebook')

savePath= r'./_output/fpEncodingModelPlots/'

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


dfEncoding= np.empty(np.shape(files))
dfEncoding= pd.DataFrame(dfEncoding) 


for file in range(len(files)):
    dfTemp= pd.read_pickle(dataPath+files[file])
    
    dfEncoding.loc[file,'file']= files[file]
    dfEncoding.loc[file,'model']= dfTemp['model_lasso']
    dfEncoding.loc[file,'subject']= dfTemp.subject
    dfEncoding.loc[file,'modelName']= dfTemp.modelName
    dfEncoding.loc[file,'modelStage']= dfTemp.modelStage
    dfEncoding.loc[file,'nSessions']= dfTemp.nSessions
    

    


#%% Load model output
dataPath= r'./_output/fpEncodingModelStats/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

# dfTemp= pd.read_pickle(r"C:\Users\Dakota\Documents\GitHub\FP-analysis\python\_output\fpEncodingModelStats\subj13.0regressionModel.pkl")


#load variables previously saved (shelf)
my_shelf = shelve.open(r"C:\Users\Dakota\Documents\GitHub\FP-analysis\python\_output\fpEncodingModelStats\subj13.0regressionModel.pkl")
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()
#%% Load regression input.pkl
dataPath= r'./_output/fpEncodingModelPrep/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

if modeCue=='DS':
    dfTemp= pd.read_pickle(dataPath+'dfRegressionInputDSonly.pkl')
elif modeCue=='NS':
    dfTemp= pd.read_pickle(dataPath+'dfRegressionInputNSonly.pkl')


#load any other variables saved during the import process ('dfTidymeta' shelf)
#load variables previously saved (shelf)
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% 