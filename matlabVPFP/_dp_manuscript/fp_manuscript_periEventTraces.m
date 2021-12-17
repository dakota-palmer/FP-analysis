%% Collect peri-event traces for each eventType
%save data into table for later subplotting 
% events= {'DS','NS','pox','lox'}

%% Preallocate table with #rows equal to observations per session
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
periEventTable.DSblue = (nan(numTrials*sesCount*periCueFrames,1));
periEventTable.DSbluePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
periEventTable.DSblueLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
periEventTable.DSpurple = (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
periEventTable.DSpurplePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
periEventTable.DSpurpleLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
periEventTable.NSblue = (nan(numTrials*sesCount*periCueFrames,1));
periEventTable.NSbluePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
periEventTable.NSblueLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
periEventTable.NSpurple = (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
periEventTable.NSpurplePox= (nan(numTrials*sesCount*periCueFrames,1)); %(nan(sesCount,1));
periEventTable.NSpurpleLox= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% 
periEventTable.timeLock= nan(numTrials*sesCount*periCueFrames,1); 
periEventTable.subject= cell(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
periEventTable.date= cell(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
periEventTable.stage= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));

%% Loop through and get signals surrounding each event for each subj & stage

% allSubjDSblue= []; %initialize 
% allSubjDSpurple= [];
% allSubjNSblue= [];
% allSubjNSpurple= [];
subjects= fieldnames(subjDataAnalyzed);

sesCount= 1; %cumulative session counter for periEventTable
% tsInd= [1:periCueFrames*numTrials]; %cumulative timestamp index for aucTableTS
tsInd= [1:periCueFrames]; %cumulative timestamp index for aucTableTS

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
        DSblue= []; DSbluePox=[]; DSblueLox=[];
        DSpurple= []; DSpurplePox=[]; DSpurpleLox=[];        
        NSblue= []; NSbluePox=[]; NSblueLox=[];
        NSpurple= []; NSpurplePox=[]; NSpurpleLox=[];        

        
        for includedSession= includedSessions %loop through only sessions that match this stage
            %Collect peri-CUE photometry signals
            DSblue= [DSblue,squeeze(currentSubj(includedSession).periDS.DSzblue)]; %squeeze to make 2d and concatenate
            DSpurple= [DSpurple, squeeze(currentSubj(includedSession).periDS.DSzpurple)];
            NSblue= [NSblue, squeeze(currentSubj(includedSession).periNS.NSzblue)];
            NSpurple= [NSpurple, squeeze(currentSubj(includedSession).periNS.NSzpurple)];
            
            %Collect peri-first PE photometry signals 
            DSbluePox= [DSbluePox, squeeze(currentSubj(includedSession).periDSpox.DSzpoxblue)];
            DSpurplePox= [DSpurplePox, squeeze(currentSubj(includedSession).periDSpox.DSzpoxpurple)];
            NSbluePox= [NSbluePox, squeeze(currentSubj(includedSession).periNSpox.NSzpoxblue)];
            NSpurplePox= [NSpurplePox, squeeze(currentSubj(includedSession).periNSpox.NSzpoxpurple)];
            
            %Collect peri-first PE photometry signals 
            DSblueLox= [DSblueLox, squeeze(currentSubj(includedSession).periDSlox.DSzloxblue)];
            DSpurpleLox= [DSpurpleLox, squeeze(currentSubj(includedSession).periDSlox.DSzloxpurple)];
            NSblueLox= [NSblueLox, squeeze(currentSubj(includedSession).periNSlox.NSzloxblue)];
            NSpurpleLox= [NSpurpleLox, squeeze(currentSubj(includedSession).periNSlox.NSzloxpurple)];

            %iterate tsInd for table
            if sesCount==1
                tsInd= 1:periCueFrames*size(DSblue,2);
            else
                tsInd= tsInd+ periCueFrames * size(DSblue,2);
            end
            
            %Save data into table
            periEventTable.DSblue(tsInd)= DSblue(:);
            periEventTable.DSpurple(tsInd)= DSpurple(:);
            periEventTable.DSbluePox(tsInd)= DSbluePox(:);
            periEventTable.DSpurplePox(tsInd)= DSpurplePox(:);
            periEventTable.DSblueLox(tsInd)= DSblueLox(:);
            periEventTable.DSpurpleLox(tsInd)= DSpurpleLox(:);
            
            periEventTable.NSblue(tsInd)= NSblue(:);
            periEventTable.NSpurple(tsInd)= NSpurple(:);
            periEventTable.NSbluePox(tsInd)= NSbluePox(:);
            periEventTable.NSpurplePox(tsInd)= NSpurplePox(:);
            periEventTable.NSblueLox(tsInd)= NSblueLox(:);
            periEventTable.NSpurpleLox(tsInd)= NSpurpleLox(:);
            
            time= repmat(currentSubj(session).periDS.timeLock(:),[1,size(DSblue,2)]);
            periEventTable.timeLock(tsInd)= time(:); 
            periEventTable.subject(tsInd)= {subjects{subj}};
            periEventTable.date(tsInd)= {num2str(currentSubj(session).date)};
            periEventTable.stage(tsInd)= currentSubj(session).trainStage; 
        end %end session loop
        
% %             saving all timestamps from all trials- seems to work but
% %             takes awhile
%             for trial= 1:size(DSblue,2)
%                 periEventTable.DSblue(tsInd)= DSblue(:,trial);
%                 tsInd= tsInd + periCueFrames * trial; %iterate tsInd for table as it grows
%             end
%             
%             periEventTable.DSblue(tsInd,:)= DSblue(:);
% 
%             trialCount= size(DSblue,2);
%             tsInd= tsInd + periCueFrames * trialCount; %iterate tsInd for table as it grows
% 


        %shouldn't be necessary if collecting everything like above, can
        %just aggregate later
%         %collect data from all subjects for a between-subjects mean plot
%         allSubjDSblue(:,thisStage,subj)= nanmean(DSblue,2);
%         allSubjDSpurple(:,thisStage, subj)= nanmean(DSpurple,2);
%     
%         if ~isempty(NSblue)
%            allSubjNSblue(:,thisStage,subj)= nanmean(NSblue,2);
%            allSubjNSpurple(:,thisStage,subj)= nanmean(NSpurple,2);
%         end
    end %end stage loop
end %end subj loop
    
% for subj= 1:numel(subjects)
%     allSubjDSblue(:,find(all(allSubjDSblue(:,:,subj)==0)),subj)= nan;
%     allSubjDSpurple(:,find(all(allSubjDSpurple(:,:,subj)==0)), subj)= nan;
%     allSubjNSblue(:,find(all(allSubjNSblue(:,:,subj)==0)), subj)= nan;
%     allSubjNSpurple(:,find(all(allSubjNSpurple(:,:,subj)==0)), subj)= nan;
% end






% % 
% % % Now make a between-subj plot of mean across all animals
% % figure;
% % figureCount=figureCount+1; sgtitle('peri-cue response: mean between subjects ');
% % for subj= 1:numel(subjects)
% %     for thisStage= 1:size(allSubjDSblue,2) 
% %             %calculate between subj mean data for this stage
% %         thisStageDSblue= nanmean(allSubjDSblue(:,thisStage,:),3);
% %         thisStageDSpurple= nanmean(allSubjDSpurple(:,thisStage,:),3);
% %         thisStageNSblue= nanmean(allSubjNSblue(:,thisStage,:), 3);
% %         thisStageNSpurple= nanmean(allSubjNSpurple(:,thisStage,:),3);
% % 
% %             %calculate SEM between subjects
% %         semDSblueAllSubj= []; semDSpurpleAllSubj=[]; semNSblueAllSubj= []; semNSpurpleAllSubj=[]; %reset btwn subj
% %         semDSblueAllSubj= nanstd(allSubjDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
% %         semDSpurpleAllSubj= nanstd(allSubjDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% %         semNSblueAllSubj= nanstd(allSubjNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
% %         semNSpurpleAllSubj= nanstd(allSubjNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% % 
% %         
% %                 %DS
% %         subplot(subplot(2, size(allSubjDSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri- DS')) 
% % %         plot(timeLock, (allSubjDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% % %         plot(timeLock, (allSubjDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
% %         plot(timeLock, thisStageDSblue,'k','LineWidth',2); %plot between-subjects mean blue
% %         plot(timeLock, thisStageDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
% %                         %overlay SEM blue
% %         semLinePosAllSubj= thisStageDSblue+nanmean(semDSblue(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageDSblue-nanmean(semDSblue(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
% %                 %overlay SEM purple
% %         semLinePosAllSubj= thisStageDSpurple+nanmean(semDSpurple(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageDSpurple-nanmean(semDSpurple(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
% %             %NS
% %         subplot(subplot(2, size(allSubjDSblue,2), size(allSubjDSblue,2)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri- NS')) 
% % %         plot(timeLock, (allSubjNSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% % %         plot(timeLock, (allSubjNSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
% %         plot(timeLock, thisStageNSblue,'k','LineWidth',2); %plot between-subjects mean blue
% %         plot(timeLock, thisStageNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
% %                            %overlay SEM blue
% %         semLinePosAllSubj= thisStageNSblue+nanmean(semNSblue(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageNSblue-nanmean(semNSblue(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
% %                 %overlay SEM purple
% %         semLinePosAllSubj= thisStageNSpurple+nanmean(semNSpurple(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageNSpurple-nanmean(semNSpurple(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
% %         
% %         if thisStage==1
% % %            legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
% %         end
% %     end
% % end
% 
% linkaxes(); %link axes for scale comparison
% 
% 
% % colors= [136/255,86/255,167/255;127/255,191/255,123/255]; %https://colorbrewer2.org/#type=sequential&scheme=BuPu&n=3
% 
% % 
% % 
% % % Now make a between-subj plot of mean across all animals- DS & NS overlay
% % figure;
% % figureCount=figureCount+1; sgtitle('peri-cue response: mean between subjects ');
% % for subj= 1:numel(subjects)
% %     for thisStage= 1:size(allSubjDSblue,2) 
% %             %calculate between subj mean data for this stage
% %         thisStageDSblue= nanmean(allSubjDSblue(:,thisStage,:),3);
% %         thisStageDSpurple= nanmean(allSubjDSpurple(:,thisStage,:),3);
% %         thisStageNSblue= nanmean(allSubjNSblue(:,thisStage,:), 3);
% %         thisStageNSpurple= nanmean(allSubjNSpurple(:,thisStage,:),3);
% % 
% %             %calculate SEM between subjects
% %         semDSblueAllSubj= []; semDSpurpleAllSubj=[]; semNSblueAllSubj= []; semNSpurpleAllSubj=[]; %reset btwn subj
% %         semDSblueAllSubj= nanstd(allSubjDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
% %         semDSpurpleAllSubj= nanstd(allSubjDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% %         semNSblueAllSubj= nanstd(allSubjNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
% %         semNSpurpleAllSubj= nanstd(allSubjNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% % 
% %         
% %                 %DS
% %         subplot(subplot(1, size(allSubjDSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri-cue')) 
% % %         plot(timeLock, (allSubjDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% % %         plot(timeLock, (allSubjDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
% %         plot(timeLock, thisStageDSblue,'Color',colors(1,:),'LineWidth',2); %plot between-subjects mean blue
% % %         plot(timeLock, thisStageDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
% %                         %overlay SEM blue
% %         semLinePosAllSubj= thisStageDSblue+nanmean(semDSblue(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageDSblue-nanmean(semDSblue(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.2);
% %             %NS
% %         plot(timeLock, thisStageNSblue,'Color',colors(2,:),'LineWidth',2); %plot between-subjects mean blue
% % %         plot(timeLock, thisStageNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
% %                            %overlay SEM blue
% %         semLinePosAllSubj= thisStageNSblue+nanmean(semNSblue(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageNSblue-nanmean(semNSblue(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(2,:),'EdgeColor','None');alpha(0.2);
% % %                 %overlay SEM purple
% % %         semLinePosAllSubj= thisStageNSpurple+nanmean(semNSpurple(:,thisStage,:),3);
% % %         semLineNegAllSubj= thisStageNSpurple-nanmean(semNSpurple(:,thisStage,:),3);
% % %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
% %         
% %         if thisStage==1
% % %            legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
% %              legend('DS 465nm', 'SEM', 'NS 465nm','SEM');
% %         end
% %     end
% % end
% % 
% % linkaxes(); %link axes for scale comparison
% 
% 
% 
% %% Peri-DSpox 2d plots by stage
% 
% allSubjDSblue= []; %initialize 
% allSubjDSpurple= [];
% allSubjNSblue= [];
% allSubjNSpurple= [];
% 
% for subj= 1:numel(subjects)
%     currentSubj= subjDataAnalyzed.(subjects{subj});
%     allStages= unique([currentSubj.trainStage]);
%     
%     for thisStage= allStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
%         includedSessions= []; %excluded sessions will reset between unique stages
%         
%         %loop through all sessions and record index of sessions that correspond only to this stage
%         for session= 1:numel(currentSubj)
%             if currentSubj(session).trainStage == thisStage %only include sessions from this stage
%                includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
%             end
%         end%end session loop
%     
%         %create empty arrays that we'll use to extract data from each included session
%         DSblue= [];
%         DSpurple= [];
%         NSblue= [];
%         NSpurple= [];
%         
%         for includedSession= includedSessions %loop through only sessions that match this stage
%             %Extracting periDS (timelocked to DS) photometry signals
%             DSblue= [DSblue,squeeze(currentSubj(includedSession).periDSpox.DSzpoxblue)]; %squeeze to make 2d and concatenate
%             DSpurple= [DSpurple, squeeze(currentSubj(includedSession).periDSpox.DSzpoxpurple)];
%             NSblue= [NSblue, squeeze(currentSubj(includedSession).periNSpox.NSzpoxblue)];
%             NSpurple= [NSpurple, squeeze(currentSubj(includedSession).periNSpox.NSzpoxpurple)];
%         end
%         
%         %collect data from all subjects for a between-subjects mean plot
%         allSubjDSblue(:,thisStage,subj)= nanmean(DSblue,2);
%         allSubjDSpurple(:,thisStage, subj)= nanmean(DSpurple,2);
%     
%         if ~isempty(NSblue)
%            allSubjNSblue(:,thisStage,subj)= nanmean(NSblue,2);
%            allSubjNSpurple(:,thisStage,subj)= nanmean(NSpurple,2);
%         end
%     
%         
%      %generate plots
%         figure(figureCount); hold on; sgtitle(strcat(subjects{subj},'-peri first PE in DS epoch by stages'));
%         subplot(2, allStages(end), thisStage); title(strcat('465nm Stage-',num2str(thisStage))); hold on;
%         
% %         plot(timeLock, DSblue, 'k--'); %plot all individual trials
%         plot(timeLock, nanmean(DSblue, 2), 'b'); %plot mean
%         xlabel('time to first PE after DS (s)'); ylabel('mean z-score 465nm');
%         
% %             %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
%         semDSblue(:,thisStage,subj)= (nanstd(DSblue,0,2))/sqrt(size(DSblue,2));
%         semDSblue(:,(find(all(semDSblue(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
%         semLinePos= nanmean(DSblue,2)+semDSblue(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
%         semLineNeg= nanmean(DSblue,2)-semDSblue(:,thisStage,subj);
% 
%         patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],'b','EdgeColor','None');alpha(0.5);
% 
%         %add only one legend for the first subplot (seems to be easiest solution)
%         if thisStage== allStages(1)
%             legend('mean', 'within-subject SEM (n=# trials)');
%         end
%         
%         subplot(2, allStages(end), allStages(end)+thisStage); title(strcat('405nm Stage-', num2str(thisStage))); hold on;
% 
% %         plot(timeLock, DSpurple, 'k--'); %plot all individual trials
%         plot(timeLock, nanmean(DSpurple, 2), 'm'); %plot mean
%         xlabel('time to first PE after DS (s)'); ylabel('mean z-score 405nm');
% 
%         %             %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
%         semDSpurple(:,thisStage,subj)= (nanstd(DSpurple,0,2))/sqrt(size(DSpurple,2));
%         semDSpurple(:,(find(all(semDSpurple(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
%         semLinePos= nanmean(DSpurple,2)+semDSpurple(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
%         semLineNeg= nanmean(DSpurple,2)-semDSpurple(:,thisStage,subj);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],'m','EdgeColor','None');alpha(0.5);
% 
%         %add only one legend for the first subplot (seems to be easiest solution)
%         if thisStage== allStages(1)
%             legend('mean', 'within-subject SEM (n=# trials)');
%         end
%             
%         semNSblue(:,thisStage,subj)= (nanstd(NSblue,0,2))/sqrt(size(NSblue,2));
%         semNSblue(:,(find(all(semNSblue(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
%         semLinePos= nanmean(NSblue,2)+semNSblue(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
%         semLineNeg= nanmean(NSblue,2)-semNSblue(:,thisStage,subj);
% 
%         semNSpurple(:,thisStage,subj)= (nanstd(NSpurple,0,2))/sqrt(size(NSpurple,2));
%         semNSpurple(:,(find(all(semNSpurple(:,:,subj)==0))),subj)= nan; %replace 0s with nan;
%         semLinePos= nanmean(NSpurple,2)+semDSblue(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
%         semLineNeg= nanmean(NSpurple,2)-semDSblue(:,thisStage,subj);
% 
%     end %end Stage loop 
%        
%     linkaxes; %make axes of subplots equal for nicer look & sense of scale
%     
%     figureCount= figureCount+1;
%     set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% 
% end %end subj loop
% 
% %replace columns that have all zeros with nans (this could happen if an animal
% %didn't run a particular stage)
% for subj= 1:numel(subjects)
%     allSubjDSblue(:,find(all(allSubjDSblue(:,:,subj)==0)),subj)= nan;
%     allSubjDSpurple(:,find(all(allSubjDSpurple(:,:,subj)==0)), subj)= nan;
%     allSubjNSblue(:,find(all(allSubjNSblue(:,:,subj)==0)), subj)= nan;
%     allSubjNSpurple(:,find(all(allSubjNSpurple(:,:,subj)==0)), subj)= nan;
% end
% 
% % Now make a between-subj plot of mean across all animals
% figure;
% figureCount=figureCount+1; sgtitle('peri-first PE response: mean between subjects ');
% for subj= 1:numel(subjects)
%     for thisStage= 1:size(allSubjDSblue,2) 
%             %calculate between subj mean data for this stage
%         thisStageDSblue= nanmean(allSubjDSblue(:,thisStage,:),3);
%         thisStageDSpurple= nanmean(allSubjDSpurple(:,thisStage,:),3);
%         thisStageNSblue= nanmean(allSubjNSblue(:,thisStage,:), 3);
%         thisStageNSpurple= nanmean(allSubjNSpurple(:,thisStage,:),3);
% 
%             %calculate SEM between subjects
%         semDSblueAllSubj= []; semDSpurpleAllSubj=[]; semNSblueAllSubj= []; semNSpurpleAllSubj=[]; %reset btwn subj
%         semDSblueAllSubj= nanstd(allSubjDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semDSpurpleAllSubj= nanstd(allSubjDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSblueAllSubj= nanstd(allSubjNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSpurpleAllSubj= nanstd(allSubjNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% 
%         
%                 %DS
%         subplot(subplot(2, size(allSubjDSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri-first PE DS')) 
% %         plot(timeLock, (allSubjDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% %         plot(timeLock, (allSubjDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
%         plot(timeLock, thisStageDSblue,'k','LineWidth',2); %plot between-subjects mean blue
%         plot(timeLock, thisStageDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                         %overlay SEM blue
%         semLinePosAllSubj= thisStageDSblue+nanmean(semDSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageDSblue-nanmean(semDSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
%                 %overlay SEM purple
%         semLinePosAllSubj= thisStageDSpurple+nanmean(semDSpurple(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageDSpurple-nanmean(semDSpurple(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
%             %NS
%         subplot(subplot(2, size(allSubjDSblue,2), size(allSubjDSblue,2)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri-first PE NS')) 
% %         plot(timeLock, (allSubjNSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% %         plot(timeLock, (allSubjNSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
%         plot(timeLock, thisStageNSblue,'k','LineWidth',2); %plot between-subjects mean blue
%         plot(timeLock, thisStageNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                            %overlay SEM blue
%         semLinePosAllSubj= thisStageNSblue+nanmean(semNSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageNSblue-nanmean(semNSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
%                 %overlay SEM purple
%         semLinePosAllSubj= thisStageNSpurple+nanmean(semNSpurple(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageNSpurple-nanmean(semNSpurple(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
%         
%         if thisStage==1
% %            legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
%         end
%     end
% end
% 
% linkaxes(); %link axes for scale comparison
% 
% 
% colors= [136/255,86/255,167/255;127/255,191/255,123/255]; %https://colorbrewer2.org/#type=sequential&scheme=BuPu&n=3
% 
% 
% 
% % Now make a between-subj plot of mean across all animals- DS & NS overlay
% figure;
% figureCount=figureCount+1; sgtitle('peri-first PE response: mean between subjects ');
% for subj= 1:numel(subjects)
%     for thisStage= 1:size(allSubjDSblue,2) 
%             %calculate between subj mean data for this stage
%         thisStageDSblue= nanmean(allSubjDSblue(:,thisStage,:),3);
%         thisStageDSpurple= nanmean(allSubjDSpurple(:,thisStage,:),3);
%         thisStageNSblue= nanmean(allSubjNSblue(:,thisStage,:), 3);
%         thisStageNSpurple= nanmean(allSubjNSpurple(:,thisStage,:),3);
% 
%             %calculate SEM between subjects
%         semDSblueAllSubj= []; semDSpurpleAllSubj=[]; semNSblueAllSubj= []; semNSpurpleAllSubj=[]; %reset btwn subj
%         semDSblueAllSubj= nanstd(allSubjDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semDSpurpleAllSubj= nanstd(allSubjDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSblueAllSubj= nanstd(allSubjNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSpurpleAllSubj= nanstd(allSubjNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% 
%         
%                 %DS
%         subplot(subplot(1, size(allSubjDSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri-first PE')) 
% %         plot(timeLock, (allSubjDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% %         plot(timeLock, (allSubjDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
%         plot(timeLock, thisStageDSblue,'Color',colors(1,:),'LineWidth',2); %plot between-subjects mean blue
% %         plot(timeLock, thisStageDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                         %overlay SEM blue
%         semLinePosAllSubj= thisStageDSblue+nanmean(semDSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageDSblue-nanmean(semDSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.2);
%             %NS
%         plot(timeLock, thisStageNSblue,'Color',colors(2,:),'LineWidth',2); %plot between-subjects mean blue
% %         plot(timeLock, thisStageNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                            %overlay SEM blue
%         semLinePosAllSubj= thisStageNSblue+nanmean(semNSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageNSblue-nanmean(semNSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(2,:),'EdgeColor','None');alpha(0.2);
% %                 %overlay SEM purple
% %         semLinePosAllSubj= thisStageNSpurple+nanmean(semNSpurple(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageNSpurple-nanmean(semNSpurple(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
%         
%         if thisStage==1
% %            legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
%              legend('DS 465nm', 'SEM', 'NS 465nm','SEM');
%         end
%     end
% end
% 
% linkaxes(); %link axes for scale comparison
% 
% 
% %% Peri-DSlox 2d plots by stage
% 
% allSubjDSblue= []; %initialize 
% allSubjDSpurple= [];
% allSubjNSblue= [];
% allSubjNSpurple= [];
% 
% for subj= 1:numel(subjects)
%     currentSubj= subjDataAnalyzed.(subjects{subj});
%     allStages= unique([currentSubj.trainStage]);
%     
%     for thisStage= allStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
%         includedSessions= []; %excluded sessions will reset between unique stages
%         
%         %loop through all sessions and record index of sessions that correspond only to this stage
%         for session= 1:numel(currentSubj)
%             if currentSubj(session).trainStage == thisStage %only include sessions from this stage
%                includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
%             end
%         end%end session loop
%     
%         %create empty arrays that we'll use to extract data from each included session
%         DSblue= [];
%         DSpurple= [];
%         NSblue= [];
%         NSpurple= [];
%         
%         for includedSession= includedSessions %loop through only sessions that match this stage
%             %Extracting periDS (timelocked to DS) photometry signals
%             DSblue= [DSblue,squeeze(currentSubj(includedSession).periDSlox.DSzloxblue)]; %squeeze to make 2d and concatenate
%             DSpurple= [DSpurple, squeeze(currentSubj(includedSession).periDSlox.DSzloxpurple)];
%             NSblue= [NSblue, squeeze(currentSubj(includedSession).periNSlox.NSzloxblue)];
%             NSpurple= [NSpurple, squeeze(currentSubj(includedSession).periNSlox.NSzloxpurple)];
%         end
%         
%      %collect data from all subjects for a between-subjects mean plot
%         allSubjDSblue(:,thisStage,subj)= nanmean(DSblue,2);
%         allSubjDSpurple(:,thisStage, subj)= nanmean(DSpurple,2);
%     
%         if ~isempty(NSblue)
%            allSubjNSblue(:,thisStage,subj)= nanmean(NSblue,2);
%            allSubjNSpurple(:,thisStage,subj)= nanmean(NSpurple,2);
%         end
%         
%      %generate plots
%         figure(figureCount); hold on; sgtitle(strcat(subjects{subj},'-peri first LICK in DS epoch by stages'));
%         subplot(2, allStages(end), thisStage); title(strcat('465nm Stage-',num2str(thisStage))); hold on;
%         
% %         plot(timeLock, DSblue, 'k--'); %plot all individual trials
%         plot(timeLock, nanmean(DSblue, 2), 'b'); %plot mean
%         xlabel('time to first lick after DS (s)'); ylabel('mean z-score 465nm');
%         
% %             %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
%         sem(:,thisStage,subj)= (nanstd(DSblue,0,2))/sqrt(size(DSblue,2));
%         semLinePos= nanmean(DSblue,2)+sem(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
%         semLineNeg= nanmean(DSblue,2)-sem(:,thisStage,subj);
% %              %calculate std for trials in this stage (will be used to overlay std for some measure of variability)
% %         stdLinePos= nanmean(DSblue,2)+nanstd(DSblue,0,2); %save mean + std and mean - std for easier patch() overlay
% %         stdLineNeg= nanmean(DSblue,2)-nanstd(DSblue,0,2);
%              
%         patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],'b','EdgeColor','None');alpha(0.5);
% 
%         %add only one legend for the first subplot (seems to be easiest solution)
%         if thisStage== allStages(1)
%             legend('mean', 'within-subject SEM (n=# trials)');
%         end
%         
%         subplot(2, allStages(end), allStages(end)+thisStage); title(strcat('405nm Stage-', num2str(thisStage))); hold on;
% 
% %         plot(timeLock, DSpurple, 'k--'); %plot all individual trials
%         plot(timeLock, nanmean(DSpurple, 2), 'm'); %plot mean
%         xlabel('time to first lick after DS (s)'); ylabel('mean z-score 405nm');
% 
%         %             %calculate SEM for this subject (will be used to overlay this SEM or even between subjects SEM later)
%         sem(:,thisStage,subj)= (nanstd(DSpurple,0,2))/sqrt(size(DSpurple,2));
%         semLinePos= nanmean(DSpurple,2)+sem(:,thisStage,subj); %save mean + sem and mean - s for easier patch() overlay
%         semLineNeg= nanmean(DSpurple,2)-sem(:,thisStage,subj);
% %              %calculate std for trials in this stage (will be used to overlay std for some measure of variability)
% %         stdLinePos = nanmean(DSblue,2)+nanstd(DSblue,0,2); %save mean + std and mean - std for easier patch() overlay
% %         stdLineNeg= nanmean(DSblue,2)-nanstd(DSblue,0,2);
%              
%         patch([timeLock,timeLock(end:-1:1)],[semLinePos',semLineNeg(end:-1:1)'],'m','EdgeColor','None');alpha(0.5);
% 
%         %add only one legend for the first subplot (seems to be easiest solution)
%         if thisStage== allStages(1)
%             legend('mean', 'within-subject SEM (n=# trials)');
%         end
%             
%     end %end Stage loop 
%        
%     linkaxes; %make axes of subplots equal for nicer look & sense of scale
%     
%     figureCount= figureCount+1;
%     set(gcf,'Position', get(0, 'Screensize')); %make the figure full screen before saving
% 
% end %end subj loop
% 
% 
% %replace columns that have all zeros with nans (this could happen if an animal
% %didn't run a particular stage)
% for subj= 1:numel(subjects)
%     allSubjDSblue(:,find(all(allSubjDSblue(:,:,subj)==0)),subj)= nan;
%     allSubjDSpurple(:,find(all(allSubjDSpurple(:,:,subj)==0)), subj)= nan;
%     allSubjNSblue(:,find(all(allSubjNSblue(:,:,subj)==0)), subj)= nan;
%     allSubjNSpurple(:,find(all(allSubjNSpurple(:,:,subj)==0)), subj)= nan;
% end
% 
% % Now make a between-subj plot of mean across all animals
% figure;
% figureCount=figureCount+1; sgtitle('peri-first LICK response: mean between subjects ');
% for subj= 1:numel(subjects)
%     for thisStage= 1:size(allSubjDSblue,2) 
%         thisStageDSblue= nanmean(allSubjDSblue(:,thisStage,:),3);
%         thisStageDSpurple= nanmean(allSubjDSpurple(:,thisStage,:),3);
%         thisStageNSblue= nanmean(allSubjNSblue(:,thisStage,:), 3);
%         thisStageNSpurple= nanmean(allSubjNSpurple(:,thisStage,:),3);
% 
%               %calculate SEM between subjects
%         semDSblueAllSubj= []; semDSpurpleAllSubj=[]; semNSblueAllSubj= []; semNSpurpleAllSubj=[]; %reset btwn subj
%         semDSblueAllSubj= nanstd(allSubjDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semDSpurpleAllSubj= nanstd(allSubjDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSblueAllSubj= nanstd(allSubjNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSpurpleAllSubj= nanstd(allSubjNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% 
%         
%                 %DS
%         subplot(subplot(2, size(allSubjDSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri-first lick DS')) 
% %         plot(timeLock, (allSubjDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% %         plot(timeLock, (allSubjDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
%         plot(timeLock, thisStageDSblue,'k','LineWidth',2); %plot between-subjects mean blue
%         plot(timeLock, thisStageDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                         %overlay SEM blue
%         semLinePosAllSubj= thisStageDSblue+nanmean(semDSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageDSblue-nanmean(semDSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
%                 %overlay SEM purple
%         semLinePosAllSubj= thisStageDSpurple+nanmean(semDSpurple(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageDSpurple-nanmean(semDSpurple(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
%             %NS
%         subplot(subplot(2, size(allSubjDSblue,2), size(allSubjDSblue,2)+thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri-first lick NS')) 
% %         plot(timeLock, (allSubjNSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% %         plot(timeLock, (allSubjNSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
%         plot(timeLock, thisStageNSblue,'k','LineWidth',2); %plot between-subjects mean blue
%         plot(timeLock, thisStageNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                            %overlay SEM blue
%         semLinePosAllSubj= thisStageNSblue+nanmean(semNSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageNSblue-nanmean(semNSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'b','EdgeColor','None');alpha(0.3);
%                 %overlay SEM purple
%         semLinePosAllSubj= thisStageNSpurple+nanmean(semNSpurple(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageNSpurple-nanmean(semNSpurple(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
%         
%         if thisStage==1
%            legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
%         end
%     end
% end
% 
% linkaxes(); %link axes for scale comparison
% 
% % Now make a between-subj plot of mean across all animals- DS & NS overlay
% figure;
% figureCount=figureCount+1; sgtitle('peri-first lick response: mean between subjects ');
% for subj= 1:numel(subjects)
%     for thisStage= 1:size(allSubjDSblue,2) 
%             %calculate between subj mean data for this stage
%         thisStageDSblue= nanmean(allSubjDSblue(:,thisStage,:),3);
%         thisStageDSpurple= nanmean(allSubjDSpurple(:,thisStage,:),3);
%         thisStageNSblue= nanmean(allSubjNSblue(:,thisStage,:), 3);
%         thisStageNSpurple= nanmean(allSubjNSpurple(:,thisStage,:),3);
% 
%             %calculate SEM between subjects
%         semDSblueAllSubj= []; semDSpurpleAllSubj=[]; semNSblueAllSubj= []; semNSpurpleAllSubj=[]; %reset btwn subj
%         semDSblueAllSubj= nanstd(allSubjDSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semDSpurpleAllSubj= nanstd(allSubjDSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSblueAllSubj= nanstd(allSubjNSblue(:,thisStage,:),0,3)/sqrt(numel(subjects));
%         semNSpurpleAllSubj= nanstd(allSubjNSpurple(:,thisStage,:),0,3)/sqrt(numel(subjects));
% 
%         
%                 %DS
%         subplot(subplot(1, size(allSubjDSblue,2), thisStage)); hold on; title(strcat('stage-',num2str(thisStage),'peri-first Lick')) 
% %         plot(timeLock, (allSubjDSblue(:,thisStage,subj)),'b--'); %plot each individual subject mean blue
% %         plot(timeLock, (allSubjDSpurple(:,thisStage, subj)), 'm--'); %plot each individual subject mean purple
%         plot(timeLock, thisStageDSblue,'Color',colors(1,:),'LineWidth',2); %plot between-subjects mean blue
% %         plot(timeLock, thisStageDSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                         %overlay SEM blue
%         semLinePosAllSubj= thisStageDSblue+nanmean(semDSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageDSblue-nanmean(semDSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(1,:),'EdgeColor','None');alpha(0.2);
%             %NS
%         plot(timeLock, thisStageNSblue,'Color',colors(2,:),'LineWidth',2); %plot between-subjects mean blue
% %         plot(timeLock, thisStageNSpurple,'r','LineWidth',2); %plot between-subjects mean purple
%                            %overlay SEM blue
%         semLinePosAllSubj= thisStageNSblue+nanmean(semNSblue(:,thisStage,:),3);
%         semLineNegAllSubj= thisStageNSblue-nanmean(semNSblue(:,thisStage,:),3);
%         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],colors(2,:),'EdgeColor','None');alpha(0.2);
% %                 %overlay SEM purple
% %         semLinePosAllSubj= thisStageNSpurple+nanmean(semNSpurple(:,thisStage,:),3);
% %         semLineNegAllSubj= thisStageNSpurple-nanmean(semNSpurple(:,thisStage,:),3);
% %         patch([timeLock,timeLock(end:-1:1)],[semLinePosAllSubj',semLineNegAllSubj(end:-1:1)'],'m','EdgeColor','None');alpha(0.3);
%         
%         if thisStage==1
% %            legend('465 individual subj mean', '405 individual subj mean', '465 all subj mean','405 all subj mean');
%              legend('DS 465nm', 'SEM', 'NS 465nm','SEM');
%         end
%     end
% end
% linkaxes();