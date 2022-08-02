%% Choose whether or not to replace reblue with dff (dff after subtracting fitted isosbestic signal)?

% if signalMode== 'dff', will overwrite reblue with dff in
% create_struct_with_animal_data

signalMode= 'dff';

% signalMode= 'reblue'


%% Run Analysis on Extracted Data


cd ('C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code');

%  cd ('C:\Users\Ally\Desktop\FP-analysis-variableReward\FP_analysis\FP-analysis\matlabVPFP\broken up code\');



%cd ('C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code');

fpAnalyzeData_create_struct_with_animal_data;
fpAnalyzeData_behavioral_analysis;
fpAnalyzeData_eventtriggered_analysis;


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
fpAnalyzeData_statisticalquant; 

%% Variable outcome analyses- dp
fpAnalyzeData_outcome_dataprep;
fpAnalyzeData_outcome_analysis;

%% Save
fpAnalyzeData_save;

%%  Speed test /optimizing

profile viewer;
% %things that should be optimized:
%% Denote the end
disp('all done');