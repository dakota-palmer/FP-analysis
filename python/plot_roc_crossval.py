# -*- coding: utf-8 -*-
"""
Created on Mon Feb 14 13:34:17 2022

@author: Dakota
"""

#adapted from https://scikit-learn.org/stable/auto_examples/model_selection/plot_roc_crossval.html#sphx-glr-auto-examples-model-selection-plot-roc-crossval-py

#%% load dependencies
import numpy as np
import matplotlib.pyplot as plt

from sklearn import svm, datasets
from sklearn.metrics import auc
from sklearn.metrics import RocCurveDisplay
from sklearn.model_selection import StratifiedKFold

# #############################################################################
# #%% Data IO and generation

# # Import some data to play with
# iris = datasets.load_iris()
# X = iris.data
# y = iris.target
# X, y = X[y != 2], y[y != 2]
# n_samples, n_features = X.shape

# # Add noisy features
# random_state = np.random.RandomState(0)
# X = np.c_[X, random_state.randn(n_samples, 200 * n_features)]

# # #############################################################################
# # Classification and ROC analysis

# # Run classifier with cross-validation and plot ROC curves
# # cv = StratifiedKFold(n_splits=6)
# # classifier = svm.SVC(kernel="linear", probability=True, random_state=random_state)

#%% dakota
cv=cv
classifier= model
# 
#got error with regular lasso, ValueError: For multi-task outputs, use MultiTaskLassoCV
# from sklearn.linear_model import MultiTaskLassoCV

# classifier= MultiTaskLassoCV(cv=cv, n_jobs=-1, max_iter=20000)

Xx= group.loc[:,X].copy()
yY= group.loc[:,y].copy()

#reset index for the train,test enumeration loop below
# Xx= Xx.reset_index(drop=True)
# yY= yY.reset_index(drop=True)

#convert sparse to dense
# Xx= Xx.sparse.to_dense()

tprs = []
aucs = []
mean_fpr = np.linspace(0, 1, 100)

fig, ax = plt.subplots()
for i, (train, test) in enumerate(cv.split(Xx, yY)): #for each cv split- (for 5 fold 5 split this would count 0-24)
    classifier.fit(Xx.iloc[train], yY.iloc[train]) #use iloc bc enumeration here doesn't match original index
   
   #I think this only works for binary/categorically labelled data 
   
    ## first method here fails, wants classifier instead of LASSO
    # viz = RocCurveDisplay.from_estimator(
    #     classifier,
    #     Xx.iloc[test],
    #     yY.iloc[test],
    #     name="ROC fold {}".format(i),
    #     alpha=0.3,
    #     lw=1,
    #     ax=ax,
    # )
    
    # ## second method here fails, wants binary output y instead of continuous float?
    # viz = RocCurveDisplay.from_predictions(
    #     yY.iloc[test],
    #     classifier.predict(Xx.iloc[test]),
    #     name="ROC fold {}".format(i),
    #     alpha=0.3,
    #     lw=1,
    #     ax=ax,
    # )
    
    # ## third method-- again wants binary metrics? 
    # from sklearn import metrics
    
    # fpr, tpr, thresholds = metrics.roc_curve(yY.iloc[test], scores, pos_label=2)
    
    
    interp_tpr = np.interp(mean_fpr, viz.fpr, viz.tpr)
    interp_tpr[0] = 0.0
    tprs.append(interp_tpr)
    aucs.append(viz.roc_auc)
    

ax.plot([0, 1], [0, 1], linestyle="--", lw=2, color="r", label="Chance", alpha=0.8)

mean_tpr = np.mean(tprs, axis=0)
mean_tpr[-1] = 1.0
mean_auc = auc(mean_fpr, mean_tpr)
std_auc = np.std(aucs)
ax.plot(
    mean_fpr,
    mean_tpr,
    color="b",
    label=r"Mean ROC (AUC = %0.2f $\pm$ %0.2f)" % (mean_auc, std_auc),
    lw=2,
    alpha=0.8,
)

std_tpr = np.std(tprs, axis=0)
tprs_upper = np.minimum(mean_tpr + std_tpr, 1)
tprs_lower = np.maximum(mean_tpr - std_tpr, 0)
ax.fill_between(
    mean_fpr,
    tprs_lower,
    tprs_upper,
    color="grey",
    alpha=0.2,
    label=r"$\pm$ 1 std. dev.",
)

ax.set(
    xlim=[-0.05, 1.05],
    ylim=[-0.05, 1.05],
    title="Receiver operating characteristic example",
)
ax.legend(loc="lower right")
plt.show()