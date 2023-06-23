% fp_manuscript_fig2
% script combining subplots into large figure

%editing prior code to make one large figure instead of multiple figs

%% default error (sem vs bootstrap CI)
errorBar= 'sem';
% errorBar= 'bootci'; %computationally expensive;

%% set defaults

% for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
% figSize1= [100, 100, 430, 600];
% 
% figSize2= [100, 100, 650, 600];
% 
% %make appropriate size
% figSize= figSize2
% 

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


% text_options_DefaultStyle

% %- set default axes limits between plots for consistency
% %default lims for traces 
% ylimTraces= [-2,5];
% xlimTraces= [-2,10];
% 
% %default lims for AUC plots
% %note xlims best to calculate dynamically for bar plots based on num x categories
% ylimAUC= [-1,16];
%% Scrap copying approach, use uipanels and draw one at a time

%% Figure 2

%for this simply not making figures between gramm objects (dont call
%figure()) then copy to one fig in positions I want 

clear i i2 i1 fig2
close all



% Create the uipanels, the 'Position' property is what will allow to create different sizes (it works the same as the corresponding argument in subplot() )


% Subplots : 2 Rows of 5
    % 1 row of 2 %normalized units of size (% of figure)
    
    
%%
% Initialize a figure with Drawable Area padding appropriately
% f = figure('Position',[100 100 1200 800])

% make figure of desired final size
% f = figure('Position',figSize)


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
%     h= 0.32; %CHANGE HEIGHT
    % making the first 2 a bit taller than third bc several subplots
    h= 0.36; %CHANGE HEIGHT

    
    bPos= 1- h - padHeight;  
    
        %iterations here
%     p1 = uipanel('Position',[padWidth, .7, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
%     p1 = uipanel('Position',[padWidth, .7, w, .30],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
%     p1 = uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p1 = uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
    %Position subsequent panels based on prior panels' Position
    
    % Panel B-  2nd row, full width
        %...height of row 1 + padding
    bPos= (p1.Position(2)) - (p1.Position(4)) - padPanel;
    
    p2 = uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    % Panel C- 3rd row, 1st half width
        %... height of row 1 + 2 + padding
%     bPos= (p2.Position(2)) - (p2.Position(4)) - padPanel; 
%was working fine prior to adding variable bPos & dynamic w above...
%     bPos= (p2.Position(2)) - (p2.Position(4)) - padPanel;

    % redeclare height now for this panel
        % make a bit shorter than first 2
    h= 0.27; %CHANGE HEIGHT

%     h= .25;
%     h= h;

    bPos= (p2.Position(2)) - (h) - padPanel;

      
%     % do full panel with subplots instead of subpanels. for perfect
%     % alignment?
%     w= p2.Position(3);
%     p3= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
%     
   
% %     - old 4 subpanels -


    
        %... width of full row /2
    w= p2.Position(3) / 2 %- padWidth;
        
%     p3= uipanel('Position',[padWidth, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p3= uipanel('Position',[padWidth, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
        

    % Panel D- 3rd row, 2nd half width
        %adjust lPos position to accomodate Panel C width + padding
%     lPos= (p3.Position(3) - p3.Position(1) - padPanel + padWidth);

%     lPos= (w + p3.Position(1) - padPanel + padWidth);
%     lPos= (w + p3.Position(1) - padPanel);
    lPos= (w + p3.Position(1));


%     p4= uipanel('Position',[lPos, bPos, w, .32],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
    p4= uipanel('Position',[lPos, bPos, w, h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%         width 1/2 of Panels A/B
    
%     p2 = uipanel('Position',[padWidth, p1.Position(2)-padPanel, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%     p1 = uipanel('Position',[lPos bPos w h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%     p1 = uipanel('Position',[lPos bPos w h],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

%     p1

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
clear i;
% h= figure();
% figure;

cmapGrand= cmapBlueGrayGrand;
cmapSubj= cmapBlueGraySubj;

% cmapGrand= cmapCueGrand;
% cmapSubj= cmapCueSubj;

% ---- 2023-04-06
 %Mean/SEM update
 %instead of all trials, simplify to mean observation per subject
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
data= groupsummary(data, ["subject","sesSpecialLabel","trialTypeLabel", "timeLock"], "mean",["periCueBlue"]);

% making new field with original column name to work with rest of old code bc 'mean_' is added 
data.periCueBlue= data.mean_periCueBlue;


% individual subjects means
group= data.subject;
i= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group', group);

i.facet_grid([],data.sesSpecialLabel);%, 'column_labels',false);


i().stat_summary('type',errorBar,'geom','line');

i().set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i().set_line_options('base_size',linewidthSubj);
% i().set_names('x','Time from cue (s)','y','GCaMP (Z-score)','color','Cue type (ind subj mean)');

% i.set_names('column','test'); %seems column label needs to come before first draw call

%- Things to do before first draw call-
i.set_names('column', '', 'x', 'Time from cue (s)','y','GCaMP (Z-score)','color','Trial type'); %row/column labels must be set before first draw call

i.no_legend(); %avoid duplicate legend from other plots (e.g. subject & grand colors)
i.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

% titleFig= 'A';   
% i.set_title(titleFig); %overarching fig title must be set before first draw call


% set parent in uipanel of overall figure
i.set_parent(p1);

% % working 
% % i.set_layout_options('legend_position',[.3,.25,.3,.5]); %avoid duplicate legend from other plots (e.g. subject & grand colors)
% 
% %cant get legend_pos without drawing first it seems
% % %try placing legend outside of figure
% % i.no_legend()
% legend_pos=get(i.legend_axe_handle,'Position');
% 
% % i.set_layout_options('legend_position',[-.1,.25,.3,.5]); %avoid duplicate legend from other plots (e.g. subject & grand colors)
% 
% % again, [l,b,w,h]
% i.set_layout_options('legend_position',[0.74 0.25  legend_pos(3) legend_pos(4)]); %avoid duplicate legend from other plots (e.g. subject & grand colors)
% 

% %try detaching legend
% % i.set_layout_options('legend_position',[1,1,1,1]); %avoid duplicate legend from other plots (e.g. subject & grand colors)
% 
% %The no_legend() call allows to remove the space on the left
% i.no_legend()
% legend_pos=get(i.legend_axe_handle,'Position');
% %This places the legend at the desired location (coordinates in the whole figure).
% set(i.legend_axe_handle,'Position',[0.74 0.25  legend_pos(3) legend_pos(4)]);
% i.redraw()


%- first draw call-
i().draw();

% %try detaching legend after drawing
% % i.set_layout_options('legend_position',[1,1,1,1]); %avoid duplicate legend from other plots (e.g. subject & grand colors)
% 
% %The no_legend() call allows to remove the space on the left
% i.no_legend()
% legend_pos=get(i.legend_axe_handle,'Position');
% %This places the legend at the desired location (coordinates in the whole figure).
% set(i.legend_axe_handle,'Position',[0.74 0.25  legend_pos(3) legend_pos(4)]);
% 
% % place legend outside of this uiPanel 
% % not working, though can move within the panel.
% % set(i.legend_axe_handle,'Position',[.08 .05 .1 .1]);
% 
% %maybe try very large distance
% set(i.legend_axe_handle,'Position',[1.5 1.5  legend_pos(3) legend_pos(4)]);
% 
% 
% i.redraw()
% 
% titleFig='test'
% saveFig(gcf, figPath, titleFig, figFormats, figSize2);


%mean between subj + sem
group= [];
i().update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group',group);

i().stat_summary('type',errorBar,'geom','area');

i().set_color_options('map',cmapGrand);

i().set_line_options('base_size',linewidthGrand)

%-set limits
i().axe_property('YLim',ylimTraces);
i().axe_property('XLim',xlimTraces);

i().geom_vline('xintercept',0, 'style', 'k--', 'linewidth', linewidthReference); %overlay t=0


%remove legend
i.no_legend();

%- Final Draw Call
i.draw();

%-initialize overall Figure for complex subplotting
% fig2Handle= figure();


% %-copy to overall Figure as subplot
% %this is a soft copy so need to draw before i is cleared/changed... because i is handle type object..., like if i is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
% fig2(1,1)= copy(i);
% 
% figTest(1,:)= copy(i);

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
% i.draw();

% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');   

% titleFig= strcat('figure2a-learning-fp-periCue');   
% 
% % for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
% figSize1= [100, 100, 430, 600];
% 
% figSize2= [100, 100, 650, 600];

%2022-12-16 playing with figure size
% set(gcf,'Position', figSize1);
% i.redraw()

% % try moving legend
% i.set_layout_options('legend_position',[0,0.5,0.5,0.5]);
% i.draw()
% 
% i.set_layout_options('legend_width',0.10);
% i.redraw()

%try gramm export 
% i.export('file_name',strcat(titleFig,'_Gramm_exported'),'export_Path',figPath,'width',11.5,'units','centimeters')

% titleFig= strcat(titleFig,'matlab_Saved');

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
clear i1; 
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

%-- subset to one observation per trial
%use findgroups to groupby trialIDcum and subset to 1 observation per
groupIDs= [];
groupIDs= findgroups(data2.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

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

% ---- 2023-04-06
 %Mean/SEM update
 %instead of all trials, simplify to mean observation per subject
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
data2= groupsummary(data2, ["subject","sesSpecialLabel","fileID","trialTypeLabel", "timeLock"], "mean",["periCueBlueAuc"]);

% making new field with original column name to work with rest of old code bc 'mean_' is added 
data2.periCueBlueAuc= data2.mean_periCueBlueAuc;



%mean between subj
group=[];
i1= gramm('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i1.facet_grid([],data2.sesSpecialLabel);

i1.set_color_options('map',cmapGrand);

%mean bar for trialType
i1.stat_summary('type',errorBar,'geom',{'bar', 'black_errorbar'}, 'dodge', dodge, 'width', width);

i1.set_line_options('base_size',linewidthGrand)


%- Things to do before first draw call-
i1.set_names('column', '', 'x','Trial Type','y','GCaMP (Z-score)','color','Trial Type');

i1.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

% titleFig= 'B';   
% i1.set_title(titleFig); %overarching fig title must be set before first draw call


%remove legend
i1.no_legend();

% set parent in uipanel of overall figure
i1.set_parent(p2);

%- first draw call-
i1.draw()

%- Draw lines between individual subject points (group= subject, color=[]);
group= data2.subject;
i1.update('x', data2.trialTypeLabel,'y',data2.periCueBlueAuc,'color',[], 'group', group)

% i1.geom_line('alpha',0.3); %individual trials way too much
i1.stat_summary('type',errorBar,'geom','line');

i1.set_line_options('base_size',linewidthSubj);

i1.set_color_options('chroma', chromaLineSubj); %black lines connecting points

i1.draw();

%ind subj mean points
i1.update('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i1.stat_summary('type',errorBar,'geom','point', 'dodge', dodge);

i1.set_color_options('map',cmapSubj); 

i1.no_legend(); %avoid duplicate legend from other plots (e.g. subject  grand colors)

%-set plot limits-

%set x lims and ticks (a bit more manual good for bars)
% lims= [0-.4,(numel(trialTypes)-1)+.4];

xlims= [1-.6,(numel(trialTypes))+.6];

i1.axe_property('XLim',xlims);

i1.axe_property('YLim', ylimAUC);

%horz line @ zero
i1.geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 

%-copy to overall Figure as subplot
%this is a soft copy so need to draw before i1 is cleared/changed... because i1 is handle type object..., like if i1 is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
fig2(2,1)= copy(i1);

figTest(2,:)= copy(i1);
%save drawing until end

% set(0,'CurrentFigure',fig2Handle);%switch to this figure before drawing

% fig2(2,1).draw();

% - final draw call-
% set(0,'CurrentFigure',h);%switch to this figure before drawing

i1().draw();


% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');
% titleFig= strcat('figure2a-learning-fp-periCue_Inlay-AUC');   

% saveFig(gcf, figPath, titleFig, figFormats);


%% Export data for external stats analysis outside of matlab
% 
%export as parquet for python
dataTableFig2B= data2;

% save table as Parquet file
% % https://www.quora.com/When-should-I-use-parquet-file-to-store-data-instead-of-csv
% 
% % test.date= [test.date{:}]'
% 
% % datetime(test.date, 'InputFormat', 'dd/MM/yyyy HH')
% 
% % parquetwrite('test.parquet', test);

% %changing dtype of date, parquet doesn't like cells
% fpTable.date= [fpTable.date{:}]';

parquetwrite(strcat('vp-vta-fp_stats_fig2bTable'), dataTableFig2B);

%-- Report mean number of days taken to reach training criteria
ind= [];
ind = strcmp(dataTableFig2B.sesSpecialLabel, 'stage-5-day-1-criteria');

df= [];
df= dataTableFig2B(ind,:);

%- subset to single observation per session

%-- subset to one observation per trial
%use findgroups to groupby trialIDcum and subset to 1 observation per trial
groupIDs= [];
groupIDs= findgroups(df.fileID);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

df2=table; 
for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
    
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= df(ind,:);

    %now cumulative count of observations in this group
    %make default value=1 for each, and then cumsum() to get cumulative count
    thisGroup(:,'cumcount')= table(1);
    thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
    
%     %save only single observation per trial (get first value)
%     %get observation where timeLock==0
%     ind= [];
%     ind= thisGroup.timeLock==0;
    ind= [];
    ind= thisGroup.cumcount==1;

    df2(thisGroupID,:)= thisGroup(ind,:);
    
end 

% test=groupsummary(df2, ["subject", "trainDay"]);

test=groupsummary(dataTableFig2B, ["subject","sesSpecialLabel"]);



% test=groupsummary(dataTableFig2B, ["subject","sesSpecialLabel","trainDay"]);
% test=groupsummary(dataTableFig2B, ["sesSpecialLabel"], ["trainDay"], 'mean');


%%

% 
% 
% % STATS for AUC plot above
% 
% %-First need to subset to actual # of observations (1 per trial)
% 
% %-Add unique trialIDs
%     %data2 currently has 2 values per timestamp per trial (1 per trialType).
%     %want to transform such that each timestamp copy belongs to distinct
%     %trialID %could simply multiply trialID by -1 if trialType== NS then values %would be unique.
%     
%     %convert to string (stack made this categorical)
%     data2.trialType= string(data2.trialType);
%     
%     %search for NS trialTypes
%     ind=[];
%     ind= contains(data2.trialType, 'NS');
%     
%     %transform trialIDs for these entries to make unique 
%     %muliplying by -1
%     data2(ind, "trialIDcum") = table(data2.trialIDcum(ind) * -1);
%     
% 
% %- aggregate to one observation per trial (AUC is aggregated measure)
%     
%     %columns to group by
% groupers= ["subject","sesSpecialLabel","trainDay", "fileID", "trialType", "trialIDcum"];
% 
%     %simplfy to one observation (using mean)
%  data3= groupsummary(data2, [groupers],'mean', ["periCueBlueAuc"]);
% 
%     %remove appended 'mean_' name on column
%  data3 = renamevars(data3,["mean_periCueBlueAuc"],[,"periCueBlueAuc"]);
%        
% %Result of groupsummary here is table with one auc value per unique trial
% 
% %-- STAT LME
% %are mean AUC different by trialType? lme with random subject intercept
% 
% %- dummy variable conversion
% % converting to dummies(retains only one column, as 2+ is redundant)
% 
% %convert trialType to dummy variable - no, just ensure categorical?
% % dummy=[];
% % dummy= categorical(data3.trialType);
% % dummy= dummyvar(dummy); 
% % 
% % data3.trialType= dummy(:,1);
% 
% % ensure categorical
% data3(:,"trialType")= table(categorical(data3.trialType));
%  
% data3(:,"sesSpecialLabel")= table(categorical(data3.sesSpecialLabel));
% dummyVar(data3.sesSpecialLabel)
% 
% 
% 
% %- run LME
% lme1=[];
% 
% % lme1= fitlme(data3, 'periCueBlueAuc~ trialType + (1|subject)');
% %add stage?
% lme1= fitlme(data3, 'periCueBlueAuc~ trialType * sesSpecialLabel + (1|subject)');
% 
% 
% %print and save results to file
% %seems diary keeps running log to same file (e.g. if code rerun seems prior output remains)
% diary('vp-vta-fp_Figure2_B_-DSvNS-auc-lmeDetails.txt')
% lme1
% diary off
% 
% %-- Followup-- 
% 
% %significant trialType * Stage interaction, so do followups for each stage?
% 
% lme2= [];
% lme2= fitlme(data3, 'periCueBlueAuc~ sesSpecialLabel + stage + (1|subject)');
% 
% % test= multcompare(lmre2)
% 
% test= anova(lme2)



%% -- Figure 2c - PE contingency PE vs no PE trace
% 
% stagesToPlot= [7];
% 
% %---- i(1) pericue z trace
% %subset specific data to plot
% data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);
% 
% %initialize & add binary variable for PE vs noPE
% 
% data(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% % ind=[];
% % ind= ~isnan(data.poxDSrel);
% 
% %trialOutcome coding: 1= PE, 2= noPE, 3=inPort
% outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 
% 
% data(:,'poxDSoutcome')= {outcomeLabels{data.DStrialOutcome}}';
% 
% %unstack based on PE outcome
% groupers= ["subject","stage","date","DStrialID","timeLock"];
% data= unstack(data, 'DSblue', 'poxDSoutcome', 'GroupingVariables',groupers);
% 
% %transform with stack to have trialOutcome variable
% data= stack(data, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlue');
% 
% % figure();
% % clear i
% 
% 
% % individual subjects means
% i2(1,1)= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group', data.subject);
% 
% i2(1,1).stat_summary('type',errorBar,'geom','line');
% i2(1,1).geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0
% 
% i2(1,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map
% 
% titleFig= 'Fig 2c)';   
% i2(1,1).set_title(titleFig); 
% 
% i2(1,1).set_line_options('base_size',linewidthSubj);
% i2(1,1).set_names('x','Time from cue (s)','y','GCaMP (Z-score)','color','Cue type (ind subj mean)');
% 
% i2(1,1).set_parent(p3);
% 
% %- First Draw call
% i2(1,1).draw();
% 
% %mean between subj + sem
% i2(1,1).update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group',[]);
% 
% i2(1,1).stat_summary('type',errorBar,'geom','area');
% 
% i2(1,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map
% 
% i2(1,1).set_line_options('base_size',linewidthGrand)
% 
% i2(1,1).axe_property('YLim',[-1,5]);
% i2(1,1).axe_property('XLim',[-5,10]);
% 
% % title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-periCue-zTraces');   
% 
% % % titleFig= strcat('-stage-',num2str(stagesToPlot),'-Figure2c');      
% i2(1,1).set_names('x','Time from cue (s)','y','GCaMP (Z-score)','color','Cue type (grand mean)');
% 
% 
% % i2(3,1).draw();
% 
% %% when making subplots gramm likes a collective i.draw() after creating
% %each subplot before updating?
% 
% %---- i(2) bar AUC
% data2= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);
% 
% % data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');
% 
% %initialize & add binary variable for PE vs noPE
% data2(:,'poxDSoutcome')= {''}; %table(0);
% % ind=[];
% % ind= ~isnan(data2.poxDSrel);
% % 
% % data2(ind,'poxDSoutcome')= {'PEtrial'};%table(1);
% %trialOutcome coding: 1= PE, 2= noPE, 3=inPort
% outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 
% 
% data2(:,'poxDSoutcome')= {outcomeLabels{data2.DStrialOutcome}}';
% 
% %unstack based on PE outcome
% groupers= ["subject","stage","date","DStrialID","timeLock"];
% data2= unstack(data2, 'aucDSblue', 'poxDSoutcome', 'GroupingVariables',groupers);
% 
% % 
% % data2(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% % ind=[];
% % ind= ~isnan(data.poxDSrel);
% 
% %transform with stack to have trialOutcome variable
% data2= stack(data2, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlueAuc');
% 
% % figure();
% % clear i
% 
% %mean between subj
% i2(1,2)= gramm('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', []);
% 
% i2(1,2).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map
% 
% %mean bar for trialType
% i2(1,2).stat_summary('type',errorBar,'geom',{'bar', 'black_errorbar'});
% 
% i2(1,2).set_line_options('base_size',linewidthGrand)
% 
% i2(1,2).axe_property('YLim',[-1,10]);
% % title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2b-periCue-byPEoutcome-zAUC');   
% titleFig= 'Fig 2d) auc';   
% i2(1,2).set_title(titleFig);
% i2(1,2).set_names('x','Cue type','y','GCaMP (Z-score)','color','Cue type (grand mean)');
% 
% %horz line @ zero
% i2(1,2).geom_hline('yintercept', 0, 'style', 'k--'); 
% 
% fig2(3,1)= copy(i2(1,1));
% 
% i2(1,2).set_parent(p4);
% 
% 
% %2022-12-23
% i2().draw();
% % i2(3,:).draw();
% 
% %ind subj mean points
% i2(1,2).update('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', data2.subject);
% 
% i2(1,2).stat_summary('type',errorBar,'geom','point');
% 
% i2(1,2).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map
% 
% i2(1,2).set_names('x','Cue type','y','GCaMP (Z-score)','color','Cue type (ind subj mean)');
% 
% fig2(3,2)= copy(i2(1,2));
% 
% i2(1,2).draw()


%% Panel 3-  distinct gramm objects for panel C and D


stagesToPlot= [7];

%---- i(1) pericue z trace
%subset specific data to plot
data= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%initialize & add binary variable for PE vs noPE

data(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% ind=[];
% ind= ~isnan(data.poxDSrel);

%trialOutcome coding: 1= PE, 2= noPE, 3=inPort
outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 

data(:,'poxDSoutcome')= {outcomeLabels{data.DStrialOutcome}}';

%unstack based on PE outcome
groupers= ["subject","stage","date","trialIDcum","timeLock"];
data= unstack(data, 'DSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

%transform with stack to have trialOutcome variable
%- only stacking() the 2 outcomes I want, ignoring inPort trial.
data= stack(data, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlue');

%-Remove invalid observations. 
% currently stack() makes a value for each ts for each trial. Remove nan
% values and should be left with single.
data= data(~isnan(data.periCueBlue),:);

% ---- 2023-04-06
 %Mean/SEM update
 %instead of all trials, simplify to mean observation per subject
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
data= groupsummary(data, ["subject","stage","trialOutcome", "timeLock"], "mean",["periCueBlue"]);

% making new field with original column name to work with rest of old code bc 'mean_' is added 
data.periCueBlue= data.mean_periCueBlue;


% figure();
clear i2

% use cmap distinct from the DS vs NS (can refine in illustrator)
cmapGrand= cmapPEGrand;
cmapSubj= cmapPESubj;

% individual subjects means
i2= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group', data.subject);

i2.stat_summary('type',errorBar,'geom','line');
i2.geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

i2.set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

% titleFig= 'C';   
% i2.set_title(titleFig); 

i2.set_line_options('base_size',linewidthSubj);
i2.set_names('x','Time from cue (s)','y','GCaMP (Z-score)','color','Cue type (ind subj mean)');

i2.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

%remove legend
i2.no_legend();

% set parent uiPanel in overall figure
i2.set_parent(p3);


%- First Draw call
i2.draw();

%mean between subj + sem
i2.update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group',[]);

i2.stat_summary('type',errorBar,'geom','area');

i2.set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

i2.set_line_options('base_size',linewidthGrand)

%-set limits
i2.axe_property('YLim',ylimTraces);
i2.axe_property('XLim',xlimTraces);

% title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-periCue-zTraces');   

% % titleFig= strcat('-stage-',num2str(stagesToPlot),'-Figure2c');      
i2.set_names('x','Time from cue (s)','y','GCaMP (Z-score)','color','Cue type (grand mean)');

%remove legend
i2.no_legend();

%-set limits
i2.axe_property('YLim',ylimTraces);
i2.axe_property('XLim',xlimTraces);

%- Final draw call
i2().draw();

%% Panel D- AUC

%---- i(2) bar AUC
data2=[];
data2= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

%-- subset to one observation per trial
%use findgroups to groupby trialIDcum and subset to 1 observation per trial
groupIDs= [];
groupIDs= findgroups(data2.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

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

%initialize & add binary variable for PE vs noPE
data2(:,'poxDSoutcome')= {''}; %table(0);
% ind=[];
% ind= ~isnan(data2.poxDSrel);
% 
% data2(ind,'poxDSoutcome')= {'PEtrial'};%table(1);
%trialOutcome coding: 1= PE, 2= noPE, 3=inPort
outcomeLabels= {'PEtrial','noPEtrial','inPortTrial'}; %1,2,3 

data2(:,'poxDSoutcome')= {outcomeLabels{data2.DStrialOutcome}}';

%unstack based on PE outcome
groupers= ["subject","stage","date","trialIDcum","timeLock"];
data2= unstack(data2, 'aucDSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

% 
% data2(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% ind=[];
% ind= ~isnan(data.poxDSrel);

%transform with stack to have trialOutcome variable
data2= stack(data2, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlueAuc');

%-Remove invalid observations. 
% currently stack() makes a value for each ts for each trial. Remove nan
% values and should be left with single.
data2= data2(~isnan(data2.periCueBlueAuc),:);

% ---- 2023-04-06
 %Mean/SEM update
 %instead of all trials, simplify to mean observation per subject
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
data2= groupsummary(data2, ["subject","stage","trialOutcome", "timeLock"], "mean",["periCueBlueAuc"]);

% making new field with original column name to work with rest of old code bc 'mean_' is added 
data2.periCueBlueAuc= data2.mean_periCueBlueAuc;


% figure();
clear i3

% use cmap distinct from the DS vs NS (can refine in illustrator)
cmapGrand= cmapPEGrand;
cmapSubj= cmapPESubj;

%mean between subj
i3= gramm('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', []);

i3.set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

%mean bar for trialType
i3.stat_summary('type',errorBar,'geom',{'bar', 'black_errorbar'}, 'dodge', dodge, 'width', width);

i3.set_line_options('base_size',linewidthGrand)

i3.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

% % i3.axe_property('YLim',[-1,10]);
% % title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2b-periCue-byPEoutcome-zAUC');   
% titleFig= 'D';   
% i3.set_title(titleFig);
i3.set_names('x','Cue type','y','GCaMP (Z-score)','color','Cue type (grand mean)');

%horz line @ zero
i3.geom_hline('yintercept', 0, 'style', 'k--'); 


xlims= [1-.6,(numel(trialTypes))+.6];

i3.axe_property('XLim',xlims);
i3.axe_property('YLim',ylimAUC);

%remove legend
i3.no_legend();

% set parent uiPanel in overall figure
i3.set_parent(p4);

%-First draw call
i3.draw();

%- Draw lines between individual subject points (group= subject, color=[]);
group= data2.subject;
i3.update('x', data2.trialOutcome,'y',data2.periCueBlueAuc,'color',[], 'group', group)

% i1.geom_line('alpha',0.3); %individual trials way too much
i3.stat_summary('type',errorBar,'geom','line');

i3.set_line_options('base_size',linewidthSubj);

i3.set_color_options('chroma', chromaLineSubj); %black lines connecting points

i3.draw();


%-ind subj mean points
i3.update('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', data2.subject);

i3.stat_summary('type',errorBar,'geom','point');

i3.set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i3.set_names('x','Trial outcome','y','GCaMP (Z-score)','color','Cue type (ind subj mean)');

fig2(3,2)= copy(i3);

%remove legend
i3.no_legend();

%-set limits
trialTypes= unique(data2.trialOutcome);

xlims= [1-.6,(numel(trialTypes))+.6];
i3.axe_property('XLim',xlims);

i3.axe_property('YLim',ylimAUC);

%- Final draw call
i3.draw()


%% Export data for external stats analysis outside of matlab
% 
%export as parquet for python
dataTableFig2D= data2;

% save table as Parquet file
% % https://www.quora.com/When-should-I-use-parquet-file-to-store-data-instead-of-csv
% 
% % test.date= [test.date{:}]'
% 
% % datetime(test.date, 'InputFormat', 'dd/MM/yyyy HH')
% 
% % parquetwrite('test.parquet', test);

% %changing dtype of date, parquet doesn't like cells
% fpTable.date= [fpTable.date{:}]';

parquetwrite(strcat('vp-vta-fp_stats_fig2dTable'), dataTableFig2D);




%% Save the figure

%-Declare Size of Figure at time of creation (up top), not time of saving.

%- Remove borders of UIpanels prior to save
p1.BorderType= 'none'
p2.BorderType= 'none'
p3.BorderType= 'none'
p4.BorderType= 'none'


%-Save the figure
% titleFig='vp-vta_Figure2_uiPanels_colorA';
titleFig='vp-vta_Figure2_uiPanels';

saveFig(gcf, figPath, titleFig, figFormats, figSize);


%% TODO: STATS for this Figure (save output)

%% AUC Stats



%% Draw the Figure2
%scrapping

% %-- make overall fig adjustments
% titleFig= 'Fig 2';   
% fig2().set_title(titleFig); %overall


%- layout
% fig2(1,1).set_layout_options('Position',[0 0.8 0.8 0.2],... %Set the position in the figure (as in standard 'Position' axe property)
%     'legend',false,... % No need to display legend for side histograms
%     'margin_height',[0.02 0.05],... %We set custom margins, values must be coordinated between the different elements so that alignment is maintained
%     'margin_width',[0.1 0.02],...
%     'redraw',false); %We deactivate automatic redrawing/resizing so that the axes stay aligned according to the margin options

% fig2(1,1).set_layout_options('Position','auto',...
%     'legend',false,... % No need to display legend for side histograms
%     'margin_height',[0.02 0.05],... %We set custom margins, values must be coordinated between the different elements so that alignment is maintained
%     'margin_width',[0.1 0.02],...
%     'redraw',false); %We deactivate automatic redrawing/resizing so that the axes stay aligned according to the margin options

% fig2(1,1).set_layout_options('legend',false,... % No need to display legend for side histograms
%     'margin_height',[0.02 0.05],... %We set custom margins, values must be coordinated between the different elements so that alignment is maintained
%     'margin_width',[0.1 0.02])
% 
% fig2(2,1).set_layout_options('legend',false,... % No need to display legend for side histograms
%     'margin_height',[0.02 0.05],... %We set custom margins, values must be coordinated between the different elements so that alignment is maintained
%     'margin_width',[0.1 0.02])
% 
% fig2(3,1).set_layout_options('legend',false,... % No need to display legend for side histograms
%     'margin_height',[0.02 0.05],... %We set custom margins, values must be coordinated between the different elements so that alignment is maintained
%     'margin_width',[0.1 0.02])
% 

%todo: 
%- eliminate redundant legends
%- maybe set_layout options('legend') will help?

%- fix suplot proportions/positions

%- having some issues with layout of subplots
% maybe set_layout_options( 'position'
% [left bottom width height]  ) will help?

% fig2(1,1).set_layout_options('po
% 

%doesnt work alone
% fig2(:).set_layout_options('legend','false');
%try loop thru?
% fig2(1,1).set_layout_options('legend','false');
% fig2(2,1).set_layout_options('legend','false');
% fig2(3,1).set_layout_options('legend','false');
% fig2(3,2).set_layout_options('legend','false');

% %no_legend might work- nope
% fig2.no_legend(); %error
% fig2(1,1).no_legend();
% fig2(2,1).no_legend();
% fig2(3,1).no_legend();
% fig2(3,2).no_legend();

% sizeSubplot= ['auto', 'auto', 200, 100];
% 
% 
% fig2(1,1).set_layout_options('position', sizeSubplot);
% 
% fig2(:).set_layout_options('position', sizeSubplot);

%examine in inspector

%changing fig2 doesn't seem to work, try changing original gramm objects.
% i(1,1).no_legend();
% i1(1,1).no_legend();


% %none of the set_layout_options stuff seems to work so try uipanels
% 
% fig2(1,1).set_parent(p1);
% fig2(2,1).set_parent(p2);
% fig2(3,1).set_parent(p3);
% fig2(3,2).set_parent(p4);
% 
% 
% %- try separate draws()?
% % doesnt work.
% % fig2(1,1).draw();
% % fig2(2,1).draw();
% 
% %- try setting parent on original gramm objects instead of the fig2 copy
% % doesnt work here. probably bc already drawn.
% % i.set_parent(p1);
% % i1.set_parent(p2);
% % i2(1,1).set_parent(p3);
% % i2(1,2).set_parent(p4);
% 
% 
% %- maybe need no prior draws. probably
% 
% 
% fig2.draw();


% fig2(1,1).set_layout_options('position', sizeSubplot);
% 
% fig2(:).set_layout_options('position', sizeSubplot);


% fig2.redraw();


% fig2(:).set_layout_options('legend',false);
% 
% fig2.redraw();

% titleFig= 'Figure2_Final';
% fig2.export('file_name',strcat(titleFig,'_Gramm_exported'),'export_Path',figPath,'width',11.5,'units','centimeters')


