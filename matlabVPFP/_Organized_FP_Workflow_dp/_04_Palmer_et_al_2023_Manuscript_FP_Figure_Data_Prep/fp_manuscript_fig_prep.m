%% Initialize variables
clear; close all; clc;

%% Load fpAnalyzedData struct
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-17-Dec-2021subjDataAnalyzed.mat")


% load(uigetfile);

% % with artifacts
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-05-Jul-2022subjDataAnalyzed.mat");
% experimentName= 'vp-vta-fp'

% % airPLS version
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-30-Aug-2022subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat")
% 
% % %revised licks .. pre 2023-03-18 criteriaSes fix
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-09-Nov-2022subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat")


%2023-03-18 revised DS/NS ratios (criteriaSes based on 10sec ratio)
load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-18-Mar-2023subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat")


experimentName= 'vp-vta-fp-airPLS';

% % % DFF version
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\VP-VTA-FP-29-Jul-2022subjDataAnalyzed_dff.mat");
% experimentName= 'vp-vta-fp-dff'

% dp workstation
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-16-Jun-2022subjDataAnalyzed.mat")

 
% %ally no artifacts (bu"C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\GADVPFP-22-Feb-2022subjDataAnalyzed.mat"t all trials)
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\GADVPFP-22-Feb-2022subjDataAnalyzed.mat")
% 
% experimentName= 'vp-vta-fp'

%% Set gramm plot defaults
set_gramm_plot_defaults();


%% ID control/exclusion subj

%mark subjects for exclusion
subjToExclude= {'rat17', 'rat10', 'rat16'}; %exclude these due to either dynamic loss of signal or behavior


controlSubj= {'rat20'}; %exclude these due to no signal ever or GFP control


%% Choose whether to plot experimental or control subjects

% subjMode= 'experimental' or 'control or 'all'
subjMode='experimental';
% subjMode='control';

% subjMode= 'all'

%% Choose whether or not to plot z score or dff

normalizeMode= 'z';

% normalizeMode= '_';

%% Choose whether to include all sessions or only Criteria sessions in analyses
% criteriaMode= 'allSes' or 'criteriaSes
criteriaMode= 'allSes';
% criteriaMode= 'criteriaSes';

%% Choose whether to exclude artifact trials based on extreme z score 

artifactExcludeMode= 'trial';
% artifactExcludeMode= '_';

%% Choose whether to exclude sessions based on fp signal correlation

% sesCorrExcludeMode= 'sesCorr';
sesCorrExcludeMode= '_';



%% Plot Settings
figPath= strcat(pwd,'\_output\');

% figFormats= {'.svg'} %list of formats to save figures as (for saveFig.m)

figFormats= {'.png'} %list of formats to save figures as (for saveFig.m)


%-- Master plot linestyles and colors

%thin, light lines for individual subj
linewidthSubj= 0.5;
lightnessRangeSubj= [100,100];

%dark, thick lines for between subj grand mean
linewidthGrand= 1.5;
lightnessRangeGrand= [10,10];


%-- Custom colormap for plots

% % - Colormap for 465nm vs 405nm comparisons (7 class PRGn, purple vs green)
% %green and purple %3 levels each, dark to light extremes + neutral middle
% mapCustomFP= [ 27,120,55;
%             127,191,123;
%             217,240,211;
%             247,247,247
%             231,212,232
%             175,141,195;
%             118,42,131;
%            ];
% 
%         mapCustomFP= mapCustomFP/255;
% 
% 
% % - Colormap for DS vs NS comparisons (7 class BrBG; teal blue vs. brown orange)
% mapCustomCue= [90,180,172;
%             199,234,229;
%             245,245,245;
%             1,102,94
%             246,232,195;
%             216,179,101;
%             140,81,10;   
%             ];
%             
%         mapCustomCue= mapCustomCue/255;



%% Get Licks per trial (for manuscript review)

% licks within fixed time post-PE 
fpManuscript_supplement_licks_per_trial_count();

%% Create periEventTable
fp_manuscript_tidyTable();

%% make training plots

% fp_manuscript_behaviorPlots();


%% ID and remove artifacts

% % explored method here for trial exclusion of simple large artifacts

% fp_manuscript_artifactExclusion();

%% ID and bad sessions for exclusion based on fp signal

% %  explored method here for "noisy" session exclusion based on
% % correlation between isosbestic and calcium signal, but didn't use for
% % manuscript

% fp_manuscript_session_correlation();

%% Isolate / exclude data based on behavioral criteria (& subject)
% will define periEventTable for subsequent scripts (control v experimental based on flag above)

fp_manuscript_dataExclusion();


%% Latency correlation

% fp_manuscript_latencyCorrelation();


%% make peri-event 465nm plots
fp_manuscript_periEventTraces();


%% FIGURE 2

%-- Peri DS vs. Peri NS 2D traces

%-- Peri DS vs. Peri NS AUC & Stat comparison

%% make variable reward plots
fp_manuscript_variableReward();


%% ------------------ older stuff follows: --------------
% 
% %% load encoding model output 
% 
% periCueFrames= [1:601];
% 
% % 
% %dp paths
% % load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465\allSubjResultskernel_Shifted_all.mat")
% 
% %ASSUME only mats with individual stats.b in this folder
% %path to .mat Mean Actual LASSO output for each subj (correlations coefficients)
% % pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\stage7\465';
% 
% %workstation for ally's data
% %ASSUME only mats with individual stats.b in this folder
% pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465'
% 
% % load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\allSubjResultskernel_Shifted_all.mat")
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\_control\stage7\465\allSubjResultskernel_Shifted_all.mat")
% 
% %loop through files and extract data
% cd(pathLasso);
% mat = dir('*.mat');
% 
% % %initialize structure (will collect individual file's (subj) kernels)
% % lassoOutput=struct(length(mat)); 
% % lassoOutput.b= [];
% %% Save kernels into table
% % easy for plotting later
% kernelTable= table();
% kernelTable.file= cell(length(mat)*(periCueFrames+1),1);
% kernelTable.subject= cell(length(mat)*(periCueFrames+1),1);
% kernelTable.timeLock= nan(length(mat)*(periCueFrames+1),1); 
% kernelTable.kernelDS= nan(length(mat)*(periCueFrames+1),1); 
% kernelTable.kernelPoxDS= nan(length(mat)*(periCueFrames+1),1); 
% kernelTable.kernelLoxDS= nan(length(mat)*(periCueFrames+1),1); 
% 
% % fileInd= 1:periCueFrames; %index for table corresponding to this file
% for file= 1:length(mat)
%     kernel=[]; %clear btwn subjects
%     
%     %load LASSO results
%     lassoOutput(file) = load(mat(file).name);
% 
%     b= lassoOutput(file).b;
% 
%     %isolate kernels for each eventType
%     for eventType = 1:k
%          %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
%           if eventType==1
%             tsThisEvent= 2:(numel(b)/k)+1; %skip first index (intercept)
%           else
%             tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(numel(b)/k); 
%           end
% 
%        sumTerm= []; %clear between event types
% 
%        for ts= 1:(numel(b)/k) %loop through ts; using 'ts' for each timestamp instead of 'i'
%     %                %this seems to fit- there should be 81 time bins in the example data x 7 event types ~ 567      
%             kernel(ts,eventType) = b(tsThisEvent(ts));
%        end
% 
%        timeLock= linspace(-time_back, time_forward, size(kernel,1));
% 
%     end 
% 
%     %iterate table index between files and save data in table
%     if file==1
%         fileInd= 1:periCueFrames+1;
%     else
%         fileInd= fileInd+ periCueFrames+1;
%     end
%     
%     
%     %assume order of eventType columns is DS, DSpox, DSlox
%     kernelTable.file(fileInd)={mat(file).name};
%     
%     subject= strfind(mat(file).name, 'rat');
%     subject= mat(file).name(subject:end);
%     subject= subject(1:strfind(subject,'_')-1);
%     
%     kernelTable.subject(fileInd)= {subject};
%     
%     kernelTable.timeLock(fileInd)=timeLock;
%     kernelTable.kernelDS(fileInd)=kernel(:,1);
%     kernelTable.kernelPoxDS(fileInd)=kernel(:,2);
%     kernelTable.kernelLoxDS(fileInd)=kernel(:,3);
%     
% 
% end %end file loop (subj)
% 
% %% gramm plot all subjects kernels + periEvent traces
% 
% %subset periEvent data for plotting
% data= periEventTable;
% data= data(data.stage==7,:); 
% 
% %nice plot w gramm
% clear i;
% % figure(); hold on;
% 
% %Plot Between-Subj Means
% i(1,1)=gramm('x',kernelTable.timeLock,'y',kernelTable.kernelDS);
% i(1,1).set_title('DS Kernel');
% i(1,1).stat_summary('type','sem','geom','area');
% i(1,1).set_names('x','time shift from event onset (s)','y','beta');
% i(1,1).set_color_options('chroma',0,'lightness',30);
% 
% i(1,2)=gramm('x',kernelTable.timeLock,'y',kernelTable.kernelPoxDS);
% i(1,2).set_title('DS PE Kernel');
% i(1,2).stat_summary('type','sem','geom','area');
% i(1,2).set_names('x','time shift from event onset (s)','y','beta');
% i(1,2).set_color_options('chroma',0,'lightness',30);
% 
% i(1,3)=gramm('x',kernelTable.timeLock,'y',kernelTable.kernelLoxDS);
% i(1,3).set_title('DS Lick Kernel');
% i(1,3).stat_summary('type','sem','geom','area');
% i(1,3).set_names('x','time shift from event onset (s)','y','beta');
% i(1,3).set_color_options('chroma',0,'lightness',30);
% 
% 
% 
% %second column with peri-event traces
% i(2,1)=gramm('x',data.timeLock,'y',data.DSblue);
% i(2,1).set_title('Peri-DS');
% i(2,1).stat_summary('type','sem','geom','area');
% i(2,1).set_names('x','time from event (s)','y','z-score');
% i(2,1).set_color_options('chroma',0,'lightness',30);
% 
% 
% i(2,2)=gramm('x',data.timeLock,'y',data.DSbluePox);
% i(2,2).set_title('Peri-DS PE');
% i(2,2).stat_summary('type','sem','geom','area');
% i(2,2).set_names('x','time from event (s)','y','z-score');
% i(2,2).set_color_options('chroma',0,'lightness',30);
% i(2,2).set_line_options('base_size',2);
% 
% 
% i(2,3)=gramm('x',data.timeLock,'y',data.DSblueLox);
% i(2,3).set_title('Peri-DS Lick');
% i(2,3).stat_summary('type','sem','geom','area');
% i(2,3).set_names('x','time from event (s)','y','z-score');
% i(2,3).set_color_options('chroma',0,'lightness',30);
% i(2,3).set_line_options('base_size',2);
% 
% 
% i.draw();
% 
% %plot Individual Subjects overlay~~~
% i(1,1).update('color',kernelTable.subject);
% % i(1,1).set_title('DS Kernel');
% % i(1,1).stat_summary('type','sem','geom','area');
% i(1,1).geom_line('alpha',0.5);
% i(1,1).set_color_options();
% i(1,1).set_line_options('base_size',0.5);
% 
% 
% i(1,2).update('color',kernelTable.subject);
% % i(1,2).set_title('DS PE Kernel');
% % i(1,2).stat_summary('type','sem','geom','area');
% i(1,2).geom_line('alpha',0.5);
% i(1,2).set_color_options();
% i(1,2).set_line_options('base_size',0.5);
% 
% 
% i(1,3).update('color',kernelTable.subject);
% % i(1,3).set_title('DS Lick Kernel');
% % i(1,3).stat_summary('type','sem','geom','area');
% i(1,3).geom_line('alpha',0.5);
% i(1,3).set_color_options();
% i(1,3).set_line_options('base_size',0.5);
% 
% 
% 
% %second column with peri-event traces
% i(2,1).update('color',data.subject);
% i(2,1).stat_summary('type','sem','geom','area');
% i(2,1).set_color_options();
% i(2,1).set_line_options('base_size',0.5);
% 
% 
% i(2,2).update('color',data.subject);
% i(2,2).stat_summary('type','sem','geom','area');
% i(2,2).set_color_options();
% i(2,2).set_line_options('base_size',0.5);
% 
% 
% i(2,3).update('color',data.subject);
% i(2,3).stat_summary('type','sem','geom','area');
% i(2,3).set_color_options();
% i(2,3).set_line_options('base_size',0.5);
% 
% 
% 
% % i.set_title('all subj');
% 
% %manually set axes limits before drawing
% i(1,:).axe_property('YLim',[-2, 5]);
% i(2,:).axe_property('YLim',[-2, 5]);
% 
% i.draw();
% 
% linkaxes(gca,'x');
% 
% saveFig(gcf, figPath, strcat('_allSubj_encoding_kernels_w_periEvent'),figFormats);
% 
% %% Individual subj figs
% 
% for file=1:length(mat)
%     %subset periEvent data for plotting
%     data= periEventTable;
%     data= data(data.stage==7,:); 
%     %find subject from filename
%     subject= strfind(mat(file).name, 'rat');
%     subject= mat(file).name(subject:end);
%     subject= subject(1:strfind(subject,'_')-1);
%     %subset data for this subj
%     data= data(~cellfun(@isempty,strfind(data.subject,subject)),:);
% 
%     %subset kernel data for plotting
%     dataKernel= kernelTable;
%     dataKernel= dataKernel(~cellfun(@isempty,strfind(dataKernel.subject,subject)),:);
% 
% 
% 
%     %nice plot w gramm
%     clear i;
%     % figure(); hold on;
% 
%     %Plot Between-Subj Means
%     i(1,1)=gramm('x',dataKernel.timeLock,'y',dataKernel.kernelDS);
%     i(1,1).set_title('DS Kernel');
%     i(1,1).stat_summary('type','sem','geom','area');
%     i(1,1).set_names('x','time shift from event onset (s)','y','beta');
%     i(1,1).set_color_options('chroma',0,'lightness',30);
% 
%     i(1,2)=gramm('x',dataKernel.timeLock,'y',dataKernel.kernelPoxDS);
%     i(1,2).set_title('DS PE Kernel');
%     i(1,2).stat_summary('type','sem','geom','area');
%     i(1,2).set_names('x','time shift from event onset (s)','y','beta');
%     i(1,2).set_color_options('chroma',0,'lightness',30);
% 
%     i(1,3)=gramm('x',dataKernel.timeLock,'y',dataKernel.kernelLoxDS);
%     i(1,3).set_title('DS Lick Kernel');
%     i(1,3).stat_summary('type','sem','geom','area');
%     i(1,3).set_names('x','time shift from event onset (s)','y','beta');
%     i(1,3).set_color_options('chroma',0,'lightness',30);
% 
% 
% 
%     %second column with peri-event traces
%     i(2,1)=gramm('x',data.timeLock,'y',data.DSblue);
%     i(2,1).set_title('Peri-DS');
%     i(2,1).stat_summary('type','sem','geom','area');
%     i(2,1).set_names('x','time from event (s)','y','z-score');
%     i(2,1).set_color_options('chroma',0,'lightness',30);
% 
% 
%     i(2,2)=gramm('x',data.timeLock,'y',data.DSbluePox);
%     i(2,2).set_title('Peri-DS PE');
%     i(2,2).stat_summary('type','sem','geom','area');
%     i(2,2).set_names('x','time from event (s)','y','z-score');
%     i(2,2).set_color_options('chroma',0,'lightness',30);
%     i(2,2).set_line_options('base_size',2);
% 
% 
%     i(2,3)=gramm('x',data.timeLock,'y',data.DSblueLox);
%     i(2,3).set_title('Peri-DS Lick');
%     i(2,3).stat_summary('type','sem','geom','area');
%     i(2,3).set_names('x','time from event (s)','y','z-score');
%     i(2,3).set_color_options('chroma',0,'lightness',30);
%     i(2,3).set_line_options('base_size',2);
% 
% 
% %     i.draw();
% % 
% %     %plot Individual Subjects overlay~~~
% %     i(1,1).update('color',kernelTable.subject);
% %     % i(1,1).set_title('DS Kernel');
% %     % i(1,1).stat_summary('type','sem','geom','area');
% %     i(1,1).geom_line('alpha',0.5);
% %     i(1,1).set_color_options();
% %     i(1,1).set_line_options('base_size',0.5);
% % 
% % 
% %     i(1,2).update('color',kernelTable.subject);
% %     % i(1,2).set_title('DS PE Kernel');
% %     % i(1,2).stat_summary('type','sem','geom','area');
% %     i(1,2).geom_line('alpha',0.5);
% %     i(1,2).set_color_options();
% %     i(1,2).set_line_options('base_size',0.5);
% % 
% % 
% %     i(1,3).update('color',kernelTable.subject);
% %     % i(1,3).set_title('DS Lick Kernel');
% %     % i(1,3).stat_summary('type','sem','geom','area');
% %     i(1,3).geom_line('alpha',0.5);
% %     i(1,3).set_color_options();
% %     i(1,3).set_line_options('base_size',0.5);
% % 
% % 
% % 
% %     %second column with peri-event traces
% %     i(2,1).update('color',data.subject);
% %     i(2,1).stat_summary('type','sem','geom','area');
% %     i(2,1).set_color_options();
% %     i(2,1).set_line_options('base_size',0.5);
% % 
% % 
% %     i(2,2).update('color',data.subject);
% %     i(2,2).stat_summary('type','sem','geom','area');
% %     i(2,2).set_color_options();
% %     i(2,2).set_line_options('base_size',0.5);
% % 
% % 
% %     i(2,3).update('color',data.subject);
% %     i(2,3).stat_summary('type','sem','geom','area');
% %     i(2,3).set_color_options();
% %     i(2,3).set_line_options('base_size',0.5);
% 
% 
% 
%     i.set_title(subject);
% 
%     %manually set axes limits before drawing
%     i(1,:).axe_property('YLim',[-2, 5]);
%     i(2,:).axe_property('YLim',[-2, 5]);
% 
%     i.draw();
% 
%     linkaxes(gca,'x');
% 
%     saveFig(gcf, figPath, strcat(mat(file).name,'_encoding_kernels_w_periEvent'),figFormats);
% end
% 
% % 
% % %% old
% % % %% Kernels + peri-event plot
% % % %individual subjects
% % % stage= 7;
% % % 
% % % %want 465nm
% % % signal= 465;
% % % 
% % % %Parameters we ran through encoding model
% % % %how much time should you shift back (in seconds)
% % % time_back=5;
% % % time_forward=10;
% % % 
% % % %events corresponding to kernels
% % % cons={'DS','poxDS','loxDS'}; 
% % % k= numel(cons);
% % % 
% % % 
% % % if stage==7 && signal==465
% % %     %path to .mat Mean Actual LASSO output for each subj (correlations coefficients)
% % %     pathLasso= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\encoding model\encoding_results\stage7\465';
% % %     
% % %     %loop through files and extract data
% % %     cd(pathLasso);
% % %     mat = dir('*.mat');
% % %     for file= 1:length(mat)
% % %         %load LASSO results
% % %         lassoOutput(file) = load(mat(file).name);
% % %         
% % %         b= lassoOutput(file).b;
% % %         
% % %         %isolate kernels for each eventType
% % %         %make figure for indidivual subj (1 per file)
% % % %         figure();
% % % %         sgtitle(mat(file).name);
% % %         for eventType = 1:k
% % % %             kernel=[];
% % %              %for indexing rows of b easily as we loop through event types and build kernel, keep track  of timestamps (ts) that correspond to this event type 
% % %               if eventType==1
% % %                 tsThisEvent= 2:(numel(b)/k)+1; %skip first index (intercept)
% % %               else
% % %                 tsThisEvent= tsThisEvent(end)+1:tsThisEvent(end)+(numel(b)/k); 
% % %               end
% % % 
% % %            sumTerm= []; %clear between event types
% % % 
% % %            for ts= 1:(numel(b)/k) %loop through ts; using 'ts' for each timestamp instead of 'i'
% % %         %                %this seems to fit- there should be 81 time bins in the example data x 7 event types ~ 567      
% % %                 kernel(ts,eventType) = b(tsThisEvent(ts));
% % %            end
% % %            
% % %            %subplot each kernel
% % %            timeLock= linspace(-time_back, time_forward, size(kernel,1));
% % % %            subplot(k,2,eventType);
% % % %            plot(timeLock, kernel(:,eventType));
% % % %            title(cons(eventType));
% % %            
% % %            
% % %         end
% % %        
% % %            
% % %            %subset periEvent data for plotting
% % %            data= periEventTable;
% % %            data= data(data.stage==7,:); 
% % %            %find subject from filename
% % %            subject= strfind(mat(file).name, 'rat');
% % %            subject= mat(file).name(subject:end);
% % %            subject= subject(1:strfind(subject,'_')-1);
% % %            %subset data for this subj
% % %            data= data(~cellfun(@isempty,strfind(data.subject,subject)),:);
% % %            
% % %            %now subplot peri-event data!!
% % % %            subplot(k,2,4); title('peri-DS');
% % % %            hold on;
% % % %            plot(data.timeLock, data.DSblue);
% % % %          
% % % %            subplot(k,2,5); title('peri-DS Pox');
% % % %            hold on;
% % % %            plot(data.timeLock, data.DSbluePox);
% % % %          
% % % %            subplot(k,2,6); title('peri-DS Lox');
% % % %            hold on;
% % % %            plot(data.timeLock, data.DSblueLox);
% % %          
% % % 
% % %            %nice plot w gramm
% % %            clear i;
% % %            figure(); hold on;
% % % 
% % %            %first column with kernels
% % %            %TODO: check axes
% % %            i(1,1)=gramm('x',timeLock,'y',kernel(:,1));
% % %            i(1,1).set_title('DS Kernel');
% % %            i(1,1).stat_summary('type','sem','geom','area');
% % %            i(1,1).set_names('x','time from event (s)','y','beta');
% % %            
% % %            i(2,1)=gramm('x',timeLock,'y',kernel(:,2));
% % %            i(2,1).set_title('DS PE Kernel');
% % %            i(2,1).stat_summary('type','sem','geom','area');
% % %            i(2,1).set_names('x','time from event (s)','y','beta');
% % %            
% % %            i(3,1)=gramm('x',timeLock,'y',kernel(:,3));
% % %            i(3,1).set_title('DS Lick Kernel');
% % %            i(3,1).stat_summary('type','sem','geom','area');
% % %            i(3,1).set_names('x','time from event (s)','y','beta');
% % %            
% % %            
% % %            %second column with peri-event traces
% % % 
% % %            i(1,2)=gramm('x',data.timeLock,'y',data.DSblue);
% % %            i(1,2).set_title('Peri-DS');
% % %            i(1,2).stat_summary('type','sem','geom','area');
% % %            i(1,2).set_names('x','time from event (s)','y','z-score');
% % %            
% % %            i(2,2)=gramm('x',data.timeLock,'y',data.DSbluePox);
% % %            i(2,2).set_title('Peri-DS PE');
% % %            i(2,2).stat_summary('type','sem','geom','area');
% % %            i(2,2).set_names('x','time from event (s)','y','z-score');
% % %            
% % %            i(3,2)=gramm('x',data.timeLock,'y',data.DSblueLox);
% % %            i(3,2).set_title('Peri-DS Lick');
% % %            i(3,2).stat_summary('type','sem','geom','area');
% % %            i(3,2).set_names('x','time from event (s)','y','z-score');
% % %            
% % %            
% % %            i.set_title(mat(file).name);
% % %                       
% % %            %manually set axes limits before drawing
% % %            i(:,1).axe_property('YLim',[-0.5, 1.5]);
% % %            i(:,2).axe_property('YLim',[-2, 5]);
% % % 
% % %            i.draw();
% % %                     
% % %            linkaxes(gca,'x');
% % %            
% % %         saveFig(gcf, figPath, strcat(mat(file).name,'_encoding_kernels_w_periEvent'),figFormats);
% % % 
% % %   
% % %     end
% % %    
% % %     
% % % end
