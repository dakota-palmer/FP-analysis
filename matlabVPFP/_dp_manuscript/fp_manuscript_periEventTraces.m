%

%% Use GRAMM to make plots

%% Mean peri-DS by stage
%subset specific data to plot
data= periEventTable;

%define variables to plot and grouping 
i=gramm('x',data.timeLock,'y',data.DSblue, 'color',data.subject);

% i.geom_line();

i.facet_wrap(data.stage);

%define stats to show
i.stat_summary('type','sem','geom','area');


%define labels for plot axes
i.set_names('x','time from event (s)','y','z-score','color','subject');
i.set_title('Peri-DS');

%set y axes limits manually
i.axe_property('YLim',[-1,4]);

%draw the actual plot
i.draw();

saveFig(gcf, figPath, 'allSubj-periDS-allStages', figFormats)

%% Mean DS vs NS by stage
%subset specific data to plot
data= periEventTable;

   
%transform to have trialType variable
%ideally want to melt() from wide to long 3 eventTypes into single col
%matlab lacks good tidying functions like melt() but we have stack
%which is quite helpful!
data= stack(data, {'DSblue', 'NSblue'}, 'IndexVariableName', 'trialType', 'NewDataVariableName', 'periCueBlue');


%define variables to plot and grouping 
%ind subjects
i=gramm('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType, 'lightness', data.subject);

% i.geom_line();

i.facet_wrap(data.stage);

%define stats to show
% Mean line for individual subj w/o SEM
% i.stat_summary('type','sem','geom','area');

%define labels for plot axes
i.set_names('x','time from event (s)','y','z-score','color','subject');
i.set_title('Peri-Cue');

%set y axes limits manually
i.axe_property('YLim',[-2,5]);

%draw the actual plot
i.draw();

%mean between subj
i.update('x',data.timeLock,'y',data.periCueBlue, 'color', data.trialType);

i.draw();
% 
% i.update('x',data.timeLock,'y',data.NSblue);
% i.stat_summary('type','sem','geom','area');
% i.draw();

saveFig(gcf, figPath, 'allSubj-periDSvsNS-allStages', figFormats)


%% Stage 7 peri-Cue vs peri-Pox vs peri-Lox
figure();

clear i
%subset data
data= periEventTable(periEventTable.stage==7,:);


%transform to have eventType variable, refined to 3 events x 2 cues
%ideally want to melt() from wide to long 3 eventTypes into single col
%matlab lacks good tidying functions like melt() but we have stack
%which is quite helpful!
data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox', 'NSblue', 'NSbluePox','NSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periCueBlue');

i=gramm('x',data.timeLock,'y',data.DSblue, 'color', data.EventType, 'lightness',data.subject);



% i(1,1)=gramm('x',data.timeLock,'y',data.DSblue, 'color', data.EventType, 'lightness',data.subject);
% i(1,1).stat_summary('type','sem','geom','area');
% i(1,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(1,1).set_title('Peri-DS');
% 
% 
% i(2,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color',data.subject);
% i(2,1).stat_summary('type','sem','geom','area');
% i(2,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(2,1).set_title('Peri-First PE DS');
% 
% i(3,1)=gramm('x',data.timeLock,'y',data.DSblueLox, 'color',data.subject);
% i(3,1).stat_summary('type','sem','geom','area');
% i(3,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(3,1).set_title('Peri-First Lick DS');

i.axe_property('YLim',[-3,8]);
i.set_title('stage 7');

i.draw();


saveFig(gcf, figPath, 'allSubj-periEvent-stage7', figFormats)

%% individual subj all stages: peri-Cue vs peri-Pox vs peri-Lox

for subj= 1:numel(subjects)
    clear i;
    figure();
    %subset data
    data=[];
    data= periEventTable(strcmp(periEventTable.subject, subjects{subj})==1,:);
    
    %transform to have eventType variable
    %ideally want to melt() from wide to long 3 eventTypes into single col
    %matlab lacks good tidying functions like melt() but we have stack
    %which is quite helpful!
    data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
    
%     %keep track of a new variable for eventType color
%     %doing this just so I don't have to manipulate orignal dataframe
%     %just make 3 columns and subset separately to map color for each
%     eventType= cell(size(data,1),3); %3 events, 1 type per observation
%     eventType(:,1)= {'DS'};
%     eventType(:,2)= {'PE DS'};
%     eventType(:,3)= {'Lick DS'};
    
    %define variables to plot and grouping 
%     figure();
%     i=gramm('x',data.timeLock,'y',data.DSblue, 'color', 'eventType');
    i=gramm('x',data.timeLock,'y',data.periEventBlue, 'color', data.eventType);

    
    %facet by stage
    i.facet_wrap(data.stage);

    %means
    i.stat_summary('type','sem','geom','area');
    i.geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0
    
    %label and draw
    i.axe_property('YLim',[-5, 10]);
    i.set_names('x','time from event (s)','y','z-score','color','eventType', 'column', 'stage');
    i.set_title(strcat(subjects{subj},'peri-event-allStages'));

    i.draw();

    
%     i.set_color_options('map','brewer1'); %hacky way to get one color per dataset plotted w/o different column, use 3 distinct maps

%     %periDS pox
% %     i.update('x',data.timeLock,'y',data.DSbluePox);
%     i.stat_summary('type','sem','geom','area'); 
% %     i.set_color_options('map','brewer_dark');
%     i.draw()
% 
%     %periDS lox
%     i.update('x',data.timeLock,'y',data.DSblueLox);
%     i.stat_summary('type','sem','geom','area'); 
%     
%     %label and draw
% %     i.set_color_options('map','matlab');
% 
%     i.set_names('x','Time from Initial Event(sec)','y','GCaMP (z-score)');
% %     i.set_names('color', {'DS','Port Entry DS','Lick DS'});
% 

%     i.draw();


    
% 
%     i(1,1)=gramm('x',data.timeLock,'y',data.DSblue, 'color',data.subject);
%     i(1,1).stat_summary('type','sem','geom','area');
%     i(1,1).set_names('x','time from event (s)','y','z-score','color','subject');
%     i(1,1).set_title('Peri-DS');
% 
% 
%     i(2,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color',data.subject);
%     i(2,1).stat_summary('type','sem','geom','area');
%     i(2,1).set_names('x','time from event (s)','y','z-score','color','subject');
%     i(2,1).set_title('Peri-First PE DS');
% 
%     i(3,1)=gramm('x',data.timeLock,'y',data.DSblueLox, 'color',data.subject);
%     i(3,1).stat_summary('type','sem','geom','area');
%     i(3,1).set_names('x','time from event (s)','y','z-score','color','subject');
%     i(3,1).set_title('Peri-First Lick DS');
% 
%     i.axe_property('YLim',[-1,4]);
%     i.set_title('stage 7');

%     i.draw();
    saveFig(gcf, figPath, strcat(subjects{subj},'-periEvent-allStages'), figFormats)
end



%% Plotting specific subj to compare with kernels
% figure();
% 
% clear i
% %subset data
% data= periEventTable(periEventTable.stage==7,:);
% data= data(strcmp(data.subject,'rat8')==1,:);
% 
% 
% i(1,1)=gramm('x',data.timeLock,'y',data.DSblue, 'color',data.subject);
% i(1,1).stat_summary('type','sem','geom','area');
% i(1,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(1,1).set_title('Peri-DS');
% 
% 
% i(2,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color',data.subject);
% i(2,1).stat_summary('type','sem','geom','area');
% i(2,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(2,1).set_title('Peri-First PE DS');
% 
% i(3,1)=gramm('x',data.timeLock,'y',data.DSblueLox, 'color',data.subject);
% i(3,1).stat_summary('type','sem','geom','area');
% i(3,1).set_names('x','time from event (s)','y','z-score','color','subject');
% i(3,1).set_title('Peri-First Lick DS');
% 
% i.axe_property('YLim',[-1,4]);
% i.set_title('stage 7');
% 
% i.draw();
% 
% saveFig(gcf, figPath, 'rat8-periEvent-stage7', figFormats)

%% TODO: Plot ALL Sessions 

% 
% 
% for subj= 1:numel(subjects)
%     clear i;
%     figure();
%     %subset data
%     data=[];
%     data= periEventTable(strcmp(periEventTable.subject, subjects{subj})==1,:);
%     
%     %transform to have eventType variable
%     %ideally want to melt() from wide to long 3 eventTypes into single col
%     %matlab lacks good tidying functions like melt() but we have stack
%     %which is quite helpful!
%    
% %     data= stack(data, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
%     
% 
%     i=gramm('x',data.timeLock,'y',data.DSblue, 'color', data.DStrialID);
% 
%     
%     %facet by stage
%     i.facet_wrap(data.stage);
% 
%     %means
%     i.stat_summary('type','sem','geom','area');
%     i.geom_vline('xintercept',0, 'style', 'k--'); %overlay t=0
%     
%     %label and draw
%     i.axe_property('YLim',[-5, 10]);
%     i.set_names('x','time from event (s)','y','z-score','color','eventType', 'column', 'stage');
%     i.set_title(strcat(subjects{subj},'peri-event-allStages'));
% 
%     i.draw();
% 
%     
%     
% end
