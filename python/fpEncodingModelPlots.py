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

    
#%% Plot settings
sns.set_style("darkgrid")
sns.set_context('notebook')

savePath= r'./_output/fpEncodingModelStats/'

    

#%% Load model output

#%% Load regression input.pkl
dataPath= r'./_output/fpEncodingModelPrep/' #r'C:\Users\Dakota\Documents\GitHub\DS-Training\Python' 

if modeCue=='DS':
    dfTemp= pd.read_pickle(dataPath+'dfRegressionInputDSonly.pkl')
elif modeCue=='NS':
    dfTemp= pd.read_pickle(dataPath+'dfRegressionInputNSonly.pkl')


#load any other variables saved during the import process ('dfTidymeta' shelf)
my_shelf = shelve.open(dataPath+'dfRegressionInputMeta')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()


#%% 