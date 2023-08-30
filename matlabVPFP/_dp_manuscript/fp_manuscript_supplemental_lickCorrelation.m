
%% -------- LICK CORRELATION with PERI-PE GCaMP --------------------------


%% Load data
data= periEventTable;

corrInputTable= table;

corrInputTable= data;

%% Set gramm plot defaults
% set_gramm_plot_defaults();


%% Plot Settings
figPath= strcat(pwd,'\_figures\_mockups\');

%SVG good for exporting for final edits
% figFormats= {'.svg'} %list of formats to save figures as (for saveFig.m)

%PNG good for quickly viewing many
% figFormats= {'.png'} %list of formats to save figures as (for saveFig.m)
% figFormats= {'.svg','.fig'} %list of formats to save figures as (for saveFig.m)
%pdf for final drafts
figFormats= {'.pdf','.svg','.fig'} %list of formats to save figures as (for saveFig.m)


%-- Master plot linestyles and colors

%thin, light lines for individual subj
linewidthSubj= 0.5;

%dark, thick lines for between subj grand mean
linewidthGrand= 1.5;

%thicker lines for reference lines
linewidthReference= 2;

%-- Master plot axes settings
%- set default axes limits between plots for consistency
%default lims for traces 
ylimTraces= [-2,5];
xlimTraces= [-2,10];

%default lims for AUC plots
%note xlims best to calculate dynamically for bar plots based on num x categories
% ylimAUC= [-1,16];
ylimAUC= [-6,16.5];


 %% Exclude data from correlation... 
 % --- Subset data
 % Only include DS trials with PE and lick
 
%- SUBSET data
data=[];
data= corrInputTable;

% subset data- by stage
% stagesToPlot= [1:11];
stagesToPlot= [7];

ind=[];
ind= ismember(data.stage, stagesToPlot);

data= data(ind,:);


% -- Subset data- restrict to last 3 sessions of stage 7 (same as encoding model input?)
nSesToInclude= 3; 

% reverse cumcount of sessions within stage, mark for exclusion
groupIDs= [];

% data.StartDate= cell2mat(data.StartDate);
groupIDs= findgroups(data.subject, data.stage);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

data(:, 'includedSes')= table(nan);


for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
        
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= data(ind,:);

    % get max trainDayThisStage for this Subject
    maxTrainDayThisStage= [];
    thisGroup(:,'maxTrainDayThisStage')= table(max(thisGroup.trainDayThisStage));

    %check if difference between trainDayThisStage and max is within
    %nSesToInclude
    thisGroup(:,'deltaTrainDayThisStage')= table(thisGroup.maxTrainDayThisStage - thisGroup.trainDayThisStage);

    % this way delta==0 is final day, up to delta < nSesToInclude
    ind2=[];
    ind2= thisGroup.deltaTrainDayThisStage < nSesToInclude;
    thisGroup(:,'includedSes')= table(nan);

    thisGroup(ind2,'includedSes')= table(1);

    
        
    %assign back into table
    data(ind, 'includedSes')= table(thisGroup.includedSes);
%     
%     %now cumulative count of observations in this group
%     %make default value=1 for each, and then cumsum() to get cumulative count
%     thisGroup(:,'cumcount')= table(1);
%     thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
%     
%     thisGroup(:,'cumcountMax')= table(max(thisGroup.cumcount));
    
    %assign back into table
%     data(ind, 'testCount')= table(thisGroup.cumcount);
  
    %subtract trainDayThisStage - cumcount max and if 
    
%     % Check if >1 observation here in group
%     % if so, flag for review
%     if height(thisGroup)>1
%        disp('duplicate ses found!')
%         dupes(ind, :)= thisGroup;
% 
%     end
    
end 


ind= [];
ind= data.includedSes==1;

data= data(ind,:);

% subset data- by PE outcome; only include trials with valid PE post-cue
ind=[];
ind= data.DStrialOutcome==1;

data= data(ind,:);

% subset data- by lick; only include trials with valid lick counted
ind= [];
ind= data.loxDSrelCountAllThisTrial>=1;

data= data(ind,:);

corrInputTable= data;

%-- old code for excluding post-PE timestamps from correlation
 
% 
%   %-- DS trials
%   
% %signal columns (what to replace with nan)
% y=[];
% y= ["DSblue", "DSpurple", "DSbluePox", "DSpurplePox"];
% 
% 
% %replace signal following first PE for each trial with nan
% ind=[];
% ind= data.timeLock > data.poxDSrel;
% 
% latencyCorrInputTable(ind, y) = table(nan);
% 
% 
% %-- dp 2023-03-13 currently excluding data per trial based on real latency
% %value
% % BUT afterward shuffling 
% % so when running stats, have signal timepoints cut off with NA
% % corresponding to new shuffled PE latency



%% Add Shuffled Data to set (shuffled lick counts per trial)


%-- DS trials
  
  %initialize col
corrInputTable(:,"loxDSrelCountAllThisTrialShuffled")= table(nan);
  
  %TODO: just shuffling latencies between trials, consider within
  %subj/session
data= corrInputTable;

allTrials= unique(data.DStrialIDcum);

allTrials= allTrials(~isnan(allTrials));

trialShuffle= [];
trialShuffle= allTrials(randperm(numel(allTrials)));

for trial= 1:numel(allTrials)
   
    %for each trial get corresponding shuffled trial's latency and add in
    %new col
    
    ind= []; 
%     ind= ismember(data.DStrialIDcum, allTrials(trial)); %16256 calls, 32s
    ind= find(data.DStrialIDcum== allTrials(trial));

    
    ind2= [];
%     ind2= ismember(data.DStrialIDcum, trialShuffle(trial));
    ind2= find(data.DStrialIDcum== trialShuffle(trial));
    
    % rather slow, idk if it is the looping or the assignment
%     data(ind,'poxDSrelShuffled')= data(ind2(1), 'poxDSrel');  
    
     corrInputTable(ind,'loxDSrelCountAllThisTrialShuffled')= data(ind2(1), 'loxDSrelCountAllThisTrial');  

      
end



%% viz/save distribution of trial lick counts

data= periEventTable;

%- SUBSET data
data= periEventTable;

% subset data- by stage
% stagesToPlot= [1:11];
stagesToPlot= [7];

ind=[];
ind= ismember(data.stage, stagesToPlot);

data= data(ind,:);


% -- Subset data- restrict to last 3 sessions of stage 7 (same as encoding model input?)
nSesToInclude= 3; 

% reverse cumcount of sessions within stage, mark for exclusion
groupIDs= [];

% data.StartDate= cell2mat(data.StartDate);
groupIDs= findgroups(data.subject, data.stage);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

data(:, 'includedSes')= table(nan);


for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
        
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= data(ind,:);

    % get max trainDayThisStage for this Subject
    maxTrainDayThisStage= [];
    thisGroup(:,'maxTrainDayThisStage')= table(max(thisGroup.trainDayThisStage));

    %check if difference between trainDayThisStage and max is within
    %nSesToInclude
    thisGroup(:,'deltaTrainDayThisStage')= table(thisGroup.maxTrainDayThisStage - thisGroup.trainDayThisStage);

    % this way delta==0 is final day, up to delta < nSesToInclude
    ind2=[];
    ind2= thisGroup.deltaTrainDayThisStage < nSesToInclude;
    thisGroup(:,'includedSes')= table(nan);

    thisGroup(ind2,'includedSes')= table(1);

    
        
    %assign back into table
    data(ind, 'includedSes')= table(thisGroup.includedSes);
%     
%     %now cumulative count of observations in this group
%     %make default value=1 for each, and then cumsum() to get cumulative count
%     thisGroup(:,'cumcount')= table(1);
%     thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
%     
%     thisGroup(:,'cumcountMax')= table(max(thisGroup.cumcount));
    
    %assign back into table
%     data(ind, 'testCount')= table(thisGroup.cumcount);
  
    %subtract trainDayThisStage - cumcount max and if 
    
%     % Check if >1 observation here in group
%     % if so, flag for review
%     if height(thisGroup)>1
%        disp('duplicate ses found!')
%         dupes(ind, :)= thisGroup;
% 
%     end
    
end 


ind= [];
ind= data.includedSes==1;

data= data(ind,:);

% subset data- by PE outcome; only include trials with valid PE post-cue
ind=[];
ind= data.DStrialOutcome==1;

data= data(ind,:);

% subset data- by lick; only include trials with valid lick counted
ind= [];
ind= data.loxDSrelCountAllThisTrial>=1;

data= data(ind,:);

% subset data-1 observation per trial

%-- subset to one observation per trial
%use findgroups to groupby trialIDcum and subset to 1 observation per trial
data2= table();
data3= table();

data2= data;
groupIDs= [];
groupIDs= findgroups(data2.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

% ignore nan trialIDcums (not sure where these came from)
groupIDsUnique= groupIDsUnique(~isnan(groupIDsUnique));

data3=table; 
for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
    
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= data2(ind,:);

    %now cumulative count of observations in this group
    %make default value=1 for each, and then cumsum() to get cumulative count
    thisGroup(:,'cumcount')= table(1);
    thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
    
    %save only single observation per trial (get first value)
    %get observation where timeLock==0
    ind= [];
    ind= thisGroup.timeLock==0;
    
    data3(thisGroupID,:)= thisGroup(ind,:);
    
end 

%redefine data table
data2= table();
data2= data3;


% 
% % -viz  -
% figure;
% g=[];
% group=[];
% g= gramm('x', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
% g.stat_bin();
% g.geom_point();
% g.draw();

% 
%-boxplot distro of PE latency by subj
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];
group=[];
g= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g.set_title('Figure 3 Supplement: Distribution of Trial Lick Counts');
g.set_names('y','Number of Licks','x','Subject','color','Subject', 'column', '');

g.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


% g.stat_boxplot();
g.stat_boxplot('dodge', dodge, 'width', 5);
g.set_color_options('map',cmapGrand);
g.no_legend();
g.draw();

%- overlay individual subj
group= data3.subject;
g.update('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.geom_point();
g.set_color_options('map',cmapSubj);
g.set_line_options('base_size',linewidthSubj);
g.no_legend();
% g.draw();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);

latMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
g.geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 

%-make horizontal
g.coord_flip();

%- final draw call
g.draw();

%%  
%-grand boxplot distro of PE latency 
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];
% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

g(1,1)= gramm('x', data3.loxDSrelCountAllThisTrial, 'group', group);

g(1,1).set_title('Between-Subjects');

g(1,1).axe_property('XLim',[0,70]);

g(1,1).set_names('y','','x','Number of Licks','color','', 'column', '');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


% % g(1,1).stat_boxplot();
% % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
g(1,1).stat_bin('geom','bar','normalization','pdf');
% % g(1,1).stat_violin(); %violin not working with 1d?
% % g(1,1).stat_violin('half','true');
% g(1,1).stat_bin('geom','bar');

g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
% data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);
data4= groupsummary(data3, ["subject"], "all",["loxDSrelCountAllThisTrial"]);


latMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
g(1,1).geom_vline('xintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

%- (2,1) overlay individual subj
g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Number of Licks','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
g(2,1).update('y', data3.loxDSrelCountAllThisTrial, 'x', data3.subject, 'color', data3.subject, 'group', group);

g(2,1).geom_point();

% % g(2,1).update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g(2,1).geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)

g(2,1).geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


g(2,1).set_title('Individual Subjects');


% g(2,1).axe_property('XLim',[0,10], 'YLim', [0, 10]);

g(2,1).axe_property('YLim',[0,70], 'XLim', [0,10]);


g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Trial Lick Counts');

%- final draw call
g.draw();

% comparing grand mean methods 
% latTableF= [];
% latTableF= groupsummary(data3, ["subject"], 'all', "poxDSrel");
% 
% nanmean(data3.poxDSrel)
% 
% nanmean(data3.poxDSrel)
% 
% nanmean(latTableF.mean_poxDSrel) % Correct like below! this was plotted and reported for Fig3F
% 
% correct!
% %  % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
% % test= groupsummary(data3, ["subject"], "mean",["poxDSrel"]);

titleFig='vp-vta_supplement_fig3_lickCount_distro';
saveFig(gcf, figPath, titleFig, figFormats);


%% Run correlation of pooled data for each timestamp

%If we want to relate Z scored fluorescence with PE latency, one way to do
%it would be to pool the Z score values for an individual timestamp
%(across all trials) and correlate them with the PE latency on that trial.
%Then, run a correlation between these Z scores and PE latency. Repeat for
%every timestamp of interest. Result is a beta coefficient for every
%timestamp with PE latency, so we can plot it over time.

% For each subject:
% Combine data within-stage for each timestamp (each trial from each session= 1 observation)

%TODO: Question: Currently combining trials from all sessions in stage for
%correlation. Shouldn't trials from each session be treated as independent
%(one corr per session)?

corrOutputTable= table;
indOutput=1; %cumulative index for correlation output (1 per timestamp per stage per subject)

data= corrInputTable;

allStages= unique(data.stage);

allTimestamps= unique(data.timeLock);

subjects= unique(data.subject);

for thisStage= 1:numel(allStages)

    ind= [];
    
%     % 2023-08-28 technically indexing error here. fine so long as all
%     stages present. Fixed:
%     ind= data.stage==thisStage;
    ind= data.stage==(allStages(thisStage));
    
    data2= data(ind,:);
    
    for subj= 1:numel(subjects)

        ind= [];
        ind= strcmp(data2.subject, subjects{subj});

        data3= data2(ind,:);
        
        for ts= 1:numel(allTimestamps)
                    
            ind= [];
            ind= data3.timeLock==allTimestamps(ts);
            
            data4= data3(ind,:);
            
            if ~isempty(data4)
                %-- Now data has been subset, run correlation.

                %-Ordered latency

                %dynamic, switch between periDS and periDSpox
                
                y1var= 'DSblue'; 
%                 y1var= 'DSbluePox';
                
%                 y1= data4.DSblue; 
%                 y1= data4.DSbluePox; 
                y1=[];
                y1= data4.(y1var); 

                y2= data4.loxDSrelCountAllThisTrial;

                rhoBlue=[]; pvalBlue=[];      

                [rhoBlue, pvalBlue]= corr(y1, y2, 'Rows', 'Complete'); %Complete= ignore nan rows

                 %-Shuffled latency

%                 y1= data4.DSblue; 
%                 y1= data4.DSbluePox; 
                y1=[];
                y1= data4.(y1var);

                y2= data4.loxDSrelCountAllThisTrialShuffled;

                rhoBlueShuffled=[]; pvalBlueShuffled=[];      

                [rhoBlueShuffled, pvalBlueShuffled]= corr(y1, y2, 'Rows', 'Complete'); %Complete= ignore nan rows

                %save actual mean lick count for plotting overlay
                lickCountMean= [];
                lickCountMean= nanmean(data4.loxDSrelCountAllThisTrial);
                
                %save mean PE latency for plotting overlay
                poxDSrelMean=[];
                poxDSrelMean= nanmean(data4.poxDSrel);
                
                %save mean lick latency for plotting overlay
                loxDSrelMean=[];
                loxDSrelMean= nanmean(data4.loxDSrel);
                
                loxDSpoxRelMean=[];
                loxDSpoxRelMean= nanmean(data4.loxDSpoxRel);
                                
                
%                 lick = periEventTable.loxDSrelAllThisTrial{1,1}
                
                %assign data to output table
                metaColumns= ["stage", "subject", "timeLock"];

                corrOutputTable(indOutput,metaColumns)= data4(1, metaColumns);

                corrOutputTable(indOutput,"rhoBlue")= table(rhoBlue); 
                corrOutputTable(indOutput,"pvalBlue")= table(pvalBlue); 
                corrOutputTable(indOutput,"rhoBlueShuffled")= table(rhoBlueShuffled); 
                corrOutputTable(indOutput,"pvalBlueShuffled")= table(pvalBlueShuffled); 

                corrOutputTable(indOutput,"poxDSrelMean")= table(poxDSrelMean);
                
                corrOutputTable(indOutput,"lickCountMean")= table(lickCountMean);
                corrOutputTable(indOutput,"loxDSrelMean")= table(loxDSrelMean);
                corrOutputTable(indOutput,"loxDSpoxRelMean")= table(loxDSpoxRelMean);

%                 % save (mean) input signals too for easy plotting
%                     %y1 represents pooled FP values for this timestamp from
%                     %all trials from this stage from this subject
                corrOutputTable(indOutput, "y1Mean")= table(nanmean(y1));
                
                
                % 2023-08-29 seeing DS correlation, but not PE
                % correlation... possible that + and - corr are flattening
                % to zero?
                % try saving/viewing all of the y1 and y2?
                
                
                indOutput= indOutput+1;  
                
%                 
% %                 %Debugging- viz
%                 figure;
%                 hold on;
%                 subplot(2,1,1);
%                 scatter(y1,y2);
%                 title('corr input');
                
            end
            

        end
        
        
        %TODO: restrict saving to 1 observation ? Could subset first of
        %each fileID after saving

              
        
    
    end %end subj loop

    
end %end stage loop



%% stack for real vs shuffled

%-- Rho ~Time , signalType, (1|subject)

ind=[];
ind= (corrOutputTable.stage==stagesToPlot);

data= corrOutputTable(ind,:);

data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');



%% ------ Visualize Output of latency correlation ---------

%alpha threshold (to plot only significant data)
alphaThreshold= 0.05;

%% Plot of corrCoef by timestamp (by stage)
% 
% data= latencyCorrOutputTable(latencyCorrOutputTable.pvalBlue<=alphaThreshold,:);
% 
% figure();
% clear i;
% 
% % i= gramm('x', data.timeLock, 'y', data.rhoBlue, 'lightness', data.subject);
% i= gramm('x', data.timeLock, 'y', data.rhoBlue, 'color', data.subject);
% 
% 
% i.facet_wrap(data.stage);
% 
% i.geom_point()
% i.stat_summary('type','sem','geom','area');
% 
% i.draw()
% 
%     %btwn subj mean
% i.update('x', data.timeLock, 'y', data.rhoBlue, 'color', [], 'lightness', []);
% i.stat_summary('type','sem','geom','area');
% 
% i.set_color_options('chroma', 10);
% 
% 
% i.axe_property('YLim',[-1,1]);
% titleFig= strcat(subjMode,'-allSubjects-latencyCorrelation-blue-actual-DS');
% i.set_title(titleFig);
% i.set_names('x','time from DS (s)','y','rho (465nm)','color','subject', 'column', 'stage');
% 
% i.draw();
% 
% saveFig(gcf, figPath, titleFig figFormats)
% 
% %% -----Shuffled data plot
% 
% data= latencyCorrOutputTable;
% 
% figure();
% clear i;
% 
% % i= gramm('x', data.timeLock, 'y', data.rhoBlueShuffled, 'lightness', data.subject);
% i= gramm('x', data.timeLock, 'y', data.rhoBlueShuffled, 'color', data.subject);
% 
% 
% i.facet_wrap(data.stage);
% 
% i.stat_summary('type','sem','geom','area');
% 
% i.draw()
% 
%     %btwn subj mean
% i.update('x', data.timeLock, 'y', data.rhoBlueShuffled, 'color', [], 'lightness', []);
% i.stat_summary('type','sem','geom','area');
% 
% i.set_color_options('chroma', 10);
% 
% 
% i.axe_property('YLim',[-1,1]);
% titleFig= strcat(subjMode,'-allSubjects-latencyCorrelation-blue-Shuffled-DS');
% i.set_title(titleFig);
% i.set_names('x','time from DS (s)','y','rho (465nm)','color','subject', 'column', 'stage');
% 
% i.draw();
% 
% saveFig(gcf, figPath, titleFig figFormats)


%% -- plot only coefficients with Pval < threshold
% 
% ind=[];
% ind= (latencyCorrOutputTable.stage==stagesToPlot);
% 
% data= latencyCorrOutputTable(ind,:);
% 
% 
% %stack table to make signalType (ordered vs shuffled) variable for faceting
% data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');
% 
% 
% %replace non-significant rhos with nan
% data(data.pvalBlue>=alphaThreshold, 'periCueRho')= table(nan);
% data(data.pvalBlueShuffled>=alphaThreshold, 'periCueRho')= table(nan);
% 
% 
% figure();
% clear i;
% 
%     %-individual subj lines
% % i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', data.subject);
% i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder);
% 
% 
% i.stat_summary('type','sem','geom','area');
% 
% % i().set_color_options('lightness_range', lightnessRangeSubj) 
% % i().set_line_options('base_size', linewidthSubj)
% 
% i().set_color_options('map', cmapSubj) 
% i().set_line_options('base_size', linewidthSubj); 
% 
% 
% i.draw();
% 
%     %-between subj mean+sem
% i.update('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', []);
% 
% i.stat_summary('type','sem','geom','area');
% 
% 
% i().set_color_options('map', cmapGrand) 
% i().set_line_options('base_size', linewidthGrand); 
% 
% % i().set_color_options('lightness_range', lightnessRangeGrand); 
% % i().set_line_options('base_size', linewidthGrand); 
% 
% 
% i.axe_property('YLim',[-1,1]);
% % titleFig= strcat(subjMode,'-allSubjects-latencyCorrelation-Figure3-shuffleVsOrderSignif-DS');
% titleFig= strcat('-allSubjects-latencyCorrelation-Figure3-shuffleVsOrderSignif-DS');
% 
% 
% i.set_title(titleFig);
% i.set_names('x','time from DS (s)','y','rho (465nm)','color','latencyOrder');
% 
% i.draw();
% % saveFig(gcf, figPath, titleFig figFormats);

%% make plot simlar to manuscript fig 3f

%- Aesthetics
yLimCorrelation= [-0.5, 0.5];
% xLimCorrelation= [-2,5];
% xTickCorrelation= [-2:2:5];

xLimCorrelation= [-2,10];
xTickCorrelation= [-2:1:10];


% Shuffled vs. Ordered data stat comparison… 2 way anova or lmm for shuffled vs real signal 
% (is there interaction with time; if not then no need for single timestamp comparisons) 


% % --Line plot of coefficients over time Subplot ordered vs shuffled
% % stagesToPlot= [5];
% 
% ind=[];
% ind= (corrOutputTable.stage==stagesToPlot);
% 
% data= corrOutputTable(ind,:);

% %stack table to make signalType (ordered vs shuffled) variable for faceting
% data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');


% figure();
clear gCorr; figure;

cmapGrand= cmapBlueGrayGrand;
cmapSubj= cmapBlueGraySubj;


%Don't use Lightness facet since importing to illustrator will make
%grouping a problem ... instead use group

    %-individual subj lines
% i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', data.subject);
gCorr= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'group', data.subject);


gCorr().stat_summary('type','sem','geom','area');

% gLat().set_color_options('lightness_range', lightnessRangeSubj) 
gCorr().set_color_options('map', cmapSubj) 

gCorr().set_line_options('base_size', linewidthSubj)

gCorr().no_legend();


% % % set parent uiPanel in overall figure
% gCorr().set_parent(p6);

%- first draw call
gCorr().draw();

    %-between subj mean+sem
gCorr().update('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', [], 'group', []);

gCorr().stat_summary('type','sem','geom','area');


% gLat().set_color_options('lightness_range', lightnessRangeGrand); 
gCorr().set_color_options('map', cmapGrand) 

gCorr().set_line_options('base_size', linewidthGrand); 


titleFig= strcat('Correlation of Lick Count per Trial with ', y1var);


gCorr().set_title(titleFig);
gCorr().set_names('x','Time from event onset (s)','y','Correlation Coefficient','color','latencyOrder');
gCorr().no_legend();

if strcmp(y1var, 'DSblue')
    gCorr().geom_vline('xintercept', 0, 'style', 'b--', 'linewidth',linewidthReference); % line @ 0 (event onset)
    
    %add vertical line for mean PE latency
    peMean= [];
    peMean= nanmean(data.poxDSrelMean);
    gCorr().geom_vline('xintercept', peMean, 'style', 'm--', 'linewidth',linewidthReference); % line @ 0 (event onset)

    
    %add vertical line overlay for mean Lick latency
    lickMean= [];
    lickMean= nanmean(data.loxDSrelMean);
    gCorr().geom_vline('xintercept', lickMean, 'style', 'k-.', 'linewidth',linewidthReference); % line @ mean 
    
elseif strcmp(y1var, 'DSbluePox')
    gCorr().geom_vline('xintercept', 0, 'style', 'm--', 'linewidth',linewidthReference); % line @ 0 (event onset)
    
    %add vertical line overlay for mean Lick latency
    lickMean= [];
    lickMean= nanmean(data.loxDSpoxRelMean);
    gCorr().geom_vline('xintercept', lickMean, 'style', 'k-.', 'linewidth',linewidthReference); % line @ mean 
    
end
    
    
%-set limits
gCorr().axe_property('YLim',yLimCorrelation);
gCorr().axe_property('XLim',xLimCorrelation);
gCorr().axe_property('XTick',xTickCorrelation);


gCorr().axe_property('YLim',[-0.5,0.5]);
% gCorr().axe_property('xLim',[-2,5]); %capping at +5s

gCorr().draw();

titleFig='vp-vta_supplement_fig3_correlation_lickCount_x_';

titleFig= strcat(titleFig, y1var);

saveFig(gcf, figPath, titleFig, figFormats);


%% Plot input to correlation? 

%% -- todo plot 'pooled/mean' y1 at each timestamp by subj



% figure();
clear gCorr; figure;

cmapGrand= cmapBlueGrayGrand;
cmapSubj= cmapBlueGraySubj;


%Don't use Lightness facet since importing to illustrator will make
%grouping a problem ... instead use group

    %-individual subj lines
% i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', data.subject);
gCorr= gramm('x', data.timeLock, 'y', data.y1Mean, 'color', data.latencyOrder, 'group', data.subject);


gCorr().stat_summary('type','sem','geom','area');

% gLat().set_color_options('lightness_range', lightnessRangeSubj) 
gCorr().set_color_options('map', cmapSubj) 

gCorr().set_line_options('base_size', linewidthSubj)

gCorr().no_legend();


% % % set parent uiPanel in overall figure
% gCorr().set_parent(p6);

%- first draw call
gCorr().draw();

    %-between subj mean+sem
gCorr().update('x', data.timeLock, 'y', data.y1Mean, 'color', data.latencyOrder, 'lightness', [], 'group', []);

gCorr().stat_summary('type','sem','geom','area');


% gLat().set_color_options('lightness_range', lightnessRangeGrand); 
gCorr().set_color_options('map', cmapGrand) 

gCorr().set_line_options('base_size', linewidthGrand); 


titleFig= strcat('Correlation Input of Lick Count per Trial with ', y1var);


gCorr().set_title(titleFig);
gCorr().set_names('x','Time from event onset (s)','y',y1var,'color','latencyOrder');
gCorr().no_legend();

if strcmp(y1var, 'DSblue')
    gCorr().geom_vline('xintercept', 0, 'style', 'b--', 'linewidth',linewidthReference); % line @ 0 (event onset)
    
    %add vertical line for mean PE latency
    peMean= [];
    peMean= nanmean(data.poxDSrelMean);
    gCorr().geom_vline('xintercept', peMean, 'style', 'm--', 'linewidth',linewidthReference); % line @ 0 (event onset)

    
    %add vertical line overlay for mean Lick latency
    lickMean= [];
    lickMean= nanmean(data.loxDSrelMean);
    gCorr().geom_vline('xintercept', lickMean, 'style', 'k-.', 'linewidth',linewidthReference); % line @ mean 
    
elseif strcmp(y1var, 'DSbluePox')
    gCorr().geom_vline('xintercept', 0, 'style', 'm--', 'linewidth',linewidthReference); % line @ 0 (event onset)
    
    %add vertical line overlay for mean Lick latency
    lickMean= [];
    lickMean= nanmean(data.loxDSpoxRelMean);
    gCorr().geom_vline('xintercept', lickMean, 'style', 'k-.', 'linewidth',linewidthReference); % line @ mean 
    
end
    
    
%-set limits
% gCorr().axe_property('YLim',yLimTraces);
gCorr().axe_property('XLim',xLimCorrelation);
gCorr().axe_property('XTick',xTickCorrelation);


% gCorr().axe_property('YLim',[-0.5,0.5]);
% gCorr().axe_property('xLim',[-2,5]); %capping at +5s

gCorr().draw();

% titleFig='vp-vta_supplement_fig3_correlation_INPUT_lickCount_x_';

% titleFig= strcat(titleFig, y1var);


%% -- Viz of lick count by pe latency

% subset data
data2=[];
data2= corrInputTable;

% subset to 1 obsv per trial

%-- subset to one observation per trial
%use findgroups to groupby trialIDcum and subset to 1 observation per
groupIDs= [];
groupIDs= findgroups(data2.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

data3=table(); 

for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
    
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= data2(ind,:);

    %now cumulative count of observations in this group
    %make default value=1 for each, and then cumsum() to get cumulative count
    thisGroup(:,'cumcount')= table(1);
    thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
    
    %save only single observation per trial (get first value)
    %get observation where timeLock==0
    ind= [];
    ind= thisGroup.timeLock==0;
    
    data3(thisGroupID,:)= thisGroup(ind,:);
    
end 

%redefine data table
data2= table();
data2= data3;
data3=data2;

% heat plot might help resolve density here...

%interesting. relationship between lick count and latency is mostly linear
%but there are some notable low lick count trials event when the latency to first lick is
%quick.

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
g(1,1).set_line_options('base_size',linewidthSubj);
% g(1,1).facet_grid(data3.subject,[]);

test=[];
test= groupsummary(data3, ["stage","subject"], 'mean', ["loxDSrelCountAllThisTrial"]);

g(1,1).geom_point();
% g(1,1).set_color_options('map', cmapSubj) 


g(1,1).set_title('Lick Count vs PE latency');
g(1,1).set_names('y', 'Lick Count', 'x', 'PE latency');

%first draw
g(1,1).draw

% % Subjects- simple within-subjects glm pooled across trials
% group= data3.subject;
% g(1,1).update('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(1,1).stat_glm('disp_fit', true, 'geom', 'line');
% g(1,1).set_line_options('base_size',linewidthGrand);
% g(1,1).no_legend;
% g(1,1).set_color_options('map', cmapGrand) 


% grand- simple glm pooled across trials & subjects
group= [];
g(1,1).update('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'color', [], 'group', group);
g(1,1).stat_glm('disp_fit', true, 'geom', 'line');
g(1,1).set_line_options('base_size',linewidthGrand);
g(1,1).no_legend;
g(1,1).set_color_options('chroma', chromaLineSubj); 


%last draw
g(1,1).draw();

% save figure
titleFig='vp-vta_supplement_lickCount_x_PElatency';
saveFig(gcf, figPath, titleFig, figFormats);

%% - other viz of lick count vs pe latency? 
% clear g; figure;
% 
% %-individual trial scatter by subj
% % group= data3.trialIDcum;
% % g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% group= data3.subject;
% g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel,'group', group);
% 
% % g(1,1).facet_grid(data3.subject,[]);
% 
% 
% %heatmap
% g(1,1).stat_bin2d('geom','image');
% 
% 
% g(1,1).set_title('Lick Count vs PE latency');
% g(1,1).set_names('y', 'Lick Count', 'x', 'PE latency');
% 
% %first draw
% g(1,1).draw


%% plot input signals

% Subset data
data= corrInputTable;


% for binning and faceting copy code from fp_manuscript_session_correlation

%initialize columns
data(:,'lickCountBin')= table(nan);
data(:,'lickCountBinEdge')= table(nan);

%----convert lick Count into n bins 
%quick and dirty binning using discretize() 

nBins=[];
nBins= 5;

y= [];
e= [];

[y, e]= discretize(data.loxDSrelCountAllThisTrial, nBins);

data.lickCountBin= y;

%save labels of bin edges too 
for bin= 1:numel(e)-1
    
    ind= [];
    ind= data.lickCountBin== bin;
    
   data(ind, "lickCountBinEdge")= table(e(bin)); 
end


%-----
% Vizualize periDSPE, faceted by lick count bin



% ---- Add Plots of peri-event mean traces

%- subset data (relying on above)
%- note: keep full time series for viz
data= data;

clear gPeriEvent

%- aesthetics
xlimTraces= [-2,10];
ylimTraces= [-2,5];

% yTickTraces= [0:2:10] 
xTickTraces= [-2:2:10]; % ticks every 2s
% xTickTraces= [-2:1:10]; % ticks every 1s

xTickHeat= [-4:2:10]; %expanded to capture longer PE latencies
xLimHeat= [-4,10];

yLimCorrelation= [-0.5, 0.5];
xLimCorrelation= [-2,5];
xTickCorrelation= [-2:2:5];

errorBar='sem';




%stack() the data by eventType
data3= data;

%all 3 events:
data3= stack(data3, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

% % DS and PE only
% data3= stack(data3, {'DSblue', 'DSbluePox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
% % %flip the color order so that PE is consistent with fig2 (purple)
% % % cmapGrand= cmapPEGrand;
% % % cmapSubj= cmapPESubj;
% cmapGrand= flip(cmapPEGrand);
% cmapSubj= flip(cmapPESubj);

% - rename eventTypes so auto faceting are in order of events
%manually relabel trialType for clarity
%convert categorical to string then search 
% data3(:,"eventType")= {''};

 %make labels matching each 'trialType' and loop thru to search/match
trialTypes= {'DSblue', 'DSbluePox', 'DSblueLox'};
trialTypeLabels= {'1_Peri-DS','2_Peri-PE', '3_Peri-Lick'};

for thisTrialType= 1:numel(trialTypes)
    ind= [];
    
    ind= strcmp(string(data3.eventType), trialTypes(thisTrialType));

    data3(ind, 'eventType')= {trialTypeLabels(thisTrialType)};
    
end


% % - All trials?
% group= data3.DStrialIDcum;
% 
% figure;
% 
% 
% clear gPeriEvent;
% 
% % gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);
% 
% gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.subject, 'group', group);
% 
% 
% gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);
% % gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.subject);
% 
% 
% % gPeriEvent(1,1).geom_line();
% 
% gPeriEvent(1,1).stat_summary('type','sem','geom','area');
% 
% gPeriEvent.draw();


% ---- 2023-04-06
 %Mean/SEM update
 %instead of all trials, simplify to mean observation per subject
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
% data3= groupsummary(data3, ["subject","stage","eventType", "timeLock"], "mean",["periEventBlue"]);

data3= groupsummary(data3, ["subject","stage", "lickCountBinEdge", "eventType", "timeLock"], "mean",["periEventBlue"]);


% making new field with original column name to work with rest of old code bc 'mean_' is added 
data3.periEventBlue= data3.mean_periEventBlue;


% - Individual Subj lines
group= data3.subject;

figure;

clear gPeriEvent;

gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);


% gPeriEvent(1,1).geom_line();
gPeriEvent(1,1).stat_summary('type',errorBar,'geom','line');


% i2.set_title(titleFig); 
gPeriEvent(1,1).set_color_options('map',cmapSubj);
gPeriEvent(1,1).set_line_options('base_size',linewidthSubj);
gPeriEvent(1,1).set_names('x','Time from event (s)','y','GCaMP (Z-Score)','color','Event Type', 'column', 'Event Type', 'row', 'Trial Licks (Binned)');

gPeriEvent(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

%remove legend
gPeriEvent(1,1).no_legend();

%-set limits
gPeriEvent(1,1).axe_property('YLim',ylimTraces);
gPeriEvent(1,1).axe_property('XLim',xlimTraces);
gPeriEvent(1,1).axe_property('XTick',xTickTraces);

% gPeriEvent(1,1).axe_property('XLim',xLimHeat);
% gPeriEvent(1,1).axe_property('XTick',xTickHeat);


% % % % set parent uiPanel in overall figure
% gPeriEvent(1,1).set_parent(p2);
% gPeriEvent(1,1).set_parent(p1);


%- First Draw call
gPeriEvent(1,1).draw();

% -- Between subjects mean+SEM 
group=[]
gPeriEvent(1,1).update('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1).stat_summary('type',errorBar,'geom','area');

gPeriEvent(1,1).set_color_options('map',cmapGrand);
gPeriEvent(1,1).set_line_options('base_size',linewidthGrand);


%remove legend
gPeriEvent(1,1).no_legend();


%- vline at 0 
gPeriEvent(1,1).geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 


% %- save final draw til end
gPeriEvent(1,1).draw();



%% -- peri event plots as above but stacked 

% color= lick count binned

% - Individual Subj lines
group= data3.subject;

figure;

clear gPeriEvent;

gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.lickCountBinEdge, 'group', group);

% gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);
gPeriEvent(1,1).facet_grid([],data3.eventType);
% gPeriEvent(1,1).facet_grid(data3.subject,data3.eventType);


% gPeriEvent(1,1).geom_line();
% gPeriEvent(1,1).stat_summary('type',errorBar,'geom','line');


% % i2.set_title(titleFig); 
% gPeriEvent(1,1).set_color_options('map',cmapSubj);
gPeriEvent(1,1).set_line_options('base_size',linewidthSubj);
gPeriEvent(1,1).set_names('x','Time from event (s)','y','GCaMP (Z-Score)','color','Lick Count (binned)', 'column', 'Event Type', 'row', 'Trial Licks (Binned)');

gPeriEvent(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

% %remove legend
% gPeriEvent(1,1).no_legend();

%-set limits
gPeriEvent(1,1).axe_property('YLim',ylimTraces);
gPeriEvent(1,1).axe_property('XLim',xlimTraces);
gPeriEvent(1,1).axe_property('XTick',xTickTraces);

% gPeriEvent(1,1).axe_property('XLim',xLimHeat);
% gPeriEvent(1,1).axe_property('XTick',xTickHeat);


% % % % set parent uiPanel in overall figure
% gPeriEvent(1,1).set_parent(p2);
% gPeriEvent(1,1).set_parent(p1);


%- First Draw call
gPeriEvent(1,1).draw();

% -- Between subjects mean+SEM 
group=[]
gPeriEvent(1,1).update('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.lickCountBinEdge, 'group', group);

gPeriEvent(1,1).stat_summary('type',errorBar,'geom','area');

% gPeriEvent(1,1).set_color_options('map',cmapGrand);
gPeriEvent(1,1).set_line_options('base_size',linewidthGrand);


%remove legend
gPeriEvent(1,1).no_legend();


%- vline at 0 
gPeriEvent(1,1).geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 


% %- save final draw til end
gPeriEvent(1,1).draw();



%% plot input signals- closer individual trial examination?

% Subset data
data= corrInputTable;


% for binning and faceting copy code from fp_manuscript_session_correlation

%initialize columns
data(:,'lickCountBin')= table(nan);
data(:,'lickCountBinEdge')= table(nan);

%----convert lick Count into n bins 
%quick and dirty binning using discretize() 

nBins=[];
nBins= 5;

y= [];
e= [];

[y, e]= discretize(data.loxDSrelCountAllThisTrial, nBins);

data.lickCountBin= y;

%save labels of bin edges too 
for bin= 1:numel(e)-1
    
    ind= [];
    ind= data.lickCountBin== bin;
    
   data(ind, "lickCountBinEdge")= table(e(bin)); 
end


%-----
% Vizualize periDSPE, faceted by lick count bin



% ---- Add Plots of peri-event mean traces

%- subset data (relying on above)
%- note: keep full time series for viz
data= data;

clear gPeriEvent

%- aesthetics
xlimTraces= [-2,10];
ylimTraces= [-2,5];

% yTickTraces= [0:2:10] 
xTickTraces= [-2:2:10]; % ticks every 2s
% xTickTraces= [-2:1:10]; % ticks every 1s

xTickHeat= [-4:2:10]; %expanded to capture longer PE latencies
xLimHeat= [-4,10];

yLimCorrelation= [-0.5, 0.5];
xLimCorrelation= [-2,5];
xTickCorrelation= [-2:2:5];

errorBar='sem';




%stack() the data by eventType
data3= data;

%all 3 events:
data3= stack(data3, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

% % DS and PE only
% data3= stack(data3, {'DSblue', 'DSbluePox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
% % %flip the color order so that PE is consistent with fig2 (purple)
% % % cmapGrand= cmapPEGrand;
% % % cmapSubj= cmapPESubj;
% cmapGrand= flip(cmapPEGrand);
% cmapSubj= flip(cmapPESubj);

% - rename eventTypes so auto faceting are in order of events
%manually relabel trialType for clarity
%convert categorical to string then search 
% data3(:,"eventType")= {''};

 %make labels matching each 'trialType' and loop thru to search/match
trialTypes= {'DSblue', 'DSbluePox', 'DSblueLox'};
trialTypeLabels= {'1_Peri-DS','2_Peri-PE', '3_Peri-Lick'};

for thisTrialType= 1:numel(trialTypes)
    ind= [];
    
    ind= strcmp(string(data3.eventType), trialTypes(thisTrialType));

    data3(ind, 'eventType')= {trialTypeLabels(thisTrialType)};
    
end


% - All trials?
group= data3.DStrialIDcum;

figure;


clear gPeriEvent;

% gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.subject, 'group', group);

% gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'group', group);

gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);

% gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);
% gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.subject);

% gPeriEvent(1,1).facet_grid(data3.subject,data3.eventType);


% gPeriEvent(1,1).stat_bin2d('geom','image');


gPeriEvent(1,1).geom_line();

% gPeriEvent(1,1).stat_summary('type','sem','geom','area');

gPeriEvent.draw();




% ---- 2023-04-06
 %Mean/SEM update
 %instead of all trials, simplify to mean observation per subject
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
% data3= groupsummary(data3, ["subject","stage","eventType", "timeLock"], "mean",["periEventBlue"]);

data3= groupsummary(data3, ["subject","stage", "lickCountBinEdge", "eventType", "timeLock"], "mean",["periEventBlue"]);


% making new field with original column name to work with rest of old code bc 'mean_' is added 
data3.periEventBlue= data3.mean_periEventBlue;


% - Individual Subj lines
group= data3.subject;

figure;

clear gPeriEvent;

gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);


% gPeriEvent(1,1).geom_line();
gPeriEvent(1,1).stat_summary('type',errorBar,'geom','line');


% i2.set_title(titleFig); 
gPeriEvent(1,1).set_color_options('map',cmapSubj);
gPeriEvent(1,1).set_line_options('base_size',linewidthSubj);
gPeriEvent(1,1).set_names('x','Time from event (s)','y','GCaMP (Z-Score)','color','Event Type', 'column', 'Event Type', 'row', 'Trial Licks (Binned)');

gPeriEvent(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

%remove legend
gPeriEvent(1,1).no_legend();

%-set limits
gPeriEvent(1,1).axe_property('YLim',ylimTraces);
gPeriEvent(1,1).axe_property('XLim',xlimTraces);
gPeriEvent(1,1).axe_property('XTick',xTickTraces);

% gPeriEvent(1,1).axe_property('XLim',xLimHeat);
% gPeriEvent(1,1).axe_property('XTick',xTickHeat);


% % % % set parent uiPanel in overall figure
% gPeriEvent(1,1).set_parent(p2);
% gPeriEvent(1,1).set_parent(p1);


%- First Draw call
gPeriEvent(1,1).draw();

% -- Between subjects mean+SEM 
group=[]
gPeriEvent(1,1).update('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1).stat_summary('type',errorBar,'geom','area');

gPeriEvent(1,1).set_color_options('map',cmapGrand);
gPeriEvent(1,1).set_line_options('base_size',linewidthGrand);


%remove legend
gPeriEvent(1,1).no_legend();


%- vline at 0 
gPeriEvent(1,1).geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 


% %- save final draw til end
gPeriEvent(1,1).draw();





