%% Trying deconvolution

%Assume that total fluorescence = Sum(event evoked fluorescence + noise)
%Assume that event evoked fluorescence is consistent (doesn't vary between trials)

%initialize variables
% eventMaskDS= zeros(1:numel(timeLock)); %this will only work for one session
flagThreshold= 0.2; %t in seconds to flag shifted event timestamps (since we shift event timestamps to make them match the downsampled time window) 

%first get timestamps of events    
trialCount= 0; %counter for total number of trials 

clear eventMaskDSpox timeShift poxDS 

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       for cue= 1:numel(currentSubj(session).periDS.DS) %for each cue (trial) in this session
           trialCount=trialCount+1; %count all trials between sessions & subjects 
       %Get PE timestamps
           if ~isempty(currentSubj(session).behavior.poxDS{cue}) %only run if PE during this cue
               poxDS{trialCount,:}= currentSubj(session).behavior.poxDS{cue}-currentSubj(session).periDS.DS(cue); %get timestamps of PEs relative to DS
           else
               poxDS{trialCount,:}= []; %if no pe during this trial, make empty
           end
           
           eventMaskDSpox(trialCount,:)= zeros(size(timeLock));
           
           %Important step!! Shifting event timestamp to match timeLock
          poxDS{trialCount,:}= interp1(timeLock,timeLock, poxDS{trialCount,:}, 'nearest'); %shift the event timestamp to the nearest in cutTime;
            
           if ~isempty(poxDS{trialCount,:}) %only run if there's a valid pe on this trial
              eventInd= find(timeLock(1,:)==poxDS{trialCount,:}(1)); %get index of timestamp corresponding to this event
              eventMaskDSpox(trialCount,eventInd)= 1;  %replace 0s with 1s for first pe on this trial
                            
              %flag event timestamps that have shifted too much
                timeShift(trialCount)= abs(poxDS{trialCount,:}(1)-currentSubj(session).behavior.DSpeLatency(cue));
                if abs(timeShift(trialCount)) >flagThreshold %this will flag cues whose time shift deviates above a threshold (in seconds)
                    disp(strcat('>>Error *big pox time shift_', num2str(timeShift(trialCount)), '; subj_', num2str(subj), '; sess_', num2str(session), '; cue_',num2str(cue)));
                end                
           end
           
          %Get DSz 465nm photometry signal
          DSzblueAllTrials(trialCount,:)= currentSubj(session).periDS.DSzblue(:,:,cue);
          
          %Add subj label for this trial
          subjLabel(trialCount,:)= subj;
           
          %Add trial type label for this trial
          trialTypeLabel(trialCount,:)= 1; %1 for DS
       end %end cue (trial) loop
   end %end session loop
end %end subject loop


%% visualization- just checking if event timestamp mask looks appropriate (should be no negative PE timestamps etc.)
%really slow bc scattering in a loop

figure;
hold on; 
for trial= 1:trialCount
    if ~isempty(find(eventMaskDSpox(trial,:)==1))
    %     scatter(timeLock(find(eventMaskDSpox(trial,:)==1)), ones(1,numel(eventMaskDSpox(eventMaskDSpox(trial,:)==1))));
    end
end

%% linear model

%Get data into proper table format
%Each column= variable (including response variable y, predictive variables x, and grouping variables g)
%Each row= observation
DSzblueAllTrials= DSzblueAllTrials(:); %vectorize into 1 column
eventMaskDSpox= eventMaskDSpox(:); %vectorize into 1 column

DSzblueModelTable= table(eventMaskDSpox,DSzblueAllTrials);

%generate linear model
fitlm(DSzblueModelTable);


