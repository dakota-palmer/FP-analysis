%% Run Analysis on Extracted Data
fpAnalyzeData_create_struct_with_animal_data;
fpAnalyzeData_behavioral_analysis;
fpAnalyzeData_eventtriggered_analysis;

%% Plot Analyzed Data
fpAnalyzeData_heatplots_cuetimelocked;
fpAnalyzeData_heatplots_portentrytimelocked;
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

%% Denote the end
disp('all done');