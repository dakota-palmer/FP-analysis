# FP-analysis

Fiber photometry analysis pipeline developed with Alexandra Scott for Jocelyn Richard’s Lab at the University of Minnesota. Used for analyses including those reported in Palmer et al., 2023.


##  Overview

### Workflow containing MATLAB, Python, and R code for:

* Combining neuronal recordings, behavioral data, & metadata 
* Preprocessing of photometry signals (downsampling, baseline estimation, artifact elimination)
* Behavioral analyses (focused on Discriminative Stimulus (DS) Task)
* Data visualization & automated figure generation
* Relating neuronal signals to behavior (Peri-event plots, correlations, encoding model, statistical analyses)

### Note about use/adapting:

* As I developed this code over ~4 years, I branched out into other programming languages (Python/R) and improved my programming/data science skills. While I think the code is robust and generalizable, I started this project while learning MATLAB and older code is not super efficient. Early on, I used nonoptimal nested struct organization with many loops. I also manually created and saved a ton of figures  (before learning about packages like gramm/seaborn/ggplot).  Eventually, in MATLAB, converted the inefficient structs into tables which are much easier to work with (see fpStruct2Table.m and fp_manuscript_TidyTable.m scripts). Newer/more recent MATLAB code (e.g. manuscript figure scripts) tends to use tables as well as the gramm package for data visualizations. I recommend going to table/dataframe format ASAP for any new analyses. If I had to do this over again, I’d ditch MATLAB and structs from the beginning and just use Python or R (possibly with relational databases).

* This code can be adapted to other behavioral tasks but many of the variable names/behavioral analyses are currently task-specific (e.g. DS, NS, port-entry (pox), licks (lox)). 
Fiber photometry analysis pipeline developed with Alexandra Scott for Jocelyn Richard’s Lab at the University of Minnesota. Used for analyses including those reported in Palmer et al., 2023.

## Data Analysis Workflow

### Data Extraction 

**In MATLAB**:

0.  Run batchTDT2Nex.m to convert TDT tanks to .NEX files (described in detail below)
     * Converts each tank to .NEX file using TDT2Nex.m 


1. Run fpExtractData.m script → outputs subjDataRaw struct in .mat file
     * imports .NEX files, imports session metadata .XLSX sheets → combines into struct → outputs subjDataRaw struct in .mat file
     * Not used in manuscript, but optional initial artifact removal if set artifactRemove=1
          * Uses fpArtifactElimination_DynamicMAD.m 
          * Also, made an interactive MATLAB app to iteratively test parameters/thresholds for artifact elimination- for this, run artifactParameterTest.mlapp
     * **change variables according to your photometry signals/behavior/data acquisition hardware configuration** 



### Data Analysis & Vizualization
2. Run fpAnalysis.m script→ outputs subjDataAnalyzed struct in .mat file
     * Optional signal preprocessing using DFF (set signalMode= ‘dff’) or airPLS method (set signalMode= ‘airPLS’) or none (set signalMode= ‘reblue’)

     * Automatically runs analysis scripts: 
          * fpAnalyzeData_create_struct_with_animal_data.m 
               * Imports subjDataRaw.mat– **UI file browser prompt will open, user selects the subjDataRaw.mat file previously generated by fpExtractData.m**
               * Initializes subjDataAnalyzed struct 
          * fpAnalyzeData_behavioral_analysis.m 
               * Trial-based behavioral analyses- assign events to trials using fpEventID.m, compute event latencies, compute PE ratios, etc. Saves in subjDataAnalyzed struct 

          * Optional fp_fit_comparison.m 
               * uncomment & run if you want to plot fp signals for all sessions to compare different preprocessing methods (determined by signalMode)
          * fp_signal_process.m 
               * Optional signal preprocessing (determined by signalMode)
          * fpAnalyzeData_eventtriggered_analysis.m
               * Computes Z-scored peri-event photometry signals using fp_periEvent.m script

          * Variable outcome analyses/viz (this is pretty specific to Richard Lab DS Task Stage >=8 with variable reward outcomes)
               * fpAnalyzeData_outcome_dataprep.m
               * fpAnalyzeData_outcome_analysis.m

          * Plotting scripts
               * fpAnalyzeData_heatplots_cuetimelocked.m
               * fpAnalyzeData_heatplots_portentrytimelocked.m
               * fpAnalyzeData_heatplots_firstlicktimelocked.m
               * fpAnalyzeData_heatplots_cuetimelocked_variablereward.m
               * fpAnalyzeData_heatplots_portentrytimelocked_variablereward.m
               * fpAnalyzeData_CueTimeLockSorted_nextto_PETimeLockedSorted.m
               * fpAnalyzeData_behavioralplots.m
               * fpAnalyzeData_traces_cuetimelocked.m
               * fpAnalyzeData_traces_portentrytimelocked.m
               * fpAnalyzeData_heatplots_cuetimelocked_stages_avgtrainday.m
               * fpAnalyzeData_heatplots_cuetimelocked_stages_latencysorttrials.m

          * fpAnalyzeData_save.m
               * Outputs subjDataAnalyzed struct into .mat file

3. Prepare data for exporting to Python/R - run fpStruct2Table.m
     * Converts subjDataAnalyzed struct to table format, Outputs subjDataAnalyzed table as .parquet file which can be loaded into Python/R 

### Reorganizing, Statistical Analyses, & Figures for Palmer et al., 2023 Manuscript

4. Run fp_manuscript_fig_prep.m

     * Loads subjDataAnalyzed.mat, converts to periEventTable in table format, computes additional analyses (e.g. AUCs, latency correlation, licks per trial), makes more plots  —> Outputs periEventTable in .mat file

5.   Encoding model, behavioral analyses, & Figure 1 from Palmer et al., 2023

     **In Python**:
     1.  Be sure you have .parquet file with subjDataAnalyzed table generated from step 3 above (fpStruct2Table.m)

     2. Run fpImportDataTidy.py
          * Loads the .parquet, tidies data in pandas dataframe, adds variables like trialID, trialType 
          * outputs dfTidyFp dataframe as .pkl file
     3. Run fpBehaviorAnalysis.py
          * Loads dfTidyFp .pkl file
          * Trial based analyses (e.g. PE outcome and probability)
          * Adds epochs, defines new & more specific event types (e.g. reward licks)
          * Outputs dfTidyAnalyzed dataframe as.pkl file
     4. For Palmer et al., Manuscript Figure 1, Run fp_Manuscript_Fig1.py
          * Outputs figure1 .pdf file and fig1d .pkl file for stats in R
     5. Run fpEncodingModelPrep.py
          * **You can adjust parameters throughout to determine eventTypes etc. included in encoding model**
          * Loads dfTidyAnalyzed .pkl file
          * Prepares dfTemp dataframe for regression input: Converts event timestamps to binary coding, Calculates peri-cue Z score FP signal for each trial, creates time shifted sets of each event (with 1 column per time shift)
          * Outputs regressionInput .pkl file and regressionInputMeta .pkl file
     6. Run fpEncodingModelStats.py
          * Loads regressionInput .pkl file and regressionInputMeta .pkl file
          * Runs LASSO regression for each subject, saves regression output results in dfEncoding dataframe
          * Outputs regressionModel .pkl for each subject
     7. Run fpEncodingModelPlots.py
          * Loads each subject’s regressionModel .pkl, combines them
          * Makes plots
          * Outputs fig3_df_kernelsAll dataframe (regression kernels) to.csv file and fig3_df_predictedMean (actual and model-predicted fp signals) to .csv file  for re-importing to MATLAB 

6. Make figures for Palmer et al., 2023 Manuscript

     **In MATLAB:**
     1. Run fp_manuscript_figure_mockups.m
          * Loads periEventTable.mat, refactors/subsets data of interest, makes manuscript figures, exports figure data in .parquet format for stats (Stats done later via Python →R)
     
          * Generates photometry figures 2/3 for Palmer et al., 2023 
               * fp_manuscript_fig2_uiPanels.m
               * fp_manuscript_fig3_uiPanels_2events.m
               * ((**Note Figure 3 encoding model plots are dependent on .csv files with model results from Python encoding model code/workflow above**))

7) Prepare data for statistical analyses
    
     **In Python:**
     1. Run vp-vta-fp_manuscript_stats.py
          * Currently, this and subsequent scripts include code for Opto data (Figures 4, 5, & 6) stats too, so those parts may throw errors if you only have FP data (opto workflow is described elsewhere)
          * Loads .parquet files of figure data generated from MATLAB, tidies/organizes, and Outputs dataframes to .pkl files for statistical analysis in R 
 
7) Run statistical analyses
     
     **In R:**
     * Each of these will import data from .pkl files, run statistical analyses, and save output reports into .txt files :
          1. Run VP-VTA_manuscript_stats_fig_1.R
          2. Run VP-VTA_manuscript_stats_fig_2.R
          3. Run VP-VTA_manuscript_stats_fig_3.R
          4. Run VP-VTA_manuscript_stats_fig_4.R
          5. Run VP-VTA_manuscript_stats_fig_5.R
          6. Run VP-VTA_manuscript_stats_fig_6.R


## Additional info: Raw input data, hardware configuration, & data extraction details

### Raw photometry & behavioral event data

* TDT Tanks containing photometry signals and behavioral event timestamps collected using Synapse and the TDT RZ5P data acquisition system

     * Behavioral event timestamps originate from MED Associates TTL pulses 

     * Will be converted to .NEX files using batchTDT2Nex.m  (.NEX) 
     
     * Due to the way that our hardware was set up- there are 2 MED PC boxes per TDT Tank/ .NEX file (1 session per Tank/.NEX file, 2 boxes collected in parallel and combined)

### Session metadata

* Manually-managed metadata spreadsheets
     * Session metadata .xslx sheet
For each recording session, has metadata including identity of Box A, Box B, Subject A, Subject B, training stage, etc.

### Data extraction notes:

This describes the current MATLAB importing/analyses process using TDT's MATLAB SDK. Note that they have other SDKs which you could use if you prefer to go straight to Python, R, etc.


1. Retrieve TDT files for each session- saved locally on recording PC
     
2. **In MatLab**, run TDT2NEX(‘tank filepath’) to generate a .NEX (.NEX5 is disposable)
     * You can use the batchTDT2NEX script to save time with a lot of tanks
     
     * Once you've generated .Nex files, save them and you won't need to do it again- these are the only files you will use for analysis

     * Generating & moving NEX files / TDT data can take a long time- batchTDT2NEX.m will help, but consider doing this on the data collection PC after recording or automating this step somehow

3. Place these .NEX files in a folder along with session metadata spreadsheet .xlsx
     * The metadata .xlsx will provide all session metadata to MatLab for analysis
     * Make sure the metadata .xlsx is up-to-date and accurate with the metadata corresponding to each TDT tank (each .NEX file)
     * Open fpExtractData.m in Matlab
     * Make sure the file paths toward the beginning of the script for the .Nex files and metadata .xlsx are up to date
     * Make sure the indices are correct for the xlsread section- they should correspond to your files of interest
     * Make sure the experiment name string is updated- this will be used to automatically generate filenames for saved plots/variables
     * Run the script. It should load all data in according to the metadata .xlsx
     * The script will loop through each recording session (each nex file within the .nex filepath indicated), associating metadata with it (Subject IDs, training day, training stage etc.)
     * Because of how our recording is setup, data is originally imported in terms of training box (for now, this is either A or B)
     * After looping through each session, data is reorganized by subject (instead of by box) and saved into a struct
     * Data from each session is stored in sesData in terms of recording box and subjData in terms of subject
     * The script will save the subjData struct as a .mat file indcluding the experimentName and date in the filename
