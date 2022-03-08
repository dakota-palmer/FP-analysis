# On Windows all of your multiprocessing-using code must be guarded by if __name__ == "__main__":

# So to be safe, I would put all of your the code currently at the top-level of your script in a main() function, and then just do this at the top-level:

# if __name__ == "__main__":
#     main()

if __name__ == '__main__':

    # -*- coding: utf-8 -*-
    """
    Created on Thu Jun 17 10:03:30 2021

    @author: Dakota
    """

    import numpy as np
    import scipy.io as sio
    import pandas as pd

#Trying import of subjDataAnalyzed struct from matlab

#%% define a function to open file with gui
    def openFile():
        global matContents #global var so we can access later
        filepath = filedialog.askopenfilename(initialdir=r'C:\Users\Dakota\Desktop\Opto DS Task Test- CUE Laser Manipulation',
                                           title="open trainData.mat",
                                           filetypes= (("mat files","*.mat"),
                                           ("all files","*.*")))
        print(filepath)
        #load the mat file contents
        # setting squeeze_me argument=true, otherwise each element seems to get nested in individual arrays
        # matContents= sio.loadmat(r'Z:\Dakota\MEDPC\Downstairs\vp-vta-stgtacr_DStrain\Opto DS Task Test- CUE Laser Manipulation\trainData.mat',squeeze_me=True)
        matContents= sio.loadmat(filepath,squeeze_me=True)
        window.destroy()
     
 
    #%% import matlab struct from .mat
    from tkinter import *
    from tkinter import filedialog
    
# #use GUI
    window = Tk()
    button = Button(text="Open",command=openFile) #openFile() function
    button.pack()
    window.mainloop()


    #%% import matlab struct manually
    
    # matContents= sio.loadmat(r'C:\Users\Dakota\Desktop\Opto DS Task Test- CUE Laser Manipulation\trainData.mat',squeeze_me=True)
   #licklaser
    # matContents= sio.loadmat(r'C:\Users\Dakota\Desktop\Opto DS Task Test- CUE Laser Manipulation\2021-07-07-16-24-31trainData.mat',squeeze_me=True)
    # matContents= sio.loadmat(r'C:\Users\Dakota\Desktop\Opto DS Task Test- CUE Laser Manipulation\laserDay\2021-07-08-12-47-22trainData.mat',squeeze_me=True)

    # %% Extract the relevant data and get the data into pandas.dataframe format
    # adapted from https://www.kaggle.com/avilesmarcel/open-mat-in-python-pandas-dataframe

    # extract the struct contents from the loaded .mat
    mdata = matContents['trainData']

    mtype = mdata.dtype  # 1 'type' of data corresponding to each column

    # now it looks like we are creating a dict matching up data (in np.arrays) from mdata with column names
    ndata = {n: mdata[n] for n in mtype.names}

    data_headline = []  # will hold list of var labels for columns
    data_raw = []  # will hold the raw data for each column
    # since our struct contains multiple data types/classes, make this np array of object type
    data_raw = np.empty([mdata.shape[0], len(mtype.names)], dtype=object)

    # now simply loop through each variable type and get the corresponding data. Probably a better way to do this
    for var in range(len(mtype.names)):

        data_headline.append([mtype.names[var]][0])

        for ses in range(data_raw.shape[0]):
            data_raw[ses, var] = ndata[mtype.names[var]].flatten()[ses]

    # save the data as a pandas dataframe
    df = pd.DataFrame(data_raw, columns=data_headline)

    # %% Do some preliminary behavioral analysis
    # TODO: Reshape the table first

    # for now, just grab MPC calculated DS PE ratios
    # to do so make an empty array, cat() together values and then assign as column in df
    var = np.empty(df.shape[0])
    for ses in range(df.shape[0]):
        # B(23)=DS PE ratio ; B(24= NS PE ratio)
        # df[ses].DSPEratio.assign=df.x_B_workingVars[ses][23].copy()
        var[ses] = df.x_B_workingVars[ses][23]

    df = df.assign(DSPEratio=var)

    var = np.empty(df.shape[0])
    for ses in range(df.shape[0]):
        # B(23)=DS PE ratio ; B(24= NS PE ratio)
        # df[ses].DSPEratio.assign=df.x_B_workingVars[ses][23].copy()
        var[ses] = df.x_B_workingVars[ses][24]
    df = df.assign(NSPEratio=var)

    # calculate a 'discrimination index' as DSratio/NSratio
    df = df.assign(discrimPEratio=df.DSPEratio/df.NSPEratio)

    # calculate port exit time estimate using PEtime and peDur, save this as a new variable
    df = df.assign(PExEst=df.x_K_PEtime + df.x_L_PEdur)

    # somehow different amount of cues and laser states...
    # possibly due to error in code from 20210604 session
    # 26 missing NSlaser entries x 11 subjects =286. = size mismatch

    # ~~EXCLUDE this date~~~~~~~~~~~~~~~~~~~!!!
    df = df[df.date != 20210604]

   