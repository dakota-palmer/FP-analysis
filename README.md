# FP-analysis
 Matlab workflow for fiber photometry analysis- In this branch, data extraction is separated from data analysis

* Download necessary MatLab scripts (https://github.umn.edu/palme876/FP-analysis/tree/master/matlabVPFP)

* Retrieve TDT files for each session- saved locally on recording PC 

* In MatLab, run TDT2NEX(‘tank filepath’) to generate a .NEX (.NEX5 is disposable)
     * You can use the batchTDT2NEX script to save time with a lot of tanks
     * Once you've generated .Nex files, save them and you won't need to do it again- these are the only files you will use for analysis
     * Generating & moving NEX files / TDT data can take a long time- batchTDT2NEX.m will help, but consider doing this on the data collection PC after recording or automating this step somehow
     
* Place these .NEX files in a folder along with VPFP_metadata_template.xlsx (https://github.umn.edu/palme876/FP-analysis/tree/master/nexFilesVPFP)
     * The metadata .xlsx will provide all session metadata to MatLab for analysis
     * Make sure the metadata .xlsx is up-to-date and accurate with the metadata corresponding to each TDT tank (each .NEX file) 

* Open fpExtractData.m in matlab
     * Make sure the file paths toward the beginning of the script for the .Nex files and metadata .xlsx are up to date 
     * Make sure the indices are correct for the xlsread section- they should correspond to your files of interest
     * Make sure the experiment name string is updated- this will be used to automatically generate filenames for saved plots/variables

* Run the script. It should load all data in according to the metadata .xlsx
     * The script will loop through each recording session (each nex file within the .nex filepath indicated), associating metadata with it (rat #s, training day, training stage etc.)
     * Because of how our recording is setup, data is originally imported in terms of training box (for now, this is either A or B)
     * After looping through each session, data is reorganized by subject (instead of by box) and saved into a struct 
     * Data from each session is stored in sesData in terms of recording box and subjData in terms of subject
     * The script will save the subjData struct as a .mat file indcluding the experimentName and date in the filename 
* Open fpAnalyzeData.m in matlab
* Run the script. You will be prompted to select a data file to load- Choose the .mat containing the subjData struct output by the previous scrip
      * This script will perform data analysis within-session (e.g. dF & z-score calculations around the time of cue onsets) and between-session analyses (e.g. plotting heatmap of all cue responses for a given rat)
      
*Edits to variableReward branch:
    * broken up code file is used to more easily edit the scripts that run analysis on the photometry data after it has been extracted         using the ASedited extracting scripts. 
    * Run the fpAnalysis.m file only. The other files are used to more easily edit and access the code.  The order the files are run in       fpAnalysis.m currently must remain the same. 
