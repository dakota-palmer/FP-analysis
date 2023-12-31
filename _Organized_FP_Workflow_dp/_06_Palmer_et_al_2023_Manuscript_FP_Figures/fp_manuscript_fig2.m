% fp_manuscript_fig2
% script combining subplots into large figure

%editing prior code to make one large figure instead of multiple figs

%% Figure 2

%for this simply not making figures between gramm objects (dont call
%figure()) then copy to one fig in positions I want 

clear i i2 i1 fig2
close all

%initialize figure?

% for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
figSize1= [100, 100, 430, 600];

figSize2= [100, 100, 650, 600];


% Create the uipanels, the 'Position' property is what will allow to create different sizes (it works the same as the corresponding argument in subplot() )


% Subplots : 2 Rows of 5
    % 1 row of 2 %normalized units of size (% of figure)
    
    
%%
%make appropriate size
% Initialize a figure with Drawable Area padding appropriately
f = figure('Position',[100 100 1200 800])
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
    padPanel= 0.02
    
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
padWidth= 0.005; %padding from width of Figure

padPanel= 0.005; %padding between other uiPanels

    % Panel A- Top row, full width
    p1 = uipanel('Position',[padWidth, .7, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    %Position subsequent panels based on prior panels' Position
    
    % Panel B-  2nd row, full width
        %...height of row 1 + padding
    bPos= (p1.Position(2)) - (p1.Position(4)) - padPanel;
    
    p2 = uipanel('Position',[padWidth, bPos, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    % Panel C- 3rd row, 1st half width
        %... height of row 1 + 2 + padding
    bPos= (p2.Position(2)) - (p2.Position(4)) - padPanel;

        %... width of full row /2
    w= p2.Position(3) / 2;
        
    p3= uipanel('Position',[padWidth, bPos, w, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')
        
    % Panel D- 3rd row, 2nd half width
        %adjust lPos position to accomodate Panel C width + padding
    lPos= (p3.Position(3) - p3.Position(1) - padPanel);
    
    p4= uipanel('Position',[lPos, bPos, w, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
        %width 1/2 of Panels A/B
    
%     p2 = uipanel('Position',[padWidth, p1.Position(2)-padPanel, .95, .3],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%     p1 = uipanel('Position',[lPos bPos w h],'Units','Normalized','Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    
%     p1 = uipanel('Position',[lPos bPos w h],'Parent',f,'BackgroundColor',[1 1 1],'BorderType','etchedout')

    

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


% individual subjects means
i= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialTypeLabel, 'group', data.subject);

i.facet_grid([],data.sesSpecialLabel);%, 'column_labels',false);


i().stat_summary('type','sem','geom','line');

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

%-set limits
i().axe_property('YLim',[-1,5]);
i().axe_property('XLim',[-2,10]);

i().geom_vline('xintercept',0, 'style', 'k--', 'linewidth', linewidthReference); %overlay t=0

%-initialize overall Figure for complex subplotting
% fig2Handle= figure();


%-copy to overall Figure as subplot
%this is a soft copy so need to draw before i is cleared/changed... because i is handle type object..., like if i is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
fig2(1,1)= copy(i);

figTest(1,:)= copy(i);

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

titleFig= strcat('figure2a-learning-fp-periCue');   

% for JNeuro, 1.5 Col max width = 11.6cm (~438 pixels); 2 col max width = 17.6cm (~665 pixels)
figSize1= [100, 100, 430, 600];

figSize2= [100, 100, 650, 600];

%2022-12-16 playing with figure size
% set(gcf,'Position', figSize1);
% i.redraw()

% i.set_layout_options('legend_position',0,0.5,0.5,0.5]);
% i.draw()
% 
% i.set_layout_options('legend_width',0.10);
% i.redraw()

%try gramm export 
% i.export('file_name',strcat(titleFig,'_Gramm_exported'),'export_Path',figPath,'width',11.5,'units','centimeters')

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
i1= gramm('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i1.facet_grid([],data.sesSpecialLabel);

i1.set_color_options('map',cmapGrand);

%mean bar for trialType
i1.stat_summary('type','sem','geom',{'bar', 'black_errorbar'}, 'dodge', dodge, 'width', width);

i1.set_line_options('base_size',linewidthGrand)


%- Things to do before first draw call-
i1.set_names('column', '', 'x','Trial Type','y','GCaMP (Z-score)','color','Trial Type');

i1.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

titleFig= 'Fig 2b) auc';   
i1.set_title(titleFig); %overarching fig title must be set before first draw call

%- first draw call-
i1.draw()

%- Draw lines between individual subject points (group= subject, color=[]);
group= data2.subject;
i1.update('x', data2.trialTypeLabel,'y',data2.periCueBlueAuc,'color',[], 'group', group)

% i1.geom_line('alpha',0.3); %individual trials way too much
i1.stat_summary('type','sem','geom','line');

i1.set_line_options('base_size',linewidthSubj);

i1.set_color_options('chroma', chromaLineSubj); %black lines connecting points

i1.draw();

%ind subj mean points
i1.update('x',data2.trialTypeLabel,'y',data2.periCueBlueAuc, 'color', data2.trialTypeLabel, 'group', group);

i1.stat_summary('type','sem','geom','point', 'dodge', dodge);

i1.set_color_options('map',cmapSubj); 

i1.no_legend(); %avoid duplicate legend from other plots (e.g. subject  grand colors)

%-set plot limits-

%set x lims and ticks (a bit more manual good for bars)
% lims= [0-.4,(numel(trialTypes)-1)+.4];

lims= [1-.6,(numel(trialTypes))+.6];


i1.axe_property('XLim',lims);

i1.axe_property('YLim',[-1,16]);

%horz line @ zero
i1.geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 

%-copy to overall Figure as subplot
%this is a soft copy so need to draw before i1 is cleared/changed... because i1 is handle type object..., like if i1 is deleted here you can't draw it again see https://www.mathworks.com/help/matlab/matlab_prog/copying-objects.html
fig2(2,1)= copy(i1);

figTest(2,:)= copy(i1);
%save drawing until end

% set(0,'CurrentFigure',fig2Handle);%switch to this figure before drawing

% fig2(2,1).draw();

%- final draw call-
% set(0,'CurrentFigure',h);%switch to this figure before drawing

% i1().draw();


% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');
titleFig= strcat('figure2a-learning-fp-periCue_Inlay-AUC');   

% saveFig(gcf, figPath, titleFig, figFormats);


%% -- Figure 2c - PE contingency PE vs no PE trace

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
groupers= ["subject","stage","date","DStrialID","timeLock"];
data= unstack(data, 'DSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

%transform with stack to have trialOutcome variable
data= stack(data, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlue');

% figure();
% clear i


% individual subjects means
i2(1,1)= gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group', data.subject);

i2(1,1).stat_summary('type','sem','geom','line');
i2(1,1).geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0

i2(1,1).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

titleFig= 'Fig 2c)';   
i2(1,1).set_title(titleFig); 

i2(1,1).set_line_options('base_size',linewidthSubj);
i2(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (ind subj mean)');

i2(1,1).draw();

%mean between subj + sem
i2(1,1).update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialOutcome, 'group',[]);

i2(1,1).stat_summary('type','sem','geom','area');

i2(1,1).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

i2(1,1).set_line_options('base_size',linewidthGrand)

i2(1,1).axe_property('YLim',[-1,5]);
i2(1,1).axe_property('XLim',[-5,10]);

% title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2-periCue-zTraces');   

% % titleFig= strcat('-stage-',num2str(stagesToPlot),'-Figure2c');      
i2(1,1).set_names('x','time from Cue (s)','y','GCaMP (z score)','color','Cue type (grand mean)');


% i2(3,1).draw();

%% when making subplots gramm likes a collective i.draw() after creating
%each subplot before updating?

%---- i(2) bar AUC
data2= periEventTable(ismember(periEventTable.stage, stagesToPlot),:);

% data2= stack(data2, {'aucDSblue', 'aucNSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlueAuc');

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
groupers= ["subject","stage","date","DStrialID","timeLock"];
data2= unstack(data2, 'aucDSblue', 'poxDSoutcome', 'GroupingVariables',groupers);

% 
% data2(:,'poxDSoutcome')= {''};%{'noPEtrial'}; %table(0);
% ind=[];
% ind= ~isnan(data.poxDSrel);

%transform with stack to have trialOutcome variable
data2= stack(data2, {'noPEtrial', 'PEtrial'}, 'IndexVariableName', 'trialOutcome', 'NewDataVariableName', 'periCueBlueAuc');

% figure();
% clear i

%mean between subj
i2(1,2)= gramm('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', []);

i2(1,2).set_color_options('map',cmapGrand); %subselecting the 2 specific color levels i want from map

%mean bar for trialType
i2(1,2).stat_summary('type','sem','geom',{'bar', 'black_errorbar'});

i2(1,2).set_line_options('base_size',linewidthGrand)

i2(1,2).axe_property('YLim',[-1,10]);
% title= strcat(subjMode,'-allSubjects-stage-',num2str(stagesToPlot),'-Figure2b-periCue-byPEoutcome-zAUC');   
titleFig= 'Fig 2d) auc';   
i2(1,2).set_title(titleFig);
i2(1,2).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (grand mean)');

%horz line @ zero
i2(1,2).geom_hline('yintercept', 0, 'style', 'k--'); 

fig2(3,1)= copy(i2(1,1));

%2022-12-23
i2().draw();
% i2(3,:).draw();

%ind subj mean points
i2(1,2).update('x',data2.trialOutcome,'y',data2.periCueBlueAuc, 'color', data2.trialOutcome, 'group', data2.subject);

i2(1,2).stat_summary('type','sem','geom','point');

i2(1,2).set_color_options('map',cmapSubj); %subselecting the 2 specific color levels i want from map

i2(1,2).set_names('x','Cue type','y','GCaMP (z score)','color','Cue type (ind subj mean)');

fig2(3,2)= copy(i2(1,2));

i2(1,2).draw()



%% Draw the Figure2

%-- make overall fig adjustments
titleFig= 'Fig 2';   
fig2().set_title(titleFig); %overall


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


%none of the set_layout_options stuff seems to work so try uipanels

fig2(1,1).set_parent(p1);
fig2(2,1).set_parent(p2);
fig2(3,1).set_parent(p3);
fig2(3,2).set_parent(p4);


%- try separate draws()?
% doesnt work.
% fig2(1,1).draw();
% fig2(2,1).draw();

%- try setting parent on original gramm objects instead of the fig2 copy
% doesnt work here. probably bc already drawn.
% i.set_parent(p1);
% i1.set_parent(p2);
% i2(1,1).set_parent(p3);
% i2(1,2).set_parent(p4);


%- maybe need no prior draws. probably


fig2.draw();


% fig2(1,1).set_layout_options('position', sizeSubplot);
% 
% fig2(:).set_layout_options('position', sizeSubplot);


% fig2.redraw();


% fig2(:).set_layout_options('legend',false);
% 
% fig2.redraw();

titleFig= 'Figure2_Final';
% fig2.export('file_name',strcat(titleFig,'_Gramm_exported'),'export_Path',figPath,'width',11.5,'units','centimeters')


