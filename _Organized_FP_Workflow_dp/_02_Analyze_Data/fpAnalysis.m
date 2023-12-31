%% Choose whether or not to replace reblue with dff (dff after subtracting fitted isosbestic signal)?

% % if signalMode== 'dff', will overwrite reblue with dff in
% % create_struct_with_animal_data

% signalMode= 'dff';

% % if signalMode== 'airPLS', will overwrite reblue with signal based on 
% % df of independently baseline-corrected 405 and 465
signalMode= 'airPLS';


% signalMode= 'reblue'

%% Figure saving options
% figFormats= {'.svg'}; %svg good for exporting to illustrator
figFormats= {'.png'}; %png good for quick review of many without interaction
% figFormats= {'.fig'}; %fig good for interaction




%% Run Analysis on Extracted Data
cd(pwd)

% cd ('C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code');
%  cd ('C:\Users\Ally\Desktop\FP-analysis-variableReward\FP_analysis\FP-analysis\matlabVPFP\broken up code\');

fpAnalyzeData_create_struct_with_animal_data;
fpAnalyzeData_behavioral_analysis;

% fp_fit_comparison;%dp---uncomment if you want to plot fp signals for all sessions to test different preprocessing methods
    
fp_signal_process; % dp ----- SIGNAL REPLACEMENT; Determined by signalMode
    

fpAnalyzeData_eventtriggered_analysis;


%% Variable outcome analyses- dp

% code pretty specific to specific to dp's DS Task stage >=8
fpAnalyzeData_outcome_dataprep;
fpAnalyzeData_outcome_analysis;

%% Plot Analyzed Data
fpAnalyzeData_heatplots_cuetimelocked;
fpAnalyzeData_heatplots_portentrytimelocked;
fpAnalyzeData_heatplots_firstlicktimelocked;
fpAnalyzeData_heatplots_cuetimelocked_variablereward;
fpAnalyzeData_heatplots_portentrytimelocked_variablereward;
fpAnalyzeData_CueTimeLockSorted_nextto_PETimeLockedSorted
fpAnalyzeData_behavioralplots;
fpAnalyzeData_traces_cuetimelocked; 
fpAnalyzeData_traces_portentrytimelocked;
fpAnalyzeData_heatplots_cuetimelocked_stages_avgtrainday;
fpAnalyzeData_heatplots_cuetimelocked_stages_latencysorttrials; 



%% Save
fpAnalyzeData_save;

%%  Speed test /optimizing

% profile viewer; 
% % %things that should be optimized:
%% Denote the end
disp('all done');