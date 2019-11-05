# FP-analysis
 Matlab workflow for fiber photometry analysis

* Download necessary MatLab scripts (https://github.umn.edu/palme876/FP-analysis/tree/master/matlabVPFP)

* Retrieve TDT files for each session- saved locally on recording PC 

* In MatLab, run TDT2NEX(‘tank filepath’) to generate a .NEX (.NEX5 is disposable)
     * You can use the batchTDT2NEX script to save time with a lot of tanks
     * Once you've generated .Nex files, save them and you won't need to do it again- these are the only files you will use for analysis
     * Generating & moving NEX files / TDT data can take a long time- batchTDT2NEX.m will help, but consider doing this on the data collection PC after recording or automating this step somehow
     
* Place these .NEX files in a folder along with VPFP_metadata_template.xlsx (https://github.umn.edu/palme876/FP-analysis/tree/master/nexFilesVPFP)
     * The metadata .xlsx will provide all session metadata to MatLab for analysis
     * Make sure the metadata .xlsx is up-to-date and accurate with the metadata corresponding to each TDT tank (each .NEX file) 

* Open fpAnalysisDakota.m in matlab
     * Make sure the file paths toward the beginning of the script for the .Nex files and metadata .xlsx are up to date 
     * Make sure the indices are correct for the xlsread section- they should correspond to your files of interest
     * Make sure the experiment name string is updated- this will be used to automatically generate filenames for saved plots

* Take time to go through and figure out what information you want to be plotted (ctl+F->plot); by default a lot of these plots are commented out to save time, but it is important to view each step of the data processing (downsample, fit, dF, etc)

* Run the script. It should load all data in according to the metadata .xlsx
     * The script will loop through each recording session (each nex file within the .nex filepath indicated), associating metadata with it (rat #s, training day, training stage etc.), and performing data analysis within-session (e.g. dF & z-score calculations around the time of cue onsets)
     * Because of how our recording is setup, data is originally imported in terms of training box (for now, this is either A or B)
After looping through each session, data is reorganized by subject (instead of by box) and then you can perform additional between-session analyses (e.g. plotting heatmap of all cue responses for a given rat)
     * Data from each session is stored in sesData in terms of recording box and subjData in terms of subject

