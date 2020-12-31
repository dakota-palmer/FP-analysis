%% Run Analysis on Extracted Data


% cd ('C:\Users\capn1\Documents\GitHub\FP-analysis\matlabVPFP\broken up code');

cd ('Y:\Ally\Code\FP-analysis-variableReward\FP_analysis\FP-analysis\matlabVPFP\broken up code\');


fpAnalyzeData_create_struct_with_animal_data();
fpAnalyzeData_behavioral_analysis();
fpAnalyzeData_eventtriggered_analysis();

%% Plot Analyzed Data
fpAnalyzeData_heatplots_cuetimelocked;
fpAnalyzeData_heatplots_portentrytimelocked;
fpAnalyzeData_heatplots_firstlicktimelocked;
fpAnalyzeData_heatplots_cuetimelocked_variablereward;
fpAnalyzeData_heatplots_portentrytimelocked_variablereward;
fpAnalyzeData_behavioralplots;
fpAnalyzeData_traces_cuetimelocked; 
fpAnalyzeData_traces_portentrytimelocked;
fpAnalyzeData_heatplots_cuetimelocked_stages_avgtrainday;
fpAnalyzeData_heatplots_cuetimelocked_stages_latencysorttrials; 
fpAnalyzeData_statisticalquant; 
%% Save
fpAnalyzeData_save;

%%  Speed test /optimizing

profile viewer;
% %things that should be optimized:
%% Denote the end
disp('all done');