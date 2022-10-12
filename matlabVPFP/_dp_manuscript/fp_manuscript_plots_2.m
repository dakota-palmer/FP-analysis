% og script became cumbserome, so load completely analyzed dataset and
% streamline more final figures below:


%% Set gramm plot defaults
set_gramm_plot_defaults();


%% Plot Settings
figPath= strcat(pwd,'\_figures\_mockups\');

%SVG good for exporting for final edits
% figFormats= {'.svg'} %list of formats to save figures as (for saveFig.m)

%PNG good for quickly viewing many
figFormats= {'.png'} %list of formats to save figures as (for saveFig.m)


%-- Master plot linestyles and colors

%thin, light lines for individual subj
linewidthSubj= 0.5;
lightnessRangeSubj= [100,100];

%dark, thick lines for between subj grand mean
linewidthGrand= 1.5;
lightnessRangeGrand= [10,10];


%% Load periEventTable from fp_manuscript_figs.m --

% for now assume preprocessing experimental all sessions

pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-12-Oct-2022periEventTable.mat";

load(pathData);


%% ----------------- Figure 2---------------------------------------------------

%% Figure 2a -- FP Learning on special sessions
% DS vs NS learning on special days: 2d 

%- Stage 5 Day 1, Stage 5 Criteria, Stage 7 Criteria
% --marked as sesSpecialLabel in fpTidyTable.m

%subset data 
data= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data.sesSpecialLabel);

data= data(ind,:);

%stack() to make trialType variable for faceting
data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');


%manually relabel trialType for clarity
%either simply "DS" or "NS"
%convert categorical to string then search 
data(:,"trialTypeLabel")= {''};

 %make labels matching each 'trialType' and loop thru to search/match
trialTypes= {'DSblue', 'NSblue'};
trialTypeLabels= {'DS','NS'};

for thisTrialType= 1:numel(trialTypes)
    ind= [];
    
    ind= strcmp(string(data.trialType), trialTypes(thisTrialType));

    data(ind, 'trialTypeLabel')= {trialTypeLabels(thisTrialType)};
    
end


% FacetGrid with sesSpecialLabel = Row
clear i;
figure();

cmapGrand= cmapBlueGrayGrand;
cmapSubj= cmapBlueGraySubj;

% cmapGrand= cmapCueGrand;
% cmapSubj= cmapCueSubj;


% individual subjects means
i= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group', data.subject);

i.facet_grid([],data.sesSpecialLabel);%, 'column_labels',false);


i().stat_summary('type','sem','geom','line');
i().geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i().set_line_options('base_size',linewidthSubj);
% i().set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

% i.set_names('column','test'); %seems column label needs to come before first draw call

%- Things to do before first draw call-
i.set_names('column', '', 'x', 'Time from Cue (s)','y','GCaMP (Z-score)','color','Trial type'); %row/column labels must be set before first draw call

i.no_legend(); %avoid duplicate legend from other plots (e.g. subject & grand colors)
i.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

titleFig= 'Fig 2a)';   
i.set_title(titleFig); %overarching fig title must be set before first draw call

%- first draw call-
i().draw();

%mean between subj + sem
i().update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group',[]);

i().stat_summary('type','sem','geom','area');

i().set_color_options('map',cmapGrand);

i().set_line_options('base_size',linewidthGrand)

i().axe_property('YLim',[-1,5]);
i().axe_property('XLim',[-5,10]);

i.draw()

% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');   

titleFig= strcat('figure2a-learning-fp-periCue');   

saveFig(gcf, figPath, titleFig, figFormats);

%% Fig 2a ----- Bar plots of AUC ------
clear i; figure;

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1

data2= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data2.sesSpecialLabel);

data2= data2(ind,:);

%stack() to make trialType variable for faceting
data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');

%manually relabel trialType for clarity
%either simply "DS" or "NS"
%convert categorical to string then search 
data2(:,"trialTypeLabel")= {''};

 %make labels matching each 'trialType' and loop thru to search/match
trialTypes= {'aucDSblue', 'aucNSblue'};
trialTypeLabels= {'DS','NS'};

for thisTrialType= 1:numel(trialTypes)
    ind= [];
    
    ind= strcmp(string(data2.trialType), trialTypes(thisTrialType));

    data2(ind, 'trialTypeLabel')= {trialTypeLabels(thisTrialType)};
    
end

%mean between subj
group=[];
i= gramm('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i.facet_grid([],data.sesSpecialLabel);

i.set_color_options('map',cmapGrand);

%mean bar for trialType
i.stat_summary('type','sem','geom',{'bar', 'black_errorbar'}, 'dodge', dodge, 'width', width);

i.set_line_options('base_size',linewidthGrand)


%- Things to do before first draw call-
i.set_names('column', '', 'x','Trial Type','y','GCaMP (Z-score)','color','Trial Type');

i.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

titleFig= 'Fig 2a) inlay';   
i.set_title(titleFig); %overarching fig title must be set before first draw call

%- first draw call-
i.draw()

%- Draw lines between individual subject points (group= subject, color=[]);
group= data2.subject;
i.update('x', data2.trialTypeLabel,'y',data2.periCueBlueAuc,'color',[], 'group', group)

% i.geom_line('alpha',0.3); %individual trials way too much
i.stat_summary('type','sem','geom','line');

i.set_line_options('base_size',linewidthSubj);

i.set_color_options('chroma', chromaLineSubj); %black lines connecting points

i.draw();

%ind subj mean points
i.update('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i.stat_summary('type','sem','geom','point', 'dodge', dodge);

i.set_color_options('map',cmapSubj); 

i.no_legend(); %avoid duplicate legend from other plots (e.g. subject  grand colors)

%-set plot limits-

%set x lims and ticks (a bit more manual good for bars)
% lims= [0-.4,(numel(trialTypes)-1)+.4];

lims= [1-.6,(numel(trialTypes))+.6];


i.axe_property('XLim',lims);

i.axe_property('YLim',[-1,10]);

%horz line @ zero
i.geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthGrand); 


%- final draw call-
i().draw();


% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');
titleFig= strcat('figure2a-learning-fp-periCue_Inlay-AUC');   

saveFig(gcf, figPath, titleFig, figFormats);

%% 





