% 2023-08-22 Examining GCaMP signal as a function of lick count

%% Load periEvent Table (with AUC computed and licks per trial counted)

pathData= ("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-22-Aug-2023periEventTable.mat");


% for now loads as 'data' struct
clear periEventTable;

load(pathData);

%% ----


%% --- Compute AUC of peri-PE ---
%TODO: Move to tidyTable script

data= periEventTable;

%---This METHOD seems WAY TOO SLOW, consider another solution elsewhere?
%ran longer than over night still running
% seems just like matlab is very inefficient doing this... cpu, ram, disk
% usage all very low 

%Overnight made it to NS subj 4 thisDate 3, trial 2386

%--running AUC on all individual trials within loop of table


%-------peri DS AUC, 465nm

%string of signal column(s)
signalCol= 'DSbluePox'

%string of trialID col
trialIDCol= 'DStrialID'

% %preallocate new columns with nan (otherwise matlab may autofill blanks with 0)
data(:, append('auc',signalCol))= table(nan); %single AUC value for trial
% data(:, append('aucAbs',signalCol))= table(nan); %single AUC value for abs(signal) 
% data(:, append('aucCum',signalCol))= table(nan); %cumulative AUC across time within trial 
% data(:, append('aucCumAbs',signalCol))= table(nan); %cumulative AUC of abs(signal) across time within trial 
% 

subjects= unique(data.subject);

for subj= 1:numel(subjects)
%  %    dataTemp= data(strcmp(data.subject,subjects{subj}),:);
   
   %create a conditional index which we'll cumulatively combine for
   %reassignment into original table
   ind=[]; ind2=[]; ind3=[]; ind4=[]; ind5=[]; ind6= [];

   ind= (strcmp(data.subject,subjects{subj}));
   
%    dates= unique(dataTemp.date);

   dates= unique(data(ind, 'date'));
   
   for thisDate= 1:numel(dates)
%        dataTemp2= dataTemp(strcmp(dataTemp.date,dates{date}),:);
       
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate})));
%         ind2= (ind & (strcmp(data(:,'date'),dates{thisDate,:})));

        %kinda slow but likely faster than ismember
        ind2= (ind & (strcmp(data{:,'date'},dates{thisDate,:})));


      
       %TODO: ~~ismember is super slow!
%        ind2= (ind & (ismember(data(:,'date'),dates(thisDate,:))));

       
       
        %retain only those with valid trialIDs 
        ind5= (ind2 & (~ismissing(data(:,trialIDCol))));

       
%        trials= unique(dataTemp2(:,trialIDCol))
    
%        trials= unique(table2array(data(ind2, trialIDCol))); %if run unique() on table doesn't actually get unique values of column
       
       %for some reason ind2 w/ nan trialID returns a unique nan for every row
       trials= unique(data(ind5,trialIDCol));

       trials= table2array(trials);
       
       for trial= 1:numel(trials)
            
%            dataTemp3= dataTemp2((ismember(dataTemp2(:,trialID),trial)),:);
           
%            ind3= (ind2 & (ismember(data(:,trialID),trials(trial))));

%              ind3= (ind5 & (ismember(data(:,trialIDCol),trials(trial,:)))); %this line takes awhile?
%              ind3= (ind5 & (data(:,trialIDCol)==trials(trial,:))); %this line takes awhile?
             ind3= (ind5 & (data.(trialIDCol))==trials(trial,:)); %this line takes awhile?




           %compute AUC of signal within this trial
           auc= []; aucAbs= []; aucCum= []; aucCumAbs= [];
           
           
           
           %Only include post-cue portion of signal in AUC (timeLock >=0)
           ind6= data.timeLock>=0;
           
           ind3= (ind3 & ind6);
           
           signal= data(ind3, signalCol);
           
           signal= table2array(signal);
           
           

           %for auc and aucAbs, single value for trials so retain only one
           %observation (for correct plotting & stats; easy w/o changing later)
           ind4= find(ind3==1);

           auc= nan(size(ind4));
           aucAbs= nan(size(ind4));
           
           [auc(1), aucAbs(1), aucCum, aucCumAbs] = fp_AUC(signal);
          
           
        % -- Eliminate redundant auc values
        
%         %for auc and aucAbs, single value for trials so retain only one
%         %observation (for correct plotting & stats; easy w/o changing later)
%         ind4= find(ind3==1);
% %         
% %         
% %         auc(1)= auc;
% % 
% %         auc(2:,:)= nan;
% %         aucAbs(2:,:)=nan;

           
           data(ind3, append('auc',signalCol))= table(auc); %single AUC value for trial
%            data(ind3, append('aucAbs',signalCol))= table(aucAbs); %single AUC value for abs(signal) 
%            data(ind3, append('aucCum',signalCol))= table(aucCum); %cumulative AUC across time within trial 
%            data(ind3, append('aucCumAbs',signalCol))= table(aucCumAbs); %cumulative AUC of abs(signal) across time within trial 

       end %end trial loop
   end %end ses loop
    
end %end subj loop

periEventTable= data; %reassign




%% 2022-11-04 examining licks before PE

ind=[];

ind= periEventTable.poxDSrel>periEventTable.loxDSrel;

test= periEventTable(ind,:);

%2023-08-16 some remain... 
unique(test.DStrialOutcome)

test2= test(test.DStrialOutcome==1,:);

% i think this file is fine and i just misread the session, other trial was
% inPort so would be fine
% % seeing rat8 20200101 trial 3. 
% % DS= [226.831237120000], PE= {227.201187840000}, lick= {227.418931200000} so before PE
% % result is a very low DSloxRel and DSloxRel<DSpoxRel... in addition there
% % is timelocked periDSloxBlue... How is this not removed by this point?
% % DStrialOutcome = 1
% subjDataAnalyzed.('rat8')(16).behavior.loxDSrel{3}(1)
% subjDataAnalyzed.('rat8')(16).behavior.poxDSrel{3}(1)


%now 8/17 not seeing this??
% same session and trial as above, DS= [226.831237120000], pox= {{227.201187840000}}, lox= {227.418931200000}

%ran behaviora analysis lick cleaning a bit and now reporting fine as
% poxDS= 227.2012, poxDSRel= 0.37, lick= 227.4189, loxDSRel= 0.5877 

%to double check, ran behavioral analysis lick cleaning full. haven't run
%exclude data yet

%yeah now unique(test.DStrialOutcome is only== 3)... data I loaded must not have
%been lick cleaned

% %revised licks .. pre 2023-03-18 criteriaSes fix
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-09-Nov-2022subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat")

% % I loaded: later date than above 'revised licks' so unclear why licks
% were not cleaned.
% %2023-03-18 revised DS/NS ratios (criteriaSes based on 10sec ratio)
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-18-Mar-2023subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat")

% manuscript repo - Q: Did this have licks cleaned?
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_mockups\vp-vta-fp-14-Jun-2023-periEventTableManuscript.mat");

% that was based on fp_manuscript_plots_2.m which does indeed load the lick
% cleaned data... still idk why the march 2023 file doesn't have cleaned licks
%but, just going to go back and load the correct one:
% % %revised licks
% pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-09-Nov-2022periEventTable.mat";


%-- ok after loading correct still getting test.DStrialOutcome 1 and 3
%only seems like 1 trial exception though? rat14, 20200915 (session 18), trial 12
%DS= [1344.80936960000], poxDS= {1348.58702848000}, loxDS= [1345.65838848000][1349.65706752000]
% how did this get past cleaning? should have definitely been removed

%defined in periEventTable as currentSubj(includedSession).behavior.loxDSrel{cue}(1)
% this loxDSrel should have been removed in behavioral_analysis script
% single trial exception from 2022-09-11 subjDataAnalyzed file:
% trialIDcum 13089
subjDataAnalyzed.('rat14')(18).behavior.loxDSrel{12}(1)

%problem could theoretically be related to deleting loxDSrel =[] and index
%mismatch with loxDS ... but it doesn't matter. should have worked:

%^ doesn't really matter. should still have worked fine. Just ran lick cleaning
%section manually and it works fine. Rerunning this now
%after manually running lick cleaning and this there's no remaining invalid
%licks with DStrialOutcome==1. makes no sense. clear memory and start
%fresh.

%after clearing memory and loading in fresh, still that one trial exception


%compare to the newer subjDataAnalyzed real quick:


unique(test.DStrialOutcome)

test2= test(test.DStrialOutcome==1,:);

unique(test2.trialIDcum)

%% 2023-08-15 quick viz of lick count distribution

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

data3= data2;


%-- summary by within-subject, within-session
test= [];
test= groupsummary(data3, ["subject", "fileID"], "all",["loxDSrelCountAllThisTrial"]);

%% Examine variability in lick counts within-subject, within-session
% does lick count change throughout session (e.g. with satiety?)

%-- summary by within-subject, within-session
withinSesTable= [];
withinSesTable= groupsummary(data3, ["subject", "fileID"], "all",["loxDSrelCountAllThisTrial"]);


%--time series within-subj, within-session?
% What is the variability of lick counts within-subject within-session?
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];


%individual session lines
group=data3.fileID;
g= gramm('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.facet_grid([],data3.subject);
g.set_title('Figure 3 Supplement: Time Series of Lick Counts Within-Session');

g.set_names('y','Lick Count','x','Trial #','color','Subject', 'column', 'Subject');

% g.geom_point();
g.geom_line();
g.set_color_options('map',cmapSubj);
g.set_line_options('base_size',linewidthSubj);
g.draw();

%between session mean top
group= data3.subject;
g.update('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.stat_summary('geom','area', 'type', 'sem');
g.set_color_options('map',cmapGrand);
g.set_line_options('base_size',linewidthGrand);
g.draw();

% 
% Save fig
titleFig='vp-vta_supplement_fig3_lickCounts_withinSession';
% saveFig(gcf, figPath, titleFig, figFormats);

 
%% above time-series but share x axes (no subj facet)

% too messy, below is great

% %--time series within-subj, within-session?
% % What is the variability of lick counts within-subject within-session?
% cmapGrand= 'brewer_dark';
% cmapSubj= 'brewer2';
% 
% figure;
% g=[];
% 
% 
% %individual session lines
% group=data3.fileID;
% g= gramm('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
% % g.facet_grid([],data3.subject);
% g.set_title('Figure 3 Supplement: Time Series of Lick Counts Within-Session');
% 
% g.set_names('y','Lick Count','x','Trial #','color','Subject', 'column', 'Subject');
% 
% % g.geom_point();
% g.geom_line();
% g.set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
% g.draw();
% 
% %between session mean top
% group= data3.subject;
% g.update('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
% g.stat_summary('geom','area', 'type', 'sem');
% g.set_color_options('map',cmapGrand);
% g.set_line_options('base_size',linewidthGrand);
% g.draw();
% 
% % 
% % Save fig
% titleFig='vp-vta_supplement_fig3_lickCounts_withinSession';
% % saveFig(gcf, figPath, titleFig, figFormats);


%% -- Distro by trial? Nice 

cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];

%subj mean
group= data3.subject;
g= gramm('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.set_title('Figure 3 Supplement: Time Course of Lick Count Within-Session (n=3 sessions)');
g.facet_grid(data3.subject,[]);
% g.geom_point();
% g.geom_line();
g.stat_boxplot('dodge', dodge, 'width', 5);
g.set_color_options('map',cmapGrand);
g.set_names('y','Lick Count','x','Trial #','color','Subject', 'column', 'Subject');


g.draw();

%ind sessions
group= data3.fileID;
g.update('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
% g.geom_point();
g.no_legend();
g.geom_line();
g.set_color_options('map',cmapSubj);
g.set_line_options('base_size',linewidthSubj);


%-make horizontal
% g.coord_flip();
% g.draw();

%%-- next step for correlation would be to correlate/viz peri-PE with lick
%count

%- overlay grand mean lick count

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);

lickMean= [];
lickMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
% g.geom_hline('yintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

%final draw call
g.draw();

titleFig='vp-vta_supplement_fig3_lickCounts_withinSession';
saveFig(gcf, figPath, titleFig, figFormats);


%% -- simple scatter of lick count by trialID?

% clear g;
% figure;
% 
% %-individual trial scatter by subj
% group= data3.trialIDcum;
% g(1,1)= gramm('y', data3.DStrialID, 'x', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
% 
% g(1,1).facet_grid([], data3.fileID);
% 
% g(1,1).geom_point();
% 
% g(1,1).set_title('Lick Count vs Peri-DS AUC');
% g(1,1).set_names('y', 'Lick Count', 'x', 'Peri-DS AUC');
% 
% 
% %- vline at 0 
% g(1,1).geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 
% 
% 
% %first draw
% g(1,1).draw


%% --distro within-subj, within-session? grouping may be incorrect
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];

%subj mean
group= data3.subject;
g= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.set_title('Figure 3 Supplement: Lick Count Distribution Within-Session');
% g.geom_point();
% g.geom_line();
g.stat_boxplot('dodge', dodge, 'width', 5);
g.set_color_options('map',cmapGrand);

g.draw();

%ind sessions
group= data3.fileID;
g.update('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.geom_point();
g.no_legend();
% g.geom_line();
g.set_color_options('map',cmapSubj);

%-make horizontal
g.coord_flip();
% g.draw();

%%-- next step for correlation would be to correlate/viz peri-PE with lick
%count

%- overlay grand mean lick count

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);

lickMean= [];
lickMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
g.geom_hline('yintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

%final draw call
g.draw();


%% old
%-- viz
figure;
g=[];
group= data3.fileID;
g= gramm('x', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.stat_bin();
g.geom_point();
g.draw();

%% 
%-boxplot distro of PE latency by subj
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];
group=[];
g= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g.set_title('Figure 3 Supplement: Distribution of Trial Raw Lick Count');
g.set_names('y','Lick Count','x','Subject','color','Subject', 'column', '');

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
g.geom_hline('yintercept', latMean, 'style', 'm--', 'linewidth',linewidthReference); 

%-make horizontal
g.coord_flip();

%- final draw call
g.draw();



%%  
%-grand boxplot distro of trial lick count
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

g(1,1).axe_property('XLim',[0,70], 'YLim', [0,0.1]);

g(1,1).set_names('y','','x','Trial Raw Lick Count','color','', 'column', '');

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
data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);

lickMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
g(1,1).geom_vline('xintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

%- (2,1) overlay individual subj
g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



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


g(2,1).axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Lick Counts');

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

titleFig='vp-vta_Figure3_supplement_lickCount_distro';
saveFig(gcf, figPath, titleFig, figFormats);

%% despite appropriate lick cleaning and restriction to trials with valid PE, there appear to be some trials with very few licks

% just visually confirm lox > pox ?
figure;
hold on;
scatter(data3.poxDSrel, data3.loxDSrel);

% %- no remaining trials where lick before PE
% test=[];
% test= data3(data3.poxDSrel>data3.loxDSrel,:);
% figure;
% hold on;
% scatter(test.poxDSrel, test.loxDSrel);
% % no trials included with lox before pox


%% -- Viz of PE vs lick latency

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('x', data3.poxDSrel, 'y', data3.loxDSrel, 'color', data3.subject, 'group', group);

g(1,1).geom_point();

g(1,1).set_title('PE vs Lick latency');
g(1,1).set_names('x', 'PE latency', 'y', 'Lick latency');

%first draw
g(1,1).draw


%% -- Viz of lick count by latency

% heat plot might help resolve density here...

%interesting. relationship between lick count and latency is mostly linear
%but there are some notable low lick count trials event when the latency to first lick is
%quick.

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.loxDSrel, 'color', data3.subject, 'group', group);

g(1,1).geom_point();

g(1,1).set_title('Lick Count vs Lick latency');
g(1,1).set_names('y', 'Lick Count', 'x', 'Lick latency');

%first draw
g(1,1).draw



%% -- bin by lick count and viz peri-PE 
% then can try correlation

%---- Subset data

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


% % gPeriEvent(1,1).geom_line();
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


%% -- peri event plots as above but stacked & CONTINUOUS (not binned)
% 
% 
% %---- Subset data
% 
% data= periEventTable;
% 
% %- SUBSET data
% data= periEventTable;
% 
% % subset data- by stage
% % stagesToPlot= [1:11];
% stagesToPlot= [7];
% 
% ind=[];
% ind= ismember(data.stage, stagesToPlot);
% 
% data= data(ind,:);
% 
% 
% % -- Subset data- restrict to last 3 sessions of stage 7 (same as encoding model input?)
% nSesToInclude= 3; 
% 
% % reverse cumcount of sessions within stage, mark for exclusion
% groupIDs= [];
% 
% % data.StartDate= cell2mat(data.StartDate);
% groupIDs= findgroups(data.subject, data.stage);
% 
% groupIDsUnique= [];
% groupIDsUnique= unique(groupIDs);
% 
% data(:, 'includedSes')= table(nan);
% 
% 
% for thisGroupID= 1:numel(groupIDsUnique)
%     %for each groupID, find index matching groupID
%     ind= [];
%     ind= find(groupIDs==groupIDsUnique(thisGroupID));
%         
%     %for each groupID, get the table data matching this group
%     thisGroup=[];
%     thisGroup= data(ind,:);
% 
%     % get max trainDayThisStage for this Subject
%     maxTrainDayThisStage= [];
%     thisGroup(:,'maxTrainDayThisStage')= table(max(thisGroup.trainDayThisStage));
% 
%     %check if difference between trainDayThisStage and max is within
%     %nSesToInclude
%     thisGroup(:,'deltaTrainDayThisStage')= table(thisGroup.maxTrainDayThisStage - thisGroup.trainDayThisStage);
% 
%     % this way delta==0 is final day, up to delta < nSesToInclude
%     ind2=[];
%     ind2= thisGroup.deltaTrainDayThisStage < nSesToInclude;
%     thisGroup(:,'includedSes')= table(nan);
% 
%     thisGroup(ind2,'includedSes')= table(1);
% 
%     
%         
%     %assign back into table
%     data(ind, 'includedSes')= table(thisGroup.includedSes);
% %     
% %     %now cumulative count of observations in this group
% %     %make default value=1 for each, and then cumsum() to get cumulative count
% %     thisGroup(:,'cumcount')= table(1);
% %     thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
% %     
% %     thisGroup(:,'cumcountMax')= table(max(thisGroup.cumcount));
%     
%     %assign back into table
% %     data(ind, 'testCount')= table(thisGroup.cumcount);
%   
%     %subtract trainDayThisStage - cumcount max and if 
%     
% %     % Check if >1 observation here in group
% %     % if so, flag for review
% %     if height(thisGroup)>1
% %        disp('duplicate ses found!')
% %         dupes(ind, :)= thisGroup;
% % 
% %     end
%     
% end 
% 
% 
% ind= [];
% ind= data.includedSes==1;
% 
% data= data(ind,:);
% 
% % subset data- by PE outcome; only include trials with valid PE post-cue
% ind=[];
% ind= data.DStrialOutcome==1;
% 
% data= data(ind,:);
% 
% % subset data- by lick; only include trials with valid lick counted
% ind= [];
% ind= data.loxDSrelCountAllThisTrial>=1;
% 
% data= data(ind,:);
% 
% 
% % for binning and faceting copy code from fp_manuscript_session_correlation
% 
% 
% %initialize columns
% data(:,'lickCountBin')= table(nan);
% data(:,'lickCountBinEdge')= table(nan);
% 
% %----convert lick Count into n bins 
% %quick and dirty binning using discretize() 
% 
% nBins=[];
% nBins= 5;
% 
% y= [];
% e= [];
% 
% [y, e]= discretize(data.loxDSrelCountAllThisTrial, nBins);
% 
% data.lickCountBin= y;
% 
% %save labels of bin edges too 
% for bin= 1:numel(e)-1
%     
%     ind= [];
%     ind= data.lickCountBin== bin;
%     
%    data(ind, "lickCountBinEdge")= table(e(bin)); 
% end
% 
% 
% %-----
% % Vizualize periDSPE, faceted by lick count bin
% 
% 
% 
% % ---- Add Plots of peri-event mean traces
% 
% %- subset data (relying on above)
% %- note: keep full time series for viz
% data= data;
% 
% clear gPeriEvent
% 
% %- aesthetics
% xlimTraces= [-2,10];
% ylimTraces= [-2,5];
% 
% % yTickTraces= [0:2:10] 
% xTickTraces= [-2:2:10]; % ticks every 2s
% % xTickTraces= [-2:1:10]; % ticks every 1s
% 
% xTickHeat= [-4:2:10]; %expanded to capture longer PE latencies
% xLimHeat= [-4,10];
% 
% yLimCorrelation= [-0.5, 0.5];
% xLimCorrelation= [-2,5];
% xTickCorrelation= [-2:2:5];
% 
% errorBar='sem';
% 
% 
% 
% 
% %stack() the data by eventType
% data3= data;
% 
% %all 3 events:
% data3= stack(data3, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
% cmapGrand= 'brewer_dark';
% cmapSubj= 'brewer2';
% 
% % % DS and PE only
% % data3= stack(data3, {'DSblue', 'DSbluePox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
% % % %flip the color order so that PE is consistent with fig2 (purple)
% % % % cmapGrand= cmapPEGrand;
% % % % cmapSubj= cmapPESubj;
% % cmapGrand= flip(cmapPEGrand);
% % cmapSubj= flip(cmapPESubj);
% 
% % - rename eventTypes so auto faceting are in order of events
% %manually relabel trialType for clarity
% %convert categorical to string then search 
% % data3(:,"eventType")= {''};
% 
%  %make labels matching each 'trialType' and loop thru to search/match
% trialTypes= {'DSblue', 'DSbluePox', 'DSblueLox'};
% trialTypeLabels= {'1_Peri-DS','2_Peri-PE', '3_Peri-Lick'};
% 
% for thisTrialType= 1:numel(trialTypes)
%     ind= [];
%     
%     ind= strcmp(string(data3.eventType), trialTypes(thisTrialType));
% 
%     data3(ind, 'eventType')= {trialTypeLabels(thisTrialType)};
%     
% end
% 
% 
% 
% % ---- 2023-04-06
%  %Mean/SEM update
%  %instead of all trials, simplify to mean observation per subject
%  % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
% % data3= groupsummary(data3, ["subject","stage","eventType", "timeLock"], "mean",["periEventBlue"]);
% 
% % data3= groupsummary(data3, ["subject","stage", "lickCountBinEdge", "eventType", "timeLock", "loxDSrelCountAllThisTrial"], "mean",["periEventBlue"]);
% data3= groupsummary(data3, ["subject","stage", "loxDSrelCountAllThisTrial", "eventType", "timeLock"], "mean",["periEventBlue"]);
% 
% 
% % making new field with original column name to work with rest of old code bc 'mean_' is added 
% data3.periEventBlue= data3.mean_periEventBlue;
% 
% % color= lick count continuous
% 
% % - Individual Subj lines
% group= data3.subject;
% 
% figure;
% 
% clear gPeriEvent;
% 
% gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.loxDSrelCountAllThisTrial, 'group', group);
% 
% % gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);
% gPeriEvent(1,1).facet_grid([],data3.eventType);
% 
% 
% % gPeriEvent(1,1).geom_line();
% gPeriEvent(1,1).stat_summary('type',errorBar,'geom','line');
% 
% 
% % i2.set_title(titleFig); 
% % gPeriEvent(1,1).set_color_options('map',cmapSubj);
% gPeriEvent(1,1).set_line_options('base_size',linewidthSubj);
% gPeriEvent(1,1).set_names('x','Time from event (s)','y','GCaMP (Z-Score)','color','Lick Count', 'column', 'Event Type', 'row', 'Trial Licks (Binned)');
% 
% gPeriEvent(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles
% 
% % %remove legend
% % gPeriEvent(1,1).no_legend();
% 
% %-set limits
% gPeriEvent(1,1).axe_property('YLim',ylimTraces);
% gPeriEvent(1,1).axe_property('XLim',xlimTraces);
% gPeriEvent(1,1).axe_property('XTick',xTickTraces);
% 
% % gPeriEvent(1,1).axe_property('XLim',xLimHeat);
% % gPeriEvent(1,1).axe_property('XTick',xTickHeat);
% 
% 
% % % % % set parent uiPanel in overall figure
% % gPeriEvent(1,1).set_parent(p2);
% % gPeriEvent(1,1).set_parent(p1);
% 
% 
% %- First Draw call
% gPeriEvent(1,1).draw();
% 
% % -- Between subjects mean+SEM 
% group=[]
% gPeriEvent(1,1).update('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.loxDSrelCountAllThisTrial, 'group', group);
% 
% gPeriEvent(1,1).stat_summary('type',errorBar,'geom','area');
% 
% % gPeriEvent(1,1).set_color_options('map',cmapGrand);
% gPeriEvent(1,1).set_line_options('base_size',linewidthGrand);
% 
% 
% %remove legend
% gPeriEvent(1,1).no_legend();
% 
% 
% %- vline at 0 
% gPeriEvent(1,1).geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 
% 
% 
% % %- save final draw til end
% gPeriEvent(1,1).draw();





%% AUC PLOTS AFTER CALCULATED-- would run plot auc but can't do it yet bc calculated later in code

%% -- scatter, Viz of periDS auc by lick count

% subset data- rely on above
data3= data;

% heat plot might help resolve density here...

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.aucDSblue, 'color', data3.subject, 'group', group);

g(1,1).facet_grid([], data3.subject);

g(1,1).geom_point();

g(1,1).set_title('Lick Count vs Peri-DS AUC');
g(1,1).set_names('y', 'Lick Count', 'x', 'Peri-DS AUC');


%- vline at 0 
g(1,1).geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 


%first draw
g(1,1).draw

%% dp 2023-08-23 seeing some really large AUCs here.

% subset data
data3=data;

% viz AUCs

clear g; figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('x', data3.trialIDcum, 'y', data3.aucDSblue, 'color', data3.subject, 'group', group);

% g(1,1).facet_grid([], data3.subject);

g(1,1).geom_point();

g(1,1).set_title(' Peri-DS AUC');
g(1,1).set_names('x', 'trial', 'y', 'Peri-DS AUC');


%- vline at 0 
g(1,1).geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 


%first draw
g(1,1).draw


% % % data looks same as manuscript. AUCs just a lot higher than I expected
% % in stage 7. Trial-by-trial this is true, the session means are more reasonable
% % --groupsummary for stats of AUC DS
% test= periEventTable;
% % test= periEventTableManuscript.periEventTable;
% 
% % subset to stage 7
% test= test((test.stage==7),:);
% 
% 
% % subset to 1 observation per trial 
% % test= test(((test.DStrialID==1) & (test.timeLock==0)),:);
% test= test(((test.timeLock==0)),:);
% 
% % subset sessions with valid labels (non '')
% test= test(~strcmp(test.sesSpecialLabel, ''),:);
% 
% %groupsummary descriptive stats
% % testGroup= groupsummary(test, ["sesSpecialLabel"], 'all', vartype('numeric'));
% 
% aucTable=[];
% aucTable= groupsummary(test, ["subject", "fileID"], 'all', "aucDSblue");






%% Plot by AUC (after running perieventplots and computing auc)

%note only computed periDS auc in perieventplots (not auc of peri PE/lick)

clear i1; 

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1


%subset data- relying on above
data2=table();

data2= data;


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

%DROP NANs for 2d plot
% data3= data3(~isnan(data3.periDSauc,:));

%-grand boxplot distro of trial lick count
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];

% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

% %1d 

% g(1,1)= gramm('x', data3.loxDSrelCountAllThisTrial, 'group', group);
% 
% % % g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal

% 2d 
g(1,1)= gramm('x', data3.lickCountBinEdge, 'y', data3.aucDSblue, 'group', group);
% 
% g(1,1)= gramm('color', data3.lickCountBinEdge, 'x', data3.aucDSblue, 'group', group);
% g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal


g(1,1).set_title('Between-Subjects');

% g(1,1).axe_property('XLim',[0,70], 'YLim', [0,0.1]);

g(1,1).set_names('y','','x','Peri-DS AUC','color','', 'row', 'Trial Lick Count (Binned)');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


g(1,1).stat_boxplot();
% % % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
% g(1,1).stat_bin('geom','bar','normalization','pdf');
% % % g(1,1).stat_violin(); %violin not working with 1d?
% % % g(1,1).stat_violin('half','true');
% % g(1,1).stat_bin('geom','bar');

% g(1,1).stat_bin('geom','bar','normalization','pdf');
% g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["aucDSblue"]);

lickMean= nanmean(data4.mean_aucDSblue);
g(1,1).geom_vline('xintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

% %- (2,1) overlay individual subj
% % -2d
g(2,1)= gramm('x', data3.aucDSblue, 'y', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);

% % g(2,1).facet_grid(data3.lickCountBinEdge,[]);

% %- 1d
% g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);


g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;

%- 1d
% % g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

%- 2d
g(2,1).update('y', data3.aucDSblue, 'x', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);


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


% g(2,1).axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Peri-DS AUC by Lick Count');

%- final draw call
g.draw();

titleFig='vp-vta_Figure3_supplement_periDSauc_by_lickCount';
% saveFig(gcf, figPath, titleFig, figFormats);

%% extend above, individual subj
clear g;
figure;


group= data3.subject;

% %- (2,1) overlay individual subj
% % -2d
% g(2,1)= gramm('x', data3.aucDSblue, 'y', data3.subject, 'color', data3.subject, 'group', group);

g(2,1)= gramm('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

% %- 1d
% g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g(2,1).facet_grid(data3.lickCountBinEdge,data3.subject);


g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;

%- 1d
% % g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

%- 2d
g(2,1).update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);


g(2,1).geom_point();

% % g(2,1).update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g(2,1).geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)
% 
% % cant map intercept automatically with facets?
% g(2,1).geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


g(2,1).set_title('Individual Subjects');


% g(2,1).axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Peri-DS AUC by Lick Count');

%- final draw call
g.draw();

titleFig='vp-vta_Figure3_supplement_periDSauc_by_lickCount';

%% extend above, NO FACETS, 2d individual subj
clear g;
figure;


group= data3.subject;

% %-  overlay individual subj
% % -2d
% g= gramm('x', data3.aucDSblue, 'y', data3.subject, 'color', data3.subject, 'group', group);

g= gramm('y', data3.aucDSblue, 'x', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);

% %- 1d
% g= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g.facet_grid([],data3.subject);


g.set_title('Individual Subjects');
g.set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g.stat_boxplot('dodge', dodge, 'width', 5);
g.set_color_options('map',cmapGrand);
g.no_legend();

g.coord_flip();


g.draw();

%- overlay individual subj points
group= data3.subject;

%- 1d
% % g.update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g.update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

%- 2d
g.update('y', data3.aucDSblue, 'x', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);


g.geom_point();

% % g.update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g.update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g.update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g.update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g.geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)
% 
% % cant map intercept automatically with facets?
% g.geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


g.set_title('Individual Subjects');


% g.axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g.set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g.no_legend();

% g.draw();


%-make horizontal
% g.coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Peri-DS AUC by Lick Count');

%- final draw call
g.draw();

titleFig='vp-vta_Figure3_supplement_periDSauc_by_lickCount';




%% Plot facet individual bins?


clear i1; 

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1


%subset data- relying on above
data2=table();

data2= data;


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

%DROP NANs for 2d plot
% data3= data3(~isnan(data3.periDSauc,:));

%-grand boxplot distro of trial lick count
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];

% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

% %1d 

g(1,1)= gramm('x', data3.aucDSblue, 'group', group);
% 
g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal

% 2d 
% g(1,1)= gramm('x', data3.lickCountBinEdge, 'y', data3.aucDSblue, 'group', group);
% 
% g(1,1)= gramm('color', data3.lickCountBinEdge, 'x', data3.aucDSblue, 'group', group);
% g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal


g(1,1).set_title('Between-Subjects');

% g(1,1).axe_property('XLim',[0,70], 'YLim', [0,0.1]);

g(1,1).set_names('y','','x','Peri-DS AUC','color','', 'row', 'Trial Lick Count (Binned)');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


g(1,1).stat_boxplot();
% % % % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
% % g(1,1).stat_bin('geom','bar','normalization','pdf');
% % % % g(1,1).stat_violin(); %violin not working with 1d?
% % % % g(1,1).stat_violin('half','true');
% % % g(1,1).stat_bin('geom','bar');

% %- dist with density smoothed
g(1,1).stat_bin('geom','bar','normalization','pdf');
g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
% data4= groupsummary(data3, ["subject"], "mean",["aucDSblue"]);
data4= groupsummary(data3, ["subject", "lickCountBinEdge"], "mean",["aucDSblue"]);


% % doesn't map to facets automatically?
% lickMean= nanmean(data4.mean_aucDSblue);
% g(1,1).geom_vline('xintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference);

% doesn't map to facets automatically?
% g(1,1).geom_vline('xintercept', data4.mean_aucDSblue, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

% % not straightforward
% 
% % % make a dummy column for intercept, use geom_line to auto map reference
% % % line accordingly to facets?
% % dummyCol=[];
% % dummyCol= zeros(numel(data4),1);
% % 
% % g(1,1).update('x', dummyCol, 'y', data4.mean_aucDSblue, 'group', group);
% % g(1,1).geom_line;%('style', 'k--', 'linewidth',linewidthReference); 
% % 
% 
% % use same table..
% % use group() to appropriately get mean?
% % data3(:,'dummyCol')=table(nan);
% % % % data3(:,'dummyCol')= table(0); %zeros(numel(data3),1);
% % % test=[];
% % % test= repmat(0:1:1*601,2);
% % % 
% % % test=[];
% % % test= repmat(0:1/601:1,2);
% 
% test= [0:1/600:1]';
% 
% data3(:,'dummyCol')= {nan};
% data3(:,'dummyCol')= {test};
% 
% % test2= [];
% % test2= repmat(test,2);
% 
% %dummy Col should span xlim
% 
% group= data3.subject;
% 
% g(1,1).update('y', data3.dummyCol, 'x', data3.aucDSblue, 'group', group);
% 
% g(1,1).geom_line();

g(1,1).draw();






%% --------------------PERI PE PLOTS------------------

%% -- scatter, Viz of peri PE auc by lick count

% subset data- relying on above
data3= data;

% heat plot might help resolve density here...

%interesting. relationship between lick count and latency is mostly linear
%but there are some notable low lick count trials event when the latency to first lick is
%quick.

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.aucDSbluePox, 'color', data3.subject, 'group', group);

g(1,1).geom_point();

g(1,1).set_title('Lick Count vs Peri-DS PE AUC');
g(1,1).set_names('y', 'Lick Count', 'x', 'Peri-DS PE AUC');

%first draw
g(1,1).draw





%% Plot by AUC (after running perieventplots and computing auc)

%note only computed periDS auc in perieventplots (not auc of peri PE/lick)

clear i1; 

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1


%subset data- relying on above
data2=table();

data2= data;


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

%DROP NANs for 2d plot
% data3= data3(~isnan(data3.periDSauc,:));

%-grand boxplot distro of trial lick count
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];

% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

% %1d 

% g(1,1)= gramm('x', data3.loxDSrelCountAllThisTrial, 'group', group);
% 
% % % g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal

% 2d 
g(1,1)= gramm('x', data3.lickCountBinEdge, 'y', data3.aucDSbluePox, 'group', group);
% 
% g(1,1)= gramm('color', data3.lickCountBinEdge, 'x', data3.aucDSblue, 'group', group);
% g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal


g(1,1).set_title('Between-Subjects');

% g(1,1).axe_property('XLim',[0,70], 'YLim', [0,0.1]);

g(1,1).set_names('y','','x','Peri-DS PE AUC','color','', 'row', 'Trial Lick Count (Binned)');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


g(1,1).stat_boxplot();
% % % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
% g(1,1).stat_bin('geom','bar','normalization','pdf');
% % % g(1,1).stat_violin(); %violin not working with 1d?
% % % g(1,1).stat_violin('half','true');
% % g(1,1).stat_bin('geom','bar');

% g(1,1).stat_bin('geom','bar','normalization','pdf');
% g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["aucDSbluePox"]);

lickMean= nanmean(data4.mean_aucDSbluePox);
g(1,1).geom_vline('xintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

% %- (2,1) overlay individual subj
% % -2d
g(2,1)= gramm('x', data3.aucDSbluePox, 'y', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);

% % g(2,1).facet_grid(data3.lickCountBinEdge,[]);

% %- 1d
% g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);


g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;

%- 1d
% % g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

%- 2d
g(2,1).update('y', data3.aucDSbluePox, 'x', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);


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


% g(2,1).axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Peri-DS PE AUC by Lick Count');

%- final draw call
g.draw();

titleFig='vp-vta_Figure3_supplement_periDSPEauc_by_lickCount';
% saveFig(gcf, figPath, titleFig, figFormats);

%% extend above, individual subj
clear g;
figure;


group= data3.subject;

% %- (2,1) overlay individual subj
% % -2d
% g(2,1)= gramm('x', data3.aucDSblue, 'y', data3.subject, 'color', data3.subject, 'group', group);

g(2,1)= gramm('y', data3.aucDSbluePox, 'x', data3.subject, 'color', data3.subject, 'group', group);

% %- 1d
% g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g(2,1).facet_grid(data3.lickCountBinEdge,data3.subject);


g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;

%- 1d
% % g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

%- 2d
g(2,1).update('y', data3.aucDSbluePox, 'x', data3.subject, 'color', data3.subject, 'group', group);


g(2,1).geom_point();

% % g(2,1).update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g(2,1).geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)
% 
% % cant map intercept automatically with facets?
% g(2,1).geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


g(2,1).set_title('Individual Subjects');


% g(2,1).axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Peri-DS PE AUC by Lick Count');

%- final draw call
g.draw();

titleFig='vp-vta_Figure3_supplement_periDSPEauc_by_lickCount';

%% extend above, NO FACETS, 2d individual subj
clear g;
figure;


group= data3.subject;

% %-  overlay individual subj
% % -2d
% g= gramm('x', data3.aucDSblue, 'y', data3.subject, 'color', data3.subject, 'group', group);

g= gramm('y', data3.aucDSbluePox, 'x', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);

% %- 1d
% g= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g.facet_grid([],data3.subject);


g.set_title('Individual Subjects');
g.set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g.stat_boxplot('dodge', dodge, 'width', 5);
g.set_color_options('map',cmapGrand);
g.no_legend();

g.coord_flip();


g.draw();

%- overlay individual subj points
group= data3.subject;

%- 1d
% % g.update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g.update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

%- 2d
g.update('y', data3.aucDSbluePox, 'x', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);


g.geom_point();

% % g.update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g.update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g.update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g.update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g.geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)
% 
% % cant map intercept automatically with facets?
% g.geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


g.set_title('Individual Subjects');


% g.axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g.set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g.no_legend();

% g.draw();


%-make horizontal
% g.coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Peri-DS PE AUC by Lick Count');

%- final draw call
g.draw();

titleFig='vp-vta_Figure3_supplement_periDSPEauc_by_lickCount';




%% Plot facet individual bins?


clear i1; 

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1


%subset data- relying on above
data2=table();

data2= data;


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

%DROP NANs for 2d plot
% data3= data3(~isnan(data3.periDSauc,:));

%-grand boxplot distro of trial lick count
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];

% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

% %1d 

g(1,1)= gramm('x', data3.aucDSbluePox, 'group', group);
% 
g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal

% 2d 
% g(1,1)= gramm('x', data3.lickCountBinEdge, 'y', data3.aucDSblue, 'group', group);
% 
% g(1,1)= gramm('color', data3.lickCountBinEdge, 'x', data3.aucDSblue, 'group', group);
% g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal


g(1,1).set_title('Between-Subjects');

% g(1,1).axe_property('XLim',[0,70], 'YLim', [0,0.1]);

g(1,1).set_names('y','','x','Peri-DS PE AUC','color','', 'row', 'Trial Lick Count (Binned)');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


g(1,1).stat_boxplot();
% % % % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
% % g(1,1).stat_bin('geom','bar','normalization','pdf');
% % % % g(1,1).stat_violin(); %violin not working with 1d?
% % % % g(1,1).stat_violin('half','true');
% % % g(1,1).stat_bin('geom','bar');

% %- dist with density smoothed
g(1,1).stat_bin('geom','bar','normalization','pdf');
g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
% data4= groupsummary(data3, ["subject"], "mean",["aucDSblue"]);
data4= groupsummary(data3, ["subject", "lickCountBinEdge"], "mean",["aucDSbluePox"]);


% % doesn't map to facets automatically?
% lickMean= nanmean(data4.mean_aucDSblue);
% g(1,1).geom_vline('xintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference);

% doesn't map to facets automatically?
% g(1,1).geom_vline('xintercept', data4.mean_aucDSblue, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

% % not straightforward
% 
% % % make a dummy column for intercept, use geom_line to auto map reference
% % % line accordingly to facets?
% % dummyCol=[];
% % dummyCol= zeros(numel(data4),1);
% % 
% % g(1,1).update('x', dummyCol, 'y', data4.mean_aucDSblue, 'group', group);
% % g(1,1).geom_line;%('style', 'k--', 'linewidth',linewidthReference); 
% % 
% 
% % use same table..
% % use group() to appropriately get mean?
% % data3(:,'dummyCol')=table(nan);
% % % % data3(:,'dummyCol')= table(0); %zeros(numel(data3),1);
% % % test=[];
% % % test= repmat(0:1:1*601,2);
% % % 
% % % test=[];
% % % test= repmat(0:1/601:1,2);
% 
% test= [0:1/600:1]';
% 
% data3(:,'dummyCol')= {nan};
% data3(:,'dummyCol')= {test};
% 
% % test2= [];
% % test2= repmat(test,2);
% 
% %dummy Col should span xlim
% 
% group= data3.subject;
% 
% g(1,1).update('y', data3.dummyCol, 'x', data3.aucDSblue, 'group', group);
% 
% g(1,1).geom_line();

g(1,1).draw();




