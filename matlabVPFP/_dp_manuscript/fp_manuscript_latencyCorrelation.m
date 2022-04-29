% replicate fp_latencyCorrelation with periEventTable

%% Plot settings 

%thin, light lines for individual subj
linewidthSubj= 0.5;
lightnessRangeSubj= [100,100];

%dark, thick lines for between subj grand mean
linewidthGrand= 1.5;
lightnessRangeGrand= [10,10];


%% TODO: subset sessions for analysis

data= periEventTable;

latencyCorrInputTable= data;

%% Exclude FP signals following PE

  %-- DS trials
  
%signal columns (what to replace with nan)
y=[];
y= ["DSblue", "DSpurple", "DSbluepox", "DSpurplePox"];


%replace signal following first PE for each trial with nan
ind=[];
ind= data.timeLock > data.poxDSrel;

latencyCorrInputTable(ind, y) = table(nan);

%% TODO: Add Shuffled Data to set (shuffled 465nm per trial)
  %-- DS trials
  
%signal columns (what to shuffle)
y=[];
y= ["DSblue"];

% shuffle independently for each trial
data= latencyCorrInputTable;

allTrials= unique(data.DStrialIDcum);

for trial= 1:numel(allTrials)
    
    ind= [];
    ind= data.DStrialIDcum==allTrials(trial);
    
    data2= data(ind, :);
    
    % after subsetting data for this trial, shuffle using randperm to make
    % random index
    ind= [];
    ind= randperm(numel(data2.(y)));
    
    data2(:,"DSblueShuffled")= data2(ind,y);
    
    
    %assign back to original table
    ind= [];
%     ind= find(data.index==data2.index);
    ind= ismember(data.index,data2.index);

    
    latencyCorrInputTable(ind,"DSblueShuffled")= data2(:, "DSblueShuffled");

end
    
%% Run correlation for each timestamp

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

latencyCorrOutputTable= table;
indOutput=1; %cumulative index for correlation output (1 per timestamp per stage per subject)

data= latencyCorrInputTable;

allStages= unique(data.stage);

allTimestamps= unique(data.timeLock);

for thisStage= 1:numel(allStages)

    ind= [];
    ind= data.stage==thisStage;
    
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

                %-Experimental fp signal

                y1= data4.DSblue; 
                y2= data4.poxDSrel;

                rhoBlue=[]; pvalBlue=[];      

                [rhoBlue, pvalBlue]= corr(y1, y2, 'Rows', 'Complete'); %Complete= ignore nan rows

                 %-Shuffled fp signal

                y1= data4.DSblueShuffled; 
                y2= data4.poxDSrel;

                rhoBlueShuffled=[]; pvalBlueShuffled=[];      

                [rhoBlueShuffled, pvalBlueShuffled]= corr(y1, y2, 'Rows', 'Complete'); %Complete= ignore nan rows

                
                
                %assign data to output table
                metaColumns= ["stage", "subject", "timeLock"];

                latencyCorrOutputTable(indOutput,metaColumns)= data4(1, metaColumns);

                latencyCorrOutputTable(indOutput,"rhoBlue")= table(rhoBlue); 
                latencyCorrOutputTable(indOutput,"pvalBlue")= table(pvalBlue); 
                latencyCorrOutputTable(indOutput,"rhoBlueShuffled")= table(rhoBlueShuffled); 
                latencyCorrOutputTable(indOutput,"pvalBlueShuffled")= table(pvalBlueShuffled); 


                indOutput= indOutput+1;            
            end
            

        end
        
        
        %TODO: restrict saving to 1 observation ? Could subset first of
        %each fileID after saving

              
        %-TODO: Shuffled control fp signal
        
    
    end %end subj loop

    
end %end stage loop


%% ------ Visualize Output of latency correlation ---------

%alpha threshold (to plot only significant data)
alphaThreshold= 0.05;

%% Plot of corrCoef by timestamp (by stage)

data= latencyCorrOutputTable(latencyCorrOutputTable.pvalBlue<=alphaThreshold,:);

figure();
clear i;

% i= gramm('x', data.timeLock, 'y', data.rhoBlue, 'lightness', data.subject);
i= gramm('x', data.timeLock, 'y', data.rhoBlue, 'color', data.subject);


i.facet_wrap(data.stage);

i.geom_point()
i.stat_summary('type','sem','geom','area');

i.draw()

    %btwn subj mean
i.update('x', data.timeLock, 'y', data.rhoBlue, 'color', [], 'lightness', []);
i.stat_summary('type','sem','geom','area');

i.set_color_options('chroma', 10);


i.axe_property('YLim',[-1,1]);
title= strcat(subjMode,'-allSubjects-latencyCorrelation-blue-actual-DS');
i.set_title(title);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','subject', 'column', 'stage');

i.draw();

saveFig(gcf, figPath, title, figFormats)

%% -----Shuffled data plot

data= latencyCorrOutputTable;

figure();
clear i;

% i= gramm('x', data.timeLock, 'y', data.rhoBlueShuffled, 'lightness', data.subject);
i= gramm('x', data.timeLock, 'y', data.rhoBlueShuffled, 'color', data.subject);


i.facet_wrap(data.stage);

i.stat_summary('type','sem','geom','area');

i.draw()

    %btwn subj mean
i.update('x', data.timeLock, 'y', data.rhoBlueShuffled, 'color', [], 'lightness', []);
i.stat_summary('type','sem','geom','area');

i.set_color_options('chroma', 10);


i.axe_property('YLim',[-1,1]);
title= strcat(subjMode,'-allSubjects-latencyCorrelation-blue-Shuffled-DS');
i.set_title(title);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','subject', 'column', 'stage');

i.draw();

saveFig(gcf, figPath, title, figFormats)


%% -------------------Manuscript Figure 3: Correlation of FP signal with Latency--------------------------

% Shuffled vs. Ordered data stat comparison… 2 way anova or lmm for shuffled vs real signal 
% (is there interaction with time; if not then no need for single timestamp comparisons) 


% --Line plot of coefficients over time Subplot ordered vs shuffled
stagesToPlot= [5];

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);

%stack table to make signalType (ordered vs shuffled) variable for faceting
data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'signalType', 'NewDataVariableName', 'periCueRho');


figure();
clear i;

    %-individual subj lines
i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.signalType, 'lightness', data.subject);

i.stat_summary('type','sem','geom','area');

i().set_color_options('lightness_range', lightnessRangeSubj) 
i().set_line_options('base_size', linewidthSubj)
i.draw();

    %-between subj mean+sem
i.update('x', data.timeLock, 'y', data.periCueRho, 'color', data.signalType, 'lightness', []);

i.stat_summary('type','sem','geom','area');


i().set_color_options('lightness_range', lightnessRangeGrand); 
i().set_line_options('base_size', linewidthGrand); 


i.axe_property('YLim',[-1,1]);
title= strcat(subjMode,'-allSubjects-latencyCorrelation-Figure3-shuffleVsOrder-DS');


i.set_title(title);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','signalType');

i.draw();
saveFig(gcf, figPath, title, figFormats);


%% -- plot only coefficients with Pval < threshold

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);


%stack table to make signalType (ordered vs shuffled) variable for faceting
data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'signalType', 'NewDataVariableName', 'periCueRho');


%replace non-significant rhos with nan
data(data.pvalBlue>=alphaThreshold, 'periCueRho')= table(nan);
data(data.pvalBlueShuffled>=alphaThreshold, 'periCueRho')= table(nan);


figure();
clear i;

    %-individual subj lines
i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.signalType, 'lightness', data.subject);

i.stat_summary('type','sem','geom','area');

i().set_color_options('lightness_range', lightnessRangeSubj) 
i().set_line_options('base_size', linewidthSubj)
i.draw();

    %-between subj mean+sem
i.update('x', data.timeLock, 'y', data.periCueRho, 'color', data.signalType, 'lightness', []);

i.stat_summary('type','sem','geom','area');


i().set_color_options('lightness_range', lightnessRangeGrand); 
i().set_line_options('base_size', linewidthGrand); 


i.axe_property('YLim',[-1,1]);
title= strcat(subjMode,'-allSubjects-latencyCorrelation-Figure3-shuffleVsOrderSignif-DS');


i.set_title(title);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','signalType');

i.draw();
saveFig(gcf, figPath, title, figFormats);

%% -- Statistical comparison (ANOVA) 

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);

% 2 way anova or lmm for shuffled vs real signal 
% (is there interaction with time; if not then no need for single timestamp comparisons) 

%Fit 

% lme= fitlme(data, '

Fit a linear mixed-effects model for miles per gallon in the city, with fixed effects for horsepower, and uncorrelated random effect for intercept and horsepower grouped by the engine type.

lme = fitlme(tbl,'CityMPG~Horsepower+(1|EngineType)+(Horsepower-1|EngineType)');


%% TODO: Time from PE ? (is there ramping prior to PE that is significant? as opposed to cue-elicited?)


%% 
print('latency corr done')
