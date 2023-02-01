# -*- coding: utf-8 -*-
"""
Created on Mon Jan 23 15:25:03 2023

@author: Dakota
"""

#%% dependencies
import glob

# from datetime import date
import datetime

import os

import shutil

import pandas as pd

#%% 
# in medpc, sometimes files from multiple dates are appended into a single file.
# after running find and split duplicates, the original date is retained in filename
# this script aims to replace the incorrect date with the actual file contents

#%% TODOs:
    
#%% Define paths and string to use for splitting
#path to the .txt datafiles saved by MedPC
# dataPathInput= r'C:/Users/Dakota/Desktop/_christelle_opto_mpc-data/'

# dataPathInput= r'C:/Users/Dakota/Desktop/_christelle_opto_mpc-data/_test/'

# root directory where this script is
dataPathRoot= os.getcwd()

# folder containing input .txt files
dataPathInput= r'F:\_Github\Richard Lab\data-vp-opto\_MPC_data\_MPC_data_Corrected\_flagged\_split_files\_files_ok_date_title_wrong/'

# output folder, here new folder to save renamed output files
dataPathOutput= r'F:\_Github\Richard Lab\data-vp-opto\_MPC_data\_MPC_data_Corrected\_flagged\_split_files\_files_ok_date_title_wrong\_renamed'

# separate folder to move flagged OG files 
# dataPathQuarantine= dataPathRoot+'/_find_and_split_duplicates/_output/_flagged_file_quarantine/'

# dataPathQuarantine= os.path.abspath(dataPathQuarantine)


# dataPathQuarantine= os.path.abspath(os.path.dirname(dataPathQuarantine))

#% Define string to search/split

#for filenames to match format, want start date, time, and subject
splitStr= 'Subject:'
splitStr2= 'Start Date:'
splitStr3= 'Start Time:'

#%% Get list of all .txt files in dataPathInput

# os.chdir(dataPathInput)

#selecting specifically SplitFiles
allFiles= glob.glob(dataPathInput+"*SplitFile*.txt")

#%% Read data file as string, find splitStr and split 
for thisFile in allFiles:
    
    content= open(thisFile).read()
    
    # if splitStr in content:
    #     print('str exists')
    
    
    
    #count # of string occurrences in file
    n= content.count(splitStr)

    #normally a file should have 1 splitStr, if >0 (python counts starting with 0) warn user
    if n>1:
        print('!~~~~~~ duplicate subject found--'+ thisFile+ '~~~~~~~~!')


    #split the raw data file into lines and get the line where "MSN:" is present
    content= content.splitlines()
    
    for line in content:
        if splitStr in line:
            thisSubj= line.split(splitStr)[1]
        
        if splitStr2 in line:
            thisStartDate= line.split(splitStr2)[1]
            
        if splitStr3 in line:
            thisStartTime= line.split(splitStr3)[1]
            break #stop reading once all are found (assume Start Time is last in file)
    
    # for some reason medpc data files save date and time differently from their filename formatting...
    # so convert datetime
    # strip spaces before conversion
    thisStartDate= thisStartDate.strip()
    thisStartTime=thisStartTime.strip()
    
    #combine date and time for one step conversion
    thisStartDateTime=[]
    thisStartDateTimeReformat= []
    thisStartDateTime= thisStartDate+' '+thisStartTime
    
    
    thisStartDateTime= pd.to_datetime(thisStartDateTime, format= '%m/%d/%y %H:%M:%S')

    thisStartDateTime= pd.Series(thisStartDateTime)
    
    thisStartDateTimeReformat= thisStartDateTime.dt.strftime('%Y-%m-%d_%Hh-%Mm')


    
    #make filename matching format of other data files
    thisSubj= thisSubj.strip()
    
    fileNameNew= thisStartDateTimeReformat+'_Subject '+thisSubj
    
    fileNameNew= fileNameNew+'_corrected_name'+'.txt'
 
    # use os.path.basename to isolate file name from rest of path
    # fileNew= os.path.basename(thisFile) + strFlagFilename + '.txt'
    
    

    #--save new renamed files into output folder
    os.chdir(dataPathOutput)
    
    fileNew= os.path.join(dataPathOutput, fileNameNew[0])
    
    with open(fileNew, 'w') as f:
        
        f.write(open(thisFile).read())

    #return to working dir
    os.chdir(dataPathRoot)