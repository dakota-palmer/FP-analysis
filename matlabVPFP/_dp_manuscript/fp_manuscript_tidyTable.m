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
allTrialCountCum= 1; %cumulative count of unique trials between all trialTypes, subjects, sessions

% tsInd= [1:periCueFrames*numTrials]; %cumulative timestamp index for aucTableTS
% tsInd= [1:periCueFrames]; %cumulative timestamp index for aucTableTS

for subj= 1:numel(subjects)
    currentSubj= subjDataAnalyzed.(subjects{subj});
    allStages= unique([currentSubj.trainStage]);
    
    for thisStage= allStages %~~ Here we vectorize the field 'trainStage' to get the unique values easily %we'll loop through each unique stage
        includedSessions= []; %excluded sessions will reset between unique stages
        
         trainDayThisStage=1; %cumcount of training days within-stage for this subj
         criteriaDayThisStage=0; %cumcount of criteria days within-stage for this subj
        
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
            
            DStrialOutcome= nan(periCueFrames, numTrials);
            
            DSblueRaw= nan(periCueFrames, numTrials);
            DSpurpleRaw= nan(periCueFrames, numTrials);
            
            DSblue= nan(periCueFrames, numTrials);
            DSpurple=  nan(periCueFrames, numTrials);
            DSbluePox= nan(periCueFrames, numTrials);
            DSpurplePox= nan(periCueFrames, numTrials);
            DSblueLox= nan(periCueFrames, numTrials);
            DSpurpleLox= nan(periCueFrames, numTrials);
            
            
            NStrialID= nan(periCueFrames, numTrials); %unique ID for each NS trial within session
            NStrialOutcome= nan(periCueFrames, numTrials);
            NSblue= nan(periCueFrames, numTrials);
            NSpurple=  nan(periCueFrames, numTrials);
            NSbluePox= nan(periCueFrames, numTrials);
            NSpurplePox= nan(periCueFrames, numTrials);
            NSblueLox= nan(periCueFrames, numTrials);
            NSpurpleLox= nan(periCueFrames, numTrials);
            
            DStrialIDcum= nan(periCueFrames, numTrials);  %cumulative 
            NStrialIDcum= nan(periCueFrames, numTrials); 
            
            trialIDcum= nan(periCueFrames, numTrials); % cumulative count of all trials (useful for stats groupsummary etc later)
            

            sesSpecialLabel= cell(periCueFrames,numTrials); %empty cell to store string labels for marking specific days to plot (e.g. first day of st5, first criteria of st 5, first criteria of st 7 for vp-vta-fp manuscript Figure 1)
            
            %behavior during trial
                %PE latency relative to cue onset
            poxDSrel= nan(periCueFrames, numTrials);
            poxNSrel= nan(periCueFrames, numTrials);
            
                %lick latency relative to cue onset
            loxDSrel= nan(periCueFrames, numTrials);
            loxNSrel= nan(periCueFrames, numTrials);
            
                %lick latency relative to PE 
            loxDSpoxrel= nan(periCueFrames, numTrials);
            
                %dp 2023-08-15 peer review simple count of licks per trial
                    %could/should have just used the same variables above,
                    %but adding this late and want to make sure not causing
                    %any errors/miscalculations based on above variables
                    %only including 1st lick...so making new ones
                
                    %count of all licks in trial
                loxDSrelCountAllThisTrial= nan(periCueFrames, numTrials);
                    %lick latencies of all licks in trial 
                    %for now cell array
%                 loxDSrelAllThisTrial= nan(periCueFrames, numTrials);
                loxDSrelAllThisTrial= cell(periCueFrames, numTrials);

                
            
            
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
                
                % Get normalized signal in z score by default unless you want 'raw' e.g. dff 
                if (strcmp(normalizeMode, 'z'))
                
                    DSblue(trialInd,cue)= currentSubj(includedSession).periDS.DSzblue(:,:,cue); 
                    DSpurple(trialInd,cue)= currentSubj(includedSession).periDS.DSzpurple(:,:,cue);
                    DSbluePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSzpoxblue(:,:,cue);
                    DSpurplePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSzpoxpurple(:,:,cue);
                    DSblueLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSzloxblue(:,:,cue);
                    DSpurpleLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSzloxpurple(:,:,cue);
                
                else %else get 'raw' e.g. dff 
                    DSblue(trialInd,cue)= currentSubj(includedSession).periDS.DSblue(:,:,cue); 
                    DSpurple(trialInd,cue)= currentSubj(includedSession).periDS.DSpurple(:,:,cue);
                    DSbluePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSpoxblue(:,:,cue);
                    DSpurplePox(trialInd,cue)= currentSubj(includedSession).periDSpox.DSpoxpurple(:,:,cue);
                    DSblueLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSloxblue(:,:,cue);
                    DSpurpleLox(trialInd,cue)= currentSubj(includedSession).periDSlox.DSloxpurple(:,:,cue);
                end

                
                DStrialID(trialInd,cue)= cue;
                
                DStrialOutcome(trialInd,cue)= currentSubj(includedSession).trialOutcome.DSoutcome(cue);
                
                    %saving first PE only (mainly just for latency correlation analysis)
                if ~isempty( currentSubj(includedSession).behavior.poxDSrel{cue})
                    poxDSrel(trialInd, cue)= currentSubj(includedSession).behavior.poxDSrel{cue}(1);
                else
                     poxDSrel(trialInd, cue)= nan;
                end
                
                %saving first lick only (mainly just for plots)
                if ~isempty( currentSubj(includedSession).behavior.loxDSrel{cue})
                    loxDSrel(trialInd, cue)= currentSubj(includedSession).behavior.loxDSrel{cue}(1);
                
                    loxDSpoxRel(trialInd,cue)= currentSubj(includedSession).behavior.loxDSpoxRel{cue}(1);
                    
                    %note this won't match up timestamp with corresponding
%                     %%time bin in periEventTable, need to do that on an
%                     %%event-by-event basis
% 
%                     loxDSrelAllThisTrial(trialInd,cue)= currentSubj(includedSession).behavior.loxDSrel{cue};
%                    
%                     %find the time bin corresponding to this event for
%                         %assignment
%                     testLickTimes= currentSubj(includedSession).behavior.loxDSrel{cue};
%                     
%                     testTimeAxis= currentSubj(includedSession).periDS.timeLock(:);
%                     
%                     testInd= find(testLickTimes, testTimeAxis);

                    % for now just save in 1st position cell instead of worrying about
                    % binned assignment. not a good approach anyway. want
                    % the raw timestamps
                    loxDSrelAllThisTrial(1,cue)= {currentSubj(includedSession).behavior.loxDSrel{cue}};

                    
                    % simple count of licks per trial
                    loxDSrelCountAllThisTrial(trialInd, cue)= numel(currentSubj(includedSession).behavior.loxDSrel{cue});

                else
                     loxDSrel(trialInd, cue)= nan;
                     loxDSpoxRel(trialInd,cue)= nan;
                     
%                      loxDSrelAllThisTrial(trialInd, cue)= nan;
                     loxDSrelCountAllThisTrial(trialInd, cue)= 0;
                end
                    

                
                    
                DStrialIDcum(trialInd,cue)= DStrialCountCum;
                DStrialCountCum= DStrialCountCum+1;
                
                trialIDcum(trialInd,cue)= allTrialCountCum;
                allTrialCountCum= allTrialCountCum+1;
                
                if thisStage>=8 %variable reward
                    pumpID(trialInd, cue)= currentSubj(includedSession).reward.DSreward(cue);
                    rewardID(trialInd,cue)= currentSubj(includedSession).reward.rewardID(cue); 
                end

            end

            for cue=1:numel(currentSubj(includedSession).periNS.NS)
                NSblue(trialInd,cue)= currentSubj(includedSession).periNS.NSzblue(:,:,cue);
                NSpurple(trialInd,cue)= currentSubj(includedSession).periNS.NSzpurple(:,:,cue);
                
               % Get normalized signal in z score by default unless you want 'raw' e.g. dff 
                if (strcmp(normalizeMode, 'z'))
                    if~isempty(currentSubj(includedSession).periNSpox.NSzpoxblue) %lazy exception for now
                        NSbluePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSzpoxblue(:,:,cue);
                        NSpurplePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSzpoxpurple(:,:,cue);
                    end

                    if~isempty(currentSubj(includedSession).periNSlox.NSzloxblue) %lazy exception for now
                        NSblueLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSzloxblue(:,:,cue);
                        NSpurpleLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSzloxpurple(:,:,cue);
                    end
                else %else get 'raw' e.g. dff 
                    
                    if~isempty(currentSubj(includedSession).periNSpox.NSpoxblue) %lazy exception for now
                        NSbluePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSpoxblue(:,:,cue);
                        NSpurplePox(trialInd,cue)= currentSubj(includedSession).periNSpox.NSpoxpurple(:,:,cue);
                    end

                    if~isempty(currentSubj(includedSession).periNSlox.NSloxblue) %lazy exception for now
                        NSblueLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSloxblue(:,:,cue);
                        NSpurpleLox(trialInd,cue)= currentSubj(includedSession).periNSlox.NSloxpurple(:,:,cue);
                    end
                end
                    %get first NS pox only for latency corr
                if ~isempty( currentSubj(includedSession).behavior.poxNSrel{cue})
                    poxNSrel(trialInd, cue)= currentSubj(includedSession).behavior.poxNSrel{cue}(1);
                else
                     poxNSrel(trialInd, cue)= nan;
                end
              
                %get first NS lox only for plots (heatmaps)
                 if ~isempty( currentSubj(includedSession).behavior.loxNSrel{cue})
                    loxNSrel(trialInd, cue)= currentSubj(includedSession).behavior.loxNSrel{cue}(1);
                else
                     loxNSrel(trialInd, cue)= nan;
                end
                    
                    
                
                NStrialID(trialInd,cue)= cue;
                NStrialOutcome(trialInd,cue)= currentSubj(includedSession).trialOutcome.NSoutcome(cue);

                NStrialIDcum(trialInd,cue)= NStrialCountCum;
                NStrialCountCum= NStrialCountCum+1;
                
                trialIDcum(trialInd, cue)= allTrialCountCum;
                allTrialCountCum= allTrialCountCum+1;
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
            
            %dp 2022-07-06 TODO: move to new script post data exclusion
            %dp 2022-06-19 labelling specific sessions for plotting
            %--Save string labels to mark specific days for plotting
            if currentSubj(includedSession).behavior.criteriaSes==1
               criteriaDayThisStage= criteriaDayThisStage+1; 
            end
                        
            % TODO: criteria ses labelling is wrong here. have multiple
            % sessions
            
            if thisStage==5 && trainDayThisStage==1 
                sesSpecialLabel(:)= {'stage-5-day-1'};
            elseif thisStage==5 && criteriaDayThisStage==1
                sesSpecialLabel(:)= {'stage-5-day-1-criteria'};
            elseif thisStage==7 && criteriaDayThisStage==1
                sesSpecialLabel(:)= {'stage-7-day-1-criteria'};
                
            %easy mark of final day of stage 5
            elseif thisStage==5 && includedSession == max(includedSessions)
                sesSpecialLabel(:)= {'stage-5-final-day'};
            
                
            %easy mark of final day of stage 7
            elseif thisStage==7 && includedSession == max(includedSessions)
                sesSpecialLabel(:)= {'stage-7-final-day'};
            end
            
            
            
            %Save data into table
            periEventTable.fileID(tsInd)= sesCount;
            
            periEventTable.trainDay(tsInd)= currentSubj(includedSession).trainDay;
          
            periEventTable.trainDayThisStage(tsInd)= trainDayThisStage;
            
            periEventTable.sesSpecialLabel(tsInd)= sesSpecialLabel(:);
            
            periEventTable.DStrialID(tsInd)= DStrialID(:);
            
            periEventTable.DStrialOutcome(tsInd)= DStrialOutcome(:);
            
            periEventTable.DSblueRaw(tsInd)= DSblueRaw(:);
            periEventTable.DSpurpleRaw(tsInd)= DSpurpleRaw(:);
            
            periEventTable.DSblue(tsInd)= DSblue(:);
            periEventTable.DSpurple(tsInd)= DSpurple(:);
            periEventTable.DSbluePox(tsInd)= DSbluePox(:);
            periEventTable.DSpurplePox(tsInd)= DSpurplePox(:);
            periEventTable.DSblueLox(tsInd)= DSblueLox(:);
            periEventTable.DSpurpleLox(tsInd)= DSpurpleLox(:);
            
            periEventTable.poxDSrel(tsInd)= poxDSrel(:);
            periEventTable.loxDSrel(tsInd)= loxDSrel(:);
            
            periEventTable.loxDSpoxRel(tsInd)= loxDSpoxRel(:);
            
            %dp 2023-08-15 saving lick count per trial for review
            periEventTable.loxDSrelAllThisTrial(tsInd)= loxDSrelAllThisTrial(:);
            periEventTable.loxDSrelCountAllThisTrial(tsInd)= loxDSrelCountAllThisTrial(:);
            
            
            %--
            periEventTable.pumpID(tsInd)= pumpID(:);
            periEventTable.rewardID(tsInd)= rewardID(:);


            periEventTable.DStrialIDcum(tsInd)= DStrialIDcum(:);
            periEventTable.NStrialIDcum(tsInd)= NStrialIDcum(:);

            %not a truly unique trialID (shared between DS/NS still due to
            %how this table is set up, but could be useful later in
            %stacking DS vs NS to get truly unique ID)
            periEventTable.trialIDcum(tsInd)= trialIDcum(:); %dp wont work since shared by DS & NS, should be computed after stacking later
            
            
            periEventTable.NStrialID(tsInd)= NStrialID(:);
            
            periEventTable.NStrialOutcome(tsInd)= NStrialOutcome(:);

            periEventTable.NSblue(tsInd)= NSblue(:);
            periEventTable.NSpurple(tsInd)= NSpurple(:);
            periEventTable.NSbluePox(tsInd)= NSbluePox(:);
            periEventTable.NSpurplePox(tsInd)= NSpurplePox(:);
            periEventTable.NSblueLox(tsInd)= NSblueLox(:);
            periEventTable.NSpurpleLox(tsInd)= NSpurpleLox(:);
            
            periEventTable.poxNSrel(tsInd)= poxNSrel(:);
            periEventTable.loxNSrel(tsInd)= loxNSrel(:);

            
            time= repmat(currentSubj(includedSession).periDS.timeLock(:),[1,size(DSblue,2)]);
            periEventTable.timeLock(tsInd)= time(:); 
            periEventTable.subject(tsInd)= {subjects{subj}};
            periEventTable.date(tsInd)= {num2str(currentSubj(includedSession).date)};
            periEventTable.stage(tsInd)= currentSubj(includedSession).trainStage;
                     
            periEventTable.DSpeRatio(tsInd)= currentSubj(includedSession).behavior.tensecDSpeRatio;
            periEventTable.NSpeRatio(tsInd)= currentSubj(includedSession).behavior.tensecNSpeRatio;
            
            %label if this ses met behavioral criteria
            periEventTable.criteriaSes(tsInd)= currentSubj(includedSession).behavior.criteriaSes;
            
            sesCount=sesCount+1;
            trainDayThisStage= trainDayThisStage+1;
        end %end session loop
    end %end stage loop
end %end subj loop


%save an 'index' column for easy reassignment of new values into table
periEventTable(:,"index")= table([1:size(periEventTable,1)]');



%% 2022-11-04 examining licks before PE

ind=[];

ind= periEventTable.poxDSrel>periEventTable.loxDSrel;

test= periEventTable(ind,:);

%2023-08-16 some remain... 
unique(test.DStrialOutcome)

test2= test(test.DStrialOutcome==1,:);

% i think this file is fine and i just misread the session, other trial was
% inPort so would be fine
% % seeing rat8 20200101 trial 3. 
% % DS= [226.831237120000], PE= {227.201187840000}, lick= {227.418931200000} so before PE
% % result is a very low DSloxRel and DSloxRel<DSpoxRel... in addition there
% % is timelocked periDSloxBlue... How is this not removed by this point?
% % DStrialOutcome = 1
% subjDataAnalyzed.('rat8')(16).behavior.loxDSrel{3}(1)
% subjDataAnalyzed.('rat8')(16).behavior.poxDSrel{3}(1)


%now 8/17 not seeing this??
% same session and trial as above, DS= [226.831237120000], pox= {{227.201187840000}}, lox= {227.418931200000}

%ran behaviora analysis lick cleaning a bit and now reporting fine as
% poxDS= 227.2012, poxDSRel= 0.37, lick= 227.4189, loxDSRel= 0.5877 

%to double check, ran behavioral analysis lick cleaning full. haven't run
%exclude data yet

%yeah now unique(test.DStrialOutcome is only== 3)... data I loaded must not have
%been lick cleaned

% %revised licks .. pre 2023-03-18 criteriaSes fix
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-09-Nov-2022subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat")

% % I loaded: later date than above 'revised licks' so unclear why licks
% were not cleaned.
% %2023-03-18 revised DS/NS ratios (criteriaSes based on 10sec ratio)
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\broken up code\VP-VTA-FP-18-Mar-2023subjDataAnalyzed_airPLS_modeFitFP-airPLS.mat")

% manuscript repo - Q: Did this have licks cleaned?
% load("C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_mockups\vp-vta-fp-14-Jun-2023-periEventTableManuscript.mat");

% that was based on fp_manuscript_plots_2.m which does indeed load the lick
% cleaned data... still idk why the march 2023 file doesn't have cleaned licks
%but, just going to go back and load the correct one:
% % %revised licks
% pathData = "C:\Users\Dakota\Documents\GitHub\FP-analysis\matlabVPFP\_dp_manuscript\_figures\_allSes\vp-vta-fp-airPLS-09-Nov-2022periEventTable.mat";


%-- ok after loading correct still getting test.DStrialOutcome 1 and 3
%only seems like 1 trial exception though? rat14, 20200915 (session 18), trial 12
%DS= [1344.80936960000], poxDS= {1348.58702848000}, loxDS= [1345.65838848000][1349.65706752000]
% how did this get past cleaning? should have definitely been removed

%defined in periEventTable as currentSubj(includedSession).behavior.loxDSrel{cue}(1)
% this loxDSrel should have been removed in behavioral_analysis script
% single trial exception from 2022-09-11 subjDataAnalyzed file:
% trialIDcum 13089
subjDataAnalyzed.('rat14')(18).behavior.loxDSrel{12}(1)

%problem could theoretically be related to deleting loxDSrel =[] and index
%mismatch with loxDS ... but it doesn't matter. should have worked:

%^ doesn't really matter. should still have worked fine. Just ran lick cleaning
%section manually and it works fine. Rerunning this now
%after manually running lick cleaning and this there's no remaining invalid
%licks with DStrialOutcome==1. makes no sense. clear memory and start
%fresh.

%after clearing memory and loading in fresh, still that one trial exception


%compare to the newer subjDataAnalyzed real quick:


unique(test.DStrialOutcome)

test2= test(test.DStrialOutcome==1,:);

unique(test2.trialIDcum)

%% 2023-08-15 quick viz of lick count distribution

data= periEventTable;

%- SUBSET data
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

% subset data- by PE outcome; only include trials with valid PE post-cue
ind=[];
ind= data.DStrialOutcome==1;

data= data(ind,:);

% subset data- by lick; only include trials with valid lick counted
ind= [];
ind= data.loxDSrelCountAllThisTrial>=1;

data= data(ind,:);


%-- subset to one observation per trial
%use findgroups to groupby trialIDcum and subset to 1 observation per trial
data2= table();
data3= table();

data2= data;
groupIDs= [];
groupIDs= findgroups(data2.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

% ignore nan trialIDcums (not sure where these came from)
groupIDsUnique= groupIDsUnique(~isnan(groupIDsUnique));

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

data3= data2;


%-- summary by within-subject, within-session
test= [];
test= groupsummary(data3, ["subject", "fileID"], "all",["loxDSrelCountAllThisTrial"]);

%% 
%--time series within-subj, within-session?
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];


%individual session lines
group=data3.fileID;
g= gramm('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.facet_grid([],data3.subject);
g.set_title('Figure 3 Supplement: Time Series of Lick Count');
% g.geom_point();
g.geom_line();
g.set_color_options('map',cmapSubj);
g.set_line_options('base_size',linewidthSubj);
g.draw();

%between session mean top
group= data3.subject;
g.update('x', data3.DStrialID, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.stat_summary('geom','area', 'type', 'sem');
g.set_color_options('map',cmapGrand);
g.set_line_options('base_size',linewidthGrand);
g.draw();

%% 
%--distro within-subj, within-session?
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];

%subj mean
group= data3.subject;
g= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.set_title('Figure 3 Supplement: Lick Count Distribution');
% g.geom_point();
% g.geom_line();
g.stat_boxplot('dodge', dodge, 'width', 5);
g.set_color_options('map',cmapGrand);

g.draw();

%ind sessions
group= data3.fileID;
g.update('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.geom_point();
g.no_legend();
% g.geom_line();
g.set_color_options('map',cmapSubj);

%-make horizontal
g.coord_flip();
% g.draw();

%%-- next step for correlation would be to correlate/viz peri-PE with lick
%count

%- overlay grand mean lick count

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);

lickMean= [];
lickMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
g.geom_hline('yintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

%final draw call
g.draw();


%% old
%-- viz
figure;
g=[];
group= data3.fileID;
g.update('x', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.stat_bin();
g.geom_point();
g.draw();

%% 
%-boxplot distro of PE latency by subj
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
g=[];
group=[];
g= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g.set_title('Figure 3 Supplement: Distribution of Trial Raw Lick Count');
g.set_names('y','Lick Count','x','Subject','color','Subject', 'column', '');

g.set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


% g.stat_boxplot();
g.stat_boxplot('dodge', dodge, 'width', 5);
g.set_color_options('map',cmapGrand);
g.no_legend();
g.draw();

%- overlay individual subj
group= data3.subject;
g.update('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);
g.geom_point();
g.set_color_options('map',cmapSubj);
g.set_line_options('base_size',linewidthSubj);
g.no_legend();
% g.draw();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);

latMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
g.geom_hline('yintercept', latMean, 'style', 'm--', 'linewidth',linewidthReference); 

%-make horizontal
g.coord_flip();

%- final draw call
g.draw();



%%  
%-grand boxplot distro of trial lick count
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];
% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

g(1,1)= gramm('x', data3.loxDSrelCountAllThisTrial, 'group', group);

g(1,1).set_title('Between-Subjects');

g(1,1).axe_property('XLim',[0,70], 'YLim', [0,0.1]);

g(1,1).set_names('y','','x','Trial Raw Lick Count','color','', 'column', '');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


% % g(1,1).stat_boxplot();
% % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
g(1,1).stat_bin('geom','bar','normalization','pdf');
% % g(1,1).stat_violin(); %violin not working with 1d?
% % g(1,1).stat_violin('half','true');
% g(1,1).stat_bin('geom','bar');

g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["loxDSrelCountAllThisTrial"]);

lickMean= nanmean(data4.mean_loxDSrelCountAllThisTrial);
g(1,1).geom_vline('xintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

%- (2,1) overlay individual subj
g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);

g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
g(2,1).update('y', data3.loxDSrelCountAllThisTrial, 'x', data3.subject, 'color', data3.subject, 'group', group);

g(2,1).geom_point();

% % g(2,1).update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g(2,1).geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)

g(2,1).geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


g(2,1).set_title('Individual Subjects');


g(2,1).axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Lick Counts');

%- final draw call
g.draw();

% comparing grand mean methods 
% latTableF= [];
% latTableF= groupsummary(data3, ["subject"], 'all', "poxDSrel");
% 
% nanmean(data3.poxDSrel)
% 
% nanmean(data3.poxDSrel)
% 
% nanmean(latTableF.mean_poxDSrel) % Correct like below! this was plotted and reported for Fig3F
% 
% correct!
% %  % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
% % test= groupsummary(data3, ["subject"], "mean",["poxDSrel"]);

titleFig='vp-vta_Figure3_supplement_lickCount_distro';
saveFig(gcf, figPath, titleFig, figFormats);

%% despite appropriate lick cleaning and restriction to trials with valid PE, there appear to be some trials with very few licks

% just visually confirm lox > pox ?
figure;
hold on;
scatter(data3.poxDSrel, data3.loxDSrel);

% %- no remaining trials where lick before PE
% test=[];
% test= data3(data3.poxDSrel>data3.loxDSrel,:);
% figure;
% hold on;
% scatter(test.poxDSrel, test.loxDSrel);
% % no trials included with lox before pox


%% -- Viz of PE vs lick latency

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('x', data3.poxDSrel, 'y', data3.loxDSrel, 'color', data3.subject, 'group', group);

g(1,1).geom_point();

g(1,1).set_title('PE vs Lick latency');
g(1,1).set_names('x', 'PE latency', 'y', 'Lick latency');

%first draw
g(1,1).draw


%% -- Viz of lick count by latency

% heat plot might help resolve density here...

%interesting. relationship between lick count and latency is mostly linear
%but there are some notable low lick count trials event when the latency to first lick is
%quick.

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.loxDSrel, 'color', data3.subject, 'group', group);

g(1,1).geom_point();

g(1,1).set_title('Lick Count vs Lick latency');
g(1,1).set_names('y', 'Lick Count', 'x', 'Lick latency');

%first draw
g(1,1).draw


%% -- bin by lick count and viz peri-PE 
% then can try correlation

%---- Subset data

data= periEventTable;

%- SUBSET data
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

% subset data- by PE outcome; only include trials with valid PE post-cue
ind=[];
ind= data.DStrialOutcome==1;

data= data(ind,:);

% subset data- by lick; only include trials with valid lick counted
ind= [];
ind= data.loxDSrelCountAllThisTrial>=1;

data= data(ind,:);


% for binning and faceting copy code from fp_manuscript_session_correlation


%initialize columns
data(:,'lickCountBin')= table(nan);
data(:,'lickCountBinEdge')= table(nan);

%----convert lick Count into n bins 
%quick and dirty binning using discretize() 

nBins=[];
nBins= 5;

y= [];
e= [];

[y, e]= discretize(data.loxDSrelCountAllThisTrial, nBins);

data.lickCountBin= y;

%save labels of bin edges too 
for bin= 1:numel(e)-1
    
    ind= [];
    ind= data.lickCountBin== bin;
    
   data(ind, "lickCountBinEdge")= table(e(bin)); 
end


%-----
% Vizualize periDSPE, faceted by lick count bin



% ---- Add Plots of peri-event mean traces

%- subset data (relying on above)
%- note: keep full time series for viz
data= data;

clear gPeriEvent

%- aesthetics
xlimTraces= [-2,10];
ylimTraces= [-2,5];

% yTickTraces= [0:2:10] 
xTickTraces= [-2:2:10]; % ticks every 2s
% xTickTraces= [-2:1:10]; % ticks every 1s

xTickHeat= [-4:2:10]; %expanded to capture longer PE latencies
xLimHeat= [-4,10];

yLimCorrelation= [-0.5, 0.5];
xLimCorrelation= [-2,5];
xTickCorrelation= [-2:2:5];

errorBar='sem';




%stack() the data by eventType
data3= data;

%all 3 events:
data3= stack(data3, {'DSblue', 'DSbluePox', 'DSblueLox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

% % DS and PE only
% data3= stack(data3, {'DSblue', 'DSbluePox'}, 'IndexVariableName', 'eventType', 'NewDataVariableName', 'periEventBlue');
% % %flip the color order so that PE is consistent with fig2 (purple)
% % % cmapGrand= cmapPEGrand;
% % % cmapSubj= cmapPESubj;
% cmapGrand= flip(cmapPEGrand);
% cmapSubj= flip(cmapPESubj);

% - rename eventTypes so auto faceting are in order of events
%manually relabel trialType for clarity
%convert categorical to string then search 
% data3(:,"eventType")= {''};

 %make labels matching each 'trialType' and loop thru to search/match
trialTypes= {'DSblue', 'DSbluePox', 'DSblueLox'};
trialTypeLabels= {'1_Peri-DS','2_Peri-PE', '3_Peri-Lick'};

for thisTrialType= 1:numel(trialTypes)
    ind= [];
    
    ind= strcmp(string(data3.eventType), trialTypes(thisTrialType));

    data3(ind, 'eventType')= {trialTypeLabels(thisTrialType)};
    
end



% ---- 2023-04-06
 %Mean/SEM update
 %instead of all trials, simplify to mean observation per subject
 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data?
% data3= groupsummary(data3, ["subject","stage","eventType", "timeLock"], "mean",["periEventBlue"]);

data3= groupsummary(data3, ["subject","stage", "lickCountBinEdge", "eventType", "timeLock"], "mean",["periEventBlue"]);


% making new field with original column name to work with rest of old code bc 'mean_' is added 
data3.periEventBlue= data3.mean_periEventBlue;



% - Individual Subj lines
group= data3.subject;

figure;

clear gPeriEvent;

gPeriEvent(1,1)= gramm('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1).facet_grid(data3.lickCountBinEdge,data3.eventType);


% gPeriEvent(1,1).geom_line();
gPeriEvent(1,1).stat_summary('type',errorBar,'geom','line');


% i2.set_title(titleFig); 
gPeriEvent(1,1).set_color_options('map',cmapSubj);
gPeriEvent(1,1).set_line_options('base_size',linewidthSubj);
gPeriEvent(1,1).set_names('x','Time from event (s)','y','GCaMP (Z-Score)','color','Event Type', 'column', 'Event Type', 'row', 'Trial Licks (Binned)');

gPeriEvent(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

%remove legend
gPeriEvent(1,1).no_legend();

%-set limits
gPeriEvent(1,1).axe_property('YLim',ylimTraces);
gPeriEvent(1,1).axe_property('XLim',xlimTraces);
gPeriEvent(1,1).axe_property('XTick',xTickTraces);

% gPeriEvent(1,1).axe_property('XLim',xLimHeat);
% gPeriEvent(1,1).axe_property('XTick',xTickHeat);


% % % % set parent uiPanel in overall figure
% gPeriEvent(1,1).set_parent(p2);
% gPeriEvent(1,1).set_parent(p1);


%- First Draw call
gPeriEvent(1,1).draw();

% -- Between subjects mean+SEM 
group=[]
gPeriEvent(1,1).update('x', data3.timeLock, 'y', data3.periEventBlue, 'color', data3.eventType, 'group', group);

gPeriEvent(1,1).stat_summary('type',errorBar,'geom','area');

gPeriEvent(1,1).set_color_options('map',cmapGrand);
gPeriEvent(1,1).set_line_options('base_size',linewidthGrand);


%remove legend
gPeriEvent(1,1).no_legend();


%- vline at 0 
gPeriEvent(1,1).geom_vline('xintercept', 0, 'style', 'k--', 'linewidth',linewidthReference); 


% %- save final draw til end
gPeriEvent(1,1).draw();



%% AUC PLOTS AFTER CALCULATED-- would run plot auc but can't do it yet bc calculated later in code

%% -- scatter, Viz of periDS auc by lick count

% heat plot might help resolve density here...

%interesting. relationship between lick count and latency is mostly linear
%but there are some notable low lick count trials event when the latency to first lick is
%quick.

clear g;
figure;

%-individual trial scatter by subj
group= data3.trialIDcum;
g(1,1)= gramm('y', data3.loxDSrelCountAllThisTrial, 'x', data3.aucDSblue, 'color', data3.subject, 'group', group);

g(1,1).geom_point();

g(1,1).set_title('Lick Count vs Peri-DS AUC');
g(1,1).set_names('y', 'Lick Count', 'x', 'Peri-DS AUC');

%first draw
g(1,1).draw





%% Plot by AUC (after running perieventplots and computing auc)

%note only computed periDS auc in perieventplots (not auc of peri PE/lick)

clear i1; 

dodge= 	1; %if dodge constant between point and bar, will align correctly
width= 1.8; %good for 2 bars w dodge >=1


%subset data- relying on above
data2=table();

data2= data;


%-- subset to one observation per trial
%use findgroups to groupby trialIDcum and subset to 1 observation per
groupIDs= [];
groupIDs= findgroups(data2.trialIDcum);

groupIDsUnique= [];
groupIDsUnique= unique(groupIDs);

data3=table(); 

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
data3=data2;

%DROP NANs for 2d plot
% data3= data3(~isnan(data3.periDSauc,:));

%-grand boxplot distro of trial lick count
cmapGrand= 'brewer_dark';
cmapSubj= 'brewer2';

figure;
clear g;
group=[];

% g= gramm('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);

% % g= gramm('x', data3.poxDSrel, 'group', group);
% % g.facet_grid(2,1, 'scale', 'free_y'); %trying to link axes manually but not working 

% %1d 

% g(1,1)= gramm('x', data3.loxDSrelCountAllThisTrial, 'group', group);
% 
% % % g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal

% 2d 
g(1,1)= gramm('x', data3.lickCountBinEdge, 'y', data3.aucDSblue, 'group', group);
% 
% g(1,1)= gramm('color', data3.lickCountBinEdge, 'x', data3.aucDSblue, 'group', group);
% g(1,1).facet_grid(data3.lickCountBinEdge,[]); %dont need facet for 1  signal


g(1,1).set_title('Between-Subjects');

% g(1,1).axe_property('XLim',[0,70], 'YLim', [0,0.1]);

g(1,1).set_names('y','','x','Peri-DS AUC','color','', 'row', 'Trial Lick Count (Binned)');

g(1,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles


g(1,1).stat_boxplot();
% % % g(1,1).stat_boxplot('dodge', dodge, 'width', 5);
% g(1,1).stat_bin('geom','bar','normalization','pdf');
% % % g(1,1).stat_violin(); %violin not working with 1d?
% % % g(1,1).stat_violin('half','true');
% % g(1,1).stat_bin('geom','bar');

% g(1,1).stat_bin('geom','bar','normalization','pdf');
% g(1,1).stat_density();


g(1,1).set_color_options('map',cmapGrand);
g(1,1).no_legend();

%- overlay grand mean pe latency

 % "Grand" mean+SEM should reflect mean and SEM of subject means, not mean and SEM of pooled data
data4=[];
data4= groupsummary(data3, ["subject"], "mean",["aucDSblue"]);

lickMean= nanmean(data4.mean_aucDSblue);
g(1,1).geom_vline('xintercept', lickMean, 'style', 'k--', 'linewidth',linewidthReference); 

g(1,1).draw();

% %- (2,1) overlay individual subj
% % -2d
g(2,1)= gramm('x', data3.aucDSblue, 'y', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);

% % g(2,1).facet_grid(data3.lickCountBinEdge,[]);

% %- 1d
% g(2,1)= gramm('x', data3.subject, 'y', data3.loxDSrelCountAllThisTrial, 'color', data3.subject, 'group', group);


g(2,1).set_title('Individual Subjects');
g(2,1).set_names('y','Trial Raw Lick Count','x','Subject','color','Subject', 'column', '');



g(2,1).set_text_options(text_options_DefaultStyle{:}); %apply default text sizes/styles

g(2,1).stat_boxplot('dodge', dodge, 'width', 5);
g(2,1).set_color_options('map',cmapGrand);
g(2,1).no_legend();

g(2,1).coord_flip();


g(2,1).draw();

%- overlay individual subj points
group= data3.subject;

%- 1d
% % g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('y', data3.aucDSblue, 'x', data3.subject, 'color', data3.subject, 'group', group);

%- 2d
g(2,1).update('y', data3.aucDSblue, 'x', data3.lickCountBinEdge, 'color', data3.subject, 'group', group);


g(2,1).geom_point();

% % g(2,1).update('y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('x', data3.subject, 'y', data3.poxDSrel, 'color', data3.subject, 'group', group);
% % g(2,1).update('y', data3.subject, 'x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% g(2,1).update('x', data3.poxDSrel, 'color', data3.subject, 'group', group);
% 
% g(2,1).geom_raster();
% % haviing issues with raster + boxplot combo (axes mismatch)

g(2,1).geom_hline('yintercept', latMean, 'style', 'k--', 'linewidth',linewidthReference); 


g(2,1).set_title('Individual Subjects');


% g(2,1).axe_property('XLim',[0,10.5], 'YLim', [0, 70]);

g(2,1).set_color_options('map',cmapSubj);
% g.set_line_options('base_size',linewidthSubj);
g(2,1).no_legend();

% g(2,1).draw();


%-make horizontal
% g(2,1).coord_flip();

g.set_title('Figure 3 Supplement: Distribution of Peri-DS AUC by Lick Count');

%- final draw call
g.draw();

titleFig='vp-vta_Figure3_supplement_periDSauc_by_lickCount';
% saveFig(gcf, figPath, titleFig, figFormats);



