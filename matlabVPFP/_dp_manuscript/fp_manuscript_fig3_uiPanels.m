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
stagesToPlot= [1:11];

ind=[];
ind= ismember(data.stage, stagesToPlot);

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
% ind=[];
% ind= data.DStrialOutcome==1;
% 
% data= data(ind,:);

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

% close all;
% 



