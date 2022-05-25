% replicate fp_latencyCorrelation with periEventTable


%% TODO: subset sessions for analysis

data= periEventTable;

latencyCorrInputTable= data;

%% Exclude FP signals following PE

  %-- DS trials
  
%signal columns (what to replace with nan)
y=[];
y= ["DSblue", "DSpurple", "DSbluePox", "DSpurplePox"];


%replace signal following first PE for each trial with nan
ind=[];
ind= data.timeLock > data.poxDSrel;

latencyCorrInputTable(ind, y) = table(nan);

%% Add Shuffled Data to set (shuffled latencies per trial)
  %-- DS trials
  
  %initialize col
latencyCorrInputTable(:,"poxDSrelShuffled")= table(nan);
  
  %TODO: just shuffle latencies between trials
data= latencyCorrInputTable;

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
    
     latencyCorrInputTable(ind,'poxDSrelShuffled')= data(ind2(1), 'poxDSrel');  

    
end

% 
% % this works but is pretty slow?
% % speeding up by just shuffling everything for now
% ind= randperm(numel(data.(y)));
% data(:,"DSblueShuffled")= data(ind,y);
% latencyCorrInputTable(:,"DSblueShuffled")= data(:, "DSblueShuffled");
% % 
% 
% for trial= 1:numel(allTrials)
%     
%     ind= [];
%     ind= data.DStrialIDcum==allTrials(trial); %ismember shoudl be faster
%     
%     data2= data(ind, :);
%     
%     % after subsetting data for this trial, shuffle using randperm to make
%     % random index
%     ind= [];
%     ind= randperm(numel(data2.(y)));
%     
%     data2(:,"DSblueShuffled")= data2(ind,y);
%     
%     
%     %assign back to original table
%     ind= [];
% %     ind= find(data.index==data2.index);
%     ind= ismember(data.index,data2.index);
% 
%     latencyCorrInputTable(ind,"DSblueShuffled")= data2(:, "DSblueShuffled");
% 
% end
%   
%   
%   
% %   %-old, shuffled fp signal
% % %signal columns (what to shuffle)
% % y=[];
% % y= ["DSblue"];
% % 
% % 
% % % shuffle independently for each trial
% % data= latencyCorrInputTable;
% % 
% % allTrials= unique(data.DStrialIDcum);
% % 
% % % this works but is pretty slow?
% % % speeding up by just shuffling everything for now
% % ind= randperm(numel(data.(y)));
% % data(:,"DSblueShuffled")= data(ind,y);
% % latencyCorrInputTable(:,"DSblueShuffled")= data(:, "DSblueShuffled");
% % % 
% % % 
% % % for trial= 1:numel(allTrials)
% % %     
% % %     ind= [];
% % %     ind= data.DStrialIDcum==allTrials(trial);
% % %     
% % %     data2= data(ind, :);
% % %     
% % %     % after subsetting data for this trial, shuffle using randperm to make
% % %     % random index
% % %     ind= [];
% % %     ind= randperm(numel(data2.(y)));
% % %     
% % %     data2(:,"DSblueShuffled")= data2(ind,y);
% % %     
% % %     
% % %     %assign back to original table
% % %     ind= [];
% % % %     ind= find(data.index==data2.index);
% % %     ind= ismember(data.index,data2.index);
% % % 
% % %     latencyCorrInputTable(ind,"DSblueShuffled")= data2(:, "DSblueShuffled");
% % % 
% % % end
%     

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

                %-Ordered latency

                y1= data4.DSblue; 
                y2= data4.poxDSrel;

                rhoBlue=[]; pvalBlue=[];      

                [rhoBlue, pvalBlue]= corr(y1, y2, 'Rows', 'Complete'); %Complete= ignore nan rows

                 %-Shuffled latency

                y1= data4.DSblue; 
                y2= data4.poxDSrelShuffled;

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
% title= strcat(subjMode,'-allSubjects-latencyCorrelation-blue-actual-DS');
% i.set_title(title);
% i.set_names('x','time from DS (s)','y','rho (465nm)','color','subject', 'column', 'stage');
% 
% i.draw();
% 
% saveFig(gcf, figPath, title, figFormats)
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
% title= strcat(subjMode,'-allSubjects-latencyCorrelation-blue-Shuffled-DS');
% i.set_title(title);
% i.set_names('x','time from DS (s)','y','rho (465nm)','color','subject', 'column', 'stage');
% 
% i.draw();
% 
% saveFig(gcf, figPath, title, figFormats)


%% -------------------Manuscript Figure 3: Correlation of FP signal with Latency--------------------------

% Shuffled vs. Ordered data stat comparison… 2 way anova or lmm for shuffled vs real signal 
% (is there interaction with time; if not then no need for single timestamp comparisons) 


% --Line plot of coefficients over time Subplot ordered vs shuffled
stagesToPlot= [5];

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);

%stack table to make signalType (ordered vs shuffled) variable for faceting
data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');


figure();
clear i;

    %-individual subj lines
i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', data.subject);

i.stat_summary('type','sem','geom','area');

i().set_color_options('lightness_range', lightnessRangeSubj) 
i().set_line_options('base_size', linewidthSubj)
i.draw();

    %-between subj mean+sem
i.update('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', []);

i.stat_summary('type','sem','geom','area');


i().set_color_options('lightness_range', lightnessRangeGrand); 
i().set_line_options('base_size', linewidthGrand); 


i.axe_property('YLim',[-1,1]);
title= strcat(subjMode,'-allSubjects-latencyCorrelation-Figure3-shuffleVsOrder-DS');


i.set_title(title);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','latencyOrder');

i.draw();
saveFig(gcf, figPath, title, figFormats);


%% -- plot only coefficients with Pval < threshold

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);


%stack table to make signalType (ordered vs shuffled) variable for faceting
data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');


%replace non-significant rhos with nan
data(data.pvalBlue>=alphaThreshold, 'periCueRho')= table(nan);
data(data.pvalBlueShuffled>=alphaThreshold, 'periCueRho')= table(nan);


figure();
clear i;

    %-individual subj lines
i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', data.subject);

i.stat_summary('type','sem','geom','area');

i().set_color_options('lightness_range', lightnessRangeSubj) 
i().set_line_options('base_size', linewidthSubj)
i.draw();

    %-between subj mean+sem
i.update('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', []);

i.stat_summary('type','sem','geom','area');


i().set_color_options('lightness_range', lightnessRangeGrand); 
i().set_line_options('base_size', linewidthGrand); 


i.axe_property('YLim',[-1,1]);
title= strcat(subjMode,'-allSubjects-latencyCorrelation-Figure3-shuffleVsOrderSignif-DS');


i.set_title(title);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','latencyOrder');

i.draw();
saveFig(gcf, figPath, title, figFormats);

%% -- Statistical comparison LME to see if rho differs between shuffled/ordered

%stack for real vs shuffled

%-- Rho ~Time , signalType, (1|subject)

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);

data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');

%convert latencyOrder to dummy variable (retain only one column here as 2
%is redundant)
latencyOrderDummy= dummyvar(data.latencyOrder);

data.latencyOrder= latencyOrderDummy(:,1);

%Stack data to have latencyOrder variable

% lme1= fitlme(data, 'periCueRho~ (timeLock:latencyOrder)+ (1|subject)');
lme1= fitlme(data, 'periCueRho~ timeLock*latencyOrder + (1|subject)');

lme1

%TBD in R, multiple comparisons seem impossible in matlab
% if significant time:latencyOrder interaction, follow-up with individual comparison at each timepoint:

% lme2= fitlme(data, 'periCueRho~ timeLock+ latencyOrder+ (1|subject)');
% 
% lme2

%% -- Statistical comparison
% 
% ind=[];
% ind= (latencyCorrInputTable.stage==stagesToPlot);
% 
% data= latencyCorrInputTable(ind,:);
% 
% % 2 way anova or lmm for shuffled vs real signal 
% % (is there interaction with time; if not then no need for single timestamp comparisons) 
% 
% %--Fit lme of y=latency with fixed effects 1)time 2) ordered fp 3) shuffled fp
% %also interaction of time*fp signals
% 
% 
% lme1= fitlme(data, 'poxDSrel~ (timeLock:DSblue) + (timeLock:DSblueShuffled)');
% 
% lme1
% 
% % 
% % Formula:
% %     poxDSrel ~ 1 + DSblue:timeLock + timeLock:DSblueShuffled
% % 
% % Model fit statistics:
% %     AIC           BIC           LogLikelihood    Deviance  
% %     1.1695e+06    1.1695e+06    -5.8474e+05      1.1695e+06
% % 
% % Fixed effects coefficients (95% CIs):
% %     Name                               Estimate     SE           tStat     DF            pValue        Lower         Upper    
% %     {'(Intercept)'            }           4.1096    0.0060098    683.81    2.3504e+05             0*        4.0978       4.1214
% %     {'DSblue:timeLock'        }         0.015901    0.0013139    12.102    2.3504e+05    1.0508e-33*      0.013326     0.018476
% %     {'timeLock:DSblueShuffled'}        0.0014651    0.0014075    1.0409    2.3504e+05       0.29791    -0.0012936    0.0042237
%     
%     
% % --add random intercept for subject
% lme2= fitlme(data, 'poxDSrel~ (timeLock:DSblue) + (timeLock:DSblueShuffled) + (1|subject)');
% 
% lme2
% 
% % Formula:
% %     poxDSrel ~ 1 + DSblue:timeLock + timeLock:DSblueShuffled + (1 | subject)
% % 
% % Model fit statistics:
% %     AIC           BIC           LogLikelihood    Deviance  
% %     1.1316e+06    1.1317e+06    -5.658e+05       1.1316e+06
% % 
% % Fixed effects coefficients (95% CIs):
% %     Name                               Estimate     SE           tStat     DF            pValue        Lower          Upper    
% %     {'(Intercept)'            }           4.0929      0.39609    10.333    2.3504e+05    5.0498e-25*         3.3166       4.8692
% %     {'DSblue:timeLock'        }         0.015392    0.0012126    12.693    2.3504e+05    6.6099e-37*       0.013015     0.017768
% %     {'timeLock:DSblueShuffled'}        0.0023068    0.0012986    1.7764    2.3504e+05      0.075669    -0.00023839    0.0048519
% 
% 
% %-- add fp signal and time as independent effects
% lme3= fitlme(data, 'poxDSrel~ timeLock + DSblue + DSblueShuffled + (timeLock:DSblue) + (timeLock:DSblueShuffled) + (1|subject)');
% 
% lme3
% 
% % Formula:
% %     poxDSrel ~ 1 + DSblue*timeLock + timeLock*DSblueShuffled + (1 | subject)
% % 
% % Model fit statistics:
% %     AIC           BIC           LogLikelihood    Deviance  
% %     1.0819e+06    1.0819e+06    -5.4092e+05      1.0818e+06
% % 
% % Fixed effects coefficients (95% CIs):
% %     Name                               Estimate      SE           tStat       DF            pValue        Lower         Upper     
% %     {'(Intercept)'            }            4.2644      0.32086      13.291    2.3504e+05    2.7172e-40*        3.6355        4.8932
% %     {'DSblue'                 }        -0.0010542    0.0042038    -0.25077    2.3504e+05       0.80199    -0.0092936     0.0071852
% %     {'timeLock'               }           0.38197    0.0016252      235.03    2.3504e+05             0*       0.37878       0.38515
% %     {'DSblueShuffled'         }          0.042788    0.0039676      10.784    2.3504e+05    4.1409e-27*      0.035012      0.050565
% %     {'DSblue:timeLock'        }         0.0038051    0.0011641      3.2687    2.3504e+05     0.0010807*     0.0015235     0.0060868
% %     {'timeLock:DSblueShuffled'}        -0.0063584    0.0011748     -5.4126    2.3504e+05    6.2191e-08*   -0.0086609    -0.0040559
% 

%% -- There is a time x fp interaction, so follow-up with individual timestamp comparisons?





%% TODO: Time from PE ? (is there ramping prior to PE that is significant? as opposed to cue-elicited?)


%% 
disp('latency corr done')
