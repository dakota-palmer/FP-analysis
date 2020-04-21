%% Trying deconvolution

%Assume that total fluorescence = Sum(event evoked fluorescence + noise)
%Assume that event evoked fluorescence is consistent (doesn't vary between trials)

%initialize variables
% eventMaskDS= zeros(1:numel(timeLock)); %this will only work for one session
flagThreshold= 0.2; %t in seconds to flag shifted event timestamps (since we shift event timestamps to make them match the downsampled time window) 

%first get timestamps of events    
trialCount= 0; %counter for total number of trials 

for subj= 1:numel(subjects) %for each subject
   currentSubj= subjDataAnalyzed.(subjects{subj}); %use this for easy indexing into the current subject within the struct
   for session = 1:numel(currentSubj) %for each training session this subject completed
       for cue= 1:numel(currentSubj(session).periDS.DS) %for each cue (trial) in this session
           trialCount=trialCount+1; %count all trials between sessions & subjects 
           
           if ~isempty(currentSubj(session).behavior.poxDS{cue}) %only run if PE during this cue
               poxDS{trialCount,:}= currentSubj(session).behavior.poxDS{cue}-currentSubj(session).periDS.DS(cue); %get timestamps of PEs relative to DS
           else
               poxDS{trialCount,:}= []; %if no pe during this trial, make empty
           end
           
           eventMaskDSpox(trialCount,:)= zeros(size(timeLock));
           
           %Important step!! Shifting event timestamp to match timeLock
          poxDS{trialCount,:}= interp1(timeLock,timeLock, poxDS{trialCount,:}, 'nearest'); %shift the event timestamp to the nearest in cutTime;
            
           if ~isempty(poxDS{trialCount,:}) %only run if there's a valid pe on this trial
              eventMaskDSpox(timeLock(1,:)==poxDS{trialCount,:}(1))= 1;  %replace 0s with 1s for first pe on this trial
              
              %flag event timestamps that have shifted too much
                timeShift(trialCount)= abs(poxDS{trialCount,:}(1)-currentSubj(session).behavior.poxDS{cue}(1));
                if abs(timeShift) >flagThreshold %this will flag cues whose time shift deviates above a threshold (in seconds)
                    disp(strcat('>>Error *big pox time shift ', num2str(timeShift(trialCount)), 'shifted pox ', num2str(poxDS{cue}(1))));
                end                
           end
           
       end %end cue (trial) loop
   end %end session loop
end %end subject loop


%% visualization
scatter(timeLock(find(eventMaskDSpox(eventMaskDSpox==1))), ones(1,numel(eventMaskDSpox(eventMaskDSpox==1))));

% eventMaskDSpox= zeros(size(timeLock));

