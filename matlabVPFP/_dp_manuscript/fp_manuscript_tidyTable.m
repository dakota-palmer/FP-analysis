% Collect peri-event traces for each eventType
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
DStrialCountCum=1; %cumulative count of unique trials between all subjects and sessions
NStrialCountCum=1;
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

%         %DP 2022-01-7 limiting to final session of stage 7 (to match
%         %encoding model input 
%         includedSessions= max(includedSessions);
        
        for includedSession= includedSessions %loop through only sessions that match this stage
            
            %reset btwn sessions            
            DStrialID= nan(periCueFrames, numTrials); %unique ID for each DS trial within session
            
            DSblueRaw= nan(periCueFrames, numTrials);
            DSpurpleRaw= nan(periCueFrames, numTrials);
            
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
            
            DStrialIDcum= nan(periCueFrames, numTrials);  %cumulative 
            NStrialIDcum= nan(periCueFrames, numTrials); 

            
            %reward info
            pumpID= nan(periCueFrames, numTrials);
            rewardID= cell(periCueFrames, numTrials);
            
            rewardID(:)= {''}; %prefill cells w empty string (gramm needs all cells to be same type I think; doesn't like empty cells mixed in)

            
            thisTrial=1; %cumulative counter for trialID within session
            %going trial by trial like this is inefficient but it works
            for cue= 1:numel(currentSubj(includedSession).periDS.DS)
                    %save raw signals for easy trial by trial corr() & artifact/noise ID
                DSblueRaw(trialInd, cue)= currentSubj(includedSession).periDS.DSblue(:,:,cue);
                DSpurpleRaw(trialInd, cue)= currentSubj(includedSession).periDS.DSpurple(:,:,cue);
                
                DSblue(trialInd,cue)= currentSubj(includedSession).periDS.DSzblue(:,:,cue); 
                DSpurple(trialInd,cue)= currentSubj(includedSession).periDS.DSzpurple(:,:,cue);
                DSbluePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSzpoxblue(:,:,cue);
                DSpurplePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSzpoxpurple(:,:,cue);
                DSblueLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSzloxblue(:,:,cue);
                DSpurpleLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSzloxpurple(:,:,cue);
                DStrialID(trialInd,cue)= cue;
                
                DStrialIDcum(trialInd,cue)= DStrialCountCum;
                DStrialCountCum= DStrialCountCum+1;
                
                if thisStage>=8 %variable reward
                    pumpID(trialInd, cue)= currentSubj(includedSession).reward.DSreward(cue);
                    rewardID(trialInd,cue)= currentSubj(includedSession).reward.rewardID(cue); 
                end

            end

            for cue=1:numel(currentSubj(includedSession).periNS.NS)
                NSblue(trialInd,cue)= currentSubj(includedSession).periNS.NSzblue(:,:,cue);
                NSpurple(trialInd,cue)= currentSubj(includedSession).periNS.NSzpurple(:,:,cue);
                
                if~isempty(currentSubj(includedSession).periNSpox.NSzpoxblue) %lazy exception for now
                    NSbluePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSzpoxblue(:,:,cue);
                    NSpurplePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSzpoxpurple(:,:,cue);
                end
                
                if~isempty(currentSubj(includedSession).periNSlox.NSzloxblue) %lazy exception for now
                    NSblueLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSzloxblue(:,:,cue);
                    NSpurpleLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSzloxpurple(:,:,cue);
                end
                NStrialID(trialInd,cue)= cue;
                
                NStrialIDcum(trialInd,cue)= NStrialCountCum;
                NStrialCountCum= NStrialCountCum+1;
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
            periEventTable.fileID(tsInd)= sesCount;
            
            periEventTable.trainDay(tsInd)= currentSubj(includedSession).trainDay;
            
            periEventTable.DStrialID(tsInd)= DStrialID(:);
            
            periEventTable.DSblueRaw(tsInd)= DSblueRaw(:);
            periEventTable.DSpurpleRaw(tsInd)= DSpurpleRaw(:);
            
            periEventTable.DSblue(tsInd)= DSblue(:);
            periEventTable.DSpurple(tsInd)= DSpurple(:);
            periEventTable.DSbluePox(tsInd)= DSbluePox(:);
            periEventTable.DSpurplePox(tsInd)= DSpurplePox(:);
            periEventTable.DSblueLox(tsInd)= DSblueLox(:);
            periEventTable.DSpurpleLox(tsInd)= DSpurpleLox(:);
            
            periEventTable.pumpID(tsInd)= pumpID(:);
            periEventTable.rewardID(tsInd)= rewardID(:);


            periEventTable.DStrialIDcum(tsInd)= DStrialIDcum(:);
            periEventTable.NStrialIDcum(tsInd)= NStrialIDcum(:);

            
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
                     
            periEventTable.DSpeRatio(tsInd)= currentSubj(includedSession).behavior.DSpeRatio;
            periEventTable.NSpeRatio(tsInd)= currentSubj(includedSession).behavior.NSpeRatio;
            
            sesCount=sesCount+1;
        end %end session loop
    end %end stage loop
end %end subj loop



