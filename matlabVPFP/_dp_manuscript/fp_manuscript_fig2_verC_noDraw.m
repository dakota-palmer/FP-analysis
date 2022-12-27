% fp_manuscript_fig2
% script combining subplots into large figure

%editing prior code to make one large figure instead of multiple figs

%% Figure 2

% maybe preinitialize gramm object with size of subplots ahead of time?
%so this way will have known size and can allocate accordingly w/o waiting
%to draw at end

% %didn't work.
% clear i;
% i(3,2)= gramm()

clear i;
figure;

%% Figure 2a -- FP Learning on special sessions
% DS vs NS learning on special days: 2d 

%- Stage 5 Day 1, Stage 5 Criteria, Stage 7 Criteria
% --marked as sesSpecialLabel in fpTidyTable.m

%subset data- only sesSpecial
data= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data.sesSpecialLabel);

data= data(ind,:);

%subset data- remove specific sesSpecialLabel
ind= [];
ind= ~strcmp('stage-7-day-1-criteria',data.sesSpecialLabel);

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
%2022-12-22 instead of clearing gramm objects, want to copy() them as
%subplots into single large Figure. To do so, want to save each object
%instead of clearing between so that single draw call can be made (e.g.
%instead of i, make i1, i2, i3... etc corresponding to single Fig)
% clear i;
% h= figure();
% figure;

cmapGrand= cmapBlueGrayGrand;
cmapSubj= cmapBlueGraySubj;

% cmapGrand= cmapCueGrand;
% cmapSubj= cmapCueSubj;


% individual subjects means
i(1,1)= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group', data.subject);

i(1,1).facet_grid([],data.sesSpecialLabel);%, 'column_labels',false);


i(1,1).stat_summary('type','sem','geom','line');

i(1,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i(1,1).set_line_options('base_size',linewidthSubj);
% i(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

% i(1,1).set_names('column','test'); %seems column label needs to come before first draw call

%- Things to do before first draw call-
i(1,1).set_names('column', '', 'x', 'Time from Cue (s)','y','GCaMP (Z-score)','color','Trial type'); %row/column labels must be set before first draw call

i(1,1).no_legend(); %avoid duplicate legend from other plots (e.g. subject & grand colors)
i(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

titleFig= 'Fig 2a)';   
i(1,1).set_title(titleFig); %overarching fig title must be set before first draw call


%- first draw call-
% i(1,1).draw();

%mean between subj + sem
i(1,1).update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group',[]);

i(1,1).stat_summary('type','sem','geom','area');

i(1,1).set_color_options('map',cmapGrand);

i(1,1).set_line_options('base_size',linewidthGrand)

%-set limits
i(1,1).axe_property('YLim',[-1,5]);
i(1,1).axe_property('XLim',[-2,10]);

i(1,1).geom_vline('xintercept',0, 'style', 'k--', 'linewidth', linewidthReference); %overlay t=0

%-initialize overall Figure for complex subplotting
% fig2Handle= figure();


%-copy to overall Figure as subplot
%this is a soft copy so need to draw before i is cleared/changed... because i is handle type object..., like if i is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
fig2(1,1)= copy(i(1,1));

figTest(1,:)= copy(i(1,1));

%save drawing til end
% %copyobj doesn't seem usable for hard copy
% fig2(1,1)= copyobj(i,fig2Handle);

% set(0,'CurrentFigure',fig2Handle);%switch to this figure before drawing
% figure(fig2Handle);
% title('test fig2');
% fig2(1,1).draw();

%- final draw call
% set(0,'CurrentFigure',h)%switch to this figure before drawing
% figure(h);
% i(1,1).draw();

% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');   

titleFig= strcat('figure2a-learning-fp-periCue');   

% for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
figSize1= [100, 100, 430, 600];

figSize2= [100, 100, 650, 600];

%2022-12-16 playing with figure size
% set(gcf,'Position', figSize1);
% i(1,1).redraw()

% i(1,1).set_layout_options('legend_position',0,0.5,0.5,0.5]);
% i(1,1).draw()
% 
% i(1,1).set_layout_options('legend_width',0.10);
% i(1,1).redraw()

%try gramm export 
% i(1,1).export('file_name',strcat(titleFig,'_Gramm_exported'),'export_Path',figPath,'width',11.5,'units','centimeters')

titleFig= strcat(titleFig,'matlab_Saved');

% saveFig(gcf, figPath, titleFig, figFormats, figSize2);

%-- TODO: maybe try https://stackoverflow.com/questions/24531402/matlab-scale-figures-for-publishing-exact-dimensions-and-font-sizes

% - also note white space min here https://interfacegroup.ch/preparing-matlab-figures-for-publication/


%-- Try embedding in 1 big figure?
%will need all subplots to fit within whole fig

% fig1(1,1)= i;

% .copy() should work, see here- https://github.com/piermorel/gramm/issues/23
% i think .copy() needs to happen before draw() or update() calls... so
% would need to copy to figure and update prior to each of those
% 
%seems to work if you put it before the final draw call!
% but soft copy, see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html

% fig1= copy(i);
% figure;
% 
% fig1.draw();
% 
% fig1(1,1)= copy(i);
% 
% fig1(1,1).draw();

%% Fig 2a ----- Bar plots of AUC ------
% clear i1; 
% h= figure;
% figure;

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1


%subset data- only sesSpecial
data2= periEventTable;

ind=[];
ind= ~cellfun(@isempty, data2.sesSpecialLabel);

data2= data2(ind,:);

%subset data- remove specific sesSpecialLabel
ind= [];
ind= ~strcmp('stage-7-day-1-criteria',data2.sesSpecialLabel);

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
i(2,1)= gramm('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i(2,1).facet_grid([],data.sesSpecialLabel);

i(2,1).set_color_options('map',cmapGrand);

%mean bar for trialType
i(2,1).stat_summary('type','sem','geom',{'bar', 'black_errorbar'}, 'dodge', dodge, 'width', width);

i(2,1).set_line_options('base_size',linewidthGrand)


%- Things to do before first draw call-
i(2,1).set_names('column', '', 'x','Trial Type','y','GCaMP (Z-score)','color','Trial Type');

i(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

titleFig= 'Fig 2a) inlay';   
i(2,1).set_title(titleFig); %overarching fig title must be set before first draw call

%- first draw call-
% i(2,1).draw()

%- Draw lines between individual subject points (group= subject, color=[]);
group= data2.subject;
i(2,1).update('x', data2.trialTypeLabel,'y',data2.periCueBlueAuc,'color',[], 'group', group)

% i1.geom_line('alpha',0.3); %individual trials way too much
i(2,1).stat_summary('type','sem','geom','line');

i(2,1).set_line_options('base_size',linewidthSubj);

i(2,1).set_color_options('chroma', chromaLineSubj); %black lines connecting points

% i(2,1).draw();

%ind subj mean points
i(2,1).update('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i(2,1).stat_summary('type','sem','geom','point', 'dodge', dodge);

i(2,1).set_color_options('map',cmapSubj); 

i(2,1).no_legend(); %avoid duplicate legend from other plots (e.g. subject  grand colors)

%-set plot limits-

%set x lims and ticks (a bit more manual good for bars)
% lims= [0-.4,(numel(trialTypes)-1)+.4];

lims= [1-.6,(numel(trialTypes))+.6];


i(2,1).axe_property('XLim',lims);

i(2,1).axe_property('YLim',[-1,16]);

%horz line @ zero
i(2,1).geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 

%-copy to overall Figure as subplot
%this is a soft copy so need to draw before i1 is cleared/changed... because i1 is handle type object..., like if i1 is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
fig2(2,1)= copy(i(2,1));

figTest(2,:)= copy(i(2,1));
%save drawing until end

% set(0,'CurrentFigure',fig2Handle);%switch to this figure before drawing

% fig2(2,1).draw();

%- final draw call-
% set(0,'CurrentFigure',h);%switch to this figure before drawing

% i(2,1).draw();


% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');
titleFig= strcat('figure2a-learning-fp-periCue_Inlay-AUC');   

% saveFig(gcf, figPath, titleFig, figFormats);

%% -- Figure 2c - PE contingency PE vs no PE trace

stagesToPlot= [7];

%---- i(1) pericue z trace
%subset specific data to plot
data3= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%initialize & add binary variable for PE vs noPE

data3(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% ind=[];
% ind= ~isnan(data.poxDSrel);

%trialOutcome coding: 1= PE, 2= noPE, 3=inPort
outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 

data3(:,'poxDSoutcome')= {outcomeLabels{data3.DStrialOutcome}}';

%unstack based on PE outcome
groupers= ["subject","stage","date","DStrialID","timeLock"];
data3= unstack(data3, 'DSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

%transform with stack to have trialOutcome variable
data3= stack(data3, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlue');

% figure();
% clear i

% individual subjects means
i(3,1)= gramm('x',data3.timeLock,'y',data3.periCueBlue, 'color', data3.trialOutcome, 'group', data3.subject);

i(3,1).stat_summary('type','sem','geom','line');
i(3,1).geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

i(3,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i(3,1).set_line_options('base_size',linewidthSubj);
i(3,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

% i(3,1).draw();

%mean between subj + sem
i(3,1).update('x',data3.timeLock,'y',data3.periCueBlue, 'color', data3.trialOutcome, 'group',[]);

i(3,1).stat_summary('type','sem','geom','area');

i(3,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

i(3,1).set_line_options('base_size',linewidthGrand)

i(3,1).axe_property('YLim',[-1,5]);
i(3,1).axe_property('XLim',[-5,10]);

% title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-periCue-zTraces');   

titleFig= strcat('-stage-',num2str(stagesToPlot),'-Figure2c');   


i(3,1).set_title(titleFig);    
i(3,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (grand mean)');


% i(3,1).draw();

%% when making subplots gramm likes a collective i.draw() after creating
%each subplot before updating?

%---- i(2) bar AUC
data4= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

% data4= stack(data4, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');

%initialize & add binary variable for PE vs noPE
data4(:,'poxDSoutcome')= {''}; %table(0);
% ind=[];
% ind= ~isnan(data4.poxDSrel);
% 
% data4(ind,'poxDSoutcome')= {'PEtrial'};%table(1);
%trialOutcome coding: 1= PE, 2= noPE, 3=inPort
outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 

data4(:,'poxDSoutcome')= {outcomeLabels{data4.DStrialOutcome}}';

%unstack based on PE outcome
groupers= ["subject","stage","date","DStrialID","timeLock"];
data4= unstack(data4, 'aucDSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

% 
% data4(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% ind=[];
% ind= ~isnan(data3.poxDSrel);

%transform with stack to have trialOutcome variable
data4= stack(data4, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlueAuc');

% figure();
% clear i

%mean between subj
i(3,2)= gramm('x',data4.trialOutcome,'y',data4.periCueBlueAuc, 'color', data4.trialOutcome, 'group', []);

i(3,2).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

%mean bar for trialType
i(3,2).stat_summary('type','sem','geom',{'bar', 'black_errorbar'});

i(3,2).set_line_options('base_size',linewidthGrand)

i(3,2).axe_property('YLim',[-1,10]);
% title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2b-periCue-byPEoutcome-zAUC');   
i(3,2).set_title(titleFig);    
i(3,2).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (grand mean)');

%horz line @ zero
i(3,2).geom_hline('yintercept', 0, 'style', 'k--'); 

fig2(3,1)= copy(i(3,1));

%2022-12-23
% i().draw();
% i(3,:).draw();

%ind subj mean points
i(3,2).update('x',data4.trialOutcome,'y',data4.periCueBlueAuc, 'color', data4.trialOutcome, 'group', data4.subject);

i(3,2).stat_summary('type','sem','geom','point');

i(3,2).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i(3,2).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (ind subj mean)');

% fig2(3,2)= copy(i(3,2));

% i(3,2).draw()


%% Single draw call
% i.draw() %looks same as prior methods...

%% Figure 2d - PE contingency PE vs no PE AUC

%% try no drawing at all, assigning just prior to single draw call
clear fig22;
% assign largest first?
fig22(3,2)= copy(i(3,2));
fig22(3,1)= copy(i(3,1));
fig22(2,1)= copy(i(2,1));
fig22(1,1)= copy(i(2,1));

figure;
fig22.draw();

%% Draw the Figure2
% fig2.draw();
% 
% titleFig= 'Figure2_Final_verB';
% fig2.export('file_name',strcat(titleFig,'_Gramm_exported_verB'),'export_Path',figPath,'width',11.5,'units','centimeters')


