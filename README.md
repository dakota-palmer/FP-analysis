# FP-analysis
 Matlab workflow for fiber photometry analysis
2.22.19 
FP Analysis Workflow
Download necessary MatLab scripts (https://drive.google.com/drive/u/2/folders/1dAtDmG79LFlYlo7CNJ1-AYH3unzDD6vB)
TDT files are saved on recording PC  in C:/TDT/Synapse/Tanks/DP_DSTraining-190125-145144 and manually on Google Drive (https://drive.google.com/drive/u/2/folders/1VDzT4CdKVNHw4y76nn2SL-biIScsM1sO)  
In MatLab, run TDT2NEX(‘tank filepath’) to generate a .NEX and a .NEX5… (I think the .NEX5 is disposable- double check?)
You can use the batchTDT2NEX script to save time with a lot of tanks
.Nex files that have already been generated are located alongside raw data in https://drive.google.com/drive/u/2/folders/1ef-eFjmgy9fXgjpCwhTiwbIEgatnW3z1 
Place these .NEX files in a folder along with VPFPIndex.xlsx (https://drive.google.com/open?id=1JIj_Uc2kd7bKnAC14wWhGfxTtYOdw_Yw)
VPFPIndex will provide all session metadata to MatLab for analysis
Make sure VPFPIndex.xlsx is up-to-date and accurate 
Open fpAnalysisDakotav2.m in matlab
Make sure the file paths toward the beginning of the script for the .Nex files and index are up to date 
Make sure the indices are correct for the xlsread section- they should correspond to your files of interest
Go through and figure out what information you want to be plotted (ctl+F->plot); by default a lot of these plots are commented out to save time, but it is important to view each step of the data processing (downsample, fit, dF, etc)
Run the script. It should load all data in according to VPFPIndex.xlsx
The script will loop through each recording session (each nex file within the .nex filepath indicated), associating metadata with it (rat #s, training day, training stage etc.), and performing data analysis within-session (e.g. dF & z-score calculations around the time of cue onsets)
Because of how our recording is setup, data is originally imported in terms of training box (for now, this is either A or B)
After looping through each session, data is reorganized by subject (instead of by box) and then you can perform additional between-session analyses (e.g. plotting heatmap of all cue responses for a given rat)
Data from each session is stored in sesData in terms of recording box and subjData in terms of subject
Notes
Generating & moving NEX files / TDT data can take a very long time- consider doing this on the data collection PC after recording or automating this step somehow
Within fpAnalysisDakota.m ctl+F-> ‘TODO’ or ‘check’ for comments in the script about specific ideas / things to double-check

