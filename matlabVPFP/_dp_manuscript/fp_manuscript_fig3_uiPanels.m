% fp_manuscript_fig3
% script combining subplots into large figure

%editing prior code to make one large figure instead of multiple figs

%% default error (sem vs bootstrap CI)
errorBar= 'sem';
% errorBar= 'bootci'; %computationally expensive;

%% set defaults

% for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
figSize1= [100, 100, 430, 600];

figSize2= [100, 100, 650, 600];

%make appropriate size
figSize= figSize2

%% Scrap copying approach, use uipanels and draw one at a time

%% Figure 3
%for this simply not making figures between gramm objects (dont call
%figure()) then copy to one fig in positions I want 

clear fig3
close all
% Create the uipanels, the 'Position' property is what will allow to create different sizes (it works the same as the corresponding argument in subplot() )


% Subplots : 3 Rows of 3 columns; 1 row of 2 col
    % 1 row of 2 %normalized units of size (% of figure)
    
    
%%
% Initialize a figure with Drawable Area padding appropriately

% make figure of desired final size
f = figure('Position',figSize)

% - Debugging/placement - With Visualization Borders / colors to help 
    % 'Position' Units are pixels (distance from left, distance from bottom, width, height)
    %but can use 'Units' 'Normalized'
    % e.g. so [.9,.1, .3, .4] is 90% from bottom, 10% from left with width of 30% and height of 40% 

    % Make width/height dependent on Position     
    panelPos= [.01, .8, .95, .3];
    lPos= panelPos(1);
    bPos= panelPos(2);
    w= panelPos(3);
    h= panelPos(4);
    
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
    
        %dynamically adjust bPos based on padHeight and height desired
    h= 0.24; %CHANGE HEIGHT

    bPos= 1- h - padHeight;  
    
        %iterations here
    p1 = uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
    %Position subsequent panels based on prior panels' Position
    
    % Panel B-  2nd row, full width
        %...height of row 1 + padding
    bPos= (p1.Position(2)) - (p1.Position(4)) - padPanel;
    
    p2 = uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    % Panel C- 3rd row, full width
        %... height of row 1 + 2 + padding


    % redeclare height now for this panel
    h= .25;
    bPos= (p2.Position(2)) - (h) - padPanel;

    w= p2.Position(3)  %- padWidth;
        
%     p3= uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p3= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
        

    % Panel D- 4th row, 1st half width

    % redeclare height now for this panel
    h= .25;
    bPos= (p3.Position(2)) - (h) - padPanel;

    w= p2.Position(3)/2  %- padWidth;
        
%     p3= uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p4= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
        

    
    
    
    %Panel E- 4th row, 2nd half width
        %adjust lPos position to accomodate Panel C width + padding
%     lPos= (p3.Position(3) - p3.Position(1) - padPanel + padWidth);

    lPos= (w + p4.Position(1) - padPanel + padWidth);

%     p4= uipanel('Position',[lPos, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p5= uipanel('Position',[lPos, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
        %width 1/2 of Panels A/B
    
%     p2 = uipanel('Position',[padWidth, p1.Position(2)-padPanel, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%     p1 = uipanel('Position',[lPos bPos w h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%     p1 = uipanel('Position',[lPos bPos w h],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

%     p1

 
%%
% Initialize a figure with Drawable Area padding appropriately
% 3 ROWS, 2 COLUMNS

% Initialize a figure with Drawable Area padding appropriately
% f = figure('Position',[100 100 1200 800])

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
    panelPos= [.01, .8, .95, .3];
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
    h= 0.33; %CHANGE HEIGHT

    bPos= 1- h - padHeight;  
    
        %iterations here
%     p1 = uipanel('Position',[padWidth, .7, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
%     p1 = uipanel('Position',[padWidth, .7, w, .30],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
%     p1 = uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p1 = uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
    %Position subsequent panels based on prior panels' Position
    
    % Panel B-  2nd row, 2nd half 
    lPos= (w + p1.Position(1) - padPanel + padWidth);
    
    p2 = uipanel('Position',[lPos+padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
    % Panel C- 2nd row, 1st half width
        %... height of row 1 + 2 + padding
    % redeclare height now for this panel
%     h= .49;
    bPos= (p2.Position(2)) - (h) - padPanel;


        %... width of A/B
    w= p2.Position(3)
        
%     p3= uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p3= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
        

    % Panel D- 3rd row, 2nd half width
    lPos= (w + p3.Position(1) - padPanel + padWidth);

    p4= uipanel('Position',[lPos, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

        
    % Panel E- 3rd row, 1st half width
        %... height of row 1 + 2 + padding
    % redeclare height now for this panel
%     h= .49;
    bPos= (p4.Position(2)) - (h) - padPanel;
    p5= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
        % Panel F-  3rd row, 2nd half 
    lPos= (w + p5.Position(1) - padPanel + padWidth);
    
    p6 = uipanel('Position',[lPos+padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%%
    
% p1 = uipanel('Position',[.01 .8 .95 (.2)],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedin')


% p2 = uipanel('Position',[0.6 0 0.8 0.2],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
% p3 = uipanel('Position',[0.6 0.5 0.4 0.5],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
% p4 = uipanel('Position',[0.6 0.5 0.4 0.5],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
% actual p
    
% p1 = uipanel('Position',[0 0 .8 .2],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','none')
% p2 = uipanel('Position',[0.6 0 0.8 0.2],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','none')
% p3 = uipanel('Position',[0.6 0.5 0.4 0.5],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','none')
% p4 = uipanel('Position',[0.6 0.5 0.4 0.5],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','none')


%% Figure 3a -- Heatplots (representative subject)

% tried in gramm, not really supported or at least not intuitive and not worth effort
%going with  matlab imagesc heatplots

% clear i; figure;

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1

% subset data
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

%subset data- only representative subj
subjToInclude= 'rat15';

ind=[];

ind= strcmp(data.subject, subjToInclude);

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


% % subset data- only include trials with licks (valid, non-nan lick peri
% % signal)
% ind=[];
% ind= ~isnan(data.DSblueLox);
% 
% data= data(ind,:);

% %subset data- only include trials where lick happens after PE 
% %TODO: CORRECT THE LICK TIMESTAMPS !!!!
% %2022-11-03
% ind=[];
% ind= data.poxDSrel>=data.loxDSrel;
% 
% data= data(ind,:);


% TODO: subset only specific encoding model input?

%subset data- only sesSpecial
% 
% ind=[];
% ind= ~cellfun(@isempty, data.sesSpecialLabel);
% 
% data= data(ind,:);

%subset data- remove specific sesSpecialLabel
% ind= [];
% ind= ~strcmp('stage-7-day-1-criteria',data.sesSpecialLabel);
% 
% data= data(ind,:);

% % subset data- retain only periDS
% ind= [];
% ind= ~isnan(data2.DSblue);
% 
% data2= data2(ind,:);

% --Sort Trials by PE Latency

% maybe can use sortrows to do this very easily?d
%sorting by PE latency within-subject and within-stage
data2 = sortrows(data,{'subject','stage','poxDSrel','fileID','trialIDcum','timeLock'});


%-- add simple cumcount of trials in these subset data
id= [];
id= unique(data2.DStrialIDcum, 'stable'); %stable to prevent sorting

idCount= [];
idCount= 1:numel(id);

%initialize
data2(:,'DStrialIDcumcount')= table(nan);

for thisID= 1:numel(id)
     
    ind=[];
    ind= data2.DStrialIDcum==id(thisID);
    
    
    data2(ind,'DStrialIDcumcount')= table(idCount(thisID)); 

    
end

% make another dataset for plotting sorted by Lick latency from PE
%sorting by Lick latency within-subject and within-stage

% %could be precalculated in tidyTable but manual reassign quickly 2022-11-08
% loxDSpoxRel should be loxDSrel - poxDSrel (PE latency)
%compared with stored values plots look same 
data(:,'loxDSpoxRel')= table(nan);
data.loxDSpoxRel= data.loxDSrel- data.poxDSrel;


data4=table;
% data4 = sortrows(data,{'subject','stage','loxDSrel','fileID','trialIDcum','timeLock'});
data4 = sortrows(data,{'subject','stage','loxDSpoxRel','fileID','trialIDcum','timeLock'});


%-- add simple cumcount of trials in these subset data
id= [];
id= unique(data4.DStrialIDcum, 'stable'); %stable to prevent sorting

idCount= [];
idCount= 1:numel(id);

%initialize
data4(:,'DStrialIDcumcount')= table(nan);

for thisID= 1:numel(id)
     
    ind=[];
    ind= data4.DStrialIDcum==id(thisID);
    
    
    data4(ind,'DStrialIDcumcount')= table(idCount(thisID)); 

    
end

% %-- heatplot figure
% 
% color lims for heat plot cbar
top= 5;%15;
bottom= -5;

% % For each subject
subjects= unique(data2.subject);
for subj= 1:numel(subjects);

    ind=[];
    ind= strcmp(data2.subject, subjects{subj});
    data3= table;
    data3= data2(ind,:);
    
    
    ind=[];
    ind= strcmp(data4.subject, subjects{subj});
    
    data5=table;
    data5= data4(ind,:);
    
%     %make figure
%     figure(); hold on;
%     imagesc(data3.timeLock,data3.DStrialIDcumcount,data3.DSblue);

%     %overlay Cue Onset (-poxDSrel) 
%     scatter(-data3.poxDSrel,data3.DStrialIDcumcount, 'k.');
%     
%     caxis manual;
%     caxis([bottom,top]); %use a shared color axis to encompass all values
% 
%     c= colorbar; %colorbar legend
% 
%     xlabel('seconds from PE');

    %x is just wrong... timelock should end at +10
    %test individual trial
%     test= data3(data3.DStrialIDcumcount<=3,:);

    test=data3;

%     figure(); hold on;
%     imagesc(test.timeLock,test.DStrialIDcumcount,test.DSblue);

%     %bad, should be flipped
%     figure;
%     imagesc(test.DStrialIDcumcount,test.timeLock,test.DSblue); %doesnt work?

    %get rid of table format
    x=[], y=[], c=[];
    x= (test.timeLock);
    y= (test.DStrialIDcumcount);
    c= (test.DSblue);
    
%     figure;
%     imagesc(x,y,c);
%     view([90 -90]) %// instead of normal view, which is view([0 90])
% 
%     
%     figure;
%     imagesc(y,x,c);
%     
%     view([90 -90]) %// instead of normal view, which is view([0 90])

    %looking at old code, input to imagesc is in columns. try this
    %and the c is 601x100 so one column per trial..probs needs to be
    %pivoted/stacked...
    x2= x';
    y2= y';
    c2= c';
%         
%     figure;
%     imagesc(y,x,c);
    
    % need to transform c...
    %unstack 
%     data4= stack(data3, {'DSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');
%     data4= unstack(data3, {'DSblue'}, {'trialType', 'NewDataVariableName', 'periCueBlue');
    bins= [];
    bins= numel(unique(x));
    
    %reshape to have specific # of columns (num trials)
    trials= [];
    trials= numel(unique(y));
    
    c2= reshape(c, [], trials);
    
%     figure;
%     imagesc(x,y,c2);
% 
%     figure;
%     imagesc(y,x,c2);
%     
%     %this one looks ok but axes wrong
%     figure;
%     imagesc(y,x,c2);
%     view([-90, 90]) %// instead of normal view, which is view([0 90])
%         
    overlayAlpha= .2;
    overlayPointSize= 10; %default i think is 10
    
    
%     figure;
%     %- heatplot
%     imagesc(y,x,c2);
%     set(gca,'YDir','normal') %increasing latency from top to bottom
%     view([90, 90]) %// instead of normal view, which is view([0 90])
% 
%     
% %     caxis manual;
% %     caxis([bottom, top]);
%     c= colorbar; %colorbar legend
%     
%     colormap parula;
%     
%     hold on;
% 
%     
%     %- scatter overlays
%     %overlay cue
%     s= scatter(data3.DStrialIDcumcount, zeros(size(data3.DStrialIDcumcount)), 'filled', 'k');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
%     s.SizeData= overlayPointSize;
%     
%     %overlay first PE
%     s= scatter(data3.DStrialIDcumcount ,data3.poxDSrel, 'filled', 'm');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
%     s.SizeData= overlayPointSize;
%     
%     %overlay first lick
%     s= scatter(data3.DStrialIDcumcount ,data3.loxDSrel, 'filled', 'g');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
%     s.SizeData= overlayPointSize;
%     
%     titleFig= 'test';
%     
    %% Subplot peri heatplot of 3 events
%     figure();

    % create plots within the UIPanel
%     set(0, 'CurrentFigure', p1) %doesnt work
    
%- for each subplot, make axes and set parent to uiPanel
    
    %1 ---- peri cue
%     subplot(1,3,1);
    ax1= [];
    ax1= subplot(1,3,1, 'Parent', p1);
    
    %get data; not in table format
    x=[], y=[], c=[];
    x= (data3.timeLock);
    y= (data3.DStrialIDcumcount);
    c= (data3.DSblue);
    
        
    %reshape to have specific # of columns (num trials)
    trials= [];
    trials= numel(unique(y));
    
    c= reshape(c, [], trials);
    
    %make heatplot
    imagesc(y,x,c);
    set(gca,'YDir','normal') %increasing latency from top to bottom
    view([90, 90]) %// instead of normal view, which is view([0 90])

    
    caxis manual;
    caxis([bottom, top]);
%     cbar= colorbar; %colorbar legend
    
    colormap parula;
    
    hold on; %hold on AFTER heatmap (before can change orientation for some reason)

%     title('Peri-DS (sorted by PE latency)');
    title('DS');
    
    %- scatter overlays
    %overlay cue
    s= scatter(data3.DStrialIDcumcount, zeros(size(data3.DStrialIDcumcount)), 'filled', 'k');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first PE
    s= scatter(data3.DStrialIDcumcount ,data3.poxDSrel, 'filled', 'm');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first lick
    s= scatter(data3.DStrialIDcumcount ,data3.loxDSrel, 'filled', 'g');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    

    %--- 2 peri DS PE ---
    
%     subplot(1,3,2);
    ax2= [];
    ax2= subplot(1,3,2, 'Parent', p1);
    
    
     %get data; not in table format
    x=[], y=[], c=[];
    x= (data3.timeLock);
    y= (data3.DStrialIDcumcount);
    c= (data3.DSbluePox);
    
    trials= [];
    trials= numel(unique(y));
    
    c= reshape(c, [], trials);
    
    %make heatplot
    imagesc(y,x,c);    
    set(gca,'YDir','normal') %increasing latency from top to bottom
    view([90, 90]) %// instead of normal view, which is view([0 90])

    
    caxis manual;
    caxis([bottom, top]);
%     cbar= colorbar; %colorbar legend
    
    colormap parula;
    
    hold on; %hold on AFTER heatmap (before can change orientation for some reason)

%     title('Peri-PE (sorted by PE latency)');
    title('Port entry');

    
    %- scatter overlays
    %overlay cue (- poxDSrel)
    s= scatter(data3.DStrialIDcumcount,-data3.poxDSrel, 'filled', 'k');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first PE (0)
    s= scatter(data3.DStrialIDcumcount, zeros(size(data3.DStrialIDcumcount)), 'filled', 'm');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
    %overlay first lick (relative to PE= lox-pox)
    s= scatter(data3.DStrialIDcumcount ,data3.loxDSrel-data3.poxDSrel, 'filled', 'g');
    s.MarkerFaceAlpha= overlayAlpha;
    s.AlphaData= overlayAlpha;
    s.SizeData= overlayPointSize;
    
     %--- 3 peri DS Lick ---
     
     %**have this data sorted by Lick Latency from PE**
    
%     subplot(1,3,3);
    ax3= [];
    ax3= subplot(1,3,3, 'Parent', p1);
    
     %get data; not in table format
    x=[], y=[], c=[];
    x= (data5.timeLock);
    y= (data5.DStrialIDcumcount);
    c= (data5.DSblueLox);
    
    trials= [];
    trials= numel(unique(y));
    
    c= reshape(c, [], trials);
    
    %make heatplot
    heat=[];
    heat= imagesc(y,x,c);    
    set(gca,'YDir','normal') %increasing latency from top to bottom
    view([90, 90]) %// instead of normal view, which is view([0 90])

    
    caxis manual;
    caxis([bottom, top]);
%     cbar= colorbar; %colorbar legend
    
    colormap parula;
    
    hold on; %hold on AFTER heatmap (before can change orientation for some reason)

%     title('Peri-Lick (sorted by lick latency)');
    title('Lick');

    
    %- scatter overlays
    %overlay cue (- loxDSrel)
    s= [], s1= []; s2= []; s3=[];
    s1= scatter(data5.DStrialIDcumcount,-data5.loxDSrel, 'filled', 'k');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
    s1.SizeData= overlayPointSize;
    
    %overlay first PE (relative to lick= -lox +pox?)
%     s= scatter(data4.DStrialIDcumcount ,-data4.loxDSrel+data3.poxDSrel, 'filled', 'm');
%     s= scatter(data5.DStrialIDcumcount ,-data5.loxDSrel+data5.poxDSrel, 'filled', 'm');
    s2= scatter(data5.DStrialIDcumcount ,-data5.loxDSpoxRel, 'filled', 'm');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;
    s2.SizeData= overlayPointSize;
    
    %overlay first lick (0)
    s3= scatter(data5.DStrialIDcumcount, zeros(size(data5.DStrialIDcumcount)), 'filled', 'g');
%     s.MarkerFaceAlpha= overlayAlpha;
%     s.AlphaData= overlayAlpha;    
    s3.SizeData= overlayPointSize;

%     
%     titleFig= strcat('Fig 3a) heatplot',' subj-', subjects{subj});   
%     sgtitle(titleFig);
   sgtitle('A');

    
  %-- make legend / colorbar in separate subplot.
  % maybe https://stackoverflow.com/questions/41454174/how-to-have-a-common-legend-for-subplots
    %TODO: matlab transparency/alpha of scatter not working,     %works in legend but not plot

%    hL= subplot(2,3,3.5, 'Parent', p1);

  %Save Legend and Colorbar into separate figure
    %make a new figure + subplot
   fig3Legend= figure;
   sgtitle('Fig 3 Legends')
   hL= subplot(4,2,1:2);
  
   % make legend within this new figure, add legend based on scatters
   poshL= get(hL, 'position') %get position of new legend subplot's handle
   lgd= legend(hL, [s1,s2,s3], 'DS','PE','Lick');
    
   %add cmap based on shared caxis
   caxis manual;
   caxis([bottom, top]);
   cbar= colorbar(hL); 
   
   title('Legend A')
       
    
    %TODO:
    %saveFig fxn doesnt seem to vectorize heatmaps...
%     saveFig(gcf, figPath, titleFig, figFormats);
    

%     %'contenttype'= 'vector' here does NOT work, way slow
%     titleFig= strcat(titleFig,'.pdf');
%     exportgraphics(gcf, titleFig,'ContentType','image')

    
% ---- export issues...
% % matlab proble- https://stackoverflow.com/questions/27383879/rendering-for-large-matlab-figure-is-slow
% MATLAB releases ever since R2014b use a new graphics engine which is known to be extremely slow with large data sets; see for example http://www.mathworks.com/matlabcentral/newsreader/view_thread/337755
% 
% The solution has nothing to do with graphics drivers etc. Revert back to MATLAB R2014a and stay there.

%maybe https://github.com/dfarrel1/fix_matlab_vector_graphics
% or maybe just different matlab version.

% https://stackoverflow.com/questions/65179763/inconsistencies-with-imagesc-for-matlab-illustrator
%%
%pcolor? tried this before, shape of my vars was off and had to change some
%stuff for axes
figure()
subplot(1,2,1)
title('imagesc');
heat=[];
heat= imagesc(y,x,c);    

subplot(1,2,2);
title('pcolor');
heat2=[];
% heat2= pcolor(y,x,c);    
heat2= pcolor(c);
set(heat2, 'EdgeColor', 'none')
colormap(parula)

% caxis(manual)
% caxis([bottom, top]);
%  saveFig(gcf, figPath, 'testPcolor', figFormats);
    
% %- try export_fig function 
% % requires code from https://github.com/altmany/export_fig
% % also requires ghostscript install
% export_fig(gcf,'testPcolor.pdf');
% 
% % betterish?
% export_fig(f,'test.pdf');
% 
% %eps requires xpdftops installed (download the xpdf command line tools and
% %the .exe is in there)
% export_fig(f,'test.eps');
% 
% %not working

% % try exportgraphics test- doesn't work.
% % In R2020a and later, use the exportgraphics command and specify the 'ContentType' as 'vector': 
%    exportgraphics(gcf, 'output.pdf', 'ContentType', 'vector');
%    % does not work
% % use the print command and include the '-painters' option: 
% %    print(fig, 'output.emf', '-painters'); 
%    print(gcf, 'output2.pdf', '-painters'); 
% 
% 

%% 
    %     %x and y also need flipping
%     figure;
%     imagesc(x2,y2,c2);
% 
%   
%     %actually in old code not plotting true unique x for each trial. only
%     %constant timeLock array
% 
%     
%     %should have 1x601 x, 1x100 y, 100x601 c
%     x3= data3.timeLock(1:bins);
%     x3= x3';
%     
%     y3= [1:trials];
%     
%     c3= reshape(c, [], bins);
%     
%     figure();
%     imagesc(x3,y3,c3);
% 
%     xlabel('seconds from cue onset');
%     ylabel('trial');
%     set(gca, 'ytick', y3); %label trials appropriately
%  
%     
%     figure();
%     imagesc(y3,x3,c3);
%     
%     %still messed up try pcolor
%     figure;
% %     pcolor(x3,y3,c3);
%    
%     h = pcolor(x3,y3,c3);
%     set(h, 'EdgeColor', 'none');
%     
%     %try heatmap
%     %- This works! but needs aesthetic modification
%     % BUT this doesn't support hold so can't plot over.
%     figure(); 
%     h= heatmap(data3,'timeLock','DStrialIDcumcount','ColorVariable','DSblue')
% 
%     h.Colormap= parula;
%     
%     %overlay Cue Onset (-poxDSrel) 
%     scatter(-data3.poxDSrel,data3.DStrialIDcumcount, 'k.');
%     
    
    
    %seems that each row is constant, not changing as fxn of time
    %also rows are time bins regardless of x,y...
    % i think it's automatically making a range of 'trial' values between 1
    % and 2 even though they should be discrete
    
    
    %try pcolor?
%     % c needs to be x-by-y matrix
%     figure;
%     pcolor(x,y,c);
    
    %imagesc by default apparently sets y to reverse
%     imagesc(test.timeLock,test.DStrialIDcumcount,test.DSblue);
%     set(gca,'YDir','normal') 

    
%     %data viz 2d with gramm for debugging
%     figure(); hold on;
%     clear g;
%     g=gramm('x',data3.timeLock,'lightness',data3.DStrialIDcumcount,'y',data3.DSblue, 'group', data3.DStrialIDcumcount);
% 
%     g.geom_line()
%     g.draw();


end


%% LATENCY CORRELATION --------------------------

% TODO: subset sessions for analysis

data= periEventTable;

latencyCorrInputTable= data;

% Limit to data relevant to Fig 3? 
% Stage 7, criteria?

%% Exclude FP signals following PE

  %-- DS trials
  
%signal columns (what to replace with nan)
y=[];
y= ["DSblue", "DSpurple", "DSbluePox", "DSpurplePox"];


%replace signal following first PE for each trial with nan
ind=[];
ind= data.timeLock > data.poxDSrel;

latencyCorrInputTable(ind, y) = table(nan);


%-- dp 2023-03-13 currently excluding data per trial based on real latency
%value
% BUT afterward shuffling 
% so when running stats, have signal timepoints cut off with NA
% corresponding to new shuffled PE latency



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

subjects= unique(data.subject);

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

                %save actual mean latency for plotting overlay
                poxDSrelMean= [];
                poxDSrelMean= nanmean(data4.poxDSrel);
                
                %assign data to output table
                metaColumns= ["stage", "subject", "timeLock"];

                latencyCorrOutputTable(indOutput,metaColumns)= data4(1, metaColumns);

                latencyCorrOutputTable(indOutput,"rhoBlue")= table(rhoBlue); 
                latencyCorrOutputTable(indOutput,"pvalBlue")= table(pvalBlue); 
                latencyCorrOutputTable(indOutput,"rhoBlueShuffled")= table(rhoBlueShuffled); 
                latencyCorrOutputTable(indOutput,"pvalBlueShuffled")= table(pvalBlueShuffled); 

                latencyCorrOutputTable(indOutput,"poxDSrelMean")= table(poxDSrelMean);
                
                indOutput= indOutput+1;            
            end
            

        end
        
        
        %TODO: restrict saving to 1 observation ? Could subset first of
        %each fileID after saving

              
        %-TODO: Shuffled control fp signal
        
    
    end %end subj loop

    
end %end stage loop



%% ------ Load Encoding model output Kernels and Predicted from Python

%-- Load .csv from python 
dfKernelsAll= readtable("C:\Users\Dakota\Documents\GitHub\FP-analysis\python\_output\fig3_df_kernelsAll.csv");

dfPredictedMean= readtable("C:\Users\Dakota\Documents\GitHub\FP-analysis\python\_output\fig3_df_predictedMean.csv");

%% -- Make Encoding model Figures

% use cmap distinct from the DS vs NS (can refine in illustrator)
figure;

clear g;

cmapGrand= cmapPEGrand;
cmapSubj= cmapPESubj;

%-- Fig3- kernels time course trace
data= dfKernelsAll;

% - Individual Subj lines
group= data.subject;

g(1,1)= gramm('x', data.timeShift, 'y', data.beta, 'color', data.eventType, 'group', group);

g(1,1).facet_grid([],data.eventType);


g(1,1).geom_line();

% i2.set_title(titleFig); 
g(1,1).set_color_options('map',cmapSubj);
g(1,1).set_line_options('base_size',linewidthSubj);
g(1,1).set_names('x','Time shift from event (s)','y','Correlation Coefficient (beta)','color','Event Type', 'column', '');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

%remove legend
g(1,1).no_legend();

% % % % set parent uiPanel in overall figure
% g(1,1).set_parent(p2);


%- First Draw call
g(1,1).draw();

% -- Between subjects mean+SEM 
group=[]
g(1,1).update('x', data.timeShift, 'y', data.beta, 'color', data.eventType, 'group', group);

g(1,1).stat_summary('type',errorBar,'geom','area');

g(1,1).set_color_options('map',cmapGrand);
g(1,1).set_line_options('base_size',linewidthGrand);

%remove legend
g(1,1).no_legend();

%- save final draw til end
g(1,1).draw();


%---- Encoding model AUC plot ------
%- Subset data to 1 observation per trial
ind=[];
ind= ~(data.timeShift== .025);
data(ind,'betaAUCpostEvent')= table(nan);

% data= data(~isnan(data.betaAUCpostEvent),:);

% -- Between subjects mean+SEM bar
group=[]
g(2,1)= gramm('x', data.eventType, 'y', data.betaAUCpostEvent, 'color', data.eventType, 'group', group);

g(2,1).stat_summary('type',errorBar,'geom',{'bar'}, 'dodge', dodge, 'width', width);

g(2,1).set_color_options('map',cmapGrand);
g(2,1).set_line_options('base_size',linewidthGrand);

%remove legend
g(2,1).no_legend();

g(1,1).set_color_options('map',cmapSubj);

g(1,1).set_names('x','Event Type','y','AUC of Post-Event Correlation Coefficient','color','Event Type', 'column', '');
g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

% % % % set parent uiPanel in overall figure
% g(1,1).set_parent(p3);


%first draw call
g(2,1).draw();

% -- Individual subjects point
group= data.subject;
g(2,1).update('x', data.eventType, 'y', data.betaAUCpostEvent, 'color', data.eventType, 'group', group);

g(2,1).geom_point();
g(2,1).set_color_options('map',cmapSubj);
g(2,1).set_line_options('base_size',linewidthSubj);

g(2,1).draw();

% -- Individual subjects lines
group= data.subject;
g(2,1).update('x', data.eventType, 'y', data.betaAUCpostEvent, 'color', [], 'group', group);

g(2,1).stat_summary('type',errorBar,'geom','line');
g(2,1).set_color_options('chroma',chromaLineSubj);
g(2,1).set_line_options('base_size',linewidthSubj);

g(2,1).draw();

% -- Grand Errorbars
group=[]
g(2,1).update('x', data.eventType, 'y', data.betaAUCpostEvent, 'color', data.eventType, 'group', group);

g(2,1).stat_summary('type',errorBar,'geom',{'black_errorbar'}, 'dodge', dodge, 'width', width);

g(2,1).set_color_options('map',cmapGrand);
g(2,1).set_line_options('base_size',linewidthGrand);

%- hline at 0 auc
g(2,1).geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 

%save final draw til end
g(2,1).draw();

%---- Fig 3- predicted vs actual time course trace ----

%- subset data
data2=[];

data2= dfPredictedMean;

%- Stack to have signalType as variable (actual vs predicted)
data2= stack(data2, {'y', 'yPredicted'}, 'IndexVariableName', 'typeSignal', 'NewDataVariableName', 'signal');


%-- fig aesthetics
cmapGrand= cmapBlueGrayGrand;
cmapSubj= cmapBlueGraySubj;

%-- Individual lines predicted vs actual trace
group=[];
% - Individual Subj lines
group= data2.subject;

g(3,1)= gramm('x', data2.timeLock, 'y', data2.signal, 'color', data2.typeSignal, 'group', group);

g(3,1).geom_line();

% i2.set_title(titleFig); 
g(3,1).set_color_options('map',cmapSubj);
g(3,1).set_line_options('base_size',linewidthSubj);
g(3,1).set_names('x','Time from DS onset (s)','y','GCaMP (Z-Score)','color','Event Type', 'column', '');

g(3,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

%remove legend
g(3,1).no_legend();

% % % set parent uiPanel in overall figure
% g(3,1).set_parent(p4);
% 

%- First Draw call
g(3,1).draw();

% -- Between subjects mean+SEM 
group=[]
g(3,1).update('x', data2.timeLock, 'y', data2.signal, 'color', data2.typeSignal, 'group', group);

g(3,1).stat_summary('type',errorBar,'geom','area');

g(3,1).set_color_options('map',cmapGrand);
g(3,1).set_line_options('base_size',linewidthGrand);

%remove legend
g(3,1).no_legend();

%- save final draw til end
g(3,1).draw();




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
% title= strcat(subjMode,'-allSubjects-latencyCorrelation-blue-Shuffled-DS');
% i.set_title(titleFig);
% i.set_names('x','time from DS (s)','y','rho (465nm)','color','subject', 'column', 'stage');
% 
% i.draw();
% 
% saveFig(gcf, figPath, titleFig figFormats)


%% -------------------Manuscript Figure 3: Correlation of FP signal with Latency--------------------------

% Shuffled vs. Ordered data stat comparison… 2 way anova or lmm for shuffled vs real signal 
% (is there interaction with time; if not then no need for single timestamp comparisons) 


% --Line plot of coefficients over time Subplot ordered vs shuffled
% stagesToPlot= [5];

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);

%stack table to make signalType (ordered vs shuffled) variable for faceting
data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');


figure();
clear i;

cmapGrand= cmapBlueGrayGrand;
cmapSubj= cmapBlueGraySubj;


%Don't use Lightness facet since importing to illustrator will make
%grouping a problem ... instead use group

    %-individual subj lines
% i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', data.subject);
i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'group', data.subject);


i.stat_summary('type','sem','geom','area');

% i().set_color_options('lightness_range', lightnessRangeSubj) 
i().set_color_options('map', cmapSubj) 

i().set_line_options('base_size', linewidthSubj)
i.draw();

    %-between subj mean+sem
i.update('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', [], 'group', []);

i.stat_summary('type','sem','geom','area');


% i().set_color_options('lightness_range', lightnessRangeGrand); 
i().set_color_options('map', cmapGrand) 

i().set_line_options('base_size', linewidthGrand); 


title= strcat('fig3latcorr');


i.set_title(titleFig);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','latencyOrder');

i().geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); %horizontal line @ 0 (cue onset)


%add vertical line overlay for mean PE latency
latMean= [];
latMean= nanmean(data.poxDSrelMean);
i().geom_vline('xintercept', latMean, 'style', 'm-.', 'linewidth',linewidthReference); %horizontal line @ mean PE

i.axe_property('YLim',[-0.5,0.5]);
i.axe_property('xLim',[-2,5]); %capping at +5s

i.draw();
% saveFig(gcf, figPath, titleFig, figFormats);


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
% i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', data.subject);
i= gramm('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder);


i.stat_summary('type','sem','geom','area');

% i().set_color_options('lightness_range', lightnessRangeSubj) 
% i().set_line_options('base_size', linewidthSubj)

i().set_color_options('map', cmapSubj) 
i().set_line_options('base_size', linewidthSubj); 


i.draw();

    %-between subj mean+sem
i.update('x', data.timeLock, 'y', data.periCueRho, 'color', data.latencyOrder, 'lightness', []);

i.stat_summary('type','sem','geom','area');


i().set_color_options('map', cmapGrand) 
i().set_line_options('base_size', linewidthGrand); 

% i().set_color_options('lightness_range', lightnessRangeGrand); 
% i().set_line_options('base_size', linewidthGrand); 


i.axe_property('YLim',[-1,1]);
% title= strcat(subjMode,'-allSubjects-latencyCorrelation-Figure3-shuffleVsOrderSignif-DS');
title= strcat('-allSubjects-latencyCorrelation-Figure3-shuffleVsOrderSignif-DS');


i.set_title(titleFig);
i.set_names('x','time from DS (s)','y','rho (465nm)','color','latencyOrder');

i.draw();
% saveFig(gcf, figPath, titleFig figFormats);

%% -- Statistical comparison LME to see if rho differs between shuffled/ordered

%stack for real vs shuffled

%-- Rho ~Time , signalType, (1|subject)

ind=[];
ind= (latencyCorrOutputTable.stage==stagesToPlot);

data= latencyCorrOutputTable(ind,:);

data= stack(data, {'rhoBlue', 'rhoBlueShuffled'}, 'IndexVariableName', 'latencyOrder', 'NewDataVariableName', 'periCueRho');


%% --EXPORT AS PARQUET FOR STATS ---
parquetwrite(strcat('vp-vta-fp_stats_fig3_latencyCorr_Table'), data);





%% lme


%convert latencyOrder to dummy variable (retain only one column here as 2
%is redundant)
latencyOrderDummy= dummyvar(data.latencyOrder);

data.latencyOrder= latencyOrderDummy(:,1);

%Stack data to have latencyOrder variable


% lme1= fitlme(data, 'periCueRho~ (timeLock:latencyOrder)+ (1|subject)');
lme1= fitlme(data, 'periCueRho~ timeLock*latencyOrder + (1|subject)');

% can call anova() on lme output to estimate main effects tho.
anova(lme1)

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



% close all;
% 



