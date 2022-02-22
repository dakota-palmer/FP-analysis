%% Collect peri-event traces for each eventType
%save data into table for later subplotting 
% events= {'DS','NS','pox','lox'}

%% Fig settings
% figPath= 'C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\';
% figFormats= {'.fig','.png'}; %list of formats to save figures as (for saveFig.m)



%% Preallocate table with #rows equal to observations per session
subjects= fieldnames(subjDataAnalyzed);
sesCount= 0;
for subj= 1:numel(subjects) %for each subject analyzed
    currentSubj= subjDataAnalyzed.(subjects{subj});

    for session = 1:numel(currentSubj) 
       sesCount=sesCount+1;
    end %end session loop
   
end
%Indexing observations based on peri-event timeseries
%1 observation per timestamp per trial per session
numTrials= 30;

periCueFrames= numel(currentSubj(1).periDS.timeLock);%assume constant timelock between sessions/events

periEventTable= table();

%%preallocate
% periEventTable.subject= cell(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% periEventTable.date= cell(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% periEventTable.stage= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% periEventTable.timeLock= nan(numTrials*sesCount*periCueFrames,1); 
% 
% periEventTable.DStrialID = (nan(numTrials*sesCount*periCueFrames,1));
% periEventTable.DSblue = (nan(numTrials*sesCount*periCueFrames,1));
% periEventTable.DSbluePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
% periEventTable.DSblueLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% periEventTable.DSpurple = (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
% periEventTable.DSpurplePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
% periEventTable.DSpurpleLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% periEventTable.NStrialID = (nan(numTrials*sesCount*periCueFrames,1));
% periEventTable.NSblue = (nan(numTrials*sesCount*periCueFrames,1));
% periEventTable.NSbluePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
% periEventTable.NSblueLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% periEventTable.NSpurple = (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
% periEventTable.NSpurplePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
% periEventTable.NSpurpleLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% % 


%% Loop through and get signals surrounding each event for each subj & stage

% allSubjDSblue= []; %initialize 
% allSubjDSpurple= [];
% allSubjNSblue= [];
% allSubjNSpurple= [];
subjects= fieldnames(subjDataAnalyzed);

sesCount= 1; %cumulative session counter for periEventTable
% tsInd= [1:periCueFrames*numTrials]; %cumulative timestamp index for aucTableTS
% tsInd= [1:periCueFrames]; %cumulative timestamp index for aucTableTS

for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    allStages= unique([currentSubj.trainStage]);
    
    for thisStage= allStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
        includedSessions= []; %excluded sessions will reset between unique stages
        
        %loop through all sessions and record index of sessions that correspond only to this stage
        for session= 1:numel(currentSubj)
            if currentSubj(session).trainStage == thisStage %only include sessions from this stage
               includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
            end
        end%end session loop
    
        %create empty arrays that we'll use to extract data from each included session
%         DSblue= []; DSbluePox=[]; DSblueLox=[];
%         DSpurple= []; DSpurplePox=[]; DSpurpleLox=[];        
%         NSblue= []; NSbluePox=[]; NSblueLox=[];
%         NSpurple= []; NSpurplePox=[]; NSpurpleLox=[];        

        %dp 12/17/21
        %due to poor code in fpAnalyzeData.m, possible that DS & NS
            %have different lengths? %should address this by initializing
            %all as equal length nan
            %for now as bandaid preinitializing based on assumed shared #
            %of trials then looping through DS & NS separately but could be
            %fixed more robustly if initialized everything back in old code
            %as nan w shared sizes
%         DSblue= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         DSpurple=  nan(numel(timeLock)*numel(includedSessions), numTrials);
%         DSbluePox= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         DSpurplePox= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         DSblueLox= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         DSpurpleLox= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         NSblue= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         NSpurple=  nan(numel(timeLock)*numel(includedSessions), numTrials);
%         NSbluePox= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         NSpurplePox= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         NSblueLox= nan(numel(timeLock)*numel(includedSessions), numTrials);
%         NSpurpleLox= nan(numel(timeLock)*numel(includedSessions), numTrials);

        trialInd= 1:periCueFrames;%numel(timeLock); %index for adding to photometry signal trial by trial

        %DP 2022-01-7 limiting to final session of stage 7 (to match
        %encoding model input 
        includedSessions= max(includedSessions);
        
        for includedSession= includedSessions %loop through only sessions that match this stage
            
            %reset btwn sessions
            DStrialID= nan(periCueFrames, numTrials); %unique ID for each DS trial within session
            DSblue= nan(periCueFrames, numTrials);
            DSpurple=  nan(periCueFrames, numTrials);
            DSbluePox= nan(periCueFrames, numTrials);
            DSpurplePox= nan(periCueFrames, numTrials);
            DSblueLox= nan(periCueFrames, numTrials);
            DSpurpleLox= nan(periCueFrames, numTrials);
            NStrialID= nan(periCueFrames, numTrials); %unique ID for each NS trial within session
            NSblue= nan(periCueFrames, numTrials);
            NSpurple=  nan(periCueFrames, numTrials);
            NSbluePox= nan(periCueFrames, numTrials);
            NSpurplePox= nan(periCueFrames, numTrials);
            NSblueLox= nan(periCueFrames, numTrials);
            NSpurpleLox= nan(periCueFrames, numTrials);
            
            thisTrial=1; %cumulative counter for trialID within session
            %going trial by trial like this is inefficient but it works
            for cue= 1:numel(currentSubj(includedSession).periDS.DS)
                DSblue(trialInd,cue)= currentSubj(includedSession).periDS.DSzblue(:,:,cue); 
                DSpurple(trialInd,cue)= currentSubj(includedSession).periDS.DSzpurple(:,:,cue);
                DSbluePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSzpoxblue(:,:,cue);
                DSpurplePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSzpoxpurple(:,:,cue);
                DSblueLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSzloxblue(:,:,cue);
                DSpurpleLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSzloxpurple(:,:,cue);
                DStrialID(trialInd,cue)= cue;
            end

            for cue=1:numel(currentSubj(includedSession).periNS.NS)
                NSblue(trialInd,cue)= currentSubj(includedSession).periNS.NSzblue(:,:,cue);
                NSpurple(trialInd,cue)= currentSubj(includedSession).periNS.NSzpurple(:,:,cue);
                NSbluePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSzpoxblue(:,:,cue);
                NSpurplePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSzpoxpurple(:,:,cue);
                NSblueLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSzloxblue(:,:,cue);
                NSpurpleLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSzloxpurple(:,:,cue);
                NStrialID(trialInd,cue)= cue;
           end


%             %Collect peri-CUE photometry signals
%                 DSblue= [DSblue,squeeze(currentSubj(includedSession).periDS.DSzblue)]; %squeeze to make 2d and concatenate
%                 DSpurple= [DSpurple, squeeze(currentSubj(includedSession).periDS.DSzpurple)];
%                 NSblue= [NSblue, squeeze(currentSubj(includedSession).periNS.NSzblue)];
%                 NSpurple= [NSpurple, squeeze(currentSubj(includedSession).periNS.NSzpurple)];
% 
%                 %Collect peri-first PE photometry signals 
%                 DSbluePox= [DSbluePox, squeeze(currentSubj(includedSession).periDSpox.DSzpoxblue)];
%                 DSpurplePox= [DSpurplePox, squeeze(currentSubj(includedSession).periDSpox.DSzpoxpurple)];
%                 NSbluePox= [NSbluePox, squeeze(currentSubj(includedSession).periNSpox.NSzpoxblue)];
%                 NSpurplePox= [NSpurplePox, squeeze(currentSubj(includedSession).periNSpox.NSzpoxpurple)];
% 
%                 %Collect peri-first PE photometry signals 
%                 DSblueLox= [DSblueLox, squeeze(currentSubj(includedSession).periDSlox.DSzloxblue)];
%                 DSpurpleLox= [DSpurpleLox, squeeze(currentSubj(includedSession).periDSlox.DSzloxpurple)];
%                 NSblueLox= [NSblueLox, squeeze(currentSubj(includedSession).periNSlox.NSzloxblue)];
%                 NSpurpleLox= [NSpurpleLox, squeeze(currentSubj(includedSession).periNSlox.NSzloxpurple)];
            
            %iterate tsInd for table
            if sesCount==1
                tsInd= 1:periCueFrames*size(DSblue,2);
            else
                tsInd= tsInd+ periCueFrames * size(DSblue,2);
            end
           
            
            %Save data into table
            periEventTable.DStrialID(tsInd)= DStrialID(:);
            periEventTable.DSblue(tsInd)= DSblue(:);
            periEventTable.DSpurple(tsInd)= DSpurple(:);
            periEventTable.DSbluePox(tsInd)= DSbluePox(:);
            periEventTable.DSpurplePox(tsInd)= DSpurplePox(:);
            periEventTable.DSblueLox(tsInd)= DSblueLox(:);
            periEventTable.DSpurpleLox(tsInd)= DSpurpleLox(:);
            
            periEventTable.NStrialID(tsInd)= NStrialID(:);
            periEventTable.NSblue(tsInd)= NSblue(:);
            periEventTable.NSpurple(tsInd)= NSpurple(:);
            periEventTable.NSbluePox(tsInd)= NSbluePox(:);
            periEventTable.NSpurplePox(tsInd)= NSpurplePox(:);
            periEventTable.NSblueLox(tsInd)= NSblueLox(:);
            periEventTable.NSpurpleLox(tsInd)= NSpurpleLox(:);
            
            time= repmat(currentSubj(includedSession).periDS.timeLock(:),[1,size(DSblue,2)]);
            periEventTable.timeLock(tsInd)= time(:); 
            periEventTable.subject(tsInd)= {subjects{subj}};
            periEventTable.date(tsInd)= {num2str(currentSubj(includedSession).date)};
            periEventTable.stage(tsInd)= currentSubj(includedSession).trainStage;
            
            sesCount=sesCount+1;
        end %end session loop
    end %end stage loop
end %end subj loop


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

%% Stage 7 peri-Cue vs peri-Pox vs peri-Lox
figure();

clear i
%subset data
data= periEventTable(periEventTable.stage==7,:);

i(1,1)=gramm('x',data.timeLock,'y',data.DSblue, 'color',data.subject);
i(1,1).stat_summary('type','sem','geom','area');
i(1,1).set_names('x','time from event (s)','y','z-score','color','subject');
i(1,1).set_title('Peri-DS');


i(2,1)=gramm('x',data.timeLock,'y',data.DSbluePox, 'color',data.subject);
i(2,1).stat_summary('type','sem','geom','area');
i(2,1).set_names('x','time from event (s)','y','z-score','color','subject');
i(2,1).set_title('Peri-First PE DS');

i(3,1)=gramm('x',data.timeLock,'y',data.DSblueLox, 'color',data.subject);
i(3,1).stat_summary('type','sem','geom','area');
i(3,1).set_names('x','time from event (s)','y','z-score','color','subject');
i(3,1).set_title('Peri-First Lick DS');

i.axe_property('YLim',[-1,4]);
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
