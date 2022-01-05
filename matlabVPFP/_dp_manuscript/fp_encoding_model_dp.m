%% for now load betas and merge() with periEventTable




%% below skeleton code to try running encoding model more dynamically: 
% 
% %% Preallocate table with #rows equal to observations per session
% subjects= fieldnames(subjDataAnalyzed);
% sesCount= 0;
% for subj= 1:numel(subjects) %for each subject analyzed
%     currentSubj= subjDataAnalyzed.(subjects{subj});
% 
%     for session = 1:numel(currentSubj) 
%        sesCount=sesCount+1;
%     end %end session loop
%    
% end
% %Indexing observations based on peri-event timeseries
% %1 observation per timestamp per trial per session
% numTrials= 30;
% 
% periCueFrames= numel(currentSubj(1).periDS.timeLock);%assume constant timelock between sessions/events
% 
% betaTable= table();
% 
% betaTable.subject= cell(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% betaTable.date= cell(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% betaTable.stage= nan(numTrials*sesCount*periCueFrames,1); %(nan(sesCount,1));
% betaTable.timeLock= nan(numTrials*sesCount*periCueFrames,1); 
% 
% betaTable.DStrialID = (nan(numTrials*sesCount*periCueFrames,1));
% betaTable.betaDSblue = (nan(numTrials*sesCount*periCueFrames,1));
% betaTable.betaDSbluePox = (nan(numTrials*sesCount*periCueFrames,1));
% betaTable.betaDSblueLox = (nan(numTrials*sesCount*periCueFrames,1));
% 
% 
% 
% %% Loop through and run encoding model each event for each subj & stage
% subjects= fieldnames(subjDataAnalyzed);
% 
% sesCount= 1; %cumulative session counter for betaTable
% % tsInd= [1:periCueFrames*numTrials]; %cumulative timestamp index for aucTableTS
% % tsInd= [1:periCueFrames]; %cumulative timestamp index for aucTableTS
% 
% for subj= 1:numel(subjects)
%     currentSubj= subjDataAnalyzed.(subjects{subj});
%     allStages= unique([currentSubj.trainStage]);
%     
%     stagesToRun=7
%     
%     for thisStage= stagesToRun; %allStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
%         includedSessions= []; %excluded sessions will reset between unique stages
%         
%         %loop through all sessions and record index of sessions that correspond only to this stage
%         for session= 1:numel(currentSubj)
%             if currentSubj(session).trainStage == thisStage %only include sessions from this stage
%                includedSessions= [includedSessions, session]; % just cat() this session into the list of sessions to save
%             end
%         end%end session loop
%     
%         %only run final session
%         includedSessions= includedSessions(end);
%        
%         trialInd= 1:periCueFrames;%numel(timeLock); %index for adding to photometry signal trial by trial
% 
%         for includedSession= includedSessions %loop through only sessions that match this stage
%             
%             %reset btwn sessions
%             DStrialID= nan(periCueFrames, numTrials); %unique ID for each DS trial within session
%             DSblue= nan(periCueFrames, numTrials);
%             DSpurple=  nan(periCueFrames, numTrials);
%             DSbluePox= nan(periCueFrames, numTrials);
%             DSpurplePox= nan(periCueFrames, numTrials);
%             DSblueLox= nan(periCueFrames, numTrials);
%             DSpurpleLox= nan(periCueFrames, numTrials);
%             NStrialID= nan(periCueFrames, numTrials); %unique ID for each NS trial within session
%             NSblue= nan(periCueFrames, numTrials);
%             NSpurple=  nan(periCueFrames, numTrials);
%             NSbluePox= nan(periCueFrames, numTrials);
%             NSpurplePox= nan(periCueFrames, numTrials);
%             NSblueLox= nan(periCueFrames, numTrials);
%             NSpurpleLox= nan(periCueFrames, numTrials);
%             
%             thisTrial=1; %cumulative counter for trialID within session
%             %going trial by trial like this is inefficient but it works
%             for cue= 1:numel(currentSubj(includedSession).periDS.DS)
%                 betaDSblue(trialInd,cue)= currentSubj(includedSession).periDS.DSzblue(:,:,cue); 
%                 betaDSbluePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSzpoxblue(:,:,cue);
%                 betaDSblueLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSzloxblue(:,:,cue);
%                 DStrialID(trialInd,cue)= cue;
%             end
% 
% 
%             %iterate tsInd for table
%             if sesCount==1
%                 tsInd= 1:periCueFrames*size(DSblue,2);
%             else
%                 tsInd= tsInd+ periCueFrames * size(DSblue,2);
%             end
%            
%             
%             %Save data into table
%             betaTable.DStrialID(tsInd)= DStrialID(:);
%             betaTable.betaDSblue(tsInd)= DSblue(:);
%             betaTable.betaDSbluePox(tsInd)= DSbluePox(:);
%             betaTable.betaDSblueLox(tsInd)= DSblueLox(:);
%             
%                      
%             time= repmat(currentSubj(includedSession).periDS.timeLock(:),[1,size(DSblue,2)]);
%             betaTable.timeLock(tsInd)= time(:); 
%             betaTable.subject(tsInd)= {subjects{subj}};
%             betaTable.date(tsInd)= {num2str(currentSubj(includedSession).date)};
%             betaTable.stage(tsInd)= currentSubj(includedSession).trainStage;
%             
%             sesCount=sesCount+1;
%         end %end session loop
%     end %end stage loop
% end %end subj loop
