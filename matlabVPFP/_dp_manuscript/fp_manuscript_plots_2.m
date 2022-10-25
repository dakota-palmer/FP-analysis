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

%dark, thick lines for between subj grand mean
linewidthGrand= 1.5;

%thicker lines for reference lines
linewidthReference= 2;

%% Load periEventTable from fp_manuscript_figs.m --

% for now assume preprocessing experimental all sessions

pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-19-Oct-2022periEventTable.mat";

% for now loads as 'data' struct
load(pathData);

% get contents and clear
% periEventTable= data;
% clear data


%% ----------------- LABEL SPECIAL SESSIONS -----------------------------
%label specific sessions for plotting

%overwrite old labels
% periEventTable(:,'sesSpecialLabel')= {''};

%manually find and assign specialSesLabels based on criteria

%--first day of stage 1 - is there an innate cue response?
ind= [];
ind= periEventTable.stage==1;


ind2= [];
ind2= periEventTable.trainDayThisStage==1;

ind3=[];
ind3= ind & ind2;

periEventTable(ind3, 'sesSpecialLabel')= {'First Session-Stage1'};


%--first day of stage 5 - NS introduced
ind= [];
ind= periEventTable.stage==5;


ind2= [];
ind2= periEventTable.trainDayThisStage==1;

ind3=[];
ind3= ind & ind2;

periEventTable(ind3, 'sesSpecialLabel')= {'NS Introduced-Stage5'};

%TODO: this complicates bc day differs between animals
%--first day of criteria stage 5- discriminating
% % %for now just keep old labels
% % 
% % ind= [];
% % ind= periEventTable.stage==5;
% % 
% % 
% % ind2= [];
% % ind2= periEventTable.criteriaSes==1;
% % 
% % ind3=[];
% % ind3= ind && ind2;
% % 
% % ind= [];
% % ind= periEventTable.trainDayThisStage
% 
% periEventTable(ind3, 'specialSesLabel')= {'NS Introduced-Stage5'};


%% ----------------- Figure 2---------------------------------------------------

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

%- final draw call
i.draw() 

% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');   

titleFig= strcat('figure2a-learning-fp-periCue');   

saveFig(gcf, figPath, titleFig, figFormats);

%% Fig 2a ----- Bar plots of AUC ------
clear i; figure;

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

i.axe_property('YLim',[-1,16]);

%horz line @ zero
i.geom_hline('yintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 


%- final draw call-
i().draw();


% titleFig= strcat(subjMode,'-allSubjects-','-Figure2-learning-periCue-zTraces');
titleFig= strcat('figure2a-learning-fp-periCue_Inlay-AUC');   

saveFig(gcf, figPath, titleFig, figFormats);

%% TODO: -----------------------FIGURE 2B --------------

%% TRYING FIG3 HEATPLOTS ---

% tried in gramm, not really supported or at least not intuitive and not worth effort
%going with  matlab imagesc heatplots

% clear i; figure;

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1

% subset data
data= periEventTable;

% subset data- by stage
stagesToPlot= [7];

ind=[];
ind= ismember(data.stage, stagesToPlot);

data= data(ind,:);

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

% data2= find(ismember(data2.trialIDcum,test,'row'))

% groupIDs= [];
% groupIDs= findgroups(data2.trialIDcum);
% 
% groupIDsUnique= [];
% groupIDsUnique= unique(groupIDs);
% 
% %go through and cumcount the timestamps in each trialID, then sort only
% %first observation in each by latency
% for thisGroupID= 1:numel(groupIDsUnique)
%     %for each groupID, find index matching groupID
%     ind= [];
%     ind= find(groupIDs==groupIDsUnique(thisGroupID));
%     
%     %for each groupID, get the table data matching this group
%     thisGroup=[];
%     thisGroup= data2(ind,:);
%     
%     %now cumulative count of observations in this group
%     %make default value=1 for each, and then cumsum() to get cumulative count
%     thisGroup(:,'cumcount')= table(1);
%     thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
%     
%     %specific code for trainDayThisPhase
%     %assign back into table
%     data2(ind, 'cumcountTrialID')= table(thisGroup.cumcount);
% end

% %-- heatplot figure
% 
top= 15;
bottom= -5;

% % For each subject
subjects= unique(data2.subject);
for subj= 1:numel(subjects);

    ind=[];
    ind= strcmp(data2.subject, subjects{subj});
    
    data3= data2(ind,:);
    
    %make figure
    figure(); hold on;
    imagesc(data3.timeLock,data3.DStrialIDcumcount,data3.DSblue);

    %overlay Cue Onset (-poxDSrel) 
    scatter(-data3.poxDSrel,data3.DStrialIDcumcount, 'k.');
    
    caxis manual;
    caxis([bottom,top]); %use a shared color axis to encompass all values

    c= colorbar; %colorbar legend

    xlabel('seconds from PE');

    %x is just wrong... timelock should end at +10
    %test individual trial
%     test= data3(data3.DStrialIDcumcount<=3,:);

    test=data3;

    figure(); hold on;
    imagesc(test.timeLock,test.DStrialIDcumcount,test.DSblue);

    %bad, should be flipped
    figure;
    imagesc(test.DStrialIDcumcount,test.timeLock,test.DSblue); %doesnt work?

    %get rid of table format
    x=[], y=[], c=[];
    x= (test.timeLock);
    y= (test.DStrialIDcumcount);
    c= (test.DSblue);
    
    figure;
    imagesc(x,y,c);
    view([90 -90]) %// instead of normal view, which is view([0 90])

    
    figure;
    imagesc(y,x,c);
    
    view([90 -90]) %// instead of normal view, which is view([0 90])

    %looking at old code, input to imagesc is in columns. try this
    %and the c is 601x100 so one column per trial..probs needs to be
    %pivoted/stacked...
    x2= x';
    y2= y';
    c2= c';
        
    figure;
    imagesc(y,x,c);
    
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

    % ---- this one looks good ---
        
    overlayAlpha= .2;
    overlayPointSize= 10; %default i think is 10
    
    
    figure;
    imagesc(y,x,c2);
    view([-90, 90]) %// instead of normal view, which is view([0 90])
    
    hold on;
    %overlay Cue Onset (-poxDSrel) 
    %     scatter(-data3.poxDSrel,data3.DStrialIDcumcount, 'k.');
    % ^ order adjusted bc imagesc
    
    %overlay cue onset

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
    %try heatmap
    %- This works! but needs aesthetic modification
    % BUT this doesn't support hold so can't plot over.
    figure(); 
    h= heatmap(data3,'timeLock','DStrialIDcumcount','ColorVariable','DSblue')

    h.Colormap= parula;
    
    %overlay Cue Onset (-poxDSrel) 
    scatter(-data3.poxDSrel,data3.DStrialIDcumcount, 'k.');
    
    
    
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

    
    %data viz 2d with gramm for debugging
    figure(); hold on;
    clear g;
    g=gramm('x',data3.timeLock,'lightness',data3.DStrialIDcumcount,'y',data3.DSblue, 'group', data3.DStrialIDcumcount);

    g.geom_line()
    g.draw();
end

close all;


%use findgroups to groupby trial and sort?


%use findgroups to groupby subject,trainPhaseLabel and manually cumcount() for
%sessions within-trainPhaseLabel

%subset to only one ts per trial
ind= [];
ind= data2.timeLock==0;

data3= data2(ind,:);

%sort by latency for this Subject within-stage
groupIDs= [];
groupIDs= findgroups(data3.subject, data3.stage,data3.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

%go through and cumcount the timestamps in each trialID, then sort only
%first observation in each by latency
for thisGroupID= 1:numel(groupIDsUnique)
    %for each groupID, find index matching groupID
    ind= [];
    ind= find(groupIDs==groupIDsUnique(thisGroupID));
    
    %for each groupID, get the table data matching this group
    thisGroup=[];
    thisGroup= data3(ind,:);
    
    %now cumulative count of observations in this group
    %make default value=1 for each, and then cumsum() to get cumulative count
    thisGroup(:,'cumcount')= table(1);
    thisGroup(:,'cumcount')= table(cumsum(thisGroup.cumcount));
    
    %specific code for trainDayThisPhase
    %assign back into table
    data3(ind, 'cumcountTrialID')= table(thisGroup.cumcount);
    
    
    %Now use this for each 
    %for each groupID, sort the data by PE latency
    indSort= []; trialIDsort=[];
    [~, indSort]= sort(thisGroup.poxDSrel);
   
    %get the sorted trialIDs and use to sort whole data
    
%     %sort this subset
%     data4=[];
%     data4= thisGroup(indSort,:);
    
    %now get the sorted trialIDs
    trialIDsort= thisGroup.trialIDcum;
    
        %dp 2022-10-21 in progress

    %match up these trialIDs with those in the whole dataset?
    
    trialsOG= [];
    
    trialsOG= data2.trialIDcum;
    
    %initialize new 'observation' column for exclusion of repeat
    %observations
    data2(:,'observation')= table(nan);
    
    for thisTrial= 1:numel(trialIDsort)
        ind2=[]; 

        ind2= (trialIDsort(thisTrial)==trialsOG);
        
        data2(ind2,'observation')= table(1);
        
    end
    
    %now get rid of redundant (invalid) observations (nan)
    ind2= [];
    ind2= data2.observation~=1;
    
    data2(ind2, 'poxDSrel')= table(nan);
    
%     ind= find(data.trialIDcum==trialIDsort);
  
end 


%-- heatplot figure

% For each subject
subjects= unique(data2.subject);
for subj= 1:numel(subjects);

    ind=[];
    ind= strcmp(data2.subject, subjects{subj});
    
    data3=[];
    data3= data2(ind,:);
    
    %make figure
    figure(); hold on;
    imagesc(data3.timeLock,data3.trialIDcumcount,data3.DSblue);

    %overlay Cue Onset (-poxDSrel) 
    scatter(-data3.poxDSrel,data3.trialIDcumcount, 'k.');
    
end



%-- Make Fig
figure();
subplot(1,3,1);
heatDSzpoxpurpleAllTrials= imagesc(timeLock,currentSubj(1).totalDScount,currentSubj(1).DSzpoxpurpleAllTrials); 

title(strcat(subjData.(subjects{subj})(1).experiment, ' : ', num2str(subjectsAnalyzed{subj}), ' purple z score response surrounding first PE in DS epoch')) %'(n= ', num2str(unique(trialDSnum)),')')); 
xlabel('seconds from PE');
ylabel(strcat('DS trial (n= ', num2str(currentSubj(1).totalDScount(end)), ')'));

%     set(gca, 'ytick', currentSubj(1).totalDScount); %label trials appropriately

caxis manual;
caxis([bottomAllShared topAllShared]); %use a shared color axis to encompass all values

c= colorbar; %colorbar legend
c.Label.String= strcat('DS purple z-score calculated from', num2str(slideTime/fs), 's preceding DS');

set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving








