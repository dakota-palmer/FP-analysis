% fp_manuscript_fig3
% script combining subplots into large figure

%editing prior code to make one large figure instead of multiple figs

%% default error (sem vs bootstrap CI)
errorBar= 'sem';
% errorBar= 'bootci'; %computationally expensive;

%% set defaults

% % for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
% figSize1= [100, 100, 430, 600];
% 
% figSize2= [100, 100, 650, 600];

% Size in CM
% works with PDF, doens't seem to work with svg... could consider trying
% pixel values with svg
% make units in cm
figWidth= 17.25;
figHeight= 17;
    %position must allow fit on screen
figPosV= 25; 
figPosH= 2;

%make appropriate size
% figSize= figSize2

figSize= [figPosV, figPosH, figWidth, figHeight];

%% Scrap copying approach, use uipanels and draw one at a time

%% Figure 3
%for this simply not making figures between gramm objects (dont call
%figure()) then copy to one fig in positions I want 

clear fig3
% close all
% % Create the uipanels, the 'Position' property is what will allow to create different sizes (it works the same as the corresponding argument in subplot() )

%% Aesthetics
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

%%
% Initialize a figure with Drawable Area padding appropriately
% 3 ROWS, 2 COLUMNS

% Initialize a figure with Drawable Area padding appropriately
% f = figure('Position',[100 1f00 1200 800])

% make figure of desired final size
% f = figure('Position',figSize)

% figSize= [25, 2, 17, 17.5];

% f = figure('Position',figSize, 'Units', 'centimeters');

f= figure();
% %cm not working on instantiation, try setting after
% % set(f, 'Units', 'centimeters', 'Position', figSize);
% 
% %set outerposition as well
% % set(f, 'Units', 'centimeters', 'Position', figSize);
% % set(f, 'Units', 'centimeters', 'OuterPosition', figSize);

%- set size appropriately in cm
set(f, 'Units', 'centimeters', 'Position', figSize);
% outerpos makes it tighter, just in case UIpanels go over
set(f, 'Units', 'centimeters', 'OuterPosition', figSize);

% % % works well for pdf, not SVG (SVG is larger for some reason)
% % % but pdf still has big white space borders
% % % https://stackoverflow.com/questions/5150802/how-to-save-a-plot-into-a-pdf-file-without-a-large-margin-around
set(f, 'PaperPosition', [0, 0, figWidth, figHeight], 'PaperUnits', 'centimeters', 'Units', 'centimeters'); %Set the paper to have width 5 and height 5.

set(f, 'PaperUnits', 'centimeters', 'PaperSize', [figWidth, figHeight]); %Set the paper to have width 5 and height 5.



% padFigure= 0.05;
% figWidth= 1200;
% figHeight= 800;
% f = figure('Position',[1-padFigure, 1-padFigure, figWidth, figHeight])


% - Debugging/placement - With Visualization Borders / colors to help 
    % 'Position' Units are pixels (distance from left, distance from bottom, width, height)
    %but can use 'Units' 'Normalized'
    % e.g. so [.9,.1, .3, .4] is 90% from bottom, 10% from left with width of 30% and height of 40% 

    % Make width/height dependent on Position     
%     panelPos= [.01, .8, .95, .3];
    panelPos= [.01, .8, .95, .5];

    lPos= panelPos(1);
    bPos= panelPos(2);
    w= panelPos(3);
    h= panelPos(4);
    
    %make half-width
    w= w / 2; %- padWidth;

    
    %amount of padding for uipanels
    padPanel= 0.0025;
    
%todo- Adjust width,height based on the whole figure size? assumes equal
%size though so not useful really

%   Full-Width panel: adjust width and height dependent on position    
    w2= 1- panelPos(1);
    h2= 1-panelPos(2);
    
%     p1 = uipanel('Position',[lPos bPos w2 h2],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedin')

%-Adjust lPos,bPos position based on width and height... so padding is good
   %e.g. Full-Width panel:
    lPos= 1-padPanel-w; %- lPos;
    bPos= 1-h; %h- bPos;
    
%todo - Manually Refine position... alter values
% padWidth= 0.0025; %padding from width of Figure

%note that having issues with padding on left side of figure... greater than right side padWidth > 0.005? 
% seems to be feature of figures
padWidth= 0.005; %padding from left side of figure

padHeight= 0.001; %todo- padding from bottom of figure

padPanel= 0.0025; %padding between other uiPanels

    % Panel A- Top row, full width
    w= 1-padWidth;
    
        %make half-width
    w= w / 2; %- padWidth;
    
        %dynamically adjust bPos based on padHeight and height desired
%     h= 0.33; %CHANGE HEIGHT
    h= 0.5; %CHANGE HEIGHT


    bPos= 1- h - padHeight;  
    
        %iterations here
%     p1 = uipanel('Position',[padWidth, .7, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
%     p1 = uipanel('Position',[padWidth, .7, w, .30],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
%     p1 = uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p1 = uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout');

    
    %Position subsequent panels based on prior panels' Position
    
    % Panel B-  2nd row, 2nd half 
    lPos= (w + p1.Position(1) - padPanel + padWidth);
    
    p2 = uipanel('Position',[lPos+padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout');

    
    % Panel C- 2nd row, 1st half width
        %... height of row 1 + 2 + padding
    % redeclare height now for this panel
%     h= .49;
    bPos= (p2.Position(2)) - (h) - padPanel;


        %... width of A/B
    w= p2.Position(3)
        
%     p3= uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p3= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout');
        

    % Panel D- 3rd row, 2nd half width
    lPos= (w + p3.Position(1) - padPanel + padWidth);

    p4= uipanel('Position',[lPos, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout');

%         
%     % Panel E- 3rd row, 1st half width
%         %... height of row 1 + 2 + padding
%     % redeclare height now for this panel
% %     h= .49;
%     bPos= (p4.Position(2)) - (h) - padPanel;
%     p5= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout');
% 
%     
%         % Panel F-  3rd row, 2nd half 
%     lPos= (w + p5.Position(1) - padPanel + padWidth);
%     
%     p6 = uipanel('Position',[lPos+padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout');
% 
%  
   
%% ---- Subfig 1) Plots of peri-event mean traces
% maybe [ trace DS , trace PE, AUC comparison]
clear gPeriEvent

%flip the color order so that PE is consistent with fig2 (purple)
% % cmapGrand= cmapPEGrand;
% % cmapSubj= cmapPESubj;
% cmapGrand= flip(cmapPEGrand);
% cmapSubj= flip(cmapPESubj);

cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';


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


%subset data- simply require DS trial
ind=[];
ind= ~isnan(data.DStrialID);

data= data(ind,:);

%subset data- based on behavioral outcome
% subset data- by PE outcome; only include trials with PE or inPort
% ind=[];
% % ind= data.DStrialOutcome==1 | data.DStrialOutcome==3;
% ind= (data.DStrialOutcome==1) | (data.DStrialOutcome==3);
% 
% data= data(ind,:);


% subset data- by PE outcome; only include trials with valid PE post-cue
ind=[];
ind= data.DStrialOutcome==1;

data= data(ind,:);

%stack() the data by eventType
data3= data;

% - all 3 events (DS, PE, lick)
data3= stack(data3, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
% % - DS and PE only
% data3= stack(data3, {'DSblue', 'DSbluePox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');


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
data3= groupsummary(data3, ["subject","stage","eventType", "timeLock"], "mean",["periEventBlue"]);

% making new field with original column name to work with rest of old code bc 'mean_' is added 
data3.periEventBlue= data3.mean_periEventBlue;



% - Individual Subj lines
group= data3.subject;

gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1).facet_grid([],data3.eventType);


% gPeriEvent(1,1).geom_line();
gPeriEvent(1,1).stat_summary('type',errorBar,'geom','line');


% i2.set_title(titleFig); 
gPeriEvent(1,1).set_color_options('map',cmapSubj);
gPeriEvent(1,1).set_line_options('base_size',linewidthSubj);
gPeriEvent(1,1).set_names('x','Time from Event (s)','y','GCaMP (Z-Score)','color','Event Type', 'column', '');

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
gPeriEvent(1,1).set_parent(p1);


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

%% Subfig 2- Trial Lick Counts, Distribution


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

%-grand boxplot distro of PE latency 
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

clear gLickCountDistro;
group=[];

% figure;

% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

gLickCountDistro(1,1)= gramm('x', data3.loxDSrelCountAllThisTrial, 'group', group);

gLickCountDistro(1,1).set_title('Between-Subjects');

gLickCountDistro(1,1).axe_property('XLim',[0,70]);

gLickCountDistro(1,1).set_names('y','Proportion of Trials','x','Number of Licks','color','', 'column', '');

gLickCountDistro(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


% % gLickCountDistro(1,1).stat_boxplot();
% % gLickCountDistro(1,1).stat_boxplot('dodge', dodge, 'width', 5);

%testing normalization fxns. 
% couldn't get smooth stat_denstiy line to work with 'probability' bins.
% just show bins for clarity
% note 'probability' and 'pdf' are different
% gLickCountDistro(1,1).stat_bin('geom','bar','normalization','pdf'); 
% gLickCountDistro(1,1).stat_density(); %default normalization fxn for this is pdf=probability density fxn

% gLickCountDistro(1,1).stat_bin('geom','bar','normalization','probability');
% gLickCountDistro(1,1).stat_density(); %default normalization fxn for this is pdf=probability density fxn
% gLickCountDistro(1,1).stat_bin('geom','bar','normalization','cdf'); 

% instead of stat_density for kernel smoothing, %use geom line with stat bin?- no, not smooth
gLickCountDistro(1,1).stat_bin('geom','bar','normalization','pdf'); 
% gLickCountDistro(1,1).stat_bin('geom','line', 'normalization','pdf'); 
% gLickCountDistro(1,1).stat_density(); %default normalization fxn for this is pdf=probability density fxn


% gLickCountDistro(1,1).stat_bin('geom','bar'); %just count
% gLickCountDistro(1,1).stat_bin('geom','line'); 


% % gLickCountDistro(1,1).stat_violin(); %violin not working with 1d?
% % gLickCountDistro(1,1).stat_violin('half','true');
% gLickCountDistro(1,1).stat_bin('geom','bar');



gLickCountDistro(1,1).set_color_options('map',cmapGrand);
gLickCountDistro(1,1).no_legend();

%- overlay grand mean pe latency
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
% data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);
data4= groupsummary(data3, ["subject"], "all",["loxDSrelCountAllThisTrial"]);


latMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
gLickCountDistro(1,1).geom_vline('xintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


% don't draw yet- with set_parent, want to wait for all subplots to
% initialize?
% gLickCountDistro(1,1).draw();

%- (2,1) overlay individual subj
gLickCountDistro(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

gLickCountDistro(2,1).set_title('Individual Subjects');
gLickCountDistro(2,1).set_names('y','Number of Licks','x','Subject','color','Subject', 'column', '');



gLickCountDistro(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

gLickCountDistro(2,1).stat_boxplot('dodge', dodge, 'width', 5);
gLickCountDistro(2,1).set_color_options('map',cmapGrand);
gLickCountDistro(2,1).no_legend();

gLickCountDistro(2,1).coord_flip();

gLickCountDistro(1,1).set_parent(p2);
gLickCountDistro(2,1).set_parent(p2);


gLickCountDistro(2,1).draw();

%- overlay individual subj points
group= data3.subject;
% gLickCountDistro(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
gLickCountDistro(2,1).update('y', data3.loxDSrelCountAllThisTrial, 'x', data3.subject, 'color', data3.subject, 'group', group);

gLickCountDistro(2,1).geom_point();

% % gLickCountDistro(2,1).update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % gLickCountDistro(2,1).update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % gLickCountDistro(2,1).update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% gLickCountDistro(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% gLickCountDistro(2,1).geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)

gLickCountDistro(2,1).geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


gLickCountDistro(2,1).set_title('Individual Subjects');


% gLickCountDistro(2,1).axe_property('XLim',[0,10], 'YLim', [0, 10]);

gLickCountDistro(2,1).axe_property('YLim',[0,70], 'XLim', [0,10]);


gLickCountDistro(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
gLickCountDistro(2,1).no_legend();

% gLickCountDistro(2,1).draw();


%-make horizontal
% gLickCountDistro(2,1).coord_flip();

% g.set_title('Figure 3 Supplement: Distribution of Trial Lick Counts');

%- final draw call
gLickCountDistro.draw();

%% Subfig 3- Scatter relationship between PE latency and Lick Counts

% -- Viz of lick count by pe latency

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


% -make figure
clear gscatter;

cmapSubj= cmapSubj;

%-individual trial scatter by subj
group= data3.trialIDcum;
gScatter(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% gScatter(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'marker', data3.subject, 'color', data3.subject, 'group', group);

gScatter(1,1).set_line_options('base_size',linewidthSubj);
% gScatter(1,1).facet_grid(data3.subject,[]);

test=[];
test= groupsummary(data3, ["stage","subject"], 'mean', ["loxDSrelCountAllThisTrial"]);

gScatter(1,1).geom_point();
gScatter(1,1).set_color_options('map', cmapSubj) 

gScatter(1,1).no_legend();

% gScatter(1,1).set_title('Lick Count vs PE latency');
gScatter(1,1).set_names('y', 'Lick Count', 'x', 'Port-Entry Latency (s)');


gScatter(1,1).set_parent(p3);

%first draw
gScatter(1,1).draw

% 
% % show 2d somehow? heatmap bin_2d works
% % %-individual trial scatter by subj
% % group= data3.trialIDcum;
% group= data3.timeLock; % heat by time bin?
% gScatter(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'group', group);
% % gScatter(1,1).set_line_options('base_size',linewidthSubj);
% % gScatter(1,1).facet_grid(data3.subject,[]);
% 
% test=[];
% test= groupsummary(data3, ["stage","subject"], 'mean', ["loxDSrelCountAllThisTrial"]);
% 
% % gScatter(1,1).geom_point();
% % gScatter(1,1).set_color_options('map', cmapSubj) 
% gScatter(1,1).stat_bin2d();
% 
% 
% % gScatter(1,1).set_title('Lick Count vs PE latency');
% gScatter(1,1).set_names('y', 'Lick Count', 'x', 'PE latency');=
% % 
% % %first draw
% % gScatter(1,1).draw

% % Subjects- simple within-subjects glm pooled across trials
% group= data3.subject;
% gScatter(1,1).update('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% gScatter(1,1).stat_glm('disp_fit', true, 'geom', 'line');
% gScatter(1,1).set_line_options('base_size',linewidthGrand);
% gScatter(1,1).no_legend;
% gScatter(1,1).set_color_options('map', cmapGrand) 


% grand- simple glm pooled across trials & subjects
group= [];
gScatter(1,1).update('y', data3.loxDSrelCountAllThisTrial, 'x', data3.poxDSrel, 'color', [], 'marker', [], 'group', group);
% gScatter(1,1).stat_glm('disp_fit', false, 'geom', 'line');
gScatter(1,1).stat_glm('disp_fit', true, 'geom', 'line');

gScatter(1,1).set_line_options('base_size',linewidthGrand);
gScatter(1,1).no_legend;
gScatter(1,1).set_color_options('chroma', chromaLineSubj); 


%last draw
gScatter(1,1).draw();

% % save figure
% titleFig='vp-vta_supplement_lickCount_x_PElatency';

%% Subfig 4- Lick Count x Peri-PE correlation 

%- Load data from correlation ouput
corrOutputTable= load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\vp-vta-fp_supplement_stats_fig3_correlation_lickCount_x_DSbluePox_Table-31-Aug-2023.mat");

data= [];
data= corrOutputTable.data;

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
clear gCorr; 

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
gCorr().set_parent(p4);

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

%% Save the figure

%-Declare Size of Figure at time of creation (up top), not time of saving.

%- Remove borders of UIpanels prior to save
p1.BorderType= 'none';
p2.BorderType= 'none';
p3.BorderType= 'none';
p4.BorderType= 'none';
% p5.BorderType= 'none';
% p6.BorderType= 'none';

%-Save the figure
titleFig='vp-vta_supplement_Figure3_uiPanels_3events_lickCorrelation';
% saveFig(f, figPath, titleFig, figFormats, figSize);
%   % too large for page warning
saveFig(f, figPath, titleFig, figFormats);

% try ally's code for saving heatplot
% saveas(f, strcat(figPath,titleFig,'.pdf')); %save the current figure in fig format


% 
% titleFig= 'vta_Figure3_uiPanels_Legend';
% % saveFig(fig3Legend, figPath, titleFig, figFormats, figSize);
% saveFig(fig3Legend, figPath, titleFig, figFormats);
% 


%% supplemental plot of PE latency distribution


%-grand boxplot distro of PE latency 
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];
% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

g(1,1)= gramm('x', data3.poxDSrel, 'group', group);

g(1,1).set_title('Between-Subjects');

g(1,1).axe_property('XLim',[0,10]);

g(1,1).set_names('y','Proportion of Trials','x','Port-Entry Latency (s)','color','', 'column', '');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


% % g(1,1).stat_boxplot();
% % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
g(1,1).stat_bin('geom','bar','normalization','pdf');
% % g(1,1).stat_violin(); %violin not working with 1d?
% % g(1,1).stat_violin('half','true');
% g(1,1).stat_bin('geom','bar');

% g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["poxDSrel"]);

latMean= nanmean(data4.mean_poxDSrel);
g(1,1).geom_vline('xintercept', latMean, 'style', 'm--', 'linewidth',linewidthReference); 

g(1,1).draw();

%- (2,1) overlay individual subj
g(2,1)= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Port-Entry Latency (s)','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
g(2,1).update('y', data3.poxDSrel, 'x', data3.subject, 'color', data3.subject, 'group', group);

g(2,1).geom_point();

% % g(2,1).update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g(2,1).geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)

g(2,1).geom_hline('yintercept', latMean, 'style', 'm--', 'linewidth',linewidthReference); 


g(2,1).set_title('Individual Subjects');


g(2,1).axe_property('XLim',[0,10], 'YLim', [0, 10]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3F Supplement: Distribution of Port-Entry Latencies');

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

titleFig='vp-vta_Figure3_supplement_latency_distro';
saveFig(gcf, figPath, titleFig, figFormats);



